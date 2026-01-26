#!/usr/bin/env bash

# Anime Launcher con ani-cli y Rofi
# Creado por J27 para streaming rápido de anime

CONFIG_DIR="$HOME/.config/anime-launcher"
CACHE_FILE="$CONFIG_DIR/anime_cache.txt"
HISTORY_FILE="$CONFIG_DIR/history.txt"

# Crear directorios necesarios
mkdir -p "$CONFIG_DIR"

# Función para mostrar ayuda
show_help() {
    echo "Uso: anime-launcher [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -h, --help     Muestra esta ayuda"
    echo "  -u, --update  Actualiza la caché de animes"
    echo "  -c, --clear   Limpia el historial"
    echo ""
    echo "Atajo recomendado: Shift+Ctrl+A"
}

# Función para actualizar caché
update_cache() {
    echo "🔄 Actualizando caché de animes..."
    
    # Obtener lista de animes populares usando ani-cli
    ani-cli -l 2>/dev/null | head -50 > "$CACHE_FILE.tmp" || {
        echo "❌ Error al obtener lista de animes"
        echo "📝 Asegúrate de que ani-cli esté instalado"
        exit 1
    }
    
    # Formatear para Rofi
    sed 's/^/🎬 /' "$CACHE_FILE.tmp" > "$CACHE_FILE"
    rm "$CACHE_FILE.tmp"
    
    echo "✅ Caché actualizada con $(wc -l < "$CACHE_FILE") animes"
}

# Función para buscar anime
search_anime() {
    local query="$1"
    
    # Si no hay caché, actualizarla
    if [[ ! -f "$CACHE_FILE" ]] || [[ $(find "$CACHE_FILE" -mtime +1 2>/dev/null) ]]; then
        update_cache
    fi
    
    # Buscar en la caché con Rofi
    local selected=$(grep -i "$query" "$CACHE_FILE" | \
        rofi -dmenu -i \
        -p "🎌 Selecciona un anime:" \
        -mesg "Escribe para filtrar • Enter para ver episodios" \
        -columns 1 \
        -lines 10 \
        -width 700)
    
    if [[ -n "$selected" ]]; then
        # Extraer nombre del anime (quitar emoji)
        local anime_name=$(echo "$selected" | sed 's/^[🎬🎞️🎦] *//')
        
        # Guardar en historial
        echo "$(date '+%Y-%m-%d %H:%M') - $anime_name" >> "$HISTORY_FILE"
        
        # Abrir ani-cli con el anime seleccionado
        echo "🎬 Abriendo: $anime_name"
        ani-cli -q "$anime_name"
    fi
}

# Función para mostrar historial
show_history() {
    if [[ -f "$HISTORY_FILE" ]]; then
        tail -10 "$HISTORY_FILE" | \
        sed 's/.*- /🕒 /' | \
        rofi -dmenu -i \
        -p "📚 Historial reciente:" \
        -mesg "Selecciona para volver a ver" \
        -columns 1 \
        -lines 10
    fi
}

# Función principal
main() {
    case "$1" in
        -h|--help)
            show_help
            ;;
        -u|--update)
            update_cache
            ;;
        -c|--clear)
            > "$HISTORY_FILE"
            echo "🗑️ Historial limpiado"
            ;;
        "")
            # Modo interactivo principal
            local choice=$(echo -e "🔍 Buscar anime\n📚 Ver historial\n🔄 Actualizar caché\n❓ Ayuda" | \
                rofi -dmenu -i \
                -p "🎌 Anime Launcher:" \
                -mesg "Shift+Ctrl+A - Streaming rápido de anime" \
                -columns 1 \
                -lines 4)
            
            case "$choice" in
                "🔍 Buscar anime")
                    search_anime ""
                    ;;
                "📚 Ver historial")
                    local history_item=$(show_history)
                    if [[ -n "$history_item" ]]; then
                        local anime_name=$(echo "$history_item" | sed 's/^[🕒] *//')
                        echo "🎬 Abriendo desde historial: $anime_name"
                        ani-cli -q "$anime_name"
                    fi
                    ;;
                "🔄 Actualizar caché")
                    update_cache
                    ;;
                "❓ Ayuda")
                    show_help
                    ;;
            esac
            ;;
        *)
            # Búsqueda directa desde argumento
            search_anime "$1"
            ;;
    esac
}

main "$@"