# Iniciar todos los servicios de EntradasYa localmente
Write-Host "Iniciando Mailpit..." -ForegroundColor Cyan
Start-Process -FilePath "mailpit" -WindowStyle Minimized

Write-Host "Iniciando Auth (Puerto 3001)..." -ForegroundColor Green
Start-Process -FilePath "node" -ArgumentList "src/index.js" -WorkingDirectory "$PSScriptRoot\auth" -WindowStyle Minimized

Write-Host "Iniciando Events (Puerto 3002)..." -ForegroundColor Green
Start-Process -FilePath "$PSScriptRoot\events\.venv\Scripts\uvicorn.exe" -ArgumentList "app.main:app --port 3002" -WorkingDirectory "$PSScriptRoot\events" -WindowStyle Minimized

Write-Host "Iniciando Payments (Puerto 3003)..." -ForegroundColor Green
Start-Process -FilePath "$PSScriptRoot\payments\payments.exe" -WorkingDirectory "$PSScriptRoot\payments" -WindowStyle Minimized

Write-Host "Iniciando Tickets (Puerto 3004)..." -ForegroundColor Green
Start-Process -FilePath "$PSScriptRoot\tickets\.venv\Scripts\uvicorn.exe" -ArgumentList "app.main:app --port 3004" -WorkingDirectory "$PSScriptRoot\tickets" -WindowStyle Minimized

Write-Host "Iniciando Notifications (Puerto 3005)..." -ForegroundColor Green
Start-Process -FilePath "node" -ArgumentList "src/index.js" -WorkingDirectory "$PSScriptRoot\notifications" -WindowStyle Minimized

Write-Host "Iniciando Orders (Puerto 3006)..." -ForegroundColor Green
Start-Process -FilePath "dotnet" -ArgumentList "run --no-build" -WorkingDirectory "$PSScriptRoot\orders" -WindowStyle Minimized

Write-Host "Iniciando Checkin (Puerto 3007)..." -ForegroundColor Green
Start-Process -FilePath "$PSScriptRoot\checkin\checkin.exe" -WorkingDirectory "$PSScriptRoot\checkin" -WindowStyle Minimized

Write-Host "Iniciando Frontend Web (Puerto 5173)..." -ForegroundColor Yellow
Start-Process -FilePath "npm" -ArgumentList "run dev" -WorkingDirectory "$PSScriptRoot\web"

Write-Host ""
Write-Host "Todos los servicios han sido lanzados." -ForegroundColor Cyan
Write-Host "Frontend disponible en: http://localhost:5173" -ForegroundColor White
Write-Host "Mailpit disponible en:  http://localhost:8025" -ForegroundColor White
