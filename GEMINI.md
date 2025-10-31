# Visão Geral do Projeto

Esta é uma API em Python que gera "mapas astrais" (cartas astrológicas) com foco em usuários brasileiros. A API é construída com FastAPI e utiliza a biblioteca `kerykeion` para os cálculos astrológicos.

## Principais Tecnologias

*   **Python 3.10+**
*   **FastAPI:** Para a criação da API RESTful.
*   **Uvicorn:** Como servidor ASGI para rodar a aplicação FastAPI.
*   **Kerykeion:** A biblioteca principal para os cálculos astrológicos.
*   **Requests:** Para fazer chamadas a APIs externas (GeoNames).
*   **python-dotenv:** Para gerenciar variáveis de ambiente.

## Arquitetura

O projeto é dividido nos seguintes módulos:

*   `main.py`: O ponto de entrada da aplicação FastAPI. Define os endpoints da API, lida com as requisições e orquestra as chamadas para os outros módulos.
*   `geonames_client.py`: Um cliente para a API do GeoNames, usado para obter as coordenadas (latitude, longitude) e o fuso horário das cidades brasileiras.
*   `chart_generator.py`: Responsável por gerar as representações visuais do mapa astral em formatos SVG e PNG.
*   `models.py`: Define os modelos de dados Pydantic para as requisições e respostas da API, garantindo a validação e a documentação dos dados.
*   `requirements.txt`: Lista todas as dependências do projeto.

# Construindo e Rodando o Projeto

Para rodar este projeto localmente, siga os passos abaixo:

1.  **Crie e ative um ambiente virtual:**

    ```bash
    python -m venv venv
    source venv/bin/activate
    ```

2.  **Instale as dependências:**

    ```bash
    pip install -r requirements.txt
    ```

3.  **Configure as variáveis de ambiente:**

    Crie um arquivo `.env` na raiz do projeto com a seguinte variável:

    ```
    GEONAMES_USERNAME=seu_usuario_geonames
    ```

    *Substitua `seu_usuario_geonames` pelo seu nome de usuário do GeoNames.*

4.  **Rode a aplicação:**

    ```bash
    uvicorn main:app --reload
    ```

    O servidor estará disponível em `http://127.0.0.1:8000`.

# Convenções de Desenvolvimento

*   **Variáveis de Ambiente:** O projeto utiliza o `python-dotenv` para carregar variáveis de ambiente de um arquivo `.env`. Certifique-se de que este arquivo não seja enviado para o controle de versão.
*   **Estilo de Código:** O código segue as convenções da PEP 8. Recomenda-se o uso de um linter como o `flake8` ou `pylint` para manter a consistência.
*   **Testes:** (TODO) Atualmente, não há testes automatizados no projeto. Uma boa prática seria adicionar testes unitários para os módulos `geonames_client.py` e `chart_generator.py`, e testes de integração para os endpoints da API.
