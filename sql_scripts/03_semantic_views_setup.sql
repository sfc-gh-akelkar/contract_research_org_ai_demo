-- ========================================================================
-- CRO DEMO - Step 3: Semantic Views Setup
-- Creates semantic views for natural language queries
-- Prerequisites: Run steps 1-2 first
-- ========================================================================

-- Switch to the CRO demo role and database
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- SEMANTIC VIEWS FOR CRO OPERATIONS
-- ========================================================================

-- Clinical Operations Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.CLINICAL_OPERATIONS_VIEW
AS
SELECT 
    -- Study Information
    s.study_id,
    s.protocol_number,
    s.study_title,
    s.study_phase,
    s.study_status,
    s.planned_enrollment,
    s.actual_enrollment,
    s.study_start_date,
    s.planned_completion_date,
    s.contract_value,
    s.cost_per_patient,
    s.regulatory_pathway,
    
    -- Sponsor Information  
    sp.sponsor_name,
    sp.sponsor_type,
    sp.company_size,
    sp.relationship_tier,
    
    -- Therapeutic Area
    ta.therapeutic_area_name,
    ta.expertise_level,
    
    -- Site Information
    st.site_name,
    st.principal_investigator,
    st.country as site_country,
    st.region as site_region,
    st.site_tier,
    st.data_quality_score,
    st.regulatory_compliance_score,
    
    -- Enrollment Metrics (aggregated)
    AVG(e.enrollment_rate) as avg_enrollment_rate,
    AVG(e.screen_failure_rate) as avg_screen_failure_rate,
    SUM(e.subjects_enrolled) as total_subjects_enrolled,
    
    -- Safety Metrics (aggregated)
    COUNT(se.safety_event_id) as safety_events_count,
    COUNT(CASE WHEN se.event_type = 'Serious Adverse Event' THEN 1 END) as serious_aes_count,
    
    -- Monitoring Metrics (aggregated)
    COUNT(sm.monitoring_visit_id) as monitoring_visits_count,
    AVG(sm.data_quality_score) as avg_visit_quality_score

FROM DIM_STUDIES s
LEFT JOIN DIM_SPONSORS sp ON s.sponsor_id = sp.sponsor_id
LEFT JOIN DIM_THERAPEUTIC_AREAS ta ON s.therapeutic_area_id = ta.therapeutic_area_id
LEFT JOIN FACT_ENROLLMENT e ON s.study_id = e.study_id
LEFT JOIN DIM_SITES st ON e.site_id = st.site_id
LEFT JOIN FACT_SAFETY_EVENTS se ON s.study_id = se.study_id
LEFT JOIN FACT_SITE_MONITORING sm ON s.study_id = sm.study_id

GROUP BY 
    s.study_id, s.protocol_number, s.study_title, s.study_phase, s.study_status,
    s.planned_enrollment, s.actual_enrollment, s.study_start_date, s.planned_completion_date,
    s.contract_value, s.cost_per_patient, s.regulatory_pathway,
    sp.sponsor_name, sp.sponsor_type, sp.company_size, sp.relationship_tier,
    ta.therapeutic_area_name, ta.expertise_level,
    st.site_name, st.principal_investigator, st.country, st.region, st.site_tier,
    st.data_quality_score, st.regulatory_compliance_score

COMMENT = '
Clinical Operations semantic view for CRO operations teams.
Provides insights into study performance, enrollment, site management, and safety monitoring.

Key Metrics:
- Study enrollment performance and timeline adherence
- Site performance and data quality scores
- Safety event monitoring and adverse event tracking
- Sponsor relationship and contract management

Synonyms for natural language queries:
- "study protocol" = protocol_number
- "trial" = study_title  
- "enrollment" = planned_enrollment, actual_enrollment
- "biotech" or "pharma" = sponsor_type
- "site performance" = data_quality_score
- "adverse events" = safety_events_count
- "SAE" = serious_aes_count
';

-- Business Development Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.BUSINESS_DEVELOPMENT_VIEW
AS
SELECT 
    -- Sponsor Information
    sp.sponsor_id,
    sp.sponsor_name,
    sp.sponsor_type,
    sp.company_size,
    sp.headquarters_country,
    sp.relationship_tier,
    sp.total_contract_value,
    sp.active_studies_count,
    
    -- Study Information
    s.study_id,
    s.protocol_number,
    s.study_phase,
    s.study_status,
    s.contract_value,
    
    -- Therapeutic Area
    ta.therapeutic_area_name,
    ta.market_size,
    ta.expertise_level,
    
    -- Business Development Metrics
    bd.opportunity_id,
    bd.opportunity_name,
    bd.opportunity_type,
    bd.estimated_value,
    bd.competition_level,
    bd.proposal_status,
    bd.win_probability,
    bd.rfp_date,
    bd.award_date,
    
    -- Financial Metrics (aggregated)
    SUM(sf.actual_amount) as total_revenue,
    COUNT(CASE WHEN sf.payment_status = 'Paid' THEN 1 END) as paid_milestones,
    SUM(CASE WHEN sf.payment_status IN ('Pending', 'Invoiced') THEN sf.actual_amount ELSE 0 END) as outstanding_amount

FROM DIM_SPONSORS sp
LEFT JOIN DIM_STUDIES s ON sp.sponsor_id = s.sponsor_id
LEFT JOIN DIM_THERAPEUTIC_AREAS ta ON s.therapeutic_area_id = ta.therapeutic_area_id
LEFT JOIN FACT_BUSINESS_DEVELOPMENT bd ON sp.sponsor_id = bd.sponsor_id
LEFT JOIN FACT_STUDY_FINANCIALS sf ON s.study_id = sf.study_id

GROUP BY 
    sp.sponsor_id, sp.sponsor_name, sp.sponsor_type, sp.company_size, sp.headquarters_country,
    sp.relationship_tier, sp.total_contract_value, sp.active_studies_count,
    s.study_id, s.protocol_number, s.study_phase, s.study_status, s.contract_value,
    ta.therapeutic_area_name, ta.market_size, ta.expertise_level,
    bd.opportunity_id, bd.opportunity_name, bd.opportunity_type, bd.estimated_value,
    bd.competition_level, bd.proposal_status, bd.win_probability, bd.rfp_date, bd.award_date

COMMENT = '
Business Development semantic view for BD teams and account managers.
Provides insights into sponsor relationships, proposal performance, and revenue analytics.

Key Metrics:
- Sponsor relationship management and contract values
- Proposal win rates and competitive positioning
- Revenue recognition and financial performance
- Therapeutic area expansion opportunities

Synonyms for natural language queries:
- "biotech companies" = sponsor_type (Biotech)
- "pharma companies" = sponsor_type (Pharma) 
- "proposals" or "RFP" = opportunity_id
- "wins" = proposal_status (Won)
- "pipeline" = estimated_value for pending opportunities
- "revenue" = total_revenue
';

-- Regulatory & Data Management Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.REGULATORY_DATA_VIEW
AS
SELECT 
    -- Study Information
    s.study_id,
    s.protocol_number,
    s.study_title,
    s.study_phase,
    s.regulatory_pathway,
    s.study_status,
    
    -- Sponsor Information
    sp.sponsor_name,
    sp.sponsor_type,
    
    -- Therapeutic Area
    ta.therapeutic_area_name,
    ta.regulatory_complexity,
    
    -- Regulatory Submissions
    rs.submission_id,
    rs.submission_type,
    rs.regulatory_authority,
    rs.submission_status,
    rs.submission_date,
    rs.planned_submission_date,
    rs.approval_date,
    rs.days_to_approval,
    rs.planned_vs_actual_days,
    
    -- Regulatory Milestones
    rm.milestone_name,
    rm.milestone_type,
    rm.complexity_level,
    rm.typical_timeline_days,
    
    -- Data Quality Metrics (aggregated)
    COUNT(sm.monitoring_visit_id) as total_monitoring_visits,
    SUM(sm.queries_opened) as total_queries_opened,
    SUM(sm.queries_resolved) as total_queries_resolved,
    SUM(sm.protocol_deviations_found) as total_protocol_deviations,
    SUM(sm.critical_findings) as total_critical_findings,
    AVG(sm.data_quality_score) as avg_data_quality_score

FROM DIM_STUDIES s
LEFT JOIN DIM_SPONSORS sp ON s.sponsor_id = sp.sponsor_id
LEFT JOIN DIM_THERAPEUTIC_AREAS ta ON s.therapeutic_area_id = ta.therapeutic_area_id
LEFT JOIN FACT_REGULATORY_SUBMISSIONS rs ON s.study_id = rs.study_id
LEFT JOIN DIM_REGULATORY_MILESTONES rm ON rs.milestone_id = rm.milestone_id
LEFT JOIN FACT_SITE_MONITORING sm ON s.study_id = sm.study_id

GROUP BY 
    s.study_id, s.protocol_number, s.study_title, s.study_phase, s.regulatory_pathway, s.study_status,
    sp.sponsor_name, sp.sponsor_type,
    ta.therapeutic_area_name, ta.regulatory_complexity,
    rs.submission_id, rs.submission_type, rs.regulatory_authority, rs.submission_status,
    rs.submission_date, rs.planned_submission_date, rs.approval_date, rs.days_to_approval, rs.planned_vs_actual_days,
    rm.milestone_name, rm.milestone_type, rm.complexity_level, rm.typical_timeline_days

COMMENT = '
Regulatory & Data Management semantic view for regulatory affairs and data management teams.
Provides insights into submission timelines, data quality, and compliance monitoring.

Key Metrics:
- Regulatory submission performance and approval timelines
- Data quality metrics and query resolution rates
- Protocol compliance and deviation tracking
- Milestone achievement and regulatory pathway optimization

Synonyms for natural language queries:
- "IND" = submission_type (IND)
- "NDA" = submission_type (NDA)
- "FDA" = regulatory_authority (FDA)
- "EMA" = regulatory_authority (EMA)
- "queries" = total_queries_opened
- "deviations" = total_protocol_deviations
- "data quality" = avg_data_quality_score
';

-- Financial & Operational Performance Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.FINANCIAL_OPERATIONAL_VIEW
AS
SELECT 
    -- Study Information
    s.study_id,
    s.protocol_number,
    s.study_phase,
    s.study_status,
    s.contract_value,
    s.cost_per_patient,
    s.planned_enrollment,
    s.actual_enrollment,
    
    -- Sponsor Information
    sp.sponsor_name,
    sp.sponsor_type,
    sp.company_size,
    
    -- Therapeutic Area
    ta.therapeutic_area_name,
    
    -- Financial Metrics
    sf.transaction_type,
    sf.payment_status,
    sf.quarter,
    sf.fiscal_year,
    sf.budgeted_amount,
    sf.actual_amount,
    sf.transaction_date,
    
    -- Calculated Financial Metrics (aggregated)
    SUM(CASE WHEN sf.payment_status = 'Paid' THEN sf.actual_amount ELSE 0 END) as revenue_recognized,
    SUM(CASE WHEN sf.payment_status IN ('Pending', 'Invoiced') THEN sf.actual_amount ELSE 0 END) as outstanding_invoices,
    SUM(sf.budgeted_amount) - SUM(sf.actual_amount) as budget_variance,
    SUM(CASE WHEN sf.transaction_type = 'Milestone Payment' THEN sf.actual_amount ELSE 0 END) as milestone_payments,
    
    -- Operational Metrics
    ROUND((s.actual_enrollment::FLOAT / NULLIF(s.planned_enrollment, 0)) * 100, 1) as enrollment_efficiency_pct

FROM DIM_STUDIES s
LEFT JOIN DIM_SPONSORS sp ON s.sponsor_id = sp.sponsor_id
LEFT JOIN DIM_THERAPEUTIC_AREAS ta ON s.therapeutic_area_id = ta.therapeutic_area_id
LEFT JOIN FACT_STUDY_FINANCIALS sf ON s.study_id = sf.study_id

GROUP BY 
    s.study_id, s.protocol_number, s.study_phase, s.study_status, s.contract_value,
    s.cost_per_patient, s.planned_enrollment, s.actual_enrollment,
    sp.sponsor_name, sp.sponsor_type, sp.company_size,
    ta.therapeutic_area_name,
    sf.transaction_type, sf.payment_status, sf.quarter, sf.fiscal_year,
    sf.budgeted_amount, sf.actual_amount, sf.transaction_date

COMMENT = '
Financial & Operational Performance semantic view for finance teams and executives.
Provides insights into contract performance, revenue recognition, and operational efficiency.

Key Metrics:
- Revenue recognition and contract value realization
- Budget variance and cost management
- Enrollment efficiency and timeline performance
- Milestone achievement and payment tracking

Synonyms for natural language queries:
- "revenue" = revenue_recognized
- "contracts" = contract_value
- "invoices" = outstanding_invoices
- "budget" = budget_variance
- "enrollment" = enrollment_efficiency_pct
- "milestones" = milestone_payments
- "quarterly" = quarter
- "annual" = fiscal_year
';

-- ========================================================================
-- GRANT PERMISSIONS
-- ========================================================================

-- Grant usage permissions on semantic views
GRANT USAGE ON SEMANTIC VIEW CLINICAL_OPERATIONS_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW BUSINESS_DEVELOPMENT_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW REGULATORY_DATA_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW FINANCIAL_OPERATIONAL_VIEW TO ROLE SF_INTELLIGENCE_DEMO;

-- ========================================================================
-- VERIFICATION
-- ========================================================================

-- Verify semantic views are created
SELECT 'CRO Semantic Views Setup Complete!' as status,
       'Views Created: 4 CRO-focused semantic views' as views_created,
       'All views use proper SQL syntax with metadata in comments' as note;