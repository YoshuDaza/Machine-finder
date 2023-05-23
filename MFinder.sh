#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n$redColour[!]Saliendo...${endColour}\n"
  exit 1
}

#Ctrl+c
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"


function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour} Uso:${endColour}\n" 
  echo -e "\t${purpleColour}u${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m${endColour}${grayColour} Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}d${endColour}${grayColour} Buscar por dificultad de la máquina${endColour}"
  echo -e "\t${purpleColour}o${endColour}${grayColour} Buscar por sistema operativo${endColour}"
  echo -e "\t${purpleColour}s${endColour}${grayColour} Buscar por Skill${endColour}"
  echo -e "\t${purpleColour}y${endColour}${grayColour} Obtener link de la resolución de la máquina en Youtube${endColour}"
  echo -e "\t${purpleColour}h${endColour}${grayColour} Mostrar este panel de ayuda${endColour} \n"
}


function updateFiles(){

  sleep 2

  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando todos los archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos fueron descargados con éxito${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5sum_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5sum_original_value=$(md5sum bundle.js | awk '{print $1}')

      if [ "$md5sum_temp_value" == "$md5sum_original_value" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones${endColour}\n"
        rm bundle_temp.js
      else
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
        sleep 1

        rm bundle.js && mv bundle_temp.js bundle.js

        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}"
      fi

    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina ${endColour}${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}"
  fi
    echo -e "\n"
}

function searchIP(){
  ipAdress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La máquina correspondiente a la IP${endColour}${blueColour} $ipAdress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}\n"
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi
}

function getYoutubeLink(){

  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  if [ "youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para la máquina${endColour}${yellowColour} ${machineName}${endColour}${grayColour} está en el siguiente enlace:${endColour}${purpleColour} ${youtubeLink}${endColour}\n"
  else
    echo -e "\n${redColour}[!] El link de youtube de la máquina ${purpleColour}${machineName}${endColour}${grayColour} no existe ${endColour}\n"
  fi
}

function getMachinesDifficulty(){
  difficulty="$1"

  result_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -i -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ "$result_check" ]; then
    echo -e "${yellowColour}[+]${endColour}${grayColour} Las máquinas con dificultad${endColour}${blueColour} ${difficulty}${endColour}${grayColour} son:${endColour}\n\n${purpleColour}$result_check${endColour}\n"
  else
    echo -e "\n${redColour}[!]${endColour}${grayColour} No se encontró la dificultad${endColour}${blueColour} ${difficulty}${endColour}\n"
  fi
}

function getOSMachines(){
  os="$1"

  os_results="$(cat bundle.js | grep "so: \"$os\"" -i -B 5 | grep "name:"  | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$os_results" ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas listadas con el sistema operativo${endColour} ${blueColour} ${os}${endColour}${grayColour} son:${endColour}\n\n${purpleColour}${os_results}${endColour}\n"
  else 
    echo -e "\n${redColour}[!]${endColour}${grayColour} No se encontraron máquinas de sistema operativo ${endColour}${blueColour} ${os}${endColour}\n"
  fi 
}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"

  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -i -B 5 | grep "\name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_results" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}  Las máquinas con diicultad${endColour}${blueColour} $difficulty${endColour}${grayColour} del sistema operativo${endColour}${blueColour} $os${endColour}${grayColour} son:${endColour}\n\n${check_results}\n"
  else 
    echo -e "\n${redColour}[!]${endColour}${grayColour} No se encontraron máquinas con las propiedades mensionadas ${endColour}\n" 
  fi
}

function getSkills(){
    skill="$1"

    check_skill="$(cat bundle.js| grep "skill" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

    if [ "$check_skill" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las máquinas con la Skill${endColour}${blueColour} ${skill}${endColour}\n\n${check_skill}\n"
    else
      echo -e "\n${redColour}[!]${endColour}${grayColour} No se encontraron máquinas con la Skill${endColour}${blueColour} ${skill}${endColour}\n" 
    fi 
}

# Indicadores
declare -i parameter_counter=0

# Combinadores
declare -i combinador_difficulty=0
declare -i combinador_os=0

while getopts "m:ui:y:d:o:s:h" arg ; do
    case $arg in
      m) machineName="$OPTARG"; let parameter_counter+=1;;
      u) let parameter_counter+=2;;
      i) ipAdress="$OPTARG";let parameter_counter+=3;;
      y) machineName="$OPTARG"; let parameter_counter+=4;;
      d) difficulty="$OPTARG"; combinador_difficulty=1; let parameter_counter+=5;;
      o) os="$OPTARG"; combinador_os=1; let parameter_counter+=6;;
      s) skill="$OPTARG"; let parameter_counter+=7;;
      h) ;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
  getSkills "$skill"
elif [ $combinador_difficulty -eq 1 ] && [ $combinador_os -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os
else
  helpPanel
fi
