#!/bin/bash

rm -rf mixbox mixbox.tar.gz

mkdir mixbox
cp -rf bin config lib scripts mixbox
tar zcvf mixbox.tar.gz mixbox
rm -rf mixbox
mv -f mixbox.tar.gz binfiles/mixbox