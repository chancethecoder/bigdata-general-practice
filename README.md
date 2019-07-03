# 빅데이터 통합 실습 1조

아래 실습 내용을 정리합니다.

## Prequel

1. yum update
```bash
sudo yum update -y
```
2. change the run level to multi-user text mode
```bash
# https://askubuntu.com/questions/900985/how-can-i-simply-change-into-a-text-mode-runlevel-under-systemd
sudo systemctl isolate multi-user.target
sudo systemctl isolate runlevel3.target
```
3. disable SELinux
```bash
# https://www.lesstif.com/pages/viewpage.action?pageId=6979732
sudo vi /etc/sysconfig/selinux
# SELINUX=disabled
```
4. disable firewall
```bash
# https://linuxize.com/post/how-to-stop-and-disable-firewalld-on-centos-7/
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```
5. check vm.swappiness and update permanently as necessary.
```bash
# https://askubuntu.com/questions/103915/how-do-i-configure-swappiness
cat /proc/sys/vm/swappiness
# sudo sysctl vm.swappiness=1
sudo vi /etc/sysctl.conf # vm.swappiness=1 추가
```
6. disable transparent hugepage support permanently
```bash
# https://www.thegeekdiary.com/centos-rhel-7-how-to-disable-transparent-huge-pages-thp/
cat /sys/kernel/mm/transparent_hugepage/enabled
sudo vi /etc/default/grub # transparent_hugepage=never 내용 추가
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# sudo reboot
cat /proc/cmdline
```
7. check to see that nscd service is running
```bash
# http://gurukaybee.blogspot.com/2017/05/rhel7-install-nscd-name-service-cache.html
sudo yum install nscd -y
sudo systemctl start nscd
sudo systemctl enable nscd
sudo systemctl status nscd
```
8. check to see that ntp service is running (disable chrony as necessary)
```bash
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/s1-disabling_chrony
# https://www.manualfactory.net/10147
sudo systemctl stop chronyd
sudo systemctl disable chronyd
sudo yum install ntp -y
sudo systemctl start ntpd
sudo systemctl enable ntpd
```
9. disable IPV6
```bash
# https://linuxhint.com/disable_ipv6_centos7/
ip a | grep inet6
sudo vi /etc/default/grub # ipv6.disable=1 내용 추가
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# sudo reboot
ip a | grep inet6 # 아무것도 안나오면 성공
```
10. setup a private/public key
```bash
# 서버들을 미리 호스트에 등록하자
# 각 서버 접속되게 키생성 및 연결
ssh-keygen -t rsa
# 엔터 계속

# 아래 두개 파일이 생성됨. 파일을 각서버에 넣음
.ssh/id_rsa
.ssh/id_rsa.pub

# .ssh/id_rsa.pub 내용을 .ssh/authorized_keys에 추가
chmod 600 .ssh/id*
```
11. update /etc/hosts
```bash
# 각 노드 /etc/hosts 등록
# ip [tab] FQDN [tab] shortcut
# ex)
# 172.31.x.x    h1.my.prac h1
# 172.31.x.x    h2.my.prac h2
# 172.31.x.x    h3.my.prac h3
# 172.31.x.x    h4.my.prac h4
# 172.31.x.x    h5.my.prac h5
```
12. change each hostname
```bash
# 각 노드 hostname 변경
sudo vi /etc/hostname
sudo reboot

# 각 노드 known host에 다른 노드 추가
# ssh centos@h1
# ssh centos@h2
# ssh centos@h3
# ssh centos@h4
# ssh centos@h5
```

## Install CM

1. install jdk
```bash
sudo yum install wget -y

# Installing the JDK Manually
# https://www.cloudera.com/documentation/enterprise/5-15-x/topics/cdh_ig_jdk_installation.html#topic_29_1
# jdk를 local 다운로드 받아서 CM node에 복사
sudo mkdir /usr/lib/java
sudo tar xvfz /home/centos/jdk-8u202-linux-x64.tar.gz -C /usr/lib/java/

# JAVA 경로 지정
sudo vi /etc/profile
export JAVA_HOME=/usr/lib/java/jdk1.8.0_202
source /etc/profile
env | grep JAVA_HOME
```