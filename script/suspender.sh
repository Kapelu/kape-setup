#!/bin/bash
# ╔════════════════════════════════════════════════════╗
# │ suspender - Script para suspender la máquina  │
# │ Versión: 3.5                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: 02/03/2026                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# ╚════════════════════════════════════════════════════╝
DELAY=15
BAR_LENGTH=15
CANCELLED=0

# Ocultar cursor al iniciar
echo -ne "\e[?25l"

# Manejar Ctrl+C para cancelar
trap 'CANCELLED=1; clear; echo -e "\n❌ Suspensión cancelada"; sleep 3; clear; exit 0' SIGINT
clear
echo "💤 La máquina se suspenderá en $DELAY segundos... (Ctrl+C para cancelar)"
echo ""

# Barra de progreso con emojis
for ((i=1; i<=DELAY; i++)); do
    [[ $CANCELLED -eq 1 ]] && exit 0
    
    filled=$i
    empty=$((BAR_LENGTH - filled))
    progress=$(printf '🟩%.0s' $(seq 1 $filled))
    spaces=$(printf '⬜%.0s' $(seq 1 $empty))
    
    # Mostrar barra y contador en la misma línea
    echo -ne "\r$progress $i/$DELAY"
    
    sleep 1
done

# Suspender la máquina si no fue cancelada
echo -e "\n✔ Suspendiendo la máquina..."
nohup systemctl suspend >/dev/null 2>&1 &
exit 0

# Mostrar cursor nuevamente antes de salir
echo -ne "\e[?25h"
exit 0



# Crear acceso directo en el escritorio
# Para crear un acceso directo en el escritorio, puedes usar el siguiente contenido para un archivo .desktop:

# nano ~/Escritorio/Suspender.desktop


# [Desktop Entry]
# Name=Suspender PC
# Comment=Suspender la máquina con barra visual de 15 segundos
# Exec=gnome-terminal --geometry=45x8 --hide-menubar -- bash -c "/home/daniel-calderon/script/suspender"
# Icon=system-suspend
# Terminal=false
# Type=Application
# Categories=Utility;

# Asegúrate de darle permisos de ejecución al script y al acceso directo:
# chmod +x ~/Escritorio/Suspender.desktop