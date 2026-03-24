@echo off
setlocal EnableExtensions

cd /d "%~dp0"

rem Check that a 32-bit Python 3 launcher tag is available.
py -3-32 --version >nul 2>&1
if errorlevel 1 (
    echo [bootstrap_scraper] 32-bit Python 3 not found. Attempting to install...

    rem Determine the version of the default Python interpreter.
    for /f "tokens=2 delims= " %%V in ('py --version 2^>^&1') do set "PY_VER=%%V"
    for /f "tokens=1,2 delims=." %%A in ("%PY_VER%") do set "PY_MAJMIN=%%A.%%B"

    echo [bootstrap_scraper] Detected default Python %PY_VER%. Installing Python %PY_MAJMIN% (32-bit) via winget...
    winget install --id Python.Python.3.%PY_MAJMIN:~2% --architecture x86 --silent --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo [bootstrap_scraper] ERROR: winget install failed.
        echo [bootstrap_scraper] Please install a 32-bit Python 3 manually from https://www.python.org/downloads/windows/
        echo [bootstrap_scraper] and ensure "py -3-32" resolves it via the Python Launcher.
        exit /b 1
    )

    py -3-32 --version >nul 2>&1
    if errorlevel 1 (
        echo [bootstrap_scraper] ERROR: Installed but "py -3-32" still not found.
        echo [bootstrap_scraper] You may need to restart this terminal so the Python Launcher picks it up.
        exit /b 1
    )
    echo [bootstrap_scraper] 32-bit Python installed successfully.
)

if not exist ".venv32\Scripts\python.exe" (
    echo [bootstrap_scraper] Creating 32-bit virtual environment...
    py -3-32 -m venv ".venv32"
    if errorlevel 1 (
        echo [bootstrap_scraper] ERROR: Failed to create 32-bit venv.
        exit /b 1
    )
)

echo [bootstrap_scraper] Ensuring scraper dependencies are installed...
".venv32\Scripts\python.exe" -m pip install --quiet -r requirements.txt
if errorlevel 1 (
    echo [bootstrap_scraper] ERROR: Failed to install dependencies.
    exit /b 1
)

exit /b 0