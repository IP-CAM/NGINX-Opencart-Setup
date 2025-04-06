#!/bin/sh

set -e 
scriptname=runner.sh
source ./includes.sh 

set_colors
read_args_by_name
source ./$action1.sh

footermsg 
echo "Exiting '$scriptname' with code:$?  "$?
echo $?