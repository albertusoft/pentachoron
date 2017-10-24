@echo off
setlocal EnableExtensions DisableDelayedExpansion

cd %~dp0
for /f "eol=# delims=" %%x in (local.conf) do (set "%%x")
cd ..

echo *** SET VARIABLES ***

set PATH=%WIN32_QT_ROOT%\bin;%WIN32_MINGW_PATH%\bin;%WIN32_QT_INSTALLER_PATH%\bin;%PATH%

set PROJECT_DIR=%cd%
set BUILD_DIR=%PROJECT_DIR%\%WIN32_BUILD_PATH%

REM # create lowercase names
for /f "usebackq delims=" %%I in (`powershell "\"%VENDOR_TLD%\".toLower()"`) do set "VENDOR_TLD_L=%%~I"
for /f "usebackq delims=" %%I in (`powershell "\"%VENDOR_NAME%\".toLower()"`) do set "VENDOR_NAME_L=%%~I"
for /f "usebackq delims=" %%I in (`powershell "\"%PRODUCT_NAME%\".toLower()"`) do set "PRODUCT_NAME_L=%%~I"

set PRODUCT_DESCRIPTION=%PRODUCT_DESCRIPTION:"=%

set WIN32_EXE_NAME=%PRODUCT_NAME_L%.exe
set WIN32_PACKAGE_DIR=%BUILD_DIR%\PACKAGE\packages\%VENDOR_TLD_L%.%VENDOR_NAME_L%.%PRODUCT_NAME_L%

echo -----------------------------------------------------------
echo PROJECT_DIR=%PROJECT_DIR%
echo BUILD_DIR=%BUILD_DIR%
echo WIN32_PACKAGE_DIR=%WIN32_PACKAGE_DIR%
echo -----------------------------------------------------------

echo *** BUILDING ***
cmake --build %BUILD_DIR%

echo *** DEPLOYING ***

REM # create build directory if not exists 
if not exist "%BUILD_DIR%\DEPLOYMENT" (mkdir "%BUILD_DIR%\DEPLOYMENT")
if not exist "%BUILD_DIR%\INSTALLER" (mkdir "%BUILD_DIR%\INSTALLER")
if not exist "%BUILD_DIR%\PACKAGE" (mkdir "%BUILD_DIR%\PACKAGE")
if not exist "%BUILD_DIR%\PACKAGE\config" (mkdir "%BUILD_DIR%\PACKAGE\config")
if not exist "%BUILD_DIR%\PACKAGE\packages" (mkdir "%BUILD_DIR%\PACKAGE\packages")
if not exist "%WIN32_PACKAGE_DIR%" (mkdir "%WIN32_PACKAGE_DIR%")
if not exist "%WIN32_PACKAGE_DIR%\data" (mkdir "%WIN32_PACKAGE_DIR%\data")
if not exist "%WIN32_PACKAGE_DIR%\meta" (mkdir "%WIN32_PACKAGE_DIR%\meta")

REM # collect all necessary files into DEPLOYMENT folder 
copy "%BUILD_DIR%\%WIN32_EXE_NAME%" "%BUILD_DIR%\DEPLOYMENT\%WIN32_EXE_NAME%"
windeployqt.exe --release --qmldir "%PROJECT_DIR%\src" "%BUILD_DIR%\DEPLOYMENT\%WIN32_EXE_NAME%"

echo *** COMPRESSING DATA ***

REM # compress DEPLOYMENT directory
archivegen.exe "%WIN32_PACKAGE_DIR%\data\main.7z" "%BUILD_DIR%\DEPLOYMENT\*"

echo *** CREATING INFO FILES ***

:copying_licenses
echo * copy license files for installer...
copy %PROJECT_DIR%\resources\doc\BSD2.txt %WIN32_PACKAGE_DIR%\meta\BSD2.txt

:create_configfile
echo * create config.xml ...
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Installer^>
echo     ^<Name^>%PRODUCT_NAME%^</Name^>
echo     ^<Version^>1.0.0^</Version^>
echo     ^<Title^>%PRODUCT_NAME% Installer^</Title^>
echo     ^<Publisher^>%VENDOR_NAME%</Publisher^>
echo     ^<StartMenuDir^>%PRODUCT_NAME%^</StartMenuDir^>
echo     ^<TargetDir^>@ApplicationsDirX86@/%PRODUCT_NAME%^</TargetDir^>
echo ^</Installer^>
) > %BUILD_DIR%\PACKAGE\config\config.xml

echo * create package.xml ...
for /f %%a in ('powershell -Command "Get-Date -format yyyy-MM-dd"') do set DATETIME=%%a
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Package^>
echo     ^<DisplayName^>%PRODUCT_NAME%^</DisplayName^>
echo     ^<Description^>%PRODUCT_DESCRIPTION%^</Description^>
echo     ^<Version^>1.0.0^</Version^>
echo     ^<ReleaseDate^>%DATETIME%^</ReleaseDate^>
echo     ^<Licenses^>
echo         ^<License name="2-clause BSD License" file="BSD2.txt" /^>
echo     ^</Licenses^>
echo     ^<Default^>true^</Default^>
echo     ^<Script^>installscript.qs^</Script^>
echo ^</Package^>
) > %WIN32_PACKAGE_DIR%\meta\package.xml

:create_installerscripts
echo * create installscript.qs ...
set "OUTF=%WIN32_PACKAGE_DIR%\meta\installscript.qs"
echo. >%OUTF%
echo function Component() { } >>%OUTF%
echo. >>%OUTF%
echo Component.prototype.createOperations = function() { >>%OUTF%
echo   try { >>%OUTF%
echo     component.createOperations(); >>%OUTF%
echo     if (installer.value("os") === "win") { >>%OUTF%
echo       try { >>%OUTF%
echo         component.addOperation( "CreateShortcut", "@TargetDir@/%PRODUCT_NAME%.exe", "@StartMenuDir@/pentachoron.lnk", "workingDirectory=@TargetDir@",  "description=%PRODUCT_DESCRIPTION%" ); >>%OUTF%
echo         component.addOperation( "CreateShortcut", "@TargetDir@/%PRODUCT_NAME%.exe", "@DesktopDir@/pentachoron.lnk", "workingDirectory=@TargetDir@",  "description=%PRODUCT_DESCRIPTION%" ); >>%OUTF%
echo       } catch (e) { >>%OUTF%
echo       } >>%OUTF%
echo     } >>%OUTF%
echo   } catch (e) { >>%OUTF%
echo     print(e); >>%OUTF%
echo   } >>%OUTF%
echo } >>%OUTF%

:build_installer
echo *** BUILDING THE INSTALLER ***

REM # build the installer
binarycreator.exe -c "%BUILD_DIR%\PACKAGE\config\config.xml" -p %BUILD_DIR%\PACKAGE\packages "%BUILD_DIR%\INSTALLER\%PRODUCT_NAME_L%-installer.exe"
