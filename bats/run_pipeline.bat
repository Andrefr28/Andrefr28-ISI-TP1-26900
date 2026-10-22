@echo off
REM ============================================================
REM  JOB: Transformacao e Carga (KNIME -> PostgreSQL)
REM  Projeto ISI TP1 - Airport Intelligence
REM  Corre o workflow AIRPORT_CTRL_WF em modo batch (sem interface).
REM  - Usa um workspace temporario (-data) para nao colidir com o KNIME aberto.
REM  - -reset  : repoe os nos antes de executar (dados sempre frescos).
REM  - -nosave : NAO altera o workflow guardado.
REM  Pre-requisitos: Docker (MongoDB + PostgreSQL) ligado e o workflow
REM  fechado no KNIME (o workflow nao pode estar aberto na interface).
REM ============================================================
setlocal
set "KNIME_EXE=C:\Users\j_nun\AppData\Local\Programs\KNIME\knime.exe"
set "WORKFLOW=C:\Users\j_nun\knime-workspace\ISI_TP1\AIRPORT_CTRL_WF"
set "FLIGHTS=%~dp0node-red\data\raw\flights.csv"
set "LOG=%~dp0logs_pipeline.txt"
set "BATCH_WS=%TEMP%\knime_batch_ws"

echo [%date% %time%] ===== INICIO job transformacao/carga ===== >> "%LOG%"

REM --- Verificacoes de dependencias (extracao feita pelo Node-RED) ---
REM --- O batch nao arranca se o KNIME (interface) estiver aberto ---
tasklist /FI "IMAGENAME eq knime.exe" 2>nul | find /I "knime.exe" >nul
if not errorlevel 1 (
  echo [%date% %time%] ERRO: o KNIME esta aberto. Fechar o KNIME por completo e voltar a executar. >> "%LOG%"
  exit /b 6
)
if not exist "%FLIGHTS%" (
  echo [%date% %time%] ERRO: %FLIGHTS% nao existe. Correr primeiro a extracao dos voos. >> "%LOG%"
  exit /b 2
)
if not exist "%KNIME_EXE%" (
  echo [%date% %time%] ERRO: knime.exe nao encontrado em %KNIME_EXE% >> "%LOG%"
  exit /b 3
)
if not exist "%WORKFLOW%\workflow.knime" (
  echo [%date% %time%] ERRO: workflow nao encontrado em %WORKFLOW% >> "%LOG%"
  exit /b 4
)

"%KNIME_EXE%" -nosplash -consolelog -reset -nosave ^
  -data "%BATCH_WS%" ^
  -application org.knime.product.KNIME_BATCH_APPLICATION ^
  -workflowDir="%WORKFLOW%" >> "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"

if "%RC%"=="0" (
  echo [%date% %time%] FIM OK (codigo %RC%) >> "%LOG%"
) else (
  echo [%date% %time%] ERRO KNIME (codigo %RC%). Ultimas linhas do registo do KNIME: >> "%LOG%"
  powershell -NoProfile -Command "Get-Content -Tail 40 -LiteralPath '%BATCH_WS%\.metadata\knime\knime.log'" >> "%LOG%" 2>&1
)
exit /b %RC%
