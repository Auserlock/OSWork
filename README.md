# OSWork

.
├── Bochs               Bochs虚拟机
│   ├── a.img               挂载镜像，挂载在/mnt/img
│   ├── bochsrc.txt         bochs配置文件
│   └── mount.sh            挂载loader.bin文件脚本
├── boot.asm            FAT16文件系统，启动引导盘
├── boot.bin
├── README.md
└── src                 源代码目录
    ├── OSLib.inc           显示函数定义
    ├── OSWork.inc          常量，宏定义
    └── Task.asm            项目源文件

