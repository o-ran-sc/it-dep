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

CREATE SCHEMA IF NOT EXISTS teiv_groups;
ALTER SCHEMA teiv_groups OWNER TO topology_exposure_user;
SET default_tablespace = '';
SET default_table_access_method = heap;

SET ROLE topology_exposure_user;

-- Function to create CONSTRAINT only if it does not exists
CREATE OR REPLACE FUNCTION teiv_groups.create_constraint_if_not_exists (
	t_name TEXT, c_name TEXT, constraint_sql TEXT
)
RETURNS void AS
$$
BEGIN
	IF NOT EXISTS (SELECT constraint_name FROM information_schema.table_constraints WHERE table_schema = 'teiv_groups' AND table_name = t_name AND constraint_name = c_name) THEN
		EXECUTE constraint_sql;
	END IF;
END;
$$ language 'plpgsql';

CREATE TABLE IF NOT EXISTS teiv_groups."groups" (
	"id"              VARCHAR(150) PRIMARY KEY,
	"name"            VARCHAR(150) NOT NULL,
	"type"            VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS teiv_groups."static_groups" (
	"id"                    VARCHAR(150),
	"topology_type"         TEXT NOT NULL,
	"provided_members_ids"  TEXT[] NOT NULL,
	PRIMARY KEY ("id", "topology_type"),
	FOREIGN KEY ("id") REFERENCES teiv_groups."groups" ("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS teiv_groups."dynamic_groups" (
	"id"                  VARCHAR(150) PRIMARY KEY,
	"criteria"            JSONB NOT NULL,
	FOREIGN KEY ("id") REFERENCES teiv_groups."groups" ("id") ON DELETE CASCADE
);

SELECT teiv_groups.create_constraint_if_not_exists(
	'groups',
	'CHECK_groups_type',
	'ALTER TABLE teiv_groups."groups" ADD CONSTRAINT "CHECK_groups_type" CHECK ("type" IN (''static'', ''dynamic''))'
);

COMMIT;
