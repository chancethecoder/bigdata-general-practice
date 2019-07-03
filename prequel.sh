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
sudo sysctl vm.swappiness=1

# https://www.thegeekdiary.com/centos-rhel-7-how-to-disable-transparent-huge-pages-thp/
cat /sys/kernel/mm/transparent_hugepage/enabled
vi /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# sudo reboot
cat /proc/cmdline

# http://gurukaybee.blogspot.com/2017/05/rhel7-install-nscd-name-service-cache.html
sudo yum install nscd
sudo systemctl start nscd
sudo systemctl status nscd

# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/s1-disabling_chrony
# https://www.manualfactory.net/10147
sudo systemctl stop chronyd
sudo systemctl disable chronyd
sudo yum install ntp
sudo systemctl start ntpd
sudo systemctl enable ntpd

# https://linuxhint.com/disable_ipv6_centos7/
ip a | grep inet6
sudo vi /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# sudo reboot
ip a | grep inet6 # 아무것도 안나오면 성공