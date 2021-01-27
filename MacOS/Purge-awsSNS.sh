#/bin/zsh

#THE SCRIPT WAS CREATED TO SERVE AS AN EASY WAY TO DELETE APPLICATIONS ON YOUR MAC IN BULK (BUSINESS) 
#THE SCRIPT WILL DELETE ALL MATCHING STRINGS AND WILL UPLOAD THE OUTPUT TO SNS
#NOTE: IT IS NOT RECOMMENDED TO HARADCODE YOUR CREDENTIALS, USE SECRETS & VAULT


if [[ "$UID" -eq 0 ]] 
then
	echo "\n\nYou're ROOT, Be extra careful what you're deleting"
        echo "\n\n**********************************************************************************\nWARNING: You could easily wipe your disk with this script, be extra careful what you're typing*****"
 else
	echo "\n***********************************************************************************\nYou're Not ROOT, you won't be able to delete programs/files that you don't have permissions\n***********************************************************************************"

fi


echo "Type what you want to delete and click enter"
read V1

   #CHECK IF THE VAR IS NULL, EXIT IF NULL
if test -z "$V1"
	then
		echo "I said, type something, man.."
exit

else

sleep 3

> /tmp/removals <<< $(find / -iname "*$V1*" -print -exec rm -r {} +) 2>/dev/null 
sed -i '' '/System/d' /tmp/removals
OUTPUT=$(< /tmp/removals) 

curl -H "Content-Type: text/plain" -H "token: 46fbc618-0dd5-43f0-b0ed-ed4ac3275474" --request PUT --data "${OUTPUT}" https://api.memstash.io/values/$V1

#topicARN=arn:aws:sns:us-east-2:975237011919:script:{YOURTOPIC}

#AWS_ACCESS_KEY=    TYPE YOUR KEY
#AWS_SECRET_KEY=    TYPE YOUR KEY 
#aws sns publish --topic-arn $topicARN --message-structure json --message "${OUTPUT}"
fi


