#!/bin/bash

# Definir el archivo de log
log_file="install_log.txt"
failed_packages=""
total_steps=30  # Número aproximado de pasos (ajusta según necesidades)
current_step=0

###############################################################################
#                              PALETA CATPPUCCIN FRAPPE                      #
#    (Basada en https://github.com/catppuccin/catppuccin/blob/main/docs)     #
###############################################################################
BASE="\033[48;2;48;52;70m"          # Fondo (opcional si deseas pintar todo el fondo)
RESET_BG="\033[49m"                 # Reset de fondo por si lo usas
TEXT="\033[38;2;198;208;245m"       # Texto principal (#c6d0f5)
ACCENT="\033[38;2;244;184;228m"     # Rosa (#f4b8e4)
BLUE="\033[38;2;140;170;238m"       # Azul (#8caaee)
GREEN="\033[38;2;166;209;137m"      # Verde (#a6d189)
PEACH="\033[38;2;239;159;118m"      # Durazno (#ef9f76)
RED="\033[38;2;231;130;132m"        # Rojo (#e78284)
LAVENDER="\033[38;2;186;187;241m"   # Lavanda (#babbf1)
RESET="\033[0m"                     # Reset total de atributos de color

###############################################################################
# Función: spinner
# Descripción: Muestra un pequeño "spinner" animado mientras se realiza algo.
###############################################################################
spinner() {
    local mensaje="$1"
    local -r FRAMES="/-\|"
    local pid=$!
    local i=0

    echo -en "${ACCENT}$mensaje ${RESET}"
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${ACCENT}%s %s${RESET}" "$mensaje" "${FRAMES:$i:1}"
        sleep 0.1
    done
    echo -ne "\r"
}

# Función para registrar mensajes en el log
log_message() {
    echo "$(date): $1" >> "$log_file"
}

# Función para instalar paquetes y registrar errores
install_package() {
    echo -e "Instalando $1... 🌟"
    (sudo apt install "$1" -y >> "$log_file" 2>&1) & spinner "Procesando..."
    if [ $? -ne 0 ]; then
        log_message "Error instalando $1 🎇"
        failed_packages="$failed_packages $1"
    fi
    ((current_step++))
    show_progress "Instalando $1"
}

# Función para agregar PPA y registrar errores
add_ppa() {
    echo -e "Agregando PPA $1... ⚙️"
    (sudo add-apt-repository "$1" -y >> "$log_file" 2>&1) & spinner "Procesando..."
    if [ $? -ne 0 ]; then
        log_message "Error agregando PPA $1 🎇"
        failed_packages="$failed_packages PPA:$1"
    fi
    ((current_step++))
    show_progress "Agregando PPA $1"
}

# Función para mostrar estado y barra de progreso
show_progress() {
    # Limpiar la pantalla para actualizar la barra
    clear
    # Estado (lo que se está haciendo)
    echo -e "${LAVENDER}Estado: $1${RESET}"
    # Barra de progreso específica (por tarea, 20 caracteres)
    local step_progress=$((current_step * 20 / total_steps))
    echo -n "${BLUE}Progreso tarea: ["
    for ((i = 0; i < 20; i++)); do
        if [ $i -lt $step_progress ]; then
            echo -n "#"
        else
            echo -n "-"
        fi
    done
    echo -e "] (${current_step}/${total_steps}) 🌟${RESET}"
    # Mostrar el nuevo logo ASCII (una vez al inicio o cuando sea necesario)
    if [ $current_step -eq 1 ]; then
        echo ""
        echo -e "${ACCENT}                                                                                                     ${RESET}"
        echo -e "${ACCENT}                                                                                                     ${RESET}"
        echo -e "${ACCENT}             @@@%:         @@@@##        :::-@     @@@@@@@@@@@@@#               @@@%::               ${RESET}"
        echo -e "${ACCENT}            @@@@@*::       @@@@###       :::-@@@   @@@@@@@@@@@@@@@:            @@@@@%::              ${RESET}"
        echo -e "${ACCENT}           @@@@@@@+::      @@@@###       :::-@@@   @@@@::     @@@@@::         @@@@@@@+::             ${RESET}"
        echo -e "${ACCENT}          @@@@@@@@@::      @@@@###       :::-@@@   @@@@::       @@@@::        @@@@@@@@-::            ${RESET}"
        echo -e "${ACCENT}         @@@@@  @@@%::     @@@@###       :::=@@@   @@@@::       @@@@::       @@@@  @@@@-::           ${RESET}"
        echo -e "${ACCENT}         @@@@   @@@@%::    @@@@###       :::+@@@   @@@@::      @@@@-::      @@@@     @@%:::          ${RESET}"
        echo -e "${ACCENT}        @@@@@@@@@@@ @*:    @@@@###       :::+@@@   @@@@:: @@@@@@@@=:::     @@@@@  @@@@@@*::          ${RESET}"
        echo -e "${ACCENT}       %@@@@@@@@@@@-:  :   @@@@###       :::*@@@   @@@@::+@@@@@@*::::     @@@@@  @@@@@@@@+::         ${RESET}"
        echo -e "${ACCENT}      @@@@@##@@@@@@@::     @@@@###        ::%@@@   @@@@:: @@@@@::::       @@@@  @@@@@@@@@@-::        ${RESET}"
        echo -e "${ACCENT}     %@@@%###    @@@%:::   @@@@###        :@@@@@   @@@@:::  @@@@         @@@@####      @@@@:::       ${RESET}"
        echo -e "${ACCENT}     @@@%###      @@@#:::   @@@@@#       @@@@@@@   @@@@:::   @@@@       @@@@####        @@@%:::      ${RESET}"
        echo -e "${ACCENT}    @@@%###        @@@-:::   @@@@@@@@@@@@@@@@@@    @@@@:::    @@@@     @@@@%###          @@@*:::     ${RESET}"
        echo -e "${ACCENT}   @@@@####        %@@@-:::     @@@@@@@@@@@@@      @@@@:::     @@@@    @@@@###           @@@@-::     ${RESET}"
        echo -e "${ACCENT}   #%%####           #%=::::       @@@@@@@@         ###*+-      @@@@@ @@@####*              +-:::    ${RESET}"
        echo -e "${ACCENT}                                                                                                     ${RESET}"
        echo ""
    fi
    echo ""
}

# Limpiar la pantalla
clear

# Pregunta 1: Confirmación de instalación
read -p "$(echo -e "${LAVENDER}¿Deseas continuar con la instalación? (s/n) [n]: ${RESET}")" respuesta
if [ "$respuesta" != "s" ]; then
    echo -e "${RED}Instalación cancelada. 🚫${RESET}"
    exit 1
fi

# Crear directorio para wallpapers si no existe
mkdir -p ~/Pictures/wallpaper
((current_step++))
show_progress "Creando directorio para wallpapers"

# Mover cherry.jpg desde auraInstall al directorio correcto
if [ -f ~/auraInstall/cherry.jpg ]; then
    mv ~/auraInstall/cherry.jpg ~/Pictures/wallpaper/
    echo -e "${GREEN}Movido cherry.jpg a ~/Pictures/wallpaper. 🌟${RESET}"
else
    echo -e "${RED}No se encontró cherry.jpg en ~/auraInstall. Asegúrate de colocarlo allí si deseas usarlo como wallpaper. ⚠️${RESET}"
fi
((current_step++))
show_progress "Moviendo cherry.jpg"

# Configurar el wallpaper con cherry.jpg
if [ -f ~/Pictures/wallpaper/cherry.jpg ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/wallpaper/cherry.jpg"
    echo -e "${GREEN}Wallpaper configurado con cherry.jpg. 🖼️${RESET}"
else
    echo -e "${RED}No se encontró 'cherry.jpg' en ~/Pictures/wallpaper. Saltando configuración del wallpaper. ⚠️${RESET}"
fi
((current_step++))
show_progress "Configurando wallpaper"

# Pregunta 2: Foto de perfil
echo -e "${TEXT}Por favor, coloca tu foto de perfil (perfil.jpg o perfil.png) en ~/Pictures/wallpaper y presiona Enter para continuar... 📸${RESET}"
read -p ""
((current_step++))
show_progress "Esperando foto de perfil"

# Verificar si la foto de perfil existe y copiarla como imagen de usuario
if [ -f ~/Pictures/wallpaper/perfil.jpg ]; then
    sudo cp ~/Pictures/wallpaper/perfil.jpg /var/lib/AccountsService/icons/$USER
    echo -e "${GREEN}Foto de perfil configurada como imagen de usuario. 🌟${RESET}"
elif [ -f ~/Pictures/wallpaper/perfil.png ]; then
    sudo cp ~/Pictures/wallpaper/perfil.png /var/lib/AccountsService/icons/$USER
    echo -e "${GREEN}Foto de perfil configurada como imagen de usuario. 🌟${RESET}"
else
    echo -e "${RED}No se encontró perfil.jpg o perfil.png en ~/Pictures/wallpaper. Saltando configuración de la foto de perfil. ⚠️${RESET}"
fi
((current_step++))
show_progress "Configurando foto de perfil"

# Iniciar el log
echo -e "${TEXT}Iniciando instalación. Los logs se guardarán en $log_file. 📝${RESET}"
log_message "Inicio de la instalación"

# Actualizar el sistema
echo -e "${TEXT}Actualizando el sistema... 🔄${RESET}"
(sudo apt update >> "$log_file" 2>&1 && sudo apt upgrade -y >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error actualizando el sistema 🎇"
    failed_packages="$failed_packages Sistema"
fi
((current_step++))
show_progress "Actualizando el sistema"

# Instalar Flatpak
echo -e "${TEXT}Instalando Flatpak... 📦${RESET}"
install_package flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >> "$log_file" 2>&1 || log_message "Error configurando Flatpak 🎇"

# Instalar Curl y Wget
echo -e "${TEXT}Instalando Curl y Wget... 🌐${RESET}"
install_package curl
install_package wget

# Instalar Homebrew
echo -e "${TEXT}Instalando Homebrew... 🍺${RESET}"
(/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$log_file" 2>&1) & spinner "Procesando..."
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
source ~/.bashrc
((current_step++))
show_progress "Instalando Homebrew"

# Instalar GCC con Homebrew
echo -e "${TEXT}Instalando GCC con Homebrew... 🛠️${RESET}"
(brew install gcc >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando GCC con Homebrew 🎇"
    failed_packages="$failed_packages GCC"
fi
((current_step++))
show_progress "Instalando GCC"

# Instalar Fzf
echo -e "${TEXT}Instalando Fzf... 🔍${RESET}"
install_package fzf

# Instalar Zsh
echo -e "${TEXT}Instalando Zsh... 🐚${RESET}"
install_package zsh

# Instalar Oh My Posh
echo -e "${TEXT}Instalando Oh My Posh... 🎨${RESET}"
(brew install jandedobbeleer/oh-my-posh/oh-my-posh >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando Oh My Posh 🎇"
    failed_packages="$failed_packages Oh My Posh"
fi
echo -e "${TEXT}Descargando tema para Oh My Posh...${RESET}"
mkdir -p ~/.config/oh-my-posh
wget https://github.com/JanDeDobbeleer/oh-my-posh/raw/main/themes/catppuccin.omp.json -O ~/.config/oh-my-posh/catppuccin.omp.json >> "$log_file" 2>&1 || log_message "Error descargando tema Oh My Posh 🎇"
echo -e "${TEXT}Instalando fuente Meslo...${RESET}"
(oh-my-posh font install meslo >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando fuente Meslo 🎇"
    failed_packages="$failed_packages Meslo Font"
fi
((current_step++))
show_progress "Instalando Oh My Posh"

# Instalar Oh My Zsh
echo -e "${TEXT}Instalando Oh My Zsh... 🌟${RESET}"
(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando Oh My Zsh 🎇"
    failed_packages="$failed_packages Oh My Zsh"
fi
((current_step++))
show_progress "Instalando Oh My Zsh"

# Configurar Oh My Posh en .zshrc
echo -e "${TEXT}Configurando Oh My Posh en .zshrc... 📝${RESET}"
echo 'eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/catppuccin.omp.json)"' >> ~/.zshrc
((current_step++))
show_progress "Configurando Oh My Posh"

# Instalar Inkscape
echo -e "${TEXT}Instalando Inkscape... 🎨${RESET}"
install_package inkscape

# Asegurar instalación de Ubuntu Software (Gnome Store)
echo -e "${TEXT}Instalando Ubuntu Software... 🛒${RESET}"
install_package gnome-software

# Instalar Gnome Sushi
echo -e "${TEXT}Instalando Gnome Sushi... 🍣${RESET}"
install_package gnome-sushi

# Instalar Docker
echo -e "${TEXT}Instalando Docker... 🐋${RESET}"
install_package docker.io
echo -e "${TEXT}Añadiendo usuario al grupo Docker...${RESET}"
(sudo usermod -aG docker $USER >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error añadiendo usuario al grupo Docker 🎇"
    failed_packages="$failed_packages Docker Grupo"
fi
((current_step++))
show_progress "Instalando Docker"

# Instalar Lazydocker
echo -e "${TEXT}Instalando Lazydocker... 🚢${RESET}"
(brew install jesseduffield/lazydocker/lazydocker >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando Lazydocker 🎇"
    failed_packages="$failed_packages Lazydocker"
fi
((current_step++))
show_progress "Instalando Lazydocker"

# Instalar TeamViewer
echo -e "${TEXT}Instalando TeamViewer... 👥${RESET}"
(wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -O teamviewer.deb >> "$log_file" 2>&1 && \
 sudo dpkg -i teamviewer.deb >> "$log_file" 2>&1 && \
 sudo apt install -f -y >> "$log_file" 2>&1 && \
 rm teamviewer.deb) & spinner "Procesando..."
((current_step++))
show_progress "Instalando TeamViewer"

# Instalar Google Chrome
echo -e "${TEXT}Instalando Google Chrome... 🌐${RESET}"
(wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb >> "$log_file" 2>&1 && \
 sudo dpkg -i chrome.deb >> "$log_file" 2>&1 && \
 sudo apt install -f -y >> "$log_file" 2>&1 && \
 rm chrome.deb) & spinner "Procesando..."
((current_step++))
show_progress "Instalando Google Chrome"

# Instalar Zapzap via Flatpak
echo -e "${TEXT}Instalando Zapzap... 💬${RESET}"
(flatpak install flathub io.github.zapzap -y >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando Zapzap 🎇"
    failed_packages="$failed_packages Zapzap"
fi
((current_step++))
show_progress "Instalando Zapzap"

# Instalar Gimp
echo -e "${TEXT}Instalando Gimp... 🖌️${RESET}"
install_package gimp

# Intentar instalar Showtime
echo -e "${TEXT}Intentando instalar Showtime... 🎬${RESET}"
(sudo apt install showtime -y >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    echo -e "${RED}Showtime no encontrado, verifica manualmente. ⚠️${RESET}"
fi
((current_step++))
show_progress "Instalando Showtime"

# Instalar tema WhiteSur GTK
echo -e "${TEXT}Instalando tema WhiteSur GTK... 🎨${RESET}"
(git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git >> "$log_file" 2>&1 && \
 cd WhiteSur-gtk-theme && \
 ./install.sh >> "$log_file" 2>&1 && \
 cd .. && \
 rm -rf WhiteSur-gtk-theme) & spinner "Procesando..."
((current_step++))
show_progress "Instalando WhiteSur GTK"

# Instalar Catppuccin para Gnome Terminal
echo -e "${TEXT}Instalando Catppuccin para Gnome Terminal... 🌈${RESET}"
(git clone https://github.com/catppuccin/gnome-terminal.git >> "$log_file" 2>&1 && \
 cd gnome-terminal && \
 ./install.sh >> "$log_file" 2>&1 && \
 cd .. && \
 rm -rf gnome-terminal) & spinner "Procesando..."
((current_step++))
show_progress "Instalando Catppuccin"

# Instalar Python, Pip y Pipx
echo -e "${TEXT}Instalando Python, Pip y Pipx... 🐍${RESET}"
install_package python3
install_package python3-pip
(pip3 install pipx >> "$log_file" 2>&1 && \
 pipx ensurepath >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error instalando Pipx 🎇"
    failed_packages="$failed_packages Pipx"
fi
((current_step++))
show_progress "Instalando Python, Pip y Pipx"

# Instalar VSCode
echo -e "${TEXT}Instalando VSCode... 💻${RESET}"
(sudo apt install software-properties-common apt-transport-https wget -y >> "$log_file" 2>&1 && \
 wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - >> "$log_file" 2>&1 && \
 sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" >> "$log_file" 2>&1 && \
 sudo apt update >> "$log_file" 2>&1 && \
 install_package code) & spinner "Procesando..."
((current_step++))
show_progress "Instalando VSCode"

# Instalar Gnome Extensions Manager
echo -e "${TEXT}Instalando Gnome Extensions Manager... 🧩${RESET}"
install_package gnome-shell-extensions

# Instalar Grub Customizer
echo -e "${TEXT}Instalando Grub Customizer... ⚙️${RESET}"
add_ppa ppa:danielrichter2007/grub-customizer
sudo apt update >> "$log_file" 2>&1
install_package grub-customizer

# Instalar OCRmyPDF
echo -e "${TEXT}Instalando OCRmyPDF... 📜${RESET}"
install_package ocrmypdf

# Instalar Speedtest-cli
echo -e "${TEXT}Instalando Speedtest-cli... ⚡${RESET}"
install_package speedtest-cli

# Instalar Exfatprogs
echo -e "${TEXT}Instalando Exfatprogs... 💾${RESET}"
install_package exfatprogs

# Instalar Gparted
echo -e "${TEXT}Instalando Gparted... 💻${RESET}"
install_package gparted

# Intentar instalar Btop
echo -e "${TEXT}Intentando instalar Btop... 📊${RESET}"
(sudo apt install btop -y >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    echo -e "${RED}Btop no encontrado. Instálalo manualmente desde https://github.com/aristocratos/btop ⚠️${RESET}"
fi
((current_step++))
show_progress "Instalando Btop"

# Mostrar barra de progreso general al final
echo -e "${LAVENDER}Progreso general: ["
for ((i = 0; i < total_steps; i++)); do
    if [ $i -lt $current_step ]; then
        echo -n "#"
    else
        echo -n "-"
    fi
done
echo -e "] (${current_step}/${total_steps}) 🌟${RESET}"

# Mensaje final
if [ -z "$failed_packages" ]; then
    echo -e "${GREEN}Instalación completada sin errores. 🎉${RESET}"
else
    echo -e "${RED}Algunos paquetes fallaron: $failed_packages. Revisa el log en $log_file para más detalles. ⚠️${RESET}"
fi

log_message "Fin de la instalación"
echo -e "${TEXT}¿Deseas reiniciar el sistema ahora? (s/n) [n]: ${RESET}"
read -t 30 -n 1 respuesta
if [ "$respuesta" = "s" ]; then
    echo -e "${GREEN}Reiniciando el sistema... 🔄${RESET}"
    sudo reboot
else
    echo -e "${GREEN}No se reiniciará el sistema. Por favor, reinicia manualmente para aplicar todos los cambios. 🔄${RESET}"
fi

# Configurar Zsh como shell predeterminada
echo -e "${TEXT}Configurando Zsh como shell predeterminada... 🐚${RESET}"
(chsh -s $(which zsh) >> "$log_file" 2>&1) & spinner "Procesando..."
if [ $? -ne 0 ]; then
    log_message "Error configurando Zsh como shell predeterminada 🎇"
    failed_packages="$failed_packages Zsh Shell"
fi

echo -e "${GREEN}Instalación y configuración completadas. Reinicia el sistema para aplicar todos los cambios. 🌟${RESET}"
