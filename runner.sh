#!/bin/sh

scriptname=runner.sh
source ./includes.sh 

set_colors
read_args_by_name
echo "# arguments called with ---->  ${@}"
if [[ $- =~ e ]]; then
    # set -e has already been set so we need to set it back it after the command
    set +e
    source ./$action.sh
	footermsg 
    set -e	
else
    source ./$action.sh
    footermsg 
fi
