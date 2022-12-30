

@echo off


@echo //Generated - do not edit!>Installer.txt
@echo. >> Installer.txt
@echo. >> Installer.txt
@echo. >> Installer.txt

@dir /A:D /B > FolderList.txt
for /f "tokens=*" %%D in (FolderList.txt) do (
echo found %%~nxD

cd %~dp0
@echo #include "%%D/GeneratedInstaller.event">>Installer.txt

cd %~dp0/%%~nxD

tmx2ea.py -s

@echo //Generated - do not edit!>GeneratedInstaller.txt
@echo. >> GeneratedInstaller.txt
@echo. >> GeneratedInstaller.txt
@echo. >> GeneratedInstaller.txt

@echo ALIGN 4 >> GeneratedInstaller.txt
@echo %%D_MapPiecesTable: >> GeneratedInstaller.txt
@echo { >> GeneratedInstaller.txt


@dir *.dmp /b > dmp.txt

setlocal enableextensions enabledelayedexpansion
set /a count = 0
@for /f "tokens=*" %%m in (dmp.txt) do (
echo POIN %%~nm >> GeneratedInstaller.txt
set /a count += 1
) 
@echo WORD 0 >> GeneratedInstaller.txt
@echo. >> GeneratedInstaller.txt

@echo. >> GeneratedInstaller.txt
setlocal enableextensions enabledelayedexpansion
@for /f "tokens=*" %%m in (dmp.txt) do (
echo ALIGN 4 >> GeneratedInstaller.txt
echo %%~nm: >> GeneratedInstaller.txt
echo #incbin "%%~nm.dmp" >> GeneratedInstaller.txt
) 
endlocal 
@echo } >> GeneratedInstaller.txt
echo ALIGN 4 >> GeneratedInstaller.txt
@echo %%D_NumberOfMapPieces: >> GeneratedInstaller.txt
@echo WORD !count! >> GeneratedInstaller.txt

@del dmp.txt

@rem type %~dp0/%%~nxD/GeneratedInstaller.txt > %~dp0/%%~nxD/GeneratedInstaller.event
@rem @del %~dp0/%%~nxD/GeneratedInstaller.txt

type GeneratedInstaller.txt > GeneratedInstaller.event
@del GeneratedInstaller.txt

)

cd %~dp0
type %~dp0Installer.txt > %~dp0Installer.event
@del %~dp0Installer.txt


pause 