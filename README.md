# shae-swift-macos-system-monitor

macOS system monitor written in Swift, built on the SHAE Field Manual
design system: warm paper #F2EEE5, ink #191712, one oxide-red #B3341B
signal per view, 0px radius, 1px borders, border-defined cards,
monospace metadata, WCAG AA contrast, reduced-motion fallbacks.

## Features

- show CPU, memory, disk usage
- show uptime, hostname
- show battery status (if available)
- formatted console output

## Install

Requires swiftc / macOS (not available locally). Cannot compile-test locally.

```bash
# Install Swift: https://swift.org/download (macOS toolchain)

git clone https://github.com/spdedsec/shae-swift-macos-system-monitor.git
cd shae-swift-macos-system-monitor

swiftc -O src/main.swift -o monitor
```

Or use the installer:

```bash
./scripts/install.sh
```

## Usage

```bash
./monitor [--interval N]
```

Example output:

```
shae-swift-macos-system-monitor
----------------------------------------
  Host: shae-macbook.local
  OS: macOS 15.0.0

CPU
----------------------------------------
  Usage: 4.2%

Memory
----------------------------------------
  Total: 16.00 GB
  Used: 8.00 GB
  Usage: 50.0%

Disk
----------------------------------------
  Total: 500.00 GB
  Used: 250.00 GB
  Usage: 50.0%

Uptime
----------------------------------------
  2 days, 3:12

Battery
----------------------------------------
  87% · AC Power
```

Metrics come from `sysctl`, `vm_stat`, `df`, `uptime`, and `pmset` (macOS).

## Design system

See `DESIGN.md`. Console rendering applies the SHAE palette via ANSI
escapes:

- Warm paper `#F2EEE5` — section rules
- Ink `#191712` — primary text
- Oxide `#B3341B` — single signal (refresh notice/errors)

Output is left-aligned, monospace, hairline-ruled. No gradients, glass,
pills, or shadows.

## Build / release

```bash
make build      # swiftc -O src/main.swift -o monitor
make release    # source tarball for GitHub release v0.1.0
```

swiftc / macOS is required and is not available locally.

## License

MIT. See `LICENSE`.
