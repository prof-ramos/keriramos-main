/**
 * Terminal UI - JavaScript
 * Interactive functionality for the Astrology API terminal interface
 */

// ============================================
// Navigation
// ============================================
document.addEventListener('DOMContentLoaded', function() {
    const navCommands = document.querySelectorAll('.nav-command');
    const sections = document.querySelectorAll('.terminal-section');

    navCommands.forEach(command => {
        command.addEventListener('click', function(e) {
            e.preventDefault();
            const targetSection = this.dataset.section;

            // Update active nav
            navCommands.forEach(nav => nav.classList.remove('active'));
            this.classList.add('active');

            // Update active section
            sections.forEach(section => section.classList.remove('active'));
            document.getElementById(targetSection).classList.add('active');

            // Update URL hash
            window.location.hash = targetSection;
        });
    });

    // Handle initial hash
    const hash = window.location.hash.substring(1);
    if (hash) {
        const targetNav = document.querySelector(`[data-section="${hash}"]`);
        if (targetNav) {
            targetNav.click();
        }
    }
});

// ============================================
// Documentation Search & Filters
// ============================================
const searchDocs = document.getElementById('search-docs');
const filterChips = document.querySelectorAll('.filter-chip');
const endpointCards = document.querySelectorAll('.endpoints-grid .terminal-card');

// Search functionality
if (searchDocs) {
    searchDocs.addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        filterEndpoints(searchTerm, getActiveFilter());
    });
}

// Filter functionality
filterChips.forEach(chip => {
    chip.addEventListener('click', function() {
        filterChips.forEach(c => c.classList.remove('active'));
        this.classList.add('active');

        const filter = this.dataset.filter;
        const searchTerm = searchDocs ? searchDocs.value.toLowerCase() : '';
        filterEndpoints(searchTerm, filter);
    });
});

function getActiveFilter() {
    const activeChip = document.querySelector('.filter-chip.active');
    return activeChip ? activeChip.dataset.filter : 'all';
}

function filterEndpoints(searchTerm, methodFilter) {
    endpointCards.forEach(card => {
        const method = card.dataset.method;
        const text = card.textContent.toLowerCase();

        const matchesSearch = !searchTerm || text.includes(searchTerm);
        const matchesFilter = methodFilter === 'all' || method === methodFilter;

        if (matchesSearch && matchesFilter) {
            card.style.display = 'block';
            card.classList.add('fade-in');
        } else {
            card.style.display = 'none';
        }
    });
}

// ============================================
// Copy to Clipboard Functionality
// ============================================
const copyButtons = document.querySelectorAll('.copy-btn');

copyButtons.forEach(button => {
    button.addEventListener('click', function() {
        const commandLine = this.closest('.command-line');
        let textToCopy;

        if (commandLine) {
            const commandElement = commandLine.querySelector('.command');
            textToCopy = commandElement.textContent;
        } else {
            // For code blocks
            const codeBlock = this.closest('.code-example');
            if (codeBlock) {
                const codeElement = codeBlock.querySelector('code');
                textToCopy = codeElement.textContent;
            } else {
                // For API key
                const apiKeyDisplay = this.closest('.api-key-display');
                if (apiKeyDisplay) {
                    const apiKeyElement = apiKeyDisplay.querySelector('code');
                    textToCopy = apiKeyElement.textContent;
                }
            }
        }

        if (textToCopy) {
            copyToClipboard(textToCopy);
            showCopyFeedback(this);
        }
    });
});

function copyToClipboard(text) {
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).catch(err => {
            console.error('Failed to copy:', err);
            fallbackCopy(text);
        });
    } else {
        fallbackCopy(text);
    }
}

function fallbackCopy(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
}

function showCopyFeedback(button) {
    const originalText = button.innerHTML;
    button.innerHTML = '✓';
    button.style.background = 'var(--text-success)';
    button.style.color = 'var(--bg-primary)';
    button.style.borderColor = 'var(--text-success)';

    setTimeout(() => {
        button.innerHTML = originalText;
        button.style.background = '';
        button.style.color = '';
        button.style.borderColor = '';
    }, 2000);
}

// ============================================
// Mapa Astral Form
// ============================================
const mapaForm = document.getElementById('mapa-form');
const mapaResult = document.getElementById('mapa-result');
const mapaOutput = document.getElementById('mapa-output');

if (mapaForm) {
    mapaForm.addEventListener('submit', function(e) {
        e.preventDefault();

        const formData = new FormData(this);
        const data = {
            data: formData.get('data'),
            hora: formData.get('hora'),
            local: formData.get('local'),
            latitude: parseFloat(formData.get('latitude')),
            longitude: parseFloat(formData.get('longitude'))
        };

        // Simular chamada API
        setTimeout(() => {
            const mockResponse = generateMapaAstral(data);
            displayMapaResult(mockResponse);
        }, 1000);
    });
}

function generateMapaAstral(data) {
    const signos = ['Áries', 'Touro', 'Gêmeos', 'Câncer', 'Leão', 'Virgem',
                    'Libra', 'Escorpião', 'Sagitário', 'Capricórnio', 'Aquário', 'Peixes'];
    const signoSol = signos[Math.floor(Math.random() * signos.length)];
    const signoLua = signos[Math.floor(Math.random() * signos.length)];
    const ascendente = signos[Math.floor(Math.random() * signos.length)];

    return {
        success: true,
        data: {
            nascimento: data.data,
            hora: data.hora,
            local: data.local,
            coordenadas: `${data.latitude}, ${data.longitude}`,
            signo_solar: signoSol,
            signo_lunar: signoLua,
            ascendente: ascendente,
            elemento_dominante: 'Fogo',
            planeta_regente: 'Marte'
        }
    };
}

function displayMapaResult(response) {
    if (response.success) {
        const data = response.data;
        mapaOutput.innerHTML = `
            <div class="status-item">
                <span class="status-label">Data de Nascimento:</span>
                <span class="status-value">${data.nascimento} às ${data.hora}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Local:</span>
                <span class="status-value">${data.local}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Coordenadas:</span>
                <span class="status-value">${data.coordenadas}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Signo Solar:</span>
                <span class="status-value status-online">♈ ${data.signo_solar}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Signo Lunar:</span>
                <span class="status-value status-online">☽ ${data.signo_lunar}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Ascendente:</span>
                <span class="status-value status-online">⇧ ${data.ascendente}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Elemento Dominante:</span>
                <span class="status-value">${data.elemento_dominante}</span>
            </div>
            <div class="status-item">
                <span class="status-label">Planeta Regente:</span>
                <span class="status-value">${data.planeta_regente}</span>
            </div>
        `;
        mapaResult.style.display = 'block';
    }
}

// ============================================
// Horóscopo Signos
// ============================================
const signoButtons = document.querySelectorAll('.signo-btn');
const horoscopoResult = document.getElementById('horoscopo-result');
const horoscopoOutput = document.getElementById('horoscopo-output');

const horoscopos = {
    aries: 'Hoje é um dia para tomar iniciativa. Sua energia está alta e as oportunidades aparecem para quem está disposto a agir.',
    touro: 'Momento de estabilidade e conforto. Aproveite para cuidar de suas finanças e fortalecer suas bases.',
    gemeos: 'Comunicação em alta! Suas palavras têm poder especial hoje. Use-as com sabedoria.',
    cancer: 'Suas emoções estão à flor da pele. Cuide de quem você ama e de si mesmo também.',
    leao: 'Brilhe com toda sua intensidade! Hoje é seu dia de ser o centro das atenções.',
    virgem: 'Organize, planeje e execute. Sua atenção aos detalhes fará toda a diferença.',
    libra: 'Harmonia e equilíbrio são suas palavras-chave. Busque a justiça em suas relações.',
    escorpiao: 'Sua intensidade está amplificada. Use seu poder de transformação com sabedoria.',
    sagitario: 'Aventura te chama! Expanda seus horizontes e busque novos conhecimentos.',
    capricornio: 'Disciplina e determinação levam ao sucesso. Continue firme em seus objetivos.',
    aquario: 'Sua originalidade está em destaque. Ouse ser diferente e inovar.',
    peixes: 'Sua intuição está aguçada. Confie em seus sentimentos e na sua espiritualidade.'
};

signoButtons.forEach(button => {
    button.addEventListener('click', function() {
        const signo = this.dataset.signo;
        const signoNome = this.querySelector('.signo-name').textContent;
        const signoIcon = this.querySelector('.signo-icon').textContent;

        displayHoroscopo(signoNome, signoIcon, horoscopos[signo]);
    });
});

function displayHoroscopo(nome, icon, texto) {
    horoscopoOutput.innerHTML = `
        <div style="text-align: center; margin-bottom: 1rem;">
            <span style="font-size: 3rem;">${icon}</span>
            <h3 style="color: var(--text-accent); margin: 0.5rem 0;">${nome}</h3>
            <p style="color: var(--text-tertiary); font-size: 0.75rem;">Horóscopo do dia - ${new Date().toLocaleDateString('pt-BR')}</p>
        </div>
        <div style="padding: 1rem; background: var(--bg-tertiary); border-radius: var(--radius-sm); border-left: 3px solid var(--text-accent);">
            <p style="color: var(--text-primary); line-height: 1.6;">${texto}</p>
        </div>
        <div style="margin-top: 1rem; display: flex; gap: 1rem; font-size: 0.75rem;">
            <div style="flex: 1;">
                <strong style="color: var(--text-success);">Amor:</strong> ★★★★☆
            </div>
            <div style="flex: 1;">
                <strong style="color: var(--text-warning);">Trabalho:</strong> ★★★☆☆
            </div>
            <div style="flex: 1;">
                <strong style="color: var(--text-info);">Saúde:</strong> ★★★★★
            </div>
        </div>
    `;
    horoscopoResult.style.display = 'block';
}

// ============================================
// API Playground
// ============================================
const playgroundForm = document.getElementById('playground-form');
const playgroundResult = document.getElementById('playground-result');
const responseStatus = document.getElementById('response-status');
const responseBody = document.getElementById('response-body');

if (playgroundForm) {
    playgroundForm.addEventListener('submit', function(e) {
        e.preventDefault();

        const formData = new FormData(this);
        const requestData = {
            method: formData.get('method'),
            endpoint: formData.get('endpoint'),
            headers: formData.get('headers'),
            body: formData.get('body')
        };

        // Simular chamada API
        setTimeout(() => {
            const mockResponse = simulateAPICall(requestData);
            displayPlaygroundResult(mockResponse);
        }, 1000);
    });
}

function simulateAPICall(request) {
    // Simular resposta baseada no endpoint
    const mockData = {
        '/v1/horoscopo': {
            signo: 'Leão',
            periodo: 'diario',
            data: new Date().toISOString().split('T')[0],
            previsao: 'Brilhe com toda sua intensidade! Hoje é seu dia de ser o centro das atenções.',
            amor: 4,
            trabalho: 5,
            saude: 4
        },
        '/v1/mapa-astral': {
            signo_solar: 'Touro',
            signo_lunar: 'Peixes',
            ascendente: 'Virgem',
            elemento_dominante: 'Terra',
            planeta_regente: 'Vênus'
        },
        '/v1/transitos': {
            data: new Date().toISOString().split('T')[0],
            planetas: [
                { nome: 'Lua', signo: 'Câncer', casa: 4 },
                { nome: 'Sol', signo: 'Escorpião', casa: 8 },
                { nome: 'Mercúrio', signo: 'Escorpião', casa: 8 }
            ]
        }
    };

    const endpoint = request.endpoint.split('?')[0];
    const data = mockData[endpoint] || { message: 'Endpoint encontrado com sucesso' };

    return {
        status: 200,
        statusText: 'OK',
        data: data
    };
}

function displayPlaygroundResult(response) {
    responseStatus.innerHTML = `
        <span class="status-online">Status: ${response.status} ${response.statusText}</span>
    `;
    responseBody.textContent = JSON.stringify(response.data, null, 2);
    playgroundResult.style.display = 'block';
}

// ============================================
// Language Tabs
// ============================================
const langTabs = document.querySelectorAll('.lang-tab');
const codeExamples = document.querySelectorAll('.code-example');

langTabs.forEach(tab => {
    tab.addEventListener('click', function() {
        const lang = this.dataset.lang;

        langTabs.forEach(t => t.classList.remove('active'));
        this.classList.add('active');

        codeExamples.forEach(example => {
            if (example.dataset.lang === lang) {
                example.classList.add('active');
            } else {
                example.classList.remove('active');
            }
        });
    });
});

// ============================================
// Authentication Form
// ============================================
const authForm = document.getElementById('auth-form');
const authResult = document.getElementById('auth-result');
const apiKeyValue = document.getElementById('api-key-value');

if (authForm) {
    authForm.addEventListener('submit', function(e) {
        e.preventDefault();

        // Simular autenticação
        setTimeout(() => {
            const mockApiKey = 'sk_live_' + generateRandomKey(32);
            apiKeyValue.textContent = mockApiKey;
            authResult.style.display = 'block';
        }, 1000);
    });
}

function generateRandomKey(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

// ============================================
// Terminal Cursor Animation
// ============================================
function addTerminalCursor() {
    const inputs = document.querySelectorAll('.terminal-search-input, .terminal-input, .terminal-textarea');
    inputs.forEach(input => {
        input.addEventListener('focus', function() {
            this.style.caretColor = 'var(--text-accent)';
        });
        input.addEventListener('blur', function() {
            this.style.caretColor = '';
        });
    });
}

addTerminalCursor();

// ============================================
// Dynamic Status Updates (Dashboard)
// ============================================
function updateDashboardMetrics() {
    const metricBars = document.querySelectorAll('.metric-fill');

    setInterval(() => {
        metricBars.forEach(bar => {
            const currentWidth = parseInt(bar.style.width);
            const variation = Math.floor(Math.random() * 10) - 5;
            let newWidth = currentWidth + variation;
            newWidth = Math.max(20, Math.min(100, newWidth));
            bar.style.width = newWidth + '%';

            const value = bar.nextElementSibling;
            if (value && value.classList.contains('metric-value')) {
                const newValue = Math.floor(Math.random() * 1000);
                value.textContent = newValue;
            }
        });
    }, 5000);
}

// Initialize dashboard updates
if (document.getElementById('dashboard')) {
    updateDashboardMetrics();
}

// ============================================
// Smooth Scroll for Anchor Links
// ============================================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        const href = this.getAttribute('href');
        if (href !== '#' && href.length > 1) {
            const target = document.querySelector(href);
            if (target && !target.classList.contains('terminal-section')) {
                e.preventDefault();
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        }
    });
});

// ============================================
// Keyboard Shortcuts
// ============================================
document.addEventListener('keydown', function(e) {
    // Ctrl/Cmd + K for search focus
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        const searchInput = document.getElementById('search-docs');
        if (searchInput) {
            searchInput.focus();
        }
    }

    // ESC to clear search
    if (e.key === 'Escape') {
        const searchInput = document.getElementById('search-docs');
        if (searchInput && searchInput.value) {
            searchInput.value = '';
            searchInput.dispatchEvent(new Event('input'));
        }
    }
});

// ============================================
// Console Welcome Message
// ============================================
console.log('%c█████╗ ███████╗████████╗██████╗  ██████╗     ██████╗ ██████╗', 'color: #d97706; font-family: monospace;');
console.log('%c██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗    ██╔══██╗██╔══██╗', 'color: #d97706; font-family: monospace;');
console.log('%c███████║███████╗   ██║   ██████╔╝██║   ██║    ██████╔╝██████╔╝', 'color: #d97706; font-family: monospace;');
console.log('%c██╔══██║╚════██║   ██║   ██╔══██╗██║   ██║    ██╔══██╗██╔══██╗', 'color: #d97706; font-family: monospace;');
console.log('%c██║  ██║███████║   ██║   ██║  ██║╚██████╔╝    ██████╔╝██║  ██║', 'color: #d97706; font-family: monospace;');
console.log('%c╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝     ╚═════╝ ╚═╝  ╚═╝', 'color: #d97706; font-family: monospace;');
console.log('%cAPI de Astrologia Brasileira v1.0.0', 'color: #10b981; font-family: monospace; font-size: 14px;');
console.log('%cDocumentação: https://api.astro.br/docs', 'color: #a0a0a0; font-family: monospace;');
