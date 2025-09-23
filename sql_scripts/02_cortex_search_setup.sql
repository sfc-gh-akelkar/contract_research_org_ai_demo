-- ========================================================================
-- CRO Demo - Step 2: Cortex Search Components Setup  
-- Creates document parsing and search services for unstructured data
-- Prerequisites: Run 01_cro_data_setup.sql first
-- ========================================================================

-- Switch to the CRO demo role and database
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- CORTEX SEARCH SERVICES FOR CRO DOCUMENTS
-- ========================================================================

-- Create table for regulatory documents with embedded content
CREATE OR REPLACE TABLE REGULATORY_DOCUMENTS (
    document_id VARCHAR(100) PRIMARY KEY,
    relative_path VARCHAR(500),
    title VARCHAR(200),
    category VARCHAR(50),
    document_type VARCHAR(100),
    content TEXT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create table for operations documents with embedded content
CREATE OR REPLACE TABLE OPERATIONS_DOCUMENTS (
    document_id VARCHAR(100) PRIMARY KEY,
    relative_path VARCHAR(500),
    title VARCHAR(200),
    category VARCHAR(50),
    document_type VARCHAR(100),
    content TEXT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create table for business documents with embedded content
CREATE OR REPLACE TABLE BUSINESS_DOCUMENTS (
    document_id VARCHAR(100) PRIMARY KEY,
    relative_path VARCHAR(500),
    title VARCHAR(200),
    category VARCHAR(50),
    document_type VARCHAR(100),
    content TEXT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Create search service for regulatory documents
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_REGULATORY_DOCS
    ON content
    ATTRIBUTES document_id, relative_path, title, category, document_type
    WAREHOUSE = CRO_DEMO_WH
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            document_id,
            relative_path,
            title,
            category,
            document_type,
            content
        FROM REGULATORY_DOCUMENTS
    );

-- Create search service for operational documents
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_OPERATIONS_DOCS
    ON content
    ATTRIBUTES document_id, relative_path, title, category, document_type
    WAREHOUSE = CRO_DEMO_WH
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            document_id,
            relative_path,
            title,
            category,
            document_type,
            content
        FROM OPERATIONS_DOCUMENTS
    );

-- Create search service for business documents
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_BUSINESS_DOCS
    ON content
    ATTRIBUTES document_id, relative_path, title, category, document_type
    WAREHOUSE = CRO_DEMO_WH
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            document_id,
            relative_path,
            title,
            category,
            document_type,
            content
        FROM BUSINESS_DOCUMENTS
    );

-- ========================================================================
-- VERIFICATION
-- ========================================================================

-- Verify CRO document tables created
SELECT 
    'CRO Document Tables' as component,
    'REGULATORY_DOCUMENTS, OPERATIONS_DOCUMENTS, BUSINESS_DOCUMENTS' as tables_created,
    'Ready for document loading' as status;

-- Count documents in each table (will be 0 until 02a script is run)
SELECT 'Document Count Check' as check_type;
SELECT 'REGULATORY_DOCUMENTS' as table_name, COUNT(*) as document_count 
FROM REGULATORY_DOCUMENTS
UNION ALL
SELECT 'OPERATIONS_DOCUMENTS' as table_name, COUNT(*) as document_count 
FROM OPERATIONS_DOCUMENTS
UNION ALL
SELECT 'BUSINESS_DOCUMENTS' as table_name, COUNT(*) as document_count 
FROM BUSINESS_DOCUMENTS
ORDER BY table_name;

-- Test search services (will work after documents are loaded)
SELECT 'Search Services Test' as test_type;

-- Test regulatory documents search (example query)
SELECT 
    'ICH GCP guidelines clinical trial monitoring' as test_query,
    'SEARCH_REGULATORY_DOCS' as search_service,
    'Ready for testing after document load' as status;

-- Test operations documents search (example query)
SELECT 
    'site management monitoring procedures' as test_query,
    'SEARCH_OPERATIONS_DOCS' as search_service,
    'Ready for testing after document load' as status;

-- Test business documents search (example query)
SELECT 
    'therapeutic area expertise oncology' as test_query,
    'SEARCH_BUSINESS_DOCS' as search_service,
    'Ready for testing after document load' as status;

-- ========================================================================
-- SETUP COMPLETION MESSAGE
-- ========================================================================

SELECT '✅ Step 2 Complete: Cortex Search services and document tables created!' as status;
SELECT 'Next: Run 02a_cro_documents_data.sql to load CRO documents' as next_step;

-- ========================================================================
-- NOTES FOR DEMO
-- ========================================================================

/*
🔍 **CORTEX SEARCH SETUP COMPLETE**

**What was created:**
• REGULATORY_DOCUMENTS table for ICH-GCP guidelines and regulatory content
• OPERATIONS_DOCUMENTS table for site management SOPs and operational procedures  
• BUSINESS_DOCUMENTS table for therapeutic area expertise and competitive analysis
• 3 Cortex Search services for intelligent document retrieval

**Next Steps:**
1. Run 02a_cro_documents_data.sql to load sample documents
2. Test search services with natural language queries
3. Integrate with semantic views for comprehensive analytics

**Search Service Usage:**
After loading documents, you can search using functions like:
- SEARCH_REGULATORY_DOCS('ICH GCP guidelines')
- SEARCH_OPERATIONS_DOCS('site monitoring procedures')  
- SEARCH_BUSINESS_DOCS('oncology expertise competitive analysis')

The search services will automatically index new documents added to the
REGULATORY_DOCUMENTS, OPERATIONS_DOCUMENTS, and BUSINESS_DOCUMENTS tables.

**Key Benefits:**
✅ Intelligent semantic search across CRO documents
✅ Multi-modal AI combining structured data + document intelligence
✅ Natural language queries for regulatory, operational, and business content
✅ Automated indexing and embedding generation
*/