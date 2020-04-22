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
# Program Name : auth2.ps1
# Description  : Delphix PowerShell API Basic Example  
# Author       : Alan Bitterman
# Created      : 2017-11-10
# Version      : v1.2
#
# Requirements :
#  1.) Populate Delphix Engine Connection Information . .\delphix_engine_conf.ps1
#  2.) Include Delphix Functions . .\delphixFunctions.ps1
#  3.) Change values below as required
#
# Usage: . .\auth2.ps1
#
#########################################################
#                   DELPHIX CORP                        #
# Please make changes to the parameters below as req'd! #
#########################################################

#########################################################
## Parameter Initialization ...

. .\delphix_engine_conf.ps1

#########################################################
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

#########################################################
## Local Functions ...

. .\delphixFunctions.ps1

#########################################################
## Authentication ...

Write-Output "Authenticating on ${BaseURL} ... ${nl}"
$session=RestSession "${DMUSER}" "${DMPASS}" "${BaseURL}" "${COOKIE}" "${CONTENT_TYPE}" 
Write-Output "Login Results: $session"

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

Remove-Variable -Name * -ErrorAction SilentlyContinue
#Remove-Variable session, DMUSER, DMPASS, BaseURL, COOKIE, CONTENT_TYPE, DELAYTIMESEC, DT, results, status
Write-Output " "
Write-Output "Done ..."
Write-Output " "
exit 0
