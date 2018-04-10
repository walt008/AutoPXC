#!/bin/bash
#AUTOPXC by walt 
#ifconfig | grep 'inet' | awk '{ print $2}'|grep -v '^$'|sed '/\.1$/d'| grep -v ':'
echo "Hello everyone,Please mail me for any question at walt008@aliyun.com"
nodeip=`ifconfig | grep 'inet' | cut -d: -f2 | awk '{ print $2}' | grep -v '^$' |sed '/\.1$/d'` #get localhost's ip.

echo "USER:$USER  TIME:`date +%Y-%m-%d\ %H:%M:%S` HOST:$HOSTNAME IP:$nodeip"

echo "$nodeip $HOSTNAME" >> /etc/hosts #hosts

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
DstMSG="Enter the path of mysqldata directory."

setenforce 0 
service firewall stop &>/dev/null
service iptables stop &>/dev/null
iptables -F

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
		read -p "do you want to delete all files of $datadir,y/n? :" yn
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


function makecnf(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
#cp /etc/my.cnf /etc/my.cnf.bak >/dev/null 2>&1

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
[client]
socket = /tmp/mysql.sock" > /etc/my.cnf 
}

function makecnf2(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
#cp /etc/my.cnf my.cnf.bak &>/dev/null

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

read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx :" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
#cp /etc/my.cnf my.cnf.bak &>/dev/null

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
wsrep_cluster_address=gcomm://$allip
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
#cp /etc/my.cnf my.cnf.bak &>/dev/null

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


function copy(){

read -p "Enter the IP of node01 :" node01ip
if [ -e /root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz -a -e /root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz ];then
	echo "xtrabackup and Percona-XtraDB-Cluster already exist"
else


scp root@$node01ip:/root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz root@$node01ip:/root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz /root && echo "copy complete"
fi

}


function tarfile(){

echo "tar...files"
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

yum remove mariadb-* mysql-* -y

yum install perl-IO-Socket-SSL.noarch perl-DBD-MySQL.x86_64 perl-Time-HiRes openssl openssl-devel socat -y

ln -s /usr/lib64/libreadline.so.6 /lib64/libreadline.so.5 &>/dev/null
ln -s /usr/lib64/libcrypto.so.10 /lib64/libcrypto.so.6 &>/dev/null
ln -s /usr/lib64/libssl.so.10 /lib64/libssl.so.6 &>/dev/null

}


function installdb(){

echo "install mysql..."

echo "export PATH=$PATH:/usr/local/mysql/bin" > /etc/profile.d/mysql.sh && source /etc/profile.d/mysql.sh

/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=$datadir --defaults-file=/etc/my.cnf --user=mysql && cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql

}


function mysqlv(){

if [ -e /etc/init.d/mysql ];then
	rm -rf /var/lock/subsys/mysql
	/etc/init.d/mysql bootstrap-pxc
	pxcstat=`/etc/init.d/mysql bootstrap-pxc`
	if [[ $pxcstat == *SUCCESS* ]];then
	echo -e "\033[32m MySQL Start SUCCESS! \033[1m"
	mysql -uroot -p'' -e " 
	delete from mysql.user where user!='root' or host!='localhost';
	grant all privileges on *.* to 'sst'@'%' identified by 'zs';
	grant all privileges on *.* to 'sst'@'localhost' identified by 'zs';
	flush privileges;
	quit"
	echo "oooook"
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
	echo "oooook"
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


while true
do

echo "*************************************************************"
cat << EOF
    1.node01
    2.node02
    3.node03 or more
    4.quit
    *iuput the NO. of machine*
    When finish all machines,login mysql of node01, 
    Use "show status like 'wsrep%';" check Cluster state,
    If state is ok, use "mysql_secure_installation" secure the Cluster.
EOF
echo "*************************************************************"

read -p ":" op

case $op in
	1)
	echo "master-node install"
	read -p "enter the IP of node02 :" node02
	read -p "enter the hostname of node02 :" hostname02
	echo "$node02 $hostname02" >> /etc/hosts
	read -p "enter the IP of node03 :" node03
	read -p "enter the hostname of node03 :" hostname03
	echo "$node03 $hostname03" >> /etc/hosts
	inputDstPath	
	download
	tarfile
	installdb
	makecnf
	mysqlv
	break
	;;       
	2)
	echo "slave-node02 install"
	inputDstPath
	copy
	read -p "enter the hostname of node01 :" hostname01
	echo "$node01ip $hostname01" >> /etc/hosts
	read -p "enter the IP of node03 :" node03
	read -p "enter the hostname of node03 :" hostname03
	echo "$node03 $hostname03" >> /etc/hosts
	tarfile
	installdb
	makecnf2
	mysql2
	break
	;;
	3)
	echo "slave-node03 install"
	inputDstPath
	copy
	read -p "enter the hostname of node01 :" hostname01
	echo "$node01ip $hostname01" >> /etc/hosts
	read -p "enter the hostname of node02 :" hostname02	
	read -p "enter the IP of node02 :" node02
	echo "$node02 $hostname02" >> /etc/hosts
	tarfile
	installdb
	mysql2
	makecnf3
	break
	;;
	4|quit)
	echo "Exit..."
	break
	;;
	*)
	echo "slave-node install"
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

