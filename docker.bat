@echo off
setlocal EnableDelayedExpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Right-click and "Run as administrator" or use an elevated command prompt.
    pause
    exit /b 1
)

echo ===============================================
echo Docker Desktop Automated Installation
echo ===============================================
echo.

:: Set variables
set "DOCKER_URL=https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
set "INSTALLER_NAME=DockerDesktopInstaller.exe"
set "DOWNLOAD_PATH=%TEMP%\%INSTALLER_NAME%"

:: Improved function to check if a command exists
:commandExists
set "command=%~1"
set "command=!command:"=!"
where "!command!" >nul 2>&1
if !errorlevel! == 0 (
    exit /b 0
) else (
    exit /b 1
)

:: Check Windows version
echo Checking Windows version...
ver | find "10." > nul || ver | find "11." > nul
if %errorlevel% neq 0 (
    echo ERROR: Docker Desktop requires Windows 10 or Windows 11.
    echo This system does not appear to be running a supported version.
    pause
    exit /b 1
)

:: Check if WSL2 is available
echo Checking WSL2 availability...
wsl --list --quiet >nul 2>&1
if %errorlevel% neq 0 (
    echo WSL2 is not available. Installing WSL2 prerequisites...
    
    :: Enable WSL feature
    echo Enabling Windows Subsystem for Linux...
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    
    :: Enable Virtual Machine Platform
    echo Enabling Virtual Machine Platform...
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    echo.
    echo WSL2 features have been enabled.
    echo Please restart your computer and run this script again to continue.
    pause
    exit /b 0
)

:: Check if WSL2 is set as default
echo Checking WSL version...
wsl --set-default-version 2 >nul 2>&1
if %errorlevel% neq 0 (
    echo WSL2 requires an update. Please ensure you have the latest WSL2 kernel.
    echo You may need to install the WSL2 Linux kernel update package from:
    echo https://aka.ms/wsl2kernel
    echo.
    choice /c YN /M "Do you want to continue with installation anyway? (Y/N)"
    if !errorlevel! equ 2 (
        echo Installation cancelled.
        pause
        exit /b 0
    )
)

:: Check if Docker is already installed
echo Checking if Docker Desktop is already installed...
call :commandExists docker
if !errorlevel! equ 0 (
    echo Docker appears to be already installed.
    docker --version
    echo.
    choice /c YN /M "Do you want to reinstall Docker Desktop? (Y/N)"
    if !errorlevel! equ 2 (
        echo Installation cancelled.
        pause
        exit /b 0
    )
)

:: Download Docker Desktop installer
echo.
echo Downloading Docker Desktop installer...
powershell -Command "Invoke-WebRequest -Uri '%DOCKER_URL%' -OutFile '%DOWNLOAD_PATH%'" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Failed to download Docker Desktop installer.
    echo Please check your internet connection and try again.
    pause
    exit /b 1
)

echo Download completed successfully.

:: Install Docker Desktop
echo.
echo Installing Docker Desktop...
echo This may take several minutes. Please wait...
"%DOWNLOAD_PATH%" install --quiet --accept-license

if %errorlevel% equ 0 (
    echo.
    echo ===============================================
    echo Docker Desktop installed successfully!
    echo ===============================================
    echo.
    echo Please restart your computer to complete the installation.
    echo After restart, Docker Desktop should start automatically.
    
    :: Clean up installer
    del "%DOWNLOAD_PATH%" >nul 2>&1
    
    echo.
    choice /c YR /M "Do you want to restart now? (Y=Restart now, R=Restart later)"
    if %errorlevel% equ 1 (
        echo Restarting computer...
        shutdown /r /t 30 /c "Docker Desktop installation completed. Restarting to apply changes."
        echo Computer will restart in 30 seconds. Save your work.
    ) else (
        echo Please remember to restart your computer to complete the installation.
    )
) else (
    echo.
    echo ===============================================
    echo ERROR: Docker Desktop installation failed!
    echo ===============================================
    echo.
    echo Exit code: %errorlevel%
    echo Please check the following:
    echo 1. Ensure virtualization is enabled in BIOS
    echo 2. Check if Hyper-V is enabled
    echo 3. Verify sufficient disk space
    echo 4. Try installing manually from docker.com
)

echo.
pause
exit /b 0
