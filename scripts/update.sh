#!/bin/sh -eu
#copyright by monlor
source /tmp/mixbox.conf
source ${MBROOT}/bin/base

loginfo "正在更新工具箱程序... "
rm -rf ${MBTMP}/mixbox.tar.gz
rm -rf ${MBTMP}/mixbox
wgetsh "${MBTMP}/mixbox.tar.gz" "$MBINURL/${APPNAME}/mixbox.tar.gz" || exit 1

loginfo "解压工具箱文件"
tarsh ${MBTMP}/mixbox.tar.gz ${MBTMP} 

# 清除不用更新的文件
rm -rf ${MBTMP}/mixbox/config/mixbox.conf
rm -rf ${MBTMP}/mixbox/config/menu.txt
cp -rf ${MBTMP}/mixbox/* ${MBROOT}/

loginfo "赋予可执行权限"
chmod -R +x ${MBROOT}

#删除临时文件
rm -rf ${MBTMP}/mixbox.tar.gz
rm -rf ${MBTMP}/mixbox