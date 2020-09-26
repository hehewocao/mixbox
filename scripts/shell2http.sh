#!/bin/sh 
#copyright by monlor
source /tmp/mixbox.conf
source ${MBROOT}/bin/base || exit 1
source ${MBROOT}/lib/jsonutil.sh

if [ -f "${MBROOT}/apps/${v_appname}/http.sh" ]; then
  source ${MBROOT}/apps/${v_appname}/http.sh
fi

_http_res() {
  local message="${1}"
  local code="${2}"
  echo "Status: ${3}"
  echo
  echo "${message}"
}

http_error() {
  _http_res "${1}" "1" "400"
  exit 0
}

http_info() {
  _http_res "${1}" "0" "200"
}

http_exe() {
  echo "Status: 200"
  echo
  eval "$@"
}

_check_app() {
  [ -z "${v_appname}" ] && http_error "appname不能为空！"
  check_install "${v_appname}" || http_error "${v_appname}未安装！"
}

sys_login() {
  if [ ${v_username} != "${MBUSER}" ] || [ "${v_password}" != "${MBPWD}" ]; then
    http_error "用户名或密码错误！"
  fi
}

get_main_config() {
  http_exe config_to_json_obj ${MBROOT}/config/mixbox.conf
}

get_applist() {
  local applists=`cat ${MBROOT}/config/applist.txt | tr '\n' ','`
  http_exe var_to_json applists
}

add_watch() {
  _check_app
  cat ${MBROOT}/config/watch.txt | grep -Eq "^${v_appname}$" && http_error "${v_appname}守护进程已添加！" && return
  pc_append "${v_appname}" ${MBROOT}/config/watch.txt
  http_info "sucess"
}

get_app_config() {
  _check_app
  json="$(config_to_json_obj ${MBROOT}/apps/${v_appname}/${v_appname}.conf)"
  [ $? -ne 0 ] && http_error "解析配置文件失败！" && return
  status="$(${MBROOT}/scripts/appmanage.sh ${v_appname} status)"
  [ $? -eq 0 ] && statusBool=1 || statusBool=0
  http_exe 'var_add_to_json "${json}" "status" "statusBool"'
}

save_app_config() {
  _check_app
  json_obj_to_config "${v_data}" ${MBROOT}/apps/${v_appname}/${v_appname}.conf
  ${MBROOT}/scripts/appmanage.sh ${v_appname} save &> /dev/null
  get_app_config
}

get_app_form() {
  _check_app
  if [ ! -f ${MBROOT}/apps/${v_appname}/web.json ]; then 
    http_exe echo "[]"
  else
    http_exe 'cat ${MBROOT}/apps/${v_appname}/web.json | sed -e "s/{LANIP}/${LANIP}/g"'
  fi
}

get_log() {
  if [ -f ${MBROOT}/log/${v_appname}.log ]; then
    http_exe cat ${MBROOT}/log/${v_appname}.log
  else
    http_exe echo "未找到日志文件！"
  fi
}

get_menu() {
  http_exe config_to_json_array ${MBROOT}/config/menu.txt
}

get_applist() {
  wgetsh ${MBTMP}/applist_all.txt ${MBURL}/applist.txt &> /dev/null || http_error "获取插件列表失败！"
  local head=`sed -n 1p ${MBTMP}/applist_all.txt`
  echo "${head}|newver|installStatus|watchStatus" > ${MBTMP}/applist.txt
  sed -i 1d ${MBTMP}/applist_all.txt
  cat ${MBTMP}/applist_all.txt | while read line; do
    appname=$(echo $line | cut -d'|' -f1)
    installStatus=$(cat ${MBROOT}/config/applist.txt | grep -Eq "^${appname}\|" && echo 1 || echo 0)
    watchStatus=$(cat ${MBROOT}/config/watch.txt | grep -Eq "^${appname}$" && echo 1 || echo 0)
    newver=$(cat ${MBTMP}/applist_all.txt| grep -E "^${appname}\|" | cut -d'|' -f7)
    echo "${line}|${newver}|${installStatus}|${watchStatus}" >> ${MBTMP}/applist.txt
  done
  http_exe config_to_json_array ${MBTMP}/applist.txt 
}

set_watch() {
  [ -z "${v_appnames}" ] && http_error "appnames不能为空！"
  for appname in `echo ${v_appnames} | tr ',' '\n'`; do
    check_install "${appname}" || http_error "${appname}未安装！" 
    if cat ${MBROOT}/config/watch.txt | grep -Eq "^${appname}$"; then
      pc_delete ${appname} ${MBROOT}/config/watch.txt
    else
      pc_append ${appname} ${MBROOT}/config/watch.txt
    fi  
  done
  get_applist
}

install_app() {
  [ -z "${v_appnames}" ] && http_error "appnames不能为空！"
  for appname in `echo ${v_appnames} | tr ',' '\n'`; do
    check_install "${appname}" && http_error "${appname}已安装！" 
    ${MBROOT}/scripts/softcenter.sh install ${appname} &> /dev/null || http_error "${appname}安装失败！"
  done
  get_applist
}

uninstall_app() {
  [ -z "${v_appnames}" ] && http_error "appnames不能为空！"
  for appname in `echo ${v_appnames} | tr ',' '\n'`; do
    check_install "${appname}" || http_error "${appname}未安装！" 
    ${MBROOT}/scripts/softcenter.sh uninstall ${appname} &> /dev/null || http_error "${appname}卸载失败！"
  done
  get_applist
}

echo "Content-Type: application/json"
if [ "$(type "${v_action}")" = "${v_action} is a shell function" ]; then
  ${v_action}
else
  http_error "操作${v_action}不存在！" 
fi