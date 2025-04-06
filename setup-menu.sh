#!/bin/bash
# Bash Menu Script  

# Copyright 2025 Vadim Durresiou
# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License, version 2.1
# as published by the Free Software Foundation.
# *
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
# *
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to
# Free Software Foundation, Inc.
# 51 Franklin St., Fifth Floor
# Boston, MA 02110, USA.
# *
# This is inspired by sources from authors referenced by url below.
 
trap "exit 1" TERM
export TOP_PID=$$ 

#https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script

oc_options_menu() {

 HEIGHT=20
 WIDTH=80
 CHOICE_HEIGHT=4

 BACKTITLE="Please select opencart source"
 TITLE="Select opencart source"
 MENU="Choose one of the following options:"

 OPTIONS=(1 "v.3:  Official Maintainence Branch 3.0.x.x (3.0.4.1)"
         2 "v.3:  DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)"
         3 "v.3:👌Custom Branch 3.0.x.x (3.0.4.1)"
         4 "v.3:  Custom DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)"
         5 "v.4:  Official latest release 4.x.x"
         6 "Exit, terminate, next time, no choice"		 
		 )

 CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
				--output-separator '-------string1-----' \
				--checklist 'text1' $HEIGHT $WIDTH 10 [ 'tag1' 'item1' 0 ] [ 'tag2' 'item2' 1 ] \
				--separator '----------string2------' \
				--inputbox 'text2' $HEIGHT $WIDTH ['init2'] \
                2>&1 >/dev/tty)

 clear
 case $CHOICE in
        1)
            echo "You chose Option 1"
			sourceurl='https://github.com/opencart/opencart/archive/refs/heads/3.0.x.x.zip'
			sourceroot='opencart-3.0.x.x/upload'
            ;;
        2)
            echo "You chose Option 2"
            ;;
        3)
            echo "You chose Option 3"
			sourceurl='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
			sourceroot='oc-3.0.x.x-3.0.x.x/upload'
            ;;
        4)
            echo "You chose Option 4"
			sourceurl='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
			sourceroot='oc-3.0.x.x-3.0.x.x/upload'
            ;;
        5)
            echo "You chose Option 5"
			sourceurl='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
			sourceroot='oc-3.0.x.x-3.0.x.x/upload'
            ;;
        6)
            echo "Bye.."
			kill -s TERM $TOP_PID
            ;;			
 esac
}


menu1() {
dialog                         --begin 2 2 --yesno "" 0 0 \
				--output-separator '-------string1-----' \
    --and-widget               --begin 4 4   "" 0 0 \
					--output-separator '-------string2-----' \
    --and-widget               --begin 6 6  "" 0 0
}
dialog_help() {
printf "Usage: dialog <options> { --and-widget <options> }
where options are 'common' options, followed by 'box' options

Special options:
[--create-rc 'file']
Common options:
[--ascii-lines] [--aspect <ratio>] [--backtitle <backtitle>]
[--begin <y> <x>] [--cancel-label <str>] [--clear] [--colors]
[--column-separator <str>] [--cr-wrap] [--default-item <str>]
[--defaultno] [--exit-label <str>] [--extra-button]
[--extra-label <str>] [--help-button] [--help-label <str>]
[--help-status] [--ignore] [--input-fd <fd>] [--insecure]
[--item-help] [--keep-tite] [--keep-window] [--max-input <n>]
[--no-cancel] [--no-collapse] [--no-kill] [--no-label <str>]
[--no-lines] [--no-ok] [--no-shadow] [--nook] [--ok-label <str>]
[--output-fd <fd>] [--output-separator <str>] [--print-maxsize]
[--print-size] [--print-version] [--quoted] [--separate-output]
[--separate-widget <str>] [--shadow] [--single-quoted] [--size-err]
[--sleep <secs>] [--stderr] [--stdout] [--tab-correct] [--tab-len <n>]
[--timeout <secs>] [--title <title>] [--trace <file>] [--trim]
[--version] [--visit-items] [--yes-label <str>]
Box options:
--calendar <text> <height> <width> <day> <month> <year>
--checklist <text> <height> <width> <list height> <tag1> <item1> <status1>...
--dselect <directory> <height> <width>
--editbox <file> <height> <width>
--form <text> <height> <width> <form height> <label1> <l_y1> <l_x1> <item1> <i_y1> <i_x1> <flen1> <ilen1>...
--fselect <filepath> <height> <width>
--gauge <text> <height> <width> [<percent>]
--infobox <text> <height> <width>
--inputbox <text> <height> <width> [<init>]
--inputmenu <text> <height> <width> <menu height> <tag1> <item1>...
--menu <text> <height> <width> <menu height> <tag1> <item1>...
--mixedform <text> <height> <width> <form height> <label1> <l_y1> <l_x1> <item1> <i_y1> <i_x1> <flen1> <ilen1> <itype>...
--mixedgauge <text> <height> <width> <percent> <tag1> <item1>...
--msgbox <text> <height> <width>
--passwordbox <text> <height> <width> [<init>]
--passwordform <text> <height> <width> <form height> <label1> <l_y1> <l_x1> <item1> <i_y1> <i_x1> <flen1> <ilen1>...
--pause <text> <height> <width> <seconds>
--progressbox <height> <width>
--radiolist <text> <height> <width> <list height> <tag1> <item1> <status1>...
--tailbox <file> <height> <width>
--tailboxbg <file> <height> <width>
--textbox <file> <height> <width>
--timebox <text> <height> <width> <hour> <minute> <second>
--yesno <text> <height> <width>
Auto-size with height and width = 0. Maximize with height and width = -1.
Global-auto-size if also menu_height/list_height = 0."
}

#  Mixed gauge demonstration
menu2(){
: ${DIALOG=dialog}
background="An Example of --mixedgauge usage"
i=60 
#60% just for test
#0=Succeeded
#1=Failed
#2=Passed
#3=Completed
#4=Done
#5=Skipped
#6=In Progress
#7=Checked
#-$i= value in i%
# "" "8" draws empty line

$DIALOG --begin 5 5 \
--backtitle "$background" \
--title "Mixed gauge demonstration" \
--mixedgauge "This is a prompt message,\nand this is the second line." \
0 0 33 \
"Process one" "0" \ 
"Process two" "1" \
"Process three" "2" \
"Process four" "3" \
"" "8" \
"Process five" "5" \
"Process six" "6" \
"Process seven" "7" \
"Process eight" "4" \
"Process nine" "-$i"

# Auto-size with height and width = 0. Maximize with height and width = -1.
# Global-auto-size if also menu_height/list_height = 0.
$DIALOG --begin 0 0 \
--backtitle "$background" \
--title "Mixed gauge demonstration" \
--mixedgauge "This is a prompt message,\nand this is the second line." \
0 0 33 \
"Process one" "0" \ 
"Process two" "1" \
"Process three" "2" \
"Process four" "3" \
"" "8" \
"Process five" "5" \
"Process six" "6" \
"Process seven" "7" \
"Process eight" "4" \
"Process nine" "-$i"
 
}

# Note that dialog is not universally available on all Linux systems(thought on Ubuntu is available)
# Script might not be compatible across different systems/releases/distributions. 

sudo apt-get -qq install dialog
if [[ $? != 0 ]]; then
  printf "No dialog boxes availabe. You can try to install whiptail and write your oun menu with it\n"
  # sudo apt-get -qq install whiptail
  # https://github.com/JazerBarclay/whiptail-examples some samples:
  # whiptail_menu
fi  
menu2
menu1

 
#oc_options_menu

scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/bootstrap-runner.sh'

bash <(  curl -Ls $scripturl )  $(  curl -Ls $argurl ) --url $sourceurl --ziproot $sourceroot