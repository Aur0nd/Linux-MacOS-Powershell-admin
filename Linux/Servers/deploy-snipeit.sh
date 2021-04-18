#Copyright (c) 2021 George Ziongkas

#!/bin/bash



echo '
       ///\\    uu       uu     RRRR\\\
      //   \\   uu       uu     RR   \\  
     ///////\\   uu     uuuu    RRRR\\     
    //       \\    uuuuu  uu    RR   \\      
'

distro="$(lsb_release -is)"
version="$(lsb_release -rs)"


readonly AVA_NAME="snipeit"
readonly AVA_PATH="/var/www/$AVA_NAME"
SITEPATH=/etc/apache2/sites-available/$AVA_NAME.conf

spinner()
{
    local pid=$!
    local delay=0.25
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

KALI=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

value=$(grep -ic $distro /etc/os-release)
if [ $value -gt 0 ]
 then  
   echo "You're Ubuntu, I'll execute"
  else 
  exit 
fiyes
fi 

apt-get update & pid=$!
spinner
apt-get install apache2 -y 

apt-get install tasksel -y & pid=$!
spinner 



cd /var/www
git clone https://github.com/snipe/snipe-it snipeit
cd snipeit/
cp .env.example .env
pipcurl=$(curl ifconfig.io)
echo -n " Whats the Domain Name or IP of your server? ($(hostname -fs) $pipcurl): "
read -r IPE 
if [ -z "$IPE" ]; then 
  readonly IPE="$(pipcurl)"
  fi 
IPE="http://$IPE"

echo " You're  $IPE"
sed -i "s|^\\(APP_URL=\\).*|\\1$IPE|g" .env
echo -n " Whats the db name should be? "
read -r db_name 
sed -i "s|^\\(DB_DATABASE=\\).*|\\1$db_name|" .env 
echo -n " Whats the db users name should be? "
read -r db_username 
sed -i "s|^\\(DB_USERNAME=\\).*|\\1$db_username|" .env 

echo -n  'If the database is hosted locally, type "localhost" '
read -r db_host
sed -i "s|^\\(DB_HOST)=\\).*|\\1$db_host|" .env 



pw=default 
until [[ $pw == "yes" ]] || [[ $pw == "no" ]]; do
echo -n " Should I generate aa password for you? (y/n)"
read -r setpw 

case $setpw in 
  [yY] | [yY][Ee][Ss] )
    db_password="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16; echo)"
    echo ""
    pw="yes"
    ;;
  [nN] | [n|N][O|o] )
    echo -n  "What do you want your snipeit user password to be?"
    read -rs db_password 
    echo ""
    pw="no"
    ;;
  *)  echo " Please type y or n"
    ;;
esac
done

#debconf-set-selections <<< "mysql-server "$db_name"/root_password password $db_password"
#debconf-set-selections <<< "mysql-server "$db_name"/root_password_again password $db_password"

tasksel install lamp-server & pid=$!
spinner 

sed -i "s|^\\(DB_PASSWORD=\\).*|\\1$db_password|" .env 
mysql -u root -p$db_password --execute="CREATE USER '$db_username'@'$db_host' IDENTIFIED BY '$db_password'; CREATE DATABASE $db_name;GRANT ALL ON *.* TO $db_username@$db_host;"
#IDENTIFIED BY '$db_password';"
curl -sS https://getcomposer.org/installer | tac | tac | php
mv composer.phar /usr/local/bin/composer 

add-apt-repository universe -y
apt-get install -y git unzip php php-curl php-mysql php-gd php-ldap php-zip php-mbstring php-xml php-bcmath php-tokenizer & pid=$!
spinner 
composer install --no-dev --prefer-source -n & pid=$!
spinner 

chown -R www-data:www-data storage public/uploads
chmod -R 777 /var/www/




php artisan key:generate --force
#php artisan migrate 

create_function () {
  {
    echo "<VirtualHost *:80>"
    echo "  <Directory $AVA_PATH/public>"
    echo "      Allow From All"
    echo "      AllowOverride All"
    echo "      Options -Indexes"
    echo "  </Directory>"
    echo "  DocumentRoot $AVA_PATH/public"
    echo "  ServerName $IPE"
    echo "</VirtualHost>"
  } > "$SITEPATH" 
} 
 
set_hosts () {
  
  echo "* Setting up hosts file."
  echo >> /etc/hosts "127.0.0.1 $(hostname) $IPE"
  
}
set_firewall () {
  
  if [ "$(firewall-cmd --state)" == "running" ] ; then
    echo "* Configuring firewall to allow HTTP traffic only."
    log "firewall-cmd --zone=public --add-port=http/tcp --permanent"
    log "firewall-cmd --reload"
  fi
}

disable_ssl () {
  {
  echo -e "[client]\nssl-mode=DISABLED"
  } > "~/.my.cnf"
}

create_user () {
  {
  echo "* Creating Snipeit User."

  if [ "$value" -gt 0 ] ; then 
  adduser --quiet --disabled-password --gecos '""' "$db_username"
  usermod -a -G www-data "$db_username"
  fi 
}
}


disable_ssl 
create_function 
set_hosts
create_user
set_firewall 


cd /etc/apache2/sites-available/
a2ensite $AVA_NAME
a2enmod rewrite 
systemctl restart apache2 
a2dissite 000-default.conf
service apache2 reload
cp 000-default.conf 000-default.confTEMP
rm 000-default.conf
phpenmod mbstring 
a2enmod rewrite 
service apache2 restart 


