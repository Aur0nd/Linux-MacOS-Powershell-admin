Get-PSSession | Remove-PSSession






#WHAT THE SCRIPT DOES:  It will Audit your office environment and send the reports in an email

                    # |------------- HOW TO USE IT ---------|

# 1: You need a user account (It can be a Shared Mailbox with Exchange permissions)

# 2: Encrypt the Creds and "hardcode" them. (Vault is ideal)

                #-: Create Variable with our Credentials
#credential = Get-Credential

            # Pull the password from the creds and SecureString it in a file
#credential.Password | ConvertFrom-SecureString | Set-Content .\creds.txt


   #OPTIONAL:        This will be used in the script, we inject the output in a var
#encrypted = Get-Content .\creds.txt | ConvertTo-SecureString



#                EXTRAS:   I personally configured all my powershell scripts on AWS Windows(Obviously)
 #                              with Task Scheduler (Cron)                       




$User1 = "exchange.admin@Avalanche.com"
$Pass1 = Get-Content -Path "C:\Users\$env:UserName\Desktop\SCRIPTS-DONT-TOUCH\creds.txt" | ConvertTo-SecureString
$UserCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $User1, $Pass1
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential
Import-Module MSOnline





#|--------------------------------------------------------------------------------------------|
        #It Will Audit o365 licences and send the output to IT 
#|--------------------------------------------------------------------------------------------|



$members1 = Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "SPB"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\SPB.csv" -Encoding UTF8
$members2 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "PROJECTPROFESSIONAL"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\PROJECTPROFESSIONAL.csv" -Encoding UTF8
$members3 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "ENTERPRISEPACK"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\E3.csv" -Encoding UTF8
$members4 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "POWER_BI_PRO"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\PowerBi.csv" -Encoding UTF8
$members5 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "MCOSTANDARD"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\Business_online.csv" -Encoding UTF8
$members6 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "PROJECTCLIENT"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\Power_Automate_Free.csv" -Encoding UTF8
$members7 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "PROJECTESSENTIALS"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\PROJECTESSENTIALS.csv" -Encoding UTF8
$members8 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "PROJECTPROFESSIONAL"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\PROJECTPROFESSIONAL.csv" -Encoding UTF8
$members9 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "VISIOCLIENT"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\VISIO.csv" -Encoding UTF8
$members0 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "POWER_BI_STANDARD"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\POWER_BI_STANDARD.csv" -Encoding UTF8
$members11 += Get-MsolUser -EnabledFilter EnabledOnly -MaxResults 20000 | Where-Object {($_.licenses).AccountSkuId -match "O365_BUSINESS_PREMIUM"} |  Select-Object UserPrincipalName, DisplayName |  export-csv  "C:\Users\$env:UserName\Desktop\Audit\Business_Standard.csv" -Encoding UTF8



 $rn1="C:\Users\$env:UserName\Desktop\Audit\SPB.csv"
 $rn2="C:\Users\$env:UserName\Desktop\Audit\PROJECTPROFESSIONAL.csv"
 $rn3="C:\Users\$env:UserName\Desktop\Audit\E3.csv"
 $rn4="C:\Users\$env:UserName\Desktop\Audit\PowerBi.csv"
 $rn5="C:\Users\$env:UserName\Desktop\Audit\Business_online.csv"
 $rn6="C:\Users\$env:UserName\Desktop\Audit\Power_Automate_Free.csv"
 $rn7="C:\Users\$env:UserName\Desktop\Audit\PROJECTESSENTIALS.csv"
 $rn8="C:\Users\$env:UserName\Desktop\Audit\PROJECTPROFESSIONAL.csv"
 $rn9="C:\Users\$env:UserName\Desktop\Audit\VISIO.csv"
 $rn0="C:\Users\$env:UserName\Desktop\Audit\POWER_BI_STANDARD.csv"
 $rn11="C:\Users\$env:UserName\Desktop\Audit\Business_Standard.csv"
 [array]$rn_all=$rn1,$rn2,$rn3,$rn4,$rn5,$rn6,$rn7,$rn8,$rn9,$rn0,$rn11


$to = "It.Auditor.Guy@Avalanche.com"
$from = "itsupport@Avalanche.com"
$cc = "Yourself@Avalanche.com", "YourBoss@Avalanche.com"
$subject = "Microsoft AIO Audit"
$body = " Audit your licenses, Save money, Make Finance happy, get Bonus!"
$attachment1 = $rn_all


Send-MailMessage -to $to -from $from -cc $cc -subject $subject -body $body -Attachment $rn_all -SmtpServer smtp.office365.com -UseSsl -Credential $UserCredential -Port 587 -BodyAsHtml
Remove-Item C:\Users\$env:UserName\Desktop\Audit\*.csv
