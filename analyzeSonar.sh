#!/usr/bin/env bash

PWD=`pwd`

if [ ! -f $HOME/.ssh/id_rsa.pub ]; then
    echo "****First, you need settings ssh conection with https://ci.uva3.com https://docs.gitlab.com/ee/ssh/ "}
    exit 0
fi

repos=(
  "$PWD/projects/levelLic"
  "$PWD/projects/LevelWeb"
  "$PWD/projects/lvlandroid"
  "$PWD/projects/WebAppIonic"
  "$PWD/projects/OmtWsSymfony"
  "$PWD/projects/OpenMyTabWeb"
  #"$HOME/project/Sonar/projects/SuperDashboard"
  #"$HOME/project/Sonar/projects/Web"
  
)
echo -e "----- ---------------------- ----------------------- ----\n "
echo -e "---Verify if directory for" ${#repos[@]} "repositorie exist---\n"
echo -e "----- ---------------------- ----------------------- ----\n "

#Validacion realizada para determinar si preguntar antes de ejecutar 
#O ejecutar directamente, ante todo en despliegue en servidor
GIT="git clone -b testing "
COMPOSE="/usr/local/bin/docker-compose exec -T"
if [ ! -d "/home/ubuntu" ]; then
    if [ "x$(id -u)" == 'x0' ]; then
        echo -e "${RED}********This script can not executed by root********${SET}."
        exit 0
    fi
fi 

for repo in "${repos[@]}"
do
  if [ ! -d ${repo} ]; then
    echo -e "----- ---------------------- ----------------------- ----\n "
    echo -e "****First, you need download every repositorie.****\n "${repo}
    echo -e "----- ---------------------- ----------------------- ----\n "
    name="${repo##*/}"
    for pjt in $name
    do
      if [ ! -e ${pjt} ]; then

        if [ ${pjt} == "levelLic" ]; then
          cd projects
          echo "Downloading.... "$pjt""
          $GIT ssh://git@ci.uva3.com:10022/uva3/level/"$pjt".git
          if [ -d "/home/ubuntu" ]; then chown -R ubuntu.ubuntu $pjt; fi
          cd ..
          $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=Licensor -Dsonar.projectBaseDir=/data/project/levelLic/ -Dsonar.source=src
        fi  
        if [ ${pjt} == "LevelWeb" ]; then
          cd projects
          echo "Downloading.... "$pjt""
          $GIT ssh://git@ci.uva3.com:10022/uva3/level/"$pjt".git
          if [ -d "/home/ubuntu" ]; then chown -R ubuntu.ubuntu $pjt; fi
          cd ..
          $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=LevelWeb -Dsonar.projectBaseDir=/data/project/LevelWeb/ -Dsonar.source=web
        fi
        if [ ${pjt} == "lvlandroid" ]; then
          cd projects
          echo "Downloading.... "$pjt""
          $GIT ssh://git@ci.uva3.com:10022/uva3/level/"$pjt".git
          if [ -d "/home/ubuntu" ]; then chown -R ubuntu.ubuntu $pjt; fi
          cd ..
          $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=LvlAndroid -Dsonar.projectBaseDir=/data/project/lvlandroid/ -Dsonar.source=src
        fi
        if [ ${pjt} == "WebAppIonic" ]; then
          cd projects
          echo "Downloading.... "$pjt""
          $GIT ssh://git@ci.uva3.com:10022/uva3/openmytab/"$pjt".git
          if [ -d "/home/ubuntu" ]; then chown -R ubuntu.ubuntu $pjt; fi
          cd ..
          $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=WebAppIonic -Dsonar.projectBaseDir=/data/project/WebAppIonic/ -Dsonar.source=src
        fi
        if [ ${pjt} == "OmtWsSymfony" ]; then
          cd projects
          echo "Downloading.... "$pjt""
          $GIT ssh://git@ci.uva3.com:10022/uva3/openmytab/"$pjt".git
          if [ -d "/home/ubuntu" ]; then chown -R ubuntu.ubuntu $pjt; fi
          cd ..
          $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=OmtWebServices -Dsonar.projectBaseDir=/data/project/OmtWsSymfony -Dsonar.source=src
        fi
        if [ ${pjt} == "OpenMyTabWeb" ]; then
          cd projects
          echo "Downloading.... "$pjt""
          $GIT ssh://git@ci.uva3.com:10022/uva3/openmytab/"$pjt".git
          if [ -d "/home/ubuntu" ]; then chown -R ubuntu.ubuntu $pjt; fi
          cd ..
          $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=OmtWeb -Dsonar.projectBaseDir=/data/project/OpenMyTabWeb -Dsonar.source=src
        fi
        # if [ ${pjt} == "test" ]; then
        #   echo "Downloading.... "$pjt""
        # fi  
        #git clone -b testing ssh://git@ci.uva3.com:10022/uva3/$name
        #git clone -b testing ssh://git@ci.uva3.com:10022/uva3/$name
        #git clone -b testing ssh://git@ci.uva3.com:10022/uva3/$name
      fi  
    done
  fi
done

set_variables(){
  repository=$(git rev-parse --show-toplevel)
  currentBranch=$(git rev-parse --abbrev-ref HEAD)
  localCommit=$(git rev-parse HEAD)
  remoteCommit=$(git ls-remote origin -h refs/heads/$currentBranch | awk -F' ' '{print $1}')
}

main(){
  ## Move directory
  cd $PWD/projects/levelLic
  ## set variables by git using funcion set_variables
  set_variables
  ## Download changes if exist.
  fetch 0
  ## Move directory
  cd projects/LevelWeb
  ## set variables by git using funcion set_variables
  set_variables
  ## Download changes if exist.
  fetch 1
  ## Move directory
  cd projects/lvlandroid
  ## set variables by git using funcion set_variables
  set_variables
  ## Download changes if exist.
  fetch 2
  ## Move directory
  cd projects/WebAppIonic
  ## set variables by git using funcion set_variables
  set_variables
  ## Download changes if exist.
  fetch 3
  cd projects/OmtWsSymfony
  ## set variables by git using funcion set_variables
  set_variables
  ## Download changes if exist.
  fetch 4
  ## Move directory
  cd projects/OpenMyTabWeb
  ## set variables by git using funcion set_variables
  set_variables
  ## Download changes if exist.
  fetch 5
  
}

scanner(){
    
  if [ "$1" == "1" ]; then
    $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=Licensor -Dsonar.projectBaseDir=/data/project/levelLic/ -Dsonar.source=src
  fi
  
  if [ "$1" == "2" ]; then
    $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=LevelWeb -Dsonar.projectBaseDir=/data/project/LevelWeb/ -Dsonar.source=web 
  fi

  if [ "$1" == "3" ] ; then
    $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=LvlAndroid -Dsonar.projectBaseDir=/data/project/lvlandroid/ -Dsonar.source=src
  fi

  if [ "$1" == "4" ]; then
    $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=WebAppIonic -Dsonar.projectBaseDir=/data/project/WebAppIonic/ -Dsonar.source=src
  fi
  if [ "$1" == "5" ]; then
    $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=OmtWebServices -Dsonar.projectBaseDir=/data/project/OmtWsSymfony -Dsonar.source=src
  fi
  if [ "$1" == "6" ]; then
    $COMPOSE sonarqube sonar-scanner -Dsonar.projectKey=OmtWeb -Dsonar.projectBaseDir=/data/project/OpenMyTabWeb -Dsonar.source=src
  fi
}


fetch(){
  IS_BUILD=$(($1+1))
  if [ "$currentBranch" == "testing" ]; then

      ## Compare if the commit in remote branch is different to local
      echo "local branch is: $localCommit and remote branch is $remoteCommit of the '$PWD' repository"

      if [ "$localCommit" != "$remoteCommit" ]; then
          ## run commands for download files to local if repo is testing branch
          git fetch --all
          git reset --hard origin/testing
          #RUTA_SCAN=`pwd`
          cd ../../
          scanner $(($IS_BUILD))                      
        else
          cd ../../      
      fi
      

    else
      echo "You need set up in Testing branch for continue, use the command 'git branch testing' for set up. '$repository' repository"
      
      
  fi

}

main 

exit 0

