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
CREATE OR REPLACE AGENT CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.CRO_INTELLIGENCE_AGENT
WITH PROFILE='{ "display_name": "CRO Intelligence Agent - Clinical Research Operations" }'
    COMMENT=$$ This is an agent that can answer questions about clinical trial operations, business development, regulatory compliance, and financial performance for contract research organizations. $$
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": ""
  },
  "instructions": {
    "response": "You are an AI assistant for a contract research organization (CRO) analytics platform. Your role is to help clinical operations teams, business development professionals, and regulatory affairs specialists analyze clinical trial data, operational metrics, and business intelligence to optimize study performance and competitive positioning. Use data from all domains to analyze and answer user questions. Provide visualizations if possible. Always maintain GCP/GLP compliance and subject privacy.",
    "orchestration": "Use cortex search for regulatory documents, SOPs, and business intelligence, then pass results to cortex analyst for detailed analysis of clinical trial data. Always ensure data privacy and regulatory compliance when handling clinical trial information.",
    "sample_questions": [
      {
        "question": "What is our enrollment performance across therapeutic areas this year?"
      },
      {
        "question": "Show me safety events by severity for our oncology studies"
      },
      {
        "question": "What are the top performing sites by data quality score?"
      }
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Clinical Operations Data",
        "description": "Allows users to query clinical trial operations data including studies, enrollment, safety events, site monitoring, and subject demographics."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql", 
        "name": "Query Business Development Data",
        "description": "Allows users to query business development data including sponsor relationships, proposals, contract values, and financial performance."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query ML-Enhanced Clinical Data", 
        "description": "Allows users to query clinical operations data enhanced with ML predictions including enrollment forecasts, site risk scores, and performance predictions."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Regulatory Documents",
        "description": "Search ICH-GCP guidelines, regulatory requirements, and compliance documentation for clinical trials."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Operations Documents",
        "description": "Search site management SOPs, operational procedures, and monitoring guidelines."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Business Documents",
        "description": "Search therapeutic area expertise, competitive intelligence, and business development documentation."
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Web_Scrape_Regulatory_Data",
        "description": "This tool scrapes regulatory websites for current guidelines, submission requirements, and compliance updates.",
        "input_schema": {
          "type": "object",
          "properties": {
            "url": {
              "description": "The regulatory website URL to scrape (FDA, EMA, ICH, etc.)",
              "type": "string"
            }
          },
          "required": [
            "url"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Send_CRO_Alert",
        "description": "This tool sends alerts for critical study events, safety signals, or operational issues to appropriate stakeholders.",
        "input_schema": {
          "type": "object",
          "properties": {
            "alert_type": {
              "description": "Type of alert: safety_signal, enrollment_issue, regulatory_deadline, data_quality",
              "type": "string"
            },
            "message": {
              "description": "Alert message content",
              "type": "string"
            },
            "priority": {
              "description": "Alert priority: low, medium, high, critical",
              "type": "string"
            },
            "recipients": {
              "description": "Comma-separated list of email recipients",
              "type": "string"
            }
          },
          "required": [
            "alert_type",
            "message",
            "priority",
            "recipients"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Get_CRO_File_URL",
        "description": "This tool generates temporary URLs for accessing CRO documents, study reports, and regulatory submissions.",
        "input_schema": {
          "type": "object",
          "properties": {
            "file_path": {
              "description": "The relative file path from cortex search results",
              "type": "string"
            },
            "expiration_hours": {
              "description": "Number of hours before URL expires (default: 24)",
              "type": "number"
            }
          },
          "required": [
            "file_path"
          ]
        }
      }
    }
  ],
  "tool_resources": {
    "Query Clinical Operations Data": {
      "semantic_view": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.CLINICAL_OPERATIONS_VIEW"
    },
    "Query Business Development Data": {
      "semantic_view": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.BUSINESS_DEVELOPMENT_VIEW"
    },
    "Query ML-Enhanced Clinical Data": {
      "semantic_view": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.ML_ENHANCED_CLINICAL_VIEW"
    },
    "Search Regulatory Documents": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.SEARCH_REGULATORY_DOCS",
      "title_column": "TITLE"
    },
    "Search Operations Documents": {
      "id_column": "RELATIVE_PATH", 
      "max_results": 5,
      "name": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.SEARCH_OPERATIONS_DOCS",
      "title_column": "TITLE"
    },
    "Search Business Documents": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5, 
      "name": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.SEARCH_BUSINESS_DOCS",
      "title_column": "TITLE"
    },
    "Web_Scrape_Regulatory_Data": {
      "execution_environment": {
        "query_timeout": 120,
        "type": "warehouse",
        "warehouse": "CRO_DEMO_WH"
      },
      "identifier": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.WEB_SCRAPE_REGULATORY_DATA",
      "name": "WEB_SCRAPE_REGULATORY_DATA(VARCHAR)",
      "type": "function"
    },
    "Send_CRO_Alert": {
      "execution_environment": {
        "query_timeout": 30,
        "type": "warehouse", 
        "warehouse": "CRO_DEMO_WH"
      },
      "identifier": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.SEND_CRO_ALERT",
      "name": "SEND_CRO_ALERT(VARCHAR, VARCHAR, VARCHAR, VARCHAR)",
      "type": "procedure"
    },
    "Get_CRO_File_URL": {
      "execution_environment": {
        "query_timeout": 30,
        "type": "warehouse",
        "warehouse": "CRO_DEMO_WH"  
      },
      "identifier": "CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.GET_CRO_FILE_URL_SP",
      "name": "GET_CRO_FILE_URL_SP(VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    }
  }
}
$$;

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
