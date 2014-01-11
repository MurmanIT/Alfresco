#!/bin/bash
#
# Script install of Alfresco on Ubuntu
# Author Anton Drelin

export ALF_HOME=/opt/alfresco
export TOMCAT=$ALF_HOME/tomcat
export ALF_USER=alfresco
export TOMCAT_DOWNLOAD=http://apache.mirror.rafal.ca/tomcat/tomcat-7/v7.0.50/bin/apache-tomcat-7.0.50.tar.gz
#Russian locate
export UTF=ru_RU.utf8

#Color variables

blue=$(tput setaf 4)
white=$(tput setaf 7)
#red=$(tpuf setaf 1)

#function print blue text
info(){
	echo "${blue}$1${txtrst}"
}

whtext(){
	echo "${white}$1${txtrst}"
}

error(){
   echo "${red}$1${txtrst}"
}


cd /tmp
if [ -d "alf_install" ]; then
	rm -rf alf_install
fi
mkdir alf_install
cd ./alf_install

# f - function
# in - value/input

#Update and Uprade System
f_update_upgrade(){
whtext
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get clean
	echo "Adding locale support"
	sudo locale-gen $UTF
}

#Add user in system
f_add_user(){
whtext
	sudo adduser --system --no-create-home --disabled-login --disabled-password --group $ALF_USER
}

#Update limit.conf
f_update_limit_conf(){
whtext
	echo "alfresco  soft  nofile  8192" | sudo tee -a /etc/security/limits.conf
	echo "alfresco  hard  nofile  65536" | sudo tee -a /etc/security/limits.conf	
}

#Install Java Oracle 7
f_install_java(){
whtext
	sudo apt-get install python-software-properties -y
	sudo add-apt-repository ppa:webupd8team/java	
	sudo apt-get update
	sudo apt-get install oracle-java7-installer oracle-java7-set-default -y
}

f_install_tomcat(){
whtext
	wget  $TOMCAT_DOWNLOAD
	sudo mkdir -p $ALF_HOME
	tar xf "$(find . -type f -name "apache-tomcat*")"
	sudo mv "$(find . -type d -name "apache-tomcat*")" $TOMCAT	

}

f_install_addons(){
whtext
	sudo apt-get install imagemagick ghostscript libgs-dev libjpeg62 libpng3 ffmpeg -y
	sudo apt-get install -f -y
	sudo add-apt-repository ppa:guilhem-fr/swftools
	sudo apt-get update
	sudo apt-get install swftools -y	
}

f_install_office(){
whtext	
	sudo apt-get install libreoffice ttf-mscorefonts-installer fonts-droid -y
}

info
read -e -p "Update and Upgrade System [y/n] " -i "n" in_update
if [ "$in_update" = "y" ]; then
	f_update_upgrade
info
	echo "Finish update and upgrade"
else
	echo "Skipping update and upgrade"
fi

read -e -p "Add alfresco system user [y/n] " -i "n" in_user
if [ "$in_user" = "y" ]; then
	f_add_user
info
	echo "Finish adding alfresco user"
else
	echo "Skipping adding alfresco user"
fi

read -e -p "Update limits.conf [y/n] " -i "n" in_limit
if [ "$in_limit" = "y" ]; then	
	f_update_limit_conf
info
	echo "Finish update limit.conf"	
else
	echo "Skipping update limit.conf"
fi

read -e -p "Install Oracle Java 7 [y/n] " -i "n" in_java
if [ "$in_java" = "y" ]; then
	f_install_java
info
	echo "Finish install java"	
else
	echo "Skipping install java"
fi

read -e -p "Install Tomcat [y/n] " -i "n" in_tomcat
if [ "$in_tomcat" = "y" ]; then
	f_install_tomcat
info
	echo "Finish install Tomcat"
else
	echo "Skipping install Tomcat"
fi

read -e -p "Install Libreoffice [y/n] " -i "n" in_libreoffice
if [ "$in_libreoffice" = "y" ]; then
	f_install_office
info
	echo "Finish LibreOffice"
else
	echo "Skipping install libreoffice"
fi

read -e -p "Install ImageMagick MPEG Swftools [y/n] " -i "n" in_addons
if [ "$in_addons" = "y" ]; then
	f_install_addons
info
	echo "Finish ImageMagic and MPEG, Swftools"
else
	echo "Skipping install ImageMagick, MPEG,Swftools"
fi

whtext 
