@echo off
chcp 65001
cd %~dp0
lua.exe debugger.lua %~dp0 dll
pause
