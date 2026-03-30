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

google(){
	log_info "Instalando Google Chrome desde repositorio oficial..."
  
  log_info "Descargando y registrar clave GPG"
  install -d -m 0755 /etc/apt/keyrings
  wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
  
  chmod a+r /etc/apt/keyrings/google-chrome.gpg
  
  log_info "Agregando repositorio oficial"
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list
  
  log_info "Actualizando e instalando: google-chrome-stable"
  apt update
  apt install -y google-chrome-stable
  
  log_ok "Google Chrome instalado correctamente y listo para actualizarse con apt"
}