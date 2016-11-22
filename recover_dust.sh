#!/bin/bash
## Coder: Shen Si 2013-06-13, shensilasg@gmail.com
## Modifier: Shen Si 2016-08-12: show failure if file contain " "; fix a bug (add $ in grep)

narg=$#
for ((i=1;i<=$narg;i=i+1)); do
    obj="$1"
    if [ ! -e $obj ]; then # check exist
        echo -ne "\033[1;31m"
        echo "FAIL: $obj can not find!"
        echo -ne "\033[0m"
        continue
    fi
    if [ -n "$(echo $obj | grep ' ')" ]; then # check if contain " " 
        echo -ne "\033[1;31m"
        echo "FAIL: $obj contains blank (" "), can not recover it (Please do it yourself manually)"
        echo -ne "\033[0m"
        continue
    fi
    obj_name=$(basename "$obj")
    date=$(echo "$obj_name" | cut -d '-' -f 1)
    obj_abspath="$DIR_DUSTBIN/$date/$obj_name"
    request=$(cat $DIR_DUSTBIN/dust_log | /bin/grep ${obj_abspath}$ )
    if [ -z "$request" ]; then # check if saved in dust_log
        echo -ne "\033[1;31m"
        echo "FAIL: It seems $DIR_DUSTBIN/dust_log is not complete or not exists"
        echo -ne "\033[0m"
        exit
    fi
    obj_origin_path=$(echo "$request" | tr -s ' ' | cut -d ' ' -f 1)
    if [ -e "$obj_origin_path" ]; then # check if have same name conflict
        echo -ne "\033[1;31m"
        echo "FAIL: $obj_origin_path exists, can not overwrite it (Please do it yourself manually)"
        echo -ne "\033[0m"
        continue
    fi
    test -d $(dirname "$obj_origin_path") || mkdir -p $(dirname "$obj_origin_path")
    echo -ne "\033[1;34m"
    echo "MVing $obj_abspath $obj_origin_path ---"
    echo -ne "\033[0m"
    mv "$obj_abspath" "$obj_origin_path"
    shift
done

