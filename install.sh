#!/bin/bash
#
# Script install of Alfresco on Ubuntu
# Author Anton Drelin
# 2014

export ALF_HOME=/opt/alfresco
export TOMCAT=$ALF_HOME/tomcat
export ALF_USER=alfresco
export TOMCAT_DOWNLOAD=http://apache.mirror.rafal.ca/tomcat/tomcat-7/v7.0.50/bin/apache-tomcat-7.0.50.tar.gz
export XALAN=http://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/HEAD/root/projects/3rd-party/lib/xalan-2.7.0/
export ALFWARZIP=http://dl.alfresco.com/release/community/build-4848/alfresco-community-4.2.e.zip
export GOOGLEDOCSREPO=http://dl.alfresco.com/release/community/build-4848/alfresco-googledocs-repo-2.0.5-6com.amp
export GOOGLEDOCSSHARE=http://dl.alfresco.com/release/community/build-4848/alfresco-googledocs-share-2.0.5-6com.amp
export SOLR=http://dl.alfresco.com/release/community/build-4848/alfresco-community-solr-4.2.e.zip
export SPP=http://dl.alfresco.com/release/community/build-4848/alfresco-community-spp-4.2.e.zip
export MYGITHUB=https://raw2.github.com/MurmanIT/Alfresco/master
export ALF_CONF=$TOMCAT/shared/classes

#Russian locate
export UTF=ru_RU.utf8

#PostgreSQL DB
export ALFRESCODB=alfresco
export ALFRESCOUSER=alfresco

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
#	sudo apt-get upgrade -y
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
#Install tomcat
f_install_tomcat(){
whtext
	wget  $TOMCAT_DOWNLOAD
	sudo mkdir -p $ALF_HOME
	tar xf "$(find . -type f -name "apache-tomcat*")"
	sudo mv "$(find . -type d -name "apache-tomcat*")" $TOMCAT	

}

#Configure Tomcat Server
f_configure_tomcat(){
whtext	
#	wget $MYGITHUB/tomcat/catalina.sh
#	sudo mv -b -f catalina.sh $TOMCAT/bin/catalina.sh		
#	sudo chmod 755 $TOMCAT/bin/catalina.sh
	wget $MYGITHUB/tomcat/catalina.properties	
	wget $MYGITHUB/tomcat/server.xml
	wget $MYGITHUB/tomcat/tomcat-users.xml
	sudo mv -b -f catalina.properties $TOMCAT/conf/catalina.properties
	sudo mv -b -f server.xml $TOMCAT/conf/server.xml
	sudo mv -b -f tomcat-users.xml $TOMCAT/conf/tomcat-users.xml
	wget $MYGITHUB/tomcat/tomcat
	sudo mv -b -f tomcat /etc/init.d/tomcat
	sudo chmod 755 /etc/init.d/tomcat
#	sudo update-rc.d tomcat defaults		
}

f_preinstall_alfresco(){
whtext
	sudo mkdir -p $TOMCAT/endorsed	

	wget $XALAN/xalan.jar
	sudo mv -b -f xalan.jar $TOMCAT/endorsed/xalan.jar
	wget $XALAN/serializer.jar
	sudo mv -b -f serializer.jar $TOMCAT/endorsed/serializer.jar
	sudo mkdir -p $TOMCAT/shared	
	sudo mkdir -p $TOMCAT/shared/classes
	sudo mkdir -p $TOMCAT/shared/lib	

	sudo mkdir -p $ALF_HOME/addins
	sudo mkdir -p $ALF_HOME/addons/war
	sudo mkdir -p $ALF_HOME/addons/share
	sudo mkdir -p $ALF_HOME/addons/alfresco

	sudo apt-get install unzip -y
	cd /tmp/alf_install
	wget $ALFWARZIP
	mv "$(find . -type f -name "alfresco-community*")" alf.zip
	sudo chmod a+x alf.zip
	unzip -q alf.zip
	sudo mv -b -f /tmp/alf_install/web-server/webapps/*  $TOMCAT/webapps/	
	sudo mv -b -f /tmp/alf_install/web-server/lib/*  $TOMCAT/lib 
	sudo mv -b -f /tmp/alf_install/web-server/shared/*  $TOMCAT/shared 			
	sudo mv -b -f /tmp/alf_install/web-server/endorsed/*  $TOMCAT/endorsed
}

f_configure_alfresco(){
	wget $MYGITHUB/script/office.sh
	sudo mv -b -f office.sh $ALF_HOME/office.sh
	chmod uga+x $ALF_HOME/office.sh
	wget $MYGITHUB/script/alfresco.sh
	sudo chmod uga+x alfresco.sh
	sudo mv  alfesco.sh /etc/init.d/alfresco
	sudo mkdir -p $ALF_HOME/alf_data	
	wget $MYGITHUB/config/alfresco-global.properties
	mv  alfresco-global.properties $ALF_CONF/alfresco-global.properties	

	wget $MYGITHUB/config/video-transformation-context.xml
	mv  video-transformation-context.xml $ALF_CONF/extension/video-transformation-context.xml
	
	wget $MYGITHUB/config/video-thumbnail-context.xml
	mv video-thumbnail-context.xml $ALF_CONF/extension/video-thumbnail-context.xml
}

#Install addons
f_install_addons(){
whtext
	sudo apt-get install imagemagick ghostscript libgs-dev libjpeg62 libpng3 libice6 libsm6 libxt6 libxrender1 libfontconfig1 ffmpeg -y
	sudo apt-get install -f -y
	wget http://launchpadlibrarian.net/121572601/swftools_0.9.2+ds1-3_amd64.deb
	sudo dpkg -i swftools_0.9.2+ds1-3_amd64.deb
}
#Install Office
f_install_office(){
whtext	
	sudo apt-get install libreoffice ttf-mscorefonts-installer fonts-droid -y
}

#Install PostgreSQL
f_install_postgresql(){
read -e -p "Install PostgreSQL database? [y/n] " -i "n" installpg
if [ "$installpg" = "y" ]; then
whtext
	sudo apt-get install postgresql -y
	sudo -u postgres psql postgres
fi
info
read -e -p "Create Alfresco Database and user? [y/n] " -i "n" createdb
if [ "$createdb" = "y" ]; then
	sudo -u postgres createuser -D -A -P $ALFRESCOUSER
	sudo -u postgres createdb -O $ALFRESCOUSER $ALFRESCODB	
fi
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

read -e -p "Configure Tomcat Server  [y/n] " -i "n" in_tomcat_configure
if [ "$in_tomcat_configure" = "y" ]; then
	f_configure_tomcat
info
	echo "Finish configure Tomcat Server"
else
	echo "Skipping configure Tomcat Server"
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

f_install_postgresql

read -e -p "Preinstall Afresco  [y/n] " -i "n" in_alfresco_download
if [ "$in_alfresco_download" = "y" ]; then
	f_preinstall_alfresco
info
	echo "Finish preinstall alfresco"
else
	echo "Skipping preinstall alfresco"
fi

#read -e -p "Add Google docs integration [y/n] " -i "n" installgoogledocs
#if [ "$installgoogledocs" = "y" ]; then

#fi

#read -e -p "Add Sharepoint plugin${ques} [y/n] " -i "n" installspp
#if [ "$installspp" = "y" ]; then

#fi

read -e -p "Configure Alfresco  [y/n] " -i "n" in_configure_alfresco
if [ "$in_configure_alfresco" = "y" ]; then
	f_configure_alfresco
info
	echo "Finish configure alfresco"	
else
	
fi	echo "Skipping configure alfresco"
whtext 
