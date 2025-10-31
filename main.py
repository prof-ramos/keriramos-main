from fastapi import FastAPI, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import HTMLResponse, JSONResponse
from datetime import datetime
import json
import asyncio
import hashlib
import os
from functools import lru_cache
from typing import Optional, Dict, Any

from kerykeion import AstrologicalSubject
from geonames_client import GeoNamesClient
from chart_generator import MapaAstralChartGenerator
from models import MapaAstralRequest, MapaAstralResponse, ChartRequest

app = FastAPI(
    title="API Mapa Astral Brasileiro",
    description="API para geração de mapas astrais com foco no público brasileiro - Formato DD/MM/YYYY",
    version="2.0.0"
)

# CORS para frontend brasileiro
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especifique domínios
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# GZip compression for response optimization
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Simple in-memory rate limiting
rate_limit_storage = {}
RATE_LIMIT_REQUESTS = 10  # requests per window
RATE_LIMIT_WINDOW = 60    # seconds

def check_rate_limit(client_ip: str) -> bool:
    """Simple rate limiting check"""
    current_time = asyncio.get_event_loop().time()

    if client_ip not in rate_limit_storage:
        rate_limit_storage[client_ip] = []

    # Clean old requests outside the window
    rate_limit_storage[client_ip] = [
        req_time for req_time in rate_limit_storage[client_ip]
        if current_time - req_time < RATE_LIMIT_WINDOW
    ]

    # Check if under limit
    if len(rate_limit_storage[client_ip]) < RATE_LIMIT_REQUESTS:
        rate_limit_storage[client_ip].append(current_time)
        return True

    return False

def get_cache_key(request: MapaAstralRequest) -> str:
    """Generate cache key for astrological calculation"""
    key_data = f"{request.nome}_{request.data_nascimento}_{request.hora_nascimento}_{request.cidade}_{request.estado}"
    return hashlib.md5(key_data.encode()).hexdigest()

# In-memory cache for astrological calculations
astro_cache = {}
CACHE_TTL = 3600  # 1 hour

def get_cached_astrology(cache_key: str) -> Optional[Dict[str, Any]]:
    """Get cached astrological data"""
    if cache_key in astro_cache:
        cache_entry = astro_cache[cache_key]
        if asyncio.get_event_loop().time() - cache_entry['timestamp'] < CACHE_TTL:
            return cache_entry['data']
        else:
            # Remove expired entry
            del astro_cache[cache_key]
    return None

def set_cached_astrology(cache_key: str, data: Dict[str, Any]):
    """Cache astrological data"""
    astro_cache[cache_key] = {
        'data': data,
        'timestamp': asyncio.get_event_loop().time()
    }

geonames_client = GeoNamesClient()
chart_generator = MapaAstralChartGenerator()

def parse_brazilian_datetime(date_str: str, time_str: str) -> datetime:
    """
    Converte data e hora no formato brasileiro para objeto datetime
    Formato: DD/MM/YYYY HH:MM
    """
    try:
        datetime_str = f"{date_str} {time_str}"
        return datetime.strptime(datetime_str, "%d/%m/%Y %H:%M")
    except ValueError as e:
        raise ValueError(f"Formato de data/hora inválido. Use DD/MM/YYYY para data e HH:MM para hora. Erro: {str(e)}")

def calcular_elementos(sun_sign: str) -> dict:
    """
    Calcula elementos baseados no signo solar
    """
    elementos = {
        'Áries': {'elemento': 'Fogo', 'qualidade': 'Cardinal'},
        'Touro': {'elemento': 'Terra', 'qualidade': 'Fixo'},
        'Gêmeos': {'elemento': 'Ar', 'qualidade': 'Mutável'},
        'Câncer': {'elemento': 'Água', 'qualidade': 'Cardinal'},
        'Leão': {'elemento': 'Fogo', 'qualidade': 'Fixo'},
        'Virgem': {'elemento': 'Terra', 'qualidade': 'Mutável'},
        'Libra': {'elemento': 'Ar', 'qualidade': 'Cardinal'},
        'Escorpião': {'elemento': 'Água', 'qualidade': 'Fixo'},
        'Sagitário': {'elemento': 'Fogo', 'qualidade': 'Mutável'},
        'Capricórnio': {'elemento': 'Terra', 'qualidade': 'Cardinal'},
        'Aquário': {'elemento': 'Ar', 'qualidade': 'Fixo'},
        'Peixes': {'elemento': 'Água', 'qualidade': 'Mutável'}
    }
    return elementos.get(sun_sign, {'elemento': 'Desconhecido', 'qualidade': 'Desconhecida'})

@app.post("/mapa-astral", response_model=MapaAstralResponse)
async def gerar_mapa_astral(
    request: MapaAstralRequest,
    http_request: Request,
    incluir_grafico: bool = Query(True, description="Incluir gráfico SVG no response")
):
    """
    Gera mapa astral completo para usuários brasileiros
    Formato de data: DD/MM/YYYY
    """
    # Rate limiting check
    client_ip = http_request.client.host if http_request.client else "unknown"
    if not check_rate_limit(client_ip):
        raise HTTPException(
            status_code=429,
            detail="Muitas requisições. Aguarde antes de tentar novamente."
        )

    # Check cache first
    cache_key = get_cache_key(request)
    cached_result = get_cached_astrology(cache_key)
    if cached_result and incluir_grafico == cached_result.get('incluir_grafico', True):
        # Return cached response (without charts if not requested)
        if not incluir_grafico:
            cached_result['grafico_svg'] = None
            cached_result['grafico_png'] = None
        return MapaAstralResponse(**cached_result)

    # Obter coordenadas da cidade
    coordenadas = await geonames_client.get_coordinates(
        request.cidade,
        request.estado
    )
    
    if not coordenadas:
        raise HTTPException(
            status_code=404, 
            detail=f"Cidade não encontrada: {request.cidade}, {request.estado}. Verifique a grafia."
        )
    
    # Converter data e hora do formato brasileiro
    try:
        dt_nascimento = parse_brazilian_datetime(
            request.data_nascimento, 
            request.hora_nascimento
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    # Criar sujeito astrológico
    try:
        subject = AstrologicalSubject(
            name=request.nome,
            year=dt_nascimento.year,
            month=dt_nascimento.month,
            day=dt_nascimento.day,
            hour=dt_nascimento.hour,
            minute=dt_nascimento.minute,
            lat=coordenadas['lat'],
            lng=coordenadas['lng'],
            tz_str=coordenadas['timezone_id'],
            city=request.cidade,
            nation="BR"
        )
        
        # Gerar gráficos se solicitado
        grafico_svg = None
        grafico_png = None
        
        if incluir_grafico:
            grafico_svg = chart_generator.generate_natal_chart_svg(subject)
            grafico_png = chart_generator.generate_natal_chart_png(subject)
        
        # Calcular elementos
        elementos = calcular_elementos(subject.sun.sign)
        
        # Construir resposta
        response_data = MapaAstralResponse(
            nome=request.nome.title(),
            signo_solar=subject.sun.sign,
            signo_lunar=subject.moon.sign,
            ascendente=subject.first_house.sign,
            planeta_posicoes={
                'sol': {'signo': subject.sun.sign, 'casa': subject.sun.house, 'grau': getattr(subject.sun, 'degree', 0)},
                'lua': {'signo': subject.moon.sign, 'casa': subject.moon.house, 'grau': getattr(subject.moon, 'degree', 0)},
                'mercurio': {'signo': subject.mercury.sign, 'casa': subject.mercury.house, 'grau': getattr(subject.mercury, 'degree', 0)},
                'venus': {'signo': subject.venus.sign, 'casa': subject.venus.house, 'grau': getattr(subject.venus, 'degree', 0)},
                'marte': {'signo': subject.mars.sign, 'casa': subject.mars.house, 'grau': getattr(subject.mars, 'degree', 0)},
                'jupiter': {'signo': subject.jupiter.sign, 'casa': subject.jupiter.house, 'grau': getattr(subject.jupiter, 'degree', 0)},
                'saturno': {'signo': subject.saturn.sign, 'casa': subject.saturn.house, 'grau': getattr(subject.saturn, 'degree', 0)},
            },
            casas_astrologicas={
                'casa1': subject.first_house.sign,
                'casa2': subject.second_house.sign,
                'casa3': subject.third_house.sign,
                'casa4': subject.fourth_house.sign,
                'casa5': subject.fifth_house.sign,
                'casa6': subject.sixth_house.sign,
                'casa7': subject.seventh_house.sign,
                'casa8': subject.eighth_house.sign,
                'casa9': subject.ninth_house.sign,
                'casa10': subject.tenth_house.sign,
                'casa11': subject.eleventh_house.sign,
                'casa12': subject.twelfth_house.sign,
            },
            elementos=elementos,
            cidade_calculada=coordenadas['cidade_encontrada'],
            grafico_svg=grafico_svg,
            grafico_png=grafico_png
        )

        # Cache the result for future requests
        cache_data = response_data.dict()
        cache_data['incluir_grafico'] = incluir_grafico
        set_cached_astrology(cache_key, cache_data)

        return response_data
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao calcular mapa astral: {str(e)}"
        )

@app.get("/")
async def root():
    """Página inicial com instruções em português"""
    html_content = """
    <html>
        <head>
            <title>API Mapa Astral Brasileiro</title>
        </head>
        <body>
            <h1>🌙 API Mapa Astral Brasileiro</h1>
            <p>Bem-vindo à API de mapa astral para o público brasileiro!</p>
            <h2>📝 Como usar:</h2>
            <p><strong>Endpoint:</strong> POST /mapa-astral</p>
            <p><strong>Formato de data:</strong> DD/MM/YYYY</p>
            <h3>Exemplo de requisição:</h3>
            <pre>
{
    "nome": "João Silva",
    "data_nascimento": "15/05/1990",
    "hora_nascimento": "18:30",
    "cidade": "São Paulo",
    "estado": "SP"
}
            </pre>
            <p>Acesse a documentação interativa: <a href="/docs">/docs</a></p>
        </body>
    </html>
    """
    return HTMLResponse(content=html_content)

@app.get("/health")
async def health_check():
    """Verificar saúde da API"""
    return {
        "status": "online",
        "versao": "2.0.0",
        "pais": "Brasil",
        "formato_data": "DD/MM/YYYY"
    }

@app.get("/performance")
async def performance_stats():
    """Estatísticas de performance e cache"""
    current_time = asyncio.get_event_loop().time()

    # Cache statistics
    active_cache_entries = len(astro_cache)
    geonames_cache_size = len(geonames_client.cache) if hasattr(geonames_client, 'cache') else 0

    # Rate limiting statistics
    active_rate_limits = len(rate_limit_storage)

    return {
        "cache_stats": {
            "astrological_cache_entries": active_cache_entries,
            "geonames_cache_entries": geonames_cache_size,
            "cache_ttl_seconds": CACHE_TTL
        },
        "rate_limiting": {
            "active_clients": active_rate_limits,
            "requests_per_window": RATE_LIMIT_REQUESTS,
            "window_seconds": RATE_LIMIT_WINDOW
        },
        "performance_features": {
            "gzip_compression": True,
            "async_io": True,
            "caching_enabled": True,
            "rate_limiting_enabled": True
        },
        "timestamp": current_time
    }

@app.post("/cache/clear")
async def clear_cache():
    """Limpar todos os caches (admin endpoint)"""
    global astro_cache
    astro_cache = {}

    # Clear geonames cache if it exists
    if hasattr(geonames_client, 'cache'):
        geonames_client.cache = {}

    return {
        "message": "Caches cleared successfully",
        "timestamp": asyncio.get_event_loop().time()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
