import os
import streamlit as st
from openai import OpenAI

st.set_page_config(page_title="ChatGPT", page_icon="💬", layout="centered")
st.title("💬 ChatGPT")

api_key = os.environ.get("OPENAI_API_KEY")

# Initialise chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Sidebar — model selection only
with st.sidebar:
    st.header("Settings")
    model = st.selectbox(
        "Model",
        ["gpt-5.4-nano","gpt-5.4-mini","gpt-5.4"],
        index=0,
    )
    if st.button("Clear chat"):
        st.session_state.messages = []
        st.rerun()

# Render existing messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Chat input
if prompt := st.chat_input("Message ChatGPT..."):
    if not api_key:
        st.error("OPENAI_API_KEY is not configured on the server.")
        st.stop()

    # Append and display user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # Stream the assistant response
    client = OpenAI(api_key=api_key)
    with st.chat_message("assistant"):
        response_placeholder = st.empty()
        full_response = ""
        stream = client.chat.completions.create(
            model=model,
            messages=st.session_state.messages,
            stream=True,
        )
        for chunk in stream:
            delta = chunk.choices[0].delta.content or ""
            full_response += delta
            response_placeholder.markdown(full_response + "▌")
        response_placeholder.markdown(full_response)

    st.session_state.messages.append({"role": "assistant", "content": full_response})
