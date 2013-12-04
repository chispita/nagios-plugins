#!/bin/sh
###################################################################

# Nagios alert status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

# Script Variable-t s
EXPECTED_ARGS=1

if [ $# -lt $EXPECTED_ARGS ]
	then
		echo "Boin.sh)"
		echo
		echo "Comprueba el funcionamiento de Boinc"
		echo
		echo "Utilización:"
		echo "  $0 <directorio proyectos> para chequear BOINC"
		echo "    Ejemplo: $0 /home/project/ibercivis"
		echo 
		echo "  $0 <directorio proyectos> <lista procesos> para chequear BOINC y procesos"
		echo "    Ejemplo: $0 /home/project/ibercivis feeder,transitioner"
		echo
		exit 1
fi

PROGRAM='BOINC'
PROCESOS=$2
PROJECT_HOME=$1

   # Volcamos el contenido del estatus a un directorio temporal
	 OUT="$(mktemp)"

	 sudo -u ibercivis $PROJECT_HOME/bin/status -v >> ${OUT}

   if [ ! -f ${OUT} ];then
	     echo "Temporal File not found!"
			 exit ${STATE_CRITIAL}
	 fi
 
   #Buscamos el contenido de BOINC
   BOINC_STATE="`cat ${OUT} | grep $PROGRAM | awk '{print $3}'`"
   if [ -z ${BOINC_STATE} ];then
     echo "BOINC PROCESS doesn't exist" 
		 rm -f ${OUT}
	   exit ${STATE_CRITICAL}
	 fi

   BOINC_STATE_DESCRIPTION="${PROGRAM}: ${BOINC_STATE}"
   if [ $BOINC_STATE != "ENABLED" ];then
		 rm -f ${OUT}
     echo ${BOINC_STATE_DESCRIPTION}
	   exit ${STATE_CRITICAL}
	 fi

   # Hacemos un loop en todos los procesos a verificar
   arrPROCESOS=$(echo ${PROCESOS} | tr "," "\n")
   for proceso in ${arrPROCESOS}
     do
	     PROCESS_STATE="`cat ${OUT} | grep $proceso | awk '{print $3}'`"

		   if [ -z  "${PROCESS_STATE}" ];then
		     PROCESS_STATE_DESCRIPTION="${PROCESS_STATE_DESCRIPTION}, $proceso: doesn't exist"
			   STATE_PROGRAM=${STATE_CRITICAL}
		  else
			   if [ "${PROCESS_STATE}" != "running" ];then
			     STATE_PROGRAM=${STATE_CRITICAL}
			   fi
				 PROCESS_STATE_DESCRIPTION="${PROCESS_STATE_DESCRIPTION}, $proceso: ${PROCESS_STATE}"
		  fi
	 done

   rm -f ${OUT}
   echo " ${BOINC_STATE_DESCRIPTION} ${PROCESS_STATE_DESCRIPTION}"
   exit ${STATE_PROGRAM}
