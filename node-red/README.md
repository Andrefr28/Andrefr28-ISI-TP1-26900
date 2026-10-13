# Node-RED

Pasta dos flows do Node-RED do projeto **Airport Intelligence**.

O Node-RED é responsável pela **extração** de dados: faz os pedidos HTTP às fontes
(Open-Meteo, OurAirports, BTS TranStats), trata o mínimo necessário e guarda os
dados brutos no MongoDB.

URL local depois de iniciar o Docker:

```text
http://localhost:1880
```

## Como está organizado

A pasta `data/` é montada no contentor (`./node-red/data:/data`), pelo que os
flows ficam guardados no repositório e podem ser vistos/alterados no editor:

- `data/flows.json` - os flows (versionado no Git).
- `data/package.json` - dependências (palette) do Node-RED (versionado no Git).
- `data/settings.js` - configuração do Node-RED (versionado no Git).
- `data/node_modules/`, `data/.config.*.json`, `data/flows_cred.json` - gerados em
  runtime, ignorados pelo Git.

A palette usada é a `node-red-contrib-mongodb4` (nós `mongodb4` e `mongodb4-client`).
Como está declarada no `package.json`, é reinstalada automaticamente no arranque.

Ligação ao MongoDB (config node "MongoDB Airport Intelligence"):

```text
mongodb://airport:airport123@mongodb:27017/?authSource=admin
base de dados: airport_intelligence
```

> **Ferramentas externas (MongoDB Compass, VS Code, KNIME):** usam `localhost:27018`
> (`27017` no host pertence a um mongod local do Windows; o contentor publica em
> `27018`). No Postgres, o conteúdo equivalente: `localhost:5433`.
>
> Compass: `mongodb://airport:airport123@localhost:27018/airport_intelligence?authSource=admin`

## Flow 1 - Meteorologia (Open-Meteo -> MongoDB)

Tab: `ETL · Meteorologia (Open-Meteo)`

Cadeia de nós:

```text
inject -> function -> mongodb4 -> http request -> function -> mongodb4 -> debug
(manual) (limpar)    (deleteMany) (Open-Meteo)    (achatar)    (insertMany) (resultado)
```

1. **inject** - `Extrair meteorologia (1 click)` (disparo manual).
2. **function** - `Limpar weather_raw (ATL)` - prepara o filtro de limpeza
   (`{ airport_code: "ATL" }`).
3. **mongodb4** - `deleteMany weather_raw (ATL)` - apaga os documentos antigos de
   ATL (passo de **idempotência**: cada execução deixa exatamente 744 docs, sem
   duplicados).
4. **http request** - `Open-Meteo archive (ATL)` - GET a:

   ```text
   https://archive-api.open-meteo.com/v1/archive
     ?latitude=33.6367&longitude=-84.4281
     &start_date=2025-01-01&end_date=2025-01-31
     &hourly=temperature_2m,precipitation,wind_speed_10m,weather_code
     &timezone=America/New_York
   ```

5. **function** - `Achatar horas -> documentos` - transforma os arrays paralelos
   da resposta em **1 documento por hora**, acrescentando `airport_code: "ATL"` e
   `ingested_at`. O campo `observed_at` fica em **hora local de Atlanta**
   (`America/New_York`), sem conversão, para fazer join direto com os horários
   locais dos voos do BTS.
6. **mongodb4** - `insertMany -> weather_raw` - insere os documentos na collection
   `weather_raw`.
7. **debug** - `Resultado (insertedCount)` - mostra o resultado da inserção.

**Resultado esperado:** 31 dias x 24 h = **744 documentos** em `weather_raw`
(sempre 744, mesmo que se clique várias vezes).

### Como correr

```powershell
docker compose up -d
# abrir http://localhost:1880 e clicar em "Extrair meteorologia (1 click)"
```

### Confirmar no MongoDB

```powershell
docker exec airport_intelligence_mongodb mongosh -u airport -p airport123 `
  --authenticationDatabase admin airport_intelligence `
  --eval "db.weather_raw.countDocuments()"
```

### Idempotência (sem duplicados)

O flow limpa os documentos de ATL em `weather_raw` **antes** de inserir, por isso
podes clicar as vezes que quiseres: fica sempre com **744** documentos.

Se alguma vez quiseres limpar a collection à mão (por exemplo, para começar do
zero), usa:

```powershell
docker exec airport_intelligence_mongodb mongosh -u airport -p airport123 `
  --authenticationDatabase admin airport_intelligence `
  --eval "db.weather_raw.deleteMany({})"
```

## Próximos flows (a implementar)

- **Flow 2 - Aeroportos:** OurAirports (CSV) -> filtro ATL + destinos -> XML -> `airports_raw`.
- **Flow 3 - Voos:** BTS TranStats (zip mensal) -> filtro origem ATL + 1 a 7 jan 2025
  -> CSV filtrado -> `flights_raw`.
