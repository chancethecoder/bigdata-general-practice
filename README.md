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
sudo vi /etc/sysconfig/selinux # SELINUX=disabled 수정
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
sudo vi /etc/sysctl.conf # vm.swappiness=1 추가
```
6. disable transparent hugepage support permanently
```bash
# https://www.thegeekdiary.com/centos-rhel-7-how-to-disable-transparent-huge-pages-thp/
cat /sys/kernel/mm/transparent_hugepage/enabled
sudo vi /etc/default/grub # transparent_hugepage=never 내용 추가
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot
cat /proc/cmdline # 
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

### Install JDK 1.8 (All nodes)

1. install jdk
```bash
# Installing the JDK Manually
# https://www.cloudera.com/documentation/enterprise/5-15-x/topics/cdh_ig_jdk_installation.html#topic_29_1
# jdk를 local 다운로드 받아서 각 노드에 복사
sudo mkdir -p /usr/java
sudo tar xvfz /home/centos/jdk-8u202-linux-x64.tar.gz -C /usr/java/
```
2. setup java path
```bash
# JAVA 경로 지정
sudo vi /etc/profile # export JAVA_HOME=/usr/java/jdk1.8.0_202 추가
source /etc/profile
env | grep JAVA_HOME
# JAVA_HOME 출력되면 성공
```

### Install Database

1. install mariadb server
```bash
# https://www.cloudera.com/documentation/enterprise/latest/topics/install_cm_mariadb.html
# https://linuxize.com/post/install-mariadb-on-centos-7/
# mariadb install
sudo yum install mariadb-server
sudo systemctl stop mariadb

ll /var/lib/mysql/
sudo rm -f /var/lib/mysql/ib_logfile*
```
2. configura mariadb server
```bash
sudo vi /etc/my.cnf
```
```conf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
symbolic-links = 0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

key_buffer = 16M
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

max_connections = 550
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space.
#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
#system and chown the specified folder to the mysql user.
log_bin=/var/lib/mysql/mysql_binary_log

#In later versions of MariaDB, if you enable the binary log and do not set
#a server_id, MariaDB will not start. The server_id must be unique within
#the replicating group.
server_id=1

binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
```
3. start mariadb and setup mariadb secure
```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo mysql_secure_installation

# 순서대로 입력
# 1. enter
# 2. Y, root 패스워드
# 3. Y
# 4. N
# 5. Y
# 6. Y
```
4. install the MySQL JDBC Driver for MariaDB (All nodes)
```bash
# https://www.cloudera.com/documentation/enterprise/5-15-x/topics/install_cm_mariadb.html
# https://dev.mysql.com/downloads/connector/j/5.1.html에서 파일 다운로드 후 각 노드에 복사
sudo mkdir -p /usr/share/java/
tar xvf mysql-connector-java-5.1.47.tar.gz
sudo cp mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar /usr/share/java/mysql-connector-java.jar
sudo ls /usr/share/java/
```
5. create Databases for Cloudera Software
```bash
mysql -u root -p
```
```sql
-- services
-- Cloudera Manager Server	scm	scm
-- Activity Monitor	amon	amon
-- Reports Manager	rman	rman
-- Hue	hue	hue
-- Hive Metastore Server	metastore	hive
-- Sentry Server	sentry	sentry
-- Cloudera Navigator Audit Server	nav	nav
-- Cloudera Navigator Metadata Server	navms	navms
-- Oozie	oozie	oozie

CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'scm';
GRANT ALL ON amon.* TO 'amon'@'%' IDENTIFIED BY 'amon';
GRANT ALL ON rman.* TO 'rman'@'%' IDENTIFIED BY 'rman';
GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'hue';
GRANT ALL ON metastore.* TO 'hive'@'%' IDENTIFIED BY 'hive';
GRANT ALL ON sentry.* TO 'sentry'@'%' IDENTIFIED BY 'sentry';
GRANT ALL ON nav.* TO 'nav'@'%' IDENTIFIED BY 'nav';
GRANT ALL ON navms.* TO 'navms'@'%' IDENTIFIED BY 'navms';
GRANT ALL ON oozie.* TO 'oozie'@'%' IDENTIFIED BY 'oozie';

SHOW DATABASES;
SHOW GRANTS FOR 'hive'@'%';
```

### Start CM

1. preparing the Cloudera Manager Server Database
```bash
sudo /usr/share/cmf/schema/scm_prepare_database.sh mysql scm scm
sudo rm /etc/cloudera-scm-server/db.mgmt.properties
```
2. start Cloudera Manager Server
```bash
sudo systemctl start cloudera-scm-server
```
3. observe the startup process
```bash
sudo tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log

# 아래 로그가 보인다면 성공
# INFO WebServerImpl:com.cloudera.server.cmf.WebServerImpl: Started Jetty server.
```
4. in a web browser, go to http://<server_host>:7180

### CM configuration

1. 역할 할당 사용자 지정하기
2. 데이터베이스 설정 - 호스트, 데이터베이스, 유저, 패스워드 입력 - 테스트 연결