-- === Set Up London FHRS Project Stage and Data Ingestion ===
-- create a file format to define how uploaded CSV is parsed
-- create a stage for data ingest
-- upload CSV to stage using Snowsight
-- run the load step
-- verify row count


-- select project DB & schema:
USE DATABASE FHRS_LONDON;
USE SCHEMA COMPLIANCE;


-- create and setup up file format:
CREATE FILE FORMAT csv_format
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        -- ensures fields containing commas (e.g. business names) are enclosed in double quotes
        -- without this, the comma would be misinterpreted as a column separator
        -- which in turn would corrup the row
    NULL_IF = ('')
    EMPTY_FIELD_AS_NULL = TRUE
        -- both the above handle pandas writing missing values as empty strings
        -- e.g. as is the case for predicted values for unscored establishments
        -- ensures these are treated as true NULL vales
    TIMESTAMP_FORMAT = 'YYYY-MM-DDTHH24:MI:SS'
    -- timestamp format is explicitly declared rather than trusting auto-detection
    -- format specified has previously been verified in pandas stage
;


-- create stage, using file format:
CREATE STAGE fhrs_stage
    FILE_FORMAT = csv_format;


/* Snowsight interface step here:  loading the processed CSV output file into the stage
- Ingestion -> Add Data -> Load Files into a Stage
- upload output file, specify DB, schema and stage created above
- await success notification and verify below: */


-- verify staging:
LIST @fhrs_stage;
    -- if ok, proceed to load step


-- load staged file into establishments table:
COPY INTO establishments
FROM @fhrs_stage/fhrs_london_scored.csv
FILE_FORMAT = (FORMAT_NAME = csv_format)
    -- technically redundant (already inherited from the stage definition)
    -- but I've left this here so that a later reader can easily see how the load is parsed
ON_ERROR = 'ABORT_STATEMENT'
    -- a default but explicitly stated for visibility
;


-- verify load:
SELECT COUNT(*) FROM establishments;
    -- expect 81217 if original data pull and output used
    -- otherwise (future users!) expect this to match final output row count