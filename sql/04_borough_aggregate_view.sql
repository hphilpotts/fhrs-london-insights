-- === London FHRS Project - Create Borough Aggregate Summary View ===
-- create and verify a borough summary view
-- aggregates establishment-level data up to borough level
-- resulting view used for 'hot' data in Tableau dashboard


-- select project DB & schema:
USE DATABASE FHRS_LONDON;
USE SCHEMA COMPLIANCE;


-- create view:
CREATE OR REPLACE VIEW borough_summary AS
SELECT
    local_authority_name AS la_group_key,
    -- establishment counts
    COUNT(*) AS establishment_count,
    COUNT(CASE WHEN rating_value IN ('0','1','2','3','4','5') THEN 1 END) AS gradable_count,
    COUNT(CASE WHEN scored THEN 1 END) AS scored_count,
    -- gradable rating counts
    COUNT(CASE WHEN rating_value = '0' THEN 1 END) AS rating_0_count,
    COUNT(CASE WHEN rating_value = '1' THEN 1 END) AS rating_1_count,
    COUNT(CASE WHEN rating_value = '2' THEN 1 END) AS rating_2_count,
    COUNT(CASE WHEN rating_value = '3' THEN 1 END) AS rating_3_count,
    COUNT(CASE WHEN rating_value = '4' THEN 1 END) AS rating_4_count,
    COUNT(CASE WHEN rating_value = '5' THEN 1 END) AS rating_5_count,
    -- class actuals counts:
    COUNT(CASE WHEN rating_value IN ('0','1','2','3','4') THEN 1 END) AS fail_count,
    COUNT(CASE WHEN rating_value = '5' THEN 1 END) AS pass_count,
    -- flagged_count / not_flagged_count:
      -- from the BALANCED classifier flag - uncalibrated
      -- overstates fail-likelihood: read as "flagged for attention", not a true fail-rate estimate.
    COUNT(CASE WHEN scored AND predicted_rating = 'fail' THEN 1 END) AS flagged_count,
    COUNT(CASE WHEN scored AND predicted_rating = 'pass' THEN 1 END) AS not_flagged_count,
    -- risk score average:
    AVG(CASE WHEN scored THEN risk_score END) AS avg_risk_score,
    -- income decile average:
    AVG(CASE WHEN scored THEN income_decile END) AS avg_income_decile
FROM establishments
GROUP BY local_authority_name
ORDER BY local_authority_name;


-- verify view:
SELECT * FROM borough_summary;