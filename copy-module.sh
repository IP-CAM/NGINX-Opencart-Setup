#!/bin/sh

set -e

: ${iexit:="Exiting.."}
: ${archivezip:?"You need to set some archivezip='Some best OC module.zip' first. $iexit"}

: "${SIG_NONE=0}"
: "${SIG_HUP=1}"
: "${SIG_INT=2}"
: "${SIG_QUIT=3}"
: "${SIG_KILL=9}"
: "${SIG_TERM=15}"

if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. $iexit"  
 exit 1
fi   

if  [ -z ${MYTMPDIR+x} ]; then 
 MYTMPDIR="$(mktemp -d)"; 
 printf "\n Created temporal directory $MYTMPDIR\n"
 if sh -c ": >/dev/tty" >/dev/null 2>/dev/null; then
  trap 'rm -rf -- "$MYTMPDIR"' 0 $SIG_NONE $SIG_HUP $SIG_INT $SIG_QUIT $SIG_TERM
 else
  trap 'rm -rf -- "$MYTMPDIR"' EXIT
 fi
fi


################################################

zipopt='-o'
#  -n  never overwrite existing files         
#  -q  quiet mode (-qq => quieter)
#  -o  overwrite files WITHOUT prompting
ocroot="/var/www/$mydomain/public"

unzip  $zipopt "$archivezip"  -d "$ocroot"

printf "\n\n${OK}Module '$archivezip' installed\n\n${NC}"
