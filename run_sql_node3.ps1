# PowerShell script to run SQL files on Node 3
param(
    [Parameter(Mandatory=$true)]
    [string]$SqlFile
)

if (-not (Test-Path $SqlFile)) {
    Write-Host "Error: SQL file '$SqlFile' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Running $SqlFile on Node 3..." -ForegroundColor Cyan
Get-Content $SqlFile | docker exec -i oracle-node3 sqlplus system/Oracle123@XE

