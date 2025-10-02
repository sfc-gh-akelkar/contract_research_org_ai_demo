-- ========================================================================
-- CRO DEMO - Step 5: ML Data Setup
-- Creates ML-specific tables and sample data for recruitment prediction demo
-- Prerequisites: Run steps 1-4 first
-- ========================================================================

-- Switch to the CRO demo role and database
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- IDEMPOTENCY CHECK
-- This script is safe to run multiple times - it won't recreate/reload if data exists
-- ========================================================================

-- Check if ML tables already exist
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_SCHEMA = 'CLINICAL_OPERATIONS_SCHEMA' 
              AND TABLE_NAME = 'SITE_PERFORMANCE_FEATURES'
        ) AND EXISTS (
            SELECT 1 FROM SITE_PERFORMANCE_FEATURES LIMIT 1
        )
        THEN '⚠️  ML tables already exist with data. Script will skip data insertion. To reload, run: TRUNCATE TABLE SITE_PERFORMANCE_FEATURES;'
        ELSE '✅ ML tables will be created or data will be inserted.'
    END as setup_status;

-- ========================================================================
-- ML FEATURE TABLE: SITE_PERFORMANCE_FEATURES
-- ========================================================================

-- This table contains historical site performance data with engineered features
-- Used for training the recruitment prediction model

CREATE TABLE IF NOT EXISTS SITE_PERFORMANCE_FEATURES (
    SITE_ID VARCHAR(50),
    SITE_NAME VARCHAR(200),
    COUNTRY VARCHAR(100),
    SITE_TIER VARCHAR(20),
    PRINCIPAL_INVESTIGATOR VARCHAR(200),
    
    -- Historical Performance Metrics
    HISTORICAL_ENROLLMENT_RATE DECIMAL(5,2),  -- Average subjects enrolled per month
    TOTAL_TRIALS_COMPLETED INTEGER,
    TOTAL_SUBJECTS_ENROLLED INTEGER,
    AVG_SCREEN_FAILURE_RATE DECIMAL(5,2),
    AVG_DROPOUT_RATE DECIMAL(5,2),
    
    -- Site Quality Metrics
    DATA_QUALITY_SCORE DECIMAL(5,2),
    REGULATORY_COMPLIANCE_SCORE DECIMAL(5,2),
    PROTOCOL_DEVIATION_RATE DECIMAL(5,2),
    QUERY_RESOLUTION_TIME_DAYS DECIMAL(6,2),
    
    -- Operational Metrics
    AVG_STARTUP_TIME_DAYS INTEGER,
    STUDY_AMENDMENTS_PER_TRIAL DECIMAL(4,2),
    MONITORING_VISIT_FREQUENCY INTEGER,
    CRITICAL_FINDINGS_COUNT INTEGER,
    
    -- Investigator Experience
    INVESTIGATOR_YEARS_EXPERIENCE INTEGER,
    INVESTIGATOR_PREVIOUS_STUDIES INTEGER,
    THERAPEUTIC_AREA_EXPERTISE VARCHAR(50),
    
    -- Labels for ML Models
    PERFORMANCE_CATEGORY VARCHAR(20),  -- High, Medium, Low (Classification)
    PREDICTED_ENROLLMENT_RATE DECIMAL(5,2),  -- Target for regression
    
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ========================================================================
-- INSERT COMPREHENSIVE SAMPLE DATA (150 sites)
-- Only runs if table is empty
-- ========================================================================

-- High Performing Sites (50 sites)
INSERT INTO SITE_PERFORMANCE_FEATURES 
SELECT * FROM (
SELECT 
    'SITE_' || LPAD(SEQ4(), 3, '0') as SITE_ID,
    CASE (UNIFORM(1, 10, RANDOM()) % 10)
        WHEN 0 THEN 'Boston Medical Research Center'
        WHEN 1 THEN 'Stanford Clinical Trials Institute'
        WHEN 2 THEN 'Johns Hopkins Research Facility'
        WHEN 3 THEN 'Mayo Clinic Research Center'
        WHEN 4 THEN 'Cleveland Clinic Trials Unit'
        WHEN 5 THEN 'Massachusetts General Hospital'
        WHEN 6 THEN 'UCSF Medical Research Center'
        WHEN 7 THEN 'Duke University Clinical Trials'
        WHEN 8 THEN 'Northwestern Medicine Research'
        ELSE 'University of Pennsylvania Trials'
    END || ' - Site ' || SEQ4() as SITE_NAME,
    CASE (UNIFORM(1, 5, RANDOM()) % 5)
        WHEN 0 THEN 'United States'
        WHEN 1 THEN 'United Kingdom'
        WHEN 2 THEN 'Germany'
        WHEN 3 THEN 'Canada'
        ELSE 'Australia'
    END as COUNTRY,
    'Tier 1' as SITE_TIER,
    'Dr. ' || 
    CASE (UNIFORM(1, 10, RANDOM()) % 10)
        WHEN 0 THEN 'Sarah Johnson'
        WHEN 1 THEN 'Michael Chen'
        WHEN 2 THEN 'Emily Rodriguez'
        WHEN 3 THEN 'David Williams'
        WHEN 4 THEN 'Jennifer Lee'
        WHEN 5 THEN 'Robert Martinez'
        WHEN 6 THEN 'Lisa Anderson'
        WHEN 7 THEN 'James Thompson'
        WHEN 8 THEN 'Maria Garcia'
        ELSE 'Christopher Brown'
    END as PRINCIPAL_INVESTIGATOR,
    
    -- High performance metrics
    UNIFORM(8.0, 15.0, RANDOM()) as HISTORICAL_ENROLLMENT_RATE,
    UNIFORM(15, 30, RANDOM()) as TOTAL_TRIALS_COMPLETED,
    UNIFORM(200, 500, RANDOM()) as TOTAL_SUBJECTS_ENROLLED,
    UNIFORM(5.0, 15.0, RANDOM()) as AVG_SCREEN_FAILURE_RATE,
    UNIFORM(3.0, 10.0, RANDOM()) as AVG_DROPOUT_RATE,
    
    UNIFORM(85.0, 98.0, RANDOM()) as DATA_QUALITY_SCORE,
    UNIFORM(90.0, 100.0, RANDOM()) as REGULATORY_COMPLIANCE_SCORE,
    UNIFORM(1.0, 5.0, RANDOM()) as PROTOCOL_DEVIATION_RATE,
    UNIFORM(2.0, 8.0, RANDOM()) as QUERY_RESOLUTION_TIME_DAYS,
    
    UNIFORM(30, 60, RANDOM()) as AVG_STARTUP_TIME_DAYS,
    UNIFORM(0.5, 2.0, RANDOM()) as STUDY_AMENDMENTS_PER_TRIAL,
    UNIFORM(8, 12, RANDOM()) as MONITORING_VISIT_FREQUENCY,
    UNIFORM(0, 3, RANDOM()) as CRITICAL_FINDINGS_COUNT,
    
    UNIFORM(15, 30, RANDOM()) as INVESTIGATOR_YEARS_EXPERIENCE,
    UNIFORM(20, 50, RANDOM()) as INVESTIGATOR_PREVIOUS_STUDIES,
    CASE (UNIFORM(1, 5, RANDOM()) % 5)
        WHEN 0 THEN 'Oncology'
        WHEN 1 THEN 'Cardiology'
        WHEN 2 THEN 'Neurology'
        WHEN 3 THEN 'Immunology'
        ELSE 'Rare Diseases'
    END as THERAPEUTIC_AREA_EXPERTISE,
    
    'High' as PERFORMANCE_CATEGORY,
    UNIFORM(8.0, 15.0, RANDOM()) as PREDICTED_ENROLLMENT_RATE,
    
    CURRENT_TIMESTAMP() as CREATED_DATE
FROM TABLE(GENERATOR(ROWCOUNT => 50))
) WHERE NOT EXISTS (SELECT 1 FROM SITE_PERFORMANCE_FEATURES LIMIT 1);

-- Medium Performing Sites (60 sites)
INSERT INTO SITE_PERFORMANCE_FEATURES 
SELECT * FROM (
SELECT 
    'SITE_' || LPAD(SEQ4() + 50, 3, '0') as SITE_ID,
    CASE (UNIFORM(1, 10, RANDOM()) % 10)
        WHEN 0 THEN 'Regional Medical Center'
        WHEN 1 THEN 'Community Hospital Trials'
        WHEN 2 THEN 'City Research Institute'
        WHEN 3 THEN 'Medical University Center'
        WHEN 4 THEN 'Healthcare Research Facility'
        WHEN 5 THEN 'Clinical Studies Center'
        WHEN 6 THEN 'Research Medical Group'
        WHEN 7 THEN 'University Hospital Trials'
        WHEN 8 THEN 'Medical Research Associates'
        ELSE 'Clinical Trials Network'
    END || ' - Site ' || (SEQ4() + 50) as SITE_NAME,
    CASE (UNIFORM(1, 8, RANDOM()) % 8)
        WHEN 0 THEN 'United States'
        WHEN 1 THEN 'Spain'
        WHEN 2 THEN 'Italy'
        WHEN 3 THEN 'France'
        WHEN 4 THEN 'Netherlands'
        WHEN 5 THEN 'Belgium'
        WHEN 6 THEN 'Sweden'
        ELSE 'Poland'
    END as COUNTRY,
    'Tier 2' as SITE_TIER,
    'Dr. ' || 
    CASE (UNIFORM(1, 10, RANDOM()) % 10)
        WHEN 0 THEN 'Amanda White'
        WHEN 1 THEN 'Kevin Park'
        WHEN 2 THEN 'Rebecca Taylor'
        WHEN 3 THEN 'Daniel Kim'
        WHEN 4 THEN 'Michelle Wong'
        WHEN 5 THEN 'Brian Jackson'
        WHEN 6 THEN 'Nicole Harris'
        WHEN 7 THEN 'Steven Clark'
        WHEN 8 THEN 'Angela Lewis'
        ELSE 'Matthew Walker'
    END as PRINCIPAL_INVESTIGATOR,
    
    -- Medium performance metrics
    UNIFORM(4.0, 8.0, RANDOM()) as HISTORICAL_ENROLLMENT_RATE,
    UNIFORM(8, 15, RANDOM()) as TOTAL_TRIALS_COMPLETED,
    UNIFORM(80, 200, RANDOM()) as TOTAL_SUBJECTS_ENROLLED,
    UNIFORM(15.0, 25.0, RANDOM()) as AVG_SCREEN_FAILURE_RATE,
    UNIFORM(10.0, 18.0, RANDOM()) as AVG_DROPOUT_RATE,
    
    UNIFORM(70.0, 85.0, RANDOM()) as DATA_QUALITY_SCORE,
    UNIFORM(80.0, 90.0, RANDOM()) as REGULATORY_COMPLIANCE_SCORE,
    UNIFORM(5.0, 10.0, RANDOM()) as PROTOCOL_DEVIATION_RATE,
    UNIFORM(8.0, 15.0, RANDOM()) as QUERY_RESOLUTION_TIME_DAYS,
    
    UNIFORM(60, 90, RANDOM()) as AVG_STARTUP_TIME_DAYS,
    UNIFORM(2.0, 4.0, RANDOM()) as STUDY_AMENDMENTS_PER_TRIAL,
    UNIFORM(4, 8, RANDOM()) as MONITORING_VISIT_FREQUENCY,
    UNIFORM(3, 8, RANDOM()) as CRITICAL_FINDINGS_COUNT,
    
    UNIFORM(8, 15, RANDOM()) as INVESTIGATOR_YEARS_EXPERIENCE,
    UNIFORM(10, 20, RANDOM()) as INVESTIGATOR_PREVIOUS_STUDIES,
    CASE (UNIFORM(1, 5, RANDOM()) % 5)
        WHEN 0 THEN 'Oncology'
        WHEN 1 THEN 'Cardiology'
        WHEN 2 THEN 'Metabolic'
        WHEN 3 THEN 'Respiratory'
        ELSE 'General Medicine'
    END as THERAPEUTIC_AREA_EXPERTISE,
    
    'Medium' as PERFORMANCE_CATEGORY,
    UNIFORM(4.0, 8.0, RANDOM()) as PREDICTED_ENROLLMENT_RATE,
    
    CURRENT_TIMESTAMP() as CREATED_DATE
FROM TABLE(GENERATOR(ROWCOUNT => 60))
) WHERE NOT EXISTS (SELECT 1 FROM SITE_PERFORMANCE_FEATURES WHERE SITE_TIER = 'Tier 2' LIMIT 1);

-- Low Performing Sites (40 sites)
INSERT INTO SITE_PERFORMANCE_FEATURES 
SELECT * FROM (
SELECT 
    'SITE_' || LPAD(SEQ4() + 110, 3, '0') as SITE_ID,
    CASE (UNIFORM(1, 8, RANDOM()) % 8)
        WHEN 0 THEN 'Local Clinic Research'
        WHEN 1 THEN 'Small Hospital Trials'
        WHEN 2 THEN 'Rural Medical Center'
        WHEN 3 THEN 'Community Health Trials'
        WHEN 4 THEN 'Primary Care Research'
        WHEN 5 THEN 'County Hospital Studies'
        WHEN 6 THEN 'District Medical Research'
        ELSE 'Regional Health Trials'
    END || ' - Site ' || (SEQ4() + 110) as SITE_NAME,
    CASE (UNIFORM(1, 10, RANDOM()) % 10)
        WHEN 0 THEN 'Brazil'
        WHEN 1 THEN 'Mexico'
        WHEN 2 THEN 'Argentina'
        WHEN 3 THEN 'India'
        WHEN 4 THEN 'South Africa'
        WHEN 5 THEN 'Romania'
        WHEN 6 THEN 'Bulgaria'
        WHEN 7 THEN 'Czech Republic'
        WHEN 8 THEN 'Hungary'
        ELSE 'Croatia'
    END as COUNTRY,
    'Tier 3' as SITE_TIER,
    'Dr. ' || 
    CASE (UNIFORM(1, 8, RANDOM()) % 8)
        WHEN 0 THEN 'Patricia Moore'
        WHEN 1 THEN 'Richard Young'
        WHEN 2 THEN 'Sandra Allen'
        WHEN 3 THEN 'Thomas Hill'
        WHEN 4 THEN 'Laura Scott'
        WHEN 5 THEN 'Gary Green'
        WHEN 6 THEN 'Donna Adams'
        ELSE 'Frank Turner'
    END as PRINCIPAL_INVESTIGATOR,
    
    -- Low performance metrics
    UNIFORM(1.0, 4.0, RANDOM()) as HISTORICAL_ENROLLMENT_RATE,
    UNIFORM(3, 8, RANDOM()) as TOTAL_TRIALS_COMPLETED,
    UNIFORM(20, 80, RANDOM()) as TOTAL_SUBJECTS_ENROLLED,
    UNIFORM(25.0, 40.0, RANDOM()) as AVG_SCREEN_FAILURE_RATE,
    UNIFORM(18.0, 30.0, RANDOM()) as AVG_DROPOUT_RATE,
    
    UNIFORM(55.0, 70.0, RANDOM()) as DATA_QUALITY_SCORE,
    UNIFORM(70.0, 80.0, RANDOM()) as REGULATORY_COMPLIANCE_SCORE,
    UNIFORM(10.0, 20.0, RANDOM()) as PROTOCOL_DEVIATION_RATE,
    UNIFORM(15.0, 30.0, RANDOM()) as QUERY_RESOLUTION_TIME_DAYS,
    
    UNIFORM(90, 150, RANDOM()) as AVG_STARTUP_TIME_DAYS,
    UNIFORM(4.0, 8.0, RANDOM()) as STUDY_AMENDMENTS_PER_TRIAL,
    UNIFORM(2, 4, RANDOM()) as MONITORING_VISIT_FREQUENCY,
    UNIFORM(8, 15, RANDOM()) as CRITICAL_FINDINGS_COUNT,
    
    UNIFORM(3, 8, RANDOM()) as INVESTIGATOR_YEARS_EXPERIENCE,
    UNIFORM(3, 10, RANDOM()) as INVESTIGATOR_PREVIOUS_STUDIES,
    CASE (UNIFORM(1, 4, RANDOM()) % 4)
        WHEN 0 THEN 'General Medicine'
        WHEN 1 THEN 'Internal Medicine'
        WHEN 2 THEN 'Family Practice'
        ELSE 'Primary Care'
    END as THERAPEUTIC_AREA_EXPERTISE,
    
    'Low' as PERFORMANCE_CATEGORY,
    UNIFORM(1.0, 4.0, RANDOM()) as PREDICTED_ENROLLMENT_RATE,
    
    CURRENT_TIMESTAMP() as CREATED_DATE
FROM TABLE(GENERATOR(ROWCOUNT => 40))
) WHERE NOT EXISTS (SELECT 1 FROM SITE_PERFORMANCE_FEATURES WHERE SITE_TIER = 'Tier 3' LIMIT 1);

-- ========================================================================
-- CREATE TABLE FOR PREDICTIONS (will be populated by ML model)
-- ========================================================================

CREATE TABLE IF NOT EXISTS SITE_PREDICTIONS (
    SITE_ID VARCHAR(50),
    SITE_NAME VARCHAR(200),
    PREDICTED_CATEGORY VARCHAR(20),
    PREDICTED_ENROLLMENT_RATE DECIMAL(5,2),
    CONFIDENCE_SCORE DECIMAL(5,4),
    PREDICTION_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ========================================================================
-- VALIDATION & SUMMARY
-- ========================================================================

SELECT 'ML Data Setup Complete!' as status;

SELECT 
    PERFORMANCE_CATEGORY,
    COUNT(*) as site_count,
    ROUND(AVG(HISTORICAL_ENROLLMENT_RATE), 2) as avg_enrollment_rate,
    ROUND(AVG(DATA_QUALITY_SCORE), 2) as avg_data_quality,
    ROUND(AVG(INVESTIGATOR_YEARS_EXPERIENCE), 1) as avg_investigator_experience
FROM SITE_PERFORMANCE_FEATURES
GROUP BY PERFORMANCE_CATEGORY
ORDER BY 
    CASE PERFORMANCE_CATEGORY 
        WHEN 'High' THEN 1 
        WHEN 'Medium' THEN 2 
        ELSE 3 
    END;

SELECT 
    'Total Sites: ' || COUNT(*) as summary,
    '50 High Performers, 60 Medium, 40 Low (if first run)' as distribution,
    'Ready for ML model training!' as next_step
FROM SITE_PERFORMANCE_FEATURES;
