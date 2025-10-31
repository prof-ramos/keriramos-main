import aiohttp
import asyncio
import os
import json
import hashlib
from typing import Optional, Dict, Any
from dotenv import load_dotenv

load_dotenv()

class GeoNamesClient:
    def __init__(self):
        self.username = os.getenv('GEONAMES_USERNAME')
        self.base_url = "http://api.geonames.org/searchJSON"
        self.cache_file = "geonames_cache.json"
        self.cache_ttl = 24 * 60 * 60  # 24 hours in seconds
        self._load_cache()

    def _load_cache(self):
        """Load cache from file"""
        try:
            if os.path.exists(self.cache_file):
                with open(self.cache_file, 'r') as f:
                    self.cache = json.load(f)
            else:
                self.cache = {}
        except Exception:
            self.cache = {}

    def _save_cache(self):
        """Save cache to file"""
        try:
            with open(self.cache_file, 'w') as f:
                json.dump(self.cache, f)
        except Exception:
            pass

    def _get_cache_key(self, city: str, state: str) -> str:
        """Generate cache key for city/state combination"""
        key = f"{city.lower()}_{state.upper()}"
        return hashlib.md5(key.encode()).hexdigest()

    def _is_cache_valid(self, timestamp: float) -> bool:
        """Check if cache entry is still valid"""
        return (asyncio.get_event_loop().time() - timestamp) < self.cache_ttl

    async def get_coordinates(self, city: str, state: str = "", country: str = "BR"):
        """
        Busca coordenadas para cidades brasileiras (async version with caching)
        Retorna latitude, longitude e timezone
        """
        cache_key = self._get_cache_key(city, state)

        # Check cache first
        if cache_key in self.cache:
            cache_entry = self.cache[cache_key]
            if self._is_cache_valid(cache_entry['timestamp']):
                return cache_entry['data']

        params = {
            'q': city,
            'adminCode1': state.upper(),
            'country': country,
            'maxRows': 1,
            'username': self.username,
            'lang': 'pt'  # Idioma português
        }

        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(self.base_url, params=params, timeout=10) as response:
                    response.raise_for_status()
                    data = await response.json()

                    if 'geonames' in data and len(data['geonames']) > 0:
                        location = data['geonames'][0]

                        # Determinar timezone baseado no estado
                        timezone = self._get_brazilian_timezone(state.upper())

                        result = {
                            'lat': float(location['lat']),
                            'lng': float(location['lng']),
                            'timezone_id': timezone,
                            'cidade_encontrada': f"{location['name']}, {state.upper()}"
                        }

                        # Cache the result
                        self.cache[cache_key] = {
                            'data': result,
                            'timestamp': asyncio.get_event_loop().time()
                        }
                        self._save_cache()

                        return result
                    else:
                        return None

        except asyncio.TimeoutError:
            print(f"Timeout ao consultar GeoNames para {city}, {state}")
            return None
        except Exception as e:
            print(f"Erro ao consultar GeoNames: {str(e)}")
            return None
    
    def _get_brazilian_timezone(self, estado: str) -> str:
        """
        Determina o timezone baseado no estado brasileiro
        """
        timezones = {
            'AC': 'America/Rio_Branco',
            'AM': 'America/Manaus',
            'RR': 'America/Boa_Vista',
            'RO': 'America/Porto_Velho',
            'MT': 'America/Cuiaba',
            'MS': 'America/Campo_Grande',
            'AL': 'America/Maceio',
            'BA': 'America/Bahia',
            'CE': 'America/Fortaleza',
            'MA': 'America/Fortaleza',
            'PB': 'America/Fortaleza',
            'PE': 'America/Recife',
            'PI': 'America/Fortaleza',
            'RN': 'America/Fortaleza',
            'SE': 'America/Maceio',
        }
        return timezones.get(estado, 'America/Sao_Paulo')  # Padrão SP
