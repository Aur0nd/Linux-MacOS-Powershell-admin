#!/bin/bash


#Createuser.sh == The script creates a new user / Home Dir / Password (NO INTERACTIVE PROMPT)

USER_NAME="$1"
shift
COMMENT="$@"

if [[ "${UID}" -ne 0 ]]
then
	exit 1 &>/dev/null
fi
if [[ "$#" -eq 0 ]]
then 
	echo "Usage: script.sh [USER_NAME] COMMENT..., you provided $@ arguments" >&2
	
fi

PASS="$(date +%s%N | sha256sum | head -c15)"
echo "$PASS" > /var/password.txt
	useradd -c "${COMMENT}" -m "$USER_NAME" && echo "${PASS}" > passwd --stdin $USER_NAME &>/dev/null &>/dev/null

if [[ "$?" -eq 1 ]]
then
	echo "You FAILED" >&2 
fi
passwd -e "$USER_NAME"

echo "USER NAME: $USER_NAME"

echo "PASSWORD: $PASS"

echo "HOSTNAME: $HOSTNAME"
