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
#   architecture: "x64" (default) or "arm64"
#
# Run this AFTER `npm install`. Requires the Electron target below to match the
# `electron` devDependency in package.json.

set -euo pipefail

ARCH="${1:-x64}"

case "$ARCH" in
  x64|arm64) ;;
  *)
    echo "Unsupported architecture: $ARCH (expected x64 or arm64)" >&2
    exit 1
    ;;
esac

ELECTRON_TARGET="8.2.0"
NODEGIT_VERSION="nodegit@0.26.x"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Initializing module cache"
node ./dev/module-switch.js init

echo "==> Dropping any existing cached nodegit builds"
node ./dev/module-switch.js drop nodegit

echo "==> Installing nodegit for electron (target ${ELECTRON_TARGET}, ${ARCH})"
rm -f ./.npmrc
# NOTE: the historical disturl atom.io/download/atom-shell is dead (Atom was
# sunset); node-gyp needs the current Electron headers host to build from source.
cat > ./.npmrc <<EOF
runtime = electron
target = ${ELECTRON_TARGET}
target_arch = ${ARCH}
disturl = "https://electronjs.org/headers"
openssl_fips =
EOF

npm install "${NODEGIT_VERSION}"
node ./dev/module-switch.js save nodegit electron

echo "==> Installing nodegit for node"
rm -f ./.npmrc
npm install "${NODEGIT_VERSION}"
node ./dev/module-switch.js save nodegit node

echo "==> Done. Use 'npm run load-native-electron' or 'npm run load-native-node' to switch."
