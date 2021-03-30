#!/bin/bash


# NOTE:  Create a people.txt file and add 50 random names format ex: "George Ziongkas"


counter=0
db_password=12345678
db_username=root
db_host=db_host
db_name=people
db_host_in=172.0.0.1
output=0

mysqlshow -u $db_username -h $db_host -p$db_password | grep people 
output=$?

if [ $output -ne 0 ]
then 
mysql -u root -h db_host -p$db_password --execute="CREATE USER '$db_username'@'$db_host_in' IDENTIFIED BY '$db_password'; CREATE DATABASE $db_name;GRANT ALL ON *.* TO $db_username@$db_host; use people; create table register (id int(3), name varchar(50), lastname varchar(50), age varchar(3));"
fi

while [ $counter -lt 50 ]; do 

 let counter=counter+1
 name=$(nl people.txt | grep -w $counter | awk '{print $2}' | awk -F ',' '{print $1}')
 lastname=$(nl people.txt | grep -w $counter | awk '{print $2}' | awk -F ',' '{print $2}')
 age=$(shuf -i 20-25 -n 1)

mysql -u root -h db_host -p$db_password people -e "insert into register values ($counter, '$name', '$lastname', $age)"
echo "$counter, $name $lastname, $age was imported"
 done
