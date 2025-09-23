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
    tables (
        STUDIES AS DIM_STUDIES primary key (STUDY_ID),
        SPONSORS AS DIM_SPONSORS primary key (SPONSOR_ID),
        THERAPEUTIC_AREAS AS DIM_THERAPEUTIC_AREAS primary key (THERAPEUTIC_AREA_ID),
        SITES AS DIM_SITES primary key (SITE_ID),
        SUBJECTS AS DIM_SUBJECTS primary key (SUBJECT_ID),
        ENROLLMENT AS FACT_ENROLLMENT primary key (ENROLLMENT_FACT_ID),
        SAFETY_EVENTS AS FACT_SAFETY_EVENTS primary key (SAFETY_EVENT_ID),
        SITE_MONITORING AS FACT_SITE_MONITORING primary key (MONITORING_VISIT_ID)
    )
    filters (
        studies.study_status in ('Recruiting', 'Active', 'Completed')
    )
    measures (
        planned_enrollment as sum(studies.planned_enrollment),
        actual_enrollment as sum(studies.actual_enrollment),
        enrollment_rate as avg(enrollment.enrollment_rate),
        screen_failure_rate as avg(enrollment.screen_failure_rate),
        safety_events_count as count(safety_events.safety_event_id),
        serious_aes as count_if(safety_events.event_type = 'Serious Adverse Event'),
        data_quality_score as avg(sites.data_quality_score),
        monitoring_visits as count(site_monitoring.monitoring_visit_id)
    )
    dimensions (
        studies.protocol_number,
        studies.study_title,
        studies.study_phase,
        studies.study_status,
        sponsors.sponsor_name,
        sponsors.sponsor_type,
        therapeutic_areas.therapeutic_area_name,
        sites.site_name,
        sites.principal_investigator,
        sites.country as site_country,
        sites.site_tier
    )
    synonyms (
        'study protocol' = studies.protocol_number,
        'trial' = studies.study_title,
        'phase' = studies.study_phase,
        'enrollment' = planned_enrollment,
        'biotech' = sponsors.sponsor_type,
        'pharma' = sponsors.sponsor_type,
        'sponsor company' = sponsors.sponsor_name,
        'therapeutic area' = therapeutic_areas.therapeutic_area_name,
        'oncology' = therapeutic_areas.therapeutic_area_name,
        'cardiovascular' = therapeutic_areas.therapeutic_area_name,
        'site performance' = data_quality_score,
        'investigator' = sites.principal_investigator,
        'adverse events' = safety_events_count,
        'SAE' = serious_aes,
        'serious adverse events' = serious_aes
    );

-- Business Development Semantic View  
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.BUSINESS_DEVELOPMENT_VIEW
    tables (
        SPONSORS AS DIM_SPONSORS primary key (SPONSOR_ID),
        STUDIES AS DIM_STUDIES primary key (STUDY_ID),
        THERAPEUTIC_AREAS AS DIM_THERAPEUTIC_AREAS primary key (THERAPEUTIC_AREA_ID),
        BUSINESS_DEV AS FACT_BUSINESS_DEVELOPMENT primary key (OPPORTUNITY_ID),
        FINANCIALS AS FACT_STUDY_FINANCIALS primary key (FINANCIAL_RECORD_ID)
    )
    measures (
        total_contract_value as sum(studies.contract_value),
        active_studies as count_if(studies.study_status in ('Recruiting', 'Active')),
        opportunities_won as count_if(business_dev.proposal_status = 'Won'),
        opportunities_lost as count_if(business_dev.proposal_status = 'Lost'),
        win_rate as (opportunities_won / (opportunities_won + opportunities_lost)) * 100,
        pipeline_value as sum_if(business_dev.estimated_value, business_dev.proposal_status = 'Pending'),
        revenue_recognized as sum_if(financials.actual_amount, financials.payment_status = 'Paid')
    )
    dimensions (
        sponsors.sponsor_name,
        sponsors.sponsor_type,
        sponsors.company_size,
        sponsors.relationship_tier,
        sponsors.headquarters_country,
        therapeutic_areas.therapeutic_area_name,
        business_dev.opportunity_type,
        business_dev.study_phase,
        business_dev.competition_level,
        business_dev.proposal_status
    )
    synonyms (
        'biotech companies' = sponsors.sponsor_type,
        'pharmaceutical companies' = sponsors.sponsor_type,
        'small companies' = sponsors.company_size,
        'proposals' = business_dev.opportunity_id,
        'RFP' = business_dev.opportunity_id,
        'wins' = opportunities_won,
        'losses' = opportunities_lost,
        'pipeline' = pipeline_value,
        'revenue' = revenue_recognized,
        'contract value' = total_contract_value
    );

-- Regulatory & Data Management Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.REGULATORY_DATA_VIEW
    tables (
        STUDIES AS DIM_STUDIES primary key (STUDY_ID),
        SPONSORS AS DIM_SPONSORS primary key (SPONSOR_ID),
        REGULATORY AS FACT_REGULATORY_SUBMISSIONS primary key (SUBMISSION_ID),
        MILESTONES AS DIM_REGULATORY_MILESTONES primary key (MILESTONE_ID),
        MONITORING AS FACT_SITE_MONITORING primary key (MONITORING_VISIT_ID)
    )
    measures (
        submissions_count as count(regulatory.submission_id),
        approvals_count as count_if(regulatory.submission_status = 'Approved'),
        avg_approval_days as avg(regulatory.days_to_approval),
        queries_opened as sum(monitoring.queries_opened),
        queries_resolved as sum(monitoring.queries_resolved),
        query_resolution_rate as (queries_resolved / queries_opened) * 100,
        protocol_deviations as sum(monitoring.protocol_deviations_found),
        critical_findings as sum(monitoring.critical_findings)
    )
    dimensions (
        studies.protocol_number,
        studies.study_phase,
        studies.regulatory_pathway,
        sponsors.sponsor_name,
        regulatory.submission_type,
        regulatory.regulatory_authority,
        regulatory.submission_status,
        milestones.milestone_type,
        milestones.complexity_level
    )
    synonyms (
        'IND' = regulatory.submission_type,
        'NDA' = regulatory.submission_type,
        'BLA' = regulatory.submission_type,
        'FDA' = regulatory.regulatory_authority,
        'EMA' = regulatory.regulatory_authority,
        'submission' = regulatory.submission_type,
        'approval' = regulatory.submission_status,
        'queries' = queries_opened,
        'data quality' = query_resolution_rate,
        'deviations' = protocol_deviations,
        'fast track' = studies.regulatory_pathway,
        'breakthrough therapy' = studies.regulatory_pathway
    );

-- Financial & Operational Performance Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.FINANCIAL_OPERATIONAL_VIEW
    tables (
        STUDIES AS DIM_STUDIES primary key (STUDY_ID),
        SPONSORS AS DIM_SPONSORS primary key (SPONSOR_ID),
        FINANCIALS AS FACT_STUDY_FINANCIALS primary key (FINANCIAL_RECORD_ID),
        ENROLLMENT AS FACT_ENROLLMENT primary key (ENROLLMENT_FACT_ID)
    )
    measures (
        total_contract_value as sum(studies.contract_value),
        revenue_recognized as sum_if(financials.actual_amount, financials.payment_status = 'Paid'),
        outstanding_invoices as sum_if(financials.actual_amount, financials.payment_status in ('Pending', 'Invoiced')),
        budget_variance as sum(financials.budgeted_amount) - sum(financials.actual_amount),
        enrollment_efficiency as (sum(studies.actual_enrollment) / sum(studies.planned_enrollment)) * 100,
        cost_per_patient as avg(studies.cost_per_patient),
        milestone_payments as sum_if(financials.actual_amount, financials.transaction_type = 'Milestone Payment')
    )
    dimensions (
        studies.protocol_number,
        studies.study_phase,
        studies.study_status,
        sponsors.sponsor_name,
        sponsors.sponsor_type,
        financials.transaction_type,
        financials.payment_status,
        financials.quarter,
        financials.fiscal_year
    )
    synonyms (
        'revenue' = revenue_recognized,
        'contracts' = total_contract_value,
        'invoices' = outstanding_invoices,
        'budget' = budget_variance,
        'enrollment' = enrollment_efficiency,
        'milestones' = milestone_payments,
        'quarterly' = financials.quarter,
        'annual' = financials.fiscal_year
    );

-- Grant permissions
GRANT USAGE ON SEMANTIC VIEW CLINICAL_OPERATIONS_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW BUSINESS_DEVELOPMENT_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW REGULATORY_DATA_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW FINANCIAL_OPERATIONAL_VIEW TO ROLE SF_INTELLIGENCE_DEMO;

SELECT 'CRO Semantic Views Setup Complete!' as status,
       'Views Created: 4 CRO-focused semantic views' as views_created;
