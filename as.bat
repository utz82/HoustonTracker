
cd ..
@echo off
if %target% == ti82 goto 82P
if %target% == r196 goto R196
if %target% == ti83 goto 83P
if %target% == ti8xp goto 8XP
if %target% == ti73 goto 73P
pause

:R196
echo 'Building for TI82 Parcus/ROM 19.006'
echo #define R196 >temp.z80
:82P
echo #define TI82 >>temp.z80
type Housto~1\merged\main.asm >>temp.z80
tasm -80 -B -Q -R16 temp.z80 houston.obj
if errorlevel 1 goto ERRORS
CRPRGM82 HOUSTON.OBJ
del HOUSTON.OBJ >nul
del temp.z80 >nul
del temp.lst >nul
goto DDONE

:73P
tasm -80 -i -b Housto~1\ti73\main.asm ht73.bin
if errorlevel 1 goto ERRORS
devpac83 ht73
del ht73.73p > nul
asm73 ht73.83p
copy ht73.73p houston.73p >nul
del ht73.73p >nul
del ht73.bin >nul
goto DONE

:8XP
echo #define TI83P >temp.z80
type Housto~1\ti8xp\main.asm >>temp.z80
tasm -80 -i -b temp.z80 ht.bin
if errorlevel 1 goto ERRORS
devpac83 ht
copy ht.83p houston.8xp >nul
del ht.83p > nul
del ht.bin > nul
goto DONE

:83P
echo #define TI83 >temp.z80
type Housto~1\merged\main.asm >>temp.z80
tasm -80 -i -b temp.z80 houston.bin
if errorlevel 1 goto ERRORS
devpac83 houston
del houston.bin >nul
echo ----- Success!
goto DONE
:ERRORS
echo ----- There were errors.
pause
:DONE
del temp.lst >nul
del temp.z80 >nul
:DDONE