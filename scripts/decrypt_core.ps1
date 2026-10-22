# LemonSign Core Engine Decryption Script
param (
    [string]$Password = "Tuananh280907@"
)

$encFile = "lemon_core.enc"
$tarFile = "lemon_core.tar.gz"

if (!(Test-Path $encFile)) {
    Write-Error "Encrypted file $encFile not found!"
    exit 1
}

Write-Host "🔓 Decrypting $encFile with master password..." -ForegroundColor Yellow
if (Get-Command openssl -ErrorAction SilentlyContinue) {
    & openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -in $encFile -out $tarFile -pass "pass:$Password"
} elseif (Test-Path "C:\Program Files\Git\usr\bin\openssl.exe") {
    & "C:\Program Files\Git\usr\bin\openssl.exe" enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -in $encFile -out $tarFile -pass "pass:$Password"
} else {
    Write-Error "OpenSSL not found!"
    exit 1
}

if (!(Test-Path $tarFile)) {
    Write-Error "Decryption failed! Incorrect password or corrupted file."
    exit 1
}

Write-Host "📦 Extracting core files..." -ForegroundColor Cyan
tar -xzf $tarFile
Remove-Item $tarFile -Force
Write-Host "✅ Decryption and extraction complete!" -ForegroundColor Green
