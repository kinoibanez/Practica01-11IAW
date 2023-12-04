# Practica01-11IAW
Este repositorio es para la Práctica 1 apartado 11 de IAW


## Introducción, ¿Que tenemos que hacer?

- En esta práctica vamos a ver como implementar *_WordPress_* en una arquitectura de tres niveles y añadiendo una máquina nueva llamada *_NFS_SERVER_*.


    En el servidor *_NFS_* almacenaremos los directorios de *_Apache2_* los cuales son `/var/www/html` en un mismo servidor. Para esto más adelante haremos una serie de *_scripts_* de instalación tanto para el cliente como para el servidor.

    La imagen de esta arquitectura se representa de la siguiente manera:

    ![](images/cap1.png)

    Asi mismo, tendremos que tener un orden de carpetas para poder almacenar la configuración correspondiente de la práctica.

    El orden será el siguiente: 

    1. `Carpeta conf` --> `000-default.conf / load-balancer.conf` 
    2. `Carpeta Exports` --> Que almacenerá una linea que modificaremos en un script para su correcta configuración de ip :  `/var/www/html NFS_FRONTEND_NETWORK(rw,sync,no_root_squash,no_subtree_check)` Realmente es una plantilla que nosotros creamos para poder modificarlo más adelante para remplazarlo por una variable, aunque realmente, es un archivo `.txt`
    3. `Carpeta htacces` --> Tendrá en su interior nuestro archivo `.htacces` que anteriormente hemos configurado en otras prácticas.
    4. `Carpeta php` --> Carpeta que tiene en su interior el archivo `index.php`
    5. `Carpeta Scripts` --> Carpeta principal que almacenará todos los *_scripts_* que deberemos ir lanzando dentro de cada máquina.
    6. `Carpeta images` --> Carpeta opcional mía donde almacenaré imagenes de la práctica.
