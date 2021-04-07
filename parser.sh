#!/bin/bash

# read input file and get only content of "script_run"
while read line; do
    if [[ $line =~ "script_run" ]]; then
        cmd=$(echo $line | grep -v sub | sed 's/\s*\(script_run\|assert_script_run\|assert_script_run_qemu\)\s*//g;s/\(\s\)\s*/\1/g'| sed 's/;$//g' | tr -d "'\"()")
        cmd_array=("${cmd_array[@]}" "$cmd")
    fi
done < $1
array_size=${#cmd_array[@]}

# discount one, so shell does not return empty position
let array_size--

# get only cmds, not parameters
for j in $(seq 0 $array_size); do
    if [[ ${cmd_array[$j]} =~ ";" ]]; then
        temp=$(echo ${cmd_array[@]} | tr ";" "\n" | sed 's/^ //g' | cut -d " " -f 1 | grep [a-zA-Z])
        for entry in $temp; do
            temp_list=("${temp_list[@]}" "$entry")
        done
    else
        temp=$(echo ${cmd_array[j]} | sed 's/^ //g' | cut -d " " -f 1 | grep [a-zA-Z])
        temp_list=("${temp_list[@]}" "$temp")
    fi
done

# need more smart way to do this
for v in ${temp_list[@]}; do
    if [[ ! ${final_list[@]} =~ "$v" ]]; then
        final_list=("${final_list[@]}" "$v")
    fi
done

# refresh repo
zypper ref

# install scout to determine app path
if ! test -x /usr/bin/scout; then
    zypper --non-interactive install -y scout
fi

for cmd in ${final_list[@]}; do
    exe=$(scout bin $cmd | cut -d "|" -f 2 | grep -v package | grep [a-zA-Z] | tr -d " " | uniq)
    exe_list=("${exe_list[@]}" "$cmd:$exe")
done
echo ${exe_list[@]}
