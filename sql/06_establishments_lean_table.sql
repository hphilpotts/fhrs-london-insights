-- === London FHRS Project - Create 'lean' Establishments Table ===
-- create and verify a lighter-weight establishment-level table
-- analogue of the main base table but intended to result in smaller file size
-- columns dropped unless essential
-- rounding applied to continuous values

-- select project DB & schema:
USE DATABASE FHRS_LONDON;
USE SCHEMA COMPLIANCE;


-- create table:
CREATE OR REPLACE TABLE establishments_lean
COMMENT = 'Reduced-column, rounded-precision version of establishments — a smaller flat-file fallback for Tableau Public if the full table causes performance issues.'
AS
SELECT
    fhrs_id,
    business_name,
    business_type,
    local_authority_name,
    ROUND(latitude, 5) AS latitude,
    ROUND(longitude, 5) AS longitude,
    rating_value,
    income_decile,
    predicted_rating,
    ROUND(risk_score, 3) AS risk_score
FROM establishments;


-- check row count:
SELECT COUNT(*) FROM establishments_lean;


-- inspect:
SELECT * FROM establishments_lean LIMIT 5;


-- select for download:
SELECT * FROM establishments_lean ORDER BY fhrs_id;