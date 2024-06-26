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


### Apunte antes de empezar con la explicación

- Esta práctica ha sido revisada anteiormente por JJ en clase, por lo tanto las máquinas que utilicé para su correspondiente instalación estan borradas por falta de espacio en *_AWS_* , aun así realizaré la explicación de todos los scrips de manera individual y diviendo la práctica en diferentes fases.

    1. Fase 0 : Instalación de WordPress en un nivel ( Un único servidor con todo lo necesario ) Lo que quiere decir en un solo *_FRONT_END_*


    2. Fase 1: Instalación de WordPress en dos niveles ( Un servidor Web y un servidor MySQL)

    3. Fase 2: Instalación de WordPress a tres niveles ( Balanceador, 2 Servidores Web, Servidor NFS y Servidor MYSQL) 

- La fase 2 será la que utilicemos en esta práctica, los anteriores han sido lo que hemos ido realizando en prácticas anteriores como pueden ser [Practica 1-10 de IAW](https://github.com/kinoibanez/Practica01-10IAW) 


## Estructura de los archivos.

- La estructura de los archivos será la siguiente, siguiendo el orden de directorios ue comentamos anteriormente:

    ![](images/cap2.png)



# Carpetas con archivos de configuración.

- La primera carpeta que contiene una serie de archivos de configuración es nuestra carpeta *_conf_*. 

    Esta carpeta tiene en su interior nuestro archivo *_000-default.conf_* que como sabemos se almacena en `etc/apache2/sites-availables`

    Y tendrá el siguiente contenido: 
    ```
        <VirtualHost *:80>
    #ServerName www.example.com
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
    <Directory "/var/www/html">
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>
        
    ```

- El siguiente archivo que encontramos dentro de esta carpeta es el archivo de configuración del balanceador. El cual tiene el siguiente contenido: 

    ```
    <VirtualHost *:80>
        <Proxy balancer://mycluster>
            # Server 1
            BalancerMember http://IP_HTTP_SERVER_1

            # Server 2
            BalancerMember http://IP_HTTP_SERVER_2
        </Proxy>

        ProxyPass / balancer://mycluster/
    </VirtualHost>

    ```

    Aquí podemos observar como en este archivo de configuración declaramos los *_miembros_* que van a ser utilizado en nuestro valanceador.

    Las variables *_IP_HTTP_SERVER__* son variables que nosotros hemos declaro en nuestro archivo `.env` que contiene la IP privada de cada uno de los servidores que queremos que se usen en el balanceador.

    ![](images/cap3.png)


### Carpeta *_Exports_*

- El contenido de la carpeta Exports contiene la siguiente linea: 

    ```
    /var/www/html NFS_FRONTEND_NETWORK(rw,sync,no_root_squash,no_subtree_check)
    ```

    Este archivo será el encargado de contener la configuración de la exportación del directorio en un servidor NFS SERVER.

    Encontramos una serie de parámetros, la explicación de ellos es la siguiente:

    1. `rw: permite lectura y escritura`
    2. `sync: Los cambios en el sistema de archivos se sincronizan`
    3. `no_root_squash: Permite que el usuario *root* tenga los mismos permisos en ambos lados, tanto cliente/servidor`
    4. `no_subtree_check: Desactiva la comprobación del subarbol para mejorar el rendimiento con archivos bastante grandes`

    Realmente la funcionalidad de esta carpeta es compartir todo esto en el directorio `var/www/html` del servidor en cuestión

    Nuestra variable que va en la linea de código estará configurada en nuestro archivo `.env`

    ![](images/cap4.png)

### Carpeta *_htacces_* 

- Como en prácticas anteriores esta carpeta contiene una serie de sentencias que lo que hacen es declarar una serie de reglas en nuestro servidor. Las reglas que encontramos pueden ser:

    1. `RewriteEngine ON: Habilita el motor de reescritura`
    2. `RewriteBase /: Define la URL`
    3. `RewriteRule ^index\.php$ : Indica que si alguien accede directamente a index.php no se realizará ninguna manipulación de datos`
    4. `RewriteCond %{REQUEST_FILENAME} !-f: Verifica si existe el archivo que solicitamos `
    5. `RewriteCond %{REQUEST_FILENAME} !-d: Igual que la anterior, pero verifica si el directorio solicitado es correcto`
    6. `RewriteRule . /index.php [L]: Si el archivo que estamos solicitando no pertenece a nada, reenvia todas las solicitudes a index.php`

    El contenido en este caso de nuestro archivo dentro de esta carpeta es el siguiente:

    ```
    # BEGIN WordPress
    <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.php$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]
    </IfModule>
    # END WordPress

    ```
### Carpeta *_php_*

- Esta carpeta unicamente contiene un *_index.php_* por lo tanto no merece explicación :)

    ![](images/cap5.png)

# *_SCRIPTS_*

- Para hablar de los scripts debido a que son varios, he decidido dividirlo en tres apartados:

    1. Instalación de cada uno ( FRONT_END, BACK_END, BALANCER, NFS SERVER AND CLIENT)

    2. Deploy de los FRONT y BACKS

    3. Instalar un certificado *_Les´t Encrypt_* con *_Cerbot_*.

# Instalaciones

## Instalación de las pilas *_LAMP_* en los *_FRONT_END_*

- La instalación de la PILA LAMP tendremos que realizarla en los dos fronts, por lo tanto este código si lo hemos utilizado en prácticas anteriores y es el siguiente:

    ```
    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -x 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    # Instalamos el servidor web apache A.

    apt install apache2 -y

    # Instalamos PHP.

    sudo apt install php libapache2-mod-php php-mysql -y

    #Copiamos el directorio 000-default.conf (Archivo de configuración de apache2)

    cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

    # Instalamos PHP.

    sudo apt install php libapache2-mod-php php-mysql -y

    # Reiniciamos el servicio (apache)

    systemctl restart  apache2

    # Modificamos el propietario y el grupo del directorio /var/www/html

    chown -R www-data:www-data /var/www/html


    ```

    Como podemos observar cada línea del script indica que función realiza ese comando.

## Instalación del *_BACK_END_*

- Para la instalación del BACK tendremos que hacer que se descargue alguna serie de programa como son *_MYSQL_*, hacer que *_MySQL_* tenga conexión solo a través de la ip privada. 

    Asi mismo también creamos el usuario para la base de datos.


    ```
    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -x 
    #Actualizamos los repositorios
    apt update

    #Añadimos el source

    source .env

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    # Instalamos Mysql L.

    sudo apt install mysql-server -y

    #Configuramos MYSQL para que sólo acepte conexiones desde la IP privada

    sed -i "s/127.0.0.1/$MYSQL_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf


    #Creamos el usuario en MYSQL

    DROP USER IF EXISTS '$DB_USER'@'$FRONTEND_PRIVATE_IP';
    CREATE USER '$DB_USER'@'$FRONTEND_PRIVATE_IP' IDENTIFIED BY '$DB_PASS';
    GRANT ALL PRIVILEGES ON '$DB_NAME'.* TO '$DB_USER'@'$FRONTEND_PRIVATE_IP';

    #Reiniciamos el servicio de mysql

    systemctl restart mysql

    ```

# Instalación del *_LOAD_BALANCER_* 

- En este script vamos a configurar la instalación de manera correcta del balanceador, los apartados mas importantes a comentar en este script son:

    1. Instalar `apache`
    2. Habilitar los módulos de `apache` que son correctos: 
        - `sudo a2enmod proxy: Habilita la funcionalidad del proxy en Apache`
        - `sudo a2enmod proxy_http: Este módulo le permite a Apache actuar como un servidor HTTP.`
        - `sudo a2enmod proxy_balancer: Este módulo permite balancear las solicitudes de carga entro los servidores de backend`
        - `mod_lbmethod_byrequests: Este modulo nos proporciona una serie de equilibrio entre las diferentes peticiones que nos hagan.`

    3. Los dos últimos modulos que tenemos que modificar son los siguientes:
    ``` 
    #Habilitamos el virtualhost que hemos creado.

        sudo a2ensite load-balancer.conf 

        #Deshabilitamos el que tiene apache por defecto.

        sudo a2dissite 000-default.conf 

    ```
    ```
    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -x 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 


    #apt upgrade -y

    source  .env
    # Instalamos el servidor web apache A.

    apt install apache2 -y

    #Habilitamos los modulos necesarios para configurar apache como proxy inverso.

    sudo a2enmod proxy
    sudo a2enmod proxy_http
    sudo a2enmod proxy_balancer

    #Habilitamos el balanceo de carga Round Robin

    sudo a2enmod lbmethod_byrequests


    #copiamos el archivo de configuración 

    sudo cp ../conf/load-balancer.conf /etc/apache2/sites-available

    #Remplazamos los valores de la plantilla con la dirección IP de los frontales 

    sed -i "s/IP_HTTP_SERVER_1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/load-balancer.conf
    sed -i "s/IP_HTTP_SERVER_2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/load-balancer.conf

    #Habilitamos el virtualhost que hemos creado.

    sudo a2ensite load-balancer.conf 

    #Deshabilitamos el que tiene apache por defecto.

    sudo a2dissite 000-default.conf 

    #Reiniciamos el servicio

    sudo systemctl restart apache2

    ```

## Instalación del *_NFS SERVER_*

- Para la instalación del servidor NFS tendremos que ejecutar el siguiente script:

    ``` 
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

    ```

- Algunas de las lineas mas importantes que encontramos en este script son como crear principalmente el directorio `/var/www/html` donde queremos compartir la información. 

    Ejecutar el cambios de permisos para que cualquier usuario pueda utiliazrlo, y como podemos observar en el comando de `sed -i` hemos utilizado `#` en vez de `/` esto es debido a que si no, el comando no funciona de manera correcta por haber un fallo con los simbolos.


## Instalamos el *_NFS_CLIENT_*

- Para el cliente tendremos que hacer uso de dos *_scripts_* que tendremos que ir lanzando de manera conjunta en ambos clientes. Como en este caso son los *_FRONTS_*

    El primer script que encontramos es el siguiente llamado *_install_nfs_client*:

    ```
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

    ```

- Lo funcionalidad de este script es instalar el paquete para el cliente, crear el montaje y habilitar una linea de configuración de manera manual en el directorio `/etc/fstab` para que cuando se reinice siga esa misma configuración.

    Los diferentes parámetros que podemos encontrar son los siguientes:

    - `nfs: Tipo de archivos`
    - `auto: Lo monta automaticamente`
    - `nofail: Permite que el sistema siempre se inicie aunque el montaje falle`
    - `noatime: No actualiza el tiempo`
    - `nolock: Deshabilitar el bloqueo de archivos NFS`
    - `intr: Si el servidor no responde, las operaciones se interrumpen`
    - `>> /etc/fstab: Haciendo uso del comando echo, agregamos y modificamos la linea dentro del archivo que estamos indicandole`

    La variable que estamos utilizando es la siguiente `$NFS_SERVER_PRIVATE_IP` que será la IP privada de nuestro servidor NFS.

    ![](images/cap6.png)


### Segundo Scrit del cliente.

- El siguiente script que tendremos que ejecutar en el cliente es el siguiente: `nfs_client.sh` que realiza una serie de funciones parecidas al anterior.



    ```
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

    ```


### Comandos utiles de uso

- Existe un comando llamado `df -h` que podemos usar en el *_NFS_SERVER_* para observar que se ha montado la IP de manera correcta y los archivos que se han montado.

    El parámetro `-h` permite que el tamaño de los archivos sea legible.


- Si después de todo estos scripts queremos comprobar que el valanceador realiza un función podemos acceder a nuestro nombre de dominio declarado en las variables y que anteriormente hemos de tener registrado, por ejemplo en mi caso se llama `practica-https.ddns.net` y lo tengo registrado con la `IP pública` del balanceador en [La página Web de NO-IP](https://www.noip.com/es-MX/login)

    Si queremos comprobar su correcto funcionamiento accedemos a nuestro dominio por URL y hacemos `F5` y si accedemos al directorio de Apache: `/var/log/apache2/access.log` podremos ver cuando se realizan las peticiones de cada uno.

# Script para *_DEPLOY FRONT_END AND BACK_END_*


- Primero vamos hablar del *_deploy_backend_* debido a que este script como hemos configurado anteriormente, es el encargado de la instalación, creación y configuración de la base de datos. Es decir, siempre que digamos de ejecutar este script borraremos la base de datos del sistema y por lo tanto tendremos que hacerlo todo de nuevo, asi que ojo.

    ```
    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -ex 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    #Incluimos las variables del archivo .env

    source .env
    # Creamos la base de datos y el usuario de base de datos.

    mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
    mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
    mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
    mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
    mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

    ```

    Como en prácticas anteriores nuestras variables estan declaradas en nuestro archivo `.env` ( Al final de la práctica adjuntaré una foto con mi configuración del archivo `.env`)



## Deploy FRONT_END

- El deploy del *_FRONT_* como en prácticas anteriores, conlleva la instalación de Wordpress, configuración de manera automática, configuración ede su propio directorio, archivos como `wp-cli` que es una interfaz por linea de comandos, etc...


- Cabe recalcar que en este script todo la instalación tiene que estar hecha de manera autónoma, por lo tanto las variables que encontremos estarán declaradas anteriormente en `.env`


    ```
    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -ex 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    #Incluimos las variables del archivo .env

    source .env

    #Eliminamos instalaciones previas 

    rm -rf /tmp/wp-cli.phar

    # Descargamos la utilidad de wp-cli

    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

    #Le asignamos permisos de ejecución al archivo wp-cli.phar

    chmod +x /tmp/wp-cli.phar

    #Movemos el archivo al directorio /usr/local/bin que almacena el listado de comandos del sistema.

    mv /tmp/wp-cli.phar /usr/local/bin/wp #wp es renombrado


    #Eliminamos instalaciones previas de wordpress

    rm -rf /var/www/html/*

    #Descargamos el codigo fuente de wordpress en /var/wwW/html

    wp core download --locale=es_ES --path=/var/www/html --allow-root

    #Crear el archivo .config, podemos comprobar haciendo un cat cat /var/www/html/wp-config.php si estan bien las variables

    wp config create \
    --dbname=$WORDPRESS_DB_NAME \
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST \
    --path=/var/www/html \
    --allow-root


    #Instalamos el directorio WORDPRESS con las variables de configuración en .env

    wp core install \
    --url=$CERTIFICATE_DOMAIN \
    --title="$WORDPRESS_TITLE"\
    --admin_user=$WORDPRESS_ADMIN_USER \
    --admin_password=$WORDPRESS_ADMIN_PASS \
    --admin_email=$WORDPRESS_ADMIN_EMAIL \
    --path=/var/www/html \
    --allow-root

    #Copiamos el archivo .htaccess

    cp ../htaccess/.htaccess /var/www/html/


    # Descargamos un plugin para la seguridad de WordPress

    sudo wp plugin install wp-staging --activate --path=/var/www/html --allow-root


    #Descargamos un tema cualquiera para la configuración

    #sudo wp  theme install Hestia --activate list --path=/var/www/html --allow-root

    #Descargamos un pluggin cualquiera.

    wp plugin install bbpress --activate --path=/var/www/html --allow-root

    #Links

    wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root


    #Modificar nombres

    wp option update whl_page "NotFound" --path=/var/www/html --allow-root

    #Coniguramos el nombre de la entrada 

    wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root

    #Modificamos los permisos de /var/www/html

    chown -R www-data:www-data /var/www/html

    sed -i "/COLLATE/a \$_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php

    ```


    Las lineas del código las hemos comentado anteriormente en otras prácticas, de todos modos cada linea tiene su correspondiente explicación pero hay algunos parámetros que caben recalcar como puede ser el uso del `sed -i` en la siguiente linea ` sed -i "/COLLATE/a \$_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php` que lo modificará para que `HTTPS este ON` siempre.


# Instalación del `Lest Encrypt`

- Como siguiente apartado hacemos uso del siguiente scritp que hemos utilizado en prácticas anteriores, con las respectivas variables del `.env` configuradas para descargar la herramienta *_cerbot_* que nos permite registrar un servicio seguro *_HTTPS_* con el nombre de nuestro dominio.

    ```

    #!/bin/bash

    #Esto muestra todos los comandos que se van ejecutando
    set -ex 
    #Actualizamos los repositorios
    apt update

    #Actualizamos los paquetes de la máquina 

    #apt upgrade -y

    #Importamos el archivo de variables .env

    source .env

    #Instalamos y Actualizamos snapd.

    snap install core
    snap refresh core

    # Eliminamos cualquier instalación previa de certobot con apt.

    apt remove certbot

    # Instalamos el cliente de Certbot con snapd.

    snap install --classic certbot

    # Creamos un alias para la aplicación cerbot.

    sudo ln -sf /snap/bin/certbot /usr/bin/certbot

    # Obtenemos el certificado y configuramos el servidor web Apache.

    #sudo certbot --apache

    #Ejecutamos el comando certbot.
    certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive


    #Con el siguiente comando podemos comprobar que hay un temporizador en el sistema encargado de realizar la renovación de los certificados de manera automática.

    #systemctl list-timers

    ```


## Imágen de mi archivo .env 

- Como hemos utilizado una cantidad de variables que son diferentes adjunto una captura de mi archivo `.env` para que podamos visualizar el nombre de cada una y relacionarla con su respectiva configuración en cada uno de los scripts.

- Al final de todo la funcionalidad de esta práctica es que tengamos en cada uno de los *_FRONT_* instalados *_Word_Press_*, que el *_balanceador_* funcione de manera correcta y que compartan todo en el directorio `var/ww/html` de nuestro servidor `NFS SERVER`

    ![](images/cap7.png)