#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════╗
# │ Nombre – Descripción                               │
# │ Versión: X.X                                       │
# │ Autor: Daniel Calderon - Kapelu                    │
# │ Fecha: XX/XX/XXXX                                  │
# │ WebSite: https://danielcalderon.vercel.app/        │
# │ Github: https://github.com/Kapelu                  │
# ╚════════════════════════════════════════════════════╝
set -Eeuo pipefail
IFS=$'\n\t'
clear

#!/usr/bin/env bash
set -e

sublime(){
	APP="sublime-text"
	KEYRING="/etc/apt/keyrings/sublimehq.gpg"
	SOURCE="/etc/apt/sources.list.d/sublime-text.list"

	log_info "Creando keyring..."
	install -d -m 0755 /etc/apt/keyrings
	curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o "$KEYRING"

	log_info "Agregando repositorio oficial..."
	echo "deb [signed-by=$KEYRING] https://download.sublimetext.com/ apt/stable/" > "$SOURCE"

	log_info "Actualizando e instalando $APP..."
	apt update -y
	apt install -y "$APP"

	log_ok "Instalación completada"
}