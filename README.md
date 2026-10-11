# Airport Intelligence - ISI TP1

Projeto academico de Integracao de Sistemas de Informacao.

## Objetivo

Desenvolver um processo ETL para integrar dados de voos, aeroportos e meteorologia, permitindo analisar indicadores de desempenho como total de voos, atrasos medios, percentagem de atrasos e possivel relacao com condicoes meteorologicas.

## Tema

O estudo inicial foca-se nas partidas do aeroporto Hartsfield-Jackson Atlanta International Airport (ATL), durante janeiro de 2025.

## Fontes previstas

- `flights.csv` - BTS TranStats, dados historicos de partidas.
- `weather.json` - Open-Meteo API, meteorologia horaria.
- `airports.xml` - OurAirports, cadastro de aeroportos.

## Ferramentas

- Node-RED - automatizacao de pedidos e recolha de dados.
- MongoDB - armazenamento de dados raw em JSON.
- KNIME - processo ETL: leitura, limpeza, validacao, transformacao e integracao.
- PostgreSQL - armazenamento dos dados tratados.
- Grafana - dashboard e indicadores.

## Fluxo previsto

```text
Node-RED / ficheiros -> MongoDB -> KNIME -> PostgreSQL -> Grafana
```

## Estrutura

- `dados/raw/` - ficheiros originais recolhidos.
- `dados/processed/` - ficheiros tratados ou exportacoes intermédias.
- `database/` - scripts SQL da base de dados.
- `docs/` - plano, proposta e documentacao.
- `node-red/` - flows e notas do Node-RED.
- `workflows/` - workflows KNIME.
- `relatorio/` - relatorio final.

## Ambiente Docker

Servicos previstos:

- MongoDB: `localhost:27017`
- PostgreSQL: `localhost:5432`
- Node-RED: `http://localhost:1880`
- Grafana: `http://localhost:3001`

Comando para iniciar:

```powershell
docker compose up -d
```
