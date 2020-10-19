#!/bin/sh
#
# Author: Luiz Sales
# Email: luiz.sales@servicemonit.com.br
# www.servicemonit.com.br
#

crypt() {
	echo "$2" | openssl enc -aes-128-cbc -a -salt -pass pass:wtf
}
decrypt() {
	echo "$2"  |  openssl enc -aes-128-cbc -a -d -salt -pass pass:wtf 
}

main() {
	TMPF=$(mktemp)
	BIN_FILE=$(find / -name zabbix_server  | grep sbin)
	CHK_FILE=$(file $BIN_FILE | grep "shell script" | wc -l)
	if [ $CHK_FILE -eq "1" ]; then
		CNF_FILE=$(`echo $BIN_FILE`".old" -h | grep default: | awk -F\" '{print $2}')
		cat $CNF_FILE | grep -v ^"#" | awk 'NF>0' > $TMPF
		for q in `cat $TMPF | grep =U2F`
		do
			param=$(echo $q | awk -F\= '{print $1}')
			crypt=$(echo $q | awk -F\= '{print $2"="$3}')
			decrypt=$($0 decrypt $crypt)
			regexq=$(echo $q | sed 's/\//\\\//g')
			sed -i "s/$regexq/$param=$decrypt/g" $TMPF
		done
		#cat $TMPF | grep -v ^"#" | awk 'NF>0' 
		$BIN_FILE".old" -c $TMPF $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 | sed 's/.old//g'
    rm -rf $TMPF
	else
		echo "script nao compativel. "
		echo
		echo "# $0 install"
	fi
}

install() {
	BIN_FILE=$(find / -name zabbix_server  | grep sbin)
	DIR_NAME=$(dirname $BIN_FILE)
	mv $BIN_FILE $BIN_FILE.old
	cp $0 $DIR_NAME/zabbix_server

}

case $1 in
	install)	install
	;;
	crypt)	crypt $1 $2
	;;
	decrypt)	decrypt $1 $2
	;;
	*)	main $1 $2 $3 $4 $5 $6 $7 $8 $9 $10
	;;
esac
