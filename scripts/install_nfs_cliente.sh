#!/bin/bash

#Esto muestra todos los comandos que se van ejecutando
set -ex 
#Actualizamos los repositorios
apt update

#Actualizamos los paquetes de la máquina 

#apt upgrade -y

#Incluimos las variables del archivo .env

source .env

#Instalamos el paquete para el cliente

apt install nfs-common -y

#Creamos el punto de montaje
mount $NFS_SERVER_PRIVATE_IP:/var/www/html /var/www/html

#Añadimos una linea de configuracion al archivo /etc/fstab para que el punto de montaje se monte automaticamente despues de cada reinicio.

echo $NFS_SERVER_PRIVATE_IP:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0 >> /etc/fstab

#El echo añade la linea a "mano" dentro del archivo /etc/fstab