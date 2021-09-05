![Raspberry NOAA](assets/header_1600_v2.png)


**根据  jekhokie/raspberry-noaa-v2 分支创建的，根据自己的理解和需求做了改动，不保证你设备可用。**




```bash
# 树莓派系统更新时区，扩展硬盘，选择语言等操作
sudo raspi-config

# 安装 git
sudo apt-get -y install git

# 下载程序到本地
cd $HOME
git clone https://github.com/showdoi/raspi-noaa-ham.git
cd raspi-noaa-ham

# 拷贝模板 sample settings 
# 编辑改动自己的设置
cp config/settings.yml.sample config/settings.yml
nano config/settings.yml

# 开始安装和升级程序
./install_and_upgrade.sh
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
