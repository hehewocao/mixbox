
path="${path:-$MBDISK/.Entware}"

init_entware() {	
	if [ ! -f ${path}/etc/init.d/rc.unslung ]; then
		loginfo "检测到第一次运行${appname}服务，正在安装..."
		local ins_mode
		case "${MBARCH}" in 
			linux_armv7) [ "$(uname -r | cut -d'.' -f1)" -ge '3' ] && ins_mode=armv7sf-k3.2 || ins_mode=armv7sf-k2.6 ;;
			linux_mipsle) ins_mode=mipselsf-k3.4 ;;
			linux_amd64) ins_mode=x64-k3.2 ;;
			linux_aarch64) ins_mode=aarch64-k3.10 ;;
			*) logerror "暂不支持你的设备型号${MBARCH}" && exit 1 ;;
		esac
		loginfo "即将安装${ins_mode}..."
		wgetsh ${MBTMP}/generic.sh ${remote_url_prefix}/${ins_mode}/installer/generic.sh || exit 1
		logexe sh ${MBTMP}/generic.sh
		if [ $? -ne 0 ]; then
			loginfo "【${appname}】服务安装失败"
			stop
			exit 1
		fi
		logexe /opt/bin/opkg update
		logexe /opt/bin/opkg install curl
		loginfo "为了不和系统的opkg冲突，请使用epkg安装软件包！"
		ln -sf /opt/bin/opkg /opt/bin/epkg
	fi
}

start () {

	loginfo "初始化${appname}服务..."
	!(mkdir -p ${path}) && logerror "创建目录失败，检查你的路径是否正确！" && exit 1
	[ ! -d /opt ] && (mkdir /opt || exit 1)
	[ ! -d /opt/bin ] && (mount -o blind "${path}" /opt || exit 1)

	add_lib_path "/opt/lib" || exit 1
	add_env_path "/opt/bin:/opt/sbin" || exit 1
	init_entware
	logexe /opt/etc/init.d/rc.unslung start

}

stop () {

	loginfo "正在停止${appname}服务... "
	/opt/etc/init.d/rc.unslung stop &> /dev/null
	[ -d /opt/bin ] && umountsh /opt
	del_lib_path "/opt/lib" 
	del_env_path "/opt/bin:/opt/sbin" 

}

is_running() {
	return `[ -d /opt/bin ] && echo ${PATH} | grep -q "/opt/bin"`
}