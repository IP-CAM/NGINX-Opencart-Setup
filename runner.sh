#!/bin/sh

set -e 

source ./includes.sh 

set_colors
read_args_by_name
source ./$action1.sh

footermsg 
echo 'Exiting runner.sh with code:'$?
echo $?