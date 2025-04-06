#!/bin/sh

scriptname=runner.sh
source ./includes.sh 

set_colors
read_args_by_name

# set -e has already been set so no need to reverse it after the command:
if [[ $- =~ e ]]; then
    # set -e has already been set so we need to set it back it after the command
    set +e
    source ./$action1.sh
    set -e	
else
     source ./$action1.sh
fi
#source ./$action1.sh

# set -e has already been set so no need to reverse it after the command
# if [[ $- =~ e ]]; then ....    
# source ./$action1.sh

footermsg 
