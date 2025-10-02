-- ========================================================================
-- CRO AI DEMO - COMPLETE SETUP
-- Master script that runs all 4 modular setup scripts in sequence
-- ========================================================================

/*
🧪 CRO AI DEMO - MODULAR SETUP

This demo has been organized into 5 focused scripts for better modularity:

📋 **SCRIPT OVERVIEW:**
1. 📊 01_cro_data_setup.sql            - Database, tables, sample data
2. 🔍 02_cortex_search_setup.sql       - Document search services  
3. 🧠 03_semantic_views_setup.sql      - Natural language query views
4. 🤖 04_agent_setup.sql               - AI agent and custom functions
5. 🤖 05_ml_crawl_phase_setup.sql      - ML models and predictions (Foundation phase)

📋 **EXECUTION OPTIONS:**

**Option A: Run All Scripts Automatically**
Execute this master script to run all 5 scripts in sequence.

**Option B: Run Scripts Individually** 
Execute each script separately for step-by-step setup:
- Allows for testing and validation at each stage
- Easier troubleshooting if issues arise
- Better understanding of each component

**Option C: Custom Setup**
Run only the scripts you need for your specific demo requirements.
*/

-- ========================================================================
-- OPTION A: AUTOMATED COMPLETE SETUP
-- ========================================================================

/*
-- Uncomment the following lines to run all scripts automatically:

-- Step 1: Data Infrastructure
!source 01_cro_data_setup.sql;

-- Step 2: Cortex Search Services
!source 02_cortex_search_setup.sql;

-- Step 2a: Load Document Data
!source 02a_cro_documents_data.sql;

-- Step 3: Semantic Views
!source 03_semantic_views_setup.sql;

-- Step 4: AI Agent Setup
!source 04_agent_setup.sql;

-- Step 5: ML Foundation Phase Setup
!source 05_ml_crawl_phase_setup.sql;

*/

-- ========================================================================
-- MANUAL SETUP INSTRUCTIONS
-- ========================================================================

SELECT '🧪 CRO INTELLIGENCE AI DEMO SETUP' as title;
SELECT '📋 Follow these steps to set up your CRO demo:' as instructions;

SELECT 
    '1️⃣' as step,
    'Run 01_cro_data_setup.sql' as script,
    'Creates database, tables, and sample clinical trial data' as description
UNION ALL
SELECT 
    '2️⃣',
    'Run 02_cortex_search_setup.sql',
    'Sets up document search tables and services'
UNION ALL
SELECT 
    '2️⃣ᵇ',
    'Run 02a_cro_documents_data.sql',
    'Loads CRO documents into Snowflake tables for search'
UNION ALL
SELECT 
    '3️⃣',
    'Run 03_semantic_views_setup.sql', 
    'Creates semantic views for natural language queries'
UNION ALL
SELECT 
    '4️⃣',
    'Run 04_agent_setup.sql',
    'Configures AI agent with CRO-specific capabilities'
UNION ALL
SELECT 
    '5️⃣',
    'Run 05_ml_crawl_phase_setup.sql',
    'Sets up ML models for enrollment prediction and site risk scoring'
UNION ALL
SELECT 
    '🎯',
    'Demo Ready!',
    '15-minute CRO intelligence demo with ML capabilities'
ORDER BY step;

-- ========================================================================
-- PREREQUISITES CHECK
-- ========================================================================

SELECT '🔍 PREREQUISITES CHECK' as check_type;

-- Check if SF_INTELLIGENCE_DEMO role exists
SELECT 
    'SF_INTELLIGENCE_DEMO Role' as requirement,
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.APPLICABLE_ROLES WHERE ROLE_NAME = 'SF_INTELLIGENCE_DEMO')
        THEN '✅ Role exists'
        ELSE '❌ Role missing - will be created'
    END as status
UNION ALL
SELECT 
    'Cortex Features' as requirement,
    '✅ Cortex Analyst and Search required' as status
UNION ALL
SELECT 
    'Demo Duration' as requirement,
    '✅ 15-minute structured demo' as status
UNION ALL
SELECT 
    'Target Audience' as requirement,
    '✅ CRO executives, clinical operations teams' as status;

-- ========================================================================
-- CRO DEMO VALUE PROPOSITION
-- ========================================================================

SELECT '🎯 CRO DEMO VALUE PROPOSITIONS' as section;

SELECT 
    '🧪 Clinical Trial Excellence' as capability,
    '25% faster patient enrollment through predictive site selection' as benefit
UNION ALL
SELECT 
    '⚡ Operational Efficiency',
    '30% improvement in study timeline adherence'
UNION ALL
SELECT 
    '🔬 Business Development Acceleration',
    '50% faster proposal response and competitive analysis'
UNION ALL
SELECT 
    '💰 Financial Performance',
    '$5-10M annually through improved efficiency and timeline adherence'
UNION ALL
SELECT 
    '🔒 Regulatory Excellence',
    '95%+ regulatory submission approval rates'
ORDER BY capability;

SELECT '🚀 Ready to begin CRO Intelligence Demo setup!' as ready_message;
