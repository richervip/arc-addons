# Addons for Arc Redpill Loader

### Links

- <a href="https://github.com/AuxXxilium">Overview</a>
- <a href="https://auxxxilium.tech/wiki">FAQ & Wiki</a>
- <a href="https://github.com/AuxXxilium/arc/releases/latest">Download</a>

# install
sudo -i

git clone https://github.com/AuxXxilium/arc-addons.git
cd arc-addons
chmod +x compile-addons.sh
./compile-addons.sh
cd surveillancepatchn
chmod +x install.sh
sed -i 's:cp -vf /:cp -vf all/:g' install.sh
sed -i 's:/tmpRoot:/:g' install.sh
./install.sh late
chmod +x /usr/lib/S82surveillance.sh
chmod +x /usr/bin/surveillancepatch.sh
systemctl start surveillancepatch.service
systemctl daemon-reload

### Thanks
Code is based on the work of TTG, pocopico, jumkey, fbelavenuto, wjz304 and others involved in continuing TTG's original redpill-load project.
