-- ========================================================================
-- CRO DEMO - Step 5: ML Foundation Phase Setup
-- Implements core ML capabilities for CRO demo
-- Prerequisites: Run steps 1-4 first
-- ========================================================================

-- Switch to the CRO demo role and database
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- ML INFRASTRUCTURE SETUP
-- ========================================================================

-- Create ML-specific schema for models and predictions
CREATE SCHEMA IF NOT EXISTS CRO_AI_DEMO.ML_MODELS
    COMMENT = 'Schema for ML models, predictions, and feature engineering';

-- Grant permissions on ML schema
GRANT ALL PRIVILEGES ON SCHEMA CRO_AI_DEMO.ML_MODELS TO ROLE SF_INTELLIGENCE_DEMO;

USE SCHEMA ML_MODELS;

-- ========================================================================
-- ML FEATURE TABLES
-- ========================================================================

-- Enhanced enrollment features for ML prediction
CREATE OR REPLACE TABLE ML_ENROLLMENT_FEATURES (
    feature_id NUMBER(15,0) NOT NULL,
    study_id NUMBER(10,0),
    site_id NUMBER(10,0),
    feature_date DATE,
    -- Study characteristics
    study_phase VARCHAR(20),
    therapeutic_area VARCHAR(255),
    planned_enrollment NUMBER(8,0),
    study_complexity_score NUMBER(3,1), -- 1-10 scale based on protocol complexity
    -- Site characteristics  
    site_tier VARCHAR(20),
    historical_enrollment_rate NUMBER(5,2),
    site_experience_score NUMBER(3,1), -- Based on previous studies
    investigator_experience_years NUMBER(3,0),
    -- Market factors
    competition_level VARCHAR(20), -- Local competition for similar studies
    patient_population_density NUMBER(8,0), -- Target population in catchment area
    seasonal_factor NUMBER(3,2), -- Seasonal enrollment patterns (0.5-1.5)
    -- Performance metrics
    current_enrollment_rate NUMBER(5,2),
    enrollment_velocity_trend VARCHAR(20), -- 'Accelerating', 'Stable', 'Declining'
    screen_failure_rate NUMBER(5,2),
    -- Target variables for ML
    enrollment_target_met BOOLEAN, -- Did site meet enrollment target?
    days_to_target NUMBER(5,0), -- Days to reach enrollment target
    final_enrollment_rate NUMBER(5,2), -- Actual final enrollment rate
    PRIMARY KEY (feature_id)
);

-- Site performance features for risk scoring
CREATE OR REPLACE TABLE ML_SITE_PERFORMANCE_FEATURES (
    feature_id NUMBER(15,0) NOT NULL,
    site_id NUMBER(10,0),
    evaluation_date DATE,
    -- Site characteristics
    site_tier VARCHAR(20),
    therapeutic_expertise_match NUMBER(3,1), -- How well site expertise matches study
    gcp_certification_days_since NUMBER(5,0),
    active_studies_load NUMBER(3,0),
    -- Historical performance
    historical_enrollment_rate NUMBER(5,2),
    historical_data_quality_avg NUMBER(3,1),
    historical_compliance_avg NUMBER(3,1),
    previous_study_completion_rate NUMBER(5,2), -- % of studies completed on time
    -- Current performance indicators
    current_enrollment_vs_target NUMBER(5,2), -- % of target achieved
    query_resolution_rate NUMBER(5,2),
    protocol_deviation_rate NUMBER(5,2),
    monitoring_visit_frequency NUMBER(3,1), -- Visits per month
    -- Risk factors
    staff_turnover_indicator BOOLEAN,
    regulatory_issues_count NUMBER(3,0), -- Recent regulatory issues
    sponsor_escalations_count NUMBER(3,0), -- Recent sponsor complaints
    -- Target variable for ML
    site_risk_level VARCHAR(20), -- 'Low', 'Medium', 'High'
    underperformance_indicator BOOLEAN, -- Site underperformed in last 6 months
    PRIMARY KEY (feature_id)
);

-- ML model registry
CREATE OR REPLACE TABLE ML_MODEL_REGISTRY (
    model_id VARCHAR(100) NOT NULL,
    model_name VARCHAR(255),
    model_type VARCHAR(100), -- 'enrollment_prediction', 'site_risk_scoring'
    model_version VARCHAR(20),
    training_date TIMESTAMP,
    model_status VARCHAR(50), -- 'Training', 'Active', 'Deprecated'
    feature_importance VARIANT, -- JSON with feature importance scores
    performance_metrics VARIANT, -- JSON with accuracy, precision, recall, etc.
    model_parameters VARIANT, -- JSON with hyperparameters
    training_data_period VARCHAR(100), -- Date range of training data
    created_by VARCHAR(255),
    comments VARCHAR(1000),
    PRIMARY KEY (model_id)
);

-- ML predictions storage
CREATE OR REPLACE TABLE ML_PREDICTIONS (
    prediction_id NUMBER(15,0) NOT NULL,
    model_id VARCHAR(100),
    prediction_date TIMESTAMP,
    entity_type VARCHAR(50), -- 'study_site', 'site_performance'
    entity_id NUMBER(10,0), -- study_id or site_id
    prediction_value NUMBER(10,4), -- Predicted value (probability, score, etc.)
    prediction_category VARCHAR(100), -- 'High Risk', 'On Track', etc.
    confidence_score NUMBER(5,4), -- Model confidence (0-1)
    feature_values VARIANT, -- JSON with input features used
    business_impact VARCHAR(500), -- Human-readable business interpretation
    PRIMARY KEY (prediction_id),
    FOREIGN KEY (model_id) REFERENCES ML_MODEL_REGISTRY(model_id)
);

-- ========================================================================
-- SAMPLE ML FEATURE DATA
-- ========================================================================

-- Generate comprehensive enrollment features dataset (120 records for credible ML)
WITH base_studies AS (
    SELECT study_id, therapeutic_area_id, study_phase, planned_enrollment, study_title
    FROM CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_STUDIES
),
base_sites AS (
    SELECT site_id, site_tier, historical_enrollment_rate, data_quality_score, country
    FROM CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_SITES
),
therapeutic_mapping AS (
    SELECT 
        therapeutic_area_id,
        therapeutic_area_name,
        CASE therapeutic_area_name
            WHEN 'Oncology' THEN 8.5
            WHEN 'Central Nervous System' THEN 9.2
            WHEN 'Cardiovascular' THEN 6.8
            WHEN 'Rare Diseases' THEN 9.5
            WHEN 'Infectious Diseases' THEN 5.2
            ELSE 7.0
        END as base_complexity_score
    FROM CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_THERAPEUTIC_AREAS
),
expanded_combinations AS (
    SELECT 
        (s.study_id * 1000 + st.site_id + (seq.seq * 10000)) as feature_id,
        s.study_id,
        st.site_id,
        DATEADD(month, seq.seq, '2024-01-01'::DATE) as feature_date,
        s.study_phase,
        tm.therapeutic_area_name as therapeutic_area,
        s.planned_enrollment,
        -- Study complexity with realistic variation
        tm.base_complexity_score + (UNIFORM(1, 100, RANDOM()) / 50.0 - 1.0) as study_complexity_score,
        st.site_tier,
        -- Historical enrollment rate with site-specific patterns
        st.historical_enrollment_rate * (0.8 + UNIFORM(1, 100, RANDOM()) / 250.0) as historical_enrollment_rate,
        -- Site experience score based on tier and data quality
        CASE st.site_tier
            WHEN 'Tier 1' THEN 8.5 + (st.data_quality_score - 9.0) * 0.5
            WHEN 'Tier 2' THEN 7.0 + (st.data_quality_score - 8.5) * 0.5
            ELSE 6.0 + (st.data_quality_score - 8.0) * 0.5
        END as site_experience_score,
        -- Investigator experience (5-25 years, tier-dependent)
        CASE st.site_tier
            WHEN 'Tier 1' THEN 12 + UNIFORM(1, 100, RANDOM()) / 8
            WHEN 'Tier 2' THEN 8 + UNIFORM(1, 100, RANDOM()) / 10
            ELSE 5 + UNIFORM(1, 100, RANDOM()) / 12
        END as investigator_experience_years,
        -- Competition level based on therapeutic area and geography
        CASE 
            WHEN tm.therapeutic_area_name IN ('Oncology', 'Rare Diseases') AND st.country IN ('United States', 'Germany') THEN 'High'
            WHEN tm.therapeutic_area_name = 'Central Nervous System' THEN 'Medium'
            ELSE 'Low'
        END as competition_level,
        -- Patient population density (country and therapeutic area dependent)
        CASE st.country
            WHEN 'United States' THEN 45000 + UNIFORM(1, 100, RANDOM()) * 300
            WHEN 'Germany' THEN 35000 + UNIFORM(1, 100, RANDOM()) * 200
            WHEN 'United Kingdom' THEN 40000 + UNIFORM(1, 100, RANDOM()) * 250
            WHEN 'Canada' THEN 25000 + UNIFORM(1, 100, RANDOM()) * 150
            ELSE 20000 + UNIFORM(1, 100, RANDOM()) * 100
        END as patient_population_density,
        -- Seasonal factor (month-dependent)
        CASE MONTH(DATEADD(month, seq.seq, '2024-01-01'::DATE))
            WHEN 1 THEN 0.9  -- January: post-holiday slow
            WHEN 2 THEN 0.95 -- February: building up
            WHEN 3 THEN 1.1  -- March: spring enrollment peak
            WHEN 4 THEN 1.15 -- April: peak season
            WHEN 5 THEN 1.1  -- May: still strong
            WHEN 6 THEN 1.0  -- June: summer start
            WHEN 7 THEN 0.85 -- July: summer vacation
            WHEN 8 THEN 0.8  -- August: vacation continues
            WHEN 9 THEN 1.05 -- September: back to school/work
            WHEN 10 THEN 1.1 -- October: fall peak
            WHEN 11 THEN 0.95 -- November: holiday prep
            ELSE 0.8         -- December: holidays
        END as seasonal_factor,
        -- Current enrollment rate (realistic variation)
        st.historical_enrollment_rate * (0.7 + UNIFORM(1, 100, RANDOM()) / 167.0) as current_enrollment_rate,
        -- Enrollment velocity trend
        CASE 
            WHEN UNIFORM(1, 100, RANDOM()) < 30 THEN 'Accelerating'
            WHEN UNIFORM(1, 100, RANDOM()) < 70 THEN 'Stable'
            ELSE 'Declining'
        END as enrollment_velocity_trend,
        -- Screen failure rate (therapeutic area dependent)
        CASE tm.therapeutic_area_name
            WHEN 'Oncology' THEN 15 + UNIFORM(1, 100, RANDOM()) / 10.0
            WHEN 'Central Nervous System' THEN 20 + UNIFORM(1, 100, RANDOM()) / 8.0
            WHEN 'Rare Diseases' THEN 25 + UNIFORM(1, 100, RANDOM()) / 6.0
            ELSE 10 + UNIFORM(1, 100, RANDOM()) / 12.0
        END as screen_failure_rate,
        -- Enrollment target met (success indicator)
        CASE WHEN UNIFORM(1, 100, RANDOM()) < 75 THEN TRUE ELSE FALSE END as enrollment_target_met,
        -- Days to target (for successful sites)
        CASE WHEN UNIFORM(1, 100, RANDOM()) < 75 
             THEN 120 + UNIFORM(1, 100, RANDOM()) * 1.5
             ELSE NULL 
        END as days_to_target,
        seq.seq as record_sequence
    FROM base_studies s
    CROSS JOIN base_sites st
    CROSS JOIN therapeutic_mapping tm
    CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 as seq FROM TABLE(GENERATOR(ROWCOUNT => 5))) seq
    WHERE s.therapeutic_area_id = tm.therapeutic_area_id
),
final_enrollment_features AS (
    SELECT 
        feature_id,
        study_id,
        site_id,
        feature_date,
        study_phase,
        therapeutic_area,
        planned_enrollment,
        study_complexity_score,
        site_tier,
        historical_enrollment_rate,
        site_experience_score,
        investigator_experience_years,
        competition_level,
        patient_population_density,
        seasonal_factor,
        current_enrollment_rate,
        enrollment_velocity_trend,
        screen_failure_rate,
        enrollment_target_met,
        days_to_target,
        -- Calculate final enrollment rate based on multiple factors
        GREATEST(1.0, 
            historical_enrollment_rate * 
            seasonal_factor * 
            (CASE competition_level WHEN 'High' THEN 0.8 WHEN 'Medium' THEN 0.9 ELSE 1.0 END) *
            (site_experience_score / 10.0) *
            (1.0 - screen_failure_rate / 100.0) *
            (CASE site_tier WHEN 'Tier 1' THEN 1.1 WHEN 'Tier 2' THEN 1.0 ELSE 0.9 END) +
            (UNIFORM(1, 100, RANDOM()) / 100.0 - 0.5) -- Add some noise
        ) as final_enrollment_rate
    FROM expanded_combinations
)
INSERT INTO ML_ENROLLMENT_FEATURES 
SELECT * FROM final_enrollment_features;

-- Generate comprehensive site performance features dataset (100 records for credible ML)
WITH base_sites_extended AS (
    SELECT 
        s.site_id,
        s.site_tier,
        s.historical_enrollment_rate,
        s.data_quality_score,
        s.regulatory_compliance_score,
        s.country,
        s.therapeutic_expertise,
        -- Add clustering-ready features
        s.enrollment_capacity,
        s.active_studies_count
    FROM CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_SITES s
),
time_periods AS (
    SELECT 
        DATEADD(month, seq, '2024-01-01'::DATE) as evaluation_date,
        seq as time_offset
    FROM (SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 as seq FROM TABLE(GENERATOR(ROWCOUNT => 20)))
),
expanded_site_performance AS (
    SELECT 
        (s.site_id * 1000 + t.time_offset * 100 + UNIFORM(1, 100, RANDOM())) as feature_id,
        s.site_id,
        t.evaluation_date,
        s.site_tier,
        -- Therapeutic expertise match (varies by time as studies change)
        GREATEST(5.0, LEAST(10.0, 
            CASE s.site_tier
                WHEN 'Tier 1' THEN 8.5 + (UNIFORM(1, 100, RANDOM()) / 50.0 - 1.0)
                WHEN 'Tier 2' THEN 7.5 + (UNIFORM(1, 100, RANDOM()) / 50.0 - 1.0)
                ELSE 6.5 + (UNIFORM(1, 100, RANDOM()) / 50.0 - 1.0)
            END
        )) as therapeutic_expertise_match,
        -- GCP certification days since (increases over time)
        GREATEST(30, 365 + t.time_offset * 30 + UNIFORM(1, 100, RANDOM()) * 5) as gcp_certification_days_since,
        -- Active studies load (varies by site capacity)
        GREATEST(1, LEAST(s.enrollment_capacity / 5, 
            s.active_studies_count + UNIFORM(1, 100, RANDOM()) / 50 - 1
        )) as active_studies_load,
        -- Historical performance metrics with time-based variation
        s.historical_enrollment_rate * (0.9 + UNIFORM(1, 100, RANDOM()) / 500.0) as historical_enrollment_rate,
        s.data_quality_score + (UNIFORM(1, 100, RANDOM()) / 100.0 - 0.5) as historical_data_quality_avg,
        s.regulatory_compliance_score + (UNIFORM(1, 100, RANDOM()) / 100.0 - 0.5) as historical_compliance_avg,
        -- Previous study completion rate (tier-dependent)
        CASE s.site_tier
            WHEN 'Tier 1' THEN 85 + UNIFORM(1, 100, RANDOM()) / 10.0
            WHEN 'Tier 2' THEN 75 + UNIFORM(1, 100, RANDOM()) / 8.0
            ELSE 65 + UNIFORM(1, 100, RANDOM()) / 6.0
        END as previous_study_completion_rate,
        -- Current performance indicators
        GREATEST(50.0, LEAST(120.0,
            100 + (s.data_quality_score - 8.5) * 10 + (UNIFORM(1, 100, RANDOM()) / 10.0 - 5.0)
        )) as current_enrollment_vs_target,
        -- Query resolution rate (data quality dependent)
        GREATEST(60.0, LEAST(100.0,
            s.data_quality_score * 10 + (UNIFORM(1, 100, RANDOM()) / 10.0 - 5.0)
        )) as query_resolution_rate,
        -- Protocol deviation rate (compliance dependent)
        GREATEST(0.5, LEAST(15.0,
            (10.0 - s.regulatory_compliance_score) * 1.5 + (UNIFORM(1, 100, RANDOM()) / 20.0)
        )) as protocol_deviation_rate,
        -- Monitoring visit frequency (tier and performance dependent)
        CASE s.site_tier
            WHEN 'Tier 1' THEN 2.5 + UNIFORM(1, 100, RANDOM()) / 100.0
            WHEN 'Tier 2' THEN 3.0 + UNIFORM(1, 100, RANDOM()) / 80.0
            ELSE 3.5 + UNIFORM(1, 100, RANDOM()) / 60.0
        END as monitoring_visit_frequency,
        -- Risk factors
        CASE WHEN UNIFORM(1, 100, RANDOM()) < 15 THEN TRUE ELSE FALSE END as staff_turnover_indicator,
        -- Regulatory issues (tier-dependent probability)
        CASE 
            WHEN s.site_tier = 'Tier 1' AND UNIFORM(1, 100, RANDOM()) < 5 THEN 1
            WHEN s.site_tier = 'Tier 2' AND UNIFORM(1, 100, RANDOM()) < 10 THEN UNIFORM(1, 3, RANDOM())
            WHEN UNIFORM(1, 100, RANDOM()) < 20 THEN UNIFORM(1, 4, RANDOM())
            ELSE 0
        END as regulatory_issues_count,
        -- Sponsor escalations (performance dependent)
        CASE 
            WHEN s.data_quality_score > 9.0 AND UNIFORM(1, 100, RANDOM()) < 5 THEN 0
            WHEN s.data_quality_score > 8.5 AND UNIFORM(1, 100, RANDOM()) < 15 THEN UNIFORM(0, 1, RANDOM())
            WHEN UNIFORM(1, 100, RANDOM()) < 25 THEN UNIFORM(0, 3, RANDOM())
            ELSE 0
        END as sponsor_escalations_count,
        t.time_offset
    FROM base_sites_extended s
    CROSS JOIN time_periods t
),
final_site_features AS (
    SELECT 
        feature_id,
        site_id,
        evaluation_date,
        site_tier,
        therapeutic_expertise_match,
        gcp_certification_days_since,
        active_studies_load,
        historical_enrollment_rate,
        historical_data_quality_avg,
        historical_compliance_avg,
        previous_study_completion_rate,
        current_enrollment_vs_target,
        query_resolution_rate,
        protocol_deviation_rate,
        monitoring_visit_frequency,
        staff_turnover_indicator,
        regulatory_issues_count,
        sponsor_escalations_count,
        -- Determine site risk level based on multiple factors
        CASE 
            WHEN (protocol_deviation_rate > 8.0 OR regulatory_issues_count > 2 OR 
                  query_resolution_rate < 75.0 OR staff_turnover_indicator = TRUE) THEN 'High'
            WHEN (protocol_deviation_rate > 5.0 OR regulatory_issues_count > 0 OR 
                  query_resolution_rate < 85.0 OR current_enrollment_vs_target < 80.0) THEN 'Medium'
            ELSE 'Low'
        END as site_risk_level,
        -- Underperformance indicator (target variable for ML)
        CASE 
            WHEN (current_enrollment_vs_target < 75.0 OR protocol_deviation_rate > 10.0 OR 
                  query_resolution_rate < 70.0 OR regulatory_issues_count > 3) THEN TRUE
            ELSE FALSE
        END as underperformance_indicator
    FROM expanded_site_performance
)
INSERT INTO ML_SITE_PERFORMANCE_FEATURES 
SELECT * FROM final_site_features;

-- ========================================================================
-- ML PROCEDURES - Foundation PHASE
-- ========================================================================

-- Python-SQL Integration Stored Procedure
-- This procedure demonstrates how Python ML models can be deployed as SQL functions
CREATE OR REPLACE PROCEDURE DEPLOY_PYTHON_ML_PREDICTIONS()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'numpy', 'scikit-learn')
HANDLER = 'deploy_ml_predictions'
COMMENT = 'Deploy Python Random Forest predictions to SQL tables for business user access'
AS
$$
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.preprocessing import LabelEncoder, StandardScaler
from datetime import datetime
import json

def deploy_ml_predictions(session):
    """
    Deploy Python ML model predictions to SQL infrastructure
    This bridges Python development with SQL production deployment
    """
    
    try:
        # Load training data from Snowflake tables
        enrollment_df = session.table("CRO_AI_DEMO.ML_MODELS.ML_ENROLLMENT_FEATURES").to_pandas()
        site_performance_df = session.table("CRO_AI_DEMO.ML_MODELS.ML_SITE_PERFORMANCE_FEATURES").to_pandas()
        
        # Feature engineering for enrollment prediction
        enrollment_features = [
            'study_complexity_score', 'historical_enrollment_rate', 'site_experience_score',
            'investigator_experience_years', 'patient_population_density', 'seasonal_factor',
            'screen_failure_rate'
        ]
        
        # Prepare enrollment data
        enrollment_ml_df = enrollment_df[enrollment_df['final_enrollment_rate'].notna()].copy()
        
        # Encode categorical variables
        le_competition = LabelEncoder()
        le_site_tier = LabelEncoder()
        le_therapeutic = LabelEncoder()
        
        enrollment_ml_df['competition_level_encoded'] = le_competition.fit_transform(enrollment_ml_df['competition_level'])
        enrollment_ml_df['site_tier_encoded'] = le_site_tier.fit_transform(enrollment_ml_df['site_tier'])
        enrollment_ml_df['therapeutic_area_encoded'] = le_therapeutic.fit_transform(enrollment_ml_df['therapeutic_area'])
        
        enrollment_features.extend(['competition_level_encoded', 'site_tier_encoded', 'therapeutic_area_encoded'])
        
        # Prepare feature matrix and target
        X_enrollment = enrollment_ml_df[enrollment_features]
        y_enrollment = enrollment_ml_df['final_enrollment_rate']
        
        # Train Random Forest Enrollment Model
        rf_enrollment = RandomForestRegressor(
            n_estimators=100, max_depth=10, min_samples_split=5,
            min_samples_leaf=2, random_state=42, n_jobs=-1
        )
        rf_enrollment.fit(X_enrollment, y_enrollment)
        
        # Generate predictions
        enrollment_predictions = rf_enrollment.predict(X_enrollment)
        
        # Create prediction results for SQL deployment
        prediction_results = []
        for i, (idx, row) in enumerate(enrollment_ml_df.iterrows()):
            prediction_results.append({
                'prediction_id': 10000 + i,
                'model_id': 'rf_enrollment_python_v1',
                'prediction_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'entity_type': 'study_site',
                'entity_id': int(row['study_id']),
                'site_id': int(row['site_id']),
                'prediction_value': float(enrollment_predictions[i]),
                'prediction_category': 'High Performance Expected' if enrollment_predictions[i] > 8 
                                    else 'On Track' if enrollment_predictions[i] > 5 
                                    else 'At Risk',
                'confidence_score': 0.85,
                'business_impact': f"Predicted enrollment: {enrollment_predictions[i]:.1f} subjects/week"
            })
        
        # Convert to DataFrame and save to Snowflake
        predictions_df = pd.DataFrame(prediction_results)
        
        # Clear existing predictions and insert new ones
        session.sql("DELETE FROM CRO_AI_DEMO.ML_MODELS.ML_PREDICTIONS WHERE model_id = 'rf_enrollment_python_v1'").collect()
        
        # Write predictions back to Snowflake
        session.write_pandas(
            predictions_df, 
            table_name="ML_PREDICTIONS",
            database="CRO_AI_DEMO",
            schema="ML_MODELS",
            auto_create_table=False,
            overwrite=False
        )
        
        # Update model registry
        model_registry_data = {
            'model_id': 'rf_enrollment_python_v1',
            'model_name': 'Python Random Forest Enrollment Predictor',
            'model_type': 'enrollment_prediction',
            'model_version': 'v1.0',
            'training_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'model_status': 'Active',
            'performance_metrics': json.dumps({
                'training_samples': len(X_enrollment),
                'features_count': len(enrollment_features),
                'model_type': 'RandomForestRegressor'
            }),
            'comments': 'Python-developed Random Forest with clinical domain features - deployed via Snowpark'
        }
        
        # Insert model registry entry
        session.sql(f"""
            MERGE INTO CRO_AI_DEMO.ML_MODELS.ML_MODEL_REGISTRY AS target
            USING (SELECT 
                '{model_registry_data['model_id']}' as model_id,
                '{model_registry_data['model_name']}' as model_name,
                '{model_registry_data['model_type']}' as model_type,
                '{model_registry_data['model_version']}' as model_version,
                '{model_registry_data['training_date']}'::timestamp as training_date,
                '{model_registry_data['model_status']}' as model_status,
                '{model_registry_data['performance_metrics']}' as performance_metrics,
                '{model_registry_data['comments']}' as comments
            ) AS source
            ON target.model_id = source.model_id
            WHEN MATCHED THEN UPDATE SET
                model_name = source.model_name,
                model_version = source.model_version,
                training_date = source.training_date,
                model_status = source.model_status,
                performance_metrics = source.performance_metrics,
                comments = source.comments
            WHEN NOT MATCHED THEN INSERT VALUES (
                source.model_id, source.model_name, source.model_type, source.model_version,
                source.training_date, source.model_status, source.performance_metrics, source.comments
            )
        """).collect()
        
        return f"✅ Successfully deployed {len(prediction_results)} Python ML predictions to SQL infrastructure. Model: rf_enrollment_python_v1"
        
    except Exception as e:
        return f"❌ Error deploying Python ML predictions: {str(e)}"
$$;

-- Call the Python ML deployment procedure
-- This demonstrates the "Python development → SQL deployment" workflow
CALL DEPLOY_PYTHON_ML_PREDICTIONS();

-- Procedure 1: Enrollment Prediction Model (Simple Linear Regression)
CREATE OR REPLACE PROCEDURE TRAIN_ENROLLMENT_PREDICTION_MODEL()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'scikit-learn', 'pandas', 'numpy')
HANDLER = 'train_enrollment_model'
AS
$$
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score
import json
from datetime import datetime

def train_enrollment_model(session):
    try:
        # Fetch training data
        training_data = session.sql("""
            SELECT 
                study_complexity_score,
                historical_enrollment_rate,
                site_experience_score,
                patient_population_density,
                seasonal_factor,
                competition_level,
                final_enrollment_rate
            FROM ML_ENROLLMENT_FEATURES 
            WHERE final_enrollment_rate IS NOT NULL
        """).to_pandas()
        
        if len(training_data) < 3:
            return "Insufficient training data. Need at least 3 records."
        
        # Encode categorical variables
        training_data['competition_numeric'] = training_data['competition_level'].map({
            'Low': 1, 'Medium': 2, 'High': 3
        })
        
        # Prepare features and target
        feature_columns = [
            'study_complexity_score', 'historical_enrollment_rate', 
            'site_experience_score', 'patient_population_density', 
            'seasonal_factor', 'competition_numeric'
        ]
        
        X = training_data[feature_columns].fillna(0)
        y = training_data['final_enrollment_rate']
        
        # Train model
        model = LinearRegression()
        model.fit(X, y)
        
        # Calculate performance metrics
        y_pred = model.predict(X)
        mae = mean_absolute_error(y, y_pred)
        r2 = r2_score(y, y_pred)
        
        # Store model metadata
        model_id = f"enrollment_prediction_v1_{datetime.now().strftime('%Y%m%d')}"
        
        feature_importance = dict(zip(feature_columns, model.coef_))
        performance_metrics = {
            'mean_absolute_error': float(mae),
            'r2_score': float(r2),
            'training_samples': len(training_data)
        }
        
        # Insert model registry entry
        session.sql(f"""
            INSERT INTO ML_MODEL_REGISTRY VALUES (
                '{model_id}',
                'Enrollment Rate Prediction Model',
                'enrollment_prediction',
                'v1.0',
                CURRENT_TIMESTAMP(),
                'Active',
                PARSE_JSON('{json.dumps(feature_importance)}'),
                PARSE_JSON('{json.dumps(performance_metrics)}'),
                PARSE_JSON('{json.dumps({"algorithm": "LinearRegression"})}'),
                'Historical data through {datetime.now().strftime("%Y-%m-%d")}',
                'ML_SYSTEM',
                'Foundation Phase - Simple enrollment prediction using linear regression'
            )
        """).collect()
        
        return f"Model trained successfully! Model ID: {model_id}, R2 Score: {r2:.3f}, MAE: {mae:.3f}"
        
    except Exception as e:
        return f"Error training model: {str(e)}"
$$;

-- Procedure 2: Site Risk Scoring Model (Logistic Regression)
CREATE OR REPLACE PROCEDURE TRAIN_SITE_RISK_SCORING_MODEL()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'scikit-learn', 'pandas', 'numpy')
HANDLER = 'train_site_risk_model'
AS
$$
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
import json
from datetime import datetime

def train_site_risk_model(session):
    try:
        # Fetch training data
        training_data = session.sql("""
            SELECT 
                therapeutic_expertise_match,
                active_studies_load,
                historical_enrollment_rate,
                historical_data_quality_avg,
                query_resolution_rate,
                protocol_deviation_rate,
                staff_turnover_indicator,
                regulatory_issues_count,
                underperformance_indicator
            FROM ML_SITE_PERFORMANCE_FEATURES 
            WHERE underperformance_indicator IS NOT NULL
        """).to_pandas()
        
        if len(training_data) < 3:
            return "Insufficient training data. Need at least 3 records."
        
        # Prepare features and target
        feature_columns = [
            'therapeutic_expertise_match', 'active_studies_load', 
            'historical_enrollment_rate', 'historical_data_quality_avg',
            'query_resolution_rate', 'protocol_deviation_rate',
            'regulatory_issues_count'
        ]
        
        X = training_data[feature_columns].fillna(0)
        # Convert boolean to int
        training_data['staff_turnover_numeric'] = training_data['staff_turnover_indicator'].astype(int)
        X['staff_turnover_numeric'] = training_data['staff_turnover_numeric']
        feature_columns.append('staff_turnover_numeric')
        
        y = training_data['underperformance_indicator'].astype(int)
        
        # Train model
        model = LogisticRegression(random_state=42)
        model.fit(X, y)
        
        # Calculate performance metrics
        y_pred = model.predict(X)
        y_prob = model.predict_proba(X)[:, 1]
        
        accuracy = accuracy_score(y, y_pred)
        precision = precision_score(y, y_pred, zero_division=0)
        recall = recall_score(y, y_pred, zero_division=0)
        f1 = f1_score(y, y_pred, zero_division=0)
        
        # Store model metadata
        model_id = f"site_risk_scoring_v1_{datetime.now().strftime('%Y%m%d')}"
        
        feature_importance = dict(zip(feature_columns, model.coef_[0]))
        performance_metrics = {
            'accuracy': float(accuracy),
            'precision': float(precision),
            'recall': float(recall),
            'f1_score': float(f1),
            'training_samples': len(training_data)
        }
        
        # Insert model registry entry
        session.sql(f"""
            INSERT INTO ML_MODEL_REGISTRY VALUES (
                '{model_id}',
                'Site Risk Scoring Model',
                'site_risk_scoring',
                'v1.0',
                CURRENT_TIMESTAMP(),
                'Active',
                PARSE_JSON('{json.dumps(feature_importance)}'),
                PARSE_JSON('{json.dumps(performance_metrics)}'),
                PARSE_JSON('{json.dumps({"algorithm": "LogisticRegression", "random_state": 42})}'),
                'Historical data through {datetime.now().strftime("%Y-%m-%d")}',
                'ML_SYSTEM',
                'Foundation Phase - Site risk classification using logistic regression'
            )
        """).collect()
        
        return f"Model trained successfully! Model ID: {model_id}, Accuracy: {accuracy:.3f}, F1 Score: {f1:.3f}"
        
    except Exception as e:
        return f"Error training model: {str(e)}"
$$;

-- Procedure 3: Generate Enrollment Predictions
CREATE OR REPLACE PROCEDURE GENERATE_ENROLLMENT_PREDICTIONS(MODEL_ID VARCHAR)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'scikit-learn', 'pandas', 'numpy')
HANDLER = 'generate_enrollment_predictions'
AS
$$
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
import json
from datetime import datetime

def generate_enrollment_predictions(session, model_id):
    try:
        # Get current studies needing predictions
        current_data = session.sql("""
            SELECT DISTINCT
                f.study_id,
                f.site_id,
                f.study_complexity_score,
                f.historical_enrollment_rate,
                f.site_experience_score,
                f.patient_population_density,
                f.seasonal_factor,
                f.competition_level,
                s.study_title,
                st.site_name
            FROM ML_ENROLLMENT_FEATURES f
            JOIN CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_STUDIES s ON f.study_id = s.study_id
            JOIN CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_SITES st ON f.site_id = st.site_id
            WHERE f.final_enrollment_rate IS NULL  -- Only predict for ongoing studies
        """).to_pandas()
        
        if len(current_data) == 0:
            return "No studies found requiring enrollment predictions."
        
        # Retrain simple model (in production, would load saved model)
        training_data = session.sql("""
            SELECT 
                study_complexity_score,
                historical_enrollment_rate,
                site_experience_score,
                patient_population_density,
                seasonal_factor,
                competition_level,
                final_enrollment_rate
            FROM ML_ENROLLMENT_FEATURES 
            WHERE final_enrollment_rate IS NOT NULL
        """).to_pandas()
        
        # Encode categorical variables
        training_data['competition_numeric'] = training_data['competition_level'].map({
            'Low': 1, 'Medium': 2, 'High': 3
        })
        current_data['competition_numeric'] = current_data['competition_level'].map({
            'Low': 1, 'Medium': 2, 'High': 3
        })
        
        feature_columns = [
            'study_complexity_score', 'historical_enrollment_rate', 
            'site_experience_score', 'patient_population_density', 
            'seasonal_factor', 'competition_numeric'
        ]
        
        X_train = training_data[feature_columns].fillna(0)
        y_train = training_data['final_enrollment_rate']
        
        model = LinearRegression()
        model.fit(X_train, y_train)
        
        # Generate predictions
        X_pred = current_data[feature_columns].fillna(0)
        predictions = model.predict(X_pred)
        
        # Store predictions
        prediction_count = 0
        for idx, row in current_data.iterrows():
            pred_value = predictions[idx]
            
            # Determine prediction category
            if pred_value >= 8.0:
                category = "High Performance Expected"
                business_impact = f"Site {row['site_name']} predicted to achieve {pred_value:.1f} subjects/month - exceeds targets"
            elif pred_value >= 5.0:
                category = "On Track"
                business_impact = f"Site {row['site_name']} predicted to achieve {pred_value:.1f} subjects/month - meets expectations"
            else:
                category = "At Risk"
                business_impact = f"Site {row['site_name']} predicted to achieve {pred_value:.1f} subjects/month - may need intervention"
            
            # Calculate confidence (simplified)
            confidence = min(0.95, max(0.6, 1.0 - abs(pred_value - np.mean(predictions)) / np.std(predictions)))
            
            feature_values = {col: float(row[col]) for col in feature_columns}
            
            session.sql(f"""
                INSERT INTO ML_PREDICTIONS VALUES (
                    {10000 + prediction_count},
                    '{model_id}',
                    CURRENT_TIMESTAMP(),
                    'study_site',
                    {row['study_id']},
                    {pred_value},
                    '{category}',
                    {confidence},
                    PARSE_JSON('{json.dumps(feature_values)}'),
                    '{business_impact}'
                )
            """).collect()
            
            prediction_count += 1
        
        return f"Generated {prediction_count} enrollment predictions using model {model_id}"
        
    except Exception as e:
        return f"Error generating predictions: {str(e)}"
$$;

-- Procedure 4: Generate Site Risk Scores
CREATE OR REPLACE PROCEDURE GENERATE_SITE_RISK_SCORES(MODEL_ID VARCHAR)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python', 'scikit-learn', 'pandas', 'numpy')
HANDLER = 'generate_site_risk_scores'
AS
$$
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
import json
from datetime import datetime

def generate_site_risk_scores(session, model_id):
    try:
        # Get current sites needing risk assessment
        current_data = session.sql("""
            SELECT DISTINCT
                f.site_id,
                f.therapeutic_expertise_match,
                f.active_studies_load,
                f.historical_enrollment_rate,
                f.historical_data_quality_avg,
                f.query_resolution_rate,
                f.protocol_deviation_rate,
                f.staff_turnover_indicator,
                f.regulatory_issues_count,
                s.site_name,
                s.principal_investigator
            FROM ML_SITE_PERFORMANCE_FEATURES f
            JOIN CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.DIM_SITES s ON f.site_id = s.site_id
        """).to_pandas()
        
        if len(current_data) == 0:
            return "No sites found for risk assessment."
        
        # Retrain simple model (in production, would load saved model)
        training_data = session.sql("""
            SELECT 
                therapeutic_expertise_match,
                active_studies_load,
                historical_enrollment_rate,
                historical_data_quality_avg,
                query_resolution_rate,
                protocol_deviation_rate,
                staff_turnover_indicator,
                regulatory_issues_count,
                underperformance_indicator
            FROM ML_SITE_PERFORMANCE_FEATURES 
            WHERE underperformance_indicator IS NOT NULL
        """).to_pandas()
        
        feature_columns = [
            'therapeutic_expertise_match', 'active_studies_load', 
            'historical_enrollment_rate', 'historical_data_quality_avg',
            'query_resolution_rate', 'protocol_deviation_rate',
            'regulatory_issues_count'
        ]
        
        X_train = training_data[feature_columns].fillna(0)
        training_data['staff_turnover_numeric'] = training_data['staff_turnover_indicator'].astype(int)
        X_train['staff_turnover_numeric'] = training_data['staff_turnover_numeric']
        feature_columns.append('staff_turnover_numeric')
        
        y_train = training_data['underperformance_indicator'].astype(int)
        
        model = LogisticRegression(random_state=42)
        model.fit(X_train, y_train)
        
        # Generate predictions
        X_pred = current_data[feature_columns[:-1]].fillna(0)  # Exclude staff_turnover_numeric
        current_data['staff_turnover_numeric'] = current_data['staff_turnover_indicator'].astype(int)
        X_pred['staff_turnover_numeric'] = current_data['staff_turnover_numeric']
        
        risk_probabilities = model.predict_proba(X_pred)[:, 1]  # Probability of high risk
        
        # Store predictions
        prediction_count = 0
        for idx, row in current_data.iterrows():
            risk_prob = risk_probabilities[idx]
            
            # Determine risk category
            if risk_prob >= 0.7:
                category = "High Risk"
                business_impact = f"Site {row['site_name']} has {risk_prob:.1%} risk of underperformance - requires immediate attention"
            elif risk_prob >= 0.4:
                category = "Medium Risk"
                business_impact = f"Site {row['site_name']} has {risk_prob:.1%} risk of underperformance - monitor closely"
            else:
                category = "Low Risk"
                business_impact = f"Site {row['site_name']} has {risk_prob:.1%} risk of underperformance - performing well"
            
            feature_values = {col: float(row[col]) if col != 'staff_turnover_numeric' else int(row[col]) 
                            for col in feature_columns}
            
            session.sql(f"""
                INSERT INTO ML_PREDICTIONS VALUES (
                    {20000 + prediction_count},
                    '{model_id}',
                    CURRENT_TIMESTAMP(),
                    'site_performance',
                    {row['site_id']},
                    {risk_prob},
                    '{category}',
                    {0.8},  -- Fixed confidence for demo
                    PARSE_JSON('{json.dumps(feature_values)}'),
                    '{business_impact}'
                )
            """).collect()
            
            prediction_count += 1
        
        return f"Generated {prediction_count} site risk scores using model {model_id}"
        
    except Exception as e:
        return f"Error generating risk scores: {str(e)}"
$$;

-- ========================================================================
-- TRAINING AND PREDICTION EXECUTION
-- ========================================================================

-- Train the models
CALL TRAIN_ENROLLMENT_PREDICTION_MODEL();
CALL TRAIN_SITE_RISK_SCORING_MODEL();

-- Generate predictions (using the latest model IDs)
CALL GENERATE_ENROLLMENT_PREDICTIONS((SELECT model_id FROM ML_MODEL_REGISTRY WHERE model_type = 'enrollment_prediction' ORDER BY training_date DESC LIMIT 1));
CALL GENERATE_SITE_RISK_SCORES((SELECT model_id FROM ML_MODEL_REGISTRY WHERE model_type = 'site_risk_scoring' ORDER BY training_date DESC LIMIT 1));

-- ========================================================================
-- ML INSIGHTS VIEWS
-- ========================================================================

-- Switch back to main schema for views
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;

-- View: Current ML Predictions Summary
CREATE OR REPLACE VIEW ML_PREDICTIONS_SUMMARY AS
SELECT 
    p.entity_type,
    p.prediction_category,
    COUNT(*) as prediction_count,
    AVG(p.prediction_value) as avg_prediction_value,
    AVG(p.confidence_score) as avg_confidence,
    m.model_name,
    m.model_version
FROM CRO_AI_DEMO.ML_MODELS.ML_PREDICTIONS p
JOIN CRO_AI_DEMO.ML_MODELS.ML_MODEL_REGISTRY m ON p.model_id = m.model_id
WHERE p.prediction_date >= CURRENT_DATE - 7  -- Last 7 days
GROUP BY p.entity_type, p.prediction_category, m.model_name, m.model_version
ORDER BY p.entity_type, prediction_count DESC;

-- View: High-Risk Sites Alert
CREATE OR REPLACE VIEW HIGH_RISK_SITES_ALERT AS
SELECT 
    s.site_name,
    s.principal_investigator,
    s.country,
    p.prediction_value as risk_probability,
    p.business_impact,
    p.prediction_date
FROM CRO_AI_DEMO.ML_MODELS.ML_PREDICTIONS p
JOIN DIM_SITES s ON p.entity_id = s.site_id
WHERE p.entity_type = 'site_performance' 
    AND p.prediction_category = 'High Risk'
    AND p.prediction_date >= CURRENT_DATE - 7
ORDER BY p.prediction_value DESC;

-- View: Enrollment Performance Forecast
CREATE OR REPLACE VIEW ENROLLMENT_PERFORMANCE_FORECAST AS
SELECT 
    st.study_title,
    s.site_name,
    s.country,
    p.prediction_value as predicted_enrollment_rate,
    p.prediction_category as performance_category,
    p.business_impact,
    p.confidence_score
FROM CRO_AI_DEMO.ML_MODELS.ML_PREDICTIONS p
JOIN DIM_STUDIES st ON p.entity_id = st.study_id
JOIN DIM_SITES s ON EXISTS (
    SELECT 1 FROM CRO_AI_DEMO.ML_MODELS.ML_ENROLLMENT_FEATURES f 
    WHERE f.study_id = p.entity_id AND f.site_id = s.site_id
)
WHERE p.entity_type = 'study_site' 
    AND p.prediction_date >= CURRENT_DATE - 7
ORDER BY p.prediction_value DESC;

-- Grant permissions on new views
GRANT SELECT ON VIEW ML_PREDICTIONS_SUMMARY TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW HIGH_RISK_SITES_ALERT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON VIEW ENROLLMENT_PERFORMANCE_FORECAST TO ROLE SF_INTELLIGENCE_DEMO;

SELECT 'ML Foundation Phase Setup Complete!' as status,
       'Models: Enrollment Prediction + Site Risk Scoring' as models_created,
       'Predictions: Generated for current studies and sites' as predictions_status,
       'Views: 3 ML insight views created' as views_created;
