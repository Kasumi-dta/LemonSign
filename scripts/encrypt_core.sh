#!/bin/bash
set -e

PASSWORD="${1:-Tuananh280907@}"
CORE_DIR="Zsign"
TAR_FILE="lemon_core.tar.gz"
ENC_FILE="lemon_core.enc"

if [ ! -d "$CORE_DIR" ]; then
  echo "Error: Directory $CORE_DIR not found!"
  exit 1
fi

echo "📦 Compressing $CORE_DIR..."
tar -czf "$TAR_FILE" "$CORE_DIR"

echo "🔐 Encrypting with AES-256-CBC..."
openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$TAR_FILE" -out "$ENC_FILE" -pass pass:"$PASSWORD"

rm -f "$TAR_FILE"
echo "✅ Encryption complete: $ENC_FILE"
