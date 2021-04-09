#MIT License
#Copyright (c) 2021 George Ziongkas
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the 
#Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
#permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
#PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



#  Destination     Gateway(via)
# 192.168.1.1     192.168.1.1

# =========================== No interactive mode ===========================


     #INSTRUCTIONS
	# 1) Add a static route via BASH,  ip route add 192.168/24 via 172.28.80.1
	# NOTE: Make sure there is no other static route, and if there is, make sure its only intended for a single host 
	# 2) chmod +x aristafailover-ni.sh 
	# 3) ./aristafailover-ni.sh 

#!/bin/bash

  CODEEXIT=0
  ALIVE=0
  ALIVE2=0
  HOSTUP=N
  Count=0
  NOW=`date`
  WHILE=0
  NETMASK=255.255.255.0
  ROTATESWAP=0
  ROTATE=0

  DESTIP=1.1.1.1  # Use Destination IP to TEST connection
  DESTDOMAIN=192.168.15 # USE DESTINATION IP BUT ONLY THE 3 FIRST OCTETS 
  DESTGW=192.168.46.1 # Use Next Hop 
  DESTGWALT=192.168.46.2 # Next Hop ALTERNATIVE

echo '
 ______________________________________
/                                      \
| Do nothing unless you must, and when  \
\ you must act -- hesitate.             /
 --------------------------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    / \_   _/ \
    \___)=(___/
'




  if [ ! -d "/mnt/flash/FailRouteTrack.log" ]; then 
   if [ ! -d "/mnt/flash/SuccessLogs.log" ]; then
	  echo "The file already exists" 
  else
	  mkdir -p /mnt/flash/
	  touch /mnt/flash/FailRouteTrack.log
	  touch /mnt/flash/SuccessLogs.log
	  echo "$NOW Initialization......" >> /mnt/flash/FailRouteTrack.log
	  echo "Logging file created"
  fi
fi

  while [ $WHILE -ne 1 ];
  do # Continues loop, no counter
   for i in $DESTIP
	 do
		  
		  ALIVE="$(ping -c 3 $DESTIP | grep '100% packet loss')"
                  ALIVE2=$? # IF PACKAGE IS DROPPED, IT WILL -eq 0



		  if [ $ALIVE2 -eq "0" ]; then # Ping returned 100% Package Loss
       if [ $ROTATESWAP -ne "1" ]; then 
			#Count=$((Count + 1))
					  echo "$NOW: Host $DESTIP is down via $DESTGW" >> /mnt/flash/FailRouteTrack.log
					  echo "TEST: PING FAILED AND ROUTING TABLE WILL BE UPDATED"
					  route del -net $DESTDOMAIN.0 gw $DESTGW netmask $NETMASK #|| true
					  CODEEXIT=$?
					  HOSTUP=N
					  ROTATESWAP=1
			  else
				  HOSTUP=Y
			  fi
			  fi

		  if [ $ALIVE2 -eq "0" ]; then # Ping returned 100% Package Loss
       if [ $ROTATESWAP -ne "2" ]; then 
			#Count=$((Count + 1))
					  echo "$NOW: Host $DESTIP is down via $DESTGWALT" >> /mnt/flash/FailRouteTrack.log
					  echo "TEST: PING FAILED AND ROUTING TABLE WILL BE UPDATED"
					  route del -net $DESTDOMAIN.0 gw $DESTGWALT netmask $NETMASK #|| true
					  CODEEXIT=$?
					  HOSTUP=N
					  ROTATESWAP=2
			  else
				  HOSTUP=Y
			  fi
		  fi		  



		  if [ $ALIVE2 = "0" ]; then
			  if [ "$HOSTUP" = "N" ]; then
         if [ $ROTATE -ne "1" ]; then 
				  Count=0
				  ip route add $DESTDOMAIN/24 via $DESTGWALT
				  HOSTUP=Y
				  echo "$NOW: PATH ADDED"
				  echo "Host is up at" $NOW via $DESTGW >> /mnt/flash/SuccessLogs.log
				  CODEEXIT=0
          ROTATE=1
			  fi
		  fi
		fi
		  if [ $ALIVE2 = "0" ]; then
			  if [ "$HOSTUP" = "N" ]; then
         if [ $ROTATE -ne "2" ]; then 
				  Count=0
				  ip route add $DESTDOMAIN/24 via $DESTGWALT
				  HOSTUP=Y
				  echo "$NOW: PATH ADDED"
				  echo "Host is up at" $NOW via $DESTGWALT >> /mnt/flash/SuccessLogs.log
				  CODEEXIT=0
          ROTATE=2
			  fi
		  fi
	    fi

			   if [ $CODEEXIT -eq "1" ]; then
	 		echo "Script was killed, it failed to remove route from table"
	  		exit 
			  fi
	  done

		  #echo "YOUR CONNECTION IS UP AND RUNNING, GOOD MAN"
	  sleep 5
done
