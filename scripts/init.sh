#!/bin/sh -eu
#copyright by monlor
MBROOT="${1}"
[ -z ${MBROOT} -o ! -d "${MBROOT}" ] && echo "请传入工具箱目录参数或未找到工具箱文件！" && exit 1

source ${MBROOT}/config/mixbox.conf
source ${MBROOT}/bin/base init

loginfo "工具箱初始化脚本启动..."

[ ! -d "${MBTMP}" ] && mkdir -p ${MBTMP}
[ ! -d "${MBINROOT}" ] && mkdir -p ${MBINROOT}

if [ -f ${MBTMP}/mixbox_inited ]; then
	logerror "工具箱已经初始化！"
fi

# 添加init标示，防止多次init
touch ${MBTMP}/mixbox_inited

loginfo "检查环境变量配置"
ln -sf ${MBROOT}/config/mixbox.conf /tmp/mixbox.conf 

loginfo "检查守护进程配置"
cru a watch "*/10 * * * * ${MBROOT}/scripts/monitor.sh watch watch"

loginfo "添加工具箱开机启动配置"
power_boot_add "mixbox" "${MBROOT}/scripts/init.sh ${MBROOT}"

loginfo "防火墙重启插件检查"
firewall_restart_add "mixbox" "${MBROOT}/scripts/monitor.sh firewall reload"

loginfo "下载二进制程序..."
download_binfile "${MBINFILE}" || exit 1
ln -sf ${MBINROOT}/mixbox/* ${MBROOT}/bin

if type on_init &> /dev/null; then
	loginfo "触发初始化帮助脚本..."
	on_init
fi

loginfo "执行工具箱插件监控脚本"
# 系统重启时重启插件
${MBROOT}/scripts/monitor.sh applist watch

loginfo "启动web服务程序..."
daemon_start shell2http -basic-auth ${MBUSER}:${MBPWD} -port 8088 -cgi -form /api/mixbox ${MBROOT}/scripts/shell2http.sh

if [ -x "${MBROOT}/scripts/userscript.sh" ]; then
	loginfo "运行用户自定义脚本"
 	${MBROOT}/scripts/userscript.sh
fi