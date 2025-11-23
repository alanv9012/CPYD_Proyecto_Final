# Master setup script for the distributed banks system

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Setting Up Distributed Banks System" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Step 0: Check if Oracle containers are running
Write-Host "Checking Oracle containers..." -ForegroundColor Yellow
$oracleRunning = docker ps --filter "name=oracle-node" --format "{{.Names}}" | Measure-Object -Line
if ($oracleRunning.Lines -lt 3) {
    Write-Host "Oracle containers not running. Starting them..." -ForegroundColor Yellow
    docker-compose -f docker-compose-oracle.yml up -d
    Write-Host "Waiting for Oracle databases to initialize (this may take 5-10 minutes)..." -ForegroundColor Yellow
    Write-Host "You can check progress with: docker-compose -f docker-compose-oracle.yml logs -f" -ForegroundColor Gray
    $response = Read-Host "Press Enter when databases are ready (check logs for 'DATABASE IS READY TO USE!')"
} else {
    Write-Host "✓ Oracle containers are running" -ForegroundColor Green
}

# Step 1: Setup Database Links
Write-Host ""
Write-Host "Step 1: Setting up database links..." -ForegroundColor Yellow
.\run_sql_node1.ps1 00_setup_database_links.sql
.\run_sql_node2.ps1 00_setup_database_links.sql
.\run_sql_node3.ps1 00_setup_database_links.sql

# Step 2: Start MySQL
Write-Host ""
Write-Host "Step 2: Starting MySQL container..." -ForegroundColor Yellow
docker-compose -f docker-compose-mysql.yml up -d

Write-Host "Waiting for MySQL to be ready..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Step 3: Create tables on Oracle nodes
Write-Host ""
Write-Host "Step 3: Creating tables on Oracle Node 1 (Region A)..." -ForegroundColor Yellow
.\run_sql_node1.ps1 01_create_tables_node1.sql

Write-Host ""
Write-Host "Step 4: Creating tables on Oracle Node 2 (Region B)..." -ForegroundColor Yellow
.\run_sql_node2.ps1 02_create_tables_node2.sql

Write-Host ""
Write-Host "Step 5: Creating tables on Oracle Node 3 (Full Replication)..." -ForegroundColor Yellow
.\run_sql_node3.ps1 03_create_tables_node3.sql

# Step 4: Create tables in MySQL
Write-Host ""
Write-Host "Step 6: Creating tables in MySQL..." -ForegroundColor Yellow
.\setup_mysql.ps1

# Step 5: Sync data from Node 3 to MySQL
Write-Host ""
Write-Host "Step 7: Syncing data from Node 3 to MySQL..." -ForegroundColor Yellow
Write-Host "This will copy all data from Oracle Node 3 to MySQL as backup" -ForegroundColor Gray
python sync_node3_to_mysql.py

# Step 6: Create global views
Write-Host ""
Write-Host "Step 8: Creating global views on Node 1..." -ForegroundColor Yellow
.\run_sql_node1.ps1 05_create_global_views.sql

Write-Host ""
Write-Host "Step 9: Creating global views on Node 2..." -ForegroundColor Yellow
.\run_sql_node2.ps1 05_create_global_views.sql

Write-Host ""
Write-Host "Step 10: Creating global views on Node 3..." -ForegroundColor Yellow
.\run_sql_node3.ps1 05_create_global_views.sql

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now run the application:" -ForegroundColor Yellow
Write-Host "  python bank_app.py" -ForegroundColor White
Write-Host ""

