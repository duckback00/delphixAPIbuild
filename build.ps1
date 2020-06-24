#
# Usage 
# . .\build.ps1 [ create | restore | restore2bookmark | reset | refresh | bookmark | delete ] [bookmark_name]
param (
    [String]$ACTION='',
    [String]$BM_NAME=''  
)#

# Config Files:  delphix_engine_conf.ps1
# 
# Variables ...
#
$DLPX_GRP = "SQL_TDM"
$DLPX_DB = "delphix_demo"
$DLPX_VDB = "vdelphix_demo"
$DLPX_TPL = "tpl"
$DLPX_DS = "ds"
$DLPX_DC = "dc"
$DLPX_BM = "baseline"
$SQL_HOST = "win1"
$SQL_INSTANCE = "MSSQLSERVER"

#
# Break Fix Group and VDB Name ...
#
$DLPX_GRP_BF = "Break_Fix"
$DLPX_VDB_BF = "vbreak_fix"

$date = Get-Date  
$DT = $date.ToString("yyyyMMddHHmmss") 

# 
# Process Action ...
#
if ("${ACTION}" -eq "create") {

   echo "Building ..."
   #. .\create_window_target_env.ps1

   . .\group_operations.ps1 create "${DLPX_GRP}"

   . .\provision_sqlserver_i.ps1 "${DLPX_DB}" "${DLPX_VDB}" "${DLPX_GRP}" "${SQL_HOST}" "${SQL_INSTANCE}"

   . .\jetstream_template_create.ps1 "${DLPX_TPL}" "${DLPX_DB}" "${DLPX_DS}"
   . .\jetstream_container_create.ps1 "${DLPX_TPL}" ds "${DLPX_VDB}" "${DLPX_DC}"
   . .\jetstream_bookmark_create_from_latest.ps1 "${DLPX_TPL}" "${DLPX_DC}" "${DLPX_BM}" false 'tag123'

} elseif ("${ACTION}" -eq "break_fix") {

   echo "Create Break_Fix ..."
   . .\group_operations.ps1 create "${DLPX_GRP_BF}"

   . .\provision_sqlserver_break_fix.ps1 "${DLPX_DB}" "${DLPX_VDB_BF}" "${DLPX_GRP_BF}" "${SQL_HOST}" "${SQL_INSTANCE}"
   
} elseif ("${ACTION}" -eq "restore") {

   echo "Restore ..."
   #. .\vdb_operations.ps1 rollback "${DLPX_VDB}"
   . .\jetstream_container_restore_to_bookmark.ps1 "${DLPX_TPL}" "${DLPX_DC}" "${DLPX_BM}"

} elseif ("${ACTION}" -eq "restore2bookmark") {

   echo "Restore to Bookmark ${BM_NAME} ..."
   if ( "${BM_NAME}" -ne "" ) {
      . .\jetstream_container_restore_to_bookmark.ps1 "${DLPX_TPL}" "${DLPX_DC}" "${BM_NAME}"
   } else { 
      echo "Warning: Missing Bookmark Name ${BM_NAME} ..."
   } 
} elseif ("${ACTION}" -eq "reset") {

   echo "Reset ..."
   . .\jetstream_container_reset.ps1 "${DLPX_TPL}" "${DLPX_DC}"

} elseif ("${ACTION}" -eq "refresh") {

   echo "Refresh ..."
   #. .\vdb_operations.ps1 refresh "${DLPX_VDB}"
   . .\jetstream_container_refresh.ps1 "${DLPX_TPL}" "${DLPX_DC}"

} elseif ("${ACTION}" -eq "bookmark") {

   if ( "${BM_NAME}" -eq "" ) {
      $BM_NAME = "BM_${DT}"
   } 
   echo "Creating Bookmark ${BM_NAME} ..."
   . .\jetstream_bookmark_create_from_latest.ps1 "${DLPX_TPL}" "${DLPX_DC}" "${BM_NAME}" false 'api'

} elseif ("${ACTION}" -eq "delete") {

   echo "Clean Up ..."
   . .\jetstream_container_delete.ps1 "${DLPX_TPL}" "${DLPX_DC}" delete false
   . .\jetstream_template_delete.ps1 "${DLPX_TPL}" delete

   . .\vdb_init.ps1 delete "${DLPX_VDB}"
   . .\group_operations.ps1 delete "${DLPX_GRP}"

} else {

   echo "Usage: . .\build.ps1 [ create | restore | restore2bookmark | reset | refresh | bookmark | delete ] [bookmark_name]"

}
Remove-Variable -Name * -ErrorAction SilentlyContinue
exit