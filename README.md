# ⚖️ SahiStep

### *The right step, when it matters.*

<p align="center">
  <b>AI-Powered Police Situation Assistance & Awareness Platform</b>
</p>

<p align="center">
  SahiStep helps users understand what to do next during common
  police-related situations through simple, situation-specific guidance.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.x-blue?style=for-the-badge&logo=python" />
  <img src="https://img.shields.io/badge/FastAPI-Backend-009688?style=for-the-badge&logo=fastapi" />
  <img src="https://img.shields.io/badge/PostgreSQL-Database-4169E1?style=for-the-badge&logo=postgresql" />
  <img src="https://img.shields.io/badge/AI--Powered-6A5ACD?style=for-the-badge" />
</p>

---

## 🚨 Why SahiStep?

Being involved in a police-related situation can be stressful, especially when you don't know what to do next.

Legal information is often:

- 📚 Difficult to navigate
- 🧩 Spread across multiple sources
- ⏱️ Time-consuming to understand
- 😕 Difficult to interpret during a stressful situation

**SahiStep turns this complexity into a simple guided experience.**

Instead of searching through pages of information, users can describe or select their situation and get **clear, structured guidance within seconds.**

---

## 💡 What does SahiStep do?

SahiStep is a **situation-based assistance platform**.

The system guides a user through a sequence of relevant questions and uses their responses to determine the appropriate next step.

```text
                 👤 USER
                    │
                    ▼
          ┌───────────────────┐
          │ Select Situation  │
          └─────────┬─────────┘
                    │
                    ▼
          ┌───────────────────┐
          │ Answer Questions  │
          └─────────┬─────────┘
                    │
                    ▼
          ┌───────────────────┐
          │  Decision Engine  │
          └─────────┬─────────┘
                    │
                    ▼
          ┌───────────────────┐
          │  Relevant Guidance│
          └───────────────────┘


          ✨ Key Features
🧭 Situation-Based Guidance

Users can select a relevant police-related situation and receive guidance specific to that scenario.

🌳 Decision-Tree Engine

A structured decision tree determines which questions and responses are relevant based on the user's previous answers.

⚡ Fast Assistance

The system is designed to reduce the time required to find relevant information and provide a useful next step quickly.

📖 Legal Information Layer

Legal documents and relevant information can be associated with situations and responses.

💬 Chatbot Support

The platform maintains chatbot queries and provides a foundation for AI-powered assistance.

🔐 Session Management

User interactions are organized into sessions, allowing the system to maintain context throughout a guided flow.

🏗️ Architecture
                        ┌──────────────┐
                        │     User     │
                        └──────┬───────┘
                               │
                               ▼
                    ┌────────────────────┐
                    │     FastAPI API    │
                    └─────────┬──────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
       ┌────────────┐  ┌────────────┐  ┌────────────┐
       │ Situations │  │ Questions  │  │  Sessions  │
       └────────────┘  └────────────┘  └────────────┘
              │               │
              └───────┬───────┘
                      ▼
              ┌────────────────┐
              │ Decision Tree  │
              │    Engine      │
              └───────┬────────┘
                      │
                      ▼
              ┌────────────────┐
              │   Responses    │
              │ & Legal Data   │
              └────────────────┘
🛠️ Tech Stack
Layer	Technology
Language	Python
Backend	FastAPI
Database	PostgreSQL
API	REST
Decision Engine	Decision Tree
AI Layer	LLM Integration
Configuration	Environment Variables
📂 Project Structure
SahiStep/
│
├── app/
│   ├── db/
│   │   └── schema.sql
│   │
│   ├── routes/
│   │
│   ├── services/
│   │
│   ├── main.py
│   ├── models.py
│   └── __init__.py
│
├── scripts/
│   └── seed_police_stop.sql
│
├── static/
│
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt
🗄️ Database Design

SahiStep uses PostgreSQL to manage the application's structured information.

Main tables
Table	Purpose
situations	Police-related situations
questions	Decision-tree questions
question_options	Available answers
tree_edges	Decision-tree connections
leaf_responses	Final guidance
sessions	User sessions
chatbot_queries	Chatbot interactions
legal_documents	Legal information
🔄 How a Request Flows
User
 │
 ▼
Select Situation
 │
 ▼
Question
 │
 ▼
User Answer
 │
 ▼
Decision Tree
 │
 ├───────────────┐
 │               │
 ▼               ▼
Next Question   Final Response
 │
 ▼
Relevant Guidance

The decision tree allows the system to follow different paths depending on the user's answers rather than providing the same generic response to everyone.

🚀 Getting Started
1. Clone the repository
git clone https://github.com/Shri-agg/SahiStep.git
cd SahiStep
2. Create a virtual environment
python -m venv venv

Activate it on Windows:

venv\Scripts\activate
3. Install dependencies
pip install -r requirements.txt
4. Configure environment variables

Create a .env file from .env.example.

DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/police_rights_navigator
LLM_API_KEY=YOUR_API_KEY

⚠️ Never commit .env or API keys to GitHub.

5. Set up PostgreSQL

Create a PostgreSQL database named:

police_rights_navigator

Run the database schema and seed scripts provided in the repository.

6. Start the backend
uvicorn app.main:app --reload

The API will be available at:

http://127.0.0.1:8000

Interactive API documentation:

http://127.0.0.1:8000/docs
🧪 Current Implementation

The current backend includes infrastructure for:

Situation management
Question and option management
Decision-tree navigation
Leaf-response handling
Session management
Legal document storage
Chatbot query tracking
PostgreSQL persistence
🔮 Future Scope

SahiStep can be extended with:

🤖 More advanced conversational AI
🌐 Multilingual assistance
📄 Retrieval-Augmented Generation (RAG)
🔎 Semantic search over legal documents
🎙️ Voice-based interaction
📱 Mobile-friendly interface
📊 Analytics and feedback-driven improvement
🧠 More comprehensive situation coverage
⚠️ Disclaimer

SahiStep is an information and awareness platform.

The guidance provided by the system is not a substitute for professional legal advice. In emergencies or serious situations, users should contact the appropriate emergency services or qualified professionals.

👩‍💻 Author
Shriya Aggarwal

Computer Science & Engineering
MNNIT Allahabad

⚖️ SahiStep — Helping you take the right step.
