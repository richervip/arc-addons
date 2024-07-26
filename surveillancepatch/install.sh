#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing addon surveillancepatch - ${1}"
  mkdir -p "/tmpRoot/usr/arc/addons/"
  cp -vf "${0}" "/tmpRoot/usr/arc/addons/"

  cp -vf /usr/bin/surveillancepatch.sh /tmpRoot/usr/bin/surveillancepatch.sh
  cp -vf /usr/lib/libssutils.so /tmpRoot/usr/lib/libssutils.so
  cp -vf /usr/bin/license.sh /tmpRoot/usr/bin/license.sh
  cp -vf /usr/bin/S82surveillance.sh /tmpRoot/usr/bin/S82surveillance.sh
  
  mkdir -p "/tmpRoot/usr/lib/systemd/system"
  DEST="/tmpRoot/usr/lib/systemd/system/surveillancepatch.service"
  cat > ${DEST} <<EOF
[Unit]
Description=addon surveillancepatch
DefaultDependencies=no
IgnoreOnIsolate=true
After=multi-user.target

[Service]
User=root
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/surveillancepatch.sh

[Install]
WantedBy=multi-user.target

[X-Synology]
Author=Virtualization Team
EOF

  mkdir -vp /tmpRoot/usr/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/surveillancepatch.service /tmpRoot/usr/lib/systemd/system/multi-user.target.wants/surveillancepatch.service
fi
elif [ "${1}" = "uninstall" ]; then
  echo "Installing addon surveillancepatch - ${1}"
  # To-Do
fi