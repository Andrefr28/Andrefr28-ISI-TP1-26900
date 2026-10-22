-- ============================================================
-- Validacoes pos-carga (SO LEITURA) - Airport Intelligence / ISI TP1
-- Tabela carregada pelo KNIME (DB Writer, modo "Remove existing table"):
--     public.flight_daily_airline   (1 linha por dia + companhia aerea)
-- Executar no pgAdmin (base airport_intelligence, porta 5433) depois de cada carga.
-- Nenhuma instrucao altera dados.
-- ============================================================

-- 0) Estrutura efetiva da tabela (confirmar nomes de colunas usados abaixo)
SELECT ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'flight_daily_airline'
ORDER BY ordinal_position;

-- 1) Contagens gerais
SELECT COUNT(*)                          AS total_linhas,
       COUNT(DISTINCT "Reporting_Airline") AS companhias,
       COUNT(DISTINCT "FlightDate")        AS dias_distintos,
       MIN("FlightDate")                   AS primeiro_dia,
       MAX("FlightDate")                   AS ultimo_dia
FROM public.flight_daily_airline;

-- 2) Valores nulos por coluna
SELECT COUNT(*) FILTER (WHERE "FlightDate" IS NULL)              AS nulos_FlightDate,
       COUNT(*) FILTER (WHERE "Reporting_Airline" IS NULL)       AS nulos_Reporting_Airline,
       COUNT(*) FILTER (WHERE "Mean(DepDelayMinutes)" IS NULL)   AS nulos_MeanDepDelay,
       COUNT(*) FILTER (WHERE "Sum(Cancelled)" IS NULL)          AS nulos_SumCancelled,
       COUNT(*) FILTER (WHERE "Sum(Diverted)" IS NULL)           AS nulos_SumDiverted,
       COUNT(*) FILTER (WHERE "Mean(WeatherDelay)" IS NULL)      AS nulos_MeanWeatherDelay
FROM public.flight_daily_airline;

-- 3) Duplicados na chave natural (dia + companhia): deve devolver 0 linhas
SELECT "FlightDate", "Reporting_Airline", COUNT(*) AS repeticoes
FROM public.flight_daily_airline
GROUP BY "FlightDate", "Reporting_Airline"
HAVING COUNT(*) > 1;

-- 4) Valores fora do intervalo esperado: deve devolver 0 linhas
SELECT *
FROM public.flight_daily_airline
WHERE "Mean(DepDelayMinutes)" < 0
   OR "Sum(Cancelled)" < 0
   OR "Sum(Diverted)" < 0
   OR "Mean(WeatherDelay)" < 0;

-- 5) Resumo PASS/FAIL (resultado para incluir no relatorio)
SELECT verificacao, resultado FROM (
  SELECT 1 AS ordem, 'Tabela com registos (> 0 linhas)' AS verificacao,
         CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'FALHA' END AS resultado
  FROM public.flight_daily_airline
  UNION ALL
  SELECT 2, 'Sem nulos nas colunas-chave (FlightDate, Reporting_Airline)',
         CASE WHEN COUNT(*) FILTER (WHERE "FlightDate" IS NULL OR "Reporting_Airline" IS NULL) = 0
              THEN 'OK' ELSE 'FALHA' END
  FROM public.flight_daily_airline
  UNION ALL
  SELECT 3, 'Sem duplicados (dia + companhia)',
         CASE WHEN (SELECT COUNT(*) FROM (
                      SELECT 1 FROM public.flight_daily_airline
                      GROUP BY "FlightDate", "Reporting_Airline" HAVING COUNT(*) > 1) d) = 0
              THEN 'OK' ELSE 'FALHA' END
  UNION ALL
  SELECT 4, 'Sem valores negativos nas metricas',
         CASE WHEN COUNT(*) FILTER (WHERE "Mean(DepDelayMinutes)" < 0 OR "Sum(Cancelled)" < 0
                                       OR "Sum(Diverted)" < 0 OR "Mean(WeatherDelay)" < 0) = 0
              THEN 'OK' ELSE 'FALHA' END
  FROM public.flight_daily_airline
  UNION ALL
  SELECT 5, 'Periodo dentro de janeiro de 2025 (ambito do caso de estudo)',
         CASE WHEN MIN("FlightDate") >= DATE '2025-01-01' AND MAX("FlightDate") <= DATE '2025-01-31'
              THEN 'OK' ELSE 'REVER' END
  FROM public.flight_daily_airline
) v
ORDER BY ordem;

-- 6) Comparacao com consulta independente sobre o CSV original:
--    contar no CSV (ex.: PowerShell/Excel) o total de cancelamentos e desvios e comparar com
SELECT SUM("Sum(Cancelled)") AS total_cancelados,
       SUM("Sum(Diverted)")  AS total_desviados
FROM public.flight_daily_airline;

-- ------------------------------------------------------------
-- OPCIONAL: so se as tabelas do database/schema.sql (airports, flights,
-- weather_hourly) forem criadas e carregadas. Descomentar nesse caso.
-- ------------------------------------------------------------
-- -- Voos sem aeroporto de origem correspondente (chave estrangeira em falta)
-- SELECT f.flight_id, f.origin_airport_code
-- FROM public.flights f
-- LEFT JOIN public.airports a ON a.airport_code = f.origin_airport_code
-- WHERE a.airport_code IS NULL;
--
-- -- Aeroportos de destino sem registo na tabela airports
-- SELECT DISTINCT f.destination_airport_code
-- FROM public.flights f
-- LEFT JOIN public.airports a ON a.airport_code = f.destination_airport_code
-- WHERE a.airport_code IS NULL;
