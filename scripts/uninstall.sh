#!/bin/sh 
#copyright by monlor
if [ -n "${1}" ]; then
  ln -sf ${1}/config/mixbox.conf /tmp/mixbox.conf
fi
source /tmp/mixbox.conf 
[ -z "${MBROOT}" ] && echo "未找到工具箱文件！" && exit 1
source ${MBROOT}/bin/base

loginfo "正在卸载工具箱..."

loginfo "停止所有插件"

${MBROOT}/scripts/monitor.sh applist stop

daemon_stop shell2http

loginfo "删除定时任务"
cru c 

loginfo "删除所有工具箱配置信息"

power_boot_del "mixbox"

firewall_restart_del "mixbox"

loginfo "See You!"

sleep 3

rm -rf ${MBINROOT} ${MBROOT} ${MBTMP} /tmp/mixbox.conf

