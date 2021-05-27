@echo off
cd %~dp0
lua.exe debugger.lua %~dp0 dll
pause
