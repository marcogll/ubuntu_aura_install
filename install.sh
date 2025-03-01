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

# Instalar herramientas básicas
install_package curl
install_package wget

# Instalar Exfatprogs
install_package exfatprogs

# Instalar Gparted
install_package gparted

# Intentar instalar Btop
echo "Intentando instalar Btop..."
sudo apt install btop -y >> "$log_file" 2>&1
if [ $? -ne 0 ]; then
    log_message "Btop no encontrado en los repositorios"
    echo "Btop no encontrado. Instálalo manualmente desde https://github.com/aristocratos/btop"
fi

# Instalar Grub Customizer (requiere agregar PPA)
add_ppa ppa:danielrichter2007/grub-customizer
echo "Actualizando repositorios después de agregar PPA..."
sudo apt update >> "$log_file" 2>&1 || log_message "Error actualizando repositorios después de agregar PPA"
install_package grub-customizer

# Mensaje final
if [ -z "$failed_packages" ]; then
    echo "Instalación completada sin errores."
else
    echo "Algunos paquetes fallaron: $failed_packages. Revisa el log en $log_file para más detalles."
fi

log_message "Fin de la instalación"
