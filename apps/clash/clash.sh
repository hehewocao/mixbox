
insert_line() {
  pc_insert_prev "^proxies:$" "${1}" ${MBROOT}/apps/clash/config.yaml
}

start() {
  check_running ${binfile} && exit 1
  assert_nil subscribe_url && exit 1
  loginfo "下载订阅配置:${subscribe_url}..."
  wgetsh ${MBROOT}/apps/clash/config.yaml ${subscribe_url} || exit 1
  loginfo "生成配置文件..."
  linenum=`cat ${MBROOT}/apps/clash/config.yaml | awk '/^proxies:$/{print NR}'`
  pc_delete_line "1" "$((linenum-1))" ${MBROOT}/apps/clash/config.yaml
  # [ "${tun_enabled}" -eq 1 ] && tun_enabled="true" || tun_enabled="false"
  insert_line "---"
  insert_line "port: 7890"           # HTTP代理端口
  insert_line "socks-port: 7891"     # SOCKS5代理端口
  insert_line "mixed-port: 8888"     # HTTP&SOCKS5代理二合一端口
  insert_line "redir-port: 7892"     # Redir模式代理端口
  insert_line "allow-lan: true"      # 允许局域网连接
  insert_line "mode: Rule"           # 默认代理模式，可在网页调试页面更换
  insert_line "log-level: info"      # 日志级别 silent / info / warning / error / debug
  insert_line "external-controller: '0.0.0.0:9999'"                                # 网页调试端口
  insert_line "secret: ''"           # 网页调试密码，默认为空
  insert_line "ipv6: false"
  insert_line "external-ui: ui"
  if [ "${fake_ip_enabled}" -eq 1 ]; then
    insert_line "dns: {enable: true, listen: 0.0.0.0:1053, fake-ip-range: 198.18.0.1/16, enhanced-mode: fake-ip, nameserver: [114.114.114.114, 127.0.0.1:53], fallback: [tcp://1.0.0.1, 8.8.4.4]}"
  else
    insert_line "dns: {enable: true, ipv6: true, listen: 0.0.0.0:1053, enhanced-mode: redir-host, nameserver: [114.114.114.114, 223.5.5.5], fallback: [1.0.0.1, 8.8.4.4]}"
  fi
  insert_line "tun: {enable: true, stack: system}"                              #Tun模式设置
  insert_line "experimental: {ignore-resolve-fail: true, interface-name: en0}"   #实验性功能，尽量不要改动
  
  if [ ! -d ${MBROOT}/apps/${appname}/ui ]; then
    loginfo "安装本地面板..."
    wgetsh ${MBTMP}/clashdb.tar.gz ${MBINURL}/${appname}/clashdb.tar.gz || exit 1
    mkdir ${MBROOT}/apps/${appname}/ui
    tarsh ${MBTMP}/clashdb.tar.gz ${MBROOT}/apps/${appname}/ui || rm -rf ${MBROOT}/apps/${appname}/ui
    pc_replace "9090" "9999" ${MBROOT}/apps/${appname}/ui/js/*.js
  fi
  pc_replace "127.0.0.1" "${LANIP}" ${MBROOT}/apps/${appname}/ui/js/*.js

  # 添加防火墙规则
  # write_firewall_start
  # open_port ${port}
  # 启动程序
  loginfo "启动${appname}主程序..."
  daemon_start ${binfile} -d ${MBROOT}/apps/${appname}
  
  loginfo "写入nat规则..."
  #允许tun网卡接受流量
	iptables -I FORWARD -o utun -j ACCEPT
	#设置dns转发
	iptables -t nat -N clash_dns
	iptables -t nat -A clash_dns -p udp --dport 53 -j REDIRECT --to 1053
	iptables -t nat -A PREROUTING -p udp -j clash_dns
}

stop() {

  # close_port ${port}
	# remove_firewall_start
  # dnsmasq_reload
  iptables -D FORWARD -o utun -j ACCEPT &> /dev/null
  iptables -t nat -D PREROUTING -p tcp -j clash &> /dev/null
	iptables -t nat -D PREROUTING -p udp -j clash_dns &> /dev/null
	iptables -t nat -F clash &> /dev/null
	iptables -t nat -X clash &> /dev/null
	iptables -t nat -F clash_dns &> /dev/null
	iptables -t nat -X clash_dns &> /dev/null

	daemon_stop ${binfile}

}

status() {

  default_status ${binfile}

}