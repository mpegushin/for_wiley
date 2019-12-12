#!/bin/bash

display_usage() { # help function to display usage
	echo "This script must be run from user with enabled ssh key-based authentication" 
	echo -e "\nUsage:\n$0 /path/to/file"
        echo -e "\nFile format should be:\nserver1\nserver2\nserver3"	
	} 

if [ $# -ne 1 ] # check that count of arguments is not equeal to 1
then
	display_usage
	exit 0 # if count of arguments is less or more than 1 - exit with usage info
fi

if [[ ( $1 == "--help") ||  $1 == "-h" ]] # check that first script argument is '--help' or '-h'
then
        display_usage
        exit 0 # if first script argument is '--help' or '-h' - exit with usage info
fi


readarray qaservers < $1 # make an array from file

for server in ${qaservers[@]} # start a loop for each element in an array
do
	nc -z -w 5 $server 22 # check that port 22 is opened with 5 sec timeout

	if [ $? -eq 1 ]; # check that exit code isn't successful
	then
		echo "On server $server ssh port isn't opened!"
		break # break the loop if the server doesn't respond
	fi

	java_processes=$(ssh sibur-user@$server "ps -eo pid,lstart,command | grep -v grep | grep java") # get an output of ps command, each process is in a separate line with '\n' ending 

	if [ $? -ne 0 ]; # check that server hasn't any running java processes
	then
		echo "Server $server doesn't have any running java processes!"
	else
		IFS=$'\n' # change IFS to '\n'
		for line in $java_processes # start a loop for each element in $java_processes, delimiter is '\n'
	     	do
			pid=$(echo $line | awk '{ print $1 }') # get a pid
			start_time=$(echo $line | awk '{ print $2 " " $3 " " $4 " " $5 " " $6 }') # get a time when a process restarted
			echo On server $server pid $pid restarted at $start_time
			if [ "$(echo $line | grep "jmxremote.port")" ]; # check that a process has jmx port setting
			then
				jmx_port=$(echo ${line} | awk -F "jmxremote.port=" '{ print $2 }' | awk '{ print $1 }') # get a jmx port value
				echo Server $server has jmx port: $jmx_port
			fi
		done
		unset IFS # set IFS to default
	fi
done
