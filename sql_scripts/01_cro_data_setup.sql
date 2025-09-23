-- ========================================================================
-- CRO DEMO - Step 1: Data Infrastructure Setup
-- Creates database, tables, and sample clinical trial data
-- ========================================================================

-- Switch to privileged role for database creation
USE ROLE accountadmin;

-- ========================================================================
-- INFRASTRUCTURE SETUP
-- ========================================================================

-- Create or reuse warehouse
CREATE WAREHOUSE IF NOT EXISTS CRO_DEMO_WH
    WITH WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Warehouse for CRO Intelligence Demo';

-- Create database and schema
CREATE DATABASE IF NOT EXISTS CRO_AI_DEMO
    COMMENT = 'Contract Research Organization Intelligence Demo Database';

CREATE SCHEMA IF NOT EXISTS CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA
    COMMENT = 'Clinical trial operations, regulatory, and business data';

-- Create role for demo (reuse if exists)
CREATE ROLE IF NOT EXISTS SF_INTELLIGENCE_DEMO
    COMMENT = 'Role for CRO Intelligence Demo with appropriate permissions';

-- Grant permissions
GRANT USAGE ON WAREHOUSE CRO_DEMO_WH TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON DATABASE CRO_AI_DEMO TO ROLE SF_INTELLIGENCE_DEMO;
GRANT ALL PRIVILEGES ON SCHEMA CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA TO ROLE SF_INTELLIGENCE_DEMO;

-- Switch to demo role
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- DIMENSION TABLES
-- ========================================================================

-- Sponsor companies (biotech, pharma, medical device)
CREATE OR REPLACE TABLE DIM_SPONSORS (
    sponsor_id NUMBER(10,0) NOT NULL,
    sponsor_name VARCHAR(255) NOT NULL,
    sponsor_type VARCHAR(50) NOT NULL, -- 'Biotech', 'Pharma', 'Medical Device'
    company_size VARCHAR(50) NOT NULL, -- 'Small', 'Mid-size', 'Large'
    headquarters_country VARCHAR(100),
    headquarters_region VARCHAR(100),
    therapeutic_focus VARCHAR(500), -- Primary therapeutic areas
    partnership_start_date DATE,
    total_contract_value NUMBER(15,2),
    active_studies_count NUMBER(5,0) DEFAULT 0,
    relationship_tier VARCHAR(20), -- 'Platinum', 'Gold', 'Silver', 'Bronze'
    PRIMARY KEY (sponsor_id)
);

-- Therapeutic areas
CREATE OR REPLACE TABLE DIM_THERAPEUTIC_AREAS (
    therapeutic_area_id NUMBER(10,0) NOT NULL,
    therapeutic_area_name VARCHAR(255) NOT NULL,
    therapeutic_area_code VARCHAR(20),
    specialty_focus VARCHAR(255),
    regulatory_complexity VARCHAR(20), -- 'Low', 'Medium', 'High'
    market_size VARCHAR(20), -- 'Small', 'Medium', 'Large'
    expertise_level VARCHAR(20), -- 'Basic', 'Intermediate', 'Advanced', 'Expert'
    PRIMARY KEY (therapeutic_area_id)
);

-- Study protocols
CREATE OR REPLACE TABLE DIM_STUDIES (
    study_id NUMBER(10,0) NOT NULL,
    protocol_number VARCHAR(100) NOT NULL,
    study_title VARCHAR(1000),
    sponsor_id NUMBER(10,0),
    therapeutic_area_id NUMBER(10,0),
    study_phase VARCHAR(20), -- 'Phase I', 'Phase II', 'Phase III', 'Phase IV'
    study_type VARCHAR(50), -- 'Interventional', 'Observational', 'Registry'
    primary_indication VARCHAR(500),
    study_design VARCHAR(100), -- 'Randomized Controlled', 'Open Label', 'Single Arm'
    planned_enrollment NUMBER(8,0),
    actual_enrollment NUMBER(8,0) DEFAULT 0,
    study_start_date DATE,
    planned_completion_date DATE,
    actual_completion_date DATE,
    study_status VARCHAR(50), -- 'Planning', 'Recruiting', 'Active', 'Completed', 'Terminated'
    contract_value NUMBER(12,2),
    cost_per_patient NUMBER(10,2),
    regulatory_pathway VARCHAR(100), -- 'Standard', 'Fast Track', 'Breakthrough', 'Orphan'
    PRIMARY KEY (study_id),
    FOREIGN KEY (sponsor_id) REFERENCES DIM_SPONSORS(sponsor_id),
    FOREIGN KEY (therapeutic_area_id) REFERENCES DIM_THERAPEUTIC_AREAS(therapeutic_area_id)
);

-- Investigation sites
CREATE OR REPLACE TABLE DIM_SITES (
    site_id NUMBER(10,0) NOT NULL,
    site_name VARCHAR(255) NOT NULL,
    site_number VARCHAR(50),
    principal_investigator VARCHAR(255),
    site_type VARCHAR(50), -- 'Academic Medical Center', 'Private Practice', 'Research Institute'
    country VARCHAR(100),
    region VARCHAR(100),
    therapeutic_expertise VARCHAR(500),
    gcp_certification_date DATE,
    site_tier VARCHAR(20), -- 'Tier 1', 'Tier 2', 'Tier 3'
    enrollment_capacity NUMBER(5,0),
    active_studies_count NUMBER(3,0) DEFAULT 0,
    historical_enrollment_rate NUMBER(5,2), -- Average patients per month
    data_quality_score NUMBER(3,1), -- 1-10 scale
    regulatory_compliance_score NUMBER(3,1), -- 1-10 scale
    PRIMARY KEY (site_id)
);

-- Study subjects/patients
CREATE OR REPLACE TABLE DIM_SUBJECTS (
    subject_id NUMBER(10,0) NOT NULL,
    subject_number VARCHAR(50) NOT NULL, -- De-identified subject ID
    study_id NUMBER(10,0),
    site_id NUMBER(10,0),
    age_group VARCHAR(20), -- '18-30', '31-50', '51-65', '65+'
    gender VARCHAR(10),
    race_ethnicity VARCHAR(100),
    enrollment_date DATE,
    randomization_date DATE,
    treatment_arm VARCHAR(100),
    subject_status VARCHAR(50), -- 'Screening', 'Enrolled', 'Randomized', 'Completed', 'Withdrawn'
    withdrawal_reason VARCHAR(255),
    completion_date DATE,
    PRIMARY KEY (subject_id),
    FOREIGN KEY (study_id) REFERENCES DIM_STUDIES(study_id),
    FOREIGN KEY (site_id) REFERENCES DIM_SITES(site_id)
);

-- CRO staff and roles
CREATE OR REPLACE TABLE DIM_CRO_STAFF (
    staff_id NUMBER(10,0) NOT NULL,
    employee_name VARCHAR(255) NOT NULL,
    department VARCHAR(100), -- 'Clinical Operations', 'Data Management', 'Biostatistics', 'Regulatory Affairs', 'Business Development'
    job_role VARCHAR(100), -- 'Clinical Research Associate', 'Data Manager', 'Biostatistician', 'Regulatory Specialist'
    therapeutic_expertise VARCHAR(500),
    years_experience NUMBER(3,0),
    certifications VARCHAR(500), -- GCP, ACRP, etc.
    location_country VARCHAR(100),
    location_region VARCHAR(100),
    active_studies_count NUMBER(3,0) DEFAULT 0,
    PRIMARY KEY (staff_id)
);

-- Regulatory milestones and submissions
CREATE OR REPLACE TABLE DIM_REGULATORY_MILESTONES (
    milestone_id NUMBER(10,0) NOT NULL,
    milestone_name VARCHAR(255) NOT NULL,
    milestone_type VARCHAR(100), -- 'IND Submission', 'Protocol Approval', 'First Patient In', 'Last Patient Out', 'Database Lock', 'NDA Submission'
    regulatory_authority VARCHAR(100), -- 'FDA', 'EMA', 'Health Canada', 'PMDA'
    complexity_level VARCHAR(20), -- 'Low', 'Medium', 'High'
    typical_timeline_days NUMBER(5,0),
    requirements_description VARCHAR(1000),
    PRIMARY KEY (milestone_id)
);

-- ========================================================================
-- FACT TABLES
-- ========================================================================

-- Study enrollment tracking
CREATE OR REPLACE TABLE FACT_ENROLLMENT (
    enrollment_fact_id NUMBER(15,0) NOT NULL,
    study_id NUMBER(10,0),
    site_id NUMBER(10,0),
    enrollment_date DATE,
    enrollment_week NUMBER(3,0), -- Week since study start
    enrollment_month NUMBER(3,0), -- Month since study start
    subjects_screened NUMBER(5,0) DEFAULT 0,
    subjects_enrolled NUMBER(5,0) DEFAULT 0,
    subjects_randomized NUMBER(5,0) DEFAULT 0,
    screen_failure_rate NUMBER(5,2), -- Percentage
    enrollment_rate NUMBER(5,2), -- Subjects per week
    cumulative_enrollment NUMBER(8,0),
    enrollment_target NUMBER(8,0),
    enrollment_vs_target_pct NUMBER(5,2),
    PRIMARY KEY (enrollment_fact_id),
    FOREIGN KEY (study_id) REFERENCES DIM_STUDIES(study_id),
    FOREIGN KEY (site_id) REFERENCES DIM_SITES(site_id)
);

-- Safety and adverse events
CREATE OR REPLACE TABLE FACT_SAFETY_EVENTS (
    safety_event_id NUMBER(15,0) NOT NULL,
    study_id NUMBER(10,0),
    site_id NUMBER(10,0),
    subject_id NUMBER(10,0),
    event_date DATE,
    event_type VARCHAR(100), -- 'Adverse Event', 'Serious Adverse Event', 'Device Deficiency'
    event_term VARCHAR(500),
    severity VARCHAR(20), -- 'Mild', 'Moderate', 'Severe'
    causality VARCHAR(50), -- 'Unrelated', 'Unlikely', 'Possible', 'Probable', 'Definite'
    outcome VARCHAR(100), -- 'Recovered', 'Recovering', 'Ongoing', 'Sequelae', 'Death'
    treatment_arm VARCHAR(100),
    days_on_treatment NUMBER(5,0),
    reported_to_sponsor_days NUMBER(3,0), -- Days to report to sponsor
    regulatory_reportable BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (safety_event_id),
    FOREIGN KEY (study_id) REFERENCES DIM_STUDIES(study_id),
    FOREIGN KEY (site_id) REFERENCES DIM_SITES(site_id),
    FOREIGN KEY (subject_id) REFERENCES DIM_SUBJECTS(subject_id)
);

-- Site monitoring and performance
CREATE OR REPLACE TABLE FACT_SITE_MONITORING (
    monitoring_visit_id NUMBER(15,0) NOT NULL,
    study_id NUMBER(10,0),
    site_id NUMBER(10,0),
    staff_id NUMBER(10,0), -- CRA conducting visit
    visit_date DATE,
    visit_type VARCHAR(50), -- 'Initiation', 'Routine', 'Close-out', 'For Cause'
    subjects_reviewed NUMBER(5,0),
    queries_opened NUMBER(5,0),
    queries_resolved NUMBER(5,0),
    protocol_deviations_found NUMBER(5,0),
    critical_findings NUMBER(3,0),
    visit_duration_hours NUMBER(4,1),
    data_quality_score NUMBER(3,1), -- 1-10 scale for this visit
    compliance_score NUMBER(3,1), -- 1-10 scale for this visit
    next_visit_planned_date DATE,
    PRIMARY KEY (monitoring_visit_id),
    FOREIGN KEY (study_id) REFERENCES DIM_STUDIES(study_id),
    FOREIGN KEY (site_id) REFERENCES DIM_SITES(site_id),
    FOREIGN KEY (staff_id) REFERENCES DIM_CRO_STAFF(staff_id)
);

-- Financial and billing
CREATE OR REPLACE TABLE FACT_STUDY_FINANCIALS (
    financial_record_id NUMBER(15,0) NOT NULL,
    study_id NUMBER(10,0),
    sponsor_id NUMBER(10,0),
    transaction_date DATE,
    transaction_type VARCHAR(100), -- 'Contract Signature', 'Milestone Payment', 'Monthly Fee', 'Pass-through Cost'
    milestone_name VARCHAR(255),
    budgeted_amount NUMBER(12,2),
    actual_amount NUMBER(12,2),
    amount_difference NUMBER(12,2),
    payment_status VARCHAR(50), -- 'Pending', 'Invoiced', 'Paid', 'Overdue'
    cost_category VARCHAR(100), -- 'Site Payments', 'Lab Costs', 'Staff Time', 'Technology', 'Pass-through'
    quarter VARCHAR(10), -- 'Q1-2024'
    fiscal_year NUMBER(4,0),
    PRIMARY KEY (financial_record_id),
    FOREIGN KEY (study_id) REFERENCES DIM_STUDIES(study_id),
    FOREIGN KEY (sponsor_id) REFERENCES DIM_SPONSORS(sponsor_id)
);

-- Regulatory submissions and timelines
CREATE OR REPLACE TABLE FACT_REGULATORY_SUBMISSIONS (
    submission_id NUMBER(15,0) NOT NULL,
    study_id NUMBER(10,0),
    milestone_id NUMBER(10,0),
    submission_date DATE,
    planned_submission_date DATE,
    submission_type VARCHAR(100), -- 'IND', 'Protocol Amendment', 'Safety Report', 'NDA', 'BLA'
    regulatory_authority VARCHAR(100),
    submission_status VARCHAR(50), -- 'Planned', 'In Progress', 'Submitted', 'Under Review', 'Approved', 'Rejected'
    approval_date DATE,
    days_to_approval NUMBER(5,0),
    planned_vs_actual_days NUMBER(5,0), -- Negative if early, positive if late
    rejection_reason VARCHAR(500),
    resubmission_required BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (submission_id),
    FOREIGN KEY (study_id) REFERENCES DIM_STUDIES(study_id),
    FOREIGN KEY (milestone_id) REFERENCES DIM_REGULATORY_MILESTONES(milestone_id)
);

-- Business development and proposals
CREATE OR REPLACE TABLE FACT_BUSINESS_DEVELOPMENT (
    opportunity_id NUMBER(15,0) NOT NULL,
    sponsor_id NUMBER(10,0),
    therapeutic_area_id NUMBER(10,0),
    rfp_date DATE,
    proposal_due_date DATE,
    proposal_submitted_date DATE,
    opportunity_name VARCHAR(500),
    opportunity_type VARCHAR(100), -- 'New Study', 'Add-on Service', 'Follow-up Study'
    estimated_value NUMBER(12,2),
    study_phase VARCHAR(20),
    number_of_subjects NUMBER(8,0),
    number_of_sites NUMBER(5,0),
    competition_level VARCHAR(20), -- 'Low', 'Medium', 'High'
    win_probability NUMBER(3,0), -- Percentage
    proposal_status VARCHAR(50), -- 'Lost', 'Won', 'Pending', 'No Bid'
    award_date DATE,
    win_loss_reason VARCHAR(500),
    PRIMARY KEY (opportunity_id),
    FOREIGN KEY (sponsor_id) REFERENCES DIM_SPONSORS(sponsor_id),
    FOREIGN KEY (therapeutic_area_id) REFERENCES DIM_THERAPEUTIC_AREAS(therapeutic_area_id)
);

-- ========================================================================
-- SAMPLE DATA INSERTION
-- ========================================================================

-- Insert sample sponsors
INSERT INTO DIM_SPONSORS VALUES
(1, 'BioPharma Innovations Inc', 'Biotech', 'Small', 'United States', 'North America', 'Oncology, Rare Diseases', '2022-03-15', 25000000, 3, 'Gold'),
(2, 'NeuroDev Therapeutics', 'Biotech', 'Mid-size', 'United Kingdom', 'Europe', 'CNS, Neurology', '2021-08-20', 45000000, 5, 'Platinum'),
(3, 'CardioLife Sciences', 'Pharma', 'Large', 'Germany', 'Europe', 'Cardiovascular, Metabolic', '2020-01-10', 75000000, 8, 'Platinum'),
(4, 'Genomic Health Solutions', 'Biotech', 'Small', 'Canada', 'North America', 'Precision Medicine, Oncology', '2023-01-25', 12000000, 2, 'Silver'),
(5, 'MedTech Devices Corp', 'Medical Device', 'Mid-size', 'United States', 'North America', 'Cardiovascular Devices, Diagnostics', '2022-11-30', 18000000, 3, 'Gold');

-- Insert therapeutic areas
INSERT INTO DIM_THERAPEUTIC_AREAS VALUES
(1, 'Oncology', 'ONC', 'Solid Tumors, Hematology', 'High', 'Large', 'Expert'),
(2, 'Cardiovascular', 'CV', 'Heart Failure, Arrhythmias', 'Medium', 'Large', 'Advanced'),
(3, 'Central Nervous System', 'CNS', 'Neurodegenerative, Psychiatric', 'High', 'Medium', 'Advanced'),
(4, 'Rare Diseases', 'RD', 'Orphan Drugs, Genetic Disorders', 'High', 'Small', 'Intermediate'),
(5, 'Infectious Diseases', 'ID', 'Antimicrobials, Vaccines', 'Medium', 'Medium', 'Basic'),
(6, 'Metabolic Disorders', 'MET', 'Diabetes, Obesity', 'Medium', 'Large', 'Intermediate');

-- Insert sample studies
INSERT INTO DIM_STUDIES VALUES
(101, 'BPI-2024-001', 'Phase II Study of Novel Oncology Compound in Advanced Solid Tumors', 1, 1, 'Phase II', 'Interventional', 'Advanced Solid Tumors', 'Randomized Controlled', 120, 87, '2024-02-01', '2025-08-31', NULL, 'Recruiting', 8500000, 70833, 'Fast Track'),
(102, 'NDT-2023-003', 'Phase III Trial of Neuroprotective Agent in Alzheimer Disease', 2, 3, 'Phase III', 'Interventional', 'Alzheimer Disease', 'Randomized Controlled', 600, 445, '2023-09-15', '2026-03-30', NULL, 'Active', 32000000, 53333, 'Breakthrough'),
(103, 'CLS-2024-002', 'Phase I/II Study of Heart Failure Therapy', 3, 2, 'Phase I/II', 'Interventional', 'Heart Failure', 'Dose Escalation', 80, 62, '2024-01-15', '2025-06-30', NULL, 'Active', 6200000, 77500, 'Standard'),
(104, 'GHS-2024-001', 'Precision Medicine Study in Breast Cancer', 4, 1, 'Phase II', 'Interventional', 'Breast Cancer', 'Single Arm', 90, 34, '2024-03-01', '2025-12-31', NULL, 'Recruiting', 5400000, 60000, 'Orphan'),
(105, 'MTD-2023-004', 'Medical Device Study for Cardiac Monitoring', 5, 2, 'Phase III', 'Interventional', 'Cardiac Arrhythmias', 'Randomized Controlled', 200, 156, '2023-11-01', '2025-05-31', NULL, 'Active', 4800000, 24000, 'Standard');

-- Insert sample sites (abbreviated for space)
INSERT INTO DIM_SITES VALUES
(201, 'Memorial Cancer Research Center', 'Site 001', 'Dr. Sarah Johnson', 'Academic Medical Center', 'United States', 'North America', 'Oncology, Hematology', '2023-01-15', 'Tier 1', 25, 4, 8.5, 9.2, 9.0),
(202, 'European Neurological Institute', 'Site 002', 'Dr. Hans Mueller', 'Research Institute', 'Germany', 'Europe', 'CNS, Neurology', '2022-11-20', 'Tier 1', 30, 3, 12.0, 8.8, 9.1),
(203, 'Heart Care Specialists', 'Site 003', 'Dr. Maria Rodriguez', 'Private Practice', 'Spain', 'Europe', 'Cardiovascular', '2023-02-10', 'Tier 2', 15, 2, 6.2, 8.5, 8.7),
(204, 'Precision Medicine Clinic', 'Site 004', 'Dr. Jennifer Chen', 'Academic Medical Center', 'Canada', 'North America', 'Oncology, Precision Medicine', '2023-03-05', 'Tier 2', 18, 2, 5.8, 8.9, 8.8),
(205, 'Advanced Cardiology Center', 'Site 005', 'Dr. Robert Smith', 'Private Practice', 'United States', 'North America', 'Cardiovascular, Device Studies', '2023-01-30', 'Tier 1', 22, 3, 7.5, 9.0, 9.2);

SELECT 'CRO Data Infrastructure Setup Complete!' as status,
       'Database: CRO_AI_DEMO' as database_created,
       'Schema: CLINICAL_OPERATIONS_SCHEMA' as schema_created,
       'Tables: 11 dimension and fact tables' as tables_created;
