#!/usr/bin/env ash
#
# Copyright (C) 2023 AuxXxilium <https://github.com/AuxXxilium>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

if [ "${1}" = "late" ]; then
  echo "Installing cpufreqscalingscaling - ${1}"
  mkdir -p "/tmpRoot/usr/arc/addons/"
  cp -vf "${0}" "/tmpRoot/usr/arc/addons/"

  cp -vf /usr/sbin/scaler.sh /tmpRoot/usr/sbin/scaler.sh
  cp -vf /usr/sbin/unscaler.sh /tmpRoot/usr/sbin/unscaler.sh
  cp -vf /usr/sbin/rescaler.sh /tmpRoot/usr/sbin/rescaler.sh
  cp -vf /usr/bin/echo /tmpRoot/usr/bin/echo

  if [ "${2}" = "userspace" ]; then
    mkdir -p "/tmpRoot/usr/lib/systemd/system"
    DEST="/tmpRoot/usr/lib/systemd/system/cpufreqscaling.service"
    cat > ${DEST} <<EOF
[Unit]
Description=Enable CPU Freq scaling
DefaultDependencies=no
IgnoreOnIsolate=true
After=multi-user.target

[Service]
User=root
Restart=always
RestartSec=30
ExecStart=/bin/ash /usr/sbin/scaler.sh

[X-Synology]
Author=Virtualization Team
EOF
    mkdir -vp /tmpRoot/usr/lib/systemd/system/multi-user.target.wants
    ln -vsf /usr/lib/systemd/system/cpufreqscaling.service /tmpRoot/usr/lib/systemd/system/multi-user.target.wants/cpufreqscaling.service
  else
    mkdir -p "/tmpRoot/usr/lib/systemd/system"
    DEST="/tmpRoot/usr/lib/systemd/system/cpufreqscaling.service"
    cat > ${DEST} <<EOF
[Unit]
Description=Enable CPU Freq scaling
DefaultDependencies=no
IgnoreOnIsolate=true
After=multi-user.target

[Service]
User=root
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/ash /usr/sbin/rescaler.sh ${2}

[X-Synology]
Author=Virtualization Team
EOF
    mkdir -vp /tmpRoot/usr/lib/systemd/system/multi-user.target.wants
    ln -vsf /usr/lib/systemd/system/cpufreqscaling.service /tmpRoot/usr/lib/systemd/system/multi-user.target.wants/cpufreqscaling.service
  fi
  if [ ! -f /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db ]; then
    echo "copy esynoscheduler.db"
    mkdir -p /tmpRoot/usr/syno/etc/esynoscheduler
    cp -vf /addons/esynoscheduler.db /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db
  fi
  echo "insert scaling... task to esynoscheduler.db"
  export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
  if [ "${2}" = "userspace" ]; then
    /tmpRoot/bin/sqlite3 /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
DELETE FROM task WHERE task_name LIKE 'Rescaler';
INSERT INTO task VALUES('Rescaler', '', 'bootup', '', 1, 0, 0, 0, '', 0, '/usr/sbin/scaler.sh', 'script', '{}', '', '', '{}', '{}');
DELETE FROM task WHERE task_name LIKE 'Unscaler';
INSERT INTO task VALUES('Unscaler', '', 'shutdown', '', 0, 0, 0, 0, '', 0, '/usr/sbin/unscaler.sh', 'script', '{}', '', '', '{}', '{}');
EOF
  else
    /tmpRoot/bin/sqlite3 /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
DELETE FROM task WHERE task_name LIKE 'Rescaler';
INSERT INTO task VALUES('Rescaler', '', 'bootup', '', 1, 0, 0, 0, '', 0, '/usr/sbin/rescaler.sh ${2}', 'script', '{}', '', '', '{}', '{}');
DELETE FROM task WHERE task_name LIKE 'Unscaler';
INSERT INTO task VALUES('Unscaler', '', 'shutdown', '', 0, 0, 0, 0, '', 0, '/usr/sbin/unscaler.sh', 'script', '{}', '', '', '{}', '{}');
EOF
  fi
elif [ "${1}" = "uninstall" ]; then
  echo "Installing cpufreqscalingscaling - ${1}"

  rm -f "/tmpRoot/usr/lib/systemd/system/multi-user.target.wants/cpufreqscaling.service"
  rm -f "/tmpRoot/usr/lib/systemd/system/cpufreqscaling.service"

  rm -f /tmpRoot/usr/sbin/scaler.sh
  rm -f /tmpRoot/usr/sbin/rescaler.sh
  rm -f /tmpRoot/usr/sbin/unscaler.sh
fi