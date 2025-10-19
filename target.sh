#!/usr/bin/env bash
# simple-restore-apt.sh
# Restores APT configuration and keyrings from backup.tgz in the current directory.

set -euo pipefail
IFS=$'\n\t'

ARCHIVE="./backup.tgz"

if [ ! -f "$ARCHIVE" ]; then
  echo "[ERROR] backup.tgz not found in current directory!"
  exit 1
fi

WORKDIR="$(mktemp -d)"
RESTORE_DIR="${WORKDIR}/apt-backup"
BACKUP_DIR="/var/backups/apt-restore-$(date +%Y%m%d-%H%M%S)"

echo "[INFO] Extracting $ARCHIVE ..."
tar xzf "$ARCHIVE" -C "$WORKDIR"

echo "[INFO] Creating system backup directory: $BACKUP_DIR"
sudo mkdir -p "$BACKUP_DIR"

echo "[INFO] Backing up existing apt configuration..."
sudo cp /etc/apt/sources.list "$BACKUP_DIR/sources.list" 2>/dev/null || true
sudo cp -r /etc/apt/sources.list.d "$BACKUP_DIR/sources.list.d" 2>/dev/null || true
sudo cp -r /usr/share/keyrings "$BACKUP_DIR/keyrings" 2>/dev/null || true
sudo cp /etc/apt/trusted.gpg "$BACKUP_DIR/trusted.gpg" 2>/dev/null || true

# Restore sources.list
if [ -f "${RESTORE_DIR}/sources.list" ]; then
  echo "[INFO] Restoring /etc/apt/sources.list ..."
  sudo cp "${RESTORE_DIR}/sources.list" /etc/apt/sources.list
fi

# Restore sources.list.d
if [ -d "${RESTORE_DIR}/sources.list.d" ]; then
  echo "[INFO] Restoring files to /etc/apt/sources.list.d/ ..."
  sudo mkdir -p /etc/apt/sources.list.d
  sudo cp -r "${RESTORE_DIR}/sources.list.d/"* /etc/apt/sources.list.d/ 2>/dev/null || true
fi

# Restore keyrings (if present)
if [ -d "${RESTORE_DIR}/keyrings" ]; then
  echo "[INFO] Restoring /usr/share/keyrings/ ..."
  sudo mkdir -p /usr/share/keyrings
  sudo cp -r "${RESTORE_DIR}/keyrings/"* /usr/share/keyrings/ 2>/dev/null || true
fi

# Import legacy apt-key export (if any)
if [ -f "${RESTORE_DIR}/apt-key-exportall.gpg" ]; then
  echo "[INFO] Importing legacy apt-key export (apt-key add)..."
  sudo apt-key add "${RESTORE_DIR}/apt-key-exportall.gpg" 2>/dev/null || true
fi

# Clean cached lists and update
echo "[INFO] Cleaning apt cache..."
sudo rm -rf /var/lib/apt/lists/* || true

echo "[INFO] Running apt-get update to verify..."
sudo apt-get update || true

echo
echo "✅ Restore complete."
echo "Backup of old files stored in: $BACKUP_DIR"
echo
echo "If you see NO_PUBKEY errors, it means the corresponding key wasn't included."
echo "You can copy missing keyrings from the source's /usr/share/keyrings or remove the repo entry."
exit 0
