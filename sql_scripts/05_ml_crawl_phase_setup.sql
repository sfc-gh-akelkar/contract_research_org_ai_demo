-- ========================================================================
-- CRO DEMO - Step 5: ML Foundation Phase Setup
-- Implements core ML capabilities for Medpace demo
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

-- Insert sample enrollment features
INSERT INTO ML_ENROLLMENT_FEATURES VALUES
(1001, 101, 201, '2024-06-01', 'Phase II', 'Oncology', 120, 7.5, 'Tier 1', 8.5, 9.0, 15, 'Medium', 50000, 1.1, 6.2, 'Stable', 12.5, TRUE, 180, 6.8),
(1002, 101, 202, '2024-06-01', 'Phase II', 'Oncology', 120, 7.5, 'Tier 1', 12.0, 8.5, 12, 'Low', 75000, 0.9, 8.5, 'Accelerating', 8.0, TRUE, 165, 9.2),
(1003, 102, 203, '2024-06-01', 'Phase III', 'CNS', 600, 8.8, 'Tier 2', 6.2, 7.8, 8, 'High', 30000, 1.0, 4.1, 'Declining', 18.5, FALSE, NULL, 3.8),
(1004, 103, 204, '2024-06-01', 'Phase I/II', 'Cardiovascular', 80, 6.2, 'Tier 2', 5.8, 8.2, 10, 'Medium', 40000, 1.2, 7.8, 'Stable', 11.2, TRUE, 195, 7.5),
(1005, 104, 205, '2024-06-01', 'Phase II', 'Oncology', 90, 7.8, 'Tier 1', 7.5, 9.1, 18, 'Low', 60000, 1.0, 5.9, 'Stable', 14.8, FALSE, NULL, 5.2);

-- Insert sample site performance features
INSERT INTO ML_SITE_PERFORMANCE_FEATURES VALUES
(2001, 201, '2024-06-01', 'Tier 1', 9.2, 365, 4, 8.5, 9.2, 9.0, 95.5, 112.5, 98.2, 2.8, 2.5, FALSE, 0, 0, 'Low', FALSE),
(2002, 202, '2024-06-01', 'Tier 1', 8.8, 545, 3, 12.0, 8.8, 9.1, 88.9, 95.8, 96.5, 3.2, 3.1, FALSE, 1, 0, 'Low', FALSE),
(2003, 203, '2024-06-01', 'Tier 2', 7.5, 485, 2, 6.2, 8.5, 8.7, 78.2, 68.5, 85.4, 4.1, 4.8, TRUE, 2, 1, 'High', TRUE),
(2004, 204, '2024-06-01', 'Tier 2', 8.9, 425, 2, 5.8, 8.9, 8.8, 82.1, 89.2, 91.8, 3.5, 3.9, FALSE, 0, 0, 'Medium', FALSE),
(2005, 205, '2024-06-01', 'Tier 1', 9.0, 395, 3, 7.5, 9.0, 9.2, 91.2, 78.9, 89.5, 3.8, 4.2, FALSE, 1, 0, 'Medium', FALSE);

-- ========================================================================
-- ML PROCEDURES - CRAWL PHASE
-- ========================================================================

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
