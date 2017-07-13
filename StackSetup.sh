#!/bin/bash
# Clear the terminal
clear

echo "                     -----=====WARNING=====-----"
echo "The most common reason for any part of this script failing is formatting."
echo "           Putty, WSL and other such emulators wrap lines."
echo " Paste this script into a fullscreen terminal or it *will* break things."
echo "					   Press any key to continue..."
read -n 1

#MIT License
#
#Copyright (c) 2017 TSpann
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

######################### Variables / Globals #########################
# Get OS information.
OS=$(lsb_release -si)
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
VER=$(lsb_release -sr)
OSST=$OS" "$VER
LOCALIP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
# bash generate random 32 character alphanumeric string (upper and lowercase) and 
RANDSTRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Get script information
SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")

######################### Menus start here #########################
# Main Menu: Displays first list of options and some information.
mainmenu () {
  infobloc
 
  echo "Press 1 for Timezone, Locale, and Certificate Options"
  echo "Press 2 for Update Options"
  echo "Press 3 for server stack options"
  echo ""
  echo "Press q to exit"
  read -n 1 -p "Input Selection:" mainmenuinput
  clear
  if [ "$mainmenuinput" = "1" ]; then
      settzdata
  elif [ "$mainmenuinput" = "2" ]; then
      updatesystem
  elif [ "$mainmenuinput" = "3" ]; then
      setwebstack
  elif [[ "$mainmenuinput" = (q|Q) ]];then
      quitscript
  else
      invalidselection
      mainmenu
  fi
}

# Main Menu Option 1 - Timezone, Locale, Certificate
settzdata () {
  infobloc
  echo "Press 1 to set Timezone"
  echo "Press 2 to set Locale"
  echo "Press 3 to install a self signed certificate"
  echo "Press 4 to complete all actions"
  echo "Press b to go back"
  read -n 1 -p "Input Selection:" tzinput
  clear
  if [ "$tzinput" = "1" ]; then
      dpkg-reconfigure tzdata
      settzdata
  elif [ "$tzinput" = "2" ]; then
      dpkg-reconfigure locales
	  settzdata
  elif [ "$tzinput" = "3" ]; then
	  selfsigned
  elif [ "$tzinput" = "4" ]; then
      dpkg-reconfigure tzdata
	  dpkg-reconfigure locales
	  selfsigned
  elif [[ $tzinput = (b|B) ]];then
      mainmenu
  else
      invalidselection
      settzdata
  fi
}

# Main Menu Option 2 - Updates
updatesystem () {
  infobloc
  echo "NOTE: This currently ONLY supports Debian based servers."
  echo "I will be adding other distros as time permits."
  echo ""
  echo "Each option here is cumulative."
  echo "Option 3 runs Option 1 and two as well."
  echo ""
  echo "Press 1 to update the repositories"
  echo "Press 2 to upgrade the server"
  echo "Press 3 to dist upgrade the server"
  echo "Press b to go back"
  read -n 1 -p "Input Selection:" updateinput
  clear
  if [ "$updateinput" = "1" ]; then
      apt update
      
      updatesystem
  elif [ "$updateinput" = "2" ]; then
      apt update
      apt upgrade -y
      #bc is an arbitrary precision numeric processing language. Helps with evaluating version numbers.
	  apt install bc
      updatesystem
  elif [ "$updateinput" = "3" ]; then
      apt update
      apt upgrade -y
      apt dist-upgrade -y
      #bc is an arbitrary precision numeric processing language. Helps with evaluating version numbers.
	  apt install bc
      updatesystem
  elif [[ $updateinput = (b|B) ]];then
      mainmenu
  else
      invalidselection
      updatesystem
  fi
}

# Main Menu Option 3 - Webstack
setwebstack () {
  echo "Press 1 to install LAMP - apache2, mysql, php7 - stack"
  echo "Press 2 to install LEMP - apache2, mysql, php7 - stack"
  read -n 1 -p "Input Selection:" stackinput
  if [ "$stackinput" = "1" ]; then
    apache2_install
	mysql_install
	php70_install
  elif [ "$stackinput" = "2" ]; then
    nginx_install
	mysql_install
	php70_install
  fi
}

######################## SubMenus start here ########################
# Apache2 a2enmods - Webstack Component
a2enmod_menu () {
  echo "This submenu enables some common Apache2 modules."
  echo "Press 1 to enable mod rewrite"
  echo "Press 2 to enable mod headers"
  echo "Press 3 to enable mod ssl"
  echo ""
  echo "Press 4 to enable all mods"
  echo "Press b to go back"
  read -n 1 -p "Input Selection:" a2enput
  if [ "$a2enput" = "1" ]; then
    a2enmod rewrite
	/etc/init.d/apache2 restart
	clear
	a2enmod_menu
  elif [ "$a2enput" = "2" ]; then
    a2enmod headers
	/etc/init.d/apache2 restart
	clear
	a2enmod_menu
  elif [ "$a2enput" = "3" ]; then
    a2enmod ssl
	/etc/init.d/apache2 restart
	clear
	a2enmod_menu
  elif [ "$a2enput" = "4" ]; then
    a2enmod rewrite ssl headers
	/etc/init.d/apache2 restart
	clear
	setwebstack
  elif [[ "$a2enput" = (b|B) ]];then
      setwebstack
  else
      invalidselection
      a2enmod_menu
  fi 
}

php7addons_menu () {
  echo "This submenu enables some common PHP addons."
  echo "Press 1 install php7.0-dev"
  echo "Press 2 install php7.0-cli"
  echo "Press 3 install php7.0-json"
  echo "Press 4 install php7.0-gd"
  echo "Press 5 install php7.0-curl"
  echo "Press 6 install php7.0-xml"
  echo "Press 7 install php7.0-mbstring"
  echo ""
  echo "Press 8 install all addons"
  echo "Press b to go back"
  read -n 1 -p "Input Selection:" phpaddinput
  if [ "$phpaddinput" = "1" ]; then
    apt install php7.0-dev
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "2" ]; then
    apt install php7.0-cli
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "3" ]; then
    apt install php7.0-json
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "4" ]; then
    apt install php7.0-gd
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "5" ]; then
    apt install php7.0-curl
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "6" ]; then
    apt install php7.0-xml
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "7" ]; then
    apt install php7.0-mbstring
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "8" ]; then
    apt install php7.0-dev php7.0-cli php7.0-json php7.0-gd php7.0-curl php7.0-xml php7.0-mbstring
	/etc/init.d/php7.0-fpm restart
	clear
  elif [[ "$phpaddinput" = (b|B) ]];then
    setwebstack
  else
    invalidselection
    php7addons_menu
  fi
}

php7config () {
  read -n 1 -p "Enable php info? [y]" php_info
    if [ "$php_info" = (y|Y) ]; then
    sh -c "echo '<?php phpinfo(); ?>' >> /var/www/html/"$RANDSTRING".php"
    chown -R www-data:www-data /var/www/html/
    if [ pidof apache2 > /dev/null ]; then
      /etc/init.d/apache2 restart
    fi
    if [ pidof nginx > /dev/null ]; then
      /etc/init.d/nginx restart
    fi
  fi

  echo "The following answers will be interpreted as MB."
  echo "    Enter numeric digits then press [ENTER]:"
  read -p "PHP Max Upload Filesize:" upload_max_filesize
  read -p "PHP Max post size:" post_max_size 
  read -p "PHP Memory limit:" memory_limit

  if [ pidof apache2 > /dev/null ]; then
    sed  -i "s/\(upload_max_filesize *\).*/\1"$upload_max_filesize"/" /etc/php/7.0/apache2/php.ini
    sed  -i "s/\(post_max_size *\).*/\1"$post_max_size"/" /etc/php/7.0/apache2/php.ini
    sed  -i "s/\(memory_limit *\).*/\1"$memory_limit"/" /etc/php/7.0/apache2/php.ini
  fi
  if [ pidof nginx > /dev/null ]; then
    sed  -i "s/\(upload_max_filesize *\).*/\1"$upload_max_filesize"/" /etc/php/7.0/fpm/php.ini
    sed  -i "s/\(post_max_size *\).*/\1"$post_max_size"/" /etc/php/7.0/fpm/php.ini
    sed  -i "s/\(memory_limit *\).*/\1"$memory_limit"/" /etc/php/7.0/fpm/php.ini
  fi
  echo "The following version of php has been installed:"
  php --version
  echo "Please check http://"$LOCALIP"/"$RANDSTRING".php"
  echo "Press any key to DELETE "$RANDSTRING".php and continue..."
  read -n 1

  rm -rf /var/www/html/$RANDSTRING.php
  setwebstack
}

############################# Not Menus ############################
# Server Info: Clears screen & displays information about server.
infobloc () {
  clear
  
  echo "NOTE: If IP isn't visible, you did not pay attention to the warning at the beginning."
  echo "OS:										"$OSST
  echo "Architecture:							"$ARCH
  echo "IP Address:								"$LOCALIP
  echo ""
  echo "Script Location:						"$SCRIPT
}

# Functionality for adding self signed cert.
selfsigned () {
      echo "Installing CA Certificate to /usr/share/ca-certificates/StackSetup/CA.crt"
	  echo "Press any key to continue..."
      read -n 1
 
	  mkdir /usr/share/ca-certificates/StackSetup
	  touch /usr/share/ca-certificates/StackSetup/CA.crt
	  
      sh -c "echo 'Erase this, then copy the contents of your CA File here.' > /usr/share/ca-certificates/StackSetup/CA.crt"
	  
	  nano /usr/share/ca-certificates/StackSetup/CA.crt
	  echo "Please select yes, then place a star next to StackSetup/CA.crt to enable your certificate."
	  echo "Press any key to continue..."
      read -n 1
	  
	  dpkg-reconfigure ca-certificates
	  settzdata
}

# Install Apache2 - Webstack Component
apache2_install () {
  apt install apache2 apache2-utils
  sed  -i "s/\(ServerSignature *\).*/\1Off/" /etc/apache2/conf-enabled/security.conf
  sed  -i "s/\(ServerTokens *\).*/\1Prod/" /etc/apache2/conf-enabled/security.conf

  echo "The following version of apache2 has been installed:"
  apache2 -v
  echo "Apache2 status is:"
  service apache2 status
  echo "If the above looks right, please visit http://"$LOCALIP" in a web browser and verify that apache2 is working."
  echo "Press y to verify and continue, or any other key to quit."
  read -n 1 -p "Input Selection:" verifyapache2
  if [ "$verifyapache2" = (y|Y) ]; then
	read -n 1 -p "Enable some Apache2 Mods? [y]" enablea2enmods
	if [ "$enablea2enmods" = (y|Y) ]; then
	  a2enmod_menu
	else
	  setwebstack
	fi
  else
    echo "Either your input was not y, or apache2 is not running."
    echo "Press any key to continue..."
    read -n 1
    clear
    setwebstack
  fi
}


nginx_install () {
  apt install nginx
  sed -i '/server_tokens/c\server_tokens off;' /etc/nginx/nginx.conf
  sed -i '/server_name_in_redirect/c\server_name_in_redirect off;' /etc/nginx/nginx.conf
  chown www-data:www-data /usr/share/nginx/html -R
  systemctl enable nginx
  echo "The following version of nginx has been installed:"
  nginx -v
  echo "nginx status is:"
  systemctl status nginx
  echo "Please visit http://"$LOCALIP" in a web browser and verify that nginx is working."
  echo "Press y to verify and continue, or any other key to quit. [y|N]"
}
# Install mysql - Webstack Component
mysql_install () {
  apt install mysql-server
  mysql_secure_installation
}

# Install PHP7.0 - Webstack Component
php70_install () {
  apt install php7.0 php7.0-mcrypt php7.0-common 
  if [ pidof apache2 > /dev/null ]; then
	apt install libapache2-mod-php7.0
	a2enmod php7.0
	/etc/init.d/apache2 restart
  fi
  if [ pidof nginx > /dev/null ]; then
    apt install php7.0-fpm 
    php_build_nginx_config
	sed -i '/cgi.fix_pathinfo/c\cgi.fix_pathinfo=0' /etc/php/7.0/fpm/php.ini
	/etc/init.d/nginx restart
  fi
  if [ pidof mysql-server > /dev/null ]; then
    apt install php7.0-mysql 
  fi
  read -n 1 -p "Install PHP7.0 Addons? [y]" enablephp7addons
  if [ "$enablephp7addons" = (y|Y) ]; then
	php7addons_menu
  fi
  read -n 1 -p "Configure PHP settings? [y]" phpconfigsettings
  if [ "$phpconfigsettings" = (y|Y) ]; then
	php7config
  fi
}

# Build nginx php config - Webstack Component
php_build_nginx_config () {
  echo "server {" > /etc/nginx/sites-available/default
  echo "    listen 80 default_server;" >> /etc/nginx/sites-available/default
  echo "    listen [::]:80 default_server;" >> /etc/nginx/sites-available/default
  echo "" >> /etc/nginx/sites-available/default
  echo "    root /var/www/html;" >> /etc/nginx/sites-available/default
  echo "    index index.php index.html index.htm;" >> /etc/nginx/sites-available/default
  echo "" >> /etc/nginx/sites-available/default
  echo "    server_name $LOCALIP;" >> /etc/nginx/sites-available/default
  echo "" >> /etc/nginx/sites-available/default
  echo "    location / {" >> /etc/nginx/sites-available/default
  echo "        try_files $uri $uri/ =404;" >> /etc/nginx/sites-available/default
  echo "    }" >> /etc/nginx/sites-available/default
  echo "" >> /etc/nginx/sites-available/default
  echo "    location ~ \.php$ {" >> /etc/nginx/sites-available/default
  echo "        include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-available/default
  echo "        fastcgi_pass unix:/run/php/php7.0-fpm.sock;" >> /etc/nginx/sites-available/default
  echo "    }" >> /etc/nginx/sites-available/default
  echo "" >> /etc/nginx/sites-available/default
  echo "    location ~ /\.ht {" >> /etc/nginx/sites-available/default
  echo "        deny all;" >> /etc/nginx/sites-available/default
  echo "    }" >> /etc/nginx/sites-available/default
  echo "}" > /etc/nginx/sites-available/default
}

# Do Not Change
# Invalid Selection in Menus
invalidselection () {
    clear
    echo "You have entered an invalid selection!"
    echo "Please try again!"
    echo ""
    echo "Press any key to continue..."
    read -n 1
}
# Q q - Press Q to Quit
quitscript () {
	clear
	exit 0
}
######################### Enable And Exit Bits #########################
# Do Not Change
# Script Runs from here:
mainmenu
# On the off chance that it ever actually makes it here (it shouldn't):
exit 0