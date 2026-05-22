@'
@echo off
setlocal enabledelayedexpansion

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR:~0,-1%"

REM Check if WSL is available
where wsl >nul 2>nul
if %errorlevel% equ 0 (
    wsl bash "%ROOT_DIR%/bin/sat" %*
    exit /b %errorlevel%
)

REM Check if Git Bash is available
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%ROOT_DIR%/bin/sat" %*
    exit /b %errorlevel%
)

echo Error: Neither WSL nor Git Bash found. Please install one of them.
echo For Windows subsystem, install WSL: https://aka.ms/wsl
echo Or install Git for Windows: https://git-scm.com/download/win
