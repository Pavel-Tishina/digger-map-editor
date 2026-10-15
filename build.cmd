@echo off
rem Build Digger Map Editor: FPC 3.2.2 i8086-msdos, small memory model.
rem 1) assemble asm\*.asm -> asm\*.obj (OMF, linked by {$L} in the units)
rem 2) compile and link run_dme.exe
rem 3) compress the exe with UPX
rem Usage: build.cmd [program.pas]   (default run_dme.pas)
rem Env:   FPCBIN - FPC bin directory, NASM - path to nasm.exe (default %FPCBIN%\nasm.exe),
rem        UPXEXE - path to upx.exe (default %FPCBIN%\upx.exe, then upx.exe from PATH)

setlocal
if "%FPCBIN%"=="" set FPCBIN=C:\FPC\3.2.2\bin\i386-win32
if "%NASM%"=="" set NASM=%FPCBIN%\nasm.exe
rem UPXEXE, not UPX: upx.exe reads its options from the UPX variable
if "%UPXEXE%"=="" if exist "%FPCBIN%\upx.exe" set UPXEXE=%FPCBIN%\upx.exe
if "%UPXEXE%"=="" for %%u in (upx.exe) do set UPXEXE=%%~$PATH:u
if "%UPXEXE%"=="" (
  echo UPX not found: put upx.exe into %FPCBIN% or PATH, or set UPXEXE
  exit /b 1
)
set PROG=%1
if "%PROG%"=="" set PROG=run_dme.pas
for %%p in (%PROG%) do set EXE=%%~dpnp.exe

for %%f in (asm\*.asm) do (
  echo Assembling %%f
  "%NASM%" -f obj -o "asm\%%~nf.obj" "%%f" || exit /b 1
)

rem -B: rebuild all units, FPC does not track changes of the .obj files
rem -O2 -Os: smallest code (-O3 gives the same size)
rem -Xs: strip symbols when linking (GNU strip does not support MZ exe)
"%FPCBIN%\fpc.exe" -Pi8086 -Tmsdos -WmSmall -O2 -Os -Xs -B %PROG% || exit /b 1

rem --8086: the unpacker runs on 8086 too (by default it needs a 286)
rem --ultra-brute: tries all methods, 32K exe takes a second; --best is ~40 bytes larger
echo Compressing %EXE%
"%UPXEXE%" -q --8086 --ultra-brute "%EXE%" || exit /b 1
"%UPXEXE%" -q -t "%EXE%" || exit /b 1
