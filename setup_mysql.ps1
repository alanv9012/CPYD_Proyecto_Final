# PowerShell script to setup MySQL database

Write-Host "Setting up MySQL database..." -ForegroundColor Cyan

# Wait for MySQL to be ready
Start-Sleep -Seconds 5

# Run the SQL script
Get-Content 04_create_tables_mysql.sql | docker exec -i mysql-bank mysql -ubankuser -pbankpass123 bankdb

Write-Host "MySQL setup complete!" -ForegroundColor Green

