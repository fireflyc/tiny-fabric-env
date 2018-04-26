###简化Fabric开发环境
里面提供了一个dev.sh脚本

* dev.sh gen生成MSP证书和创世块
* dev.sh up启动容器
* dev.sh down停止并且删除所有容器（数据都保留在var目录中）
* dev.sh clean删除所有生成的MSP证书、创世块和var目录（相当于重新初始化）


使用方法
1. ./dev.sh gen生成证书
2. ./dev.sh up启动容器

创建Channel、配置ChainCode直接通过docker exec -it cli bash 命令进入到命令行工具进行操作。

注意：./dev.sh down不会清空数据，仅仅是把容器删掉。./dev.sh clean才会删数据