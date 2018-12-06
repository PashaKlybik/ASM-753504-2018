@echo off
tasm\tasm /zd /zi labsix.asm
if errorlevel 1 goto end
tasm\tlink /t /x labsix.obj
if errorlevel 1 goto end
del labsix.obj
labsix
:end