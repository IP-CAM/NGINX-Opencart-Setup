#!/bin/sh

scriptname=runner.sh
source ./includes.sh 

set_colors
read_args_by_name

if [[ $- =~ e ]]; then
    set +e
    source ./$action1.sh
    set -e
else
    # set -e has not been set so no need to reverse it after the command
    source ./$action1.sh
fi

# set -e has already been set so no need to reverse it after the command
# if [[ $- =~ e ]]; then ....    
# source ./$action1.sh

footermsg 
echo "Exiting '$scriptname' with code:$?  "$?
echo $?