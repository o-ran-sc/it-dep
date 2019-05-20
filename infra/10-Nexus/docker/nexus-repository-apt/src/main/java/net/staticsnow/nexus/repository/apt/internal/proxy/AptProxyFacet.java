/*
 * Nexus APT plugin.
 * 
 * Copyright (c) 2016-Present Michael Poindexter.
 * 
 * This program and the accompanying materials are made available under the terms of the Eclipse Public License Version 1.0,
 * which accompanies this distribution and is available at http://www.eclipse.org/legal/epl-v10.html.
 *
 * "Sonatype" and "Sonatype Nexus" are trademarks of Sonatype, Inc.
 */

package net.staticsnow.nexus.repository.apt.internal.proxy;

import static com.google.common.base.Preconditions.checkState;
import static org.sonatype.nexus.repository.storage.MetadataNodeEntityAdapter.P_NAME;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URI;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

import javax.inject.Named;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.DateUtils;
import org.apache.http.client.utils.HttpClientUtils;
import org.joda.time.DateTime;
import org.sonatype.nexus.common.collect.AttributesMap;
import org.sonatype.nexus.repository.Facet;
import org.sonatype.nexus.repository.cache.CacheController;
import org.sonatype.nexus.repository.cache.CacheInfo;
import org.sonatype.nexus.repository.httpclient.HttpClientFacet;
import org.sonatype.nexus.repository.proxy.ProxyFacet;
import org.sonatype.nexus.repository.proxy.ProxyFacetSupport;
import org.sonatype.nexus.repository.proxy.ProxyServiceException;
import org.sonatype.nexus.repository.storage.Asset;
import org.sonatype.nexus.repository.storage.Bucket;
import org.sonatype.nexus.repository.storage.StorageTx;
import org.sonatype.nexus.repository.view.Content;
import org.sonatype.nexus.repository.view.Context;
import org.sonatype.nexus.repository.view.payloads.HttpEntityPayload;
import org.sonatype.nexus.transaction.Transactional;
import org.sonatype.nexus.transaction.UnitOfWork;

import com.google.common.base.Strings;
import com.google.common.net.HttpHeaders;
import com.orientechnologies.common.concur.ONeedRetryException;

import net.staticsnow.nexus.repository.apt.AptFacet;
import net.staticsnow.nexus.repository.apt.internal.snapshot.AptSnapshotHandler;
import net.staticsnow.nexus.repository.apt.internal.snapshot.SnapshotItem;
import net.staticsnow.nexus.repository.apt.internal.snapshot.SnapshotItem.ContentSpecifier;

@Named
@Facet.Exposed
public class AptProxyFacet
    extends ProxyFacetSupport
{

  public List<SnapshotItem> getSnapshotItems(List<SnapshotItem.ContentSpecifier> specs) throws IOException {
    return fetchLatest(specs);
  }

  @Override
  protected Content getCachedContent(Context context) throws IOException {
    return getAptFacet().get(assetPath(context));
  }

  @Override
  protected Content store(Context context, Content content) throws IOException {
    if (assetPath(context).endsWith("Release")) {
      // Whenever we fetch a new release file, make sure we get the signature
      // and package files that go along with it.
      cacheControllerHolder.getMetadataCacheController().invalidateCache();
    }
    return getAptFacet().put(assetPath(context), content);
  }

  @Transactional(retryOn = { ONeedRetryException.class })
  @Override
  protected void indicateVerified(Context context, Content content, CacheInfo cacheInfo) throws IOException {
    doIndicateVerified(content, cacheInfo, assetPath(context));
  }

  @Override
  protected String getUrl(Context context) {
    return assetPath(context);
  }

  @Override
  protected CacheController getCacheController(Context context) {
    if (assetPath(context).endsWith(".deb") || assetPath(context).endsWith(".udeb")) {
      return cacheControllerHolder.getContentCacheController();
    }
    return cacheControllerHolder.getMetadataCacheController();
  }

  private String assetPath(Context context) {
    final AptSnapshotHandler.State snapshotState = context.getAttributes().require(AptSnapshotHandler.State.class);
    return snapshotState.assetPath;
  }

  private List<SnapshotItem> fetchLatest(List<ContentSpecifier> specs) throws IOException {
    try {
      return specs.stream().map(ioCheck(spec -> fetchLatest(spec))).filter(item -> item.isPresent())
          .map(item -> item.get()).collect(Collectors.toList());
    }
    catch (UncheckedIOException e) {
      throw e.getCause();
    }
  }

  private Optional<SnapshotItem> fetchLatest(ContentSpecifier spec) throws IOException {
    AptFacet aptFacet = getRepository().facet(AptFacet.class);
    ProxyFacet proxyFacet = facet(ProxyFacet.class);
    HttpClientFacet httpClientFacet = facet(HttpClientFacet.class);
    HttpClient httpClient = httpClientFacet.getHttpClient();
    CacheController cacheController = cacheControllerHolder.getMetadataCacheController();
    CacheInfo cacheInfo = cacheController.current();
    Content oldVersion = aptFacet.get(spec.path);

    URI fetchUri = proxyFacet.getRemoteUrl().resolve(spec.path);
    HttpGet getRequest = buildFetchRequest(oldVersion, fetchUri);

    HttpResponse response = httpClient.execute(getRequest);
    StatusLine status = response.getStatusLine();

    if (status.getStatusCode() == HttpStatus.SC_OK) {
      HttpEntity entity = response.getEntity();
      Content fetchedContent = new Content(new HttpEntityPayload(response, entity));
      AttributesMap contentAttrs = fetchedContent.getAttributes();
      contentAttrs.set(Content.CONTENT_LAST_MODIFIED, getDateHeader(response, HttpHeaders.LAST_MODIFIED));
      contentAttrs.set(Content.CONTENT_ETAG, getQuotedStringHeader(response, HttpHeaders.ETAG));
      contentAttrs.set(CacheInfo.class, cacheInfo);
      Content storedContent = getAptFacet().put(spec.path, fetchedContent);
      return Optional.of(new SnapshotItem(spec, storedContent));
    }

    try {
      if (status.getStatusCode() == HttpStatus.SC_NOT_MODIFIED) {
        checkState(oldVersion != null, "Received 304 without conditional GET (bad server?) from %s", fetchUri);
        doIndicateVerified(oldVersion, cacheInfo, spec.path);
        return Optional.of(new SnapshotItem(spec, oldVersion));
      }
      throwProxyExceptionForStatus(response);
    }
    finally {
      HttpClientUtils.closeQuietly(response);
    }

    return Optional.empty();
  }

  private HttpGet buildFetchRequest(Content oldVersion, URI fetchUri) {
    HttpGet getRequest = new HttpGet(fetchUri);
    if (oldVersion != null) {
      DateTime lastModified = oldVersion.getAttributes().get(Content.CONTENT_LAST_MODIFIED, DateTime.class);
      if (lastModified != null) {
        getRequest.addHeader(HttpHeaders.IF_MODIFIED_SINCE, DateUtils.formatDate(lastModified.toDate()));
      }
      final String etag = oldVersion.getAttributes().get(Content.CONTENT_ETAG, String.class);
      if (etag != null) {
        getRequest.addHeader(HttpHeaders.IF_NONE_MATCH, "\"" + etag + "\"");
      }
    }
    return getRequest;
  }

  private DateTime getDateHeader(HttpResponse response, String name) {
    Header h = response.getLastHeader(name);
    if (h != null) {
      try {
        return new DateTime(DateUtils.parseDate(h.getValue()).getTime());
      }
      catch (Exception ex) {
        log.warn("Invalid date '{}', will skip", h);
      }
    }
    return null;
  }

  private String getQuotedStringHeader(HttpResponse response, String name) {
    Header h = response.getLastHeader(name);
    if (h != null) {
      String value = h.getValue();
      if (!Strings.isNullOrEmpty(value)) {
        if (value.startsWith("\"") && value.endsWith("\"")) {
          return value.substring(1, value.length() - 1);
        }
        else {
          return value;
        }
      }
    }
    return null;
  }

  @Transactional(retryOn = { ONeedRetryException.class })
  protected void doIndicateVerified(Content content, CacheInfo cacheInfo, String assetPath) {
    StorageTx tx = UnitOfWork.currentTx();
    Bucket bucket = tx.findBucket(getRepository());

    Asset asset = Content.findAsset(tx, bucket, content);
    if (asset == null) {
      asset = tx.findAssetWithProperty(P_NAME, assetPath, bucket);
    }
    if (asset == null) {
      return;
    }
    CacheInfo.applyToAsset(asset, cacheInfo);
    tx.saveAsset(asset);
  }

  private void throwProxyExceptionForStatus(HttpResponse httpResponse) {
    final StatusLine status = httpResponse.getStatusLine();
    if (HttpStatus.SC_UNAUTHORIZED == status.getStatusCode() 
        || HttpStatus.SC_PAYMENT_REQUIRED == status.getStatusCode()
        || HttpStatus.SC_PROXY_AUTHENTICATION_REQUIRED == status.getStatusCode()
        || HttpStatus.SC_INTERNAL_SERVER_ERROR <= status.getStatusCode()) {
      throw new ProxyServiceException(httpResponse);
    }
  }

  private AptFacet getAptFacet() {
    return getRepository().facet(AptFacet.class);
  }

  @FunctionalInterface
  private interface IOExceptionFunction<T, R>
  {
    R apply(T t) throws IOException;
  }

  private static <T, R> Function<T, R> ioCheck(IOExceptionFunction<T, R> func) {
    return t -> {
      try {
        return func.apply(t);
      }
      catch (IOException e) {
        throw new UncheckedIOException(e);
      }
    };
  }
}
