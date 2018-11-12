#!/bin/sh

COMMANDLINE_PARAMETERS="${2}" #add any command line parameters you want to pass here
D1=$(readlink -f "$0")
BINARYPATH="$(dirname "${D1}")"
cd "${BINARYPATH}"
LIBRARYPATH="$(pwd)"
BINARYNAME="sflowtool"
SPID="/var/run/sflowtool.pid"

case "$1" in
 start)
  if [ -e ${SPID} ]; then
   if ( kill -0 $(cat server.pid) 2> /dev/null ); then
    echo "The server is already running, try restart or stop"
    exit 1
   else
    echo "server.pid found, but no server running. Possibly your previously started server crashed"
    echo "Please view the logfile for details."
    rm ${SPID} 
   fi
  fi
  if [ "${UID}" = "0" ]; then
   echo WARNING ! For security reasons we advise: DO NOT RUN THE SERVER AS ROOT
   c=1
   while [ "$c" -le 10 ]; do
    echo -n "!"
    sleep 1
    c=$(($c+1))
   done
   echo "!"
  fi
  echo "Starting the  server"
  if [ -e "$BINARYNAME" ]; then
   if [ ! -x "$BINARYNAME" ]; then
    echo "${BINARYNAME} is not executable, trying to set it"
    chmod u+x "${BINARYNAME}"
   fi
   if [ -x "$BINARYNAME" ]; then
    export LD_LIBRARY_PATH="${LIBRARYPATH}:${LD_LIBRARY_PATH}"     
    "./${BINARYNAME}" | ./sflow_read ${COMMANDLINE_PARAMETERS} > /dev/null &
     PID=`pidof ${BINARYNAME}`
    ps -p ${PID} > /dev/null 2>&1
    if [ "$?" -ne "0" ]; then
     echo "  server could not start"
    else
     echo $PID > ${SPID}
    fi
   else
    echo "${BINARNAME} is not exectuable, cannot start   server"
   fi
  else
   echo "Could not find binary, aborting"
   exit 5
  fi
 ;;
 stop)
  if [ -e ${SPID} ]; then
   echo -n "Stopping the   server"
   if ( kill -TERM $(cat ${SPID}) 2> /dev/null ); then
    c=1
    while [ "$c" -le 300 ]; do
     if ( kill -0 $(cat ${SPID}) 2> /dev/null ); then
      echo -n "."
      sleep 1
     else
      break
     fi
     c=$(($c+1)) 
    done
   fi
   if ( kill -0 $(cat "${SPID}") 2> /dev/null ); then
    echo "Server is not shutting down cleanly - killing"
    kill -KILL $(cat "${SPID}")
   else
    echo "done"
   fi
   rm ${SPID}
  else
   echo "No server running (${SPID} is missing)"
   exit 7
  fi
 ;;
 restart)
  $0 stop && $0 start ${COMMANDLINE_PARAMETERS} || exit 1
 ;;
 status)
  if [ -e ${SPID} ]; then
   if ( kill -0 $(cat ${SPID}) 2> /dev/null ); then
    echo "Server is running"
   else
    echo "Server seems to have died"
   fi
  else
   echo "No server running (${SPID} is missing)"
  fi
 ;;
 *)
  echo "Usage: ${0} {start|stop|restart|status}"
  exit 2
esac
exit 0
