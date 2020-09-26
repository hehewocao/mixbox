#!/bin/bash

# 打包工具箱
rm -rf mixbox mixbox.tar.gz

mkdir mixbox
cp -rf bin config lib scripts mixbox
tar zcvf mixbox.tar.gz mixbox
rm -rf mixbox
mv -f mixbox.tar.gz binfiles/mixbox

# 打包插件
cd apps
for appname in `ls`; do
  tar zcvf ${appname}.tar.gz ${appname}
  mv -f ${appname}.tar.gz ../binfiles/${appname}
done