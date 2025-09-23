-- ========================================================================
-- CRO Demo - Step 2a: Document Data Loading
-- Loads CRO documents into Snowflake tables for Cortex Search
-- Prerequisites: Run 01_cro_data_setup.sql and 02_cortex_search_setup.sql first
-- ========================================================================

-- Switch to the CRO demo role and database
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- REGULATORY DOCUMENTS DATA
-- ========================================================================

-- Insert ICH-GCP Guidelines document
INSERT INTO REGULATORY_DOCUMENTS (
    document_id,
    title,
    category,
    document_type,
    content,
    relative_path,
    upload_date
) VALUES (
    'REG_001',
    'ICH-GCP Guidelines and Standard Operating Procedures',
    'Regulatory',
    'Guidelines',
    '# ICH-GCP Guidelines and Standard Operating Procedures
**Document Version**: 3.2  
**Effective Date**: January 1, 2025  
**Review Date**: December 31, 2025  
**Department**: Regulatory Affairs, Clinical Operations, Quality Assurance

## Purpose

This document establishes guidelines for Good Clinical Practice (GCP) compliance in accordance with ICH E6(R2) guidelines to ensure the integrity, safety, and quality of clinical trial data and protect the rights and welfare of trial subjects.

## Scope

These guidelines apply to all clinical trials conducted by the Contract Research Organization, including:
- Phase I through Phase IV clinical trials
- Interventional and observational studies
- Medical device studies
- Post-market surveillance studies
- International multi-center trials

## Fundamental Principles of GCP

### Quality Management
Clinical trials should be conducted in accordance with a comprehensive quality management system that covers all aspects of trial conduct including:

**Risk-Based Approach:**
- Identification of critical processes and data
- Implementation of proportionate oversight
- Focus on essential study conduct activities
- Adaptive monitoring strategies

**Quality by Design:**
- Quality considerations integrated from protocol development
- Pre-defined critical to quality factors
- Robust study design minimizing risks to data integrity
- Proactive identification and mitigation of quality risks

### Subject Rights and Safety

**Informed Consent Process:**
- Voluntary participation without coercion
- Adequate time for consideration
- Understanding of trial procedures and risks
- Right to withdraw at any time without penalty
- Documentation of consent process

**Subject Safety Monitoring:**
- Continuous safety monitoring throughout trial
- Prompt reporting of adverse events
- Independent Data Safety Monitoring Board (DSMB) oversight
- Emergency procedures and contact information
- Medical care for trial-related injuries

## Organizational Responsibilities

### Sponsor Responsibilities
The pharmaceutical or biotechnology sponsor company is responsible for:

**Protocol Development:**
- Scientific rationale and objectives
- Risk-benefit assessment
- Statistical considerations and sample size
- Data management and analysis plans
- Quality management approach

**Site Selection and Management:**
- Investigator qualifications assessment
- Site facility and resource evaluation
- Training and communication
- Supply chain management
- Contract and budget negotiations

**Regulatory Compliance:**
- Regulatory authority communications
- Safety reporting requirements
- Annual safety reports
- Protocol amendments and approvals
- Inspection readiness and response

### Contract Research Organization (CRO) Responsibilities

**Clinical Operations Management:**
- Study startup and site initiation
- Subject enrollment monitoring and support
- Clinical monitoring and site visits
- Data quality oversight and query management
- Timeline and milestone tracking

**Regulatory Affairs Support:**
- Regulatory submission preparation
- Global regulatory strategy development
- Interaction with regulatory authorities
- Compliance monitoring and reporting
- Documentation management

**Data Management:**
- Electronic Data Capture (EDC) system setup
- Data validation and quality checks
- Query generation and resolution
- Database lock procedures
- Data transfer and archival

## Adverse Event Reporting

### Safety Monitoring Requirements

**Immediate Reporting (24 hours):**
- Death of a trial subject
- Life-threatening adverse events
- Events requiring hospitalization
- Suspected unexpected serious adverse reactions (SUSARs)
- Adverse events of special interest (AESI)

**Expedited Reporting (15 days):**
- Serious adverse events related to study drug
- Significant safety findings
- New safety information
- Regulatory authority notifications
- Safety signal evaluations

### Causality Assessment
Systematic evaluation of adverse events:

**Relationship to Study Treatment:**
- Unrelated: No temporal or biological relationship
- Unlikely: Temporal relationship but other causes likely
- Possible: Temporal relationship, other causes possible
- Probable: Good temporal relationship, difficult to explain otherwise
- Definite: Clear temporal relationship, positive dechallenge/rechallenge

## Regulatory Submissions and Communications

### Regulatory Strategy Development
Comprehensive approach to global regulatory requirements:

**Pre-Submission Activities:**
- Regulatory landscape assessment
- Scientific advice meetings
- Orphan drug designations
- Fast track and breakthrough therapy designations
- Pediatric investigation plans

**Clinical Trial Applications:**
- Investigational New Drug (IND) applications
- Clinical Trial Applications (CTA) for EMA
- Health Canada Clinical Trial Applications
- Ethics committee submissions
- Local regulatory authority approvals

This document serves as the foundation for GCP compliance across all clinical trial activities and should be referenced in conjunction with study-specific procedures and local regulatory requirements.',
    'regulatory/ICH_GCP_Guidelines.md',
    CURRENT_TIMESTAMP()
);

-- ========================================================================
-- OPERATIONS DOCUMENTS DATA
-- ========================================================================

-- Insert Site Management SOP document
INSERT INTO OPERATIONS_DOCUMENTS (
    document_id,
    title,
    category,
    document_type,
    content,
    relative_path,
    upload_date
) VALUES (
    'OPS_001',
    'Site Management and Monitoring Standard Operating Procedure',
    'Operations',
    'SOP',
    '# Site Management and Monitoring Standard Operating Procedure
**Document Version**: 2.8  
**Effective Date**: January 1, 2025  
**Review Date**: December 31, 2025  
**Department**: Clinical Operations, Site Management

## Purpose

This Standard Operating Procedure (SOP) establishes standardized processes for investigative site selection, qualification, initiation, monitoring, and management to ensure consistent high-quality clinical trial conduct across all therapeutic areas and geographic regions.

## Scope

This SOP applies to all clinical trials managed by the Contract Research Organization including:
- Phase I-IV interventional studies
- Observational and registry studies  
- Medical device clinical evaluations
- Post-market surveillance studies
- Global multi-center trials

## Site Selection and Qualification

### Site Identification Process

**Therapeutic Area Expertise Assessment:**
- Previous experience in relevant therapeutic indication
- Principal Investigator (PI) publication record
- Site''s patient population demographics
- Access to target patient population
- Competitive study landscape evaluation

**Feasibility Assessment Criteria:**
- Projected enrollment capability
- Timeline feasibility and availability
- Regulatory and ethics approval timelines
- Staff qualifications and availability
- Infrastructure and equipment requirements

### Site Qualification Visit (SQV)

**Pre-Visit Preparation:**
- Site qualification questionnaire completion
- Curriculum vitae and training records review
- Facility and equipment assessment forms
- Regulatory documentation checklist
- Financial and contract consideration review

**On-Site Assessment Components:**
- Principal Investigator interview and evaluation
- Study coordinator and staff assessment
- Facility tour and equipment inspection
- Patient population and medical records review
- Regulatory documentation verification
- Information technology and data systems evaluation

## Risk-Based Monitoring Strategy

### Risk Assessment and Categorization

**Study-Level Risk Factors:**
- Therapeutic area complexity and safety profile
- Primary endpoint complexity and subjectivity
- Subject population characteristics
- Regulatory pathway and approval requirements
- Investigational product characteristics

**Site-Level Risk Factors:**
- Site experience with similar protocols
- Historical performance and data quality
- Staff turnover and training status
- Patient enrollment challenges
- Regulatory compliance history

### Central Monitoring Activities

**Statistical Data Monitoring:**
- Outlier detection and analysis
- Data trend identification and evaluation
- Cross-site data comparison and assessment
- Key risk indicator (KRI) tracking
- Automated quality control check execution

**Medical Data Review:**
- Adverse event pattern analysis
- Concomitant medication evaluation
- Laboratory data trend assessment
- Efficacy endpoint consistency review
- Protocol deviation impact analysis

### On-Site Monitoring Procedures

**Monitoring Visit Types:**

**Routine Monitoring Visits:**
- Frequency: Every 4-8 weeks based on enrollment
- Source data verification (SDV) sampling
- Regulatory documentation review
- Investigational product accountability
- Site staff training and qualification verification

**Triggered Monitoring Visits:**
- Safety signal or serious adverse event follow-up
- Data quality issues or high query rates
- Regulatory compliance concerns
- Enrollment challenges or protocol deviations
- Site staff changes or training needs

## Site Performance Management

### Key Performance Indicators (KPIs)

**Enrollment Metrics:**
- Monthly enrollment rate vs. target
- Screen failure rate and reasons
- Time from screening to randomization
- Cumulative enrollment achievement
- Enrollment predictability and consistency

**Data Quality Metrics:**
- Query rate per patient and per data field
- Query response time and resolution rate
- Source data verification error rate
- Critical data discrepancy frequency
- Electronic data capture completion timeliness

**Operational Excellence Metrics:**
- Protocol deviation frequency and severity
- Serious adverse event reporting timeliness
- Monitoring visit completion rate
- Training completion and compliance
- Regulatory submission timeliness

This SOP ensures consistent, high-quality site management across all clinical trials while maintaining regulatory compliance and optimizing study conduct efficiency.',
    'operations/Site_Management_SOP.md',
    CURRENT_TIMESTAMP()
);

-- ========================================================================
-- BUSINESS DOCUMENTS DATA
-- ========================================================================

-- Insert Therapeutic Area Expertise document
INSERT INTO BUSINESS_DOCUMENTS (
    document_id,
    title,
    category,
    document_type,
    content,
    relative_path,
    upload_date
) VALUES (
    'BUS_001',
    'Therapeutic Area Expertise and Competitive Analysis',
    'Business',
    'Analysis',
    '# Therapeutic Area Expertise and Competitive Analysis
**Document Version**: 1.5  
**Effective Date**: January 1, 2025  
**Review Date**: December 31, 2025  
**Department**: Business Development, Scientific Affairs

## Executive Summary

This document outlines our Contract Research Organization''s core therapeutic area capabilities, competitive positioning, and strategic advantages in serving biotechnology and pharmaceutical companies across diverse clinical development programs.

## Core Therapeutic Area Capabilities

### Oncology - Center of Excellence

**Solid Tumor Expertise:**
- Phase I dose escalation and expansion studies
- Biomarker-driven precision medicine trials
- Immuno-oncology combination studies
- CAR-T cell therapy development programs
- Antibody-drug conjugate (ADC) clinical trials

**Hematologic Malignancies:**
- Acute and chronic leukemia studies
- Lymphoma and multiple myeloma trials
- Stem cell transplantation protocols
- Minimal residual disease monitoring
- Novel targeted therapy development

**Key Differentiators:**
- 85+ oncology studies completed over 5 years
- Dedicated oncology medical team with KOL relationships
- Central laboratory with specialized biomarker capabilities
- Patient advocacy group partnerships
- Orphan drug development expertise

### Cardiovascular - Advanced Capabilities

**Heart Failure and Cardiomyopathy:**
- Device-based therapy trials
- Heart failure with preserved ejection fraction (HFpEF)
- Cardiomyopathy and sudden cardiac death prevention
- Mechanical circulatory support studies
- Cardiac regenerative medicine trials

**Specialized Infrastructure:**
- Cardiac safety core laboratory
- ECG monitoring and analysis
- Echocardiography core lab
- Cardiac MRI and CT imaging
- Holter and event monitoring capabilities

### Central Nervous System (CNS) - Strategic Focus

**Neurodegenerative Diseases:**
- Alzheimer''s disease clinical trials
- Parkinson''s disease and movement disorders
- Amyotrophic lateral sclerosis (ALS) studies
- Huntington''s disease trials
- Multiple sclerosis clinical programs

**CNS-Specific Capabilities:**
- Cognitive assessment and neuropsychological testing
- Biomarker development (CSF, neuroimaging)
- Digital therapeutics and apps
- Caregiver-reported outcomes
- Regulatory pathway expertise (breakthrough therapy, fast track)

### Rare Diseases - Specialized Expertise

**Genetic Disorders:**
- Inherited metabolic disorders
- Lysosomal storage diseases
- Muscular dystrophies and myopathies
- Primary immunodeficiencies
- Mitochondrial diseases

**Orphan Drug Development:**
- Natural history studies
- Patient registries and biobanks
- Regulatory strategy for orphan designation
- Pediatric investigation plans
- Health technology assessment (HTA) support

**Regulatory Expertise:**
- FDA Orphan Drug Designation applications
- EMA COMP interactions
- Humanitarian Device Exemption (HDE) support
- Pediatric Rare Disease Priority Review Vouchers
- Accelerated approval pathway strategy

## Competitive Landscape Analysis

### Market Position Assessment

**Tier 1 Competitors (Large Global CROs):**
- Strengths: Global reach, comprehensive services, therapeutic breadth
- Weaknesses: Less flexible, higher costs, complex matrix organizations
- Our Differentiation: Agility, personalized service, integrated laboratory services

**Competitive Advantages:**
- Scientific Leadership with board-certified physicians in each therapeutic area
- Operational Excellence with 95%+ study completion rate
- Client Partnership Approach with dedicated therapeutic area account management

## Financial Performance and Metrics

### Therapeutic Area Revenue Analysis

**Revenue Distribution by Therapeutic Area (2024):**
- Oncology: 45% ($180M) - maintaining market leadership
- Cardiovascular: 25% ($100M) - steady growth trajectory
- CNS: 20% ($80M) - emerging therapeutic focus
- Rare Diseases: 10% ($40M) - high-growth opportunity

### Regulatory Track Record

**FDA Submission Success Rates:**
- IND Approvals: 98% first-time approval rate
- NDA/BLA Submissions: 85% approval rate within standard timeline
- Breakthrough Therapy Designations: 15 designations supported
- Fast Track Designations: 25 designations obtained
- Orphan Drug Designations: 40 designations secured

This document establishes our therapeutic area leadership position and competitive strategy to support continued growth and client success across diverse clinical development programs.',
    'business/Therapeutic_Area_Expertise.md',
    CURRENT_TIMESTAMP()
);

-- ========================================================================
-- VERIFICATION
-- ========================================================================

-- Verify documents were loaded
SELECT 'Regulatory Documents' as document_type, COUNT(*) as count FROM REGULATORY_DOCUMENTS
UNION ALL
SELECT 'Operations Documents' as document_type, COUNT(*) as count FROM OPERATIONS_DOCUMENTS  
UNION ALL
SELECT 'Business Documents' as document_type, COUNT(*) as count FROM BUSINESS_DOCUMENTS
ORDER BY document_type;

-- Show sample of loaded content
SELECT 
    'REGULATORY' as source,
    document_id,
    title,
    category,
    LEFT(content, 200) as content_preview
FROM REGULATORY_DOCUMENTS
UNION ALL
SELECT 
    'OPERATIONS' as source,
    document_id,
    title,
    category,
    LEFT(content, 200) as content_preview
FROM OPERATIONS_DOCUMENTS
UNION ALL
SELECT 
    'BUSINESS' as source,
    document_id,
    title,
    category,
    LEFT(content, 200) as content_preview
FROM BUSINESS_DOCUMENTS
ORDER BY source, document_id;

SELECT '✅ CRO Documents Successfully Loaded into Snowflake Tables!' as status;
