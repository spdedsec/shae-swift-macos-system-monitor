#!/usr/bin/env bash
#
# scripts/install.sh — shae-swift-macos-system-monitor
#
# Builds and installs the Swift macOS system monitor.
#
# Requires: swiftc / macOS (not available locally). Cannot compile-test locally.
#
# Usage:
#   ./scripts/install.sh        # build release binary
#   ./scripts/install.sh run    # build + run
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/src/main.swift"
BIN="$REPO_ROOT/monitor"

require_swift() {
    if ! command -v swiftc >/dev/null 2>&1; then
        echo "Error: swiftc (Swift toolchain) is required but not installed." >&2
        echo "Install Swift (https://swift.org/download) on macOS and re-run." >&2
        exit 1
    fi
}

build() {
    require_swift
    swiftc -O "$SRC" -o "$BIN"
    echo "Built: $BIN"
}

run() {
    build
    "$BIN" "$@"
}

case "${1:-}" in
    run)
        shift
        "$BIN" "$@"
        ;;
    *)
        build
        echo "Done. Run with: ./monitor [--interval N]"
        ;;
esac
