#!/bin/bash
# 🔧 Script de instalación automatizada para Ubuntu 24.04
# Desarrollado por Ing. Marco Gallegos

# === Función Auxiliar ===
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# === Validaciones Iniciales ===
echo "🔍 Verificando versión de Ubuntu..."
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "24.04" ]]; then
    echo "❌ Error: Este script está diseñado para Ubuntu 24.04."
    exit 1
fi

echo "📡 Verificando conectividad a Internet..."
if ! ping -c 1 google.com > /dev/null 2>&1; then
    echo "❌ Error: No hay conexión a Internet."
    exit 1
fi

# === Configuraciones Previas ===
echo "📁 Creando directorio base..."
mkdir -p /home/auraInst/
echo "📜 Configurando log..."
exec > >(tee -a /var/log/aura-install.log) 2>&1

# === Actualización del Sistema ===
echo "🔄 Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# === Instalación de Paquetes Base ===
echo "📦 Instalando paquetes esenciales..."
sudo apt install -y git curl wget software-properties-common

# === Ejemplo de Personalización ===
echo "🧹 Limpiando el escritorio..."
rm -rf ~/Desktop/*
gsettings set org.gnome.nautilus.desktop home-icon-visible false

# === Instalación de Aplicaciones Ejemplo ===
echo "🌐 Instalando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo dpkg -i /tmp/chrome.deb
sudo apt -f install -y
rm /tmp/chrome.deb

echo "🐚 Instalando Zsh y Oh My Zsh..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# === Finalización ===
echo "✅ Instalación completada."
echo "🔧 Desarrollado por Ing. Marco Gallegos"
