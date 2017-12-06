@echo off
setlocal EnableExtensions DisableDelayedExpansion

cd %~dp0
cd ..
for /f "eol=# delims=" %%x in (local.conf) do (set "%%x")

set PATH=%WIN32_QT_ROOT%\bin;%WIN32_MINGW_PATH%\bin;%PATH%

set PROJECT_DIR=%cd%
set BUILD_DIR=%PROJECT_DIR%\%WIN32_BUILD_PATH%

echo

echo "-------------------------------------------------------------------------"

echo "PROJECT_DIR=%PROJECT_DIR%

echo "BUILD_DIR=%BUILD_DIR%
echo "-------------------------------------------------------------------------"

REM # create build directory if not exists 
if not exist "%BUILD_DIR%" (mkdir "%BUILD_DIR%")

REM # enter into build directory
cd %BUILD_DIR%

REM # run cmake
cmake %PROJECT_DIR% -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%WIN32_QT_ROOT%
