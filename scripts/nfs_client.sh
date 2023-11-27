#!/bin/bash

#Esto muestra todos los comandos que se van ejecutando
set -ex 
#Actualizamos los repositorios
apt update

#Actualizamos los paquetes de la máquina 

#apt upgrade -y

#Incluimos las variables del archivo .env

source .env

#Instalamos el paquete necesario de NFS client

sudo apt install nfs-common -y

#Montamos

sudo mount 172.31.94.238:/var/www/html /var/www/html