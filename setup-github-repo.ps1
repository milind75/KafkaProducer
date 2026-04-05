# GitHub Repository Setup Script
# Run this to create and push to GitHub repository

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$repoName = "rabbitmq-producer"
$username = "milind75"
$repoUrl = "https://github.com/$username/$repoName.git"

Write-Host "[Step 1/4] Checking Git status..." -ForegroundColor Yellow
git status

Write-Host ""
Write-Host "[Step 2/4] Setting up remote..." -ForegroundColor Yellow
Write-Host "Repository URL: $repoUrl" -ForegroundColor White

# Remove existing remote if it exists
git remote remove origin 2>$null

# Add new remote
git remote add origin $repoUrl

Write-Host ""
Write-Host "[Step 3/4] Instructions to create GitHub repository:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: https://github.com/new" -ForegroundColor Cyan
Write-Host "2. Repository name: $repoName" -ForegroundColor White
Write-Host "3. Description: RabbitMQ Producer Spring Boot Application with CI/CD" -ForegroundColor White
Write-Host "4. Choose 'Public' or 'Private'" -ForegroundColor White
Write-Host "5. Do NOT initialize with README" -ForegroundColor Red
Write-Host "6. Click 'Create repository'" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Have you created the repository on GitHub? (yes/no)"

if ($continue -eq "yes") {
    Write-Host ""
    Write-Host "[Step 4/4] Pushing to GitHub..." -ForegroundColor Yellow

    git branch -M main

    Write-Host "Pushing code..." -ForegroundColor White
    git push -u origin main

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Go to: https://github.com/$username/$repoName/settings/secrets/actions" -ForegroundColor Cyan
        Write-Host "2. Add GitHub Secrets (see CICD_QUICK_START.md)" -ForegroundColor White
        Write-Host "3. Configure EC2 security group" -ForegroundColor White
        Write-Host "4. Push code to trigger deployment!" -ForegroundColor White
        Write-Host ""
        Write-Host "Repository URL: https://github.com/$username/$repoName" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "✗ Push failed. Please check:" -ForegroundColor Red
        Write-Host "- Repository exists on GitHub" -ForegroundColor White
        Write-Host "- You have access to the repository" -ForegroundColor White
        Write-Host "- Your Git credentials are configured" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "Please create the repository on GitHub first, then run this script again." -ForegroundColor Yellow
    Write-Host "Repository URL: https://github.com/new" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

