#!/bin/bash

#Confirm if you're root
if [[ "$UID" -ne 0 ]]
then
	echo "You're not root, execute with Root!"
fi
# Make sure you got arguments
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

