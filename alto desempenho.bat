@echo off
:: Verifica se o script está rodando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

echo ========================================
echo Ativando plano de energia Alto Desempenho
echo ========================================

:: Duplica e ativa o plano Alto Desempenho
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

:: Captura o GUID do plano de energia ativo (opcional, para exibir no final)
FOR /F "tokens=3,* delims=:" %%i IN ('powercfg /getactivescheme') DO SET ActiveScheme=%%i

echo.
echo ========================================
echo Desativando desligamento de vídeo e suspensão
echo ========================================

:: DESLIGAMENTO DE VÍDEO
powercfg -change -monitor-timeout-ac 0
powercfg -change -monitor-timeout-dc 0

:: SUSPENSÃO DO COMPUTADOR
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0

echo.
echo ========================================
echo Configuracoes aplicadas com sucesso!
echo Plano ativo:%ActiveScheme%
echo ========================================
pause
