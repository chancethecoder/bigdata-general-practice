sudo yum update -y

# https://askubuntu.com/questions/900985/how-can-i-simply-change-into-a-text-mode-runlevel-under-systemd
sudo systemctl isolate multi-user.target
sudo systemctl isolate runlevel3.target

# https://www.lesstif.com/pages/viewpage.action?pageId=6979732
sudo vi /etc/sysconfig/selinux
# SELINUX=disabled

# https://linuxize.com/post/how-to-stop-and-disable-firewalld-on-centos-7/
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# https://askubuntu.com/questions/103915/how-do-i-configure-swappiness
cat /proc/sys/vm/swappiness
# sudo sysctl vm.swappiness=1
sudo vi /etc/sysctl.conf # vm.swappiness=1 추가

# https://www.thegeekdiary.com/centos-rhel-7-how-to-disable-transparent-huge-pages-thp/
cat /sys/kernel/mm/transparent_hugepage/enabled
sudo vi /etc/default/grub # transparent_hugepage=never 내용 추가
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# sudo reboot
cat /proc/cmdline

# http://gurukaybee.blogspot.com/2017/05/rhel7-install-nscd-name-service-cache.html
sudo yum install nscd -y
sudo systemctl start nscd
sudo systemctl status nscd

# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/s1-disabling_chrony
# https://www.manualfactory.net/10147
sudo systemctl stop chronyd
sudo systemctl disable chronyd
sudo yum install ntp -y
sudo systemctl start ntpd
sudo systemctl enable ntpd

# https://linuxhint.com/disable_ipv6_centos7/
ip a | grep inet6
sudo vi /etc/default/grub # ipv6.disable=1 내용 추가
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# sudo reboot
ip a | grep inet6 # 아무것도 안나오면 성공

# 서버들을 미리 호스트에 등록하자
# 각 서버 접속되게 키생성 및 연결
ssh-keygen -t rsa
# 엔터 계속

# 아래 두개 파일이 생성됨. 파일을 각서버에 넣음
.ssh/id_rsa
.ssh/id_rsa.pub

# .ssh/id_rsa.pub 내용을 .ssh/authorized_keys에 추가
chmod 600 .ssh/id*

# 각 노드 /etc/hosts 등록
# ip [tab] FQDN [tab] shortcut
# ex)
# 172.31.x.x    h1.my.prac h1
# 172.31.x.x    h2.my.prac h2
# 172.31.x.x    h3.my.prac h3
# 172.31.x.x    h4.my.prac h4
# 172.31.x.x    h5.my.prac h5

# 각 노드 hostname 변경
sudo vi /etc/hostname
sudo reboot

# 각 노드 known host에 다른 노드 추가
# ssh centos@h1
# ssh centos@h2
# ssh centos@h3
# ssh centos@h4
# ssh centos@h5