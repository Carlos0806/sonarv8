# SonarQube

Para la instalación de SonarQube se debe de tener instalado docker y docker-compose
*  [Docker for Mac](https://docs.docker.com/docker-for-mac/)
*  [Docker Linux](https://websiteforstudents.com/how-to-install-docker-and-docker-compose-on-ubuntu-16-04-18-04/)

Con docker instalado y encendido ahora se debe descargar el [proyecto Sonar del CI](ssh://git@ci.uva3.com:10022/uva3/software-testing-and-qa-services/sonar.git), al descargar el proyecto debe de hacerse en el HOME de sistemas en una directorio llamado project.

## Lanzar SoanrQube

Ahora accederemos al proyecto con la siguiente linea en la terminal 
`$ cd $HOME/project/Sonar`, una vez ubicado en el proyecto se deberá ejecutar los siguientes comandos:
*  `$ docker-compose build`
*  `$ docker-compose up -d`

Esto con el fin de construir y levantar el contenedor que contendrá todas las características necesarias para alojar SonarQube, cuando este procesos termine, bastara con escribir **localhost:9000** en el navegador

## Analizar Proyectos

con el contenedor de SonarQube iniciado, ahora se pasara a la parte de análisis de proyectos, para esto se debe de ejecutar el siguiente script `$ ./analyzeSonar.sh`. cuando este script se ejecute completamente, en nuestra pagina de SonarQube se empezara a ver reflejados los proyectos.