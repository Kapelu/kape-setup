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

vscode(){
	echo "Instalando dependencias..."
	apt-get update -y
	apt-get install -y wget gpg

	echo "Importando clave GPG oficial..."
	install -d -m 0755 /etc/apt/keyrings
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor \
		| tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
	chmod 644 /etc/apt/keyrings/packages.microsoft.gpg

	echo "Agregando repositorio oficial de VS Code..."
	[[ -f /etc/apt/sources.list.d/vscode.list ]] || \ 
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
	| tee /etc/apt/sources.list.d/vscode.list > /dev/null

	echo "Actualizando repositorios..."
	apt-get update -y

	echo "Instalando Visual Studio Code..."
	apt-get install -y code

	echo "Limpieza..."
	apt-get autoremove -y

	echo "VS Code instalado correctamente y listo para actualizarse con apt"
}