![Raspberry NOAA](assets/header_1600_v2.png)


# 根据jekhokie/raspberry-noaa-v2 源码更改创建
# 根据自己的理解和需求做了改动，不保证你设备可用。

```bash
# 1、树莓派系统更新时区，扩展硬盘，选择语言等操作
sudo raspi-config

# 2、安装 git
sudo apt-get -y install git

# 3、下载程序到本地
cd $HOME
git clone https://github.com/showdoi/raspi-noaa-ham.git
cd raspi-noaa-ham

# 4、拷贝模板 sample settings 
# 5、编辑改动自己的设置
cp config/settings.yml.sample config/settings.yml
nano config/settings.yml

# 6、开始安装和升级程序
./install_and_upgrade.sh
```

# 分享几个基础测试

1、测试树莓派供电（rtl-fm）接收工作时检查供电问题
`throttled=0x50005（供电不足）`
`throttled=0x0（供电可以）`
```bash
vcgencmd get_throttled
```
2、测试收听FM 只更改`104.2M`更改为本地最强FM频率  树莓派接上音响或者耳机
```bash
rtl_fm -f 104.2M  -g 7.7 -s 200K -r 48000 -| ffplay -f s16le -ar 48000  -showmode 1 -i -
```
3、按照自己config/settings.yml 做接收测试
```bash
cd /home/pi/raspi-noaa-ham/scripts/testing
./test_reception.sh 104.2
```
4、测试PPM
```bash
rtl_test -p 
```
5、更新卫星列表
-t: 更新/重新下载 TLE 文件
-x：擦除所有现有的未来预定捕获并重新开始
```bash
/home/pi/raspi-noaa-ham/scripts/schedule.sh -t -x 
```
--------------------------------------------------------------------------------------------------
1. 新增业余卫星中继下行音频接收录音包含（ISS_FM_RPT 音频录音 新增so-50音频录音）
2. 新增ISS_sstv解码

