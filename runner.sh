#!/bin/sh

set -e 

source ./includes.sh 

set_colors
read_args_by_name
source ./$ACTION.sh

footermsg 