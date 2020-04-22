#
# Usage 
# . .\build.ps1 [ create | restore | refresh | delete ]
param (
    [String]$ACTION=''   
)#

# 
# Variables ...
#
$DLPX_GRP = "SQL_TDM"
$DLPX_DB = "delphix_demo"
$DLPX_VDB = "vdelphix_demo"

# 
# Process Action ...
#
if ("${ACTION}" -eq "create") {

   echo "Building ..."
   #. .\create_window_target_env.ps1

   . .\group_operations.ps1 create "${DLPX_GRP}"

   $DLPX_GRP = "SQL_TDM"
   $DLPX_DB = "delphix_demo"
   $DLPX_VDB = "vdelphix_demo"
   ##echo "provision_sqlserver_i.ps1 "${DLPX_DB}" "${DLPX_VDB}" "${DLPX_GRP}" "win1" MSSQLSERVER"
   . .\provision_sqlserver_i.ps1 "${DLPX_DB}" "${DLPX_VDB}" "${DLPX_GRP}" "win1" MSSQLSERVER

} elseif ("${ACTION}" -eq "restore") {

   echo "Restore ..."
   . .\vdb_operations.ps1 rollback "${DLPX_VDB}"
   #./jetstream_container_restore_to_bookmark_jq.sh tpl dc baseline

} elseif ("${ACTION}" -eq "refresh") {

   echo "Refresh ..."
   . .\vdb_operations.ps1 refresh "${DLPX_VDB}"
   #  ./jetstream_container_refresh_jq.sh tpl dc

} elseif ("${ACTION}" -eq "delete") {

   echo "Clean Up ..."
   #   ./jetstream_container_delete_jq.sh tpl dc delete false
   # ./jetstream_template_delete_jq.sh tpl delete
   # ./build_my_datasets.sh appdata delete

   . .\vdb_init.ps1 delete "${DLPX_VDB}"

   $DLPX_GRP = "SQL_TDM" 
   $DLPX_DB = "delphix_demo"
   $DLPX_VDB = "vdelphix_demo"
   . .\group_operations.ps1 delete "${DLPX_GRP}"

} else {

   echo "Usage: . .\build.ps1 [ create | restore | refresh | delete ]"

}
exit