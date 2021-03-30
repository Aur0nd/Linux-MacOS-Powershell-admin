sudo apt-get update 
sudo apt-get install nginx wget -y
enable --now nginx 

# Optional
# sudo apt-get install mysql-server 
# or.. sudo apt-get install mysql-client 

apt-get install -y git php php-curl php-mysql php-gd php-ldap php-zip php-mbstring php-xml php-bcmath php-tokenizer php-cli php-common

systemctl restart nginx 

apt install php-fpm -y

# Download wordpress & unzip & unzip downloadedfile

wget repo@

mv file/* /var/www/html/
rm -r index.html index.nginx-debian.html
cd /etc/nginx/sites-enabled/

rm -r default 
rpm -qa |grep php7.*-fpm or ls /etc/php/7.*/fpm/




nginx_config () {
  {
    echo "server {"
    echo "    listen 80 default_server;"
    echo "    listen [::]:80 default_server;"
    echo "    client_max_body_size 20M;"
    echo "     root /var/www/html/public;"
    echo "     index index.php;"
    echo "     #server_name application.com;"
    echo "     location / {"
    echo "            try_files $uri $uri/ /index.php?$args;"
    echo "     }"
    echo "     location ~ \.php$ {"
    echo "           include snippets/fastcgi-php.conf;"
    echo "            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;"
    echo "     location ~ /\.ht {  # It will ignore all ht files which works for apache"
    echo "         deny all;"
    echo "     }"
    echo " }"
    echo "}"
  } > /etc/nginx/sites-enabled/application.conf
} 
 nginx_config 

                 OR THE BELOW 

sudo tee -a application.conf > /dev/null << EOT
server {
     listen 80 default_server;
     listen [::]:80 default_server;
     client_max_body_size 20M;

     root /var/www/html/public;
     index index.php;

     #server_name application.com;

     location / {
            try_files $uri $uri/ /index.php?$args;
     }

     location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;  
     
     location ~ /\.ht {  # It will ignore all ht files which works for apache
         deny all;
     }
 }
}
 
EOT



rm -r /etc/nginx/sites-available/default 

# create user for the database wordpress_dbuser 

chown -R www-data:www-data /var/www/html

sed -i 's/upload_max_filesize = 2M/upload_max_filesize =20M/' /etc/php/7.4/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 20M/' /etc/php/7.4/fpm/php.ini 

systemctl restart nginx php7.4-fpm 



