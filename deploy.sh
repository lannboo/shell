#!/bin/bash


#Node List
#NODE_LIST="192.168.0.121 192.168.0.122"
GROUP1_LIST="192.168.0.121"

GROUP2_LIST="192.168.0.122"

#Date/Time Variables
LOG_DATE='date "+%Y-%m-%d"'
LOG_TIME='date "+%H-%M-%S"'

CDATE=$(date "+%Y-%m-%d")
CTIME=$(date "+%H-%M-%S")

# Shell Env
SHELL_NAME="deploy.sh"
SHELL_DIR="/root/www"
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}.log"

#Code Env
PRO_NAME="web-demo"
CODE_DIR="/deploy/code/web-demo"
CONFIG_DIR="/deploy/config/web-demo"
TMP_DIR="/deploy/tmp"
TAR_DIR="/deploy/tar"
LOCK_FILE="/tmp/deploy.lock"


#DEPLOY_METHOD=$1


usage(){
	echo $"Usage $0 [ deploy | rollback ]"
}

writelog(){
	LOGINFO=$1
	echo "${CDATE} ${CTIME}: ${SHELL_NAME} : ${LOGINFO} " >> ${SHELL_LOG}
}

shell_lock(){
	touch ${LOCK_FILE}
}

shell_unlock(){
	rm -f ${LOCK_FILE}
}


code_get(){
	writelog  "code_get";
	cd $CODE_DIR && echo "git pull"
	cp -r ${CODE_DIR} ${TMP_DIR}/
	API_VER="2345"
}

code_build(){
	echo code_build
}


code_config(){
	writelog "code_config"
	/bin/cp -r $CONFIG_DIR/base/* ${TMP_DIR}/"${PRO_NAME}"
	PKG_NAME="${PRO_NAME}"_"$API_VER"_"${CDATE}-${CTIME}"
	cd ${TMP_DIR} && mv ${PRO_NAME} ${PKG_NAME}
}

code_tar(){
	writelog "code_tar"
	cd ${TMP_DIR} && tar czf ${PKG_NAME}.tar.gz ${PKG_NAME}
	writelog "${PKG_NAME}.tar.gz"
	
}

code_scp(){
	writelog "code_scp"
	for node in $GROUP1_LIST;do
		scp ${TMP_DIR}/${PKG_NAME}.tar.gz $node:/opt/webroot/
	done

	for node in $GROUP2_LIST;do
                scp ${TMP_DIR}/${PKG_NAME}.tar.gz $node:/opt/webroot/
        done

}

cluster_node_remove(){
	writelog "cluster_node_remove"
}

url_test(){
	URL=$1
	curl -s --head $URL | grep '200 OK'
	if  [ $? -ne 0  ];then
		shell_unlock;
		writelog "test error" && exit;
	fi
}



group1_deploy(){
	writelog "group1_deploy"
	for node in $GROUP1_LIST;do
	        ssh $node "cd /opt/webroot/ && tar zxf ${PKG_NAME}.tar.gz"
		ssh $node "rm -f /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo"
	done
	scp ${CONFIG_DIR}/other/192.168.0.121.crontab.xml 192.168.0.121:/opt/webroot/${PKG_NAME}/crontab.xml

}


group1_test(){
	url_test " http://192.168.0.121/index.html"	
	echo " group1 add to cluster!!"
}

group2_deploy(){
        writelog "group2_deploy"
        for node in $GROUP2_LIST;do
                ssh $node "cd /opt/webroot/ && tar zxf ${PKG_NAME}.tar.gz"
                ssh $node "rm -f /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo"
        done
        scp ${CONFIG_DIR}/other/192.168.0.121.crontab.xml 192.168.0.121:/opt/webroot/${PKG_NAME}/crontab.xml

}


group2_test(){
	url_test " http://192.168.0.122/index.html"
	echo " group2 add to cluster!!"

}



config_diff(){
	writelog "config_diff"
	
}

code_test(){
	writelog "code_test"
}

cluster_node_in(){
	writelog "cluster_node_in"
}

rollback(){
	echo rollback.....
}

main(){
	if  [ -f $LOCK_FILE ];then
		echo "Deploy is running" && exit;
	fi
	DEPLOY_METHOD=$1	
	case $DEPLOY_METHOD in
		deploy)
			shell_lock;
			code_get;
			code_build;
			code_config;
			code_tar;
			code_scp;
			cluster_node_remove;
			group1_deploy;
			group1_test;
			
			#group2_deploy;
                        #group2_test;
			config_diff;
			code_test;
			cluster_node_in;
			shell_unlock;
			;;
		rollback)
			shell_lock;
			rollback;
			shell_unlock;
			;;
		*)
			usage;
	esac
}

main $1

