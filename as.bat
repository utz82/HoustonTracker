
cd ..
@echo off
if %target% == ti82 goto 82P
if %target% == ti83 goto 83P
if %target% == ti8xp goto 8XP
if %target% == ti73 goto 73P
pause

:82P
tasm -80 -B -Q -R16 Housto~1\ti82\main.asm houston.obj
if errorlevel 1 goto ERRORS
CRPRGM82 HOUSTON.OBJ
del HOUSTON.OBJ >nul
del Housto~1\ti82\main.lst >nul
goto DDONE

:73P
tasm -80 -i -b Housto~1\ti73\main.asm houston.bin
if errorlevel 1 goto ERRORS
devpac83 houston
del houston.73p > nul
asm73 houston.83p
goto DONE

:8XP
echo #define TI83P >temp.z80
type Housto~1\ti8xp\main.asm >>temp.z80
tasm -80 -i -b temp.z80 ht.bin
if errorlevel 1 goto ERRORS
devpac83 ht.bin
copy ht.83p houston.8xp >nul
del ht.83p > nul
del ht.bin > nul
goto DONE

:83P
echo #define TI83 >temp.z80
type Housto~1\ti83\main.asm >>temp.z80
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