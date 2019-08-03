#!/usr/bin/env bash

function linux_install {
    declare -A osInfo;
    osInfo[/etc/redhat-release]=yum
    osInfo[/etc/arch-release]=pacman
    osInfo[/etc/SuSE-release]=zypper
    osInfo[/etc/debian_version]=apt-get 

    for f in ${!osInfo[@]}; do
        if [[ -f $f ]];then
            case ${osInfo[$f]} in
                yum)
                    if [[ $EUID -ne 0 ]]; then
                        sudo yum update
                        sudo yum install wget unzip
                    else
                        yum update
                        yum install wget unzip
                    fi
                    ;;
                pacman)
                    pacman -Syu
                    if [[ $EUID -ne 0 ]]; then sudo pacman -S wget unzip; else pacman -S wget unzip; fi
                    ;;
                zypper)
                    zypper update
                    if [[ $EUID -ne 0 ]]; then sudo zypper install wget unzip; else zypper install wget unzip; fi
                    ;;
                apt-get)
                    apt-get update
                    if [[ $EUID -ne 0 ]]; then sudo apt-get install wget unzip; else apt-get install wget unzip; fi
                    ;;
                *)
                    echo Error: package manager not recognized
                    exit 1
            esac

            wget https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
            if [[ $EUID -ne 0 ]]; then
                sudo unzip ./terraform_0.12.6_linux_amd64.zip -d /usr/local/bin/
            else
                unzip ./terraform_0.12.6_linux_amd64.zip -d /usr/local/bin/
            fi
        fi
    done
}

function terraform_install {
    OS=$(uname -s)

    case $OS in
        Darwin)
            curl -O https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_darwin_amd64.zip
            unzip ./terraform_0.12.6_darwin_amd64.zip -d /usr/local/bin/
            ;;
        Linux)
            linux_install
            ;;
        *)
            echo Error: OS not recognized
            exit 1
    esac
}

function get_one_click_folder {
    OS=$(uname -s)
    case $OS in
            Darwin)
                curl -O https://one-click-test.s3.amazonaws.com/one-click-deploy.zip
                ;;
            Linux)
                wget https://one-click-test.s3.amazonaws.com/one-click-deploy.zip
                 ;;
             *)
                echo Error: OS not recognized
                exit 1
    esac
}

function setup_terraform {
    terraform init
}
function get_stuff {
    get_one_click_folder
    terraform_install
    setup_terraform
} 

ACTION=$1

if [ -z "$ACTION" ]; then
   ACTION=download
fi

case $ACTION in
   usage)
        show ;;
   download)  
         get_stuff ;;
esac

exit 0


