#!/bin/sh
#
# You can add the path of configuration file or folder to the CONFIG
# environment variable, and use semicolon to separate them. This script
# will catch all SUNKAISENS_ prefix environment variable and match it
# in configuration files. e.g. 'SUNKAISENS_HELLO__ZHANG_XIANG_LONG' will
# be converted to 'hello.zhang_xiang_long'.
#
# Borrowed from the emqx's docker-entrypoint.sh.
# ZhangXiangLong <zhangxianglong@sunkaisens.com>

set -eo pipefail

array=(${CONFIG//;/ })
for path in ${array[@]}; do
	if [[ -f $path ]]; then
		file_list=$file_list";"$path
	elif [[ -d $path ]]; then
		for var in $(ls $path); do
			if [[ -f $path/$var ]]; then
				file_list=$file_list";"$path/$var
			fi
		done
	fi
done
file_array=(${file_list//;/ })

for var in $(env); do
	if [[ -n "$(echo $var | grep -E '^SUNKAISENS_')" ]]; then
		var_name=$(echo "$var" | sed -r "s/SUNKAISENS_([^=]*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | sed -r "s/__/\./g")
		var_full_name=$(echo "$var" | sed -r "s/([^=]*)=.*/\1/g")

		for file in ${file_array[@]}; do
			if [[ -f $file && -n "$(cat $file | grep -E "^(^|^#*|^#*\s*)$var_name")" ]]; then
				echo "$var_name=$(eval echo \$$var_full_name)"
				echo "$(sed -r "s/(^#*\s*)($var_name)\s*=\s*(.*)/\2=$(eval echo \$$var_full_name | sed -e 's/\//\\\//g')/g" $file)" > $file
			fi
		done
	fi
done

# https://docs.docker.com/compose/startup-order/
# https://github.com/vishnubob/wait-for-it
if [[ -z "$WAIT_FOR_TIMEOUT" ]]; then
	WAIT_FOR_TIMEOUT=0
fi
if [[ -n "$WAIT_FOR_SERVICE" ]]; then
	serv_array=(${WAIT_FOR_SERVICE//;/ })
	for serv in ${serv_array[@]}; do
		./wait-for-it.sh -t $WAIT_FOR_TIMEOUT $serv
	done
fi

exec "$@"
