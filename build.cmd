@echo off
rem Build Digger Map Editor: FPC 3.2.2 i8086-msdos, small memory model.
rem 1) assemble asm\*.asm -> asm\*.obj (OMF, linked by {$L} in the units)
rem 2) compile and link run_dme.exe
rem Usage: build.cmd [program.pas]   (default run_dme.pas)

setlocal
if "%FPCBIN%"=="" set FPCBIN=C:\FPC\3.2.2\bin\i386-win32
set PROG=%1
if "%PROG%"=="" set PROG=run_dme.pas

for %%f in (asm\*.asm) do (
  echo Assembling %%f
  "%FPCBIN%\nasm.exe" -f obj -o "asm\%%~nf.obj" "%%f" || exit /b 1
)

rem -B: rebuild all units, FPC does not track changes of the .obj files
"%FPCBIN%\fpc.exe" -Pi8086 -Tmsdos -WmSmall -B %PROG% || exit /b 1
