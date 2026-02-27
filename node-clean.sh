#!/usr/bin/env bash
# ╔═════════════════════════════════════════════╗
# │ node-clean – Limpieza de proyectos Node.js  │
# │ Versión: 3.1                                │
# │ Autor: Daniel Calderon - Kapelu             │
# │ Refactor técnico profesional                │
# ╚═════════════════════════════════════════════╝

set -euo pipefail

# ========================================================
# Configuración
# ========================================================

TARGETS=("node_modules" ".next")
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ========================================================
# Funciones base
# ========================================================

cleanup() {
    tput rmcup 2>/dev/null || true
    clear
}

salir() {
    cleanup
    echo ""
    echo "Gracias por usar node-clean by Kapelu."
    echo "https://github.com/Kapelu"
    echo "¡Hasta la próxima!"
    echo ""
    exit 0
}

trap salir EXIT INT TERM

validar_dialog() {
    if ! command -v dialog >/dev/null 2>&1; then
        echo "dialog no está instalado. Intentando instalar..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y dialog
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y dialog
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y dialog
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm dialog
    else
        echo "No se pudo determinar el gestor de paquetes. Instale dialog manualmente."
        exit 1
    fi
    fi
}

get_size_mb() {
    /usr/bin/du -sm --max-depth=0 "$1" 2>/dev/null | awk '{print $1}'
}

calc_height() {
    local items=$1
    local max_height=$((TERM_HEIGHT - 8))
    if [[ $items -lt $max_height ]]; then
        echo $((items + 8))
    else
        echo $max_height
    fi
}

shorten_path() {
    local path="$1"
    local max_len=$2
    local path_len=${#path}

    if (( path_len <= max_len )); then
        echo "$path"
    else
    local part_len=$(( (max_len - 3) / 2 ))
    echo "${path:0:part_len}…${path: -part_len}"
    fi
}

confirmar_borrado() {
    local DIRS=("$@")
    local TOTAL_MB=0

    for DIR in "${DIRS[@]}"; do
        SIZE_MB=$(get_size_mb "$DIR")
        TOTAL_MB=$((TOTAL_MB + SIZE_MB))
    done

    local COUNT=${#DIRS[@]}
    dialog  --title "Confirmación de borrado" \
            --yes-label "Sí" --no-label "No" \
            --yesno "Se van a eliminar ${COUNT} carpetas.\nEspacio total a liberar: ${TOTAL_MB} MB\n\n¿Desea continuar?" \
    10 $((TERM_WIDTH / 2))

    [[ $? -ne 0 ]] && return 1
    return 0
}

mostrar_carpetas() {
    DIR_LIST=""
    TOTAL_MB=0

    for DIR in "${NODE_DIRS[@]}"; do
        SIZE_MB=$(get_size_mb "$DIR")
        DIR_LIST+=$(shorten_path "$DIR" 80)
        DIR_LIST+=" → ${SIZE_MB} MB\n"
        TOTAL_MB=$((TOTAL_MB + SIZE_MB))
    done

    HEIGHT=$(calc_height ${#NODE_DIRS[@]})

    dialog  --title "Carpetas encontradas" \
            --msgbox "Se encontraron ${#NODE_DIRS[@]} carpetas:\n\n$DIR_LIST\nTamaño total combinado: ${TOTAL_MB} MB" \
    $HEIGHT $TERM_WIDTH
}

borrar_todas() {

    if $DRY_RUN; then
        DIR_LIST=""
        for DIR in "${NODE_DIRS[@]}"; do
        DIR_LIST+=$(shorten_path "$DIR" 80)
        DIR_LIST+="\n"
        done

    HEIGHT=$(calc_height ${#NODE_DIRS[@]})
    dialog --msgbox "== DRY-RUN: Se eliminarían todas las carpetas ==\n\n$DIR_LIST" \
        $HEIGHT $TERM_WIDTH
    return
    fi

    confirmar_borrado "${NODE_DIRS[@]}" || return

    TOTAL_DELETED_MB=0

    for DIR in "${NODE_DIRS[@]}"; do
        SIZE_MB=$(get_size_mb "$DIR")
        [[ -d "$DIR" ]] && /bin/rm -rf -- "$DIR"
        TOTAL_DELETED_MB=$((TOTAL_DELETED_MB + SIZE_MB))
    done

    dialog --msgbox "Se eliminaron todas las carpetas.\nEspacio liberado: ${TOTAL_DELETED_MB} MB" \
        10 $((TERM_WIDTH / 2))
}

borrar_checklist() {

    TOTAL_DELETED_MB=0
    CHECKLIST_ARGS=()
    MAP_DIRS=()

    for DIR in "${NODE_DIRS[@]}"; do
        SIZE_MB=$(get_size_mb "$DIR")
        SHORT=$(shorten_path "$DIR" 50)
        LABEL="item$(( ${#MAP_DIRS[@]} + 1 ))"
        MAP_DIRS+=("$DIR")
        CHECKLIST_ARGS+=("$LABEL" "$SHORT → ${SIZE_MB} MB" "off")
    done

    HEIGHT=$(calc_height ${#NODE_DIRS[@]})

    SELECTED=$(dialog --title "Seleccionar carpetas a borrar" \
    --checklist "Use la barra espaciadora para seleccionar:" \
    $HEIGHT $TERM_WIDTH 20 \
    "${CHECKLIST_ARGS[@]}" \
    3>&1 1>&2 2>&3) || return

    [[ -z "$SELECTED" ]] && return

    TO_DELETE=()

    for LABEL in $SELECTED; do
    LABEL=$(echo "$LABEL" | tr -d '"')
    INDEX=$(( ${LABEL//[!0-9]/} - 1 ))
    TO_DELETE+=("${MAP_DIRS[$INDEX]}")
    done

    confirmar_borrado "${TO_DELETE[@]}" || return

    for DIR in "${TO_DELETE[@]}"; do
        SIZE_MB=$(get_size_mb "$DIR")
        [[ -d "$DIR" ]] && /bin/rm -rf -- "$DIR"
    TOTAL_DELETED_MB=$((TOTAL_DELETED_MB + SIZE_MB))
    done

    dialog --msgbox "Proceso completado.\nEspacio liberado: ${TOTAL_DELETED_MB} MB" \
    10 $((TERM_WIDTH / 2))
}

# ========================================================
# MAIN
# ========================================================

validar_dialog

tput smcup
clear
printf '\033[3J'

TERM_WIDTH=$(tput cols)
TERM_HEIGHT=$(tput lines)

while true; do

    ROOT_DIR_NAME=$(dialog --title "Seleccionar carpeta raíz" \
        --inputbox "Ingrese la carpeta donde buscar:" \
        10 $((TERM_WIDTH / 2)) \
        3>&1 1>&2 2>&3)
    
    STATUS=$?  # Capturamos el exit code de dialog
    
    # Cancel o Escape
    if [[ $STATUS -ne 0 ]]; then
        salir
    fi

    # Si no ingresó nada
    if [[ -z "$ROOT_DIR_NAME" ]]; then
        dialog --msgbox "No ingresó ningún nombre de carpeta. Intente nuevamente." 6 $((TERM_WIDTH / 2))
        clear
        continue  # vuelve al inicio del while
    fi

    [[ -z "$ROOT_DIR_NAME" ]] && continue

    BASE_DIR="$HOME/$ROOT_DIR_NAME"

    if [[ -d "$BASE_DIR" ]]; then
        break
    else
        dialog --msgbox "La carpeta $BASE_DIR no existe." 6 $((TERM_WIDTH / 2))
    fi
done

NODE_DIRS=()

for TARGET in "${TARGETS[@]}"; do
    while IFS= read -r path; do
        NODE_DIRS+=("$path")
    done < <(/usr/bin/find "$BASE_DIR" -name "$TARGET" -prune 2>/dev/null)
done

[[ ${#NODE_DIRS[@]} -eq 0 ]] && {
    dialog --msgbox "No se encontraron carpetas: ${TARGETS[*]}" \
        8 $((TERM_WIDTH / 2))
    salir
}

mostrar_carpetas

while true; do

    OPCION=$(dialog --title "Opciones de borrado" \
        --menu "Seleccione una opción:" \
        12 50 3 \
        1 "Borrar todas" \
        2 "Borrado múltiple (checklist)" \
        3 "Salir" \
        3>&1 1>&2 2>&3) || salir

    case $OPCION in
        1) borrar_todas ;;
        2) borrar_checklist ;;
        3) salir ;;
      *) dialog --msgbox "Opción inválida" 5 30 ;;
    esac
done