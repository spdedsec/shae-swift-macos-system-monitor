# shae-swift-macos-system-monitor (Deutsch)

macOS-Systemmonitor in Swift, nach dem SHAE Field Manual Design System:
warmes Papier #F2EEE5, Tinte #191712, ein Oxid-Rot #B3341B als einziges
Signal pro Ansicht, 0px Radius, 1px Rahmen, Monospace-Metadaten,
WCAG-AA-Kontrast, reduzierte-Bewegung-Fallbacks.

## Funktionen

- CPU-, Arbeitsspeicher-, Festplattenauslastung anzeigen
- Laufzeit und Hostname anzeigen
- Batteriestatus anzeigen (falls vorhanden)
- Formatierte Konsolenausgabe

## Installation

Erfordert swiftc / macOS (nicht lokal verfügbar). Kann nicht lokal
kompiliert-getestet werden.

```bash
# Swift installieren: https://swift.org/download (macOS Toolchain)

git clone https://github.com/spdedsec/shae-swift-macos-system-monitor.git
cd shae-swift-macos-system-monitor

swiftc -O src/main.swift -o monitor
```

## Verwendung

```bash
./monitor [--interval N]
```

## Design-System

Siehe `DESIGN.md`. Die Konsolenausgabe nutzt die SHAE-Palette über
ANSI-Escape-Sequenzen.

## Lizenz

MIT. Siehe `LICENSE`.
