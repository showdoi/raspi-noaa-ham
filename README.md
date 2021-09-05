![Raspberry NOAA](assets/header_1600_v2.png)


# 由  jekhokie/raspberry-noaa-v2 创建
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
#得到一个十六进制数，这个数字反映了和当前系统频率、输入电压等相关的状态信息
#throttled=0x50005（供电不足）
#throttled=0x0（供电可以）
#这个数字的第 0 位为 1 的话，表明当前发生了输入电压不足的情况；
#这个数字的第 16 位为 1 的话，表明启动之后曾经发生过输入电压不足的情况；
```bash
vcgencmd get_throttled
```
2、测试收听FM   104.2更改为本地最强FM频率  树莓派接上音响或者耳机
```bash
rtl_fm -f 104.2M  -g 7.7 -s 200K -r 48000 -| ffplay -f s16le -ar 48000  -showmode 1 -i -
```
3、按照自己config/settings.yml 做接收测试
```bash
cd /home/pi/raspberry-noaa-v2/scripts/testing
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
/home/pi/raspberry-noaa-v2/scripts/schedule.sh -t -x 
```
1. Fork the repository to your own GitHub account.
2. `git clone` your forked repository.
3. `git checkout -b <my-branch-name>` to create a branch, replacing with your actual branch name.
4. Do some awesome feature development or bug fixes, committing to the branch regularly.
5. `git push origin <my-branch-name>` to push your branch to your forked repository.
6. Head back to the upstream `jekhokie/raspberry-noaa-v2` repository and submit a pull request using your branch from your forked repository.
7. Provide really good details on the development you've done within the branch, and answer any questions asked/address feedback.
8. Profit when you see your pull request merged to the upstream master and used by the community!

Make sure you keep your forked repository up to date with the upstream `jekhokie/raspberry-noaa-v2` master branch as this will make
development and addressing merge conflicts MUCH easier in the long run.

Happy coding (and receiving)!
