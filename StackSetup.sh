#!/bin/bash

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

# Clear the terminal
clear

echo "                     -----=====WARNING=====-----"
echo "The most common reason for any part of this script failing is formatting."
echo "           Putty, WSL and other such emulators wrap lines."
echo " Paste this script into a fullscreen terminal or it *will* break things."
echo "					   Press any key to continue..."
read -n 1
######################### Variables / Globals #########################
# Get OS information.
OS=$(lsb_release -si)
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
VER=$(lsb_release -sr)
OSST=$OS" "$VER
LOCALIP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
# This Broke it, Fix Later.
#RANDSTRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

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
  elif [[ $mainmenuinput = "q" || $mainmenuinput = "Q" ]];then
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
  elif [[ $tzinput = "b" || $tzinput = "B" ]];then
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
  echo "Option 3 runs Option 1 and 2 as well."
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
	  apt install bc -y
      updatesystem
  elif [ "$updateinput" = "3" ]; then
      apt update
      apt upgrade -y
      apt dist-upgrade -y
      #bc is an arbitrary precision numeric processing language. Helps with evaluating version numbers.
	  apt install bc -y
      updatesystem
  elif [[ $updateinput = "b" || $updateinput = "B" ]];then
      mainmenu
  else
      invalidselection
      updatesystem
  fi
}

# Main Menu Option 3 - Webstack
setwebstack () {
  infobloc
  echo "Press 1 to install LAMP - apache2, mysql, php7 - stack"
  echo "Press 2 to install LEMP - apache2, mysql, php7 - stack"
  echo "Press 3 to install django - Python3 - stack"
  echo "Press b to go back"
  read -n 1 -p "Input Selection:" stackinput
  if [ "$stackinput" = "1" ]; then
    apache2_install
	mysql_install
	php70_install
  elif [ "$stackinput" = "2" ]; then
    nginx_install
	mysql_install
	php70_install
  elif [ "$stackinput" = "3" ]; then
    django_install
  elif [[ $stackinput = "b" || $stackinput = "B" ]];then
    setwebstack
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
  elif [[ $a2enput = "b" || $a2enput = "B" ]];then
      setwebstack
  else
      invalidselection
      a2enmod_menu
  fi 
}

# PHP7.0 Addons - Webstack Component
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
    apt install php7.0-dev -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "2" ]; then
    apt install php7.0-cli -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "3" ]; then
    apt install php7.0-json -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "4" ]; then
    apt install php7.0-gd -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "5" ]; then
    apt install php7.0-curl -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "6" ]; then
    apt install php7.0-xml -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "7" ]; then
    apt install php7.0-mbstring -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [ "$phpaddinput" = "8" ]; then
    apt install php7.0-dev php7.0-cli php7.0-json php7.0-gd php7.0-curl php7.0-xml php7.0-mbstring -y
	/etc/init.d/php7.0-fpm restart
	clear
  elif [[ $phpaddinput = "b" || $phpaddinput = "B" ]];then
    setwebstack
  else
    invalidselection
    php7addons_menu
  fi
}

# PHP Configuration
php7config () {
  read -n 1 -p "Enable php info? [y]" php_info
    if [ "$php_info" = "(y|Y)" ]; then
    sh -c "echo '<?php phpinfo(); ?>' >> /var/www/html/test.php"
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
  echo "Please check http://"$LOCALIP"/test.php"
  echo "Press any key to DELETE test.php and continue..."
  read -n 1

  rm -rf /var/www/html/test.php
  setwebstack
}

# django mods  - Webstack Component
djangomod_menu () {
  echo "This submenu enables some common django addons."
  echo "Press 1 to install redis"
  echo "Press 2 to install django REST framework"
  echo "Press 3 to install django formtools"
  echo "Press 4 to install python3-arrow"
  echo "Press 5 to install django js reverse"
  echo "Press 6 to install pypandoc"
  echo "Press 7 to install requests_oauthlib"
  echo "Press 8 to install libtidy"
  echo ""
  echo "Press 9 to install all mods"
  echo "Press b to go back"
  read -n 1 -p "Input Selection:" djangoinput
  if [ "$djangoinput" = "1" ]; then
    redis_install
	clear
	djangomod_menu
  elif [ "$djangoinput" = "2" ]; then
    apt install python3-djangorestframework -y
	clear
	djangomod_menu
  elif [ "$djangoinput" = "3" ]; then
    apt install python3-django-formtools -y
	clear
	djangomod_menu
  elif [ "$djangoinput" = "4" ]; then
    apt install python3-arrow -y
	clear
	setwebstack
  elif [ "$djangoinput" = "5" ]; then
    pip3 install django-js-reverse
	clear
	setwebstack
elif [ "$djangoinput" = "6" ]; then
    pip3 install pypandoc
	clear
	setwebstack
elif [ "$djangoinput" = "7" ]; then
    pip3 install requests requests_oauthlib
	clear
	setwebstack
elif [ "$djangoinput" = "8" ]; then
    apt install libtidy-dev -y
	clear
	setwebstack
elif [ "$djangoinput" = "9" ]; then
    redis_install
	apt install python3-djangorestframework python3-django-formtools python3-arrow libtidy-dev -y
	pip3 install django-js-reverse pypandoc requests requests_oauthlib
	clear
	setwebstack
  elif [[ $djangoinput = "b" || $djangoinput = "B" ]];then
      setwebstack
  else
      invalidselection
      djangomod_menu
  fi 
}

############################# Not Menus ############################
# Server Info: Clears screen & displays information about server.
infobloc () {
  clear
  
  echo "NOTE: If IP isn't visible, you did not pay attention to the warning at the beginning."
  echo ""
  echo "OS:										"$OSST
  echo "Architecture:							"$ARCH
  echo "IP Address:								"$LOCALIP
  echo ""
  echo "Script Location:						"$SCRIPT
  echo ""
}

# Functionality for adding self signed cert.
selfsigned () {
  echo "Installing CA Certificate to /usr/share/ca-certificates/StackSetup/CA.crt"
  echo "Press any key to continue..."
  read -n 1 -p
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

redis_install () {
  apt install build-essential tcl curl -y
  curl -O http://download.redis.io/redis-stable.tar.gz
  tar xzvf redis-stable.tar.gz
  cd redis-stable
  make
  make test
  make install
  mkdir /etc/redis
  cp redis.conf /etc/redis
  sed  -i "s/\(supervised *\).*/\1systemd/" /etc/redis/redis.conf
  sed -i '/dir .\//c\dir /var/lib/redis;' /etc/redis/redis.conf
  echo "[Unit]" > /etc/systemd/system/redis.service
  echo "Description=Redis In-Memory Data Store" >> /etc/systemd/system/redis.service
  echo "After=network.target" >> /etc/systemd/system/redis.service
  echo "" >> /etc/systemd/system/redis.service
  echo "[Service]" >> /etc/systemd/system/redis.service
  echo "User=redis" >> /etc/systemd/system/redis.service
  echo "Group=redis" >> /etc/systemd/system/redis.service
  echo "ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf" >> /etc/systemd/system/redis.service
  echo "ExecStop=/usr/local/bin/redis-cli shutdown" >> /etc/systemd/system/redis.service
  echo "Restart=always" >> /etc/systemd/system/redis.service
  echo "" >> /etc/systemd/system/redis.service
  echo "[Install]" >> /etc/systemd/system/redis.service
  echo "WantedBy=multi-user.target" >> /etc/systemd/system/redis.service
  adduser --system --group --no-create-home redis
  mkdir /var/lib/redis
  chown redis:redis /var/lib/redis
  chmod 770 /var/lib/redis
  systemctl start redis
  cd ..
  echo "redis status is:"
  systemctl status redis
  echo "Press [Y] to enable redis autostart at boot,"
  read -n 1 -p "or any other key to quit." enableredis
  if [[ $enableredis = "y" || $enableredis = "Y" ]];then
    systemctl enable redis
	pip3 install django-redis
	sed -i "/django.core.cache.backends.locmem.LocMemCache/c\        'BACKEND': 'django_redis.cache.RedisCache'," /usr/lib/python3/dist-packages/django/conf/global_settings.py
	#These are based on line numbers and will break at some point.
	sed -i "501i\        'LOCATION': 'redis://127.0.0.1:6379/1'," /usr/lib/python3/dist-packages/django/conf/global_settings.py
	sed -i "502i\        'OPTIONS': {" /usr/lib/python3/dist-packages/django/conf/global_settings.py
	sed -i "503i\            'CLIENT_CLASS': 'django_redis.client.DefaultClient'," /usr/lib/python3/dist-packages/django/conf/global_settings.py
	sed -i "504i\        }" /usr/lib/python3/dist-packages/django/conf/global_settings.py
	sed -i "/SESSION_ENGINE/c\SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" /usr/lib/python3/dist-packages/django/conf/global_settings.py
  else
	quitscript
  fi 
}

# Install Apache2 - Webstack Component
apache2_install () {
  apt install apache2 apache2-utils -y
  sed  -i "s/\(ServerSignature *\).*/\1Off/" /etc/apache2/conf-enabled/security.conf
  sed  -i "s/\(ServerTokens *\).*/\1Prod/" /etc/apache2/conf-enabled/security.conf

  echo "The following version of apache2 has been installed:"
  apache2 -v
  echo "Apache2 status is:"
  service apache2 status
  echo "If the above looks right, please visit http://"$LOCALIP" in a web browser and verify that apache2 is working."
  echo "Press y to verify and continue, or any other key to quit."
  read -n 1 -p "Input Selection:" verifyapache2
  if [ "$verifyapache2" = "(y|Y)" ]; then
	read -n 1 -p "Enable some Apache2 Mods? [y]" enablea2enmods
	if [[ $enablea2enmods = "y" || $enablea2enmods = "Y" ]];then
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

# Install nginx - Webstack Component
nginx_install () {
  apt install nginx -y
  sed -i '/server_tokens/c\server_tokens off;' /etc/nginx/nginx.conf
  sed -i '/server_name_in_redirect/c\server_name_in_redirect off;' /etc/nginx/nginx.conf
  chown www-data:www-data /usr/share/nginx/html -R
  systemctl enable nginx
  echo "The following version of nginx has been installed:"
  nginx -v
  echo "nginx status is:"
  systemctl status nginx
  echo "Please visit http://"$LOCALIP" in a web browser and verify that nginx is working."
  echo "Press y to verify and continue, or any other key to quit. [y|Any Other Key]"
  read -n 1 -p "Input Selection:" verifynginx
  if [[ $verifynginx = "y" || $verifynginx = "Y" ]];then
	mainmenu
  else
    echo "Either your input was not y, or apache2 is not running."
    echo "Press any key to continue..."
    read -n 1
    clear
    setwebstack
  fi
}

# Install python - django - Webstack Component
django_install () {
  apt install python3-pip javascript-common libjs-jquery python-django-common python3-django python3-sqlparse python3-tz -y
  echo "The following version of django has been installed:"
  python3 -c "import django; print(django.get_version())"
  echo "Press y to verify and continue, or any other key to quit. [y|Any Other Key]"
  read -n 1 -p "Input Selection:" verifydjango
  if [[ "$verifydjango" = "y" || "$verifydjango" = "Y" ]]; then
	echo ""
	read -n 1 -p "Enable some Python-django Mods? [y|Any Other Key]" enableadjangomods
	if [[ $enableadjangomods = "y" || $enableadjangomods = "Y" ]];then
	  djangomod_menu
	else
	  mainmenu
	fi
  fi
  mainmenu
}

# Install mysql - Webstack Component
mysql_install () {
  apt install mysql-server -y
  mysql_secure_installation
}

# Install PHP7.0 - Webstack Component
php70_install () {
  apt install php7.0 php7.0-mcrypt php7.0-common -y
  if [ pidof apache2 > /dev/null ]; then
	apt install libapache2-mod-php7.0 -y
	a2enmod php7.0
	/etc/init.d/apache2 restart
  fi
  if [ pidof nginx > /dev/null ]; then
    apt install php7.0-fpm -y
    php_build_nginx_config
	sed -i '/cgi.fix_pathinfo/c\cgi.fix_pathinfo=0' /etc/php/7.0/fpm/php.ini
	/etc/init.d/nginx restart
  fi
  if [ pidof mysql-server > /dev/null ]; then
    apt install php7.0-mysql  -y
  fi
  read -n 1 -p "Install PHP7.0 Addons? [y]" enablephp7addons
  if [ "$enablephp7addons" = "(y|Y)" ]; then
	php7addons_menu
  fi
  read -n 1 -p "Configure PHP settings? [y]" phpconfigsettings
  if [[ $phpconfigsettings = "y" || $phpconfigsettings = "Y" ]];then
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
