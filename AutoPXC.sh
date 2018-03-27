#!/bin/bash
#AUTOPXC by walt 
#ifconfig | grep 'inet' | awk '{ print $2}'|grep -v '^$'|sed '/\.1$/d'| grep -v ':'

nodeip=`ifconfig | grep 'inet' | cut -d: -f2 | awk '{ print $2}' | grep -v '^$' |sed '/\.1$/d'` #get localhost's ip.

echo "USER:$USER  TIME:`date +%Y-%m-%d\ %H:%M:%S` HOST:$HOSTNAME IP:$nodeip"

echo "$nodeip $HOSTNAME" >> /etc/hosts #ke xuan

datadir="" #mysql basedir

ErrMSG="Directory is exsit."
DstMSG="Enter the path of mysqldata directory."

function inputDstPath(){

	echo $DstMSG
	read -p ":" datadir
	if [ -d $datadir ];then
	echo "$ErrMSG"	
	useradd -s /sbin/nologin mysql >/dev/null &>1
	chown mysql.mysql -R $datadir
	ll $datadir
	else
	mkdir -p $datadir
	useradd -s /sbin/nologin mysql >/dev/null &>1
	chown mysql.mysql -R $datadir
	ll $datadir
	fi
}

function makecnf(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak > /dev/null &>1

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
wsrep_cluster_address=gcomm://$nodeip,$node02,$node03
wsrep_node_address=$nodeip
wsrep_provider=/usr/local/mysql/lib/libgalera_smm.so
wsrep_sst_method=xtrabackup-v2 
wsrep_sst_auth=sst:zs " > /etc/my.cnf

}

function makecnf2(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak > /dev/null &>1

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
wsrep_sst_auth=sst:zs " > /etc/my.cnf

}

function makeall(){

read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx :" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak > /dev/null &>1

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
wsrep_sst_auth=sst:zs " > /etc/my.cnf

}


function makecnf3(){

#read -p "Enter the IP of all the nodes,like 192.168.xxx.xxx,192.168.xxx.xxx,192.168.xxx.xxx:" allip
#read -p "input server-id like 1,2,3...,make sure every machine difference:" sid

sid=`date +%s%N | cut -c17-19`

cpun=`cat /proc/cpuinfo| grep "processor"| wc -l`
cp /etc/my.cnf my.cnf.bak > /dev/null &>1

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
wsrep_cluster_address=gcomm://$node01ip,$node02,$nodeip
wsrep_node_address=$nodeip
wsrep_provider=/usr/local/mysql/lib/libgalera_smm.so
wsrep_sst_method=xtrabackup-v2 
wsrep_sst_auth=sst:zs " > /etc/my.cnf

}



function download(){

echo "downloading..."
if [ -f percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz ];then
	echo "percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz is exsit"
else
wget -c https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.6/binary/tarball/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz && echo "download xtrabackup complete"
fi
if [ -f Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz ];then
	echo "Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz is exsit"
else
wget -c https://www.percona.com/downloads/Percona-XtraDB-Cluster-56/Percona-XtraDB-Cluster-5.6.26-25.12/binary/tarball/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz && echo "download XtraDB complete"
fi
}



function copy(){

read -p "Enter the IP of node01 :" node01ip

scp root@$node01ip:/root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz root@$node01ip:/root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz /root && echo "copy complete"

}

function tarfile(){

cd /usr/local && rm -f mysql
rm -rf percona-xtrabackup-2.4.6-Linux-x86_64
rm -rf Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64

tar xvf /root/percona-xtrabackup-2.4.6-Linux-x86_64.tar.gz
tar xvf /root/Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64.tar.gz && ln -s Percona-XtraDB-Cluster-5.6.26-rel74.0-25.12.1.Linux.x86_64 mysql
chown mysql.mysql -R mysql
cp percona-xtrabackup-2.4.6-Linux-x86_64/bin/* mysql/bin/

yum remove mariadb-* -y >/dev/null &>1

yum install perl-IO-Socket-SSL.noarch perl-DBD-MySQL.x86_64 perl-Time-HiRes openssl openssl-devel socat -y

ln -s /usr/lib64/libreadline.so.6 /lib64/libreadline.so.5 >/dev/null &>1
ln -s /usr/lib64/libcrypto.so.10 /lib64/libcrypto.so.6 >/dev/null &>1
ln -s /usr/lib64/libssl.so.10 /lib64/libssl.so.6 >/dev/null &>1

}


function installdb(){

echo "export PATH=$PATH:/usr/local/mysql/bin" > /etc/profile.d/mysql.sh && source /etc/profile.d/mysql.sh

/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=$datadir --defaults-file=/etc/my.cnf --user=mysql && cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql

}

function mysqlv(){

if [ -f /etc/init.d/mysql ];then
	/etc/init.d/mysql bootstrap-pxc
	pxcstat=`/etc/init.d/mysql bootstrap-pxc`
	if [ "$pxcstat" == "*SUCCESS*" ];then
	mysql -v
	delete from mysql.user where user!='root' or host!='localhost';
	grant all privileges on *.* to 'sst'@'%' identified by 'zs';
	grant all privileges on *.* to 'sst'@'localhost' identified by 'zs';
	flush privileges;
	quit;
	else
	break
	fi
else
echo "/etc/init.d/mysql is not exsit,quit."
break
fi
}

function mysql2(){

if [ -f /etc/init.d/mysql ];then
	/etc/init.d/mysql start
	pxcstat=`/etc/init.d/mysql start`
	if [ "$pxcstat" == "*SUCCESS*" ];then
	mysql -v
	delete from mysql.user where user!='root' or host!='localhost';
	grant all privileges on *.* to 'sst'@'%' identified by 'zs';
	grant all privileges on *.* to 'sst'@'localhost' identified by 'zs';
	flush privileges;
	quit;
	else
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
	makecnf
	download
	tarfile
	installdb
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
	makecnf2
	tarfile
	installdb
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
	makecnf3
	tarfile
	installdb
	mysql2
	break
	;;
	*)
	echo "slave-node install"
	inputDstPath
	copy
	makeall
	tarfile
	installdb
	mysql2
	break
	;;
	4|quit)
	echo "Exit..."
	break
	;;
esac
done

