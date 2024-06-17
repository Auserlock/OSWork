#!/bin/zsh
#挂载a.img并复制可运行文件
sudo mount a.img /mnt/img -t vfat -o loop
sudo rm -rf /mnt/img/loader.bin
sudo cp ./loader.bin /mnt/img/
sudo sync
sudo umount /mnt/img
