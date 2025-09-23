# CRO Data Model - Entity Relationship Diagrams

This document provides comprehensive Entity Relationship Diagrams (ERDs) for the Contract Research Organization (CRO) data model, showing the relationships between clinical trial entities, sponsor management, regulatory tracking, and financial operations.

## Complete CRO Data Model Overview

```mermaid
erDiagram
    DIM_SPONSORS {
        NUMBER sponsor_id PK
        VARCHAR sponsor_name
        VARCHAR sponsor_type
        VARCHAR company_size
        VARCHAR headquarters_country
        VARCHAR headquarters_region
        VARCHAR therapeutic_focus
        DATE partnership_start_date
        NUMBER total_contract_value
        NUMBER active_studies_count
        VARCHAR relationship_tier
    }

    DIM_THERAPEUTIC_AREAS {
        NUMBER therapeutic_area_id PK
        VARCHAR therapeutic_area_name
        VARCHAR therapeutic_area_code
        VARCHAR specialty_focus
        VARCHAR regulatory_complexity
        VARCHAR market_size
        VARCHAR expertise_level
    }

    DIM_STUDIES {
        NUMBER study_id PK
        VARCHAR protocol_number
        VARCHAR study_title
        NUMBER sponsor_id FK
        NUMBER therapeutic_area_id FK
        VARCHAR study_phase
        VARCHAR study_type
        VARCHAR primary_indication
        VARCHAR study_design
        NUMBER planned_enrollment
        NUMBER actual_enrollment
        DATE study_start_date
        DATE planned_completion_date
        DATE actual_completion_date
        VARCHAR study_status
        NUMBER contract_value
        NUMBER cost_per_patient
        VARCHAR regulatory_pathway
    }

    DIM_SITES {
        NUMBER site_id PK
        VARCHAR site_name
        VARCHAR site_number
        VARCHAR principal_investigator
        VARCHAR site_type
        VARCHAR country
        VARCHAR region
        VARCHAR therapeutic_expertise
        DATE gcp_certification_date
        VARCHAR site_tier
        NUMBER enrollment_capacity
        NUMBER active_studies_count
        NUMBER historical_enrollment_rate
        NUMBER data_quality_score
        NUMBER regulatory_compliance_score
    }

    DIM_SUBJECTS {
        NUMBER subject_id PK
        VARCHAR subject_number
        NUMBER study_id FK
        NUMBER site_id FK
        VARCHAR age_group
        VARCHAR gender
        VARCHAR race_ethnicity
        DATE enrollment_date
        DATE randomization_date
        VARCHAR treatment_arm
        VARCHAR subject_status
        VARCHAR withdrawal_reason
        DATE completion_date
    }

    DIM_CRO_STAFF {
        NUMBER staff_id PK
        VARCHAR employee_name
        VARCHAR department
        VARCHAR job_role
        VARCHAR therapeutic_expertise
        NUMBER years_experience
        VARCHAR certifications
        VARCHAR location_country
        VARCHAR location_region
        NUMBER active_studies_count
    }

    DIM_REGULATORY_MILESTONES {
        NUMBER milestone_id PK
        VARCHAR milestone_name
        VARCHAR milestone_type
        VARCHAR regulatory_authority
        VARCHAR complexity_level
        NUMBER typical_timeline_days
        VARCHAR requirements_description
    }

    FACT_ENROLLMENT {
        NUMBER enrollment_fact_id PK
        NUMBER study_id FK
        NUMBER site_id FK
        DATE enrollment_date
        NUMBER enrollment_week
        NUMBER enrollment_month
        NUMBER subjects_screened
        NUMBER subjects_enrolled
        NUMBER subjects_randomized
        NUMBER screen_failure_rate
        NUMBER enrollment_rate
        NUMBER cumulative_enrollment
        NUMBER enrollment_target
        NUMBER enrollment_vs_target_pct
    }

    FACT_SAFETY_EVENTS {
        NUMBER safety_event_id PK
        NUMBER study_id FK
        NUMBER site_id FK
        NUMBER subject_id FK
        DATE event_date
        VARCHAR event_type
        VARCHAR event_term
        VARCHAR severity
        VARCHAR causality
        VARCHAR outcome
        VARCHAR treatment_arm
        NUMBER days_on_treatment
        NUMBER reported_to_sponsor_days
        BOOLEAN regulatory_reportable
    }

    FACT_SITE_MONITORING {
        NUMBER monitoring_visit_id PK
        NUMBER study_id FK
        NUMBER site_id FK
        NUMBER staff_id FK
        DATE visit_date
        VARCHAR visit_type
        NUMBER subjects_reviewed
        NUMBER queries_opened
        NUMBER queries_resolved
        NUMBER protocol_deviations_found
        NUMBER critical_findings
        NUMBER visit_duration_hours
        NUMBER data_quality_score
        NUMBER compliance_score
        DATE next_visit_planned_date
    }

    FACT_STUDY_FINANCIALS {
        NUMBER financial_record_id PK
        NUMBER study_id FK
        NUMBER sponsor_id FK
        DATE transaction_date
        VARCHAR transaction_type
        VARCHAR milestone_name
        NUMBER budgeted_amount
        NUMBER actual_amount
        NUMBER amount_difference
        VARCHAR payment_status
        VARCHAR cost_category
        VARCHAR quarter
        NUMBER fiscal_year
    }

    FACT_REGULATORY_SUBMISSIONS {
        NUMBER submission_id PK
        NUMBER study_id FK
        NUMBER milestone_id FK
        DATE submission_date
        DATE planned_submission_date
        VARCHAR submission_type
        VARCHAR regulatory_authority
        VARCHAR submission_status
        DATE approval_date
        NUMBER days_to_approval
        NUMBER planned_vs_actual_days
        VARCHAR rejection_reason
        BOOLEAN resubmission_required
    }

    FACT_BUSINESS_DEVELOPMENT {
        NUMBER opportunity_id PK
        NUMBER sponsor_id FK
        NUMBER therapeutic_area_id FK
        DATE rfp_date
        DATE proposal_due_date
        DATE proposal_submitted_date
        VARCHAR opportunity_name
        VARCHAR opportunity_type
        NUMBER estimated_value
        VARCHAR study_phase
        NUMBER number_of_subjects
        NUMBER number_of_sites
        VARCHAR competition_level
        NUMBER win_probability
        VARCHAR proposal_status
        DATE award_date
        VARCHAR win_loss_reason
    }

    %% Relationships
    DIM_SPONSORS ||--o{ DIM_STUDIES : "sponsors"
    DIM_THERAPEUTIC_AREAS ||--o{ DIM_STUDIES : "categorizes"
    DIM_STUDIES ||--o{ DIM_SUBJECTS : "enrolls"
    DIM_SITES ||--o{ DIM_SUBJECTS : "treats"
    DIM_STUDIES ||--o{ FACT_ENROLLMENT : "tracks"
    DIM_SITES ||--o{ FACT_ENROLLMENT : "participates"
    DIM_STUDIES ||--o{ FACT_SAFETY_EVENTS : "monitors"
    DIM_SITES ||--o{ FACT_SAFETY_EVENTS : "reports"
    DIM_SUBJECTS ||--o{ FACT_SAFETY_EVENTS : "experiences"
    DIM_STUDIES ||--o{ FACT_SITE_MONITORING : "oversees"
    DIM_SITES ||--o{ FACT_SITE_MONITORING : "receives"
    DIM_CRO_STAFF ||--o{ FACT_SITE_MONITORING : "conducts"
    DIM_STUDIES ||--o{ FACT_STUDY_FINANCIALS : "generates"
    DIM_SPONSORS ||--o{ FACT_STUDY_FINANCIALS : "pays"
    DIM_STUDIES ||--o{ FACT_REGULATORY_SUBMISSIONS : "requires"
    DIM_REGULATORY_MILESTONES ||--o{ FACT_REGULATORY_SUBMISSIONS : "defines"
    DIM_SPONSORS ||--o{ FACT_BUSINESS_DEVELOPMENT : "requests"
    DIM_THERAPEUTIC_AREAS ||--o{ FACT_BUSINESS_DEVELOPMENT : "focuses"
```

## Clinical Operations Focus ERD

This diagram focuses on the core clinical trial operations entities and their relationships:

```mermaid
erDiagram
    DIM_STUDIES {
        NUMBER study_id PK
        VARCHAR protocol_number
        VARCHAR study_title
        VARCHAR study_phase
        VARCHAR study_status
        NUMBER planned_enrollment
        NUMBER actual_enrollment
        DATE study_start_date
        VARCHAR regulatory_pathway
    }

    DIM_SITES {
        NUMBER site_id PK
        VARCHAR site_name
        VARCHAR principal_investigator
        VARCHAR country
        VARCHAR site_tier
        NUMBER data_quality_score
        NUMBER regulatory_compliance_score
    }

    DIM_SUBJECTS {
        NUMBER subject_id PK
        VARCHAR subject_number
        VARCHAR age_group
        VARCHAR gender
        DATE enrollment_date
        VARCHAR subject_status
        VARCHAR treatment_arm
    }

    FACT_ENROLLMENT {
        NUMBER enrollment_fact_id PK
        DATE enrollment_date
        NUMBER subjects_screened
        NUMBER subjects_enrolled
        NUMBER enrollment_rate
        NUMBER screen_failure_rate
    }

    FACT_SAFETY_EVENTS {
        NUMBER safety_event_id PK
        DATE event_date
        VARCHAR event_type
        VARCHAR severity
        VARCHAR causality
        BOOLEAN regulatory_reportable
    }

    FACT_SITE_MONITORING {
        NUMBER monitoring_visit_id PK
        DATE visit_date
        VARCHAR visit_type
        NUMBER queries_opened
        NUMBER queries_resolved
        NUMBER protocol_deviations_found
        NUMBER data_quality_score
    }

    DIM_STUDIES ||--o{ DIM_SUBJECTS : "enrolls"
    DIM_SITES ||--o{ DIM_SUBJECTS : "treats"
    DIM_STUDIES ||--o{ FACT_ENROLLMENT : "tracks"
    DIM_SITES ||--o{ FACT_ENROLLMENT : "participates"
    DIM_STUDIES ||--o{ FACT_SAFETY_EVENTS : "monitors"
    DIM_SUBJECTS ||--o{ FACT_SAFETY_EVENTS : "experiences"
    DIM_STUDIES ||--o{ FACT_SITE_MONITORING : "oversees"
    DIM_SITES ||--o{ FACT_SITE_MONITORING : "receives"
```

## Business Development & Sponsor Management ERD

This diagram shows the business development and sponsor relationship entities:

```mermaid
erDiagram
    DIM_SPONSORS {
        NUMBER sponsor_id PK
        VARCHAR sponsor_name
        VARCHAR sponsor_type
        VARCHAR company_size
        VARCHAR headquarters_country
        VARCHAR relationship_tier
        NUMBER total_contract_value
        NUMBER active_studies_count
    }

    DIM_THERAPEUTIC_AREAS {
        NUMBER therapeutic_area_id PK
        VARCHAR therapeutic_area_name
        VARCHAR market_size
        VARCHAR expertise_level
        VARCHAR regulatory_complexity
    }

    DIM_STUDIES {
        NUMBER study_id PK
        VARCHAR protocol_number
        VARCHAR study_phase
        NUMBER contract_value
        VARCHAR study_status
    }

    FACT_BUSINESS_DEVELOPMENT {
        NUMBER opportunity_id PK
        VARCHAR opportunity_name
        VARCHAR opportunity_type
        NUMBER estimated_value
        VARCHAR competition_level
        NUMBER win_probability
        VARCHAR proposal_status
        DATE rfp_date
        DATE award_date
    }

    FACT_STUDY_FINANCIALS {
        NUMBER financial_record_id PK
        DATE transaction_date
        VARCHAR transaction_type
        NUMBER budgeted_amount
        NUMBER actual_amount
        VARCHAR payment_status
        VARCHAR quarter
        NUMBER fiscal_year
    }

    DIM_SPONSORS ||--o{ DIM_STUDIES : "sponsors"
    DIM_THERAPEUTIC_AREAS ||--o{ DIM_STUDIES : "categorizes"
    DIM_SPONSORS ||--o{ FACT_BUSINESS_DEVELOPMENT : "requests"
    DIM_THERAPEUTIC_AREAS ||--o{ FACT_BUSINESS_DEVELOPMENT : "focuses"
    DIM_STUDIES ||--o{ FACT_STUDY_FINANCIALS : "generates"
    DIM_SPONSORS ||--o{ FACT_STUDY_FINANCIALS : "pays"
```

## Regulatory & Compliance ERD

This diagram focuses on regulatory submissions and compliance tracking:

```mermaid
erDiagram
    DIM_STUDIES {
        NUMBER study_id PK
        VARCHAR protocol_number
        VARCHAR study_phase
        VARCHAR regulatory_pathway
        VARCHAR study_status
    }

    DIM_REGULATORY_MILESTONES {
        NUMBER milestone_id PK
        VARCHAR milestone_name
        VARCHAR milestone_type
        VARCHAR regulatory_authority
        VARCHAR complexity_level
        NUMBER typical_timeline_days
    }

    FACT_REGULATORY_SUBMISSIONS {
        NUMBER submission_id PK
        DATE submission_date
        DATE planned_submission_date
        VARCHAR submission_type
        VARCHAR regulatory_authority
        VARCHAR submission_status
        DATE approval_date
        NUMBER days_to_approval
        NUMBER planned_vs_actual_days
        BOOLEAN resubmission_required
    }

    FACT_SITE_MONITORING {
        NUMBER monitoring_visit_id PK
        DATE visit_date
        VARCHAR visit_type
        NUMBER queries_opened
        NUMBER queries_resolved
        NUMBER protocol_deviations_found
        NUMBER critical_findings
        NUMBER compliance_score
    }

    DIM_STUDIES ||--o{ FACT_REGULATORY_SUBMISSIONS : "requires"
    DIM_REGULATORY_MILESTONES ||--o{ FACT_REGULATORY_SUBMISSIONS : "defines"
    DIM_STUDIES ||--o{ FACT_SITE_MONITORING : "oversees"
```

## Data Model Key Features

### **Dimension Tables (Master Data)**
- **DIM_SPONSORS**: Biotech/pharma companies with relationship management
- **DIM_STUDIES**: Clinical trial protocols and study information
- **DIM_SITES**: Investigational sites and investigator network
- **DIM_SUBJECTS**: De-identified study participants
- **DIM_THERAPEUTIC_AREAS**: Disease areas and expertise levels
- **DIM_CRO_STAFF**: Clinical operations team members
- **DIM_REGULATORY_MILESTONES**: Submission types and requirements

### **Fact Tables (Transactional Data)**
- **FACT_ENROLLMENT**: Subject screening and enrollment tracking
- **FACT_SAFETY_EVENTS**: Adverse event and safety monitoring
- **FACT_SITE_MONITORING**: Site visits and data quality tracking
- **FACT_STUDY_FINANCIALS**: Contract values and payment tracking
- **FACT_REGULATORY_SUBMISSIONS**: Regulatory submission timelines
- **FACT_BUSINESS_DEVELOPMENT**: Proposal and opportunity tracking

### **Key Relationships**
1. **Study-Centric Model**: Studies are the central entity connecting sponsors, sites, subjects, and all activities
2. **Hierarchical Sponsor Management**: Sponsors → Studies → Sites → Subjects
3. **Comprehensive Tracking**: All activities (enrollment, safety, monitoring, financial) linked to studies
4. **Multi-Dimensional Analysis**: Support for analysis by therapeutic area, geography, time, and business metrics

### **Business Intelligence Capabilities**
- **Clinical Operations**: Study performance, enrollment, safety monitoring
- **Business Development**: Sponsor relationships, proposal analytics, win rates
- **Regulatory Affairs**: Submission tracking, compliance monitoring
- **Financial Management**: Contract performance, revenue recognition, budget tracking

This data model supports comprehensive CRO operations analytics while maintaining data integrity and enabling sophisticated business intelligence reporting through the semantic views.
