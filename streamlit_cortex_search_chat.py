# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session
import json

# Set page configuration
st.set_page_config(
    page_title="CRO Operations Document Chat",
    page_icon="🔍",
    layout="wide"
)

# Get the current credentials
session = get_active_session()

# App title and description
st.title("🔍 CRO Operations Document Chat")
st.markdown("""
**Chat with your CRO Operations Documents using Cortex Search**

This app lets you search and chat with site management SOPs, operational procedures, 
and monitoring guidelines stored in your CRO operations document repository.
""")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Function to search documents using Cortex Search
def search_operations_docs(query, limit=5):
    """Search the operations documents using Cortex Search service"""
    try:
        # Call the Cortex Search service
        search_sql = f"""
        SELECT SNOWFLAKE.CORTEX.SEARCH(
            'CRO_AI_DEMO.CLINICAL_OPERATIONS_SCHEMA.SEARCH_OPERATIONS_DOCS',
            '{query}',
            {limit}
        ) as search_results
        """
        
        result = session.sql(search_sql).collect()
        
        if result and len(result) > 0:
            search_results = json.loads(result[0]['SEARCH_RESULTS'])
            return search_results
        else:
            return {"results": []}
            
    except Exception as e:
        st.error(f"Error searching documents: {str(e)}")
        return {"results": []}

# Function to format search results for display
def format_search_results(search_results):
    """Format search results for display in chat"""
    if not search_results.get("results"):
        return "No relevant documents found for your query."
    
    formatted_response = "**📚 Found the following relevant documents:**\n\n"
    
    for i, result in enumerate(search_results["results"][:3], 1):  # Show top 3 results
        title = result.get("title", "Untitled Document")
        content_preview = result.get("content", "")[:300] + "..." if len(result.get("content", "")) > 300 else result.get("content", "")
        score = result.get("score", 0)
        
        formatted_response += f"**{i}. {title}**\n"
        formatted_response += f"*Relevance Score: {score:.2f}*\n\n"
        formatted_response += f"{content_preview}\n\n"
        formatted_response += "---\n\n"
    
    return formatted_response

# Function to generate contextual response using Cortex Complete
def generate_contextual_response(user_query, search_results):
    """Generate a contextual response using Cortex Complete with search results"""
    try:
        # Prepare context from search results
        context = ""
        if search_results.get("results"):
            context = "\n\n".join([
                f"Document: {result.get('title', 'Untitled')}\nContent: {result.get('content', '')[:1000]}"
                for result in search_results["results"][:2]  # Use top 2 results for context
            ])
        
        # Create prompt for Cortex Complete
        prompt = f"""
You are an AI assistant specializing in CRO (Contract Research Organization) operations. 
Based on the following operational documents and user question, provide a helpful and accurate response.

CONTEXT FROM CRO OPERATIONS DOCUMENTS:
{context}

USER QUESTION: {user_query}

Please provide a comprehensive answer based on the context provided. If the context doesn't contain enough information to fully answer the question, say so and provide what information you can based on the available documents.

Focus on:
- Specific operational procedures and guidelines
- Compliance requirements and best practices
- Practical implementation steps
- Any relevant regulatory considerations

RESPONSE:
"""
        
        # Use Cortex Complete to generate response
        complete_sql = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'llama3.1-8b',
            '{prompt.replace("'", "''")}'
        ) as response
        """
        
        result = session.sql(complete_sql).collect()
        
        if result and len(result) > 0:
            return result[0]['RESPONSE']
        else:
            return "I apologize, but I couldn't generate a response at this time."
            
    except Exception as e:
        st.error(f"Error generating response: {str(e)}")
        return "I encountered an error while processing your request."

# Chat input
if prompt := st.chat_input("Ask about CRO operations, SOPs, or monitoring procedures..."):
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    # Display user message
    with st.chat_message("user"):
        st.markdown(prompt)
    
    # Generate and display assistant response
    with st.chat_message("assistant"):
        with st.spinner("Searching operations documents..."):
            # Search for relevant documents
            search_results = search_operations_docs(prompt)
            
            # Generate contextual response
            contextual_response = generate_contextual_response(prompt, search_results)
            
            # Display the response
            st.markdown(contextual_response)
            
            # Optionally show the source documents
            with st.expander("📖 Source Documents"):
                if search_results.get("results"):
                    for i, result in enumerate(search_results["results"][:3], 1):
                        st.write(f"**{i}. {result.get('title', 'Untitled Document')}**")
                        st.write(f"Relevance Score: {result.get('score', 0):.2f}")
                        st.write(f"Preview: {result.get('content', '')[:200]}...")
                        st.write("---")
                else:
                    st.write("No source documents found.")
    
    # Add assistant response to chat history
    st.session_state.messages.append({"role": "assistant", "content": contextual_response})

# Sidebar with example queries
with st.sidebar:
    st.header("💡 Example Questions")
    st.markdown("""
    **Operational Procedures:**
    - What are the site monitoring requirements?
    - How do we handle protocol deviations?
    - What is the process for investigator qualification?
    
    **Data Management:**
    - What are the data quality standards?
    - How should we handle missing data?
    - What are the source data verification requirements?
    
    **Regulatory Compliance:**
    - What are the GCP requirements for site management?
    - How do we prepare for regulatory inspections?
    - What documentation is required for site close-out?
    
    **Site Management:**
    - What is the site selection criteria?
    - How do we manage investigator communications?
    - What are the site performance metrics?
    """)
    
    st.header("🔧 Search Settings")
    search_limit = st.slider("Number of documents to search", 1, 10, 5)
    
    if st.button("Clear Chat History"):
        st.session_state.messages = []
        st.rerun()

# Footer
st.markdown("---")
st.markdown("""
**About this app:** This Streamlit application uses Snowflake's Cortex Search to find relevant 
CRO operations documents and Cortex Complete to generate contextual responses based on your 
organization's specific procedures and guidelines.
""")
