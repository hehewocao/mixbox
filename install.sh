#!/bin/sh -eu
#copyright by monlor
alias loginfo='echo 【$(TZ=UTC-8 date +%Y年%m月%d日\ %X)】【INFO】:'
   
clear
loginfo "***********************************************"
loginfo "**                                           **"
loginfo "**            Welcome to MIXBOX !            **"
loginfo "**                                           **"
loginfo "***********************************************"
loginfo "请按任意键安装工具箱(Ctrl + C 退出)."
read answer

#MBURL="${MBURL:-https://cdn.jsdelivr.net/gh/monlor/mixbox@latest}"
#MBINURL="${MBINURL:-https://cdn.jsdelivr.net/gh/monlor/binfiles@latest}"
MBURL="https://raw.githubusercontent.com/monlor/mixbox/master"
MBINURL="https://raw.githubusercontent.com/monlor/binfiles/master"
if [ -L /tmp/mixbox.conf ]; then
	loginfo "工具箱配置文件已存在！请确认工具箱是否已安装！"
	exit 1
fi
loginfo "加载工具箱配置文件..."
curl -kfsSlo /tmp/mixbox.conf ${MBURL}/config/mixbox.conf || exit 1
source /tmp/mixbox.conf

loginfo "支持的兼容配置：[ ${MBHELPERS} ]"
loginfo "请输入设备兼容配置名[回车即default]：" 
read helper
!(echo ${MBHELPERS} | tr ',' '\n' | grep -Eq "^${helper:-default}$") && loginfo "输入有误！" && exit 1
curl -kfsSlo /tmp/helper.sh ${MBURL}/helpers/${helper:-default}.sh || exit 1
source /tmp/helper.sh

loginfo "清理文件中..."
rm -rf ${MBTMP} /tmp/mixbox.conf 

[ ! -d "${MBTMP}" ] && mkdir -p ${MBTMP}

ARCH=$(uname -ms | tr ' ' '_' | tr '[A-Z]' '[a-z]')
echo $ARCH | grep -qE "linux.*aarch64.*" && MBARCH="linux_aarch64"
echo $ARCH | grep -qE "linux.*arm.*" && MBARCH="linux_armv7"
echo $ARCH | grep -qE "linux.*mips.*" && MBARCH="linux_mipsle"
echo $ARCH | grep -qE "linux.*x86_64.*" && MBARCH="linux_amd64"
echo $ARCH | grep -qE "linux.*x86_64.*" && MBARCH="linux_amd64"
echo $ARCH | grep -qE "darwin.*x86_64.*" && MBARCH="darwin_amd64"
cat << EOF
=====================================================================================
> 请在以下路径中选择一个合适的[工具箱安装位置],[二进制程序路径]和[用户数据目录]：
> 工具箱二进制程序路径：由于插件的二进制文件一般较大，所以此目录用于存放插件的二进制文件，rom小的设备推荐临时目录，如/tmp/mixbox
> 用户数据目录：一般用于文件管理器的目录，比如entware默认会安装在此目录中，filebrowser默认使用此目录
> 当二进制程序配置成临时目录时，每次重启系统后，启动插件时会自动下载插件二进制文件
> 小米路由器硬盘版推荐 工具箱安装位置：/etc，二进制程序路径：/etc/mixbox，用户数据目录：/userdisk/data
> 小米路由器普通版推荐 工具箱安装位置：/etc，二进制程序路径：/tmp/mixbox，用户数据目录：/extdisks/sda*
=====================================================================================
EOF

[ ! -d "${MBTMP}" ] && mkdir -p ${MBTMP}
loginfo "请输入工具箱安装路径：" 
read MBROOT
[ -z "${MBROOT}" -o ! -d "${MBROOT}" ] && loginfo "工具箱安装位置不能为空或目录不存在！" && exit 1
MBROOT=${MBROOT}/mixbox

[ -d "${MBROOT}" ] && loginfo "工具箱文件夹${MBROOT}已存在！请检查工具箱是否已经安装！" && exit 1

loginfo "请输入用户数据目录：" 
read MBDISK
[ -z "${MBDISK}" -o ! -d "${MBDISK}" ] && loginfo "用户数据目录不能为空或目录不存在！" && exit 1

loginfo "请输入二进制程序路径[回车即${MBROOT}/apps]：" 
read MBINROOT
MBINROOT=${MBINROOT:-${MBROOT}/apps}

loginfo "设置工具箱web访问用户密码..."
loginfo "请输入你的工具箱用户名：" 
read MBUSER
[ -z "${MBUSER}" ] && logerror "用户名不能为空！"
loginfo "请输入你的工具箱密码：" 
read MBPWD
[ -z "${MBPWD}" ] && logerror "密码不能为空！"

loginfo "下载工具箱文件..."
rm -rf ${MBTMP}/mixbox.tar.gz &> /dev/null
wgetsh ${MBTMP}/mixbox.tar.gz ${MBINURL}/mixbox/mixbox.tar.gz || exit 1

loginfo "安装工具箱文件..."
tarsh ${MBTMP}/mixbox.tar.gz ${MBTMP}
# 安装工具箱文件
cp -rf ${MBTMP}/mixbox ${MBROOT}
mv -f /tmp/helper.sh ${MBROOT}/lib
chmod -R +x ${MBROOT}/*
# 清楚安装文件
rm -rf ${MBTMP}/mixbox.tar.gz
rm -rf ${MBTMP}/mixbox

loginfo "初始化工具箱配置信息..."
mkdir ${MBROOT}/log
mkdir ${MBROOT}/apps
touch ${MBROOT}/config/firewall.txt
touch ${MBROOT}/config/watch.txt
touch ${MBROOT}/config/crontab.txt

cat >> ${MBROOT}/config/mixbox.conf << EOF
MBROOT="${MBROOT}"
MBDISK="${MBDISK}"
MBARCH="${MBARCH}"
MBINROOT="${MBINROOT}"
MBLOG="${MBROOT}/log"
MBUSER="${MBUSER}"
MBPWD="${MBPWD}"
MBURL="${MBURL}"
MBINURL="${MBINURL}"
EOF

loginfo "执行工具箱初始化脚本..."
${MBROOT}/scripts/init.sh ${MBROOT}

if type on_install &> /dev/null; then
	loginfo "触发安装帮助脚本..."
	on_install
fi

loginfo "工具箱安装完成!"

