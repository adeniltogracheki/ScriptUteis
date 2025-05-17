@echo off
setlocal enabledelayedexpansion

:: Verifica se o script está rodando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs" -WindowStyle Hidden
    exit /b
)


:: Primeiro muda para o plano equilibrado antes de excluir outros planos
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1

:: Depois exclui planos de alto desempenho antigos (silenciosamente)
:: Método 1: Excluir por comandos PowerCfg
for /f "tokens=2,3,4* delims=:()" %%a in ('powercfg -list 2^>nul ^| findstr /i "alto desempenho high performance ultimate performance" 2^>nul') do (
    set "guid=%%a"
    set "guid=!guid: =!"
    set "guid=!guid:~0,36!"
    
    powercfg -delete !guid! >nul 2>&1
)

:: Método 2: Remover via registro
set "REG_POWER_PATH=HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes"
set "HIGH_PERF_GUID=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
set "ULTIMATE_PERF_GUID=e9a42b02-d5df-448d-aa00-03f14749eb61"

reg delete "%REG_POWER_PATH%\%HIGH_PERF_GUID%" /f >nul 2>&1
reg delete "%REG_POWER_PATH%\%ULTIMATE_PERF_GUID%" /f >nul 2>&1

:: Método 3: Desativar pelo PowerCfg attributes
powercfg -setacvalueindex SCHEME_BALANCED SUB_NONE PERFBOOSTMODE 0 >nul 2>&1
powercfg -setdcvalueindex SCHEME_BALANCED SUB_NONE PERFBOOSTMODE 0 >nul 2>&1

:: Restaurando planos de energia padrão...
powercfg -restoredefaultschemes

:: Aguarda 2 segundos
timeout /t 2 >nul


:: Parte para criar e ativar plano de energia Alto Desempenho - COMANDO ATUALIZADO
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
:: Captura o GUID do plano de energia ativo (opcional, para exibir no final)
FOR /F "tokens=3,* delims=:" %%i IN ('powercfg /getactivescheme') DO SET ActiveScheme=%%i


:: Desligamento de vídeo e suspensão (silenciosamente)
powercfg -change -monitor-timeout-ac 0 >nul 2>&1
powercfg -change -monitor-timeout-dc 0 >nul 2>&1
powercfg -change -standby-timeout-ac 0 >nul 2>&1
powercfg -change -standby-timeout-dc 0 >nul 2>&1

:: Exibir mensagem grande por 10 segundos e fechar automaticamente
cls
color 2
echo.
echo.
echo  **************************************************
echo  *                                                *
echo  *             ALTO DESEMPENHO                    *
echo  *              ATIVADO COM                       *
echo  *                SUCESSO!                        *
echo  *                                                *
echo  *         Criado por: Adenilto Gracheki          *
echo  **************************************************
echo.
echo  ===============================================
echo    [+] Mudado para plano Equilibrado temporariamente
echo    [+] Planos antigos excluidos com seguranca
echo    [+] Novo plano de energia configurado
echo    [+] Monitor configurado para nunca desligar
echo    [+] Sistema configurado para nunca suspender
echo  ===============================================
echo.
echo    Plano ativo:%ActiveScheme%
echo.
echo    TODAS AS CONFIGURACOES FORAM APLICADAS!
echo.
echo    O sistema esta otimizado para desempenho maximo
echo.
echo    Esta janela fechara em 10 segundos...
echo.

:: Esperar 5 segundos e fechar automaticamente
ping -n 11 127.0.0.1 >nul 2>&1
exit
