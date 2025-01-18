#!/bin/bash

# apt update -y && apt upgrade -y
CONFIG_OVERWRITE=0
clear

if [ "$1" == "-o" ]; then
  CONFIG_OVERWRITE=1
fi

echo -e "\e[33mTERMUX Samba Script: SERVER\e[0m\n"
if [ -z $TERMUX_VERSION ]; then
  echo -e "\e[33mIt seems TERMUX is not available.\e[0m"
  echo -e "\e[33mScript might work but is optimized for android devices.\e[0m"
fi

if ! command -v ifconfig >/dev/null; then
  echo "Installing net-tools"
  apt install net-tools -y
fi

if ! command -v sed >/dev/null; then
  echo "Installing Text utils..."
  apt install sed -y
fi

if ! command -v git >/dev/null; then
  echo "Installing Git"
  apt install git -y
fi

if ! command -v smbd >/dev/null; then
  echo "Installing Samba server"
  apt install samba -y
fi

mkdir -p $HOME/repo
cd $HOME/repo

if [ ! -e $HOME/repo/android-samba-server ]; then
  echo "Cloning repo..."
  git clone https://github.com/fireclouu/android-samba-server

  if [ $? -ne 0 ]; then
    echo -e "\e[31mFailed cloning repository!"
    exit 1
  fi
else
  echo "Checking for updates..."
  cd $HOME/repo/android-samba-server
  git pull &>/dev/null
fi

echo "Changing directory to $HOME/repo/android-samba-server"
cd $HOME/repo/android-samba-server

if [ ! -z $TERMUX_VERSION ]; then
  echo "Requesting storage permission..."
  yes | termux-setup-storage &>/dev/null
fi

echo "Creating directories..."
mkdir -p $PREFIX/etc/samba
mkdir -p $HOME/remote_share

echo "Setting shared folder permission to 755..."
chmod -R 755 $HOME/remote_share

if [ ! -e $PREFIX/etc/smb.conf ] || [ $CONFIG_OVERWRITE -eq 1 ]; then
  echo "Copy and link default configs..."
  rm -f $PREFIX/etc/smb.conf
  rm -f $PREFIX/etc/samba/smb.conf
  cp $PWD/config/smb.conf $PREFIX/etc/
  ln -s $PREFIX/etc/smb.conf $PREFIX/etc/samba/smb.conf
fi

echo -en "\e[33mInput server password (leave blank to unchange):\e[0m "
read -s password

if [ -z $password ]; then
  echo "(Unchanged)"
else
  echo -en "$password\n$password" | smbpasswd -L -c $PREFIX/etc/smb.conf -a $(whoami) >/dev/null
  echo
fi

ifconfig

echo -e "\e[33mRun client-windows.ps1 on your PC and input your home IP network, see output above.\n[ Waiting for client device... ]\e[0m"
client_ip=$(nc -lvnp 9000 2>&1 | awk 'NR==2 {print $4}')

echo -e "\e[32mClient $client_ip communicated!\e[0m"
echo "Sending user $(whoami)...."
echo $(whoami) | nc -lnp 9000
echo -e "\e[32mSent successfully!\e[0m"

echo "Terminate existing samba servers before starting one..."
pkill smbd

echo "Starting new samba server.."
smbd -D -s $PREFIX/etc/smb.conf

echo -e "\e[32mServer has started!\e[0m"
echo "Waiting for client to finish binding..."
client_ip=$(nc -lvnp 9000 2>&1 | awk 'NR==2 {print $4}')
echo -e "\e[32mClient binding successful!\e[0m"
