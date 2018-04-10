#!/bin/bash
#AUTOPXC by walt 
#ifconfig | grep 'inet' | awk '{ print $2}'|grep -v '^$'|sed '/\.1$/d'| grep -v ':'
echo "Hello everyone,Please mail me for any question at walt008@aliyun.com" #欢迎信息

nodeip=`ifconfig | grep 'inet' | cut -d: -f2 | awk '{ print $2}' | grep -v '^$' |sed '/\.1$/d'` #get localhost's ip.获取本机ip

echo "USER:$USER  TIME:`date +%Y-%m-%d\ %H:%M:%S` HOST:$HOSTNAME IP:$nodeip" #状态提示

echo "$nodeip $HOSTNAME" >> /etc/hosts #hosts  #输入hosts文件

#关闭selinux，防火墙打开pxc所需端口，或者取消注释直接关闭防火墙
sed -i s/"SELINUX=enforcing"/"SELINUX=disabled"/g /etc/selinux/config
setenforce 0 
#systemctl stop firewalld 
#systemctl disable firewalld 
#iptables -F
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --zone=public --add-port=4567/tcp --permanent
firewall-cmd --zone=public --add-port=4568/tcp --permanent
firewall-cmd --zone=public --add-port=4444/tcp --permanent
firewall-cmd --reload

datadir="" #mysql datadir

ErrMSG="Directory is exsit."
DstMSG="Enter the path of mysqldata directory.输入MySQL数据存放目录绝对路径："

#mysql data目录判断函数
function inputDstPath(){ 
while true
do
	echo $DstMSG
	read -p ":" datadir
	if [ -d $datadir ];then
	echo "$ErrMSG"	
	useradd -s /sbin/nologin mysql &>/dev/null
	chown mysql.mysql -R $datadir
	ls -l $datadir
		read -p "您输入的目录可能包含文件，是否清空目录？do you want to delete all files of $datadir,y/n? :" yn
		if [ "$yn" == "y" ];then
		rm -rf $datadir/*
		echo "del success!"
		break
        		else
		break     	
		fi
	break
	else
	mkdir -p $datadir
	useradd -s /sbin/nologin mysql &>/dev/null
	chown mysql.mysql -R $datadir
	ls -l $datadir
	break
	fi
done
}

#my.cnf配置文件生成函数
function makecnf(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19` #生成随机server-id

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l` #获取cpu罗辑核心数
cp /etc/my.cnf /etc/my.cnf.bak >/dev/null 2>&1

echo "[mysqld]
datadir=$datadir
socket = /tmp/mysql.sock
pid-file=$datadir/mysql.pid
character_set_server = utf8
max_connections = 3000
back_log= 3000
skip-name-resolve
sync_binlog=0
innodb_flush_log_at_trx_commit=1
server-id = $sid
default_storage_engine=Innodb
innodb_autoinc_lock_mode=2
binlog_format=row
wsrep_cluster_name=pxc_zs
wsrep_slave_threads=$cpun #开启的复制线程数，cpu核数*2
wsrep_cluster_address=gcomm://$nodeip,$node02,$node03
wsrep_node_address=$nodeip
wsrep_provider=/usr/local/mysql/lib/libgalera_smm.so
wsrep_sst_method=xtrabackup-v2 
wsrep_sst_auth=sst:zs
[client] #添加客户端套接字文件路径，防止无法登陆mysql
socket = /tmp/mysql.sock" > /etc/my.cnf 
echo $?
}

function makecnf2(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak &>/dev/null

echo "
[mysqld]
datadir=$datadir
socket = /tmp/mysql.sock
pid-file=$datadir/mysql.pid
character_set_server = utf8
max_connections = 3000
back_log= 3000
skip-name-resolve
sync_binlog=0
innodb_flush_log_at_trx_commit=1
server-id = $sid
default_storage_engine=Innodb
innodb_autoinc_lock_mode=2
binlog_format=row
wsrep_cluster_name=pxc_zs
wsrep_slave_threads=$cpun #开启的复制线程数，cpu核数*2
wsrep_cluster_address=gcomm://$node01ip,$nodeip,$node03
wsrep_node_address=$nodeip
wsrep_provider=/usr/local/mysql/lib/libgalera_smm.so
wsrep_sst_method=xtrabackup-v2 
wsrep_sst_auth=sst:zs
[client]
socket = /tmp/mysql.sock" > /etc/my.cnf

}

function makeall(){

read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx ，输入除第一节点和本机外其他所有节点ip地址，英文逗号隔开:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak &>/dev/null

echo "
[mysqld]
datadir=$datadir
socket = /tmp/mysql.sock
pid-file=$datadir/mysql.pid
character_set_server = utf8
max_connections = 3000
back_log= 3000
skip-name-resolve
sync_binlog=0
innodb_flush_log_at_trx_commit=1
server-id = $sid
default_storage_engine=Innodb
innodb_autoinc_lock_mode=2
binlog_format=row
wsrep_cluster_name=pxc_zs
wsrep_slave_threads=$cpun #开启的复制线程数，cpu核数*2
wsrep_cluster_address=gcomm://$node01ip,$nodeip,$allip
wsrep_node_address=$nodeip
wsrep_provider=/usr/local/mysql/lib/libgalera_smm.so
wsrep_sst_method=xtrabackup-v2 
wsrep_sst_auth=sst:zs
[client]
socket = /tmp/mysql.sock " > /etc/my.cnf

}


function makecnf3(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak &>/dev/null

echo "[mysqld]
datadir=$datadir
socket = /tmp/mysql.sock
pid-file=$datadir/mysql.pid
character_set_server = utf8
max_connections = 3000
back_log= 3000
skip-name-resolve
sync_binlog=0
innodb_flush_log_at_trx_commit=1
server-id = $sid
default_storage_engine=Innodb
innodb_autoinc_lock_mode=2
binlog_format=row
wsrep_cluster_name=pxc_zs
wsrep_slave_threads=$cpun #开启的复制线程数，cpu核数*2
wsrep_cluster_address=gcomm://$node01ip,$node02,$nodeip
wsrep_node_address=$nodeip
wsrep_provider=/usr/local/mysql/lib/libgalera_smm.so
wsrep_sst_method=xtrabackup-v2 
wsrep_sst_auth=sst:zs
[client]
socket = /tmp/mysql.sock " > /etc/my.cnf
}

#下载pxc安装包
function download(){
#directory-prefix=/root/
echo "downloading..."
if [ -e /root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz ];then
	echo "percona-xtrabackup-2.4.6 already exist"
else
wget -c -p /root/ https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.6/binary/tarball/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz && echo "download xtrabackup complete"
fi

if [ -e /root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz ];then
	echo "Percona-XtraDB-Cluster-5.6.26 already exist"
else
wget -c -p /root/ https://www.percona.com/downloads/Percona-XtraDB-Cluster-56/Percona-XtraDB-Cluster-5.6.26-25.12/binary/tarball/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz && echo "download XtraDB complete"
fi

}

#从第一节点复制安装包函数
function copy(){

read -p "Enter the IP of node01 ，输入第一节点ip地址:" node01ip
if [ -e /root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz -a -e /root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz ];then
	echo "xtrabackup and Percona-XtraDB-Cluster already exist"
else
echo "输入yes回车后输入第一节点root账户密码进行pxc安装包拷贝"
scp root@$node01ip:/root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz root@$node01ip:/root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz /root && echo "copy complete"
fi

}

#解压安装包函数
function tarfile(){

echo "tar...files..."
cd /usr/local && rm -f mysql

if [ -d percona-xtrabackup-2.4.6-Linux-x86_64 -a -d Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64 ];then
	echo "xtrabackup and PXC files already exist"
#rm -rf /root/percona-xtrabackup-2.4.6-Linux-x86_64
#rm -rf /root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64
else
tar xvf /root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz
tar xvf /root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz
fi
ln -s Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64 mysql
chown mysql.mysql -R mysql

cp percona-xtrabackup-2.4.6-Linux-x86_64/bin/* mysql/bin/

yum remove mariadb-* mysql-* -y #删除系统自带数据库

yum install perl-IO-Socket-SSL.noarch perl-DBD-MySQL.x86_64 perl-Time-HiRes openssl openssl-devel socat -y  #安装依赖包

ln -s /usr/lib64/libreadline.so.6 /lib64/libreadline.so.5 &>/dev/null
ln -s /usr/lib64/libcrypto.so.10 /lib64/libcrypto.so.6 &>/dev/null
ln -s /usr/lib64/libssl.so.10 /lib64/libssl.so.6 &>/dev/null

}

#数据库初始化函数
function installdb(){

echo "install mysql..."
echo "export PATH=$PATH:/usr/local/mysql/bin" > /etc/profile.d/mysql.sh && source /etc/profile.d/mysql.sh #添加环境变量

/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=$datadir --defaults-file=/etc/my.cnf --user=mysql && cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql

}

#数据库进程启动及账号授权
function mysqlv(){

if [ -e /etc/init.d/mysql ];then
	rm -rf /var/lock/subsys/mysql
	/etc/init.d/mysql bootstrap-pxc
	pxcstat=`/etc/init.d/mysql bootstrap-pxc`
	if [[ $pxcstat == *SUCCESS* ]];then
	echo -e "\033[32m MySQL Start SUCCESS! \033[1m"
	mysql -v -e " 
	delete from mysql.user where user!='root' or host!='localhost';
	grant all privileges on *.* to 'sst'@'%' identified by 'zs';
	grant all privileges on *.* to 'sst'@'localhost' identified by 'zs';
	flush privileges;
	quit"
		if [[ $? == 0 ]];then
	echo "mysql configure success,授权成功！"
	else
	echo "error"
	break
		fi
	else
	echo -e "\033[31m MySQL Start failed! \033[0m"
	tail $datadir/$HOSTNAME.err
	break
	fi
else
echo "/etc/init.d/mysql is not exsit,quit."
break
fi
}


function mysql2(){

if [ -f /etc/init.d/mysql ];then
	rm -rf /var/lock/subsys/mysql
	/etc/init.d/mysql start
	pxcstat=`/etc/init.d/mysql start`
	if [[ $pxcstat == *SUCCESS* ]];then
	echo -e "\033[32m MySQL Start SUCCESS! \033[1m"
	mysql -v -e "
	delete from mysql.user where user!='root' or host!='localhost';
	grant all privileges on *.* to 'sst'@'%' identified by 'zs';
	grant all privileges on *.* to 'sst'@'localhost' identified by 'zs';
	flush privileges;
	quit"
		if [[ $? == 0 ]];then
	echo "mysql configure success,授权成功！"
	else
	echo "error"
	break	
		fi
	else
	echo -e "\033[31m MySQL Start failed! \033[0m"
	tail $datadir/$HOSTNAME.err
	break
	fi
else
echo "/etc/init.d/mysql is not exsit,quit."
break
fi
}

#程序前台
while true
do

echo "*************************************************************"
cat << EOF
    1.node01，配置第一节点
    2.node02，配置第二节点
    3.node03，配置第三节点
    4.quit，退出程序
    5.更多节点配置，需要在hosts里手动添加主机名与ip映射。
    *Iuput the NO. of node，输入需要配置节点的序号。*
    完成所有节点配置后, 使用命令 show status like 'wsrep%';查看集群状态；
    若状态正常使用命令"mysql_secure_installation" 安全初始化集群。
EOF
echo "*************************************************************"

read -p "输入选项前面序号即可:" op

case $op in
	1)
	echo "master-node install，配置第一节点"
	read -p "enter the IP of node02，输入第二节点ip :" node02
	read -p "enter the hostname of node02 ，输入第二节点主机名:" hostname02
	echo "$node02 $hostname02" >> /etc/hosts
	read -p "enter the IP of node03 输入第三节点ip:" node03
	read -p "enter the hostname of node03 输入第三节点主机名:" hostname03
	echo "$node03 $hostname03" >> /etc/hosts
	inputDstPath
	download
	tarfile
	installdb
	makecnf
	mysqlv
	echo "mysql_secure_installation"
	break
	;;       
	2)
	echo "slave-node02 install，配置第二节点"
	inputDstPath
	copy
	read -p "enter the hostname of node01 ,输入第一节点主机名:" hostname01
	echo "$node01ip $hostname01" >> /etc/hosts
	read -p "enter the IP of node03，输入第三节点ip:" node03
	read -p "enter the hostname of node03，输入第三节点主机名 :" hostname03
	echo "$node03 $hostname03" >> /etc/hosts
	tarfile
	installdb
	makecnf2
	mysql2
	break
	;;
	3)
	echo "slave-node03 install，配置第三节点"
	inputDstPath
	copy
	read -p "enter the hostname of node01 ，输入第一节点主机名:" hostname01
	echo "$node01ip $hostname01" >> /etc/hosts
	read -p "enter the hostname of node02，输入第二节点主机名 :" hostname02	
	read -p "enter the IP of node02，输入第二节点ip:" node02
	echo "$node02 $hostname02" >> /etc/hosts
	tarfile
	installdb
	makecnf3
	mysql2
	break
	;;
	4|quit)
	echo "Exit..."
	break
	;;
	*)
	echo "slave-node install，配置更多节点，需要手动添加所有节点主机名与ip对应到hosts文件，非必须"
	inputDstPath
	copy
	tarfile
	installdb
	makeall
	mysql2
	break
	;;
	
esac
done

