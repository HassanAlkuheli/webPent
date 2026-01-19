# WordPress Testing Environment Setup Script
$ErrorActionPreference = "Stop"

$currentDir = Get-Location
$wpDir = Join-Path $currentDir "wordpress"
$pluginsDir = Join-Path $wpDir "wp-content\plugins"

Write-Host "Setting up WordPress Testing Environment..." -ForegroundColor Green

# 1. Create Directory Structure
Write-Host "Creating directories..."
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $currentDir "logs") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $currentDir "backups") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $currentDir "database") | Out-Null

# 2. Download Ninja Forms 3.8.4
$ninjaUrl = "https://downloads.wordpress.org/plugin/ninja-forms.3.8.4.zip"
$ninjaZip = Join-Path $currentDir "ninja-forms.zip"
$ninjaDest = Join-Path $pluginsDir "ninja-forms"

if (-not (Test-Path $ninjaDest)) {
    Write-Host "Downloading Ninja Forms 3.8.4..."
    Invoke-WebRequest -Uri $ninjaUrl -OutFile $ninjaZip
    
    Write-Host "Extracting Ninja Forms..."
    Expand-Archive -Path $ninjaZip -DestinationPath $pluginsDir
    Remove-Item $ninjaZip
} else {
    Write-Host "Ninja Forms already installed."
}

# 3. Create Maintenance Scripts
$manageScriptPath = Join-Path $currentDir "scripts\manage.bat"
$manageContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0manage.ps1" %*
"@
Set-Content -Path $manageScriptPath -Value $manageContent

# 4. Instructions
Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "`nIMPORTANT MANUAL STEPS:" -ForegroundColor Yellow
Write-Host "1. Add the following line to C:\Windows\System32\drivers\etc\hosts (requires Admin):"
Write-Host "   127.0.0.1 local-test-site.dev" -ForegroundColor White
Write-Host "2. Run 'docker-compose up -d --build' to start the environment."
Write-Host "3. Access the site at http://local-test-site.dev:8080"
Write-Host "4. Use 'scripts\manage.bat' for maintenance tasks."
