#!/usr/bin/env bash
#
# Copyright (C) 2023 AuxXxilium <https://github.com/AuxXxilium> and Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

if [[ ! -x $(which perl) ]]; then
  echo "install Perl ..."
  synopkg install_from_server Perl
fi

if [[ ! -x $(which perl) ]]; then
  echo "Perl not found"
  exit 1
fi

modprobe -q it87
modprobe -q adt7470
modprobe -q adt7475
modprobe -q nct6683
modprobe -q nct6775
modprobe -q coretemp
modprobe -q k10temp

echo 'Y' | sensors-detect --auto >/tmp/sensors.log
cat /tmp/sensors.log | grep Driver | awk '{print $2}'

sensors

echo "$@" | grep -qw "\-f" && rm -f /etc/fancontrol
if [ ! -f /etc/fancontrol ]; then
  # Or use pwmconfig to generate /etc/fancontrol interactively.
  DEVPATH=""
  DEVNAME=""
  FCTEMPS=""
  FCFANS=""
  MINTEMP=""
  MAXTEMP=""
  MINSTART=""
  MINSTOP=""
  CORETEMP="$(find /sys/devices/platform/ -name temp1_input | grep -E 'coretemp|k10temp' | sed -n -e 's|.*/\(hwmon.*\/temp1_input\).*|\1|p')"
  for P in $(find /sys/devices/platform/ -name temp1_input); do
    D="$(echo ${P} | sed -n -e 's|.*/\(devices/platform/[^/]*\)/.*|\1|p')"
    I="$(echo ${P} | sed -n -e 's|.*hwmon\([0-9]\).*|\1|p')"
    DEVPATH="${DEVPATH} hwmon${I}=${D}"
    DEVNAME="${DEVNAME} hwmon${I}=$(cat /sys/${D}/*/*/name)"
    for F in $(find "/sys/${D}" -name "fan[0-9]_input"); do
      IDX="$(echo ${F} | sed -n -e 's|.*fan\([0-9]\)_input|\1|p')"
      FCTEMPS="${FCTEMPS} hwmon${I}/pwm${IDX}=${CORETEMP}"
      FCFANS="${FCFANS} hwmon${I}/pwm${IDX}=hwmon${I}/fan${IDX}_input"
      MINTEMP="${MINTEMP} hwmon${I}/pwm${IDX}=30"
      MAXTEMP="${MAXTEMP} hwmon${I}/pwm${IDX}=70"
      MINSTART="${MINSTART} hwmon${I}/pwm${IDX}=150"
      MINSTOP="${MINSTOP} hwmon${I}/pwm${IDX}=50"
    done
    i=$((i + 1))
  done

  DEST=/etc/fancontrol
  echo "# Configuration file generated by pwmconfig, changes will be lost" >${DEST}
  echo "INTERVAL=10" >>${DEST}
  echo "DEVPATH=$(echo ${DEVPATH})" >>${DEST}
  echo "DEVNAME=$(echo ${DEVNAME})" >>${DEST}
  echo "FCTEMPS=$(echo ${FCTEMPS})" >>${DEST}
  echo "FCFANS=$(echo ${FCFANS})" >>${DEST}
  echo "MINTEMP=$(echo ${MINTEMP})" >>${DEST}
  echo "MAXTEMP=$(echo ${MAXTEMP})" >>${DEST}
  echo "MINSTART=$(echo ${MINSTART})" >>${DEST}
  echo "MINSTOP=$(echo ${MINSTOP})" >>${DEST}
fi

killall fancontrol
fancontrol &

exit 0