#!/usr/bin/env bash

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install nfs-kernel-server -y

#sudo -i
TEST=false
NFS_MOUNT=/mqm
sudo mkdir -p $NFS_MOUNT

sudo mkdir -p /opt/data/vol/0
sudo mkdir -p /opt/data/vol/1
sudo mkdir -p /opt/data/vol/2
sudo mkdir -p /opt/data/content
sudo chmod -R 0777 /opt/data

sudo groupadd mqm
sudo useradd -g mqm mqm 
sudo usermod -a -G mqm mqm
sudo usermod -aG sudo mqm
sudo chmod -R 0777 $NFS_MOUNT
sudo chown -R mqm:mqm $NFS_MOUNT

sudo mkdir -p /var/jenkins_home
sudo groupadd jenkins
sudo useradd -g jenkins jenkins 
sudo usermod -a -G jenkins jenkins
sudo usermod -aG sudo jenkins
sudo chmod -R 0777 /var/jenkins_home
sudo chown -R jenkins:jenkins /var/jenkins_home

sudo echo "$NFS_MOUNT  *(rw,sync,no_subtree_check)" >> /etc/exports
sudo echo "/var/jenkins_home  *(rw,sync,no_subtree_check)" >> /etc/exports
sudo echo "/opt/data  *(rw,sync,no_subtree_check)" >> /etc/exports

sudo exportfs -arvf
#echo "Verify the mount point is being exported from this server"
#showmount -e

# to verify if this part works
# start
sudo mount --bind /var/jenkins_home /var/jenkins_home
sudo echo "/var/jenkins_home    /var/jenkins_home   none    bind  0  0" >> /etc/fstab

sudo mount 192.168.99.103:/var/jenkins_home /var/jenkins_home
# end

sudo systemctl start nfs-kernel-server
sudo systemctl enable nfs-kernel-server
sudo systemctl status nfs-kernel-server

#sudo apt-get install rsync -y 

# added on 02-06-2020 (2nd June 2020)
# Enable ssh password authentication
echo "[TASK 11] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 12] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
