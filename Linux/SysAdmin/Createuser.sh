#!/bin/bash

#Confirm if you're root
if [[ "$UID" -ne 0 ]]
then
	echo "You're not root, execute with Root!"
exit 
fi
# Make sure you got arguments
lib=default

   # Create Username
  # Repeat loop till you get y or a n
until [[ $lib == "yes" ]] || [[ $lib == "no" ]]; do

echo -n " Q. Do you want to automatically create username? (y/n) "
read -r setusrn
case $setusrn in 
	[yY] | [yY][Ee][Ss] )
	  USER_NAME="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16; echo)"
	  echo ""
	  ans="yes"
	  ;;
  	[nN] | [n|N][O|o] )
	  echo -n " Q. What should be the username?"
	  read -rs USER_NAME
	  echo ""
	  ;;
	*) echo " Invalid answer. Please type y or n"
	  ;;
esac
done 


read -n " Q. What is your name?: "
read -r name

if [[ "$#" -eq 0 ]]
then
	echo "You need to add at least one argument"
	exit
fi
#Capture the first Argument and make it Variable 
USER_NAME="$1"

#Make the rest of the arguments "COMMENTS"
shift
COMMENT="$@"


#Generate a Password

PASSWORD="$(date +%s%N | sha256sum | head -c48 )"

# Create the user with the password

useradd -c "${COMMENT}" -m ${USER_NAME}
if [[ "$?" -eq 1 ]]
then
	exit 1
fi

#Set the password
echo "${PASSWORD}" | passwd --stdin ${USER_NAME} 

if [[ "$?" -eq 1 ]]
then
	echo "Password failed"
	exit 1
fi

#Force Password change on first login.
passwd -e ${USER_NAME}

#Display the Username / Password / Home Dir

echo "USERNAME: $USER_NAME"
echo "PASSWORD: $PASSWORD"
echo "HOSTNAME: $HOSTNAME"

