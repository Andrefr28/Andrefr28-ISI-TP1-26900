# Airport Intelligence — Projeto de Integração de Sistemas de Informação

## 1. Identificação dos autores

- **Autor:** André Rodrigues
- **Número:** 26900
- **Curso:** Licenciatura em Engenharia de Sistemas Informáticos
- **Unidade Curricular:** Integração de Sistemas de Informação (ISI)
- **Instituição:** Instituto Politécnico do Cávado e do Ave (IPCA)
- **Ano letivo:** 2026/2027

## 2. Descrição do projeto

O Airport Intelligence é um projeto de integração e análise de dados relacionados com voos, aeroportos e condições meteorológicas.

A solução utiliza diferentes fontes de dados e formatos, implementando processos de extração, transformação e carregamento (ETL). Os dados são recolhidos através do Node-RED, armazenados nas estruturas definidas para cada fonte, transformados no KNIME e carregados para o PostgreSQL. O Grafana permite consultar e visualizar os indicadores produzidos.

O projeto inclui ainda um workflow experimental de Machine Learning, desenvolvido no KNIME, para a classificação de voos.

## 3. Tecnologias utilizadas

| Tecnologia | Função |
|---|---|
| Docker Compose | Inicialização dos serviços definidos no ambiente |
| Node-RED | Extração e preparação inicial dos dados |
| MongoDB | Armazenamento dos dados originais de determinadas fontes |
| KNIME Analytics Platform | Transformação, integração, carregamento e Machine Learning |
| PostgreSQL | Armazenamento dos dados tratados |
| Grafana | Visualização dos dados através de dashboards |

## 4. Fontes de dados

- **BTS — TranStats:** dados históricos de voos, obtidos em ficheiros ZIP com dados CSV.
- **Open-Meteo:** dados meteorológicos históricos, obtidos através de uma API que devolve JSON.
- **OurAirports:** dados de aeroportos, originalmente disponibilizados em CSV e preparados em XML para leitura no KNIME.

Referências:

- https://transtats.bts.gov/
- https://open-meteo.com/en/docs/historical-weather-api
- https://ourairports.com/data/

## 5. Descrição dos ficheiros e componentes entregues

A organização exata deve corresponder aos ficheiros presentes no repositório.

| Ficheiro ou componente | Descrição |
|---|---|
| `README.md` | Identificação dos autores, descrição do projeto e instruções de execução. |
| `docker-compose.yml` ou `compose.yaml` | Configuração dos serviços executados através do Docker Compose, se incluída na entrega. |
| `nodered/` | Fluxos de extração, preparação dos pedidos, validação das respostas e armazenamento inicial, se esta pasta fizer parte do repositório. |
| `database/` | Scripts SQL ou outros ficheiros relacionados com a base de dados, caso existam. |
| `data/` | Ficheiros de dados utilizados pelo projeto, como CSV e XML, caso estejam incluídos. |
| `knime/` | Workflows de transformação, integração e Machine Learning, caso estejam incluídos nesta pasta. |
| `grafana/` | Configurações ou exportações dos dashboards, se disponibilizadas. |
| `docs/` | Relatório, diagramas e documentação complementar, caso sejam entregues nesta pasta. |

Os nomes apresentados são indicativos. Devem ser ajustados à estrutura real do repositório, removendo as entradas que não correspondam a ficheiros efetivamente entregues.

Os dados originais podem estar armazenados no MongoDB ou em ficheiros externos, dependendo da fonte. A disponibilidade desses dados para reprodução depende de os mesmos estarem incluídos na entrega ou poderem ser novamente obtidos a partir das fontes públicas.

## 6. Como executar a solução

### 6.1. Pré-requisitos

Instalar ou disponibilizar:

- Docker Desktop com Docker Compose.
- Node-RED.
- KNIME Analytics Platform.
- MongoDB e MongoDB Compass.
- PostgreSQL.
- Grafana.

Alguns destes serviços podem estar incluídos no ambiente Docker Compose. Deve confirmar-se a configuração efetiva do projeto antes de iniciar os serviços.

### 6.2. Iniciar os serviços

Abrir um terminal na pasta onde se encontra o ficheiro `docker-compose.yml` ou `compose.yaml`.

Executar:

```bash
docker compose up -d
```

Verificar o estado dos serviços:

```bash
docker compose ps
```

Consultar os logs:

```bash
docker compose logs
```

Para acompanhar os logs em tempo real:

```bash
docker compose logs -f
```

### 6.2.1. Restaurar os dados a partir da pasta `backup`

A pasta `backup/` contém uma cópia das bases de dados e dos dashboards:

| Ficheiro | Conteúdo |
|---|---|
| `backup/mongodb.archive` | Base `airport_intelligence` do MongoDB (dados RAW) |
| `backup/postgres.backup` | Base `airport_intelligence` do PostgreSQL (formato `pg_dump -Fc`) |
| `backup/Dashboards_Grafana.json` | Dashboard do Grafana (importar em Dashboards > New > Import) |
| `backup/TP1_ISI_nodered_backup/` | Cópia de segurança dos fluxos do Node-RED |

Depois de `docker compose up -d`, executar com duplo clique `backup/restaurar_backup.bat` (Windows), que restaura o MongoDB e o PostgreSQL. Para gerar um backup novo, executar `backup/fazer_backup.bat`, com os contentores em execução.

### 6.3. Executar a extração no Node-RED

1. Abrir a interface Node-RED no endereço configurado no ambiente.
2. Confirmar as configurações dos fluxos e as ligações ao MongoDB.
3. Selecionar o fluxo pretendido.
4. Acionar o nó de disparo manual.
5. Verificar os resultados no painel Debug.
6. Confirmar os documentos armazenados no MongoDB ou os ficheiros produzidos, conforme a fonte.

Os fluxos de extração podem ser iniciados manualmente (botão de disparo) ou correm de forma agendada (ver secção 6.7).

### 6.4. Executar os workflows no KNIME

1. Abrir o KNIME Analytics Platform.
2. Importar ou abrir os workflows entregues.
3. Confirmar os caminhos dos ficheiros CSV e XML.
4. Verificar as ligações ao MongoDB e ao PostgreSQL.
5. Executar os nós do workflow de acordo com a sequência definida.
6. Confirmar os resultados das operações de limpeza, normalização, validação, junção e agregação.
7. Executar o workflow de Machine Learning, caso se pretenda reproduzir essa componente.

Os caminhos, as credenciais e as ligações podem necessitar de adaptação ao computador de destino.

### 6.5. Verificar os dados no PostgreSQL

Depois de executar o carregamento no KNIME, abrir uma ferramenta de consulta SQL, como o pgAdmin ou o SQL client utilizado no projeto.

Para verificar o número de registos:

```sql
SELECT COUNT(*) AS total_registos
FROM public.flight_daily_airline;
```

Para consultar uma amostra:

```sql
SELECT *
FROM public.flight_daily_airline
LIMIT 20;
```

Estas consultas pressupõem que a tabela `public.flight_daily_airline` existe na base de dados utilizada. Se o nome efetivo for diferente, deve ser ajustado.

### 6.6. Validar a carga (SQL)

Executar `database/validacoes.sql` no pgAdmin (base `airport_intelligence`, porta 5433). As consultas são só de leitura e incluem um resumo PASS/FAIL (contagens, nulos, duplicados e valores fora do intervalo).

### 6.7. Execução automática (jobs agendados)

| Hora (domingo) | Job | Ferramenta | Resultado |
|---|---|---|---|
| 01:00 | Extração da meteorologia | Node-RED (cron) | `weather_raw_original` no MongoDB |
| 01:10 | Extração dos aeroportos | Node-RED (cron) | `node-red/data/raw/airports.xml` + metadados no MongoDB |
| 01:20 | Extração dos voos | Node-RED (cron) | `node-red/data/raw/flights.csv` + `flights_raw` no MongoDB |
| manual | Transformação e carga | KNIME (*Execute all* no workflow `AIRPORT_CTRL_WF`), depois da extração | tabela `public.flight_daily_airline` |

- Os jobs de extração registam o resultado (sucesso ou erro) na coleção `etl_logs` do MongoDB e usam *upsert*, pelo que repetições não geram duplicados.
- A carga do KNIME substitui a tabela no PostgreSQL (idempotente).
- `run_pipeline.bat` e `agendar_tarefa.bat` são uma tentativa opcional de executar o KNIME em modo batch; requerem a extensão *KNIME Batch Executor*, que não foi possível instalar (erro "KNIME Batch Executor is not installed"). Por isso o job do KNIME é executado manualmente.
- Requisitos da extração agendada: computador ligado e Docker em execução à hora marcada.
- Limitação: a dependência entre a extração e o KNIME é garantida pelo horário (e por uma verificação da existência do `flights.csv`), não por um orquestrador de eventos.

### 6.8. Consultar o Grafana

1. Abrir o Grafana no endereço configurado.
2. Confirmar que a fonte de dados PostgreSQL está operacional.
3. Abrir os dashboards disponibilizados.
4. Verificar se os gráficos e indicadores apresentam dados.

## 7. Execução e limitações

A extração dos dados é feita no Node-RED a partir dos ficheiros disponibilizados pelas entidades, de forma manual ou agendada. Os workflows KNIME são utilizados para executar as transformações e o carregamento dos resultados.

A reprodução integral do projeto depende da disponibilidade dos ficheiros necessários, dos serviços configurados, das ligações às bases de dados e dos caminhos definidos nos workflows.

A componente de Machine Learning tem caráter experimental, pelo que os resultados devem ser interpretados considerando as métricas de avaliação e as limitações dos dados utilizados.

Link para o vídeo de demonstração: https://www.youtube.com/watch?v=5UTS9J_oeKo&t=52s

## 8. Documentação técnica

- Node-RED: https://nodered.org/docs/
- MongoDB: https://www.mongodb.com/docs/
- KNIME: https://docs.knime.com/
- PostgreSQL: https://www.postgresql.org/docs/
- Grafana: https://grafana.com/docs/
- Docker Compose: https://docs.docker.com/compose/

---

**Instituto Politécnico do Cávado e do Ave (IPCA)**  
Licenciatura em Engenharia de Sistemas Informáticos  
Unidade Curricular de Integração de Sistemas de Informação