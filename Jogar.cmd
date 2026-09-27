@echo off
setlocal
cd /d "%~dp0"
if defined GODOT_BIN (
  "%GODOT_BIN%" --path "%~dp0."
  exit /b
)
if exist "%~dp0..\..\work\godot-4.7.2\Godot_v4.7.2-stable_win64.exe" (
  start "RutherFox" "%~dp0..\..\work\godot-4.7.2\Godot_v4.7.2-stable_win64.exe" --path "%~dp0."
  exit /b
)
where godot >nul 2>nul
if not errorlevel 1 (
  godot --path "%~dp0."
  exit /b
)
echo Abra project.godot no Godot 4.7.2 e pressione F5.
echo Voce tambem pode definir GODOT_BIN com o caminho do executavel do Godot.
pause
