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

KEYRING_BRAVE="/usr/share/keyrings/brave-browser-archive-keyring.gpg"
SOURCE_LIST_BRAVE="/etc/apt/sources.list.d/brave-browser-release.list"
REPO_BRAVE="https://brave-browser-apt-release.s3.brave.com"

add_key() {
  if [[ ! -f "$KEYRING_BRAVE" ]]; then
    curl -fsSL "$REPO_BRAVE/brave-browser-archive-keyring.gpg" \
      | gpg --dearmor -o "$KEYRING_BRAVE"
  fi
}

add_repo() {
  if [[ ! -f "$SOURCE_LIST_BRAVE" ]]; then
    echo "deb [signed-by=$KEYRING_BRAVE] $REPO_BRAVE stable brave" \
      > "$SOURCE_LIST_BRAVE"
  fi
}

install_brave() {
  apt update -y
  apt install -y brave-browser
}

# Setup Brave
# ───────────
brave() {
	log_info "Instalando Brave desde repositorio oficial..."
	log_info "Agregando clave oficial Brave"
  add_key
	log_info "Registrando repo en source.list.d"
  add_repo
	log_info "Instalando Brave-browser"
  install_brave
  log_ok "Brave instalado correctamente y listo para actualizarse con apt"
}

brave "$@"