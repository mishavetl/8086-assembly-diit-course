echo off
call COMPILE.BAT %1
if errorlevel 1 goto end
%1
:end
