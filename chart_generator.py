from kerykeion import AstrologicalSubject, KerykeionChartSVG
import base64
import tempfile
import os
from io import BytesIO

class MapaAstralChartGenerator:
    def __init__(self):
        self.chart_types = {
            "natal": "Mapa Natal",
            "houses": "Casas Astrológicas",
            "aspects": "Aspectos Planetários"
        }
    
    def generate_natal_chart_svg(self, subject: AstrologicalSubject) -> str:
        """
        Gera gráfico do mapa natal em SVG
        """
        try:
            chart = KerykeionChartSVG(subject, chart_type="Natal")
            chart.makeSVG()
            
            # Ler o arquivo SVG gerado
            svg_filename = f"{subject.name}_natal_chart.svg"
            if os.path.exists(svg_filename):
                with open(svg_filename, 'r', encoding='utf-8') as f:
                    svg_content = f.read()
                # Limpar arquivo temporário
                os.remove(svg_filename)
                return svg_content
            else:
                # Fallback: criar SVG básico
                return self._create_basic_svg(subject)
                
        except Exception as e:
            print(f"Erro ao gerar gráfico SVG: {e}")
            return self._create_basic_svg(subject)
    
    def generate_natal_chart_png(self, subject: AstrologicalSubject) -> str:
        """
        Gera gráfico do mapa natal em PNG (base64)
        """
        try:
            # Kerykeion não gera PNG diretamente, então usamos o SVG convertido
            svg_content = self.generate_natal_chart_svg(subject)
            
            # Em produção, você pode usar libraries como cairosvg ou batik
            # Por enquanto retornamos o SVG em base64 para simular PNG
            svg_base64 = base64.b64encode(svg_content.encode('utf-8')).decode('utf-8')
            return f"data:image/svg+xml;base64,{svg_base64}"
            
        except Exception as e:
            print(f"Erro ao gerar gráfico PNG: {e}")
            return ""
    
    def _create_basic_svg(self, subject: AstrologicalSubject) -> str:
        """
        Cria um SVG básico como fallback
        """
        return f'''
        <svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">
            <circle cx="200" cy="200" r="150" fill="none" stroke="black" stroke-width="2"/>
            <text x="200" y="100" text-anchor="middle" font-family="Arial" font-size="16">
                Mapa Astral de {subject.name}
            </text>
            <text x="200" y="130" text-anchor="middle" font-family="Arial" font-size="12">
                Sol: {subject.sun.sign} {subject.sun.degree}°
            </text>
            <text x="200" y="150" text-anchor="middle" font-family="Arial" font-size="12">
                Lua: {subject.moon.sign} {subject.moon.degree}°
            </text>
            <text x="200" y="170" text-anchor="middle" font-family="Arial" font-size="12">
                Ascendente: {subject.first_house.sign}
            </text>
        </svg>
        '''
    
    def generate_aspects_grid(self, subject: AstrologicalSubject) -> list:
        """
        Gera grade de aspectos em formato de lista
        """
        aspects_data = []
        for aspect in subject.aspects:
            aspects_data.append({
                'planeta1': aspect.p1_name,
                'planeta2': aspect.p2_name,
                'aspecto': aspect.aspect_type,
                'grau': aspect.orbit
            })

        return aspects_data