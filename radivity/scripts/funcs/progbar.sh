#!/bin/bash

function prog_bar {

lines=$(echo $(wc -l "$1") | sed 's/ .*//')
let lines=$lines-1
let lines=$3*$lines


echo -n " [=>                                                                        ]"
for ((i=1;i<=74;++i)); do
	printf "\b"
done
counter=1
while [ "$(tail -n 1 $2 | egrep '[0-9]{1,}' -o)" -lt "$lines" ]; do
	let prog=$(tail -n 1 $2 | egrep '[0-9]{1,}' -o)
	let modifier=($lines/72)
	let modifier=$counter*$modifier
	if [ "$prog" -gt "$modifier" ]; then
		echo -n "=>"
		printf "\b"
		let counter=$counter+1
	fi
	sleep 10
done

echo -n "=]"

}