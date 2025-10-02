# 🎯 CRO Patient Recruitment ML Demo - Notebook Specification

## **Status:** Ready to Build

This document specifies the complete structure of the Snowflake Notebook for the patient recruitment ML demo.

---

## 📊 **Notebook Overview**

**Title:** Accelerating Clinical Trials with AI-Powered Recruitment  
**Target Audience:** Medpace Data Science & Clinical Operations Teams  
**Duration:** 40 minutes  
**Total Cells:** ~28-30 cells  

---

## 📋 **Complete Cell-by-Cell Structure**

### **SECTION 1: BUSINESS PROBLEM** (2 cells, 5 min)

**Cell 1 [Markdown]:** Title + Business Challenge
- The Business Problem: 80% of trials miss enrollment timelines
- Cost impact: $600K-$8M per day of delay  
- Solution preview: AI-powered site selection

**Cell 2 [Markdown]:** Demo Roadmap
- 40-minute agenda table
- Key value propositions
- What attendees will learn

---

### **SECTION 2: DATA INGESTION & UNIFICATION** (3 cells, 5 min)

**Cell 3 [Markdown]:** Data Ingestion Capabilities
- Mention Zero-Copy Cloning, Schema-on-Read, COPY INTO, Snowpipe
- Explain data sources (EDC, CTMS, EHRs)
- Note: Demo data already loaded

**Cell 4 [SQL]:** Show Data Architecture
```sql
-- View tables in our database
SELECT TABLE_SCHEMA, TABLE_NAME, ROW_COUNT 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'CLINICAL_OPERATIONS_SCHEMA'
ORDER BY TABLE_NAME;
```

**Cell 5 [SQL]:** Preview ML Training Data
```sql
-- Preview SITE_PERFORMANCE_FEATURES table
SELECT SITE_ID, SITE_NAME, COUNTRY, SITE_TIER,
       HISTORICAL_ENROLLMENT_RATE, DATA_QUALITY_SCORE,
       PERFORMANCE_CATEGORY
FROM SITE_PERFORMANCE_FEATURES
LIMIT 10;
```

---

### **SECTION 3: DATA EXPLORATION & FEATURE ENGINEERING** (8 cells, 10 min)

**Cell 6 [Markdown]:** Unified Environment Introduction
- SQL + Python in one notebook
- Snowpark DataFrames explained
- Workflow: SQL for prep → Python for ML

**Cell 7 [SQL]:** Analyze Performance Distribution
```sql
SELECT PERFORMANCE_CATEGORY,
       COUNT(*) as site_count,
       AVG(HISTORICAL_ENROLLMENT_RATE) as avg_enrollment,
       AVG(DATA_QUALITY_SCORE) as avg_quality
FROM SITE_PERFORMANCE_FEATURES
GROUP BY PERFORMANCE_CATEGORY;
```

**Cell 8 [SQL]:** Explore Site Tiers vs Performance
```sql
SELECT SITE_TIER, PERFORMANCE_CATEGORY,
       COUNT(*) as count,
       AVG(HISTORICAL_ENROLLMENT_RATE) as avg_enrollment
FROM SITE_PERFORMANCE_FEATURES
GROUP BY SITE_TIER, PERFORMANCE_CATEGORY;
```

**Cell 9 [SQL]:** Identify Key Performance Indicators
```sql
-- Compare high performers vs others across key metrics
SELECT 
    'Top Tier Sites' as metric,
    COUNT(*) as count,
    AVG(HISTORICAL_ENROLLMENT_RATE) as avg_rate
FROM SITE_PERFORMANCE_FEATURES
WHERE SITE_TIER = 'Tier 1' AND DATA_QUALITY_SCORE > 90
UNION ALL
...
```

**Cell 10 [Markdown]:** Transition to Python
- Key insights from SQL exploration
- Why Snowpark for feature engineering

**Cell 11 [Python]:** Import Libraries & Connect
```python
import snowflake.snowpark as snowpark
from snowflake.snowpark import functions as F
import pandas as pd
import numpy as np

session = snowpark.Session.builder.getOrCreate()
print(f"✅ Connected to {session.get_current_database()}")
```

**Cell 12 [Python]:** Load Data with Snowpark
```python
df = session.table("SITE_PERFORMANCE_FEATURES")
print(f"📊 Total Records: {df.count()}")
df.limit(5).to_pandas()
```

**Cell 13 [Python]:** Feature Engineering
```python
df_engineered = df.with_column(
    "ENROLLMENT_EFFICIENCY",
    F.col("HISTORICAL_ENROLLMENT_RATE") / (F.col("AVG_SCREEN_FAILURE_RATE") + 1)
).with_column(
    "QUALITY_COMPOSITE_SCORE",
    (F.col("DATA_QUALITY_SCORE") + F.col("REGULATORY_COMPLIANCE_SCORE")) / 2
)
# Show new features
```

**Cell 14 [Python]:** Correlation Analysis & Visualization
```python
df_pandas = df_engineered.to_pandas()
correlations = df_pandas[numeric_cols].corrwith(
    df_pandas['PREDICTED_ENROLLMENT_RATE']
)
# Plot feature correlations
```

---

### **SECTION 4: MODEL TRAINING & VALIDATION** (9 cells, 10 min)

**Cell 15 [Markdown]:** Model Training Introduction
- Why train in Snowflake
- Two models: Classification + Regression
- Using scikit-learn Random Forest

**Cell 16 [Python]:** Import ML Libraries
```python
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, r2_score, ...
```

**Cell 17 [Python]:** Prepare Features & Split Data
```python
feature_columns = ['HISTORICAL_ENROLLMENT_RATE', 'DATA_QUALITY_SCORE', ...]
X = df_pandas[feature_columns]
y_category = df_pandas['PERFORMANCE_CATEGORY']
y_regression = df_pandas['PREDICTED_ENROLLMENT_RATE']

X_train, X_test, y_cat_train, y_cat_test, y_reg_train, y_reg_test = train_test_split(...)
```

**Cell 18 [Markdown]:** Model 1 - Classification
- Predict High/Medium/Low performance category

**Cell 19 [Python]:** Train Classification Model
```python
clf_model = RandomForestClassifier(n_estimators=100, max_depth=10, ...)
clf_model.fit(X_train, y_cat_train)
print("✅ Classification model trained!")
```

**Cell 20 [Python]:** Evaluate Classification Model
```python
y_cat_pred = clf_model.predict(X_test)
accuracy = accuracy_score(y_cat_test, y_cat_pred)
print(f"🎯 Accuracy: {accuracy:.2%}")
print(classification_report(y_cat_test, y_cat_pred))
# Confusion matrix
```

**Cell 21 [Markdown]:** Model 2 - Regression
- Predict exact enrollment rate (subjects/month)

**Cell 22 [Python]:** Train Regression Model
```python
reg_model = RandomForestRegressor(n_estimators=100, max_depth=12, ...)
reg_model.fit(X_train, y_reg_train)
print("✅ Regression model trained!")
```

**Cell 23 [Python]:** Evaluate Regression Model
```python
y_reg_pred = reg_model.predict(X_test)
r2 = r2_score(y_reg_test, y_reg_pred)
rmse = np.sqrt(mean_squared_error(y_reg_test, y_reg_pred))
print(f"🎯 R² Score: {r2:.4f}")
print(f"📉 RMSE: {rmse:.3f} subjects/month")
```

**Cell 24 [Python]:** Feature Importance Analysis
```python
feature_importance = pd.DataFrame({
    'feature': feature_columns,
    'importance': clf_model.feature_importances_
}).sort_values('importance', ascending=False)

# Visualize top 10 features
plt.barh(...)
```

**Cell 25 [Markdown]:** Model Performance Summary
- Classification: ~85-90% accuracy expected
- Regression: R² ~0.80-0.90 expected
- Top predictive features identified
- Business impact explained

---

### **SECTION 5: DEPLOYMENT & INFERENCE** (4 cells, 5 min)

**Cell 26 [Markdown]:** Deployment Options
- Batch predictions (most common for CROs)
- UDF deployment (real-time, mentioned but not implemented)
- From training to production in minutes

**Cell 27 [Python]:** Generate Batch Predictions
```python
X_all = df_pandas[feature_columns]
predictions_category = clf_model.predict(X_all)
predictions_enrollment = reg_model.predict(X_all)
predictions_proba = clf_model.predict_proba(X_all)
confidence_scores = np.max(predictions_proba, axis=1)

predictions_df = pd.DataFrame({
    'SITE_ID': df_pandas['SITE_ID'],
    'SITE_NAME': df_pandas['SITE_NAME'],
    'PREDICTED_CATEGORY': predictions_category,
    'PREDICTED_ENROLLMENT_RATE': predictions_enrollment,
    'CONFIDENCE_SCORE': confidence_scores
})
```

**Cell 28 [Python]:** Write Predictions to Snowflake
```python
predictions_snow = session.create_dataframe(predictions_df)
predictions_snow.write.mode('overwrite').save_as_table('SITE_PREDICTIONS')
print("✅ Predictions saved to SITE_PREDICTIONS table")
```

**Cell 29 [SQL]:** Query Predictions via SQL
```sql
-- Now ANY user can query predictions using SQL
SELECT SITE_ID, SITE_NAME, 
       PREDICTED_CATEGORY,
       ROUND(PREDICTED_ENROLLMENT_RATE, 2) as ENROLLMENT_RATE,
       ROUND(CONFIDENCE_SCORE, 3) as CONFIDENCE
FROM SITE_PREDICTIONS
WHERE PREDICTED_CATEGORY = 'High'
  AND CONFIDENCE_SCORE > 0.85
ORDER BY PREDICTED_ENROLLMENT_RATE DESC
LIMIT 10;
```

**Cell 30 [Markdown]:** UDF Deployment (Conceptual)
- Explain how to deploy as UDF for real-time scoring
- Show example CREATE FUNCTION syntax
- When to use batch vs UDF

---

### **SECTION 6: BUSINESS APPLICATION & ROI** (5 cells, 5 min)

**Cell 31 [Markdown]:** Business Impact Introduction
- Key questions we can answer
- From predictions to actionable insights

**Cell 32 [SQL]:** Top Sites for Next Trial
```sql
-- Actionable list of high-confidence sites
SELECT sp.SITE_NAME, sp.PREDICTED_CATEGORY,
       sp.PREDICTED_ENROLLMENT_RATE,
       sp.CONFIDENCE_SCORE,
       spf.COUNTRY, spf.THERAPEUTIC_AREA_EXPERTISE
FROM SITE_PREDICTIONS sp
JOIN SITE_PERFORMANCE_FEATURES spf ON sp.SITE_ID = spf.SITE_ID
WHERE sp.PREDICTED_CATEGORY = 'High'
  AND sp.CONFIDENCE_SCORE > 0.80
ORDER BY sp.PREDICTED_ENROLLMENT_RATE DESC
LIMIT 15;
```

**Cell 33 [SQL]:** Site Portfolio Analysis by Region
```sql
SELECT spf.COUNTRY, sp.PREDICTED_CATEGORY,
       COUNT(*) as site_count,
       AVG(sp.PREDICTED_ENROLLMENT_RATE) as avg_enrollment
FROM SITE_PREDICTIONS sp
JOIN SITE_PERFORMANCE_FEATURES spf ON sp.SITE_ID = spf.SITE_ID
GROUP BY spf.COUNTRY, sp.PREDICTED_CATEGORY;
```

**Cell 34 [SQL]:** High-Risk Sites Requiring Attention
```sql
-- Identify underperforming sites
SELECT sp.SITE_NAME, sp.PREDICTED_CATEGORY,
       sp.PREDICTED_ENROLLMENT_RATE,
       spf.PROTOCOL_DEVIATION_RATE,
       spf.CRITICAL_FINDINGS_COUNT
FROM SITE_PREDICTIONS sp
JOIN SITE_PERFORMANCE_FEATURES spf ON sp.SITE_ID = spf.SITE_ID
WHERE sp.PREDICTED_CATEGORY = 'Low'
   OR (sp.PREDICTED_CATEGORY = 'Medium' AND sp.CONFIDENCE_SCORE < 0.60)
LIMIT 15;
```

**Cell 35 [Python]:** ROI Calculation
```python
# Scenario: Phase III Oncology Trial
# 400 patients, 40 sites, 18 months target

traditional_avg_enrollment = 0.56  # industry average
traditional_timeline_months = 400 / (40 * traditional_avg_enrollment)

top_40_sites = predictions_df.nlargest(40, 'PREDICTED_ENROLLMENT_RATE')
optimized_avg_enrollment = top_40_sites['PREDICTED_ENROLLMENT_RATE'].mean()
optimized_timeline_months = 400 / (40 * optimized_avg_enrollment)

timeline_reduction_months = traditional_timeline_months - optimized_timeline_months
timeline_reduction_days = timeline_reduction_months * 30

# Cost savings
delay_savings = timeline_reduction_days * 50000  # $50K per day
site_cost_savings = timeline_reduction_months * 40 * 25000
total_savings = delay_savings + site_cost_savings

print(f"⏱️ Time Saved: {timeline_reduction_months:.1f} months")
print(f"💵 Total Savings: ${total_savings:,.0f}")
print(f"🎯 ROI for single trial: ${total_savings:,.0f}")
```

**Cell 36 [Markdown]:** Summary & Next Steps
- What we accomplished
- Measurable business impact ($5-15M per trial)
- Scaling the solution (immediate, short-term, long-term)
- Questions and discussion

---

## 🎯 **Total Summary**

**Total Cells:** 36 cells
- **Markdown:** 12 cells (explanations, context)
- **SQL:** 9 cells (data exploration, queries)
- **Python:** 15 cells (ML training, predictions, ROI)

**Demo Flow:**
1. Business problem → Data ingestion (5 min)
2. SQL exploration → Python feature engineering (10 min)
3. Train 2 models (Classification + Regression) (10 min)
4. Deploy predictions to SQL tables (5 min)
5. Business insights + $5-15M ROI (10 min)

**Key Features:**
✅ Shows SQL-Python interoperability  
✅ Uses scikit-learn (familiar to data scientists)  
✅ Both classification AND regression models  
✅ Batch predictions with optional UDF mention  
✅ Quantified ROI  
✅ No Streamlit (ends with SQL insights)  
✅ 28-36 cells (clean, walkable)  

---

## 🚀 **Ready to Build**

All content specified above. Ready to create the complete `.ipynb` file.

**Dependencies:**
- `sql_scripts/05_ml_data_setup.sql` ✅ Created
- Notebook content ✅ Specified
- Sample data (150 sites) ✅ In SQL script

**Next Step:** Build the complete notebook file?

