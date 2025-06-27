--
-- ============LICENSE_START=======================================================
-- Copyright (C) 2024 Ericsson
-- Modifications Copyright (C) 2025 OpenInfra Foundation Europe
-- ================================================================================
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- SPDX-License-Identifier: Apache-2.0
-- ============LICENSE_END=========================================================
--

BEGIN;

CREATE SCHEMA IF NOT EXISTS teiv_consumer_data;
ALTER SCHEMA teiv_consumer_data OWNER TO topology_exposure_user;
SET default_tablespace = '';
SET default_table_access_method = heap;

SET ROLE topology_exposure_user;

CREATE TABLE IF NOT EXISTS teiv_consumer_data."module_reference" (
    "name"            TEXT PRIMARY KEY,
    "namespace"       TEXT,
    "revision"        TEXT NOT NULL,
    "content"         TEXT NOT NULL,
    "ownerAppId"      VARCHAR(511) NOT NULL,
    "status"          VARCHAR(127) NOT NULL
);

CREATE TABLE IF NOT EXISTS teiv_consumer_data."decorators" (
    "name"                TEXT PRIMARY KEY,
    "dataType"            VARCHAR(511) NOT NULL,
    "moduleReferenceName" TEXT NOT NULL,
    FOREIGN KEY ("moduleReferenceName") REFERENCES teiv_consumer_data."module_reference" ("name") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS teiv_consumer_data."classifiers" (
    "name"                TEXT PRIMARY KEY,
    "moduleReferenceName" TEXT NOT NULL,
    FOREIGN KEY ("moduleReferenceName") REFERENCES teiv_consumer_data."module_reference" ("name") ON DELETE CASCADE
);

COMMIT;
