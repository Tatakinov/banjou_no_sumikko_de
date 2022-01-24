@echo off
chcp 65001
cd /d "%~dp0"
lua.exe debugger.lua "%~dp0" dll
pause
