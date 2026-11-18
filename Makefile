# Makefile — shae-swift-macos-system-monitor
#
# Targets: build test run install clean release help
#
# SHAE design system applied: paper #F2EEE5, ink #191712, oxide #B3341B,
# 0px radius, 1px borders, border-defined cards (console-rendered).
#
# NOTE: swiftc / macOS is required and NOT available locally.

.PHONY: build test run install clean release help

SWIFTC   ?= swiftc
SRC      := src/main.swift
BIN      := monitor
DIST     := dist
VERSION  := v0.1.0
PKG_NAME := shae-swift-macos-system-monitor

build:
	@echo "==> Building $(PKG_NAME)"
	$(SWIFTC) -O $(SRC) -o $(BIN)
	@echo "Binary: $(BIN)"

test: build
	@echo "==> Smoke test: run monitor once"
	timeout 2s ./$(BIN) || true

run: build
	./$(BIN) $(ARGS)

install: build
	@echo "==> Install $(PKG_NAME)"
	@echo "Copy $(BIN) to a directory on your PATH, e.g. /usr/local/bin"
	@echo "  sudo cp $(BIN) /usr/local/bin/"

clean:
	rm -f $(BIN)
	rm -rf $(DIST) .build/

release: clean build
	@echo "==> Preparing release $(VERSION)"
	mkdir -p $(DIST)
	tar czf $(DIST)/$(PKG_NAME)-$(VERSION)-src.tar.gz -C .. --exclude='.git' $(PKG_NAME)
	@echo "Artifact: $(DIST)/$(PKG_NAME)-$(VERSION)-src.tar.gz"
	@echo "Create the GitHub release: gh release create $(VERSION) $(DIST)/*.tar.gz --title '$(PKG_NAME) $(VERSION)'"

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build    compile with swiftc -O"
	@echo "  test     build and run smoke test (timeout)"
	@echo "  run      run the monitor (pass args via ARGS=\"...\")"
	@echo "  install  print install instructions"
	@echo "  clean    remove binary/build output"
	@echo "  release  build a source tarball for GitHub release"
	@echo "  help     show this help"
