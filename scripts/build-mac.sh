#!/bin/bash
#
# scripts/build-mac.sh
#
# Build NotchPrompter from source on macOS and assemble a distributable
# .app bundle (plus a .zip archive) in the repository's build/ directory.
#
# What it does:
#   1. Checks prerequisites (macOS, Xcode Command Line Tools / swift).
#   2. Compiles a release build with SwiftPM for the native host
#      architecture only (arm64 or x86_64 — not a universal binary).
#   3. Assembles build/NotchPrompter.app with the bundled Info.plist.
#   4. Generates AppIcon.icns from the existing PNG assets (iconutil),
#      when available.
#   5. Ad-hoc codesigns the bundle locally and verifies the signature.
#   6. Zips the bundle and reveals it in Finder (does not launch the app).
#
# The result is an unsigned / not-notarized local build: it runs on your
# Mac but is not suitable for distribution to others without a signing
# identity and notarization.
#
# Prerequisites (one-time):
#   xcode-select --install
#
set -euo pipefail

APP_NAME="NotchPrompter"
BUNDLE_ID="local.notchprompter.app"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICONSET_DIR="$BUILD_DIR/$APP_NAME.iconset"

ICON_SRC_DIR="$ROOT_DIR/notch-prompter/Assets.xcassets/AppIcon.appiconset"
INFO_PLIST_SRC="$ROOT_DIR/macOS/Info.plist"

log()  { printf '\n==> %s\n' "$*"; }
warn() { printf '\nWARNING: %s\n' "$*" >&2; }
die()  { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
log "Checking prerequisites"

[[ "$(uname)" == "Darwin" ]] || die "This script must be run on macOS."

command -v swift >/dev/null 2>&1 \
    || die "swift not found. Install Xcode Command Line Tools: xcode-select --install"
command -v codesign >/dev/null 2>&1 \
    || die "codesign not found. Install Xcode Command Line Tools: xcode-select --install"
command -v zip >/dev/null 2>&1 \
    || die "zip not found."

HAS_ICONUTIL=0
if command -v iconutil >/dev/null 2>&1; then
    HAS_ICONUTIL=1
else
    warn "iconutil not found; skipping .icns generation (app will use the default icon)."
fi

ARCH="$(uname -m)"

# ---------------------------------------------------------------------------
# Compile
# ---------------------------------------------------------------------------
log "Compiling release build for native architecture: $ARCH"
swift build -c release --arch "$ARCH"

BIN_PATH="$(swift build -c release --arch "$ARCH" --show-bin-path)"
BINARY="$BIN_PATH/$APP_NAME"
[[ -x "$BINARY" ]] || die "Compiled binary not found at: $BINARY"

# ---------------------------------------------------------------------------
# Assemble .app bundle
# ---------------------------------------------------------------------------
log "Assembling $APP_DIR"

rm -rf "$APP_DIR" "$ICONSET_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BINARY" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

[[ -f "$INFO_PLIST_SRC" ]] || die "Info.plist template not found at: $INFO_PLIST_SRC"
cp "$INFO_PLIST_SRC" "$CONTENTS_DIR/Info.plist"

# ---------------------------------------------------------------------------
# App icon (iconutil, when feasible)
# ---------------------------------------------------------------------------
if [[ "$HAS_ICONUTIL" == "1" && -d "$ICON_SRC_DIR" ]]; then
    log "Generating AppIcon.icns from existing PNG assets"

    declare -a ICON_MAP=(
        "icon_16x16.png:NotchPrompterIcon-iOS-Default-16x16@1x.png"
        "icon_16x16@2x.png:NotchPrompterIcon-iOS-Default-16x16@2x.png"
        "icon_32x32.png:NotchPrompterIcon-iOS-Default-32x32@1x.png"
        "icon_32x32@2x.png:NotchPrompterIcon-iOS-Default-32x32@2x.png"
        "icon_128x128.png:NotchPrompterIcon-iOS-Default-128x128@1x.png"
        "icon_128x128@2x.png:NotchPrompterIcon-iOS-Default-128x128@2x.png"
        "icon_256x256.png:NotchPrompterIcon-iOS-Default-256x256@1x.png"
        "icon_256x256@2x.png:NotchPrompterIcon-iOS-Default-256x256@2x.png"
        "icon_512x512.png:NotchPrompterIcon-iOS-Default-512x512@1x.png"
        "icon_512x512@2x.png:NotchPrompterIcon-iOS-Default-512x512@2x.png"
    )

    mkdir -p "$ICONSET_DIR"
    MISSING_ICON=0
    for entry in "${ICON_MAP[@]}"; do
        target="${entry%%:*}"
        source="${entry#*:}"
        if [[ -f "$ICON_SRC_DIR/$source" ]]; then
            cp "$ICON_SRC_DIR/$source" "$ICONSET_DIR/$target"
        else
            warn "Missing icon source: $source"
            MISSING_ICON=1
        fi
    done

    if [[ "$MISSING_ICON" == "0" ]]; then
        iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
        log "AppIcon.icns generated"
    else
        warn "Skipping .icns generation due to missing source icons."
    fi
else
    warn "Icon assets not found; skipping .icns generation."
fi

rm -rf "$ICONSET_DIR"

# ---------------------------------------------------------------------------
# Ad-hoc codesign and verify
# ---------------------------------------------------------------------------
log "Ad-hoc codesigning (no identity — local use only)"
codesign --force --deep --sign - --timestamp=none "$APP_DIR"

log "Verifying codesign signature"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

# ---------------------------------------------------------------------------
# Zip the bundle
# ---------------------------------------------------------------------------
ZIP_PATH="$BUILD_DIR/$APP_NAME.zip"
log "Creating $ZIP_PATH"
rm -f "$ZIP_PATH"

if command -v ditto >/dev/null 2>&1; then
    ditto -c -k --keepParent --sequesterRsrc "$APP_DIR" "$ZIP_PATH"
else
    (cd "$BUILD_DIR" && zip -qry "$APP_NAME.zip" "$APP_NAME.app")
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
log "Build complete"
printf '\nApp bundle: %s\n' "$APP_DIR"
printf 'Zip:        %s\n' "$ZIP_PATH"
printf 'Arch:       %s (native only, not universal)\n' "$ARCH"
printf 'Signing:    ad-hoc (unsigned for distribution, not notarized)\n'

# Reveal the finished app in Finder without launching it.
if command -v open >/dev/null 2>&1; then
    open -R "$APP_DIR"
fi
