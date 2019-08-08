#!/bin/bash


#sudo apt update && sudo apt install -y wget tmux
#sudo yum -y update && 
sudo yum -y install tmux 
# Download Harmony Scripts
#wget https://harmony.one/wallet.sh && chmod u+x wallet.sh && ./wallet.sh -d
wget https://raw.githubusercontent.com/harmony-one/harmony/587a29696a9bf7d77226c4b5699f495e39feb032/scripts/node.sh  && chmod u+x node.sh
touch empty.txt
