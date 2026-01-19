param(
    [string]$Action
)

$baseDir = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $baseDir

function Show-Menu {
    Clear-Host
    Write-Host "WordPress Environment Manager" -ForegroundColor Cyan
    Write-Host "-----------------------------"
    Write-Host "1. Start Environment"
    Write-Host "2. Stop Environment"
    Write-Host "3. Clear WordPress Cache"
    Write-Host "4. Backup Database & Files"
    Write-Host "5. View Logs (Tail)"
    Write-Host "Q. Quit"
    Write-Host "-----------------------------"
}

function Start-Env {
    Write-Host "Starting services..."
    docker-compose up -d
}

function Stop-Env {
    Write-Host "Stopping services..."
    docker-compose stop
}

function Clear-Cache {
    Write-Host "Flushing WordPress Object Cache..."
    docker-compose exec -u www-data wordpress wp cache flush
}

function Backup-Env {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $backupPath = Join-Path "backups" $timestamp
    New-Item -ItemType Directory -Force -Path $backupPath | Out-Null
    
    Write-Host "Backing up Database..."
    $dbFile = Join-Path $backupPath "db.sql"
    docker-compose exec -T db mysqldump -u wp_tester -pTestPassword123! wp_testing > $dbFile
    
    Write-Host "Backing up wp-content..."
    $contentZip = Join-Path $backupPath "wp-content.zip"
    Compress-Archive -Path "wordpress\wp-content" -DestinationPath $contentZip
    
    Write-Host "Backup created at $backupPath" -ForegroundColor Green
}

function View-Logs {
    Write-Host "Tailing logs (Ctrl+C to stop)..."
    Get-Content -Path "logs\*" -Wait -Tail 10
}

if ($Action) {
    switch ($Action) {
        "start" { Start-Env }
        "stop" { Stop-Env }
        "backup" { Backup-Env }
        "cache" { Clear-Cache }
    }
} else {
    do {
        Show-Menu
        $choice = Read-Host "Select an option"
        switch ($choice) {
            "1" { Start-Env }
            "2" { Stop-Env }
            "3" { Clear-Cache }
            "4" { Backup-Env }
            "5" { View-Logs }
            "Q" { exit }
            "q" { exit }
        }
        Pause
    } while ($true)
}