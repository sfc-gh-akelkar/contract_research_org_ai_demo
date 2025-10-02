-- ========================================================================
-- CRO ML DEMO - SITE PERFORMANCE DATA SETUP
-- Creates sample data for patient recruitment prediction ML demo
-- ========================================================================

/*
🎯 ML DEMO DATA SETUP

This script creates sample site performance data for the ML demo:
- SITE_PERFORMANCE_FEATURES: 150 sites with 12 engineered features
- Realistic distribution: 50 High, 60 Medium, 40 Low performers
- Features designed for classification and regression ML models

📋 **USAGE:**
Run this script after completing the core CRO setup (scripts 01-04)
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- CREATE SITE PERFORMANCE FEATURES TABLE
-- ========================================================================

CREATE TABLE IF NOT EXISTS SITE_PERFORMANCE_FEATURES (
    -- Identifiers
    SITE_ID VARCHAR(20) PRIMARY KEY,
    SITE_NAME VARCHAR(100) NOT NULL,
    COUNTRY VARCHAR(50) NOT NULL,
    SITE_TIER VARCHAR(20) NOT NULL,
    
    -- Core Performance Metrics
    HISTORICAL_ENROLLMENT_RATE DECIMAL(5,2) NOT NULL COMMENT 'Average subjects enrolled per month',
    DATA_QUALITY_SCORE DECIMAL(5,2) NOT NULL COMMENT 'Data quality score (0-100)',
    INVESTIGATOR_YEARS_EXPERIENCE INTEGER NOT NULL COMMENT 'Principal investigator years of experience',
    REGULATORY_COMPLIANCE_SCORE DECIMAL(5,2) NOT NULL COMMENT 'Regulatory compliance score (0-100)',
    
    -- Operational Metrics
    SCREEN_FAILURE_RATE DECIMAL(5,4) NOT NULL COMMENT 'Proportion of screening failures',
    PROTOCOL_DEVIATION_RATE DECIMAL(5,4) NOT NULL COMMENT 'Protocol deviation rate',
    CRITICAL_FINDINGS_COUNT INTEGER NOT NULL COMMENT 'Number of critical findings in last 2 years',
    PATIENT_RETENTION_RATE DECIMAL(5,4) NOT NULL COMMENT 'Patient retention rate through study completion',
    
    -- Derived Features (for ML feature engineering demo)
    ENROLLMENT_EFFICIENCY DECIMAL(8,4) COMMENT 'Enrollment rate adjusted for screen failures',
    QUALITY_COMPOSITE DECIMAL(5,2) COMMENT 'Combined quality and compliance score',
    RISK_SCORE DECIMAL(6,3) COMMENT 'Combined risk indicator',
    
    -- Target Variables
    PERFORMANCE_CATEGORY VARCHAR(10) NOT NULL COMMENT 'High, Medium, or Low performance classification',
    PREDICTED_ENROLLMENT_RATE DECIMAL(5,2) COMMENT 'Target for regression models',
    
    -- Metadata
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    LAST_UPDATED TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ========================================================================
-- GENERATE SAMPLE DATA
-- ========================================================================

-- Clear existing data if re-running
DELETE FROM SITE_PERFORMANCE_FEATURES WHERE SITE_ID LIKE 'SITE_%';

-- Insert High Performing Sites (50 sites)
INSERT INTO SITE_PERFORMANCE_FEATURES (
    SITE_ID, SITE_NAME, COUNTRY, SITE_TIER,
    HISTORICAL_ENROLLMENT_RATE, DATA_QUALITY_SCORE, INVESTIGATOR_YEARS_EXPERIENCE,
    REGULATORY_COMPLIANCE_SCORE, SCREEN_FAILURE_RATE, PROTOCOL_DEVIATION_RATE,
    CRITICAL_FINDINGS_COUNT, PATIENT_RETENTION_RATE, PERFORMANCE_CATEGORY, PREDICTED_ENROLLMENT_RATE
)
SELECT 
    'SITE_H' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM()), 3, '0') AS SITE_ID,
    'High Performance Site ' || ROW_NUMBER() OVER (ORDER BY RANDOM()) AS SITE_NAME,
    CASE (ROW_NUMBER() OVER (ORDER BY RANDOM()) % 6)
        WHEN 0 THEN 'United States'
        WHEN 1 THEN 'Germany' 
        WHEN 2 THEN 'United Kingdom'
        WHEN 3 THEN 'Canada'
        WHEN 4 THEN 'Australia'
        ELSE 'Netherlands'
    END AS COUNTRY,
    CASE (ROW_NUMBER() OVER (ORDER BY RANDOM()) % 3)
        WHEN 0 THEN 'Tier 1'
        WHEN 1 THEN 'Tier 1'
        ELSE 'Tier 2'
    END AS SITE_TIER,
    -- High performers: 2.5-4.5 subjects/month
    ROUND(UNIFORM(2.5, 4.5, RANDOM()), 2) AS HISTORICAL_ENROLLMENT_RATE,
    -- High data quality: 85-98
    ROUND(UNIFORM(85, 98, RANDOM()), 1) AS DATA_QUALITY_SCORE,
    -- Experienced investigators: 8-25 years
    FLOOR(UNIFORM(8, 25, RANDOM())) AS INVESTIGATOR_YEARS_EXPERIENCE,
    -- High compliance: 88-99
    ROUND(UNIFORM(88, 99, RANDOM()), 1) AS REGULATORY_COMPLIANCE_SCORE,
    -- Low screen failure: 0.05-0.15
    ROUND(UNIFORM(0.05, 0.15, RANDOM()), 4) AS SCREEN_FAILURE_RATE,
    -- Low protocol deviations: 0.01-0.05
    ROUND(UNIFORM(0.01, 0.05, RANDOM()), 4) AS PROTOCOL_DEVIATION_RATE,
    -- Few critical findings: 0-2
    FLOOR(UNIFORM(0, 3, RANDOM())) AS CRITICAL_FINDINGS_COUNT,
    -- High retention: 0.88-0.98
    ROUND(UNIFORM(0.88, 0.98, RANDOM()), 4) AS PATIENT_RETENTION_RATE,
    'High' AS PERFORMANCE_CATEGORY,
    ROUND(UNIFORM(2.8, 4.3, RANDOM()), 2) AS PREDICTED_ENROLLMENT_RATE
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- Insert Medium Performing Sites (60 sites)
INSERT INTO SITE_PERFORMANCE_FEATURES (
    SITE_ID, SITE_NAME, COUNTRY, SITE_TIER,
    HISTORICAL_ENROLLMENT_RATE, DATA_QUALITY_SCORE, INVESTIGATOR_YEARS_EXPERIENCE,
    REGULATORY_COMPLIANCE_SCORE, SCREEN_FAILURE_RATE, PROTOCOL_DEVIATION_RATE,
    CRITICAL_FINDINGS_COUNT, PATIENT_RETENTION_RATE, PERFORMANCE_CATEGORY, PREDICTED_ENROLLMENT_RATE
)
SELECT 
    'SITE_M' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM()), 3, '0') AS SITE_ID,
    'Medium Performance Site ' || ROW_NUMBER() OVER (ORDER BY RANDOM()) AS SITE_NAME,
    CASE (ROW_NUMBER() OVER (ORDER BY RANDOM()) % 8)
        WHEN 0 THEN 'United States'
        WHEN 1 THEN 'Germany'
        WHEN 2 THEN 'United Kingdom'
        WHEN 3 THEN 'Canada'
        WHEN 4 THEN 'France'
        WHEN 5 THEN 'Spain'
        WHEN 6 THEN 'Italy'
        ELSE 'Poland'
    END AS COUNTRY,
    CASE (ROW_NUMBER() OVER (ORDER BY RANDOM()) % 3)
        WHEN 0 THEN 'Tier 2'
        WHEN 1 THEN 'Tier 2'
        ELSE 'Tier 3'
    END AS SITE_TIER,
    -- Medium performers: 1.2-2.8 subjects/month
    ROUND(UNIFORM(1.2, 2.8, RANDOM()), 2) AS HISTORICAL_ENROLLMENT_RATE,
    -- Medium data quality: 70-88
    ROUND(UNIFORM(70, 88, RANDOM()), 1) AS DATA_QUALITY_SCORE,
    -- Mixed experience: 3-15 years
    FLOOR(UNIFORM(3, 15, RANDOM())) AS INVESTIGATOR_YEARS_EXPERIENCE,
    -- Medium compliance: 75-90
    ROUND(UNIFORM(75, 90, RANDOM()), 1) AS REGULATORY_COMPLIANCE_SCORE,
    -- Medium screen failure: 0.12-0.25
    ROUND(UNIFORM(0.12, 0.25, RANDOM()), 4) AS SCREEN_FAILURE_RATE,
    -- Medium protocol deviations: 0.03-0.08
    ROUND(UNIFORM(0.03, 0.08, RANDOM()), 4) AS PROTOCOL_DEVIATION_RATE,
    -- Some critical findings: 1-4
    FLOOR(UNIFORM(1, 5, RANDOM())) AS CRITICAL_FINDINGS_COUNT,
    -- Medium retention: 0.75-0.90
    ROUND(UNIFORM(0.75, 0.90, RANDOM()), 4) AS PATIENT_RETENTION_RATE,
    'Medium' AS PERFORMANCE_CATEGORY,
    ROUND(UNIFORM(1.5, 2.7, RANDOM()), 2) AS PREDICTED_ENROLLMENT_RATE
FROM TABLE(GENERATOR(ROWCOUNT => 60));

-- Insert Low Performing Sites (40 sites)
INSERT INTO SITE_PERFORMANCE_FEATURES (
    SITE_ID, SITE_NAME, COUNTRY, SITE_TIER,
    HISTORICAL_ENROLLMENT_RATE, DATA_QUALITY_SCORE, INVESTIGATOR_YEARS_EXPERIENCE,
    REGULATORY_COMPLIANCE_SCORE, SCREEN_FAILURE_RATE, PROTOCOL_DEVIATION_RATE,
    CRITICAL_FINDINGS_COUNT, PATIENT_RETENTION_RATE, PERFORMANCE_CATEGORY, PREDICTED_ENROLLMENT_RATE
)
SELECT 
    'SITE_L' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM()), 3, '0') AS SITE_ID,
    'Developing Site ' || ROW_NUMBER() OVER (ORDER BY RANDOM()) AS SITE_NAME,
    CASE (ROW_NUMBER() OVER (ORDER BY RANDOM()) % 10)
        WHEN 0 THEN 'United States'
        WHEN 1 THEN 'Brazil'
        WHEN 2 THEN 'Mexico'
        WHEN 3 THEN 'India'
        WHEN 4 THEN 'China'
        WHEN 5 THEN 'South Korea'
        WHEN 6 THEN 'Argentina'
        WHEN 7 THEN 'Chile'
        WHEN 8 THEN 'Czech Republic'
        ELSE 'Hungary'
    END AS COUNTRY,
    CASE (ROW_NUMBER() OVER (ORDER BY RANDOM()) % 2)
        WHEN 0 THEN 'Tier 3'
        ELSE 'Tier 4'
    END AS SITE_TIER,
    -- Low performers: 0.3-1.5 subjects/month
    ROUND(UNIFORM(0.3, 1.5, RANDOM()), 2) AS HISTORICAL_ENROLLMENT_RATE,
    -- Lower data quality: 55-75
    ROUND(UNIFORM(55, 75, RANDOM()), 1) AS DATA_QUALITY_SCORE,
    -- Less experience: 1-8 years
    FLOOR(UNIFORM(1, 8, RANDOM())) AS INVESTIGATOR_YEARS_EXPERIENCE,
    -- Lower compliance: 60-80
    ROUND(UNIFORM(60, 80, RANDOM()), 1) AS REGULATORY_COMPLIANCE_SCORE,
    -- Higher screen failure: 0.20-0.40
    ROUND(UNIFORM(0.20, 0.40, RANDOM()), 4) AS SCREEN_FAILURE_RATE,
    -- Higher protocol deviations: 0.06-0.15
    ROUND(UNIFORM(0.06, 0.15, RANDOM()), 4) AS PROTOCOL_DEVIATION_RATE,
    -- More critical findings: 3-8
    FLOOR(UNIFORM(3, 9, RANDOM())) AS CRITICAL_FINDINGS_COUNT,
    -- Lower retention: 0.60-0.80
    ROUND(UNIFORM(0.60, 0.80, RANDOM()), 4) AS PATIENT_RETENTION_RATE,
    'Low' AS PERFORMANCE_CATEGORY,
    ROUND(UNIFORM(0.5, 1.3, RANDOM()), 2) AS PREDICTED_ENROLLMENT_RATE
FROM TABLE(GENERATOR(ROWCOUNT => 40));

-- ========================================================================
-- UPDATE DERIVED FEATURES
-- ========================================================================

UPDATE SITE_PERFORMANCE_FEATURES SET
    ENROLLMENT_EFFICIENCY = ROUND(
        CASE 
            WHEN SCREEN_FAILURE_RATE >= 0.01 THEN 
                LEAST(HISTORICAL_ENROLLMENT_RATE / SCREEN_FAILURE_RATE, 999.9999)
            ELSE 
                LEAST(HISTORICAL_ENROLLMENT_RATE * 100, 999.9999)  -- Simple multiplier for very low failure rates
        END, 4),
    QUALITY_COMPOSITE = ROUND((DATA_QUALITY_SCORE + REGULATORY_COMPLIANCE_SCORE) / 2, 2),
    RISK_SCORE = ROUND(PROTOCOL_DEVIATION_RATE + (CRITICAL_FINDINGS_COUNT / 10.0), 3),
    LAST_UPDATED = CURRENT_TIMESTAMP();

-- ========================================================================
-- CREATE PREDICTIONS TABLE (FOR ML OUTPUT)
-- ========================================================================

CREATE TABLE IF NOT EXISTS SITE_PREDICTIONS (
    SITE_ID VARCHAR(20) NOT NULL,
    SITE_NAME VARCHAR(100) NOT NULL,
    COUNTRY VARCHAR(50) NOT NULL,
    PREDICTED_PERFORMANCE VARCHAR(10) NOT NULL,
    CONFIDENCE_SCORE DECIMAL(5,3) NOT NULL,
    PREDICTED_ENROLLMENT_RATE DECIMAL(5,2),
    MODEL_VERSION VARCHAR(50),
    PREDICTION_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    PRIMARY KEY (SITE_ID, PREDICTION_DATE)
);

-- ========================================================================
-- VERIFICATION AND SUMMARY
-- ========================================================================

SELECT '🎯 ML DEMO DATA SETUP COMPLETE' AS status;

SELECT 
    '📊 Site Performance Features' AS table_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT COUNTRY) AS countries,
    COUNT(DISTINCT SITE_TIER) AS site_tiers
FROM SITE_PERFORMANCE_FEATURES

UNION ALL

SELECT 
    '📈 Performance Distribution' AS table_name,
    NULL AS total_records,
    NULL AS countries,
    NULL AS site_tiers
FROM DUAL;

-- Performance category breakdown
SELECT 
    PERFORMANCE_CATEGORY,
    COUNT(*) AS site_count,
    ROUND(AVG(HISTORICAL_ENROLLMENT_RATE), 2) AS avg_enrollment_rate,
    ROUND(AVG(DATA_QUALITY_SCORE), 1) AS avg_quality_score,
    ROUND(AVG(INVESTIGATOR_YEARS_EXPERIENCE), 1) AS avg_experience
FROM SITE_PERFORMANCE_FEATURES
GROUP BY PERFORMANCE_CATEGORY
ORDER BY avg_enrollment_rate DESC;

SELECT '✅ Ready for ML Demo! Import notebook: CRO_Patient_Recruitment_ML_Demo.ipynb' AS next_step;
