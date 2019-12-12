#!/bin/bash

display_usage() { # help function to display usage
        echo -e "Usage:\n$0 /path/to/file"
        echo -e "\nFile format should be a valid json"   
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

cat $1 | python -m json.tool > /dev/null 2>&1 # check that file contains a valid json

if [ $? -eq 1 ] # check the exit code
then
	echo "This is'nt a valid json!"
	exit 1 # if file contains not a valid json - exit with code 1
fi

users_with_laborum_tag=$(cat $1 | jq '.[] | select(.tags | tostring | contains("laborum"))') # get a user with laborum tag
user_friends_names=$(echo "$users_with_laborum_tag" | jq '.friends[] | select(.id | tostring | contains("2")) | .name') # get a user's friends with id number 2

echo Users with laborum tag have friends with id number 2: $user_friends_names
