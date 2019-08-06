#!/bin/bash


#sudo apt update && sudo apt install -y wget tmux
#sudo yum -y update && 
sudo yum -y install tmux 
# Download Harmony Scripts
#wget https://harmony.one/wallet.sh && chmod u+x wallet.sh && ./wallet.sh -d
wget https://raw.githubusercontent.com/alajko/harmony/nodes/scripts/node.sh  && chmod u+x node.sh
touch empty.txt
