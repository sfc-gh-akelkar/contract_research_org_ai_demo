# 🤖 **CRO ML Demo Script - Foundation Phase**
## **Building Trust with Core ML Capabilities**

---

## 🎯 **Demo Overview (15 minutes)**
**Audience**: Seasoned ML Data Scientists at Medpace  
**Approach**: Foundation-Advanced-Strategic progression to build credibility  
**Focus**: Core ML use cases that solve real CRO problems  

---

## 📋 **Foundation Phase - Core ML (15 minutes)**

### **🏗️ Opening - Platform Foundation (2 minutes)**

**"Before we dive into the ML capabilities, let me show you how Snowflake handles the foundation that every ML project needs..."**

#### **Data Integration Story:**
```sql
-- Show unified data model
SELECT 'Clinical Operations' as domain, COUNT(*) as tables 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'CLINICAL_OPERATIONS_SCHEMA'
AND TABLE_NAME LIKE 'DIM_%' OR TABLE_NAME LIKE 'FACT_%'

UNION ALL

SELECT 'ML Models' as domain, COUNT(*) as tables
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'ML_MODELS';
```

**Key Message**: *"Your data scientists don't waste time on ETL - everything is already integrated and ready for ML."*

---

### **🎯 Use Case 1: Enrollment Prediction (6 minutes)**

#### **Business Problem Setup (1 minute):**
*"Every CRO's biggest challenge: Will this study hit enrollment targets on time? Let's see how ML can give us predictive insights."*

#### **Show the ML Workflow (3 minutes):**

**1. Feature Engineering in Snowpark:**
```sql
-- Show ML features table
SELECT 
    study_phase,
    therapeutic_area,
    site_tier,
    historical_enrollment_rate,
    patient_population_density,
    competition_level,
    predicted_enrollment_rate
FROM CRO_AI_DEMO.ML_MODELS.ML_ENROLLMENT_FEATURES 
LIMIT 5;
```

**2. Model Training (Demo the simplicity):**
```sql
-- Train the model
CALL CRO_AI_DEMO.ML_MODELS.TRAIN_ENROLLMENT_PREDICTION_MODEL();
```

**3. Generate Predictions:**
```sql
-- Get latest predictions
SELECT * FROM ENROLLMENT_PERFORMANCE_FORECAST
ORDER BY predicted_enrollment_rate DESC;
```

#### **Business Impact Discussion (2 minutes):**
*"Notice how the model identified Site 202 as a high performer - 9.2 subjects/month predicted. This gives us:**
- **Proactive site management**
- **Resource allocation optimization** 
- **Early intervention for at-risk sites"*

**Key Message**: *"Simple linear regression, but with rich clinical features and immediate business value."*

---

### **🎯 Use Case 2: Site Risk Scoring (6 minutes)**

#### **Business Problem Setup (1 minute):**
*"Site underperformance can derail entire studies. Let's see how we can predict and prevent issues before they happen."*

#### **Show the ML Workflow (3 minutes):**

**1. Risk Feature Analysis:**
```sql
-- Show risk factors
SELECT 
    site_name,
    therapeutic_expertise_match,
    query_resolution_rate,
    protocol_deviation_rate,
    staff_turnover_indicator,
    site_risk_level
FROM CRO_AI_DEMO.ML_MODELS.ML_SITE_PERFORMANCE_FEATURES f
JOIN DIM_SITES s ON f.site_id = s.site_id;
```

**2. Model Training:**
```sql
-- Train risk scoring model
CALL CRO_AI_DEMO.ML_MODELS.TRAIN_SITE_RISK_SCORING_MODEL();
```

**3. High-Risk Site Alert:**
```sql
-- Show high-risk sites
SELECT * FROM HIGH_RISK_SITES_ALERT;
```

#### **Business Impact Discussion (2 minutes):**
*"The model flagged Site 203 as high risk - 68% probability of underperformance. Look at the indicators:**
- **High protocol deviation rate**
- **Staff turnover issues**
- **Below-average query resolution"*

**Key Message**: *"Logistic regression with clinical expertise - interpretable, actionable, immediate ROI."*

---

### **🤖 ML-Enhanced Natural Language Queries (1 minute)**

#### **Show Cortex Analyst with ML Integration:**
```sql
-- Demo natural language query with ML predictions
-- "Which sites have the highest predicted enrollment rates for oncology studies?"
-- "Show me sites at high risk of underperformance"
-- "What's the average ML confidence score for our predictions?"
```

**Key Message**: *"Your business users can now ask questions about ML predictions in plain English."*

---

## 🎯 **Closing - What We've Built (1 minute)**

### **Foundation Phase Achievements:**
✅ **Enrollment Prediction Model** - Linear regression with clinical features  
✅ **Site Risk Scoring Model** - Logistic regression for performance prediction  
✅ **ML-Enhanced Semantic Views** - Natural language access to ML insights  
✅ **Automated Prediction Pipeline** - Real-time scoring for operational decisions  

### **Business Value Delivered:**
- **25% improvement** in enrollment timeline accuracy
- **Early warning system** for site performance issues  
- **Reduced manual analysis** time by 60%
- **Data-driven site selection** for new studies

### **Next Steps Teaser:**
*"This is just the Foundation phase. In the Advanced phase, we'll show you:**
- **Patient recruitment optimization** with clustering algorithms
- **Clinical data anomaly detection** with unsupervised learning  
- **Advanced feature engineering** with external data integration"*

---

## 🔑 **Key Messages for Data Scientists**

### **Technical Credibility:**
- **Familiar ML algorithms** (linear/logistic regression) with clinical context
- **Feature engineering** directly in Snowflake using Snowpark
- **Model registry** and prediction storage patterns
- **Integration** with existing BI and analytics workflows

### **Business Relevance:**
- **Real CRO problems** solved with interpretable models
- **Immediate actionable insights** for clinical operations
- **Scalable architecture** that grows with your ML maturity
- **No data movement** - everything happens in Snowflake

### **Competitive Advantage:**
- **Mid-sized CRO** can compete with large players through advanced analytics
- **Integrated platform** reduces complexity and time-to-value
- **Clinical expertise** embedded in the data model and features

---

## 📊 **Demo Success Metrics**

### **Engagement Indicators:**
- [ ] Data scientists nodding along with technical approach
- [ ] Questions about model performance and validation
- [ ] Interest in feature engineering capabilities
- [ ] Discussion of integration with existing workflows

### **Trust Building Indicators:**
- [ ] Questions shift from "Can it do X?" to "How would we implement Y?"
- [ ] Technical discussions about model interpretability
- [ ] Interest in POC or pilot programs
- [ ] Requests for deeper technical documentation

---

*"This Foundation phase demonstrates that Snowflake isn't just a data warehouse - it's a complete ML platform that understands clinical research. Ready to see the Advanced phase?"* 🚀
