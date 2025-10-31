from pydantic import BaseModel
from typing import Optional, Dict, Any

class MapaAstralRequest(BaseModel):
    nome: str
    data_nascimento: str  # Formato: DD/MM/YYYY
    hora_nascimento: str  # Formato: HH:MM
    cidade: str
    estado: str

class MapaAstralResponse(BaseModel):
    nome: str
    signo_solar: str
    signo_lunar: str
    ascendente: str
    planeta_posicoes: Dict[str, Any]
    casas_astrologicas: Dict[str, Any]
    elementos: Dict[str, Any]
    cidade_calculada: str
    grafico_svg: Optional[str] = None
    grafico_png: Optional[str] = None

class ChartRequest(BaseModel):
    mapa_astral: Dict[str, Any]
    tipo_grafico: str = "natal"  # natal, sinastria, etc.