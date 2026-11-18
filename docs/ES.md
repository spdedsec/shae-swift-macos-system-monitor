# shae-swift-macos-system-monitor (Español)

Monitor del sistema macOS en Swift, basado en el SHAE Field Manual
design system: papel cálido #F2EEE5, tinta #191712, una señal óxido
#B3341B por vista, 0px de radio, bordes de 1px, metadatos monoespaciados,
contraste WCAG AA, fallback de movimiento reducido.

## Funcionalidades

- Mostrar uso de CPU, memoria y disco
- Mostrar tiempo de actividad y nombre de host
- Mostrar estado de la batería (si está disponible)
- Salida por consola formateada

## Instalación

Requiere swiftc / macOS (no disponible localmente). No se puede
compilar-probar localmente.

```bash
# Instalar Swift: https://swift.org/download (toolchain macOS)

git clone https://github.com/spdedsec/shae-swift-macos-system-monitor.git
cd shae-swift-macos-system-monitor

swiftc -O src/main.swift -o monitor
```

## Uso

```bash
./monitor [--interval N]
```

## Sistema de diseño

Véase `DESIGN.md`. La salida por consola usa la paleta SHAE mediante
secuencias de escape ANSI.

## Licencia

MIT. Véase `LICENSE`.
