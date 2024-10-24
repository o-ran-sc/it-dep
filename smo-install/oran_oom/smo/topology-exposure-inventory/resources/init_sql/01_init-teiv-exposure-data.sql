--
-- ============LICENSE_START=======================================================
-- Copyright (C) 2024 Ericsson
-- Modifications Copyright (C) 2024 OpenInfra Foundation Europe
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

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

GRANT USAGE ON SCHEMA topology to topology_exposure_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA topology TO topology_exposure_user;
GRANT SELECT ON ALL TABLES IN SCHEMA topology TO topology_exposure_user;

CREATE SCHEMA IF NOT EXISTS ties_data;
ALTER SCHEMA ties_data OWNER TO topology_exposure_user;
SET default_tablespace = '';
SET default_table_access_method = heap;

SET ROLE 'topology_exposure_user';

-- Function to create CONSTRAINT only if it does not exists
CREATE OR REPLACE FUNCTION ties_data.create_constraint_if_not_exists (
	t_name TEXT, c_name TEXT, constraint_sql TEXT
)
RETURNS void AS
$$
BEGIN
	IF NOT EXISTS (SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = t_name AND constraint_name = c_name) THEN
		EXECUTE constraint_sql;
	END IF;
END;
$$ language 'plpgsql';

-- Update data schema exec status
INSERT INTO ties_model.execution_status("schema", "status") VALUES ('ties_data', 'success');

CREATE TABLE IF NOT EXISTS ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" (
	"id"			TEXT,
	"aSide_NFDeployment"			TEXT,
	"bSide_NearRTRICFunction"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" (
	"id"			TEXT,
	"aSide_AntennaModule"			TEXT,
	"bSide_AntennaCapability"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" (
	"id"			TEXT,
	"name"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" (
	"id"			TEXT,
	"aSide_NFDeployment"			TEXT,
	"bSide_OCloudNamespace"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_NFDeployment" (
	"id"			TEXT,
	"name"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_comprised-by-cloudifiedNF"			TEXT,
	"REL_ID_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT"			TEXT,
	"REL_CD_sourceIds_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT"			jsonb,
	"REL_CD_classifiers_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT"			jsonb,
	"REL_CD_decorators_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT"			jsonb,
	"REL_FK_serviced-managedElement"			TEXT,
	"REL_ID_NFDEPLOYMENT_SERVES_MANAGEDELEMENT"			TEXT,
	"REL_CD_sourceIds_NFDEPLOYMENT_SERVES_MANAGEDELEMENT"			jsonb,
	"REL_CD_classifiers_NFDEPLOYMENT_SERVES_MANAGEDELEMENT"			jsonb,
	"REL_CD_decorators_NFDEPLOYMENT_SERVES_MANAGEDELEMENT"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "REL_CD_sourceIds_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "REL_CD_classifiers_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "REL_CD_decorators_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "REL_CD_sourceIds_NFDEPLOYMENT_SERVES_MANAGEDELEMENT" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "REL_CD_classifiers_NFDEPLOYMENT_SERVES_MANAGEDELEMENT" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NFDeployment" ALTER COLUMN "REL_CD_decorators_NFDEPLOYMENT_SERVES_MANAGEDELEMENT" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" (
	"id"			TEXT,
	"aSide_NodeCluster"			TEXT,
	"bSide_OCloudSite"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_NodeCluster" (
	"id"			TEXT,
	"name"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NodeCluster" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NodeCluster" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_NodeCluster" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" (
	"id"			TEXT,
	"name"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_deployed-on-nodeCluster"			TEXT,
	"REL_ID_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER"			TEXT,
	"REL_CD_sourceIds_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER"			jsonb,
	"REL_CD_classifiers_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER"			jsonb,
	"REL_CD_decorators_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ALTER COLUMN "REL_CD_sourceIds_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ALTER COLUMN "REL_CD_classifiers_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ALTER COLUMN "REL_CD_decorators_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-cloud_OCloudSite" (
	"id"			TEXT,
	"geo-location"			geography,
	"name"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudSite" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudSite" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-cloud_OCloudSite" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-equipment_AntennaModule" (
	"id"			TEXT,
	"antennaBeamWidth"			jsonb,
	"antennaModelNumber"			TEXT,
	"electricalAntennaTilt"			INTEGER,
	"geo-location"			geography,
	"mechanicalAntennaBearing"			INTEGER,
	"mechanicalAntennaTilt"			INTEGER,
	"positionWithinSector"			TEXT,
	"totalTilt"			INTEGER,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_installed-at-site"			TEXT,
	"REL_ID_ANTENNAMODULE_INSTALLED_AT_SITE"			TEXT,
	"REL_CD_sourceIds_ANTENNAMODULE_INSTALLED_AT_SITE"			jsonb,
	"REL_CD_classifiers_ANTENNAMODULE_INSTALLED_AT_SITE"			jsonb,
	"REL_CD_decorators_ANTENNAMODULE_INSTALLED_AT_SITE"			jsonb,
	"REL_FK_grouped-by-sector"			TEXT,
	"REL_ID_SECTOR_GROUPS_ANTENNAMODULE"			TEXT,
	"REL_CD_sourceIds_SECTOR_GROUPS_ANTENNAMODULE"			jsonb,
	"REL_CD_classifiers_SECTOR_GROUPS_ANTENNAMODULE"			jsonb,
	"REL_CD_decorators_SECTOR_GROUPS_ANTENNAMODULE"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "REL_CD_sourceIds_ANTENNAMODULE_INSTALLED_AT_SITE" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "REL_CD_classifiers_ANTENNAMODULE_INSTALLED_AT_SITE" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "REL_CD_decorators_ANTENNAMODULE_INSTALLED_AT_SITE" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "REL_CD_sourceIds_SECTOR_GROUPS_ANTENNAMODULE" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "REL_CD_classifiers_SECTOR_GROUPS_ANTENNAMODULE" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_AntennaModule" ALTER COLUMN "REL_CD_decorators_SECTOR_GROUPS_ANTENNAMODULE" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-equipment_Site" (
	"id"			TEXT,
	"geo-location"			geography,
	"name"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_Site" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_Site" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-equipment_Site" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-oam_ManagedElement" (
	"id"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_deployed-as-cloudifiedNF"			TEXT,
	"REL_ID_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF"			TEXT,
	"REL_CD_sourceIds_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF"			jsonb,
	"REL_CD_classifiers_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF"			jsonb,
	"REL_CD_decorators_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-oam_ManagedElement" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-oam_ManagedElement" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-oam_ManagedElement" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-oam_ManagedElement" ALTER COLUMN "REL_CD_sourceIds_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-oam_ManagedElement" ALTER COLUMN "REL_CD_classifiers_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-oam_ManagedElement" ALTER COLUMN "REL_CD_decorators_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_AntennaCapability" (
	"id"			TEXT,
	"eUtranFqBands"			jsonb,
	"geranFqBands"			jsonb,
	"nRFqBands"			jsonb,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_AntennaCapability" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_AntennaCapability" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_AntennaCapability" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_NRCellCU" (
	"id"			TEXT,
	"cellLocalId"			INTEGER,
	"nCI"			BIGINT,
	"nRTAC"			INTEGER,
	"plmnId"			jsonb,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_provided-by-ocucpFunction"			TEXT,
	"REL_ID_OCUCPFUNCTION_PROVIDES_NRCELLCU"			TEXT,
	"REL_CD_sourceIds_OCUCPFUNCTION_PROVIDES_NRCELLCU"			jsonb,
	"REL_CD_classifiers_OCUCPFUNCTION_PROVIDES_NRCELLCU"			jsonb,
	"REL_CD_decorators_OCUCPFUNCTION_PROVIDES_NRCELLCU"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellCU" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellCU" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellCU" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellCU" ALTER COLUMN "REL_CD_sourceIds_OCUCPFUNCTION_PROVIDES_NRCELLCU" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellCU" ALTER COLUMN "REL_CD_classifiers_OCUCPFUNCTION_PROVIDES_NRCELLCU" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellCU" ALTER COLUMN "REL_CD_decorators_OCUCPFUNCTION_PROVIDES_NRCELLCU" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_NRCellDU" (
	"id"			TEXT,
	"cellLocalId"			INTEGER,
	"nCI"			BIGINT,
	"nRPCI"			INTEGER,
	"nRTAC"			INTEGER,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_provided-by-oduFunction"			TEXT,
	"REL_ID_ODUFUNCTION_PROVIDES_NRCELLDU"			TEXT,
	"REL_CD_sourceIds_ODUFUNCTION_PROVIDES_NRCELLDU"			jsonb,
	"REL_CD_classifiers_ODUFUNCTION_PROVIDES_NRCELLDU"			jsonb,
	"REL_CD_decorators_ODUFUNCTION_PROVIDES_NRCELLDU"			jsonb,
	"REL_FK_grouped-by-sector"			TEXT,
	"REL_ID_SECTOR_GROUPS_NRCELLDU"			TEXT,
	"REL_CD_sourceIds_SECTOR_GROUPS_NRCELLDU"			jsonb,
	"REL_CD_classifiers_SECTOR_GROUPS_NRCELLDU"			jsonb,
	"REL_CD_decorators_SECTOR_GROUPS_NRCELLDU"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "REL_CD_sourceIds_ODUFUNCTION_PROVIDES_NRCELLDU" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "REL_CD_classifiers_ODUFUNCTION_PROVIDES_NRCELLDU" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "REL_CD_decorators_ODUFUNCTION_PROVIDES_NRCELLDU" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "REL_CD_sourceIds_SECTOR_GROUPS_NRCELLDU" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "REL_CD_classifiers_SECTOR_GROUPS_NRCELLDU" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRCellDU" ALTER COLUMN "REL_CD_decorators_SECTOR_GROUPS_NRCELLDU" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" (
	"id"			TEXT,
	"arfcnDL"			INTEGER,
	"arfcnUL"			INTEGER,
	"bSChannelBwDL"			INTEGER,
	"frequencyDL"			INTEGER,
	"frequencyUL"			INTEGER,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_used-by-nrCellDu"			TEXT,
	"REL_ID_NRCELLDU_USES_NRSECTORCARRIER"			TEXT,
	"REL_CD_sourceIds_NRCELLDU_USES_NRSECTORCARRIER"			jsonb,
	"REL_CD_classifiers_NRCELLDU_USES_NRSECTORCARRIER"			jsonb,
	"REL_CD_decorators_NRCELLDU_USES_NRSECTORCARRIER"			jsonb,
	"REL_FK_used-antennaCapability"			TEXT,
	"REL_ID_NRSECTORCARRIER_USES_ANTENNACAPABILITY"			TEXT,
	"REL_CD_sourceIds_NRSECTORCARRIER_USES_ANTENNACAPABILITY"			jsonb,
	"REL_CD_classifiers_NRSECTORCARRIER_USES_ANTENNACAPABILITY"			jsonb,
	"REL_CD_decorators_NRSECTORCARRIER_USES_ANTENNACAPABILITY"			jsonb,
	"REL_FK_provided-by-oduFunction"			TEXT,
	"REL_ID_ODUFUNCTION_PROVIDES_NRSECTORCARRIER"			TEXT,
	"REL_CD_sourceIds_ODUFUNCTION_PROVIDES_NRSECTORCARRIER"			jsonb,
	"REL_CD_classifiers_ODUFUNCTION_PROVIDES_NRSECTORCARRIER"			jsonb,
	"REL_CD_decorators_ODUFUNCTION_PROVIDES_NRSECTORCARRIER"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_sourceIds_NRCELLDU_USES_NRSECTORCARRIER" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_classifiers_NRCELLDU_USES_NRSECTORCARRIER" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_decorators_NRCELLDU_USES_NRSECTORCARRIER" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_sourceIds_NRSECTORCARRIER_USES_ANTENNACAPABILITY" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_classifiers_NRSECTORCARRIER_USES_ANTENNACAPABILITY" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_decorators_NRSECTORCARRIER_USES_ANTENNACAPABILITY" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_sourceIds_ODUFUNCTION_PROVIDES_NRSECTORCARRIER" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_classifiers_ODUFUNCTION_PROVIDES_NRSECTORCARRIER" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ALTER COLUMN "REL_CD_decorators_ODUFUNCTION_PROVIDES_NRSECTORCARRIER" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" (
	"id"			TEXT,
	"nearRtRicId"			BIGINT,
	"pLMNId"			jsonb,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_managed-by-managedElement"			TEXT,
	"REL_ID_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION"			TEXT,
	"REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION"			jsonb,
	"REL_CD_classifiers_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION"			jsonb,
	"REL_CD_decorators_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ALTER COLUMN "REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ALTER COLUMN "REL_CD_classifiers_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ALTER COLUMN "REL_CD_decorators_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_OCUCPFunction" (
	"id"			TEXT,
	"gNBCUName"			TEXT,
	"gNBId"			BIGINT,
	"gNBIdLength"			INTEGER,
	"pLMNId"			jsonb,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_managed-by-managedElement"			TEXT,
	"REL_ID_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION"			TEXT,
	"REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION"			jsonb,
	"REL_CD_classifiers_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION"			jsonb,
	"REL_CD_decorators_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ALTER COLUMN "REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ALTER COLUMN "REL_CD_classifiers_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ALTER COLUMN "REL_CD_decorators_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_OCUUPFunction" (
	"id"			TEXT,
	"gNBId"			BIGINT,
	"gNBIdLength"			INTEGER,
	"pLMNIdList"			jsonb,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_managed-by-managedElement"			TEXT,
	"REL_ID_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION"			TEXT,
	"REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION"			jsonb,
	"REL_CD_classifiers_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION"			jsonb,
	"REL_CD_decorators_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ALTER COLUMN "REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ALTER COLUMN "REL_CD_classifiers_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ALTER COLUMN "REL_CD_decorators_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_ODUFunction" (
	"id"			TEXT,
	"gNBDUId"			BIGINT,
	"gNBId"			BIGINT,
	"gNBIdLength"			INTEGER,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_managed-by-managedElement"			TEXT,
	"REL_ID_MANAGEDELEMENT_MANAGES_ODUFUNCTION"			TEXT,
	"REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_ODUFUNCTION"			jsonb,
	"REL_CD_classifiers_MANAGEDELEMENT_MANAGES_ODUFUNCTION"			jsonb,
	"REL_CD_decorators_MANAGEDELEMENT_MANAGES_ODUFUNCTION"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ODUFunction" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ODUFunction" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ODUFunction" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ODUFunction" ALTER COLUMN "REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_ODUFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ODUFunction" ALTER COLUMN "REL_CD_classifiers_MANAGEDELEMENT_MANAGES_ODUFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ODUFunction" ALTER COLUMN "REL_CD_decorators_MANAGEDELEMENT_MANAGES_ODUFUNCTION" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_ORUFunction" (
	"id"			TEXT,
	"oruId"			BIGINT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb,
	"REL_FK_managed-by-managedElement"			TEXT,
	"REL_ID_MANAGEDELEMENT_MANAGES_ORUFUNCTION"			TEXT,
	"REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_ORUFUNCTION"			jsonb,
	"REL_CD_classifiers_MANAGEDELEMENT_MANAGES_ORUFUNCTION"			jsonb,
	"REL_CD_decorators_MANAGEDELEMENT_MANAGES_ORUFUNCTION"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ORUFunction" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ORUFunction" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ORUFunction" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ORUFunction" ALTER COLUMN "REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_ORUFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ORUFunction" ALTER COLUMN "REL_CD_classifiers_MANAGEDELEMENT_MANAGES_ORUFUNCTION" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_ORUFunction" ALTER COLUMN "REL_CD_decorators_MANAGEDELEMENT_MANAGES_ORUFUNCTION" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-ran_Sector" (
	"id"			TEXT,
	"azimuth"			DECIMAL,
	"geo-location"			geography,
	"sectorId"			BIGINT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_Sector" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_Sector" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-ran_Sector" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" (
	"id"			TEXT,
	"aSide_NFDeployment"			TEXT,
	"bSide_OCUCPFunction"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" (
	"id"			TEXT,
	"aSide_NFDeployment"			TEXT,
	"bSide_OCUUPFunction"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

CREATE TABLE IF NOT EXISTS ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" (
	"id"			TEXT,
	"aSide_NFDeployment"			TEXT,
	"bSide_ODUFunction"			TEXT,
	"CD_sourceIds"			jsonb,
	"CD_classifiers"			jsonb,
	"CD_decorators"			jsonb
);

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" ALTER COLUMN "CD_sourceIds" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" ALTER COLUMN "CD_classifiers" SET DEFAULT '[]';

ALTER TABLE ONLY ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" ALTER COLUMN "CD_decorators" SET DEFAULT '{}';

SELECT ties_data.create_constraint_if_not_exists(
	'3C2E2CE7BDF8321BC824B6318B190690F58DBB82',
 'PK_82A1C5618438FF6DF7CDD48FD71E0A584E6D052A',
 'ALTER TABLE ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" ADD CONSTRAINT "PK_82A1C5618438FF6DF7CDD48FD71E0A584E6D052A" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'CFC235E0404703D1E4454647DF8AAE2C193DB402',
 'PK_63E61CB6802F21FE7A04A80A095F6AF8ABF067CE',
 'ALTER TABLE ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" ADD CONSTRAINT "PK_63E61CB6802F21FE7A04A80A095F6AF8ABF067CE" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_CloudifiedNF',
 'PK_o-ran-smo-teiv-cloud_CloudifiedNF_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" ADD CONSTRAINT "PK_o-ran-smo-teiv-cloud_CloudifiedNF_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE',
 'PK_E4FDDE2DC433209F933C7F53C9F72C1D2EB04BC6',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" ADD CONSTRAINT "PK_E4FDDE2DC433209F933C7F53C9F72C1D2EB04BC6" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDeployment',
 'PK_o-ran-smo-teiv-cloud_NFDeployment_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDeployment" ADD CONSTRAINT "PK_o-ran-smo-teiv-cloud_NFDeployment_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE',
 'PK_o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" ADD CONSTRAINT "PK_o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NodeCluster',
 'PK_o-ran-smo-teiv-cloud_NodeCluster_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NodeCluster" ADD CONSTRAINT "PK_o-ran-smo-teiv-cloud_NodeCluster_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_OCloudNamespace',
 'PK_o-ran-smo-teiv-cloud_OCloudNamespace_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ADD CONSTRAINT "PK_o-ran-smo-teiv-cloud_OCloudNamespace_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_OCloudSite',
 'PK_o-ran-smo-teiv-cloud_OCloudSite_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_OCloudSite" ADD CONSTRAINT "PK_o-ran-smo-teiv-cloud_OCloudSite_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-equipment_AntennaModule',
 'PK_o-ran-smo-teiv-equipment_AntennaModule_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-equipment_AntennaModule" ADD CONSTRAINT "PK_o-ran-smo-teiv-equipment_AntennaModule_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-equipment_Site',
 'PK_o-ran-smo-teiv-equipment_Site_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-equipment_Site" ADD CONSTRAINT "PK_o-ran-smo-teiv-equipment_Site_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-oam_ManagedElement',
 'PK_o-ran-smo-teiv-oam_ManagedElement_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-oam_ManagedElement" ADD CONSTRAINT "PK_o-ran-smo-teiv-oam_ManagedElement_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_AntennaCapability',
 'PK_o-ran-smo-teiv-ran_AntennaCapability_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_AntennaCapability" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_AntennaCapability_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellCU',
 'PK_o-ran-smo-teiv-ran_NRCellCU_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellCU" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_NRCellCU_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellDU',
 'PK_o-ran-smo-teiv-ran_NRCellDU_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellDU" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_NRCellDU_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'PK_o-ran-smo-teiv-ran_NRSectorCarrier_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_NRSectorCarrier_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NearRTRICFunction',
 'PK_o-ran-smo-teiv-ran_NearRTRICFunction_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_NearRTRICFunction_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_OCUCPFunction',
 'PK_o-ran-smo-teiv-ran_OCUCPFunction_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_OCUCPFunction_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_OCUUPFunction',
 'PK_o-ran-smo-teiv-ran_OCUUPFunction_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_OCUUPFunction_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_ODUFunction',
 'PK_o-ran-smo-teiv-ran_ODUFunction_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_ODUFunction" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_ODUFunction_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_ORUFunction',
 'PK_o-ran-smo-teiv-ran_ORUFunction_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_ORUFunction" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_ORUFunction_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_Sector',
 'PK_o-ran-smo-teiv-ran_Sector_id',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_Sector" ADD CONSTRAINT "PK_o-ran-smo-teiv-ran_Sector_id" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION',
 'PK_2D854968CB74C42C534D8E7C2A53E93F6B7F001F',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" ADD CONSTRAINT "PK_2D854968CB74C42C534D8E7C2A53E93F6B7F001F" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION',
 'PK_E551D02D14B3C04A565DC73A386BEB29627D3C08',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" ADD CONSTRAINT "PK_E551D02D14B3C04A565DC73A386BEB29627D3C08" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION',
 'PK_A10CB552A0F126991DD325EC84DBFAC6F2BBE1A3',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" ADD CONSTRAINT "PK_A10CB552A0F126991DD325EC84DBFAC6F2BBE1A3" PRIMARY KEY ("id");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'3C2E2CE7BDF8321BC824B6318B190690F58DBB82',
 'FK_BE847E738902EA979AC709D5A3D0CCD3FD8911CA',
 'ALTER TABLE ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" ADD CONSTRAINT "FK_BE847E738902EA979AC709D5A3D0CCD3FD8911CA" FOREIGN KEY ("aSide_NFDeployment") REFERENCES ties_data."o-ran-smo-teiv-cloud_NFDeployment" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'3C2E2CE7BDF8321BC824B6318B190690F58DBB82',
 'FK_CCC0DEA6E4ABAB8614332070E83D953254D5A3A5',
 'ALTER TABLE ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" ADD CONSTRAINT "FK_CCC0DEA6E4ABAB8614332070E83D953254D5A3A5" FOREIGN KEY ("bSide_NearRTRICFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'CFC235E0404703D1E4454647DF8AAE2C193DB402',
 'FK_D80D1E6B26DF620B4DE659C600A3B7F709A41960',
 'ALTER TABLE ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" ADD CONSTRAINT "FK_D80D1E6B26DF620B4DE659C600A3B7F709A41960" FOREIGN KEY ("aSide_AntennaModule") REFERENCES ties_data."o-ran-smo-teiv-equipment_AntennaModule" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'CFC235E0404703D1E4454647DF8AAE2C193DB402',
 'FK_7148BEED02C0617DE1DEEB6639F34A9FA9251B06',
 'ALTER TABLE ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" ADD CONSTRAINT "FK_7148BEED02C0617DE1DEEB6639F34A9FA9251B06" FOREIGN KEY ("bSide_AntennaCapability") REFERENCES ties_data."o-ran-smo-teiv-ran_AntennaCapability" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE',
 'FK_A08D274894ECB6799E56C2089A494AF0345B9B16',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" ADD CONSTRAINT "FK_A08D274894ECB6799E56C2089A494AF0345B9B16" FOREIGN KEY ("aSide_NFDeployment") REFERENCES ties_data."o-ran-smo-teiv-cloud_NFDeployment" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE',
 'FK_D39953B79C8D39296B892FCF2C00B9C99AC7023F',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" ADD CONSTRAINT "FK_D39953B79C8D39296B892FCF2C00B9C99AC7023F" FOREIGN KEY ("bSide_OCloudNamespace") REFERENCES ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDeployment',
 'FK_127C21CB9B8871C3BCACA05A5400BE6B8E7FCAC0',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDeployment" ADD CONSTRAINT "FK_127C21CB9B8871C3BCACA05A5400BE6B8E7FCAC0" FOREIGN KEY ("REL_FK_comprised-by-cloudifiedNF") REFERENCES ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDeployment',
 'UNIQUE_A5A8418B6BE911F281E6E2AA640D7D9F777471DC',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDeployment" ADD CONSTRAINT "UNIQUE_A5A8418B6BE911F281E6E2AA640D7D9F777471DC" UNIQUE ("REL_ID_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDeployment',
 'FK_AC1348E208C2E64F2EB1DECE2CCA5DB10B89CBD9',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDeployment" ADD CONSTRAINT "FK_AC1348E208C2E64F2EB1DECE2CCA5DB10B89CBD9" FOREIGN KEY ("REL_FK_serviced-managedElement") REFERENCES ties_data."o-ran-smo-teiv-oam_ManagedElement" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NFDeployment',
 'UNIQUE_8AD46969905BEEB89F63D3F37FD82B14F34FDCBC',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NFDeployment" ADD CONSTRAINT "UNIQUE_8AD46969905BEEB89F63D3F37FD82B14F34FDCBC" UNIQUE ("REL_ID_NFDEPLOYMENT_SERVES_MANAGEDELEMENT");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE',
 'FK_AE882D77CE8D21B8032B124E1822E0EEE5DAAD92',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" ADD CONSTRAINT "FK_AE882D77CE8D21B8032B124E1822E0EEE5DAAD92" FOREIGN KEY ("aSide_NodeCluster") REFERENCES ties_data."o-ran-smo-teiv-cloud_NodeCluster" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE',
 'FK_888BF6FF782916E61B3FE80643A549A1CFDB6117',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" ADD CONSTRAINT "FK_888BF6FF782916E61B3FE80643A549A1CFDB6117" FOREIGN KEY ("bSide_OCloudSite") REFERENCES ties_data."o-ran-smo-teiv-cloud_OCloudSite" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_OCloudNamespace',
 'FK_143EFC1953E68469572446EFB56BDEBBC83B8EBF',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ADD CONSTRAINT "FK_143EFC1953E68469572446EFB56BDEBBC83B8EBF" FOREIGN KEY ("REL_FK_deployed-on-nodeCluster") REFERENCES ties_data."o-ran-smo-teiv-cloud_NodeCluster" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-cloud_OCloudNamespace',
 'UNIQUE_C4DE73BD7AA3DBFA2D32E577D4E0A534A7184AB0',
 'ALTER TABLE ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" ADD CONSTRAINT "UNIQUE_C4DE73BD7AA3DBFA2D32E577D4E0A534A7184AB0" UNIQUE ("REL_ID_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-equipment_AntennaModule',
 'FK_E3BAEF04443354C0FC1837CF7964E05BEF9FD6CC',
 'ALTER TABLE ties_data."o-ran-smo-teiv-equipment_AntennaModule" ADD CONSTRAINT "FK_E3BAEF04443354C0FC1837CF7964E05BEF9FD6CC" FOREIGN KEY ("REL_FK_installed-at-site") REFERENCES ties_data."o-ran-smo-teiv-equipment_Site" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-equipment_AntennaModule',
 'UNIQUE_9DF414C2F0CD7FA8BFCB3E9BF851784AC4BC49B1',
 'ALTER TABLE ties_data."o-ran-smo-teiv-equipment_AntennaModule" ADD CONSTRAINT "UNIQUE_9DF414C2F0CD7FA8BFCB3E9BF851784AC4BC49B1" UNIQUE ("REL_ID_ANTENNAMODULE_INSTALLED_AT_SITE");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-equipment_AntennaModule',
 'FK_078764B2F3D613D44CC6E3586F564C83164D2481',
 'ALTER TABLE ties_data."o-ran-smo-teiv-equipment_AntennaModule" ADD CONSTRAINT "FK_078764B2F3D613D44CC6E3586F564C83164D2481" FOREIGN KEY ("REL_FK_grouped-by-sector") REFERENCES ties_data."o-ran-smo-teiv-ran_Sector" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-equipment_AntennaModule',
 'UNIQUE_78B1D3DCD903AFFB1965D440D87B2D194CA028A0',
 'ALTER TABLE ties_data."o-ran-smo-teiv-equipment_AntennaModule" ADD CONSTRAINT "UNIQUE_78B1D3DCD903AFFB1965D440D87B2D194CA028A0" UNIQUE ("REL_ID_SECTOR_GROUPS_ANTENNAMODULE");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-oam_ManagedElement',
 'FK_899B8130A861D1450FC49D3159D8B29C0628A717',
 'ALTER TABLE ties_data."o-ran-smo-teiv-oam_ManagedElement" ADD CONSTRAINT "FK_899B8130A861D1450FC49D3159D8B29C0628A717" FOREIGN KEY ("REL_FK_deployed-as-cloudifiedNF") REFERENCES ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-oam_ManagedElement',
 'UNIQUE_EC9B35192A31C6491E6566602720D1C26E3CB708',
 'ALTER TABLE ties_data."o-ran-smo-teiv-oam_ManagedElement" ADD CONSTRAINT "UNIQUE_EC9B35192A31C6491E6566602720D1C26E3CB708" UNIQUE ("REL_ID_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellCU',
 'FK_o-ran-smo-teiv-ran_NRCellCU_REL_FK_provided-by-ocucpFunction',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellCU" ADD CONSTRAINT "FK_o-ran-smo-teiv-ran_NRCellCU_REL_FK_provided-by-ocucpFunction" FOREIGN KEY ("REL_FK_provided-by-ocucpFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_OCUCPFunction" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellCU',
 'UNIQUE_928074AEE57C9CB151F93FDC81BC59200D5F7497',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellCU" ADD CONSTRAINT "UNIQUE_928074AEE57C9CB151F93FDC81BC59200D5F7497" UNIQUE ("REL_ID_OCUCPFUNCTION_PROVIDES_NRCELLCU");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellDU',
 'FK_o-ran-smo-teiv-ran_NRCellDU_REL_FK_provided-by-oduFunction',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellDU" ADD CONSTRAINT "FK_o-ran-smo-teiv-ran_NRCellDU_REL_FK_provided-by-oduFunction" FOREIGN KEY ("REL_FK_provided-by-oduFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_ODUFunction" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellDU',
 'UNIQUE_B70F668E0E45FFFC5B7014489F6FD528EB15F192',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellDU" ADD CONSTRAINT "UNIQUE_B70F668E0E45FFFC5B7014489F6FD528EB15F192" UNIQUE ("REL_ID_ODUFUNCTION_PROVIDES_NRCELLDU");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellDU',
 'FK_o-ran-smo-teiv-ran_NRCellDU_REL_FK_grouped-by-sector',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellDU" ADD CONSTRAINT "FK_o-ran-smo-teiv-ran_NRCellDU_REL_FK_grouped-by-sector" FOREIGN KEY ("REL_FK_grouped-by-sector") REFERENCES ties_data."o-ran-smo-teiv-ran_Sector" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRCellDU',
 'UNIQUE_AC1C114ABED77D6DEC3F3AE3F9EBE8231924AEF4',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRCellDU" ADD CONSTRAINT "UNIQUE_AC1C114ABED77D6DEC3F3AE3F9EBE8231924AEF4" UNIQUE ("REL_ID_SECTOR_GROUPS_NRCELLDU");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'FK_o-ran-smo-teiv-ran_NRSectorCarrier_REL_FK_used-by-nrCellDu',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "FK_o-ran-smo-teiv-ran_NRSectorCarrier_REL_FK_used-by-nrCellDu" FOREIGN KEY ("REL_FK_used-by-nrCellDu") REFERENCES ties_data."o-ran-smo-teiv-ran_NRCellDU" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'UNIQUE_1AB577E5AC207ED4C99A9A96BA1C9C35544AFD25',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "UNIQUE_1AB577E5AC207ED4C99A9A96BA1C9C35544AFD25" UNIQUE ("REL_ID_NRCELLDU_USES_NRSECTORCARRIER");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'FK_65D538D54EB33081C808540235FEB28823428E64',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "FK_65D538D54EB33081C808540235FEB28823428E64" FOREIGN KEY ("REL_FK_used-antennaCapability") REFERENCES ties_data."o-ran-smo-teiv-ran_AntennaCapability" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'UNIQUE_A799EC9DA6624651081E1DA21B5F0C2D38F6A192',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "UNIQUE_A799EC9DA6624651081E1DA21B5F0C2D38F6A192" UNIQUE ("REL_ID_NRSECTORCARRIER_USES_ANTENNACAPABILITY");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'FK_9B73B9E2DBA36736FB76606005C823A6D565A5CD',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "FK_9B73B9E2DBA36736FB76606005C823A6D565A5CD" FOREIGN KEY ("REL_FK_provided-by-oduFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_ODUFunction" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NRSectorCarrier',
 'UNIQUE_D5D35955594A6EB48640425529F7DE44BED00B62',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" ADD CONSTRAINT "UNIQUE_D5D35955594A6EB48640425529F7DE44BED00B62" UNIQUE ("REL_ID_ODUFUNCTION_PROVIDES_NRSECTORCARRIER");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NearRTRICFunction',
 'FK_32BDE0334EA6AD74ABB3958A2B163F63A3F05203',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ADD CONSTRAINT "FK_32BDE0334EA6AD74ABB3958A2B163F63A3F05203" FOREIGN KEY ("REL_FK_managed-by-managedElement") REFERENCES ties_data."o-ran-smo-teiv-oam_ManagedElement" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_NearRTRICFunction',
 'UNIQUE_E020461673334EB824643649B6B31670FB064EC8',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" ADD CONSTRAINT "UNIQUE_E020461673334EB824643649B6B31670FB064EC8" UNIQUE ("REL_ID_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_OCUCPFunction',
 'FK_122DD9709032528D161177B3624AD7AAF6589005',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ADD CONSTRAINT "FK_122DD9709032528D161177B3624AD7AAF6589005" FOREIGN KEY ("REL_FK_managed-by-managedElement") REFERENCES ties_data."o-ran-smo-teiv-oam_ManagedElement" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_OCUCPFunction',
 'UNIQUE_2B7D3D49C1072E660047DE56843413CE628BF94A',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_OCUCPFunction" ADD CONSTRAINT "UNIQUE_2B7D3D49C1072E660047DE56843413CE628BF94A" UNIQUE ("REL_ID_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_OCUUPFunction',
 'FK_8062AF50E5EE5543FBCC68D66FDFF673E31E081D',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ADD CONSTRAINT "FK_8062AF50E5EE5543FBCC68D66FDFF673E31E081D" FOREIGN KEY ("REL_FK_managed-by-managedElement") REFERENCES ties_data."o-ran-smo-teiv-oam_ManagedElement" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_OCUUPFunction',
 'UNIQUE_DF85FE7809B5527CB4A6028DD1A599DBBD5AF214',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_OCUUPFunction" ADD CONSTRAINT "UNIQUE_DF85FE7809B5527CB4A6028DD1A599DBBD5AF214" UNIQUE ("REL_ID_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_ODUFunction',
 'FK_B6F0A4F9024FB47DA39C9A4F1DFFF78330222A80',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_ODUFunction" ADD CONSTRAINT "FK_B6F0A4F9024FB47DA39C9A4F1DFFF78330222A80" FOREIGN KEY ("REL_FK_managed-by-managedElement") REFERENCES ties_data."o-ran-smo-teiv-oam_ManagedElement" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_ODUFunction',
 'UNIQUE_D570291C9E28A2AF73387B7A8B0F4C70130EEDB4',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_ODUFunction" ADD CONSTRAINT "UNIQUE_D570291C9E28A2AF73387B7A8B0F4C70130EEDB4" UNIQUE ("REL_ID_MANAGEDELEMENT_MANAGES_ODUFUNCTION");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_ORUFunction',
 'FK_B497A8C3DC2D647938E6DB4C7E691509DD8C90DE',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_ORUFunction" ADD CONSTRAINT "FK_B497A8C3DC2D647938E6DB4C7E691509DD8C90DE" FOREIGN KEY ("REL_FK_managed-by-managedElement") REFERENCES ties_data."o-ran-smo-teiv-oam_ManagedElement" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-ran_ORUFunction',
 'UNIQUE_4E6F008B82605A806EED04B2315A1FEE095A9241',
 'ALTER TABLE ties_data."o-ran-smo-teiv-ran_ORUFunction" ADD CONSTRAINT "UNIQUE_4E6F008B82605A806EED04B2315A1FEE095A9241" UNIQUE ("REL_ID_MANAGEDELEMENT_MANAGES_ORUFUNCTION");'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION',
 'FK_2B4B09AF7CC9C877B1140BB127B4CB4DA438195D',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" ADD CONSTRAINT "FK_2B4B09AF7CC9C877B1140BB127B4CB4DA438195D" FOREIGN KEY ("aSide_NFDeployment") REFERENCES ties_data."o-ran-smo-teiv-cloud_NFDeployment" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION',
 'FK_BCF2F9776761ABC19AE0BBD0244D7CD5785E7AC6',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" ADD CONSTRAINT "FK_BCF2F9776761ABC19AE0BBD0244D7CD5785E7AC6" FOREIGN KEY ("bSide_OCUCPFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_OCUCPFunction" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION',
 'FK_AC1393DCBA845EDA13DADCB5BD87DF4163CD1669',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" ADD CONSTRAINT "FK_AC1393DCBA845EDA13DADCB5BD87DF4163CD1669" FOREIGN KEY ("aSide_NFDeployment") REFERENCES ties_data."o-ran-smo-teiv-cloud_NFDeployment" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION',
 'FK_8585D545BC37A473A298E0F5F5942F897A7105B1',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" ADD CONSTRAINT "FK_8585D545BC37A473A298E0F5F5942F897A7105B1" FOREIGN KEY ("bSide_OCUUPFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_OCUUPFunction" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION',
 'FK_ABA5D0BEEB45E6A5B14DB24E880029CA38DF3F79',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" ADD CONSTRAINT "FK_ABA5D0BEEB45E6A5B14DB24E880029CA38DF3F79" FOREIGN KEY ("aSide_NFDeployment") REFERENCES ties_data."o-ran-smo-teiv-cloud_NFDeployment" (id) ON DELETE CASCADE;'
);

SELECT ties_data.create_constraint_if_not_exists(
	'o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION',
 'FK_C7C12DB840FBCF4EA729B8C2BBCD8BFDE06F0F08',
 'ALTER TABLE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" ADD CONSTRAINT "FK_C7C12DB840FBCF4EA729B8C2BBCD8BFDE06F0F08" FOREIGN KEY ("bSide_ODUFunction") REFERENCES ties_data."o-ran-smo-teiv-ran_ODUFunction" (id) ON DELETE CASCADE;'
);

CREATE INDEX IF NOT EXISTS "IDX_996D2C34C2458A6EFE8599C1A0E6942D3D288B7A" ON ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_F52FEEDBAF1B04D2D22EBAE051BB5125DF6A6968" ON ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_D333FA5882890B7CD3599712FFFB2641B9E04C80" ON ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_E896A9EB22A3F9F96CE75A271475316A98B629C8" ON ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_DD0D676834B12CA2F7E8219310998376A08D7F5F" ON ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_7BF09D0227840279556AD27ACECB068705893D28" ON ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_9EDB5C47201FC82A4565BFED9EF369D6C6529B19" ON ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_BD96130868B69147B2F87B0D15F5829690DEF454" ON ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-cloud_CloudifiedNF_CD_decorators" ON ties_data."o-ran-smo-teiv-cloud_CloudifiedNF" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_F97E398B17532BCD9923CE0CF98E73227D890037" ON ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_1BCFD9635C4FA089EDC2E18FFEF56DBF3C5E7A52" ON ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_4055A796F223DD01411AFFB5AD97EEEAB6B2320C" ON ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_6433B9B7D69E51E828BDCFCAF59729EDCD10DA60" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_BED5B5FAA75FEE133E27581EAA611B89D20F24E1" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-cloud_NFDeployment_CD_decorators" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_072EB0C094138AB2D90F9CFBDA765B3B464EE86F" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN (("REL_CD_sourceIds_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_31F185F0F700C0AE11C5A9B8D28DBF6E37538635" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN (("REL_CD_classifiers_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_46CDB369134F042EC021F7496DF721B49A9D43C0" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN ("REL_CD_decorators_CLOUDIFIEDNF_COMPRISES_NFDEPLOYMENT");

CREATE INDEX IF NOT EXISTS "IDX_4DD95BAED8503502101FEB9ECA25DDA8F371816C" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN (("REL_CD_sourceIds_NFDEPLOYMENT_SERVES_MANAGEDELEMENT"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_1EE98ACCAE5537752BD51A3D5F6429585CC543F6" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN (("REL_CD_classifiers_NFDEPLOYMENT_SERVES_MANAGEDELEMENT"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_39A292C3C42B34C2AD7C2A0FD087739C253B06FC" ON ties_data."o-ran-smo-teiv-cloud_NFDeployment" USING GIN ("REL_CD_decorators_NFDEPLOYMENT_SERVES_MANAGEDELEMENT");

CREATE INDEX IF NOT EXISTS "IDX_1D7F9BD4B5BBF73CC3D06D949731DC169DDED26D" ON ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_29702D5C8D0B9B20BFB534FA233B9D9FADC2E3A1" ON ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_98A32BE3A8C1FF8CDEC95561DE4A74852FE70322" ON ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_DC1829E4241BA7C9B3E5281AC0DF00A766F9452E" ON ties_data."o-ran-smo-teiv-cloud_NodeCluster" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_CB29E8DDA990051B2A3DF193D8E4912F25D5FA0D" ON ties_data."o-ran-smo-teiv-cloud_NodeCluster" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-cloud_NodeCluster_CD_decorators" ON ties_data."o-ran-smo-teiv-cloud_NodeCluster" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_1B8DF6B061E229E5B6AC796911E6C8C23ECAD585" ON ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_57EB74DEF745DE4BA9AAD8E735BACB71F2E8C417" ON ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-cloud_OCloudNamespace_CD_decorators" ON ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_A7A50200F582AB86EF483F9BA74F999F17B7F653" ON ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" USING GIN (("REL_CD_sourceIds_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_6EE081E80342904B676496DA42DFAEC3EDA2CE27" ON ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" USING GIN (("REL_CD_classifiers_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_9AB8994DE0826F790D70614D4C52DD270AEF946B" ON ties_data."o-ran-smo-teiv-cloud_OCloudNamespace" USING GIN ("REL_CD_decorators_OCLOUDNAMESPACE_DEPLOYED_ON_NODECLUSTER");

CREATE INDEX IF NOT EXISTS "IDX_30C83E5F8447D28D8E2A73048DF751C886AF318B" ON ties_data."o-ran-smo-teiv-cloud_OCloudSite" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_281A2DE604D25D6CFECB9B26D1FF70429FDB0FD0" ON ties_data."o-ran-smo-teiv-cloud_OCloudSite" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-cloud_OCloudSite_CD_decorators" ON ties_data."o-ran-smo-teiv-cloud_OCloudSite" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_21B0F1FE632B6CB185C49BA6F00224068F443215" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("antennaBeamWidth"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_905011128A2C218B5352C19ED1FE9851F43EB911" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_1C0CAFD80FDD6444044E3F76C7C0A7BDC35F9BC8" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-equipment_AntennaModule_CD_decorators" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_F497DEC01DA066CB09DA2AA7EDE3F4410078491B" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("REL_CD_sourceIds_ANTENNAMODULE_INSTALLED_AT_SITE"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_17E417F7EF56809674BE1D5F5154DCCE01E00A96" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("REL_CD_classifiers_ANTENNAMODULE_INSTALLED_AT_SITE"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_2321BFA482AD2700F41E2BA359F6EB00F47601B9" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN ("REL_CD_decorators_ANTENNAMODULE_INSTALLED_AT_SITE");

CREATE INDEX IF NOT EXISTS "IDX_5ABDB19E55A6BDEF33855F14CB1B3B8CF457912C" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("REL_CD_sourceIds_SECTOR_GROUPS_ANTENNAMODULE"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_83B6347C0C0A005D5E3D856D973D3322DFEDEA35" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN (("REL_CD_classifiers_SECTOR_GROUPS_ANTENNAMODULE"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_6C6FBD69F47F41970595A8775DC99CA0F5E894A1" ON ties_data."o-ran-smo-teiv-equipment_AntennaModule" USING GIN ("REL_CD_decorators_SECTOR_GROUPS_ANTENNAMODULE");

CREATE INDEX IF NOT EXISTS "IDX_102A50584376DE25B6BBD7157594C607A5C957F2" ON ties_data."o-ran-smo-teiv-equipment_Site" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_EEBF1BC3344E97988232825777AB13FAB6C4F3F0" ON ties_data."o-ran-smo-teiv-equipment_Site" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-equipment_Site_CD_decorators" ON ties_data."o-ran-smo-teiv-equipment_Site" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_DDD73D6F4004BF3A96AA118281EE3E565A922B47" ON ties_data."o-ran-smo-teiv-oam_ManagedElement" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_98AC4232BC02323E03416954215889CEE874A1E9" ON ties_data."o-ran-smo-teiv-oam_ManagedElement" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-oam_ManagedElement_CD_decorators" ON ties_data."o-ran-smo-teiv-oam_ManagedElement" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_8065626F3F48D4E5A4285654739D3B26499E4C4E" ON ties_data."o-ran-smo-teiv-oam_ManagedElement" USING GIN (("REL_CD_sourceIds_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_634619CF7333EBC0AFDE990900B79220FC626EBA" ON ties_data."o-ran-smo-teiv-oam_ManagedElement" USING GIN (("REL_CD_classifiers_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_F15A070FC83B2E49223B4232E0BEB8931C2B7A4C" ON ties_data."o-ran-smo-teiv-oam_ManagedElement" USING GIN ("REL_CD_decorators_MANAGEDELEMENT_DEPLOYED_AS_CLOUDIFIEDNF");

CREATE INDEX IF NOT EXISTS "IDX_5FB80647AE3E5C0443A792618D65B9090EE2A3FC" ON ties_data."o-ran-smo-teiv-ran_AntennaCapability" USING GIN (("eUtranFqBands"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_A94722FF7B95D8974B494793908B57B4E1A9743B" ON ties_data."o-ran-smo-teiv-ran_AntennaCapability" USING GIN (("geranFqBands"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_441B5C05448D63552C6414BD59C13641D8A4408D" ON ties_data."o-ran-smo-teiv-ran_AntennaCapability" USING GIN (("nRFqBands"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_CC3E208A4EE51D3B505416A599F36F3C99F466C8" ON ties_data."o-ran-smo-teiv-ran_AntennaCapability" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_E7FFE8F4A166AA9A382A0659762FFEC313A9EB5C" ON ties_data."o-ran-smo-teiv-ran_AntennaCapability" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_AntennaCapability_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_AntennaCapability" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_NRCellCU_plmnId" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN ("plmnId");

CREATE INDEX IF NOT EXISTS "IDX_0C443A16285D233F16966C2F0314CDC9D0F6D0B8" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_E5930226819982DC0CFC1FA64FB3600647222435" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_NRCellCU_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_6891C1BB8EE214340A362906C08955E8ACC1C597" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN (("REL_CD_sourceIds_OCUCPFUNCTION_PROVIDES_NRCELLCU"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_D366F952FD4A52645C45A19CBFD02B8897FC1F18" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN (("REL_CD_classifiers_OCUCPFUNCTION_PROVIDES_NRCELLCU"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_5D761303176D3B9338784DFBEE0CEC51046ADC30" ON ties_data."o-ran-smo-teiv-ran_NRCellCU" USING GIN ("REL_CD_decorators_OCUCPFUNCTION_PROVIDES_NRCELLCU");

CREATE INDEX IF NOT EXISTS "IDX_FFD60DD99D80C276F402E66546F5DACB2D81EE26" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_C437D39632DC79BAB6AC4F0880826A05425F9C32" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_NRCellDU_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_B48D188E92ACBE9A2CAF8CD730A5DDFD7E086705" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN (("REL_CD_sourceIds_ODUFUNCTION_PROVIDES_NRCELLDU"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_A950BF337D5D820E5B39AC3F1B1AC09C062F30C9" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN (("REL_CD_classifiers_ODUFUNCTION_PROVIDES_NRCELLDU"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_F494CB3BA4C726D4C45D53B1EF62E1E26811CCEF" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN ("REL_CD_decorators_ODUFUNCTION_PROVIDES_NRCELLDU");

CREATE INDEX IF NOT EXISTS "IDX_6325926B4D2FDD1FBBB34250DABEA5E7229FF9F5" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN (("REL_CD_sourceIds_SECTOR_GROUPS_NRCELLDU"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_7CB4A7724F68D1CB2D12E8DE779BA9103F7DBE0A" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN (("REL_CD_classifiers_SECTOR_GROUPS_NRCELLDU"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_0A03C47C13AD3B5C84D3D8081493D670E9CBDCD1" ON ties_data."o-ran-smo-teiv-ran_NRCellDU" USING GIN ("REL_CD_decorators_SECTOR_GROUPS_NRCELLDU");

CREATE INDEX IF NOT EXISTS "IDX_8E34EC0B1DE7DDCE3B32ADD85B11E15F95C5644E" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_050A80BEEF775E4D3CE216F282F23DB99DA2D798" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_NRSectorCarrier_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_7BFD17A71AB1B7765FE6431DA4E66C2EDE88AC3B" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("REL_CD_sourceIds_NRCELLDU_USES_NRSECTORCARRIER"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_ED50A5139F1449DBAD8DA10D45F5A5BF819EACBA" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("REL_CD_classifiers_NRCELLDU_USES_NRSECTORCARRIER"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_2ADB5C6DCAEE8811FB1CA8FD9EB53381F35FCB70" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN ("REL_CD_decorators_NRCELLDU_USES_NRSECTORCARRIER");

CREATE INDEX IF NOT EXISTS "IDX_1F27C515A028616FAC422A02ABBEC402D5DBB2E5" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("REL_CD_sourceIds_NRSECTORCARRIER_USES_ANTENNACAPABILITY"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_B975D24291849007D4AA6686C5D3983885D5C884" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("REL_CD_classifiers_NRSECTORCARRIER_USES_ANTENNACAPABILITY"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_902B73F741160B9D4FBF62406D3D9ABBECAD8BE7" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN ("REL_CD_decorators_NRSECTORCARRIER_USES_ANTENNACAPABILITY");

CREATE INDEX IF NOT EXISTS "IDX_986B2223E72FF79237337329F4C3BB9DA9025A34" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("REL_CD_sourceIds_ODUFUNCTION_PROVIDES_NRSECTORCARRIER"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_FC70CCFDC1359B698BBBE5CA7AA158F0AF693461" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN (("REL_CD_classifiers_ODUFUNCTION_PROVIDES_NRSECTORCARRIER"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_5AB1D780E57D940C42BAD29772E9E2B6C63498A0" ON ties_data."o-ran-smo-teiv-ran_NRSectorCarrier" USING GIN ("REL_CD_decorators_ODUFUNCTION_PROVIDES_NRSECTORCARRIER");

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_NearRTRICFunction_pLMNId" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN ("pLMNId");

CREATE INDEX IF NOT EXISTS "IDX_E4E40B26C322AF63A662706AF8B0B36E1043B793" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_8BCCF388DFC8652AD5CD0675C64F49D2D2EDC7A1" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_NearRTRICFunction_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_B608D8F6B8A79097EA61A1B4777A96CD3D2D1E98" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN (("REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_0ECC814A408874C9F8E73EEE3968984A6345A606" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN (("REL_CD_classifiers_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_B10FD045A6C3E169953CCC38CC2D801FCE15A75F" ON ties_data."o-ran-smo-teiv-ran_NearRTRICFunction" USING GIN ("REL_CD_decorators_MANAGEDELEMENT_MANAGES_NEARRTRICFUNCTION");

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_OCUCPFunction_pLMNId" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN ("pLMNId");

CREATE INDEX IF NOT EXISTS "IDX_84A29F8571860AC5A7BD1A99923485ECB6A3939D" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_8D9862DBF6A721FABAEA4204E04B374692C1C5B8" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_OCUCPFunction_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_4C6B5CB5CF018656DC8191CE6FE3B9DA2CD0C819" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN (("REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_21F2560C8330A795E8AFB54C6D31CDCF6CCD3070" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN (("REL_CD_classifiers_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_D856E84F300B6711E81931AE1CBC8AD905FA384F" ON ties_data."o-ran-smo-teiv-ran_OCUCPFunction" USING GIN ("REL_CD_decorators_MANAGEDELEMENT_MANAGES_OCUCPFUNCTION");

CREATE INDEX IF NOT EXISTS "IDX_9122DAA7A60DB585BE5ECA68A2EDB9ABF1E7156A" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN (("pLMNIdList"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_6C81B2BBFCFE94C87598869A2099E04571202BA7" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_25E4BCFBF8F5344DFC60BCB159FA873FFC8109E9" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_OCUUPFunction_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_50209F1FF59B49F79FF194887B631994F2B5148A" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN (("REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_3346DFB8C2B7D6EEA12B7C1DE4A84B058C24A657" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN (("REL_CD_classifiers_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_ADD3393C27589066C4993A3491436C6FB57A539F" ON ties_data."o-ran-smo-teiv-ran_OCUUPFunction" USING GIN ("REL_CD_decorators_MANAGEDELEMENT_MANAGES_OCUUPFUNCTION");

CREATE INDEX IF NOT EXISTS "IDX_73790DA8FF6365B752DC8B399893AC6DE8CF26C4" ON ties_data."o-ran-smo-teiv-ran_ODUFunction" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_5CE9EDE1F25AB2D880A41BC5D297FDBE668182E8" ON ties_data."o-ran-smo-teiv-ran_ODUFunction" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_ODUFunction_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_ODUFunction" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_0E5C91A3252FBAFA72DB644D4E949A379F0CB910" ON ties_data."o-ran-smo-teiv-ran_ODUFunction" USING GIN (("REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_ODUFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_5DD192861541E0EB2776C6BFE34B327FF27F93C3" ON ties_data."o-ran-smo-teiv-ran_ODUFunction" USING GIN (("REL_CD_classifiers_MANAGEDELEMENT_MANAGES_ODUFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_0B9AC962B1E07740CE43D912B5FBC54E0B39DD24" ON ties_data."o-ran-smo-teiv-ran_ODUFunction" USING GIN ("REL_CD_decorators_MANAGEDELEMENT_MANAGES_ODUFUNCTION");

CREATE INDEX IF NOT EXISTS "IDX_D0D11CFAA917F4FA12748A041A34D2B39A3AD707" ON ties_data."o-ran-smo-teiv-ran_ORUFunction" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_2A5AAAD13FDCFF7F2958005C22937366F6604A0D" ON ties_data."o-ran-smo-teiv-ran_ORUFunction" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_ORUFunction_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_ORUFunction" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_AF235FB2C9CCA99D94CC4038669EDD1BB6C7B2DF" ON ties_data."o-ran-smo-teiv-ran_ORUFunction" USING GIN (("REL_CD_sourceIds_MANAGEDELEMENT_MANAGES_ORUFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_DA79A3F946C1F4E8D05B4D6ADEF5E4C65E47635E" ON ties_data."o-ran-smo-teiv-ran_ORUFunction" USING GIN (("REL_CD_classifiers_MANAGEDELEMENT_MANAGES_ORUFUNCTION"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_7B916E1753D2860DF434831CF1E9697ED9973C8F" ON ties_data."o-ran-smo-teiv-ran_ORUFunction" USING GIN ("REL_CD_decorators_MANAGEDELEMENT_MANAGES_ORUFUNCTION");

CREATE INDEX IF NOT EXISTS "IDX_E234B43A7CD7843672F08F2197AB46A2A50BECB0" ON ties_data."o-ran-smo-teiv-ran_Sector" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_19C19556F9714850389595E0A16218FA229205FE" ON ties_data."o-ran-smo-teiv-ran_Sector" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_GIN_o-ran-smo-teiv-ran_Sector_CD_decorators" ON ties_data."o-ran-smo-teiv-ran_Sector" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_10BCC6B44663A8D5431668BEE5DF80423420C616" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_03F9C6A2FA82614A788443AC6044BCED2401C465" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_0867A1E865A904F4BB513948DAEB60412BE67DF3" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_64B7C127C01069009A3FB13592DAE249B0029283" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_69152691D777DDB084C053915D4A4B15F7F8B3EB" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_3AB53A0DB6DC4B4C8BB6194D6D487EBDC3D0E88F" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION" USING GIN ("CD_decorators");

CREATE INDEX IF NOT EXISTS "IDX_5996D077978D38D0C1A951A262F1F7E1E339F052" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" USING GIN (("CD_sourceIds"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_F4A1999634924C7E4D1CBD05E83996A5B1262A8A" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" USING GIN (("CD_classifiers"::TEXT) gin_trgm_ops);

CREATE INDEX IF NOT EXISTS "IDX_5BAC6D2F05A63FDE27F082E8C8F4D766C145E835" ON ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION" USING GIN ("CD_decorators");

ANALYZE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUUPFUNCTION";

ANALYZE ties_data."o-ran-smo-teiv-ran_ODUFunction";

ANALYZE ties_data."o-ran-smo-teiv-equipment_Site";

ANALYZE ties_data."o-ran-smo-teiv-cloud_NODECLUSTER_LOCATED_AT_OCLOUDSITE";

ANALYZE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_ODUFUNCTION";

ANALYZE ties_data."o-ran-smo-teiv-cloud_NodeCluster";

ANALYZE ties_data."o-ran-smo-teiv-rel-cloud-ran_NFDEPLOYMENT_SERVES_OCUCPFUNCTION";

ANALYZE ties_data."o-ran-smo-teiv-ran_OCUCPFunction";

ANALYZE ties_data."o-ran-smo-teiv-oam_ManagedElement";

ANALYZE ties_data."o-ran-smo-teiv-ran_NRCellDU";

ANALYZE ties_data."o-ran-smo-teiv-ran_NearRTRICFunction";

ANALYZE ties_data."o-ran-smo-teiv-cloud_CloudifiedNF";

ANALYZE ties_data."o-ran-smo-teiv-cloud_NFDeployment";

ANALYZE ties_data."o-ran-smo-teiv-ran_AntennaCapability";

ANALYZE ties_data."3C2E2CE7BDF8321BC824B6318B190690F58DBB82";

ANALYZE ties_data."o-ran-smo-teiv-cloud_NFDEPLOYMENT_DEPLOYED_ON_OCLOUDNAMESPACE";

ANALYZE ties_data."o-ran-smo-teiv-equipment_AntennaModule";

ANALYZE ties_data."o-ran-smo-teiv-ran_ORUFunction";

ANALYZE ties_data."o-ran-smo-teiv-ran_NRCellCU";

ANALYZE ties_data."CFC235E0404703D1E4454647DF8AAE2C193DB402";

ANALYZE ties_data."o-ran-smo-teiv-ran_OCUUPFunction";

ANALYZE ties_data."o-ran-smo-teiv-ran_NRSectorCarrier";

ANALYZE ties_data."o-ran-smo-teiv-ran_Sector";

ANALYZE ties_data."o-ran-smo-teiv-cloud_OCloudSite";

ANALYZE ties_data."o-ran-smo-teiv-cloud_OCloudNamespace";

COMMIT;
