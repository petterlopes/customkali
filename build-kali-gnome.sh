#!/bin/bash
cd ~
apt update
export DEBIAN_FRONTEND=noninteractive
yes '' | apt install wget gnupg gnupg1 gnupg2 git live-build cdebootstrap devscripts libssl-dev libffi-dev python-dev build-essential -y
apt source debian-installer
git clone git://git.kali.org/live-build-config.git

cd /opt/CrackMapExec
git pull

cd /opt/Empire
git pull

cd /opt/impacket
git pull

cd /opt/Responder
git pull

cd ~/live-build-config


mkdir -p kali-config/variant-default/package-lists/
cat > kali-config/variant-default/package-lists/kali.list.chroot << EOF
# You always want those
kali-linux
kali-desktop-live

# Kali applications

# You can customize the set of Kali applications to install
# (-full is the default, -all is absolutely everything, the rest
# corresponds to various subsets)
kali-linux-full
# kali-linux-all
# kali-linux-sdr
# kali-linux-gpu
# kali-linux-wireless
# kali-linux-web
# kali-linux-forensic
# kali-linux-voip
# kali-linux-pwtools
# kali-linux-top10
# kali-linux-rfid

# Graphical desktop
kali-desktop-gnome

# meus aplicativos
remmina
freerdp-x11
cifs-utils
bleachbit
qemu
openssh-server
openvas
metasploit-framework
nano
openvpn
leafpad
libreoffice
crackmapexec
ltrace
strace
EOF

mkdir -p kali-config/common/packages.chroot
#cp ~/Downloads/powershell_6.0.0-alpha.18-1ubuntu1.16.04.1_amd64.deb kali-config/common/packages.chroot/

# Instalar o Nessus
#cp ~/Downloads/Nessus-7.0.1-debian6_amd64.deb kali-config/common/packages.chroot/

mkdir -p kali-config/common/includes.binary/isolinux/
cat << EOF > kali-config/common/includes.binary/isolinux/install.cfg
label install
    menu label ^Install Automated
    linux /install/vmlinuz
    initrd /install/initrd.gz
    append vga=788 -- quiet file=/preseed.cfg locale=pt_BR.UTF8 keymap=br-abnt2 hostname=kali domain=local.lan
EOF

#echo 'systemctl enable ssh' >>  kali-config/common/hooks/01-start-ssh.chroot
#chmod +x kali-config/common/hooks/01-start-ssh.chroot

mkdir -p kali-config/common/includes.chroot/opt/
cp -r /opt/CrackMapExec/ kali-config/common/includes.chroot/opt/
cp -r /opt/Empire/ kali-config/common/includes.chroot/opt/
cp -r /opt/impacket/ kali-config/common/includes.chroot/opt/
cp -r /opt/Responder/ kali-config/common/includes.chroot/opt/

mkdir -p kali-config/common/includes.chroot/root/Desktop/
mkdir -p kali-config/common/includes.chroot/root/Documents/

cp -r ~/Documents/ kali-config/common/includes.chroot/root/
cp ~/Desktop/acessar-pasta-compartilhada-smbclient kali-config/common/includes.chroot/root/Documents/
cp ~/Desktop/* kali-config/common/includes.chroot/root/Desktop/

mkdir -p kali-config/common/debian-installer
#wget https://raw.githubusercontent.com/offensive-security/kali-linux-preseed/master/kali-linux-full-unattended.preseed -O kali-config/common/debian-installer/preseed.cfg
cp ~/kali-linux-full-unattended.preseed kali-config/common/debian-installer/preseed.cfg
#mkdir -p kali-config/common/includes.chroot/cdrom/install/
#cp ~/kali-linux-full-unattended.preseed kali-config/common/includes.chroot/cdrom/install/preseed.cfg

./build.sh --distribution kali-rolling --variant gnome --verbose
#lb build