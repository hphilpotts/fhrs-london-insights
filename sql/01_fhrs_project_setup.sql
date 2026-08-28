-- === London FHRS Project Setup ===
-- create project-specific DB and schema
-- check setup & active context pointer


-- create DB and schema:
CREATE DATABASE FHRS_LONDON;
CREATE SCHEMA FHRS_LONDON.COMPLIANCE;

-- set both as active context (worksheet only):
USE DATABASE FHRS_LONDON;
USE SCHEMA COMPLIANCE;

-- check return:
SELECT CURRENT_DATABASE(), CURRENT_SCHEMA();