#!/bin/bash
DB_HOST="${DB_HOST}"
WHILE='0'
NOW=`date`
cat /etc/os-release | grep "ubuntu" 
if [ $? -eq 0 ]; then 
 OS='apt-get -y'
else
 OS='yum -y'
fi 
which socat
if [ $? -ne 0 ]; then
 echo 'Install socat first & run the script again if the script fails'
  $OS install socat
elif [ $UID -ne 0 ] ; then
  echo 'Run the script as root'
exit
fi
cleanup ()
{
kill -s SIGTERM $!
exit 0
}
 while [ $WHILE -ne 1 ];
  do
    trap cleanup SIGINT SIGTERM
    ps aux | grep TCP-LISTEN:3306 | grep -v "grep --color=auto"
if [ $? -gt 128 ]; then 
   break
elif [ $? -ne 0 ];
  then
    socat TCP-LISTEN:3306,reuseaddr,fork TCP4:$DB_HOST:3306 &>/dev/null
    echo 'lost session $NOW, reconnecting' &> ~/socat.logs
    trap cleanup SIGINT SIGTERM
  fi
  sleep 5
done
