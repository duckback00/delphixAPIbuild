#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (c) 2017 by Delphix. All rights reserved.
#
# Program Name : auth1.ps1
# Description  : Delphix PowerShell API Basic Example  
# Author       : Alan Bitterman
# Created      : 2017-11-15
# Version      : v1.2
#
# Requirements :
#  1.) Change values below as required
#
# Usage: . .\auth1.ps1
#
#########################################################
#                   DELPHIX CORP                        #
# Please make changes to the parameters below as req'd! #
#########################################################

#
# Delphix Engine Variables ...
#
$BaseURL = "http://3.135.185.65/resources/json/delphix"
$DMUSER = "delphix_admin"
$DMPASS = "delphix"

#########################################################
#                   DELPHIX CORP                        #
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

# 
# Application Variables ...
#
$nl = [Environment]::NewLine
$CONTENT_TYPE="Content-Type: application/json"
$COOKIE = "cookies.txt"

#########################################################
## Authentication ...

echo "Authenticating on ${BaseURL}"

#########################################################
## Delphix Curl Session API ...

write-output "${nl}Calling Session API ...${nl}"
$arr=@{}
$arr["type"] = "APISession"
$arr["version"] = @{}
$arr["version"]["type"]="APIVersion"
$arr["version"]["major"]=1
$arr["version"]["minor"]=10
$arr["version"]["micro"]=0
$json = $arr | ConvertTo-Json
$results = Invoke-RestMethod -URI "${BaseURL}/session" -SessionVariable session -Method Post -Body $json -ContentType 'application/json'
write-output "Session API Results: ${results}"

#########################################################
## Delphix Login API ...

write-output "${nl}Calling Login API ...${nl}"
$person = @{}
$person["type"]="LoginRequest"
$person["username"]="${DMUSER}"
$person["password"]="${DMPASS}"
$json = $person | ConvertTo-Json
$results = Invoke-RestMethod -URI "${BaseURL}/login" -WebSession $session -Method Post -Body $json -ContentType 'application/json'
write-output "Login API Results: ${results}"

#########################################################
## Delphix API ...

write-output "${nl}Calling API ...${nl}"
$results = Invoke-RestMethod -Method Get -ContentType "application/json" -WebSession $session -URI "${BaseURL}/database"
write-output "API Results: ${results}"

#$str = $results | ConvertTo-Json    # -InputObject $results
#$str = ConvertTo-Json -InputObject $results
#write-output "API Results: ${str}"

$o = $results.result
$o

############## E O F ####################################
## Clean up and Done ...

Remove-Variable DMUSER, DMPASS, BaseURL, COOKIE, CONTENT_TYPE, results, json
Write-Output " "
Write-Output "Done ..."
Write-Output " "
exit 0
