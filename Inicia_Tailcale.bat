@echo off
setlocal

REM ======= CONFIGURAÇÕES ========
set "TASK_NAME=inicia Tailscale"
set "TS_PATH=C:\Program Files\Tailscale\tailscale-ipn.exe"
set "TS_ARGS="
set "USER_NAME=%USERNAME%"
REM =================================

REM Verifica se o executável existe
if not exist "%TS_PATH%" (
    echo ERRO: Caminho para tailscale-ipn.exe não encontrado:
    echo %TS_PATH%
    pause
    exit /b 1
)

REM Remove a tarefa se ela já existir
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorlevel%==0 (
    echo Tarefa "%TASK_NAME%" já existe. Removendo...
    schtasks /delete /tn "%TASK_NAME%" /f >nul
)

echo Criando nova tarefa "%TASK_NAME%" no Agendador de Tarefas...

schtasks /create ^
 /tn "%TASK_NAME%" ^
 /tr "\"%TS_PATH%\" %TS_ARGS%" ^
 /sc onstart ^
 /ru "%USER_NAME%" ^
 /rl highest ^
 /f

REM Agora ajusta a tarefa para NUNCA expirar via PowerShell
powershell -Command "Get-ScheduledTask -TaskName '%TASK_NAME%' | ForEach-Object { $_.Settings.ExecutionTimeLimit = 'PT0S'; Set-ScheduledTask -InputObject $_ }"

if %errorlevel% neq 0 (
    echo [ERRO] Falha ao criar ou configurar a tarefa.
) else (
    echo [OK] Tarefa criada com sucesso e configurada para nunca expirar.
)

pause
endlocal
