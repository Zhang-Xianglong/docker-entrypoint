#!/bin/sh

export VAR_CASE=
#export VAR_CASE="ignore-case"
#export VAR_CASE="CamelCase"
#export VAR_CASE="snake_case"

export VAR_SEPARATOR=
#export VAR_SEPARATOR="="
#export VAR_SEPARATOR=":"

export CONFIG="test.txt"
export WAIT_FOR_SERVICE="www.baidu.com:80;www.sina.com:80"

echo "a.b_c=1" >  $CONFIG
echo "a.b_C=1" >> $CONFIG
echo "a.B_c=1" >> $CONFIG
echo "a.B_C=1" >> $CONFIG
echo "a.bC=1"  >> $CONFIG

export SUNKAISENS_A__B_C=100

./docker-entrypoint.sh
