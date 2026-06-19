#!/usr/bin/env bash

# Script para generar tema desde wallpaper y aplicarlo a Hyprland
# Uso: ./wallpaper-theme.sh /ruta/a/imagen.jpg

WALLPAPER="$1"

if [ -z "$WALLPAPER" ]; then
    echo "Uso: $0 /ruta/a/wallpaper.jpg"
    exit 1
fi

# Generar tema con pywal
wal -i "$WALLPAPER" -n

# Aplicar wallpaper a Hyprland
killall swaybg 2>/dev/null; swaybg -i "$WALLPAPER" -m fill &

# Recargar Hyprland para aplicar colores
hyprctl reload

echo "✨ Tema aplicado: $WALLPAPER"