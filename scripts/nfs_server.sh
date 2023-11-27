#!/bin/bash

#Esto muestra todos los comandos que se van ejecutando
set -ex 
#Actualizamos los repositorios
apt update

#Actualizamos los paquetes de la máquina 

#apt upgrade -y

#Incluimos las variables del archivo .env

source .env

#Instalamos el paquete necesario de NFS server

sudo apt install nfs-kernel-server -y


#Creamos el directorio que queremos compartir

mkdir -p /var/www/html 

#Le damos unos permisos especiales para que cualquier usuario lo pueda utilizar

sudo chown nobody:nogroup /var/www/html


#Copiamos el archivo exports

cp ../exports/exports /etc/exports

#Modificamos la variable #Modificamos el archivo exports.

sed -i "s#NFS_FRONTEND_NETWORK#$NFS_FRONTEND_NETWORK#" /etc/exports

#Reiniciamos el servicio.

systemctl restart nfs-kernel-server


