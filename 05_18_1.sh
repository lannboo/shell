#!/bin/bash
#no.1
[ $# -ne 2 ] &&{
	echo $ "USAGE $0 NUM1 NUM2"
	exit 1
}

#no.2
a=$1
b=$2
expr $a + $b + 1100 &>/dev/null 
if [ $? -ne 0 ]  #判断是为0，零为整数
	then
		echo "you must input two nums."
		exit 2
fi

#no.3
echo "a-b=$(($a-$b))"
echo "a+b=$(($a+$b))"
echo "a/b=$(($a/$b))"
echo "a*b=$(($a*$b))"
echo "a**b=$(($a**$b))"
echo "a%b=$(($a%$b))"

