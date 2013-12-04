#!/bin/sh
###################################################################

# Nagios alert status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

# Script Variable-t s

PROGRAM='BOINC'
PROCESOS=$1
PROJECT_HOME=$2

   # Volcamos el contenido del estatus a un directorio temporal
	 OUT="$(mktemp)"

   sudo -u ibercivis $PROJECT_HOME/bin/status -v >> ${OUT}

   $PROJECT_HOME/bin/status -v >> ${OUT}

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
