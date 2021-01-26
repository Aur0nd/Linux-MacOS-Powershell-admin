#! /bin/bash

sn=$(sudo dmidecode -s system-serial-number)

echo $sn

proc=$(sudo dmidecode -s processor-version)

echo $proc

ram=$(free -h | awk '/Mem\:/ { print $2 }')

echo $ram

model=$(sudo dmidecode -s system-product-name)

echo $model

yom="201${sn:3:1}"
	
echo $yom

wom="${sn:4:2}"

echo $wom

echo "Please enter your email address (press enter when finished)"
read eadd
echo "Email is $eadd"



echo "$eadd,"LINUX",$model,$sn,$proc,$ram,$yom,$wom," >> ./compinfo.csv

file_upload="data.txt"

echo -e "From: $eadd
To: Addemail@whatever.com                                
Subject: Audit Machines
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"MULTIPART-MIXED-BOUNDARY\"

--MULTIPART-MIXED-BOUNDARY
Content-Type: multipart/alternative; boundary=\"MULTIPART-ALTERNATIVE-BOUNDARY\"

--MULTIPART-ALTERNATIVE-BOUNDARY
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Content-Disposition: inline

" > "$file_upload"

echo "Please find date of manufacture information attached " | base64 >> "$file_upload"


echo "
--MULTIPART-ALTERNATIVE-BOUNDARY--

--MULTIPART-MIXED-BOUNDARY
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"compInfo.csv\"
" >> "$file_upload"

cat compinfo.csv | base64 >> "$file_upload"

echo "--MULTIPART-MIXED-BOUNDARY--" >> "$file_upload"

curl --url 'smtp://smtp.office365.com:587' --ssl-reqd --mail-from "$eadd" --mail-rcpt 'AddSameEmail@here.com' --user "$eadd" -T "$file_upload"

rm compinfo.csv
rm data.txt
