
start() {
  check_running ${binfile} && exit 1
  # 添加dnsmasq配置
  echo -e "srv-host=_vlmcs._tcp,XiaoQiang,1688,0,100\ndomain=lan" > ${MBTMP}/kms_dnsmasq.conf
  dnsmasq_add_config kms_dnsmasq.conf
  dnsmasq_reload
  # 添加防火墙规则
  write_firewall_start
  open_port ${port}
  # 启动程序
  daemon_start ${binfile} -l ${MBLOG}/${appname}.log
}

stop() {

  close_port ${port}
	remove_firewall_start
  dnsmasq_del_config kms_dnsmasq.conf
  dnsmasq_reload
	daemon_stop ${binfile}

}

status() {

  default_status ${binfile}

}