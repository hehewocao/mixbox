#!/bin/sh -eu
#copyright by monlor
source /tmp/mixbox.conf
source ${MBROOT}/bin/base || exit 1

type=${1}
action=${2}

# if [ ! -f ${MBTMP}/mixbox_inited ]; then
#   loginfo "检查到mixbox未初始化！初始化中..."
#   ${MBROOT}/scripts/init.sh
# fi

list() {
  cat ${MBROOT}/config/${type}.txt | while read appname; do
    ${MBROOT}/scripts/appmanage.sh ${appname} ${action}
  done
}

array() {
  cat ${MBROOT}/config/${type}.txt | sed -n 1d | cut -d'|' -f1 | while read appname; do
    ${MBROOT}/scripts/appmanage.sh ${appname} ${action}
  done
}

case "${type}" in
  "firewall"|"watch") list ;;
  "applist") array ;;
esac