echo off
tasm %1 /l/n/zi
if errorlevel 1 goto end
tlink /v/d %1
:end
