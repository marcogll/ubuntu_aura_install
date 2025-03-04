#!/bin/bash

# Definir el archivo de log
log_file="install_log.txt"
failed_packages=""

# Función para registrar mensajes en el log
log_message() {
    echo "$(date): $1" >> "$log_file"
}

# Función para instalar paquetes y registrar errores
install_package() {
    echo "Instalando $1..."
    sudo apt install "$1" -y >> "$log_file" 2>&1
    if [ $? -ne 0 ]; then
        log_message "Error instalando $1"
        failed_packages="$failed_packages $1"
    fi
}

# Función para agregar PPA y registrar errores
add_ppa() {
    echo "Agregando PPA $1..."
    sudo add-apt-repository "$1" -y >> "$log_file" 2>&1
    if [ $? -ne 0 ]; then
        log_message "Error agregando PPA $1"
        failed_packages="$failed_packages PPA:$1"
    fi
}

# Iniciar el log
echo "Iniciando instalación. Los logs se guardarán en $log_file."
log_message "Inicio de la instalación"

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update >> "$log_file" 2>&1 && sudo apt upgrade -y >> "$log_file" 2>&1 || log_message "Error actualizando el sistema"

# Instalar Flatpak
echo "Instalando Flatpak..."
install_package flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >> "$log_file" 2>&1 || log_message "Error configurando Flatpak"

# Instalar Curl y Wget
install_package curl
install_package wget

# Instalar Homebrew
echo "Instalando Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$log_file" 2>&1
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
source ~/.bashrc

# Instalar GCC con Homebrew
echo "Instalando GCC con Homebrew..."
brew install gcc >> "$log_file" 2>&1 || log_message "Error instalando GCC con Homebrew"

# Instalar Fzf
install_package fzf

# Instalar Zsh
install_package zsh

# Instalar Oh My Posh
echo "Instalando Oh My Posh..."
brew install jandedobbeleer/oh-my-posh/oh-my-posh >> "$log_file" 2>&1 || log_message "Error instalando Oh My Posh"
echo "Descargando tema para Oh My Posh..."
mkdir -p ~/.config/oh-my-posh
wget https://github.com/JanDeDobbeleer/oh-my-posh/raw/main/themes/catppuccin.omp.json -O ~/.config/oh-my-posh/catppuccin.omp.json >> "$log_file" 2>&1 || log_message "Error descargando tema Oh My Posh"
echo "Instalando fuente Meslo..."
oh-my-posh font install meslo >> "$log_file" 2>&1 || log_message "Error instalando fuente Meslo"

# Instalar Oh My Zsh
echo "Instalando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> "$log_file" 2>&1 || log_message "Error instalando Oh My Zsh"

# Configurar Oh My Posh en .zshrc
echo "Configurando Oh My Posh en .zshrc..."
echo 'eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/catppuccin.omp.json)"' >> ~/.zshrc

# Instalar Inkscape
install_package inkscape

# Asegurar instalación de Ubuntu Software (Gnome Store)
install_package gnome-software

# Instalar Gnome Sushi
install_package gnome-sushi

# Instalar Docker
echo "Instalando Docker..."
install_package docker.io
echo "Añadiendo usuario al grupo Docker..."
sudo usermod -aG docker $USER >> "$log_file" 2>&1 || log_message "Error añadiendo usuario al grupo Docker"

# Instalar Lazydocker
echo "Instalando Lazydocker..."
brew install jesseduffield/lazydocker/lazydocker >> "$log_file" 2>&1 || log_message "Error instalando Lazydocker"

# Instalar TeamViewer
echo "Instalando TeamViewer..."
wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O teamviewer.deb >> "$log_file" 2>&1
sudo dpkg -i teamviewer.deb >> "$log_file" 2>&1
sudo apt install -f -y >> "$log_file" 2>&1
rm teamviewer.deb

# Instalar Google Chrome
echo "Instalando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb >> "$log_file" 2>&1
sudo dpkg -i chrome.deb >> "$log_file" 2>&1
sudo apt install -f -y >> "$log_file" 2>&1
rm chrome.deb

# Instalar Zapzap via Flatpak
echo "Instalando Zapzap..."
flatpak install flathub io.github.zapzap -y >> "$log_file" 2>&1 || log_message "Error instalando Zapzap"

# Instalar Gimp
install_package gimp

# Intentar instalar Showtime
echo "Intentando instalar Showtime..."
sudo apt install showtime -y >> "$log_file" 2>&1 || echo "Showtime no encontrado, verifica manualmente."

# Instalar tema WhiteSur GTK
echo "Instalando tema WhiteSur GTK..."
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git >> "$log_file" 2>&1
cd WhiteSur-gtk-theme
./install.sh >> "$log_file" 2>&1
cd ..
rm -rf WhiteSur-gtk-theme

# Instalar Catppuccin para Gnome Terminal
echo "Instalando Catppuccin para Gnome Terminal..."
git clone https://github.com/catppuccin/gnome-terminal.git >> "$log_file" 2>&1
cd gnome-terminal
./install.sh >> "$log_file" 2>&1
cd ..
rm -rf gnome-terminal

# Instalar Python, Pip y Pipx
install_package python3
install_package python3-pip
pip3 install pipx >> "$log_file" 2>&1 || log_message "Error instalando Pipx"
pipx ensurepath >> "$log_file" 2>&1

# Instalar VSCode
echo "Instalando VSCode..."
sudo apt install software-properties-common apt-transport-https wget -y >> "$log_file" 2>&1
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - >> "$log_file" 2>&1
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >> "$log_file" 2>&1
sudo apt update >> "$log_file" 2>&1
install_package code

# Instalar Gnome Extensions Manager
install_package gnome-shell-extensions

# Instalar Grub Customizer
add_ppa ppa:danielrichter2007/grub-customizer
sudo apt update >> "$log_file" 2>&1
install_package grub-customizer

# Instalar OCRmyPDF
install_package ocrmypdf

# Instalar Speedtest-cli
install_package speedtest-cli

# Instalar Exfatprogs
install_package exfatprogs

# Instalar Gparted
install_package gparted

# Intentar instalar Btop
echo "Intentando instalar Btop..."
sudo apt install btop -y >> "$log_file" 2>&1 || echo "Btop no encontrado. Instálalo manualmente desde https://github.com/aristocratos/btop"

# Mensaje final
if [ -z "$failed_packages" ]; then
    echo "Instalación completada sin errores."
else
    echo "Algunos paquetes fallaron: $failed_packages. Revisa el log en $log_file para más detalles."
fi

log_message "Fin de la instalación"
echo "Por favor, reinicia el sistema para aplicar todos los cambios (especialmente para Docker y zsh)."
