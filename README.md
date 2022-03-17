# COLCHA DE TESOROS - DESPLIEGUE EN EL I3LAP

## Contenido
  * [Descripción](#descripcion)
  * [Prerrequisitos](#prerrequisitos)
  * [Despliegue en Docker utilizando el docker-compose](#despliegue)

<a name="descripcion"></a>
## Descripción

Este proyecto contiene la información necesaria para desplegar Colcha de Tesoros en el I3LAP utilizando Docker. 

### Software utilizado:

* Sistema operativo del I3LAP: Ubuntu 16.04.5 LTS (Xenial Xerus)
* Docker: Versión 20.10.7
* Docker compose: Version 1.18.0
* MySQL: Versión 14.14 Distribución 5.7.33

<a name="prerrequisitos"></a>
## Prerrequisitos

### Credenciales de acceso
Se deben solicitar las siguientes credenciales:

* Credenciales de acceso por SSH al I3LAP.
* Credenciales de acceso a MySQL.
* Contraseña de un usuario con privilegios de root.

### Conexión al I3LAP mediante SSH
Para establecer la conexión puede utilizar el software PuTTY que puede descargar dando clic [aquí.][putty]

[putty]: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

### Apertura de puertos en el I3LAP
* Los puertos 3306 (Base de datos), 8090 (Videojuego), 3000 (Sistema de información) y 3001 (Backend) deben estar abiertos en el I3LAP, para ello ejecutar los siguientes comandos en la shell del dispositivo.    

Para entrar al modo super usuario ejecutar:  

```bash
    sudo su
```

Para la apertura de puertos ejecutar:  

```bash
    sudo ufw allow 3306
    sudo ufw allow 3000
    sudo ufw allow 3301
    sudo ufw allow 8090
```

### Permitir las conexiones externas a la base de datos
En el archivo /etc/mysql/mysql.conf.d/mysqld.cnf  ubicar la línea bind-address = 127.0.0.1 y cambiarla por bind-address = 0.0.0.0

### Conecta el I3LAP a Internet
Conectar un cable de red con acceso a Internet en el purto LAN que se encuentra más cercano al puerto donde se conecta el adaptador de corriente.

<a name="despliegue"></a>
## Despliegue en Docker utilizando el docker-compose

### Clonar el proyecto:

Para clonar el proyecto ejecutar los siguientes comandos:

```bash
    cd /
    mkdir repositories
    cd repositories
    git clone https://github.com/jrgranada/Colcha-de-Tesoros-WebGl-i3lap.git
    cd Colcha-de-Tesoros-WebGl-i3lap/
```

### Creación de la base de datos y del usuario mysql:

Para crear la base de datos y un usuario para su acceso, se deben ejecutar los siguientes comandos, en este punto es requerido el usuario de MySQL:

```bash
    mysql -u root -p
    CREATE DATABASE talentum_inclusion_narino;
    CREATE USER 'narino-user'@'%' IDENTIFIED BY 'Inclusionnarino2022*';
    GRANT ALL PRIVILEGES ON talentum_inclusion_narino.* TO 'narino-user'@'%' IDENTIFIED BY 'Inclusionnarino2022*';
    FLUSH PRIVILEGES;
    Exit;
```

### Cargue de la base de datos

Para cargar la infromación en la base de datos creada en el paso anterior, se debe ejecutar el siguiente comando:

```bash
    mysql -u root -p talentum_inclusion_narino < docker/db/inclusion-narino-db.sql
```

### Despliegue de la solución

Para el despliegue de la solución se deben ejecutar los siguientes comandos:

```bash
    docker kill $(docker ps -q)
    docker rm $(docker ps -a -q)
    iptables -L
    service docker restart
    docker-compose -d -p "inclusion_narino" up
```




