#!/bin/bash

# Script Definition
logpath=/var/log/deploymentscriptlog

# Update Package List
echo "#############################" >> $logpath
echo "Setting up Terraform" >> $logpath
echo "#############################" >> $logpath
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Upgrading Linux Distribution
echo "#############################" >> $logpath
echo "Upgrading Linux Distribution" >> $logpath
echo "#############################" >> $logpath
sudo apt-get update >> $logpath
sudo apt-get -y upgrade >> $logpath
echo " " >> $logpath

# Install Azure CLI
echo "#############################" >> $logpath
echo "Installing Azure CLI" >> $logpath
echo "#############################" >> $logpath
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform
echo "#############################" >> $logpath
echo "Installing Terraform" >> $logpath
echo "#############################" >> $logpath
sudo apt install terraform