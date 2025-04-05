#!/bin/sh

set -e 

source ./includes.sh

setcolors
read_args_by_name
source ./$ACTION.sh