Write-Host "Generating Sample Data..."

$wp = "docker-compose exec -T -u www-data wordpress wp"

# Check if WP is ready
Write-Host "Checking WordPress connection..."
Invoke-Expression "$wp core is-installed"
if ($LASTEXITCODE -ne 0) {
    Write-Host "WordPress is not installed or running. Please install WordPress via the browser first." -ForegroundColor Red
    exit
}

# Create Users
Write-Host "Creating 10 Users..."
for ($i=1; $i -le 10; $i++) {
    $user = "testuser$i"
    $email = "testuser$i@local-test-site.dev"
    Invoke-Expression "$wp user create $user $email --role=subscriber --user_pass=password123"
}

# Create Posts
Write-Host "Creating 5 Posts..."
for ($i=1; $i -le 5; $i++) {
    Invoke-Expression "$wp post create --post_type=post --post_title='Test Post $i' --post_content='This is a test post content for QA.' --post_status=publish"
}

Write-Host "Data Generation Complete."
