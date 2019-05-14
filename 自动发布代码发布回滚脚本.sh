#!/bin/bash
#Data:2018/6/28
#tomcat
# chkconfig: - 85 15
#description: tomcat
. /etc/init.d/functions
## test
TEST=ytsf_tomcat
test_path=/mnt/work/Test_check
start_user=root
update_path=/mnt/test_ytsf
project=ROOT
test(){
tomcat_name=$TEST
tomcat_home=$test_path/$tomcat_name
}
start(){
uppid=`/bin/ps -ef|grep java|grep $tomcat_home/|awk '{print $2}'`
[ -n "$uppid" ] && {
echo "$tomcat_name is running."
exit 1
}
/bin/su - $start_user -c "$tomcat_home/bin/startup.sh" >/dev/null
[ "$?" == "0" ] && action $"Staring $tomcat_name: " /bin/true \
|| action $"Starting $tomcat_name: " /bin/false
}
stop(){
/bin/su - $start_user -c "$tomcat_home/bin/shutdown.sh -force" >/dev/null
killpid=`/bin/ps -ef|grep java|grep $tomcat_home/|awk '{print $2}'`
/bin/rm -rf $tomcat_home/work/*
if [ ! -n "$killpid" ]
then [ "$?" == "0" ] && action $"Stoping $tomcat_name: " /bin/true \
|| action $"Stoping $tomcat_name: " /bin/false
else /bin/kill -9 $killpid && [ "$?" == "0" ] && action $"Stoping $tomcat_name: " /bin/true \
|| action $"Stoping $tomcat_name: " /bin/false
fi
}
status(){
pid=`/bin/ps -ef|grep java|grep $tomcat_home/|awk '{print $2}'`
port=`/bin/cat $tomcat_home/conf/server.xml|grep "Connector port"|grep HTTP|awk '{print $2}'|awk -F= '{print $2}'|sed 's/\"//g'`
url="/usr/bin/curl http://localhost:$port/jsp/login.jsp"
tmpfile=/tmp/tmpfile.txt
$url > $tmpfile /dev/null 2>&1
true=`cat $tmpfile|grep "商城后台管理系统"`
if [ -n "$pid" -a -n "$true" ]
then echo "$tomcat_name is running."
else echo "$tomcat_name is not running.(如果pid存在，可能是进程挂死!!)"
fi
/bin/rm -rf $tmpfile
read -p "Do you need tail -f catalina.out ? [ Y/y or N/n ] : " ANSWER
if [ "$ANSWER" = "Y" -o "$ANSWER" = "y" ] ; then
/usr/bin/tail -f $tomcat_home/logs/catalina.out;
elif [ "$ANSWER" = "N" -o "$ANSWER" = "n" ] ; then
exit 1;
else
echo "输入错误,并退出(!Input error,and exit!)"
exit 1;
fi
}
log(){
/usr/bin/tail -f $tomcat_home/logs/catalina.out
}
ps(){
/bin/ps -ef|grep java|grep $tomcat_home/
}
###### END
###### update tomcat
update(){
if [ -f $update_path/* ] ; then
#清理web目录
if [ -d $update_path/web ]; then
rm -rf $update_path/web
else
war=`ls $update_path/*war`
gz=`ls $update_path/*gz`
if [ -n "$war" ] ;then
/usr/bin/unzip -o $update_path/*.war -d $update_path/web/
elif [ -n "$gz" ] ; then
mkdir -p $update_path/web/
/bin/tar zxvf $gz -C $update_path/web/
fi
/bin/rm -rf $update_path/web/static/uploads
if [ ! -d /mnt/backup/$tomcat_name/ ];then
mkdir -p /mnt/backup/$tomcat_name/
fi
cd $tomcat_home/webapps/
/bin/tar -zcvf /mnt/backup/$tomcat_name/${tomcat_name}_`date +%F_%H-%M-%S`.tar.gz $project/ --exclude=uploads
if [ ! -d /mnt/nick/tmp/$tomcat_name/ ];then
mkdir -p /mnt/nick/tmp/$tomcat_name/
fi
/bin/cp -rf $tomcat_home/webapps/$project/WEB-INF/classes/{*.properties,*.jks,*.xml} /mnt/nick/tmp/$tomcat_name/
/bin/rm -rf $tomcat_home/{work/*,webapps/$project/WEB-INF/lib/*,webapps/$project/WEB-INF/classes/*}
/bin/chown -R ${start_user}.${start_user} $update_path/web/
/usr/bin/rsync -vzrtopg --progress $update_path/web/ $tomcat_home/webapps/$project/
/bin/cp -rf /mnt/nick/tmp/$tomcat_name/* $tomcat_home/webapps/$project/WEB-INF/classes/
/bin/rm -rf /mnt/nick/tmp/$tomcat_name/
fi
if [ ! -d /mnt/backup/$tomcat_name/ ];then
mkdir -p /mnt/backup/$tomcat_name/
fi
cd $tomcat_home/webapps/
/bin/tar -zcvf /mnt/backup/$tomcat_name/${tomcat_name}_`date +%F_%H-%M-%S`.tar.gz $project/ --exclude=uploads
if [ ! -d /mnt/nick/tmp/$tomcat_name/ ];then
mkdir -p /mnt/nick/tmp/$tomcat_name/
fi
/bin/cp -rf $tomcat_home/webapps/$project/WEB-INF/classes/{*.properties,*.jks,*.xml} /mnt/nick/tmp/$tomcat_name/
/bin/rm -rf $tomcat_home/{work/*,webapps/$project/WEB-INF/lib/*,webapps/$project/WEB-INF/classes/*}
/bin/chown -R ${start_user}.${start_user} $update_path/web/
/usr/bin/rsync -vzrtopg --progress $update_path/web/ $tomcat_home/webapps/$project/
/bin/cp -rf /mnt/nick/tmp/$tomcat_name/* $tomcat_home/webapps/$project/WEB-INF/classes/
/bin/rm -rf /mnt/nick/tmp/$tomcat_name/
fi
exit 0;
}
version(){
cd $update_path/
/bin/tar zcvf /mnt/backup/version/test/${tomcat_name}_`date +%F_%H-%M-%S`.tar.gz ./*
/bin/rm -rf $update_path/*
}
###### END
case "$1" in
test)
test
;;
*)
echo $"{Usage 1: $0 {test} {start|stop|status|restart|update|log|ps}"
esac
#if [ "$1" = mall -o "$1" = mall1 -o "$1" = admin -o "$1" = admin1 ];then
if [ "$1" = test ];then
case "$2" in
start)
start
;;
stop)
stop
;;
restart)
stop
start
;;
status)
status
;;
log)
log
;;
update)
stop
update
start
version
;;
version)
version
;;
ps)
ps
;;
*)
echo $"{Usage 1: $0 {test} {start|stop|status|restart|update|log|ps}"
esac
fi