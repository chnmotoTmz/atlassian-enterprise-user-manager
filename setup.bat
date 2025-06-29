@echo off
:: ========================================
:: Atlassian Enterprise User Manager
:: Windows Batch Setup Script
:: ========================================

setlocal enabledelayedexpansion

echo.
echo 🏢 Atlassian Enterprise User Manager - Windows Setup
echo =====================================================
echo.

:: Check for PowerShell
powershell -Command "exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PowerShell is required but not found
    echo Please install PowerShell from: https://github.com/PowerShell/PowerShell
    pause
    exit /b 1
)

:: Check execution policy
for /f "tokens=*" %%i in ('powershell -Command "Get-ExecutionPolicy"') do set EXEC_POLICY=%%i

if /i "!EXEC_POLICY!"=="Restricted" (
    echo ⚠️ PowerShell execution policy is restricted
    echo.
    echo To fix this, run PowerShell as Administrator and execute:
    echo Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    echo.
    echo Alternatively, you can run the setup with:
    echo powershell -ExecutionPolicy Bypass -File "scripts\setup.ps1"
    echo.
    choice /c YN /m "Do you want to continue with bypass? (Y/N)"
    if !errorlevel! equ 2 (
        echo Setup cancelled
        pause
        exit /b 1
    )
    set BYPASS_POLICY=-ExecutionPolicy Bypass
) else (
    set BYPASS_POLICY=
)

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ Not running as administrator
    echo Some installations may require administrator privileges
    echo.
    choice /c YN /m "Continue anyway? (Y/N)"
    if !errorlevel! equ 2 (
        echo.
        echo To run as administrator:
        echo 1. Right-click on Command Prompt
        echo 2. Select "Run as administrator"
        echo 3. Navigate to this directory and run setup.bat again
        pause
        exit /b 1
    )
) else (
    echo ✅ Running with administrator privileges
)

:: Display options
echo.
echo 📋 Setup Options:
echo ================
echo.
echo [1] Full setup (recommended)
echo [2] Skip Node.js installation
echo [3] Skip MongoDB installation  
echo [4] Skip Redis installation
echo [5] Skip Docker installation
echo [6] Custom setup (choose components)
echo [7] Quiet mode (no prompts)
echo [0] Exit
echo.

set /p choice="Select option (1-7, 0 to exit): "

set SKIP_PARAMS=

if "!choice!"=="0" (
    echo Setup cancelled
    exit /b 0
)

if "!choice!"=="1" (
    echo Running full setup...
    set SKIP_PARAMS=
) else if "!choice!"=="2" (
    echo Skipping Node.js installation...
    set SKIP_PARAMS=-SkipNodeJS
) else if "!choice!"=="3" (
    echo Skipping MongoDB installation...
    set SKIP_PARAMS=-SkipMongoDB
) else if "!choice!"=="4" (
    echo Skipping Redis installation...
    set SKIP_PARAMS=-SkipRedis
) else if "!choice!"=="5" (
    echo Skipping Docker installation...
    set SKIP_PARAMS=-SkipDocker
) else if "!choice!"=="6" (
    echo.
    echo Custom Setup Configuration:
    echo ==========================
    
    choice /c YN /m "Skip Node.js? (Y/N)"
    if !errorlevel! equ 1 set SKIP_PARAMS=!SKIP_PARAMS! -SkipNodeJS
    
    choice /c YN /m "Skip MongoDB? (Y/N)"
    if !errorlevel! equ 1 set SKIP_PARAMS=!SKIP_PARAMS! -SkipMongoDB
    
    choice /c YN /m "Skip Redis? (Y/N)"
    if !errorlevel! equ 1 set SKIP_PARAMS=!SKIP_PARAMS! -SkipRedis
    
    choice /c YN /m "Skip Docker? (Y/N)"
    if !errorlevel! equ 1 set SKIP_PARAMS=!SKIP_PARAMS! -SkipDocker
    
) else if "!choice!"=="7" (
    echo Running in quiet mode...
    set SKIP_PARAMS=-QuietMode
) else (
    echo Invalid choice. Running full setup...
    set SKIP_PARAMS=
)

echo.
echo 🚀 Starting PowerShell setup script...
echo ======================================

:: Check if PowerShell script exists
if not exist "scripts\setup.ps1" (
    echo ❌ PowerShell setup script not found: scripts\setup.ps1
    echo.
    echo Please ensure you're running this from the project root directory
    echo and that all files have been properly downloaded.
    pause
    exit /b 1
)

:: Run PowerShell setup script
echo Executing: powershell !BYPASS_POLICY! -File "scripts\setup.ps1" !SKIP_PARAMS!
echo.

powershell !BYPASS_POLICY! -File "scripts\setup.ps1" !SKIP_PARAMS!

set PS_EXIT_CODE=%errorlevel%

echo.
echo ========================================

if %PS_EXIT_CODE% equ 0 (
    echo ✅ Setup completed successfully!
    echo.
    echo 🌐 Next Steps:
    echo 1. Edit .env file with your Atlassian API credentials
    echo 2. Open http://localhost:3000 in your browser
    echo 3. Check the documentation in the docs folder
    echo.
    echo 💡 Tip: Desktop shortcuts have been created for easy access
) else (
    echo ❌ Setup encountered errors (Exit Code: %PS_EXIT_CODE%)
    echo.
    echo 🔧 Troubleshooting:
    echo - Check if you have administrator privileges
    echo - Ensure internet connection is stable
    echo - Try running components individually
    echo - Check the PowerShell script output for specific errors
    echo.
    echo 📞 For help, visit:
    echo https://github.com/chnmotoTmz/atlassian-enterprise-user-manager/issues
)

echo.
echo 📁 Project Location: %CD%
echo 🔧 Configuration File: .env
echo 📚 Documentation: docs\
echo.

pause
exit /b %PS_EXIT_CODE%
