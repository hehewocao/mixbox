#!/bin/sh -eu
#copyright by monlor
source /tmp/mixbox.conf
source ${MBROOT}/bin/base

file=${1}
action=${2}

if [ ! -f ${MBTMP}/mixbox_inited ]; then
  loginfo "检查到mixbox未初始化！初始化中..."
  ${MBROOT}/scripts/init.sh
fi

cat ${MBROOT}/config/${file} | while read appname; do
  ${MBROOT}/scripts/appmanage.sh ${appname} ${action}
done