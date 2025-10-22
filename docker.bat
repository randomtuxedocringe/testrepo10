@echo off
echo Starting Docker Desktop Download and Installation...
echo.

:: Set the download URL for Docker Desktop
set DOCKER_URL=https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe

:: Set the installation directory
set INSTALL_DIR=%TEMP%\DockerInstall
mkdir "%INSTALL_DIR%" 2>nul

echo Downloading Docker Desktop...
:: Use PowerShell to download the installer
powershell -Command "& {Invoke-WebRequest -Uri '%DOCKER_URL%' -OutFile '%INSTALL_DIR%\DockerDesktopInstaller.exe'}"

if %ERRORLEVEL% NEQ 0 (
    echo Failed to download Docker Desktop. Please check your internet connection and try again.
    goto :EOF
)

echo Download completed successfully.
echo.
echo Installing Docker Desktop...
echo This may take several minutes. Please wait...

:: Run the installer silently
"%INSTALL_DIR%\DockerDesktopInstaller.exe" install --quiet

if %ERRORLEVEL% NEQ 0 (
    echo Installation may have encountered issues.
    echo Please check if Docker Desktop was installed correctly.
) else (
    echo Docker Desktop has been successfully installed!
    echo You may need to restart your computer to complete the setup.
)

:: Clean up the installation files
echo Cleaning up temporary files...
rmdir /S /Q "%INSTALL_DIR%" 2>nul

echo.
echo Installation process completed.
pause
