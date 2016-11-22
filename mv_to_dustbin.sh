#!/bin/bash
## Coder: Shen Si, 2013-06-13, shensilasg@gmail.com

function abspath(){
    filepath=$1
    dir=$(dirname "$filepath")
    base=$(basename "$filepath")
    absdir=$(cd $dir && pwd)
    echo "$absdir/$base"
}

function reblank(){
    path=$1
    echo "$path" | sed 's/ /\\ /g'
}

declare -a objects
declare -a options
objects=()
options=()

narg=$#
cnt_opt=0
cnt_obj=0
for ((i=1;i<=$narg;i=i+1)); do
    item=$1
    obj=$(echo "$1" | sed 's/^-.*//g')
    opt=$(echo "$1" | sed 's/^[^-].*//g')
    if [ -n "$obj" ]; then
        objects[$cnt_obj]="$obj"
        cnt_obj=$(($cnt_obj + 1))
    fi
    if [ -n "$opt" ]; then
        if [ "$opt" == "-Iamsure" ]; then
            to_rm=1
        else
            options[$cnt_opt]="$opt"
            cnt_opt=$(($cnt_opt  +1))
        fi
    fi
    shift
done

#echo ${#objects[@]}
#echo ${objects[@]}
#echo ${#options[@]}
#echo ${options[@]}
#exit

if [ -n "$to_rm" ]; then
    read -p "remove ${objects[@]} ? [y/N]" x
    if [ "$x" == "y" ] || [ "$x" == "Y" ]; then
        /bin/rm ${options[@]} "${objects[@]}"
    fi
else
    test -d $DIR_DUSTBIN || mkdir $DIR_DUSTBIN
    date=$(date +%Y%m%d)
    test -d $DIR_DUSTBIN/$date || mkdir -p $DIR_DUSTBIN/$date
    file_prefix=$(date +%Y%m%d-%H%M%S_)
    for ((i=0;i<${#objects[@]};i=i+1)); do
        obj="${objects[$i]}"
        if [ -n "$(echo $obj | /bin/grep -e ' ')" ]; then
            echo -ne "\033[1;31m"
            echo "FAIL move_to_dustbin: $obj has blank in its name"
            echo -ne "\033[0m"
        fi
        obj_name=$(basename "$obj")
        obj_print=$(reblank "$obj")
        dest=$DIR_DUSTBIN/$date/$file_prefix"$obj_name"
        echo -ne "\033[1;34m"
        echo "MVing $obj_print to DUSTBIN: $(reblank "$dest")---"
        echo -ne "\033[0m"
        mv "$obj" "$dest"
        abs_path=$(abspath "$obj")
        echo "$(reblank "$abs_path") $(reblank "$dest")" >> $DIR_DUSTBIN/dust_log
    done
fi




