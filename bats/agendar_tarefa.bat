@echo off
REM ============================================================
REM  Cria (uma so vez) a tarefa agendada do Windows que corre o
REM  run_pipeline.bat todos os domingos as 02:30, depois da extracao
REM  do Node-RED (01:00 meteorologia, 01:10 aeroportos, 01:20 voos).
REM  Duplo clique para executar. Para remover:
REM     schtasks /Delete /TN "ISI_TP1_Pipeline_KNIME" /F
REM ============================================================
schtasks /Create /TN "ISI_TP1_Pipeline_KNIME" /TR "\"%~dp0run_pipeline.bat\"" /SC WEEKLY /D SUN /ST 02:30 /F
echo.
schtasks /Query /TN "ISI_TP1_Pipeline_KNIME" /FO LIST
pause
