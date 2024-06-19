#!/bin/bash

# Ensuring Root Privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo."
  exit 1
fi

# Variables
USER_HOME=$(eval echo ~$SUDO_USER)
TEMPDIR="$USER_HOME/.tailscale_certs"
TS_DNS=$(tailscale status --json | jq -r '.Self.DNSName | .[:-1]')
SYNO_ID=$(cat /usr/syno/etc/certificate/_archive/DEFAULT)
CERT_PATH="/usr/syno/etc/certificate/_archive/$SYNO_ID/cert.pem"
EXPIRY_THRESHOLD_DAYS=30

# Function to check certificate expiration
check_cert_expiry() {
  if [ -f "$1" ]; then
    expiry_date=$(openssl x509 -enddate -noout -in "$1" | cut -d= -f2)
    expiry_seconds=$(date -d "$expiry_date" +%s)
    current_seconds=$(date +%s)
    remaining_days=$(( (expiry_seconds - current_seconds) / 86400 ))

    if [ "$remaining_days" -le "$EXPIRY_THRESHOLD_DAYS" ]; then
      echo "Certificate for $TS_DNS is expiring in $remaining_days days. Regenerating..."
      return 1
    else
      echo "Certificate for $TS_DNS is valid for another $remaining_days days."
      return 0
    fi
  else
    echo "Certificate file not found. Proceeding to generate a new one."
    return 1
  fi
}

# Check if the existing certificate is expiring soon
if ! check_cert_expiry "$CERT_PATH"; then
  # Cleanup of Old Certificates
  rm -f "$TEMPDIR/$TS_DNS.crt" "$TEMPDIR/$TS_DNS.key" "$TEMPDIR/$TS_DNS.pem"

  # Directory Creation for Certs
  mkdir -p "$TEMPDIR"

  # Generating Tailscale Certificates
  tailscale cert --cert-file "$TEMPDIR/$TS_DNS.crt" --key-file "$TEMPDIR/$TS_DNS.key" "$TS_DNS"

  # Key Conversion to PKCS#8 Format
  openssl pkcs8 -topk8 -nocrypt -in "$TEMPDIR/$TS_DNS.key" -out "$TEMPDIR/p8file.pem"

  # Copying Certificates to Synology
  cp "$TEMPDIR/$TS_DNS.crt" "/usr/syno/etc/certificate/_archive/$SYNO_ID/cert.pem"
  cp "$TEMPDIR/$TS_DNS.crt" "/usr/syno/etc/certificate/_archive/$SYNO_ID/fullchain.pem"
  cp "$TEMPDIR/p8file.pem" "/usr/syno/etc/certificate/_archive/$SYNO_ID/privkey.pem"

  # Storing Certificates in a Specific Location
  mkdir -p /etc/ssl/tailscale
  cp "$TEMPDIR/$TS_DNS.crt" "$TEMPDIR/$TS_DNS.key" /etc/ssl/tailscale/

  # Restarting Synology Web Server
  /usr/syno/bin/synosystemctl restart nginx
else
  echo "No need to regenerate certificates."
fi
