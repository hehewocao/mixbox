#!/bin/sh -euo pipefail
#copyright by monlor
source /etc/profile &> /dev/null
source ${MBROOT}/bin/base

APPNAME="$2"
[ -z "${APPNAME}" ] && logerror "请输入插件名！"

ENABLED=0
UPGRADE=0

install () {

	loginfo "开始安装插件【$APPNAME】..."
	wgetsh ${MBTMP}/${APPNAME}.conf ${MBINURL}/apps/${APPNAME}/${APPNAME}.conf || logerror "加载远程配置文件失败！"
	source ${MBTMP}/${APPNAME}.conf 
	rm -rf ${MBTMP}/${APPNAME}.conf
	echo ${supports} | tr ',' '\n' | grep -E "^${MODEL}$" &> /dev/null || logerror "设备架构：$MODEL，插件支持：$supports，无法安装！"
	loginfo "检查工具箱版本..."
	[ "$(versioncmp $MBVER $needver)" = '-1' ] && logerror "工具箱版本过低！【${APPNAME}】要求工具箱版本：$needver"	
	loginfo "工具箱版本[$MBVER]满足安装要求"

	loginfo "下载插件安装文件..."
	wgetsh "${MBTMP}/${APPNAME}.tar.gz" "$MBINURL/${APPNAME}/${APPNAME}.tar.gz" || logerror "文件下载失败！"
	loginfo "解压安装文件..."
	tarsh ${MBTMP}/${APPNAME}.tar.gz ${MBTMP} || logerror "文件解压失败！"
	loginfo "赋予可执行文件..."
	chmod +x -R ${MBTMP}/${APPNAME}/
	if [ "${UPGRADE}" -eq 1 ]; then
		# 清除不用更新的文件
		rm -rf ${MBTMP}/${APPNAME}/${APPNAME}.conf
	fi 
	cp -rf ${MBTMP}/${APPNAME}/ ${MBROOT}/apps/

	if [ -f ${MBROOT}/apps/${APPNAME}/scripts/extra.sh ]; then
		loginfo "检查到插件有升级补丁脚本！"
		${MBROOT}/apps/${APPNAME}/scripts/extra.sh
	fi

	loginfo "添加插件到工具箱..."
	if cat ${MBROOT}/config/applist.txt | grep -Eq "^${appname}$"; then
		pc_append "${APPNAME}" ${MBROOT}/config/applist.txt
	fi

	loginfo "添加菜单..."
	if cat ${MBROOT}/config/menu.txt | grep -Eq "^${appname},"; then
		pc_append "${appname},${service},${webicon:-lock},${webpath:-/app/general/${appname}},${weborder:-2000}" ${MBROOT}/config/menu.txt
	fi

  [ ! -d ${MBINROOT}/${APPNAME} ] && mkdir -p ${MBINROOT}/${APPNAME}
	# 清除临时文件
	rm -rf ${MBTMP}/${APPNAME}
	rm -rf ${MBTMP}/${APPNAME}.tar.gz

	loginfo "插件安装完成！"
	if [ -n "${newinfo}" ]; then
		echo -e "-----------------------------------------"
		echo -e "${newinfo}"
		echo -e "-----------------------------------------"
	fi

}

upgrade() {
	
	loginfo "开始更新【${APPNAME}】插件..."
	checkuci ${APPNAME} || logerror "插件【${APPNAME}】未安装！" 
	${MBROOT}/scripts/appmanage.sh ${APPNAME} status &> /dev/null
	[ $? -eq 0 ] && ENABLED=1 || ENABLED=0
	if [ "${ENABLED}" -eq 1 ]; then
		loginfo "先停止插件..."
		${MBROOT}/scripts/appmanage.sh ${APPNAME} stop
	fi
	UPGRADE=1
	install ${APPNAME}
	loginfo "更新二进制程序..."
	download_binfile ${binfile} 1
	if [ "${ENABLED}" -eq 1 ]; then
		loginfo "启动插件中..."
		${MBROOT}/scripts/appmanage.sh ${APPNAME} start
	fi

}

uninstall() {

	checkuci ${APPNAME} || logerror "插件【${APPNAME}】未安装！" 
	loginfo "开始卸载【${APPNAME}】插件..."
	loginfo "先停止【${APPNAME}】插件..."
	${MBROOT}/scripts/appmanage.sh ${APPNAME} stop
	# 清除插件列表中的插件信息
	loginfo "从插件列表中移除..."
  pc_delete ${APPNAME} ${MBROOT}/config/applist.txt
	# 删除插件文件
	loginfo "清除所有插件文件"
  rm -rf ${MBINROOT}/${APPNAME}
	rm -rf ${MBROOT}/apps/${APPNAME} 
  loginfo "插件【${APPNAME}】卸载完成"

}
 

case "$1" in
	install) install;;
	upgrade) upgrade ;;
	uninstall) uninstall ;;
	*) echo "Usage: $0 {add|upgrade|del} APPNAME"
esac
