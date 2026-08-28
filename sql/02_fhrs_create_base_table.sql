-- === Create London FHRS Project Base Table ===
-- define base table for initial ingestion
-- rename and snake_case columns (currently mostly PascalCase)
-- apply table and column comments
-- no masking required - public/open data only


-- select project DB & schema:
USE DATABASE FHRS_LONDON;
USE SCHEMA COMPLIANCE;


-- define table for output data ingest:
CREATE OR REPLACE TABLE establishments (
    fhrs_id NUMBER PRIMARY KEY 
        COMMENT 'Unique establishment identifier from the FSA API. Primary key (informational only).',
        -- Snowflake PK contstraint is informational only, not enforced
        -- duplicate inserts are not blocked (but this was checked ok upstream in pandas)
        -- declared anyway as it provides clean documentation of intent
        -- and some downstream tools (e.g. Tableau) use this as a hint
    business_name VARCHAR 
        COMMENT 'Trading name of the establishment.',
    business_type VARCHAR 
        COMMENT 'FSA business category (e.g. Restaurant/Cafe/Canteen). Raw category, not the grouped version used in modelling.',
    local_authority_name VARCHAR 
        COMMENT 'London borough (Local Authority) in which the establishment is located.',
    postcode VARCHAR 
        COMMENT 'Establishment postcode, as recorded by the FSA. Completeness varies - see postcode_tier.',
    latitude FLOAT 
        COMMENT 'Latitude from the FSA API. Missing for ~17% of establishments, disproportionately so for mobile/non-fixed-premises business types.',
    longitude FLOAT 
        COMMENT 'Longitude from the FSA API. Missing for ~17% of establishments, disproportionately so for mobile/non-fixed-premises business types.',
    rating_value VARCHAR 
        COMMENT 'FHRS rating: "0"-"5", or a non-numeric status (AwaitingInspection, AwaitingPublication, Exempt). Stored as text as it holds mixed content.',
    rating_date TIMESTAMP_NTZ 
        COMMENT 'Date of the most recent inspection for the establishment. Note: a small number of rows carry a 1901-01-01 placeholder rather than a genuine date.',
        -- NTZ (No Time Zone) used as no timezone info is encoded in the incoming data
        -- this variant prevents unwanted conversion / any timezone info being attached/assumed
    imd_decile NUMBER(2, 0) 
        COMMENT 'Overall IMD 2025 decile for the LSOA in which the establishment is located. 1 = most deprived, 10 = least deprived.',
    income_decile NUMBER(2, 0) 
        COMMENT 'Income domain decile from IMD 2025, for the LSOA in which the establishment is located. 1 = most deprived, 10 = least deprived.',
    lsoa_match_type VARCHAR 
        COMMENT 'Confidence of the LSOA match: full_match, sector_fallback (best-guess), or unmatched.',
    postcode_tier VARCHAR 
        COMMENT 'Completeness of the establishment postcode record: full, sector, outward, blank, or unclassified.',
    scored BOOLEAN 
        COMMENT 'Indicates whether this establishment had a usable income_decile and could be scored. False for ~13% (mostly no LSOA match).',
    predicted_rating VARCHAR 
        COMMENT 'Classification from a class-weight-balanced model (fail/pass, i.e. RATING <5 vs 5). Deliberately skewed toward fail to maximise recall - read as "flagged for attention", not a prevalence estimate. Null if scored = FALSE.',
    risk_score FLOAT 
        COMMENT 'Calibrated probability of falling below a 5 rating, from an unweighted model. Use this (not predicted_rating) for any quantitative reading. Null if scored = FALSE.'
) 
COMMENT = 'Base data table with premises-level dimensions. Scored FHRS establishment data for London. Source: FSA Food Hygiene Rating Scheme API + ONS LSOA lookup + IMD 2025, joined and modelled in Python (see project README/notebooks). Loaded from outputs/fhrs_london_scored.csv.';


-- check table shape:
DESC TABLE establishments;


-- view and check column comments applied:
SELECT column_name, comment
FROM information_schema.columns
WHERE table_name = 'ESTABLISHMENTS'
ORDER BY ordinal_position;