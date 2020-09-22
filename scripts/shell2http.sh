#!/bin/sh 
#copyright by monlor
source /etc/mixbox.conf
source ${MBROOT}/bin/base
source ${MBROOT}/lib/jsonutil.sh

if [ -n "${v_appname}" ]; then
  source ${MBROOT}/apps/${v_appname}/${v_appname}.sh
fi

http_error() {
  local message="${1}"
  local code=1
  echo "Status: 500"
  echo
  echo "$(var_to_json message v_action v_appname code)"
  exit
}

# http_info() {
#   local data="${1}"
#   local msg="${2}"
#   local code=0
#   echo "Status: 200"
#   echo
#   echo "$(var_add_to_json msg v_action v_appname data code)"
# }

sys_login() {
  if [ ${v_username} != "${MBUSER}" ] || [ "${v_password}" != "${MBPWD}" ]; then
    http_error "用户名或密码错误！"
  fi
}

get_main_config() {
  config_to_json_obj ${MBROOT}/config/mixbox.conf
}

get_applist() {
  local applists=`cat ${MBROOT}/config/applist.txt | tr '\n' ','`
  var_to_json applists
}

add_watch() {
  cat ${MBROOT}/config/watch.txt | grep -Eq "^${v_appname}$" && http_error "${v_appname}守护进程已添加！" && return
  pc_append "${v_appname}" ${MBROOT}/config/watch.txt
}

del_watch() {
  pc_delete ${v_appname} ${MBROOT}/config/watch.txt
}

get_watch() {
  local watchs=`cat ${MBROOT}/config/watch.txt | tr '\n' ','`
  var_to_json watchs
}

get_app_config() {
  [ -z "${v_appname}" ] && http_error "appname不能为空！" && return
  json="$(config_to_json_obj ${MBROOT}/apps/${v_appname}/${v_appname}.conf)"
  [ $? -ne 0 ] && http_error "解析配置文件失败！" && return
  status="$(${MBROOT}/scripts/appmanage.sh ${v_appname} status)"
  [ $? -eq 0 ] && statusBool=1 || statusBool=0
  var_add_to_json "${json}" "status" "statusBool"
}

save_app_config() {
  [ -z "${v_appname}" ] && http_error "appname不能为空！" && return
  json_obj_to_config "${v_data}" ${MBROOT}/apps/${v_appname}/${v_appname}.conf
  ${MBROOT}/scripts/appmanage.sh ${v_appname} save &> /dev/null
  get_app_config
}

get_app_form() {
  if [ ! -f ${MBROOT}/apps/${v_appname}/web.json ]; then 
    echo "[]"
  else
    cat ${MBROOT}/apps/${v_appname}/web.json | sed -e "s/{LANIP}/${LANIP}/g"
  fi
}

get_log() {
  if [ -f ${MBROOT}/log/${v_appname}.log ]; then
    cat ${MBROOT}/log/${v_appname}.log
  else
    echo "未找到日志文件！"
  fi
}

get_menu() {
  config_to_json_array ${MBROOT}/config/menu.txt
}

echo "Content-Type: application/json"
echo "Status: 200"
echo
if [ "$(type "${v_action}")" = "${v_action} is a shell function" ]; then
  ${v_action}
else
  http_error "操作${v_action}不存在！" 
fi