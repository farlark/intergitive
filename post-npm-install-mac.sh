#!/usr/bin/env bash
#
# Installs the native `nodegit` module for both electron and node runtimes on
# macOS, mirroring `post-npm-install-win.ps1`. Two builds are produced and
# cached with `dev/module-switch.js` so the project can switch between running
# under node (tests) and electron (the app) quickly.
#
# Usage:
#   ./post-npm-install-mac.sh [architecture]
#
#   architecture: "arm64" or "x64" (defaults to this machine's arch)
#
# Run this AFTER `npm install`. Requires the Electron target below to match the
# `electron` devDependency in package.json.

set -euo pipefail

ARCH="${1:-$(uname -m | sed 's/^x86_64$/x64/; s/^aarch64$/arm64/')}"

case "$ARCH" in
  x64|arm64) ;;
  *)
    echo "Unsupported architecture: $ARCH (expected x64 or arm64)" >&2
    exit 1
    ;;
esac

ELECTRON_TARGET="41.3.0"
NODEGIT_VERSION="nodegit@0.28.0-alpha.38"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Initializing module cache"
node ./dev/module-switch.js init

echo "==> Dropping any existing cached nodegit builds"
node ./dev/module-switch.js drop nodegit

echo "==> Installing nodegit for electron (target ${ELECTRON_TARGET}, ${ARCH})"
rm -f ./.npmrc
# ELECTRON_TARGET must match the `electron` devDependency: nodegit publishes
# its prebuilt binaries per Electron ABI (electron-v41.3), so a mismatch would
# force a slow, fragile source build.
cat > ./.npmrc <<EOF
runtime = electron
target = ${ELECTRON_TARGET}
target_arch = ${ARCH}
disturl = "https://electronjs.org/headers"
EOF

npm install "${NODEGIT_VERSION}"
node ./dev/module-switch.js save nodegit electron

echo "==> Installing nodegit for node"
rm -f ./.npmrc
npm install "${NODEGIT_VERSION}"
node ./dev/module-switch.js save nodegit node

echo "==> Done. Use 'npm run load-native-electron' or 'npm run load-native-node' to switch."
