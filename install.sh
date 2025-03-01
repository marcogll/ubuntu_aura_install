#!/bin/bash
# 🔧 Script de instalación automatizada para Ubuntu 24.04/24.10
# Desarrollado por Ing. Marco Gallegos

# === Definición de Colores ANSI ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # Sin Color

# === Variables Globales para Progreso ===
TOTAL_STEPS=9
CURRENT_STEP=0

# === Función para Actualizar la Barra de Progreso General ===
update_progress() {
    local progress=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
    local total=50
    local filled=$(( progress * total / 100 ))
    local empty=$(( total - filled ))
    # Barra de progreso: [#####-----] 50%
    printf "\r${BLUE}Progreso General: ["
    for ((i=0; i<filled; i++)); do printf "#"; done
    for ((i=0; i<empty; i++)); do printf "-"; done
    printf "] %d%%${NC}" "$progress"
    echo ""
}

# === Función para Mostrar Mensaje de Proceso Individual ===
print_step() {
    local msg="$1"
    echo -e "${YELLOW}➡️  $msg...${NC}"
}

# === Función de Logging Verboso con Timestamp ===
log_msg() {
    local status="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $status: $*" >> /var/log/aura-install.log
}

# === Función para Incrementar el Contador de Pasos y Actualizar la Barra ===
next_step() {
    CURRENT_STEP=$(( CURRENT_STEP + 1 ))
    update_progress
}

# === Validaciones Iniciales ===
echo -e "${BLUE}🔍 Verificando versión de Ubuntu...${NC}"
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "24.04" && "$UBUNTU_VERSION" != "24.10" ]]; then
    echo -e "${RED}❌ Error: Este script está diseñado para Ubuntu 24.04 o 24.10.${NC}"
    log_msg "ERROR" "Versión no compatible: $UBUNTU_VERSION"
    exit 1
elif [[ "$UBUNTU_VERSION" == "24.10" ]]; then
    echo -e "${YELLOW}⚠️  Advertencia: Ubuntu 24.10 detectado. Continuando la instalación...${NC}"
    log_msg "INFO" "Ubuntu 24.10 detectado, se continúa la instalación"
fi
next_step

echo -e "${BLUE}📡 Verificando conectividad a Internet...${NC}"
if ! ping -c 1 google.com > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: No hay conexión a Internet.${NC}"
    log_msg "ERROR" "Fallo en la conectividad a Internet"
    exit 1
fi
next_step

# === Configuraciones Previas ===
echo -e "${BLUE}📁 Creando directorio base /home/auraInst/...${NC}"
mkdir -p /home/auraInst/ && log_msg "INFO" "Directorio /home/auraInst/ creado"
next_step

echo -e "${BLUE}📜 Configurando log en /var/log/aura-install.log...${NC}"
sudo touch /var/log/aura-install.log && sudo chown $USER:$USER /var/log/aura-install.log
# Redirigir salida a log (stdout y stderr)
exec > >(tee -a /var/log/aura-install.log) 2>&1
next_step

# === Actualización del Sistema ===
print_step "Actualizando el sistema (apt update & upgrade)"
sudo apt update -y && sudo apt upgrade -y
log_msg "INFO" "Sistema actualizado"
next_step

# === Instalación de Paquetes Base ===
print_step "Instalando paquetes esenciales (git, curl, wget, software-properties-common)"
sudo apt install -y git curl wget software-properties-common apt-transport-https ca-certificates lsb-release gnupg
log_msg "INFO" "Paquetes base instalados"
next_step

# === Limpieza del Escritorio ===
print_step "Limpiando el escritorio y ocultando el icono 'Home'"
rm -rf ~/Desktop/*
gsettings set org.gnome.nautilus.desktop home-icon-visible false
log_msg "INFO" "Escritorio limpio y home oculto"
next_step

# === Instalación de Google Chrome ===
print_step "Instalando Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo dpkg -i /tmp/chrome.deb
sudo apt -f install -y
rm /tmp/chrome.deb
log_msg "INFO" "Google Chrome instalado"
next_step

# === Instalación de Zsh y Oh My Zsh ===
print_step "Instalando Zsh y configurando Oh My Zsh (modo no interactivo)"
sudo apt install -y zsh
# Ejecutar el script de instalación de Oh My Zsh en modo no interactivo
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
log_msg "INFO" "Zsh y Oh My Zsh instalados"
next_step

# === Barra de Progreso Final y Resumen ===
update_progress
echo -e "${GREEN}✅ Instalación completada exitosamente.${NC}"
echo -e "${GREEN}🔧 Desarrollado por Ing. Marco Gallegos | Agencia: Aura Dev | Más en: https://github.com/marcogll/ubuntu_aura_install${NC}"
log_msg "INFO" "Instalación finalizada con éxito"
