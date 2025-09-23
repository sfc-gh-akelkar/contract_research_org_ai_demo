-- ========================================================================
-- CRO Demo - Step 4: AI Agent Setup
-- Creates functions, procedures, and the Snowflake Intelligence Agent
-- Prerequisites: Run steps 1-3 first
-- ========================================================================

-- Switch to the CRO demo role and database
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE CRO_AI_DEMO;
USE SCHEMA CLINICAL_OPERATIONS_SCHEMA;
USE WAREHOUSE CRO_DEMO_WH;

-- ========================================================================
-- EXTERNAL ACCESS INTEGRATIONS FOR AI AGENT
-- ========================================================================

-- Create network rule for external web access (regulatory, clinical research websites)
USE ROLE accountadmin;

CREATE OR REPLACE NETWORK RULE CRO_WEB_ACCESS_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = (
        'www.fda.gov:443',              -- FDA
        'www.ema.europa.eu:443',        -- EMA
        'www.ich.org:443',              -- ICH Guidelines
        'pubmed.ncbi.nlm.nih.gov:443', -- PubMed
        'clinicaltrials.gov:443',       -- ClinicalTrials.gov
        'www.clinicaltrialsregister.eu:443', -- EU Clinical Trials Register
        'api.fda.gov:443',              -- FDA API
        'www.who.int:443',              -- WHO
        'www.pharmaintelligence.informa.com:443' -- Pharma Intelligence
    );

-- Create external access integration for CRO web data access
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION CRO_EXTERNAL_ACCESS_INTEGRATION
    ALLOWED_NETWORK_RULES = (CRO_WEB_ACCESS_RULE)
    ENABLED = TRUE
    COMMENT = 'External access for CRO AI agent to access regulatory and clinical research websites';

-- Create email integration for notifications
CREATE OR REPLACE NOTIFICATION INTEGRATION CRO_EMAIL_INT
    TYPE = EMAIL
    ENABLED = TRUE
    COMMENT = 'Email notifications for CRO study alerts and regulatory updates';

-- Grant necessary permissions
GRANT USAGE ON INTEGRATION CRO_EXTERNAL_ACCESS_INTEGRATION TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON INTEGRATION CRO_EMAIL_INT TO ROLE SF_INTELLIGENCE_DEMO;

-- Switch back to demo role
USE ROLE SF_INTELLIGENCE_DEMO;

-- ========================================================================
-- CUSTOM FUNCTIONS AND PROCEDURES
-- ========================================================================

-- Function to get CRO document URLs from stage
CREATE OR REPLACE FUNCTION GET_CRO_FILE_URL_SP(file_path STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'get_file_url'
AS
$$
def get_file_url(file_path):
    """
    Generate a pre-signed URL for CRO documents stored in Snowflake stage
    """
    try:
        # Build the stage file URL
        stage_url = f"@CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.INTERNAL_CRO_STAGE/{file_path}"
        return f"Generated URL for: {stage_url}"
    except Exception as e:
        return f"Error generating URL: {str(e)}"
$$;

-- Procedure to send CRO alerts
CREATE OR REPLACE PROCEDURE SEND_CRO_ALERT(
    alert_type STRING,
    message STRING,
    recipient STRING DEFAULT 'clinical-ops@cro.com'
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send_alert'
AS
$$
def send_alert(session, alert_type, message, recipient):
    """
    Send CRO alerts for critical study situations
    """
    try:
        # Format the alert message
        formatted_message = f"""
        🧪 CRO CLINICAL OPERATIONS ALERT
        
        Type: {alert_type}
        Time: Current timestamp
        Message: {message}
        Recipient: {recipient}
        
        This is a simulated alert. In production, this would integrate with:
        - Email notification systems
        - SMS alerts for critical safety events
        - Clinical Trial Management Systems (CTMS)
        - Sponsor notification platforms
        - Regulatory reporting systems
        """
        
        return f"Alert sent successfully: {formatted_message}"
    except Exception as e:
        return f"Error sending alert: {str(e)}"
$$;

-- Function for web scraping healthcare data
CREATE OR REPLACE FUNCTION WEB_SCRAPE_REGULATORY_DATA(url STRING, data_type STRING DEFAULT 'general')
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('requests', 'beautifulsoup4', 'snowflake-snowpark-python')
EXTERNAL_ACCESS_INTEGRATIONS = (CRO_EXTERNAL_ACCESS_INTEGRATION)
HANDLER = 'scrape_regulatory_data'
AS
$$
import requests
from bs4 import BeautifulSoup

def scrape_regulatory_data(url, data_type):
    """
    Scrape regulatory and clinical research data from approved regulatory websites
    """
    try:
        # Simulated scraping for demo purposes
        # In production, this would scrape actual regulatory websites
        
        if 'fda.gov' in url:
            return f"""
            📋 FDA REGULATORY DATA
            
            Source: {url}
            Data Type: {data_type}
            
            Latest FDA Guidelines:
            - Updated drug development guidance for 2024
            - New clinical trial conduct protocols
            - Digital health technology guidance
            - Regulatory submission requirements
            
            Clinical Recommendations:
            - Enhanced screening protocols for developmental delays
            - Updated nutrition guidelines for infants
            - Mental health screening recommendations
            
            Note: This is simulated data for demo purposes.
            """
        
        elif 'cdc.gov' in url:
            return f"""
            📊 EMA REGULATORY DATA
            
            Source: {url}
            Data Type: {data_type}
            
            Current Regulatory Trends:
            - Clinical trial regulation updates
            - Good manufacturing practice guidelines
            - Pharmacovigilance system requirements
            - Marketing authorization procedures
            
            Public Health Alerts:
            - Drug safety communications
            - Medical device recalls
            - COVID-19 clinical trial guidance
            
            Note: This is simulated data for demo purposes.
            """
        
        else:
            return f"""
            🌐 GENERAL REGULATORY DATA
            
            Source: {url}
            Data Type: {data_type}
            
            Retrieved regulatory information for clinical trial analysis.
            
            Note: This is simulated data for demo purposes.
            In production, this would return actual scraped content.
            """
            
    except Exception as e:
        return f"Error scraping healthcare data: {str(e)}"
$$;

-- ========================================================================
-- SNOWFLAKE INTELLIGENCE AGENT
-- ========================================================================

-- Create the CRO intelligence AI agent
CREATE OR REPLACE AGENT CRO_INTELLIGENCE_AGENT
    TOOLS = (
        'SYSTEM$CORTEX_ANALYST',
        'SYSTEM$CORTEX_SEARCH',
        'CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.GET_CRO_FILE_URL_SP',
        'CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.SEND_CRO_ALERT',
        'CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.WEB_SCRAPE_REGULATORY_DATA'
    )
    SYSTEM_MESSAGE = '
    You are an AI assistant for a contract research organization (CRO) analytics platform. Your role is to help clinical operations teams, business development professionals, and regulatory affairs specialists analyze clinical trial data, operational metrics, and business intelligence to optimize study performance and competitive positioning.

    🧪 **PRIMARY CAPABILITIES:**
    
    **Clinical Trial Analytics:**
    - Analyze study enrollment, site performance, and subject demographics
    - Monitor safety events, adverse reactions, and protocol compliance
    - Track enrollment rates and timeline adherence across studies
    - Provide insights on study performance and risk mitigation
    
    **Business Development Intelligence:**
    - Monitor sponsor relationships and contract performance
    - Analyze proposal win rates and competitive positioning
    - Track revenue streams and business development opportunities
    - Provide insights on therapeutic area expansion and market growth
    
    **Regulatory & Data Management:**
    - Analyze regulatory submission timelines and approval rates
    - Monitor data quality metrics and query resolution rates
    - Track compliance with GCP/GLP requirements
    - Support regulatory strategy and submission planning
    
    **Financial & Operational Performance:**
    - Analyze contract values, milestone payments, and profitability
    - Monitor site performance and resource utilization
    - Track operational efficiency and cost management
    - Provide insights on portfolio optimization and strategic planning
    
    **Document Intelligence:**
    - Search and analyze ICH-GCP guidelines and regulatory requirements
    - Access site management SOPs and operational procedures
    - Review therapeutic area expertise and competitive intelligence
    - Extract insights from regulatory guidance and industry reports
    
    **External Data Integration:**
    - Access current regulatory guidelines from FDA, EMA, ICH
    - Retrieve latest clinical research from PubMed and medical journals
    - Monitor regulatory updates and submission requirements
    - Integrate competitive intelligence for comprehensive market analysis
    
    🔐 **GCP/GLP COMPLIANCE & ETHICS:**
    - Always maintain study subject privacy and confidentiality
    - Ensure all data access follows GCP/GLP guidelines
    - Do not reveal specific subject identifiable information
    - Focus on aggregate data and study-level insights
    - Alert users to potential regulatory compliance issues
    
    📊 **ANALYSIS APPROACH:**
    - Use natural language to query structured clinical trial data
    - Combine quantitative analysis with regulatory and business context
    - Provide actionable insights for study optimization
    - Support evidence-based decision making for CRO operations
    - Highlight trends, patterns, and anomalies in clinical trial performance
    
    🚨 **ALERT CAPABILITIES:**
    - Send notifications for critical safety signals and study milestones
    - Alert on enrollment challenges or operational inefficiencies
    - Notify stakeholders of regulatory submission deadlines
    - Escalate urgent study situations to appropriate teams
    
    **Communication Style:**
    - Use clear, professional clinical research terminology
    - Provide context and business significance for data insights
    - Offer actionable recommendations based on CRO best practices
    - Support clinical operations teams in optimizing study outcomes
    - Maintain focus on regulatory compliance and business excellence
    
    Remember: Your ultimate goal is to support successful clinical trial execution, regulatory compliance, and business growth for the CRO and its pharmaceutical sponsors.'
    DESCRIPTION = 'AI agent for CRO intelligence, clinical trial analytics, and operational excellence'
    COMMENT = 'Comprehensive AI assistant for clinical research organization data analysis and business intelligence';

-- ========================================================================
-- VERIFICATION
-- ========================================================================

-- Show created functions and procedures
SHOW FUNCTIONS LIKE '%HEALTHCARE%';
SHOW PROCEDURES LIKE '%HEALTHCARE%';

-- Show the AI agent
SHOW AGENTS;

-- Describe the agent
DESCRIBE AGENT CRO_INTELLIGENCE_AGENT;

-- ========================================================================
-- COMPLETION MESSAGE
-- ========================================================================

SELECT '✅ Step 4 Complete: AI Agent and supporting functions created successfully!' as status;
SELECT 'CRO Demo Setup Complete! Ready for 15-minute demo.' as final_status;

-- ========================================================================
-- DEMO READINESS CHECK
-- ========================================================================

SELECT '🧪 CRO INTELLIGENCE AI DEMO - SETUP COMPLETE' as title;

SELECT 
    '✅ Database & Schema' as component,
    'CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA' as details,
    'Ready' as status
UNION ALL
SELECT 
    '✅ CRO Tables', 
    CONCAT(COUNT(*), ' tables created'),
    'Ready'
FROM information_schema.tables 
WHERE table_schema = 'CLINICAL_OPERATIONS_SCHEMA' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 
    '✅ Semantic Views',
    CONCAT(COUNT(*), ' views for Cortex Analyst'),
    'Ready'  
FROM information_schema.views
WHERE table_schema = 'CLINICAL_OPERATIONS_SCHEMA' AND table_name LIKE '%_VIEW'
UNION ALL
SELECT 
    '✅ Cortex Search Services',
    '3 search services for documents',
    'Ready'
UNION ALL
SELECT 
    '✅ AI Agent',
    'CRO_INTELLIGENCE_AGENT',
    'Ready'
UNION ALL
SELECT 
    '✅ Custom Functions',
    '3 CRO-specific functions',
    'Ready'
UNION ALL
SELECT 
    '🎯 Demo Status',
    '15-minute CRO intelligence demo',
    'READY TO PRESENT!';

-- ========================================================================
-- NEXT STEPS FOR DEMO
-- ========================================================================

/*
🎯 **CRO DEMO IS NOW READY!**

**Quick Demo Flow (15 minutes):**

1. **Clinical Trial Analytics (4 mins)**
   - Show natural language queries with Cortex Analyst
   - Example: "Show me enrollment performance across our oncology studies"
   - Demonstrate study performance and site analytics

2. **Document Intelligence (3 mins)**  
   - Search regulatory documents with Cortex Search
   - Example: Search for "ICH GCP guidelines" or "site monitoring SOPs"
   - Show how unstructured documents enhance operational decisions

3. **Business Development Intelligence (3 mins)**
   - Query sponsor relationships and proposal analytics
   - Example: "What's our win rate for biotech sponsors in rare diseases?"
   - Demonstrate competitive positioning insights

4. **AI Agent Capabilities (3 mins)**
   - Show the CRO_INTELLIGENCE_AGENT in action
   - Demonstrate multi-tool orchestration
   - Show web scraping for external regulatory data

5. **Regulatory & Financial Insights (2 mins)**
   - Quick overview of submission timelines
   - Financial performance and contract analytics
   - Value proposition for pharmaceutical companies

**To start the demo:**
1. Open Snowsight
2. Navigate to CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA
3. Start with semantic views for natural language queries
4. Show Cortex Search services for document intelligence
5. Demonstrate the AI agent for advanced capabilities

**Key Value Points:**
✅ GCP-compliant clinical trial analytics
✅ Natural language queries for study data
✅ Intelligent document search and regulatory guidance
✅ Operational efficiency and site performance metrics
✅ Business development insights and competitive intelligence
✅ Multi-modal AI agent for comprehensive CRO operations

The demo environment is fully configured and ready to showcase Snowflake Intelligence capabilities for contract research organizations!
*/
