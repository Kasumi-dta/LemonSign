#!/bin/bash
set -e

PASSWORD="${1:-Tuananh280907@}"
ENC_FILE="lemon_core.enc"
TAR_FILE="lemon_core.tar.gz"

if [ ! -f "$ENC_FILE" ]; then
  echo "Error: Encrypted file $ENC_FILE not found!"
  exit 1
fi

echo "🔓 Decrypting $ENC_FILE with master password..."
openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$ENC_FILE" -out "$TAR_FILE" -pass pass:"$PASSWORD"

echo "📦 Extracting core files..."
tar -xzf "$TAR_FILE"
rm -f "$TAR_FILE"

echo "✅ Decryption and extraction complete!"
