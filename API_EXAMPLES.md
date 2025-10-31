# Exemplos Práticos da API de Astrologia Brasileira

## 1. Gerar Mapa Astral Natal

### Python
```python
import requests

# Usando JWT Token
headers = {
    'Authorization': 'Bearer YOUR_JWT_TOKEN',
    'Content-Type': 'application/json'
}

data = {
    "name": "João Silva",
    "birth_date": "15/05/1990",
    "birth_time": "18:30",
    "city": "São Paulo",
    "state": "SP"
}

response = requests.post(
    'https://api.astrologia.br/api/v2/charts/natal',
    json=data,
    headers=headers
)

chart = response.json()
print(f"Signo Solar: {chart['sun_sign']}")
print(f"Signo Lunar: {chart['moon_sign']}")
print(f"Ascendente: {chart['rising_sign']}")
```

### JavaScript (Node.js)
```javascript
const axios = require('axios');

async function createNatalChart() {
    try {
        const response = await axios.post(
            'https://api.astrologia.br/api/v2/charts/natal',
            {
                name: "João Silva",
                birth_date: "15/05/1990",
                birth_time: "18:30",
                city: "São Paulo",
                state: "SP",
                include_charts: true
            },
            {
                headers: {
                    'Authorization': 'Bearer YOUR_JWT_TOKEN',
                    'Content-Type': 'application/json'
                }
            }
        );

        const chart = response.data;
        console.log(`Signo Solar: ${chart.sun_sign}`);
        console.log(`Signo Lunar: ${chart.moon_sign}`);

        // Salvar gráfico SVG
        if (chart.charts && chart.charts.svg) {
            require('fs').writeFileSync('mapa_astral.svg', chart.charts.svg);
        }
    } catch (error) {
        console.error('Erro:', error.response.data);
    }
}

createNatalChart();
```

### JavaScript (Browser)
```javascript
async function createNatalChart() {
    const response = await fetch('https://api.astrologia.br/api/v2/charts/natal', {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer YOUR_JWT_TOKEN',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            name: "João Silva",
            birth_date: "15/05/1990",
            birth_time: "18:30",
            city: "São Paulo",
            state: "SP"
        })
    });

    if (response.ok) {
        const chart = await response.json();
        document.getElementById('resultado').innerHTML = `
            <h2>Mapa Astral de ${chart.name}</h2>
            <p><strong>Signo Solar:</strong> ${chart.sun_sign}</p>
            <p><strong>Signo Lunar:</strong> ${chart.moon_sign}</p>
            <p><strong>Ascendente:</strong> ${chart.rising_sign}</p>
        `;

        // Exibir gráfico
        if (chart.charts && chart.charts.svg) {
            document.getElementById('chart-container').innerHTML = chart.charts.svg;
        }
    } else {
        const error = await response.json();
        alert(`Erro: ${error.message}`);
    }
}
```

### cURL
```bash
# Gerar mapa natal
curl -X POST https://api.astrologia.br/api/v2/charts/natal \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "birth_date": "15/05/1990",
    "birth_time": "18:30",
    "city": "São Paulo",
    "state": "SP",
    "include_charts": true
  }'

# Salvar gráfico em arquivo
curl -X POST https://api.astrologia.br/api/v2/charts/natal \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "João", "birth_date": "15/05/1990", "birth_time": "18:30", "city": "São Paulo", "state": "SP"}' \
  | jq -r '.charts.svg' > mapa_astral.svg
```

## 2. Autenticação e Gerenciamento de Usuários

### Registro de Usuário
```python
import requests

response = requests.post('https://api.astrologia.br/api/v2/auth/register', json={
    "email": "joao.silva@email.com",
    "password": "senhaSegura123",
    "name": "João Silva",
    "plan": "free"
})

if response.status_code == 201:
    user = response.json()
    print(f"Usuário criado: {user['user_id']}")
else:
    print(f"Erro: {response.json()}")
```

### Login e Uso de Token
```python
import requests

# Fazer login
login_response = requests.post('https://api.astrologia.br/api/v2/auth/login', json={
    "email": "joao.silva@email.com",
    "password": "senhaSegura123"
})

if login_response.status_code == 200:
    tokens = login_response.json()
    access_token = tokens['access_token']

    # Usar token para fazer requests autenticados
    headers = {'Authorization': f'Bearer {access_token}'}

    # Obter perfil
    profile = requests.get('https://api.astrologia.br/api/v2/users/profile', headers=headers)
    print(f"Nome: {profile.json()['name']}")

    # Gerar mapa astral
    chart_response = requests.post('https://api.astrologia.br/api/v2/charts/natal',
        json={
            "name": "João Silva",
            "birth_date": "15/05/1990",
            "birth_time": "18:30",
            "city": "São Paulo",
            "state": "SP"
        },
        headers=headers
    )

    chart = chart_response.json()
    print(f"Signo Solar: {chart['sun_sign']}")
```

## 3. Busca de Localizações

### Buscar Cidades
```python
import requests

# Buscar cidades
response = requests.get('https://api.astrologia.br/api/v2/locations/cities', params={
    'q': 'São Paulo',
    'state': 'SP',
    'limit': 5
})

cities = response.json()
for city in cities['cities']:
    print(f"{city['name']}, {city['state']} - População: {city['population']}")
```

### Obter Timezone por Estado
```python
import requests

response = requests.get('https://api.astrologia.br/api/v2/locations/timezones', params={
    'state': 'SP'
})

timezone_info = response.json()
print(f"Estado: {timezone_info['state']}")
print(f"Timezone: {timezone_info['timezone']}")
print(f"Offset UTC: {timezone_info['utc_offset']}")
```

## 4. Operações em Lote

### Gerar Múltiplos Mapas
```python
import requests

# Preparar dados para lote
batch_data = {
    "requests": [
        {
            "name": "João Silva",
            "birth_date": "15/05/1990",
            "birth_time": "18:30",
            "city": "São Paulo",
            "state": "SP"
        },
        {
            "name": "Maria Santos",
            "birth_date": "22/08/1985",
            "birth_time": "14:15",
            "city": "Rio de Janeiro",
            "state": "RJ"
        },
        {
            "name": "Pedro Oliveira",
            "birth_date": "10/12/1992",
            "birth_time": "09:45",
            "city": "Belo Horizonte",
            "state": "MG"
        }
    ],
    "callback_url": "https://myapp.com/webhook/batch-complete"
}

headers = {'Authorization': 'Bearer YOUR_JWT_TOKEN'}

# Enviar lote
response = requests.post(
    'https://api.astrologia.br/api/v2/batch/charts',
    json=batch_data,
    headers=headers
)

if response.status_code == 202:
    batch_info = response.json()
    batch_id = batch_info['batch_id']
    print(f"Lote enviado: {batch_id}")

    # Verificar status
    import time
    while True:
        status_response = requests.get(
            f'https://api.astrologia.br/api/v2/batch/status/{batch_id}',
            headers=headers
        )
        status = status_response.json()

        print(f"Status: {status['status']}")
        print(f"Progresso: {status['progress']['completed']}/{status['progress']['total']}")

        if status['status'] == 'completed':
            # Obter resultados
            results_response = requests.get(
                f'https://api.astrologia.br/api/v2/batch/results/{batch_id}',
                headers=headers
            )
            results = results_response.json()

            for i, chart in enumerate(results['charts']):
                print(f"Mapa {i+1}: {chart['name']} - {chart['sun_sign']}")
            break
        elif status['status'] == 'failed':
            print("Lote falhou!")
            break

        time.sleep(2)  # Aguardar 2 segundos antes de verificar novamente
```

## 5. Tratamento de Erros

### Exemplo de Tratamento de Erros
```python
import requests
from requests.exceptions import RequestException

def safe_api_call(method, url, **kwargs):
    try:
        response = requests.request(method, url, **kwargs)

        # Verificar rate limiting
        if response.status_code == 429:
            retry_after = response.headers.get('Retry-After', 60)
            print(f"Rate limit excedido. Tentar novamente em {retry_after} segundos.")
            return None

        response.raise_for_status()  # Levantar exceção para códigos 4xx/5xx
        return response.json()

    except requests.exceptions.HTTPError as e:
        error_data = e.response.json()
        print(f"Erro HTTP {e.response.status_code}: {error_data.get('message', 'Erro desconhecido')}")
        if 'details' in error_data:
            print(f"Detalhes: {error_data['details']}")
        return None

    except requests.exceptions.ConnectionError:
        print("Erro de conexão. Verifique sua internet.")
        return None

    except requests.exceptions.Timeout:
        print("Timeout. A API demorou muito para responder.")
        return None

    except RequestException as e:
        print(f"Erro de request: {str(e)}")
        return None

# Exemplo de uso
headers = {'Authorization': 'Bearer YOUR_JWT_TOKEN'}

# Tentativa com dados inválidos
result = safe_api_call('POST', 'https://api.astrologia.br/api/v2/charts/natal',
    json={
        "name": "João",
        "birth_date": "1990-05-15",  # Formato errado!
        "birth_time": "18:30",
        "city": "São Paulo",
        "state": "SP"
    },
    headers=headers
)

if result is None:
    print("Falha ao gerar mapa astral")
```

## 6. Webhooks

### Configurar Webhook para Lotes
```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/webhook/batch-complete', methods=['POST'])
def batch_webhook():
    # Verificar assinatura do webhook (recomendado em produção)
    signature = request.headers.get('X-API-Signature')
    # Implementar verificação de assinatura aqui

    data = request.get_json()

    print(f"Webhook recebido: {data['event']}")
    print(f"Batch ID: {data['batch_id']}")
    print(f"Status: {data['status']}")

    if data['status'] == 'completed':
        # Processar resultados
        results_url = data['results_url']
        # Buscar resultados da API
        # ...

    return jsonify({'received': True}), 200

if __name__ == '__main__':
    app.run(port=5000)
```

## 7. Analytics e Monitoramento

### Obter Estatísticas de Uso
```python
import requests

headers = {'Authorization': 'Bearer YOUR_JWT_TOKEN'}

# Estatísticas de uso (últimos 30 dias)
response = requests.get(
    'https://api.astrologia.br/api/v2/analytics/usage',
    params={'period': '30d'},
    headers=headers
)

if response.status_code == 200:
    analytics = response.json()

    print(f"Total de requests: {analytics['total_requests']}")
    print(f"Taxa de erro: {analytics['error_rate'] * 100}%")
    print(f"Tempo médio de resposta: {analytics['average_response_time']}ms")

    print("\nRequests por endpoint:")
    for endpoint, count in analytics['requests_by_endpoint'].items():
        print(f"  {endpoint}: {count}")

    print("\nRequests por dia:")
    for day in analytics['requests_by_day'][-7:]:  # Últimos 7 dias
        print(f"  {day['date']}: {day['count']}")
```

## 8. Exemplos Avançados

### Comparação Sinástrica
```python
import requests

headers = {'Authorization': 'Bearer YOUR_JWT_TOKEN'}

synastry_data = {
    "person1": {
        "name": "João Silva",
        "birth_date": "15/05/1990",
        "birth_time": "18:30",
        "city": "São Paulo",
        "state": "SP"
    },
    "person2": {
        "name": "Maria Santos",
        "birth_date": "22/08/1985",
        "birth_time": "14:15",
        "city": "Rio de Janeiro",
        "state": "RJ"
    },
    "include_charts": true
}

response = requests.post(
    'https://api.astrologia.br/api/v2/charts/synastry',
    json=synastry_data,
    headers=headers
)

if response.status_code == 200:
    synastry = response.json()
    print(f"Compatibilidade: {synastry['compatibility_score']}%")

    print("Aspectos principais:")
    for aspect in synastry['aspects'][:5]:  # Top 5 aspectos
        print(f"  {aspect['planet1']} {aspect['aspect_type']} {aspect['planet2']} (órbita: {aspect['orb']}°)")
```

### Mapa de Trânsito
```python
import requests
from datetime import datetime

headers = {'Authorization': 'Bearer YOUR_JWT_TOKEN'}

# Mapa de trânsito para hoje
transit_data = {
    "natal_chart": {
        "name": "João Silva",
        "birth_date": "15/05/1990",
        "birth_time": "18:30",
        "city": "São Paulo",
        "state": "SP"
    },
    "transit_date": datetime.now().strftime("%d/%m/%Y"),
    "transit_time": datetime.now().strftime("%H:%M"),
    "include_charts": true
}

response = requests.post(
    'https://api.astrologia.br/api/v2/charts/transit',
    json=transit_data,
    headers=headers
)

if response.status_code == 200:
    transit = response.json()
    print("Planetas em trânsito:")
    for planet, data in transit['transit_planets'].items():
        print(f"  {planet}: {data['sign']} {data['degree']}°")
```

---

**Nota**: Todos os exemplos assumem que você tem um token JWT válido. Substitua `YOUR_JWT_TOKEN` pelo seu token real obtido através do endpoint de login.