-- ========================================================================
-- CRO DEMO - Step 3: Semantic Views Setup
-- Creates semantic views for natural language queries following Snowflake best practices
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
		STUDIES as DIM_STUDIES primary key (STUDY_ID),
		SPONSORS as DIM_SPONSORS primary key (SPONSOR_ID),
		THERAPEUTIC_AREAS as DIM_THERAPEUTIC_AREAS primary key (THERAPEUTIC_AREA_ID),
		SITES as DIM_SITES primary key (SITE_ID),
		SUBJECTS as DIM_SUBJECTS primary key (SUBJECT_ID),
		ENROLLMENT as FACT_ENROLLMENT primary key (ENROLLMENT_FACT_ID),
		SAFETY_EVENTS as FACT_SAFETY_EVENTS primary key (SAFETY_EVENT_ID),
		MONITORING as FACT_SITE_MONITORING primary key (MONITORING_VISIT_ID)
	)
	relationships (
		STUDYTOSPONSOR as STUDIES(SPONSOR_ID) references SPONSORS(SPONSOR_ID),
		STUDYTOTHERAPEUTIC as STUDIES(THERAPEUTIC_AREA_ID) references THERAPEUTIC_AREAS(THERAPEUTIC_AREA_ID),
		ENROLLMENTTOSTUDY as ENROLLMENT(STUDY_ID) references STUDIES(STUDY_ID),
		ENROLLMENTTOSITE as ENROLLMENT(SITE_ID) references SITES(SITE_ID),
		SUBJECTTOSTUDY as SUBJECTS(STUDY_ID) references STUDIES(STUDY_ID),
		SUBJECTTOSITE as SUBJECTS(SITE_ID) references SITES(SITE_ID),
		SAFETYEVENTTOSTUDY as SAFETY_EVENTS(STUDY_ID) references STUDIES(STUDY_ID),
		SAFETYEVENTTOSITE as SAFETY_EVENTS(SITE_ID) references SITES(SITE_ID),
		SAFETYEVENTTOSUBJECT as SAFETY_EVENTS(SUBJECT_ID) references SUBJECTS(SUBJECT_ID),
		MONITORINGTOSTUDY as MONITORING(STUDY_ID) references STUDIES(STUDY_ID),
		MONITORINGTOSITE as MONITORING(SITE_ID) references SITES(SITE_ID)
	)
	facts (
		STUDIES.PLANNED_ENROLLMENT as planned_enrollment,
		STUDIES.ACTUAL_ENROLLMENT as actual_enrollment,
		STUDIES.CONTRACT_VALUE as contract_value,
		STUDIES.COST_PER_PATIENT as cost_per_patient,
		ENROLLMENT.SUBJECTS_SCREENED as subjects_screened,
		ENROLLMENT.SUBJECTS_ENROLLED as subjects_enrolled,
		ENROLLMENT.SCREEN_FAILURE_RATE as screen_failure_rate,
		ENROLLMENT.ENROLLMENT_RATE as enrollment_rate,
		SITES.DATA_QUALITY_SCORE as data_quality_score,
		SITES.REGULATORY_COMPLIANCE_SCORE as regulatory_compliance_score,
		MONITORING.QUERIES_OPENED as queries_opened,
		MONITORING.QUERIES_RESOLVED as queries_resolved,
		MONITORING.PROTOCOL_DEVIATIONS_FOUND as protocol_deviations_found,
		MONITORING.CRITICAL_FINDINGS as critical_findings
	)
	dimensions (
		STUDIES.STUDY_ID as study_id,
		STUDIES.PROTOCOL_NUMBER as protocol_number,
		STUDIES.STUDY_TITLE as study_title,
		STUDIES.STUDY_PHASE as study_phase,
		STUDIES.STUDY_STATUS as study_status,
		STUDIES.REGULATORY_PATHWAY as regulatory_pathway,
		SPONSORS.SPONSOR_NAME as sponsor_name,
		SPONSORS.SPONSOR_TYPE as sponsor_type,
		SPONSORS.COMPANY_SIZE as company_size,
		SPONSORS.RELATIONSHIP_TIER as relationship_tier,
		THERAPEUTIC_AREAS.THERAPEUTIC_AREA_NAME as therapeutic_area_name,
		THERAPEUTIC_AREAS.EXPERTISE_LEVEL as expertise_level,
		SITES.SITE_NAME as site_name,
		SITES.PRINCIPAL_INVESTIGATOR as principal_investigator,
		SITES.COUNTRY as country,
		SITES.SITE_TIER as site_tier,
		SUBJECTS.AGE_GROUP as age_group,
		SUBJECTS.GENDER as gender,
		SUBJECTS.SUBJECT_STATUS as subject_status,
		SAFETY_EVENTS.EVENT_TYPE as event_type,
		SAFETY_EVENTS.SEVERITY as severity,
		SAFETY_EVENTS.CAUSALITY as causality
	)
	metrics (
		STUDIES.TOTAL_ENROLLMENT as SUM(actual_enrollment)
			WITH SYNONYMS = ('total enrollment', 'total subjects', 'enrolled patients'),
		ENROLLMENT.AVG_ENROLLMENT_RATE as AVG(enrollment_rate)
			WITH SYNONYMS = ('enrollment rate', 'recruitment rate', 'accrual rate'),
		STUDIES.TOTAL_CONTRACT_VALUE as SUM(contract_value)
			WITH SYNONYMS = ('total contract value', 'contract revenue', 'study value'),
		SAFETY_EVENTS.TOTAL_SAFETY_EVENTS as COUNT(*)
			WITH SYNONYMS = ('safety events', 'adverse events', 'AEs'),
		SAFETY_EVENTS.SERIOUS_ADVERSE_EVENTS as SUM(CASE WHEN event_type = 'Serious Adverse Event' THEN 1 ELSE 0 END)
			WITH SYNONYMS = ('serious adverse events', 'SAEs', 'serious AEs'),
		MONITORING.TOTAL_QUERIES as SUM(queries_opened)
			WITH SYNONYMS = ('total queries', 'data queries', 'query count'),
		MONITORING.QUERY_RESOLUTION_RATE as SUM(queries_resolved) / SUM(queries_opened) * 100
			WITH SYNONYMS = ('query resolution rate', 'query closure rate', 'data quality'),
		SITES.AVG_DATA_QUALITY as AVG(data_quality_score)
			WITH SYNONYMS = ('data quality score', 'site performance', 'data quality')
	);

-- Business Development Semantic View
CREATE OR REPLACE SEMANTIC VIEW CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.BUSINESS_DEVELOPMENT_VIEW
	tables (
		SPONSORS as DIM_SPONSORS primary key (SPONSOR_ID),
		STUDIES as DIM_STUDIES primary key (STUDY_ID),
		THERAPEUTIC_AREAS as DIM_THERAPEUTIC_AREAS primary key (THERAPEUTIC_AREA_ID),
		BUSINESS_DEV as FACT_BUSINESS_DEVELOPMENT primary key (OPPORTUNITY_ID),
		FINANCIALS as FACT_STUDY_FINANCIALS primary key (FINANCIAL_RECORD_ID)
	)
	relationships (
		STUDYTOSPONSOR as STUDIES(SPONSOR_ID) references SPONSORS(SPONSOR_ID),
		STUDYTOTHERAPEUTIC as STUDIES(THERAPEUTIC_AREA_ID) references THERAPEUTIC_AREAS(THERAPEUTIC_AREA_ID),
		BUSINESSDEVTOSPONSOR as BUSINESS_DEV(SPONSOR_ID) references SPONSORS(SPONSOR_ID),
		BUSINESSDEVTOTHERAPEUTIC as BUSINESS_DEV(THERAPEUTIC_AREA_ID) references THERAPEUTIC_AREAS(THERAPEUTIC_AREA_ID),
		FINANCIALSTOSTUDY as FINANCIALS(STUDY_ID) references STUDIES(STUDY_ID),
		FINANCIALSTOSPONSOR as FINANCIALS(SPONSOR_ID) references SPONSORS(SPONSOR_ID)
	)
	facts (
		SPONSORS.TOTAL_CONTRACT_VALUE as total_contract_value,
		SPONSORS.ACTIVE_STUDIES_COUNT as active_studies_count,
		STUDIES.CONTRACT_VALUE as contract_value,
		BUSINESS_DEV.ESTIMATED_VALUE as estimated_value,
		BUSINESS_DEV.WIN_PROBABILITY as win_probability,
		FINANCIALS.BUDGETED_AMOUNT as budgeted_amount,
		FINANCIALS.ACTUAL_AMOUNT as actual_amount
	)
	dimensions (
		SPONSORS.SPONSOR_ID as sponsor_id,
		SPONSORS.SPONSOR_NAME as sponsor_name,
		SPONSORS.SPONSOR_TYPE as sponsor_type,
		SPONSORS.COMPANY_SIZE as company_size,
		SPONSORS.HEADQUARTERS_COUNTRY as headquarters_country,
		SPONSORS.RELATIONSHIP_TIER as relationship_tier,
		STUDIES.STUDY_ID as study_id,
		STUDIES.PROTOCOL_NUMBER as protocol_number,
		STUDIES.STUDY_PHASE as study_phase,
		STUDIES.STUDY_STATUS as study_status,
		THERAPEUTIC_AREAS.THERAPEUTIC_AREA_NAME as therapeutic_area_name,
		THERAPEUTIC_AREAS.MARKET_SIZE as market_size,
		BUSINESS_DEV.OPPORTUNITY_TYPE as opportunity_type,
		BUSINESS_DEV.PROPOSAL_STATUS as proposal_status,
		BUSINESS_DEV.COMPETITION_LEVEL as competition_level,
		FINANCIALS.TRANSACTION_TYPE as transaction_type,
		FINANCIALS.PAYMENT_STATUS as payment_status,
		FINANCIALS.QUARTER as quarter,
		FINANCIALS.FISCAL_YEAR as fiscal_year
	)
	metrics (
		SPONSORS.TOTAL_REVENUE as SUM(total_contract_value)
			WITH SYNONYMS = ('total revenue', 'sponsor revenue', 'contract revenue'),
		BUSINESS_DEV.OPPORTUNITIES_WON as SUM(CASE WHEN proposal_status = 'Won' THEN 1 ELSE 0 END)
			WITH SYNONYMS = ('opportunities won', 'wins', 'successful proposals'),
		BUSINESS_DEV.OPPORTUNITIES_LOST as SUM(CASE WHEN proposal_status = 'Lost' THEN 1 ELSE 0 END)
			WITH SYNONYMS = ('opportunities lost', 'losses', 'unsuccessful proposals'),
		BUSINESS_DEV.WIN_RATE as SUM(CASE WHEN proposal_status = 'Won' THEN 1 ELSE 0 END) / SUM(CASE WHEN proposal_status IN ('Won', 'Lost') THEN 1 ELSE 0 END) * 100
			WITH SYNONYMS = ('win rate', 'success rate', 'proposal success rate'),
		BUSINESS_DEV.PIPELINE_VALUE as SUM(CASE WHEN proposal_status = 'Pending' THEN estimated_value ELSE 0 END)
			WITH SYNONYMS = ('pipeline value', 'pending opportunities', 'business pipeline'),
		FINANCIALS.REVENUE_RECOGNIZED as SUM(CASE WHEN payment_status = 'Paid' THEN actual_amount ELSE 0 END)
			WITH SYNONYMS = ('revenue recognized', 'paid revenue', 'collected revenue'),
		FINANCIALS.OUTSTANDING_INVOICES as SUM(CASE WHEN payment_status IN ('Pending', 'Invoiced') THEN actual_amount ELSE 0 END)
			WITH SYNONYMS = ('outstanding invoices', 'pending payments', 'accounts receivable')
	);

-- Grant permissions
GRANT USAGE ON SEMANTIC VIEW CLINICAL_OPERATIONS_VIEW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW BUSINESS_DEVELOPMENT_VIEW TO ROLE SF_INTELLIGENCE_DEMO;

SELECT 'CRO Semantic Views Setup Complete!' as status,
       'Views Created: 2 CRO-focused semantic views with proper Snowflake syntax' as views_created;
