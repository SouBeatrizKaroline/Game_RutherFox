@echo off
setlocal
cd /d "%~dp0"
if exist "%~dp0RutherFox.exe" (
  start "RutherFox" "%~dp0RutherFox.exe"
  exit /b
)
if exist "%~dp0builds\RutherFox.exe" (
  start "RutherFox" "%~dp0builds\RutherFox.exe"
  exit /b
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch.ps1"
if errorlevel 1 (
  echo.
  echo Nao foi possivel abrir o jogo. A mensagem acima explica o problema.
  echo Os detalhes estao na pasta .runtime\logs ao lado de Jogar.cmd.
  pause
)

