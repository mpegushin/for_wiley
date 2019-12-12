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

	ssh_cmd="echo $(uname -r) | wall; echo $(cat /proc/cmdline) | wall" # save a command	
	ssh -t sibur-user@$server $ssh_cmd # connect to server and execute a command
done


