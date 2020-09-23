# 此脚本提供工具箱所需的一些变量或者函数，后期用于兼容各类不同的系统环境

WANIP="127.0.0.1"
LANIP="127.0.0.1"
MODEL=$(uname -s)

on_install() {
	return
}

on_init() {
	return
}

pidsh() {
  ps ax | grep shell2http | grep -v grep | awk '{print$1}'
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
	sed -i "" "/$PATTERN/a$CONTENT" $3
}

pc_insert_prev() {
	PATTERN=$(_quote "$1")
	CONTENT=$(_quote "$2")
	sed -i "" "/$PATTERN/i$CONTENT" $3
}

# This function looks for a string, and replace it with a different string inside a given file
# $1: the line to locate, $2: the line to replace with, $3: Config file where to insert
pc_replace() {
	PATTERN=$(_quote "$1")
	CONTENT=$(_quote "$2")
	sed -i "" "s/$PATTERN/$CONTENT/" $3
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
	sed -i "" "/$PATTERN/d" $2
}

pc_delete_line() {
	sed -i "" "$1,$2d" $3
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
	logwarn "${MODEL}开启启动待完善！"
}

power_boot_del() {
	return
}

# 添加脚本到防火墙触发文件中
firewall_restart_add() {
	logwarn "${MODEL}防火墙启动事件待完善！"
}

# 移除防火墙触发文件中的脚本
firewall_restart_del() {
	return
}

dnsmasq_reload() {
	return
}

dnsmasq_add_config() {
	logwarn "${MODEL}的dnsmasq待完善！"
}

dnsmasq_del_config() {
	return
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
# 	if cat ~/.bash_profile | grep -q "${1}"; then
# 		logwarn "环境变量配置已添加！"
# 		return 1
# 	fi
# 	echo "${1} #mixbox" >> ~/.bash_profile
# 	[ -f ~/.zshrc ] && echo "${1} #mixbox" >> ~/.zshrc
# }

# del_env_profile() {
# 	[ -z "${1}" ] && logwarn "add_env_profile参数不能为空！" && return 1
#   PATTERN=$(_quote "$1")
# 	sed -i "" "/$PATTERN/d" ~/.bash_profile
# 	[ -f ~/.zshrc ] && sed -i "" "/$PATTERN/d" ~/.zshrc
# }

general_cron_task() {
  loginfo "${MODEL}暂时手动添加以下定时任务！"
  logexe "cat ${MBROOT}/config/crontab.txt | cut -d',' -f2"
	# [ ! -f /etc/crontab ] && sudo mkdir /etc/crontab
	# sudo sed -i "" "/#mixbox/d" /etc/crontab
	# cat ${MBROOT}/config/crontab.txt | cut -d',' -f2 | sudo sed -e 's/$/ #mixbox/g' >> /etc/crontab
}
