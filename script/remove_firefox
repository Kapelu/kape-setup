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

remove_firefox(){
	log_info "Deteniendo procesos de Firefox..."
	pkill -f firefox >/dev/null 2>&1 || true
	sleep 1

	if command -v snap >/dev/null 2>&1; then
		if snap list | grep -q firefox; then
			log_info "Removiendo Firefox (snap)..."
			sudo snap remove --purge firefox || true
			log_ok "Snap eliminado"
		fi
	fi

	if dpkg -l | grep -q firefox; then
		log_info "Removiendo Firefox (apt)..."
		sudo apt purge -y firefox firefox-locale-* || true
		sudo apt autoremove -y
		log_ok "APT eliminado"
	fi

	if command -v flatpak >/dev/null 2>&1; then
		if flatpak list | grep -qi firefox; then
			log_info "Removiendo Firefox (flatpak)..."
			flatpak uninstall -y --delete-data org.mozilla.firefox || true
			log_ok "Flatpak eliminado"
		fi
	fi

	log_info "Eliminando configuraciones de usuario..."

	rm -rf "$HOME/.mozilla"
	rm -rf "$HOME/.cache/mozilla"
	rm -rf "$HOME/.config/firefox"
	rm -rf "$HOME/.local/share/flatpak/app/org.mozilla.firefox" 2>/dev/null || true
	rm -rf "$HOME/.var/app/org.mozilla.firefox" 2>/dev/null || true

	sudo rm -rf /etc/firefox
	sudo rm -rf /usr/lib/firefox*
	sudo rm -rf /usr/lib64/firefox*
	sudo rm -rf /usr/share/firefox
	sudo rm -rf /usr/share/applications/firefox.desktop
	sudo rm -rf /var/lib/snapd/desktop/applications/firefox_firefox.desktop

	log_ok "Restos del sistema eliminados"

	sudo apt clean

	log_ok "Firefox eliminado completamente del sistema"
}