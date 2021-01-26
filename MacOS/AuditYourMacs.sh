#! /bin/bash

sn=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

proc=$(sysctl -n machdep.cpu.brand_string)

ram=$(system_profiler SPHardwareDataType | grep " Memory:")

ram="${ram:14}"

model=$(system_profiler SPHardwareDataType | grep "Model Identifier")

model="${model:24}"

model=$(echo $model | tr "," "-")

yom=$(curl -s https://support-sp.apple.com/sp/product?cc=$(
  system_profiler SPHardwareDataType \
    | awk '/Serial/ {print $4}' \
    | cut -c 9-
) | sed 's|.*<configCode>\(.*\)</configCode>.*|\1|' | awk -F"[()]" '{print $2}'| tr -dc '0-9')

if [[ $yom != 2* ]]; then 
	yom="${yom:2}";
fi;
	

wom=$(curl -s https://support-sp.apple.com/sp/product?cc=$(
  system_profiler SPHardwareDataType \
    | awk '/Serial/ {print $4}' \
    | cut -c 9-
) | sed 's|.*<configCode>\(.*\)</configCode>.*|\1|' | awk -F"[()]" '{print $2}'| tr -dc 'A-za-z')

if [ "$wom" = "Early" ]; then
	wom=5; 
elif [ "$wom" = "Mid" ]; then 
	wom=25; 
elif [ "$wom" = "Late" ]; then
	wom=42;
elif [ "$wom" = "inch" ]; then
	wom=25;
fi;

echo "Please enter your email address (press enter when finished)"
read eadd
echo "Email is $eadd"



echo "$eadd,"OSX",$model,$sn,$proc,$ram,$yom,$wom," >> ./compinfo.csv

file_upload="data.txt"

echo -e "From: $eadd
To: Enter@Email.com
Subject:IT Audit Information
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

curl --url 'smtp://smtp.office365.com:587' --ssl-reqd --mail-from "$eadd" --mail-rcpt 'Enter@Email.com' --user "$eadd" -T "$file_upload"

rm compinfo.csv
rm data.txt
