#!/usr/bin/env bash
set -euo pipefail

KEYSTORE_PATH="/home/ubuntu/tgx_custom_release.jks"
SECRET_FILE="/home/ubuntu/tgx_custom_release.signing.env"
ALIAS="tgxcustom"
STORE_PASSWORD="$(openssl rand -hex 32)"
KEY_PASSWORD="$(openssl rand -hex 32)"

rm -f "$KEYSTORE_PATH" "$SECRET_FILE"
keytool -genkeypair \
  -keystore "$KEYSTORE_PATH" \
  -storetype JKS \
  -storepass "$STORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 9125 \
  -dname "CN=Telegram X Custom, OU=Private Build, O=Private, L=Private, ST=Private, C=MM" \
  -noprompt

keytool -list -keystore "$KEYSTORE_PATH" -storetype JKS -storepass "$STORE_PASSWORD" -alias "$ALIAS" >/dev/null
BASE64_VALUE="$(base64 -w 0 "$KEYSTORE_PATH")"
printf '%s' "$BASE64_VALUE" | base64 -d > "${KEYSTORE_PATH}.roundtrip"
cmp -s "$KEYSTORE_PATH" "${KEYSTORE_PATH}.roundtrip"
rm -f "${KEYSTORE_PATH}.roundtrip"

umask 077
cat > "$SECRET_FILE" <<EOF
SIGNING_KEY=$BASE64_VALUE
ALIAS=$ALIAS
KEY_STORE_PASSWORD=$STORE_PASSWORD
KEY_PASSWORD=$KEY_PASSWORD
EOF
chmod 600 "$KEYSTORE_PATH" "$SECRET_FILE"
printf 'Validated signing keystore prepared at %s\n' "$KEYSTORE_PATH"
