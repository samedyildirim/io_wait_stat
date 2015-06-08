#!/bin/bash

#cpu  14444691 0 2279860 106369861 12746845 110 130453 262054 0 0
#cpu0 4037595 0 701248 21543919 7366695 110 121696 122488 0 0
#cpu1 3461949 0 529905 27676621 2388970 0 2934 48990 0 0
#cpu2 3619604 0 537019 28257575 1652386 0 2874 45748 0 0
#cpu3 3325541 0 511687 28891744 1338792 0 2948 44827 0 0

SCALE="scale=2;"

#% olarak iowait limiti
IOWAIT_LIMIT=25

while [ 1 ]
do
  CPU_USAGE0=($(grep "cpu " /proc/stat))
  sleep 5
  CPU_USAGE1=($(grep "cpu " /proc/stat))

  LOAD_AVG=($(cat /proc/loadavg))
  
  TOPLAM0=$(echo ${CPU_USAGE0[*]}|grep -Po "\d*"|paste -sd +|bc)
  TOPLAM1=$(echo ${CPU_USAGE1[*]}|grep -Po "\d*"|paste -sd +|bc)

	TOPLAM_FARK=$(($TOPLAM1-$TOPLAM0))
  IDLE_STAT=$((${CPU_USAGE1[4]}-${CPU_USAGE0[4]}))
  IOWAIT_STAT=$((${CPU_USAGE1[5]}-${CPU_USAGE0[5]}))
  USER_STAT=$((${CPU_USAGE1[1]}-${CPU_USAGE0[1]}))

  IDLE_P=$(echo "$SCALE 100*$IDLE_STAT/$TOPLAM_FARK"|bc)
  IOWAIT_P=$(echo "$SCALE 100*$IOWAIT_STAT/$TOPLAM_FARK"|bc)
  USER_P=$(echo "$SCALE 100*$USER_STAT/$TOPLAM_FARK"|bc)
  IOWAIT_LIMIT_STAT=$(($TOPLAM_FARK*$IOWAIT_LIMIT/100))

  if [[ "$IOWAIT_STAT" -gt "$IOWAIT_LIMIT_STAT" ]] || [[ "${AVG[0]}" -gt "4" ]]
  then
    echo $(date +"%Y-%m-%d %H:%M:%S") "| $CPU_USAGE1 user:%$USER_P idle:%$IDLE_P iowait:%$IOWAIT_P | ${LOAD_AVG[*]}"
	fi
done
