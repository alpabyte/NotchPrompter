#!/bin/bash
#
# Build NotchPrompter.command
#
# Double-click this file in Finder to build NotchPrompter from source and
# then open the finished app. It wraps scripts/build-mac.sh with friendly
# diagnostics. The build produces a local, ad-hoc signed (not notarized)
# build in the repository's build/ directory.
#
# Requirements (one-time):
#   xcode-select --install
#
# If macOS asks whether to open this file, click "Open" once. The app it
# produces is unsigned/not notarized, so macOS may ask for confirmation the
# first time you launch the .app as well.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPT="$SCRIPT_DIR/scripts/build-mac.sh"
APP_PATH="$SCRIPT_DIR/build/NotchPrompter.app"

echo "=============================================================="
echo " NotchPrompter — build and launch"
echo "=============================================================="
echo

if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This builder only runs on macOS." >&2
    echo "NotchPrompter is a native macOS app and cannot run on Linux." >&2
    exit 1
fi

if ! command -v swift >/dev/null 2>&1; then
    echo "ERROR: Xcode Command Line Tools are not installed." >&2
    echo >&2
    echo "Install them with:" >&2
    echo "    xcode-select --install" >&2
    echo >&2
    echo "Then run this file again." >&2
    exit 1
fi

echo "Using build script: $BUILD_SCRIPT"
echo
echo "This will:"
echo "  - compile a release build (native architecture only)"
echo "  - assemble build/NotchPrompter.app"
echo "  - ad-hoc codesign it locally (not notarized)"
echo "  - zip it and reveal it in Finder"
echo "  - open the app"
echo

"$BUILD_SCRIPT"

echo
echo "Build finished. Opening NotchPrompter..."
open "$APP_PATH"

echo
echo "Done. If macOS blocked the app, right-click it in Finder and"
echo "choose Open, then confirm. This is expected for a local,"
echo "unsigned/not-notarized build."
