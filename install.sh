#!/bin/sh -e
#copyright by monlor
   
clear
echo "***********************************************"
echo "**                                           **"
echo "**            Welcome to MIXBOX !            **"
echo "**                                           **"
echo "***********************************************"
MBURL="https://cdn.jsdelivr.net/gh/monlor/mixbox@latest"
curl -kfsSlo /tmp/mixbox.conf ${MBURL}/config/mixbox.conf || exit 1
source /tmp/mixbox.conf
echo "支持的兼容配置：[ ${MBHELPERS} ]"
read -p "请输入设备兼容配置名[回车即default]：" helper
curl -kfsSlo /tmp/helper.sh ${MBURL}/helpers/${helper:-default}.sh || exit 1
source /tmp/helper.sh
rm -rf /tmp/helper.sh /tmp/mixbox.conf

loginfo "请按任意键安装工具箱(Ctrl + C 退出)."
read answer
ARCH=$(uname -ms | tr ' ' '_' | tr '[A-Z]' '[a-z]')
[ -n "$(echo $ARCH | grep -E "linux.*aarch64.*")" ] && MBARCH="linux_aarch64"
[ -n "$(echo $ARCH | grep -E "linux.*arm.*")" ] && MBARCH="linux_armv7"
[ -n "$(echo $ARCH | grep -E "linux.*mips.*")" ] && MBARCH="linux_mipsle"
[ -n "$(echo $ARCH | grep -E "linux.*x86_64.*")" ] && MBARCH="linux_amd64"
cat << EOF
请在以下路径中选择一个合适的[工具箱安装位置],[二进制程序路径]和[用户数据目录]：
工具箱二进制程序路径：由于插件的二进制文件一般较大，所以此目录用于存放插件的二进制文件，rom小的设备推荐临时目录，如/tmp/mixbox
用户数据目录：一般用于文件管理器的目录，比如entware默认会安装在此目录中，filebrowser默认使用此目录
> 当二进制程序配置成临时目录时，每次重启系统后，启动插件时会自动下载插件二进制文件
> 小米路由器硬盘版推荐 工具箱安装位置：/etc，二进制程序路径：/etc/mixbox，用户数据目录：/userdisk/data
> 小米路由器普通版推荐 工具箱安装位置：/etc，二进制程序路径：/tmp/mixbox，用户数据目录：/extdisks/sda*
> 如果未插入u盘，用户目录可与工具箱安装位置相同！
EOF

[ ! -d "${MBTMP}" ] && mkdir -p ${MBTMP}
df -h | sed 1d | awk '{print NR"."$6}'
read -p "请输入工具箱安装路径[可手动输入路径]：" MBROOT
read -p "请输入用户数据目录[可手动输入路径]：" MBDISK
read -p "请输入二进制程序路径[回车即${MBROOT}/apps][可手动输入路径]：" MBINROOT
if [ -n "$(echo "$MBROOT" | grep -E "^[0-9][0-9]*$")" ]; then
	MBROOT="$(df -h | sed 1d | awk '{print $6}' | sed -n "$MBROOT"p)/mixbox"
else
	MBROOT=${MBROOT}/mixbox
fi
if [ -n "$(echo "$MBDISK" | grep -E "^[0-9][0-9]*$")" ]; then
	MBDISK="$(df -h | sed 1d | awk '{print $6}' | sed -n "$MBDISK"p)"
fi
[ -z "${MBROOT}" ] && echo "工具箱安装位置不能为空！" && exit 1
[ -z "${MBDISK}" ] && echo "用户数据目录不能为空！" && exit 1
# MBINROOT 默认为${MBROOT}/apps
MBINROOT=${MBINROOT:-${MBROOT}/apps}

loginfo "下载工具箱文件..."
rm -rf ${MBTMP}/mixbox.tar.gz &> /dev/null
wgetsh ${MBTMP}/mixbox.tar.gz ${MBINURL}/appstore/mixbox.tar.gz || exit 1
loginfo "安装工具箱文件..."
tarsh ${MBTMP}/mixbox.tar.gz ${MBTMP}
# 安装工具箱文件
cp -rf ${MBTMP}/mixbox ${MBROOT}
wgetsh ${MBROOT}/lib/helper.sh ${MBURL}/helpers/${helper:-default}.sh || exit 1
chmod -R +x ${MBROOT}/*

loginfo "初始化工具箱配置信息..."
mkdir ${MBROOT}/log
touch ${MBROOT}/config/applist.txt #初始化插件列表
touch ${MBROOT}/config/firewall.txt
touch ${MBROOT}/config/watch.txt
touch ${MBROOT}/config/crontab.txt

echo "设置工具箱web访问用户密码："
read -p "请输入你的工具箱用户名：" MBUSER
read -p "请输入你的工具箱密码：" MBPWD

cat >> ${MBROOT}/config/mixbox.conf << EOF
MBROOT="${MBROOT}"
MBDISK="${MBDISK}"
MBARCH="${MBARCH}"
MBINROOT="${MBINROOT}"
MBLOG="${MBROOT}/log"
MBUSER="${MBUSER}"
MBPWD="${MBPWD}"
EOF

loginfo "执行工具箱初始化脚本..."
export MBROOT=${MBROOT}
export MBTMP=${MBTMP}
export MBINROOT=${MBINROOT}
${MBROOT}/scripts/init.sh

if type on_install &> /dev/null; then
	loginfo "触发安装帮助脚本..."
	on_install
fi

loginfo "工具箱安装完成!"
rm -rf ${MBTMP}/mixbox.tar.gz
rm -rf ${MBTMP}/mixbox
