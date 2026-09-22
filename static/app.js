const API_BASE = '/api';

const state = {
    currentSessionId: null,
    currentSituationId: null,
};

// UI Controller
const ui = {
    container: document.getElementById('app-container'),
    fab: document.getElementById('chatbot-fab'),

    showLoader() {
        this.container.innerHTML = `
            <div class="loader-container">
                <div class="loader"></div>
                <p style="margin-top: 1rem; color: var(--text-muted);">Loading...</p>
            </div>
        `;
    },

    showHome(situations) {
        this.fab.classList.remove('hidden');
        let html = `
            <div class="view active" id="home-view">
                <h2 style="margin-bottom: 0.5rem;">What is your situation?</h2>
                <p style="color: var(--text-muted); margin-bottom: 1.5rem;">Select an option below to get immediate guidance on your rights.</p>
                <div class="situation-grid">
        `;

        situations.forEach(sit => {
            html += `
                <div class="situation-card" onclick="startSituation('${sit.situation_id}')">
                    <div class="card-icon"><i class="${sit.icon || 'fa-solid fa-circle-info'}"></i></div>
                    <div class="card-title">${sit.title}</div>
                </div>
            `;
        });

        html += `
                </div>
            </div>
        `;
        this.container.innerHTML = html;
    },

    showQuestion(data) {
        this.fab.classList.remove('hidden');
        let html = `
            <div class="view active" id="question-view">
                <div class="chat-header" style="background: transparent; padding: 0 0 1rem 0; border: none; margin-bottom: 1rem;">
                    <i class="fa-solid fa-arrow-left back-btn" onclick="loadHome()"></i>
                    <span>Back</span>
                </div>
                <div class="question-container">
                    <div class="question-text">${data.question_text}</div>
                    ${data.help_text ? `<div class="question-help">${data.help_text}</div>` : ''}
                    <div class="options-list">
        `;

        data.options.forEach(opt => {
            html += `
                <button class="option-btn" onclick="answerQuestion('${data.question_id}', '${opt.option_id}')">
                    <span>${opt.option_label}</span>
                    <i class="fa-solid fa-chevron-right"></i>
                </button>
            `;
        });

        html += `
                    </div>
                </div>
                <div class="not-listed">
                    <p style="color: var(--text-muted); margin-bottom: 0.5rem; font-size: 0.9rem;">Situation not matching these options?</p>
                    <button class="btn-secondary" onclick="ui.showChatbot(true)">Describe it to our Chatbot</button>
                </div>
            </div>
        `;
        this.container.innerHTML = html;
    },

    showLeaf(data, isVerified) {
        this.fab.classList.remove('hidden');
        
        let warningHtml = '';
        if (!isVerified) {
            warningHtml = `
                <div class="warning-banner">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.5rem;"></i>
                    <div>
                        <strong>Unverified Output</strong><br>
                        This specific situation hasn't been verified by legal professionals yet. Use as general guidance only.
                    </div>
                </div>
            `;
        }

        let html = `
            <div class="view active" id="leaf-view">
                <div class="chat-header" style="background: transparent; padding: 0 0 1rem 0; border: none; margin-bottom: 1rem;">
                    <i class="fa-solid fa-home back-btn" onclick="loadHome()"></i>
                    <span>Start Over</span>
                </div>
                ${warningHtml}
                <div class="result-header">
                    <div class="result-icon"><i class="fa-solid fa-shield-halved"></i></div>
                    <h2 class="result-title">Your Guidance</h2>
                </div>
        `;

        if (data.your_rights && data.your_rights.length > 0) {
            let rightsHtml = data.your_rights.map(r => `<li>${r}</li>`).join('');
            html += `
                <div class="result-section">
                    <h3><i class="fa-solid fa-scale-balanced"></i> Your Rights</h3>
                    <ul>${rightsHtml}</ul>
                </div>
            `;
        }

        if (data.what_to_do_now && data.what_to_do_now.length > 0) {
            let actionsHtml = data.what_to_do_now.map(a => `<li>${a}</li>`).join('');
            html += `
                <div class="result-section">
                    <h3><i class="fa-solid fa-person-walking-arrow-right"></i> What to do now</h3>
                    <ul>${actionsHtml}</ul>
                </div>
            `;
        }

        if (data.sources && data.sources.length > 0) {
            let sourcesHtml = data.sources.map(s => {
                if (typeof s === 'string') return `<li>${s}</li>`;
                let link = (s.url && s.url !== 'TBD') ? `<a href="${s.url}" target="_blank">${s.document}</a>` : s.document;
                return `<li><strong>${link}</strong> (Section: ${s.section})</li>`;
            }).join('');
            html += `
                <div class="result-section">
                    <h3><i class="fa-solid fa-book"></i> Sources</h3>
                    <ul>${sourcesHtml}</ul>
                </div>
            `;
        }

        html += `</div>`;
        this.container.innerHTML = html;
    },

    showChatbot(fromTree = false) {
        this.fab.classList.add('hidden');
        const html = `
            <div class="view active" id="chat-view">
                <div class="chat-container">
                    <div class="chat-header">
                        <i class="fa-solid fa-arrow-left back-btn" onclick="${fromTree ? 'loadHome()' : 'loadHome()'}"></i>
                        <span>Describe your situation</span>
                    </div>
                    <div class="chat-messages" id="chat-messages">
                        <div class="message bot">
                            Please briefly describe what happened or what your situation is, and I will find the best guidance for you.
                        </div>
                    </div>
                    <div class="chat-input-area">
                        <input type="text" id="chat-input" placeholder="Type your situation here..." onkeypress="if(event.key === 'Enter') sendChatMessage()">
                        <button onclick="sendChatMessage()">
                            <i class="fa-solid fa-paper-plane"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;
        this.container.innerHTML = html;
        document.getElementById('chat-input').focus();
    },

    appendChatMessage(text, sender) {
        const msgs = document.getElementById('chat-messages');
        const div = document.createElement('div');
        div.className = `message ${sender}`;
        div.textContent = text;
        msgs.appendChild(div);
        msgs.scrollTop = msgs.scrollHeight;
    },

    appendChatLoader() {
        const msgs = document.getElementById('chat-messages');
        const div = document.createElement('div');
        div.className = `message bot loader-msg`;
        div.innerHTML = `<div class="loader" style="width: 16px; height: 16px; border-width: 2px;"></div>`;
        msgs.appendChild(div);
        msgs.scrollTop = msgs.scrollHeight;
    },

    removeChatLoader() {
        const loader = document.querySelector('.loader-msg');
        if (loader) loader.remove();
    }
};


// API Interactions
async function fetchJSON(url, options = {}) {
    try {
        const res = await fetch(url, options);
        const data = await res.json();
        if (!res.ok) throw new Error(data.detail || 'API Error');
        return data;
    } catch (err) {
        alert(err.message);
        throw err;
    }
}

async function loadHome() {
    ui.showLoader();
    try {
        const data = await fetchJSON(`${API_BASE}/situations`);
        ui.showHome(data.situations);
    } catch (e) {
        ui.container.innerHTML = `<div style="color:red; padding: 2rem;">Error loading situations. Make sure the backend is running.</div>`;
    }
}

async function startSituation(situationId) {
    ui.showLoader();
    state.currentSituationId = situationId;
    try {
        const data = await fetchJSON(`${API_BASE}/interact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'start',
                situation_id: situationId
            })
        });
        
        state.currentSessionId = data.session_id;
        handleInteractResponse(data);
    } catch (e) {
        loadHome();
    }
}

async function answerQuestion(questionId, optionId) {
    ui.showLoader();
    try {
        const data = await fetchJSON(`${API_BASE}/interact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'answer',
                session_id: state.currentSessionId,
                question_id: questionId,
                option_id: optionId
            })
        });
        
        handleInteractResponse(data);
    } catch (e) {
        loadHome();
    }
}

async function sendChatMessage() {
    const input = document.getElementById('chat-input');
    const text = input.value.trim();
    if (!text) return;

    input.value = '';
    ui.appendChatMessage(text, 'user');
    ui.appendChatLoader();

    try {
        const data = await fetchJSON(`${API_BASE}/interact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'chatbot',
                session_id: state.currentSessionId, // might be null, backend handles it
                situation_id: state.currentSituationId,
                text: text,
                entry_point: state.currentSessionId ? 'mid_tree_stuck' : 'homescreen'
            })
        });
        
        ui.removeChatLoader();
        
        if (data.type === 'leaf') {
            ui.showLeaf(data.data, data.is_verified);
        } else {
            ui.appendChatMessage("I'm sorry, I couldn't process that properly.", 'bot');
        }

    } catch (e) {
        ui.removeChatLoader();
        ui.appendChatMessage("Error communicating with server.", 'bot');
    }
}

function handleInteractResponse(res) {
    if (res.type === 'question') {
        ui.showQuestion(res.data);
    } else if (res.type === 'leaf') {
        ui.showLeaf(res.data, res.is_verified);
    } else if (res.type === 'error') {
        if (res.data.suggest_chatbot) {
            ui.showChatbot(true);
            ui.appendChatMessage("It seems your situation is unique and not fully covered by the predefined options. Please describe what happened.", 'bot');
        } else {
            alert("An error occurred: " + res.data.reason);
            loadHome();
        }
    }
}

// Init
window.onload = loadHome;
