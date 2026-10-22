# LemonSign Core Engine Encryption Script
param (
    [string]$Password = "Tuananh280907@"
)

$coreDir = "Zsign"
$tarFile = "lemon_core.tar.gz"
$encFile = "lemon_core.enc"

if (!(Test-Path $coreDir)) {
    Write-Error "Directory $coreDir not found!"
    exit 1
}

Write-Host "📦 Compressing $coreDir..." -ForegroundColor Cyan
tar -czf $tarFile $coreDir

Write-Host "🔐 Encrypting with AES-256-CBC (PBKDF2 100,000 rounds)..." -ForegroundColor Yellow
$opensslCmd = "openssl"
if (Get-Command openssl -ErrorAction SilentlyContinue) {
    & openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in $tarFile -out $encFile -pass "pass:$Password"
} elseif (Test-Path "C:\Program Files\Git\usr\bin\openssl.exe") {
    & "C:\Program Files\Git\usr\bin\openssl.exe" enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in $tarFile -out $encFile -pass "pass:$Password"
} else {
    Write-Error "OpenSSL not found!"
    Remove-Item $tarFile -Force
    exit 1
}

Remove-Item $tarFile -Force
Write-Host "✅ Encryption complete! Output: $encFile" -ForegroundColor Green
