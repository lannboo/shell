#!/bin/bash 
MYSQL=/usr/local/mysql/bin/mysql
MYSQL_HOST=localhost 
MYSQL_USER=root 
MYSQL_PASSWORD=tianyun
CHECK_TIME=3

#mysql  is working MYSQL_OK is 1 , mysql down MYSQL_OK is 0 
MYSQL_OK=1
 
check_mysql_helth (){ 
    $MYSQL -h $MYSQL_HOST -u $MYSQL_USER -p${MYSQL_PASSWORD} -e "show status" &>/dev/null 
    if [ $? -eq 0 ] ;then 
    	MYSQL_OK=1
    else 
    	MYSQL_OK=0 
    fi 
    return $MYSQL_OK 
}
 
while [ $CHECK_TIME -ne 0 ]
do 
    check_mysql_helth 
	if [ $MYSQL_OK -eq 1 ] ; then 
    		exit 0 
	fi
 
	if [ $MYSQL_OK -eq 0 ] &&  [ $CHECK_TIME -eq 1 ];then
     		/etc/init.d/keepalived stop					
     		exit 1								
 	fi										
	let CHECK_TIME--
 	sleep 1 
done
