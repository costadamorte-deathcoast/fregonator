# FREGONATOR Quick Installer
# Usage: irm https://fregonator.com/install.ps1 | iex

$ErrorActionPreference = "Stop"
$repo = "dthcst/fregonator"
$installPath = "$env:ProgramFiles\FREGONATOR"

# Banner
Write-Host ""
Write-Host "  ███████╗██████╗ ███████╗ ██████╗  ██████╗ ███╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗ " -ForegroundColor Cyan
Write-Host "  ██╔════╝██╔══██╗██╔════╝██╔════╝ ██╔═══██╗████╗  ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗" -ForegroundColor Cyan
Write-Host "  █████╗  ██████╔╝█████╗  ██║  ███╗██║   ██║██╔██╗ ██║███████║   ██║   ██║   ██║██████╔╝" -ForegroundColor Cyan
Write-Host "  ██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██║   ██║██║╚██╗██║██╔══██║   ██║   ██║   ██║██╔══██╗" -ForegroundColor Cyan
Write-Host "  ██║     ██║  ██║███████╗╚██████╔╝╚██████╔╝██║ ╚████║██║  ██║   ██║   ╚██████╔╝██║  ██║" -ForegroundColor Cyan
Write-Host "  ╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Quick Installer - https://fregonator.com" -ForegroundColor White
Write-Host ""

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "  [!] Requesting admin privileges..." -ForegroundColor Yellow
    $script = [System.IO.Path]::GetTempFileName() + ".ps1"
    Invoke-RestMethod "https://raw.githubusercontent.com/$repo/main/install.ps1" -OutFile $script
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$script`"" -Verb RunAs
    exit
}

try {
    # Download from main branch
    Write-Host "  [1/4] Fetching latest version..." -ForegroundColor Yellow
    $downloadUrl = "https://github.com/$repo/archive/refs/heads/main.zip"
    $version = "v4.0"

    # Download
    Write-Host "  [2/4] Downloading FREGONATOR $version..." -ForegroundColor Yellow
    $tempZip = "$env:TEMP\fregonator-install.zip"
    $tempDir = "$env:TEMP\fregonator-extract"

    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing
    Write-Host "        Downloaded!" -ForegroundColor Green

    # Extract
    Write-Host "  [3/4] Installing to $installPath..." -ForegroundColor Yellow

    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    # Find extracted folder (could be fregonator-main or just files)
    $sourceDir = Get-ChildItem $tempDir -Directory | Select-Object -First 1
    if ($sourceDir) {
        $sourceDir = $sourceDir.FullName
    } else {
        $sourceDir = $tempDir
    }

    # Create install directory
    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    }

    # Copy files
    Copy-Item "$sourceDir\*" -Destination $installPath -Recurse -Force
    Write-Host "        Installed!" -ForegroundColor Green

    # Create shortcuts
    Write-Host "  [4/4] Creating shortcuts..." -ForegroundColor Yellow

    $WshShell = New-Object -ComObject WScript.Shell

    # Desktop shortcut
    $desktopLink = "$env:USERPROFILE\Desktop\FREGONATOR.lnk"
    $shortcut = $WshShell.CreateShortcut($desktopLink)
    $shortcut.TargetPath = "$installPath\FREGONATOR.bat"
    $shortcut.WorkingDirectory = $installPath
    $shortcut.IconLocation = "$installPath\fregonator.ico"
    $shortcut.Description = "FREGONATOR - PC Optimizer"
    $shortcut.Save()

    # Start Menu shortcut
    $startMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\FREGONATOR.lnk"
    $shortcut2 = $WshShell.CreateShortcut($startMenu)
    $shortcut2.TargetPath = "$installPath\FREGONATOR.bat"
    $shortcut2.WorkingDirectory = $installPath
    $shortcut2.IconLocation = "$installPath\fregonator.ico"
    $shortcut2.Description = "FREGONATOR - PC Optimizer"
    $shortcut2.Save()

    Write-Host "        Shortcuts created!" -ForegroundColor Green

    # Cleanup
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "  FREGONATOR installed successfully!" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Location: $installPath" -ForegroundColor White
    Write-Host "  Shortcut: Desktop + Start Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "  Run it now? (Y/N): " -ForegroundColor Yellow -NoNewline
    $run = Read-Host

    if ($run -eq "Y" -or $run -eq "y") {
        Start-Process "$installPath\FREGONATOR.bat" -WorkingDirectory $installPath
    }

} catch {
    Write-Host ""
    Write-Host "  [ERROR] Installation failed: $_" -ForegroundColor Red
    Write-Host "  Try downloading manually from: https://fregonator.com" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  Press Enter to exit..." -ForegroundColor Gray
Read-Host
