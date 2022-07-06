#!/bin/bash

# install lxd
if lxd --help &>/dev/null;then
	echo "lxd is already installed" 
else 
	echo "Installing lxd!"; 
	sudo snap install lxd; 
fi

# run lxd init --auto if no lxdbr0 interface exists
if ip link show lxdbr0 1>/dev/null;then
	echo "lxdbr0 interface exists"
else
	sudo lxd init --auto
fi

# launch a container running Ubuntu 20.04 server named COMP2101-S22 if necessary
if sudo lxc list | grep -q COMP2101-S22 &>/dev/null;then
	echo "Container has been launched"
else 
	echo "Setting up the COMP2101-S22 container"
	sudo lxc launch images:ubuntu/20.04  COMP2101-S22; 
fi

# add or update the entry in /etc/hosts for hostname COMP2101-S22 with the container’s current IP address if necessary
IP=$(sudo lxc list COMP2101-S22 -c 4 | grep eth | awk '{print $2}')
sudo sed -i '/COMP2101-S22/d' /etc/hosts && echo "$IP COMP2101-S22" | sudo tee -a /etc/hosts 1>/dev/null && echo "Added IP to the file"

# install Apache2 in the container if necessary
if sudo lxc exec COMP2101-S22 -- systemctl status apache2 &>/dev/null ;then 
	echo "Apache2 is already installed"
else 
	echo "Apache2 is not installed, installing now";
	sudo lxc exec COMP2101-S22 -- apt-get update &>/dev/null
	sudo lxc exec COMP2101-S22 -- apt install -y apache2 &>/dev/null
fi

# retrieve the default web page from the container and notify the user of success or failure
curl http://COMP2101-S22 && echo 'success fetching page' || echo 'failure fetching page'
