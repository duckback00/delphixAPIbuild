
#########################################################
## Masking Hook Parameters ... 

$DMIP="10.0.0.9"             # Delphix Masking Engine ...
$DMUSER="admin"              # Delphix Masking User ...
$DMPASS='Admin-12'           # Need single quotes in case password contains special characters
$JOBID="94"                   # Masking Job Number ...

## Local Log File ...
$date = Get-Date  
$DT = $date.ToString("yyyyMMddHHmmss")    
#$LOG="c:\temp\masking_hook_${DT}.log"    # Local Log File ...  

#########################################################
##       NO CHANGES BELOW THIS POINT REQUIRED          ##
#########################################################

$BaseURL="http://"+$DMIP+"/masking/api/"     
$CONTENT_TYPE = "application/json"
$DELAYTIMESEC=10

echo "Masking Started: ${DT}" #| Out-File -FilePath ${LOG} 
$PSVersionTable #| Out-File -FilePath ${LOG} -Append

#########################################################
## Authentication ...

echo "Processing ..."
echo "Authenticating on ${BaseURL}" #| Out-File -FilePath ${LOG} -Append 

$json = "{ ""username"": """+${DMUSER}+""", ""password"": """+${DMPASS}+"""}"
##echo "JSON: ${json}" #| Out-File -FilePath ${LOG} -Append

$results = (Invoke-RestMethod -Method POST -URI "${BaseURL}/login" -body "${json}" -ContentType: "${CONTENT_TYPE}")
$KEY=$results.Authorization
echo "Token: $KEY" #| Out-File -FilePath ${LOG} -Append

#########################################################
## System Information ...

echo "Gathering System Information ..." #| Out-File -FilePath ${LOG} -Append
$results = (Invoke-RestMethod -Headers @{ "Authorization" = $KEY } -Method GET -URI "${BaseURL}/system-information" -ContentType: "${CONTENT_TYPE}")
$VERSION=$results.version
echo "Masking Platform Version: ${VERSION}" #| Out-File -FilePath ${LOG} -Append

#########################################################
## Submit Job ...

$json="{""jobId"": """+${JOBID}+"""}"

echo "Running Masking JobId ${JOBID} ..." #| Out-File -FilePath ${LOG} -Append
$results = (Invoke-RestMethod -Headers @{ "Authorization" = $KEY } -Method POST -URI "${BaseURL}/executions" -body "${json}" -ContentType: "${CONTENT_TYPE}")
#echo $results
#{"executionId":896,"jobId":677,"status":"RUNNING","startTime":"2018-06-26T01:08:42.206+0000"}
$execId = $results.executionId
$status = $results.status
echo "Job Execution Id: $execId" #| Out-File -FilePath ${LOG} -Append
echo "Job Submit Status: $status" #| Out-File -FilePath ${LOG} -Append

if ("${status}" -ne "RUNNING") {
   echo "Masking job ${JOBID} failed with ""${status}"" Status" #| Out-File -FilePath ${LOG} -Append
   echo "${results}" #| Out-File -FilePath ${LOG} -Append
   echo "Exiting ..." #| Out-File -FilePath ${LOG} -Append
   exit 1
}

#########################################################
## Getting Job Status ...

echo "*** waiting for status every ${DELAYTIMESEC} (secs) ***" #| Out-File -FilePath ${LOG} -Append
$rows = 0
$total = 0
DO
{
   sleep ${DELAYTIMESEC}
   $d = Get-Date
   $results = (Invoke-RestMethod -Headers @{ "Authorization" = $KEY } -Method GET -URI "${BaseURL}/executions/${execId}" -ContentType: "${CONTENT_TYPE}")
   #echo $results
   #{"executionId":896,"jobId":677,"status":"RUNNING","startTime":"2018-06-26T01:08:42.206+0000"}
   $status = $results.status
   echo "$d $status" #| Out-File -FilePath ${LOG} -Append
} While ($status -contains "RUNNING")

#########################################################
## Final Status ...

if ("${status}" -eq "SUCCEEDED") {
   #echo $results
   #{"executionId":901,"jobId":677,"status":"SUCCEEDED","rowsMasked":3,"rowsTotal":3,"startTime":"2018-06-26T01:31:58.644+0000","endTime":"2018-06-26T01:32:29.268+0000"}
   $startTime = $results.startTime
   $endTime = $results.endTime
   $rows = $results.rowsMasked
   $total = $results.rowsTotal
   echo "${status}. Rows Masked: ${rows}  of  Rows Total: ${total}" 
   #echo "${status}. Rows Masked: ${rows}  of  Rows Total: ${total}" #| Out-File -FilePath ${LOG} -Append
   #echo "Masking Start Time: ${startTime}" #| Out-File -FilePath ${LOG} -Append
   #echo "Masking End Time: ${endTime}" #| Out-File -FilePath ${LOG} -Append
} else {
   echo "Masking job(s) Failed with ${status} Status" 
   #echo "Masking job(s) Failed with ${status} Status" #| Out-File -FilePath ${LOG} -Append
}

############## E O F ####################################
## Done ...

$d = Get-Date
echo "$d  Finished Time ..." #| Out-File -FilePath ${LOG} -Append
echo "Done ..." #| Out-File -FilePath ${LOG} -Append
echo "Log File: ${LOG}"
Remove-Variable -Name * -ErrorAction SilentlyContinue
exit
