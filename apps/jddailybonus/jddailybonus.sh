
JD_SCRIPT=${MBROOT}/apps/${appname}/JD_DailyBonus.js
export skip_quote=1

signin() {
  !(type node &> /dev/null) && logerror "需要安装node环境！" && exit 1
  !(type npm &> /dev/null) && logerror "需要安装npm环境！" && exit 1
  assert_nil cookie && exit 1
  loginfo "安装request依赖..."
  logexe npm install request -g --registry=https://registry.npm.taobao.org 
  loginfo "更新签到脚本..."
  wgetsh ${JD_SCRIPT} ${remote_url} 
  pc_replace "var Key.*" "var Key = '$cookie';" $JD_SCRIPT
  loginfo "开始执行签到任务..."
  logexe node $JD_SCRIPT
}

start() {

  cru a "${appname}" "1 ${time:-0} * * * ${MBROOT}/scripts/appmanage.sh ${appname} signin"
  # 启动程序
  signin
}

stop() {

  cru d "${appname}"
  return 0

}

is_running() {
  test "${enabled:-0}" -eq 1
}