# 此脚本提供工具箱所需的一些变量或者函数，后期用于兼容各类不同的系统环境

WANIP=$(ubus call network.interface.wan status 2> /dev/null | grep \"address\" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || echo -n "127.0.0.1")
LANIP=$(uci get network.lan.ipaddr 2> /dev/null || echo -n "127.0.0.1")
MODEL=$(cat /proc/xiaoqiang/model 2> /dev/null || uname -s)

on_install() {
	return 0
}

on_init() {
	[ ! -d /tmp/etc/dnsmasq.d ] && mkdir /tmp/etc/dnsmasq.d
	return 0
}

pidsh() {
	pidof "${1}"
}

_quote() {
	# 不转换
	[ "${skip_quote:-0}" -eq 1 ] && echo $1 && return
	# 默认不转换^$
	echo $1 | sed 's/[]\/()*.|[]/\\&/g'
}

# This function looks for a string, and inserts a specified string after it inside a given file
# $1: the line to locate, $2: the line to insert, $3: Config file where to insert
pc_insert_next() {
	PATTERN=$(_quote "$1")
	CONTENT=$(_quote "$2")
	sed -i "/$PATTERN/a$CONTENT" $3
}

pc_insert_prev() {
	PATTERN=$(_quote "$1")
	CONTENT=$(_quote "$2")
	sed -i "/$PATTERN/i$CONTENT" $3
}

# This function looks for a string, and replace it with a different string inside a given file
# $1: the line to locate, $2: the line to replace with, $3: Config file where to insert
pc_replace() {
	PATTERN=$(_quote "$1")
	CONTENT=$(_quote "$2")
	sed -i "s/$PATTERN/$CONTENT/" $3
}

# This function will append a given string at the end of a given file
# $1 The line to append at the end, $2: Config file where to append
pc_append() {
	echo "$1" >> $2
}

# This function will delete a line containing a given string inside a given file
# $1 The line to locate, $2: Config file where to delete
pc_delete() {
	PATTERN=$(_quote "$1")
	sed -i "/$PATTERN/d" $2
}

pc_delete_line() {
	sed -i "$1,$2d" $3
}

wgetsh() {
	# 传入下载的文件位置和下载地址，自动下载到${MBTMP}，若成功则移到下载位置
	[ -z "$1" -o -z "$2" ] && return 1
	[ -x /opt/bin/curl ] && alias curl=/opt/bin/curl
	local wgetfilepath="$1"
	local wgetfilename=$(basename $wgetfilepath)
	local wgetfiledir=$(dirname $wgetfilepath)
	local wgeturl="$2"
	[ ! -d "$wgetfiledir" ] && mkdir -p $wgetfiledir
	[ ! -d ${MBTMP} ] && mkdir -p ${MBTMP}
	rm -rf ${MBTMP}/${wgetfilename}
	if command -v curl &> /dev/null; then
		result1=$(curl -skL --connect-timeout 10 -m 20 -w %{http_code} -o "${MBTMP}/${wgetfilename}" "$wgeturl")
	else
		wget-ssl -q --no-check-certificate --tries=1 --timeout=10 -O "${MBTMP}/${wgetfilename}" "$wgeturl"
		[ $? -eq 0 ] && result1="200"
	fi
	if [ "$result1" = "200" ]; then
		chmod +x ${MBTMP}/${wgetfilename} > /dev/null 2>&1
		mv -f ${MBTMP}/${wgetfilename} $wgetfilepath > /dev/null 2>&1
		return 0
	else
		rm -rf ${MBTMP}/${wgetfilename}
		logwarn "下载文件失败：${wgeturl}"
		return 1
	fi

}

wgetlist() {
	[ -z "$1" ] && echo -n ""
	if command -v wget-ssl &> /dev/null; then
		wget --no-check-certificate -q -O - "$1"
		return $?
	else
		curl -kfsSl "$1"
		return $?
	fi
}

tarsh() {
	tar -zxvf $1 -C $2 &> /dev/null || logerror "文件解压失败：$1"
}

power_boot_add() {
	[ -z "${1}" -o -z "${2}" ] && logerror "参数不能为空！"
	cat > /etc/init.d/${1} <<-EOF
#!/bin/sh /etc/rc.common

START=99

start() {
	/bin/sh ${2} &
}

EOF
	chmod +x /etc/init.d/${1}
	/etc/init.d/${1} enable
}

power_boot_del() {
	[ -z "${1}" ] && logerror "参数不能为空！"
	/etc/init.d/${1} disable
	rm -rf /etc/init.d/${1}
}

# 添加脚本到防火墙触发文件中
firewall_restart_add() {
	[ -z "${1}" -o -z "${2}" ] && logerror "参数不能为空！"
	uci set firewall.${1}=include
	uci set firewall.${1}.type=script
	uci set firewall.${1}.path="${2}"
	uci set firewall.${1}.reload=1
	uci set firewall.${1}.family=any
	uci commit firewall
}

# 移除防火墙触发文件中的脚本
firewall_restart_del() {
	[ -z "${1}" ] && logerror "参数不能为空！"
	uci del firewall.${1}
	uci commit firewall
}

dnsmasq_reload() {
	loginfo "重启dnsmasq..."
	/etc/init.d/dnsmasq reload &> /dev/null
}

dnsmasq_add_config() {
	[ -z "${1}" ] && return 1
	for i in "$@"; do
		loginfo "添加dnsmasq配置文件:${i}"
		ln -sf ${MBTMP}/${i} /tmp/etc/dnsmasq.d/${i}
	done
}

dnsmasq_del_config() {
	[ -z "${1}" ] && return 1
	for i in "$@"; do
		loginfo "删除dnsmasq配置文件:${i}"
		rm -rf /tmp/etc/dnsmasq.d/${i}
		rm -rf ${MBTMP}/${i}
	done
}

daemon_start() {
	loginfo "启动程序:${1}..."
	local binname="$(basename "${1}")"
	local res=0
	local appname=${appname:-mixbox}
	if pidsh ${binname} &> /dev/null; then
    logwarn "${binname}已经启动！"
  fi
	if type nohup &>/dev/null; then 
		nohup ${MBINROOT}/${appname}/$@ >> ${MBLOG}/${appname}.log 2>&1 &
		res=$?
	else 
		${MBINROOT}/${appname}/$@ >> ${MBLOG}/${appname}.log 2>&1 &
		res=$?
	fi
	if [ "${res}" -ne 0 ]; then
		logwarn "启动程序失败:${1}"
		return 1
	fi
	return 0
}

daemon_stop() {
	loginfo "停止程序:$@"
	killall -9 "$@" &> /dev/null
}

# add_env_profile() {
# 	[ -z "${1}" ] && logwarn "add_env_profile参数不能为空！" && return 1
# 	if cat /etc/profile | grep -q "${1}"; then
# 		logwarn "环境变量配置已添加！"
# 		return 1
# 	fi
# 	echo "${1} #mixbox" >> /etc/profile
# }

# del_env_profile() {
# 	[ -z "${1}" ] && logwarn "add_env_profile参数不能为空！" && return 1
# 	pc_delete "${1} #mixbox" /etc/profile
# }

general_cron_task() {
	# 使定时任务生效
	if [ -d /etc/crontabs/ ]; then 
		cronpath="/etc/crontabs/root"
	elif [ -d /var/spool/cron/ ]; then
		cronpath="/var/spool/cron/root"
	elif [ -d /var/spool/cron/crontabs/ ]; then
		cronpath="/var/spool/cron/crontabs/root"
	else
		echo "【Tools】" "找不到定时任务文件！" 
		exit 1
	fi

	pc_delete "#mixbox" ${cronpath} &> /dev/null
	cat ${MBROOT}/config/crontab.txt | cut -d',' -f2 | sed -e 's/$/ #mixbox/g' >> ${cronpath}

}

check_port() {
	[ -z ${port} ] && return
	for i in `echo ${port} | tr ',' '\n'`;do
		if [ -n "$(netstat -ntulp | grep :${i})" ]; then
			logwarn "检测到端口：${i} 被以下进程占用！无法启动！" 
			logerror "$(netstat -ntulp |grep :${i})"
		fi
	done
}


open_port () {
	[ -z "$1" ] && logerror "开放端口不能为空！"
	local port="$1"
	local protocol=${2:-tcp}
	loginfo "开放端口[${port}]/${protocol}"
	if [ -n "$(echo ${port} | grep ',')" ]; then
		iptables -I INPUT -p "${protocol}" -m multiport --dport "${port}" -m comment --comment "mixbox-${appname}" -j ACCEPT 
	else
		iptables -I INPUT -p "${protocol}" --dport "${port}" -m comment --comment "mixbox-${appname}" -j ACCEPT 
	fi
}

close_port () {
	loginfo "关闭端口插件${appname}所有端口..."
	eval `iptables -S | grep "mixbox-${appname}" | sed -e 's/-A/iptables -D/g' | sed -e 's/\$/;/g'`
}