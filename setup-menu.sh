#!/bin/bash
# Bash Menu Script  

# This script is an "orchestrator" for the other scripts that exist in the "setup" directory, 
# and is only responsible for setting values and displaying the TerminalUI.
# This keeps the installer cleaner and easier to manipulate.

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
 URL1='https://github.com/opencart/opencart/archive/refs/heads/3.0.x.x.zip'
 URL3='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
 URL4='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
 URL5='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'

 OPTIONS=(1 "v.3:  Official Maintainence Branch 3.0.x.x (3.0.4.1)" "Official from opencart $URL1"
         2 "v.3:  DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)" "Development branch $URL2"
         3 "v.3:👌Custom Branch 3.0.x.x (3.0.4.1)" "Custom branch with some enhancements $URL3"
         4 "v.3:  Custom DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)" "Custom development branch $URL4"
         5 "v.4:  Official latest release 4.x.x" "Latest release from Opencart $URL5"
         6 "\Zb\Z1Exit, terminate\Zn, next time, no choice" "Do nothing, please exit"		 
		 )
# see for options here https://linux.die.net/man/1/dialog
# 	  --begin 0 0 \
 CHOICE=$(dialog --clear \
	--backtitle 'Opencart Terminal' \
    --title "Select opencart source" \
	--item-help \
	  --colors	\
    --menu "Choose one of the following options:" \
      0 0 6\
      "${OPTIONS[@]}" \
	--and-widget \
	  --title '💾 \Zb\Z2Configure\Zn oc server address and more' \
	  --visit-items \
	  --insecure \
	  --colors	\
	  --mixedform "The \Zb\Z2settings\Zn for connecting to your oc server are saved to $conf_file" \
	    0 0 12 \
		'What is the server hostname/IP?' 1 0 "$oc_host"     1 32 50 0 0 \
        '' 2 0 '' 2 0 0 0 0 \
        'On which port does the server run... (leave empty if unsed)' 3 0 '' 3 0 0 0 0 \
        'HTTP port'                      4 0 "$port_httpd"       4 32 8 0 0 \
        "HTTPS port"                     5 0 "port_httpsd"      5 32 18 0 2 \
        'In order to execute app commands on your oc server...' 6 0 "" 6 0 0 0 0 \
        'Command processor password'    7 0 "$app_cmd_pass"     7 32 50 0 1 \
        'App command execution API URL' 8 0 "app_cmd_endpoint" 8 32 50 0 3 \
        '' 9 0 '' 9 0 0 0 0 \
        'What is the community string for probing SNMP?' 10 0 '' 10 0 0 0 0 \
        'Leave empty if unused'       11 0 "$snmp_community_string" 11 32 50 0 0 \
        '' 12 0 '' 12 0 0 0 0 \
        'Low bandwidth mode works better over satellite (reduce security)' 13 0 '' 13 0 0 0 5 \
        'Use low bandwidth mode? (y/n)' 14 0 "$low_bandwidth_mode" 14 32 50 0 0 \
               2>&1 >/dev/tty)

 #clear
 echo "$CHOICE"
 case $CHOICE in
        1)
            echo "You chose Option 1"
			sourceurl=$URL1
			sourceroot='opencart-3.0.x.x/upload'
            ;;
        2)
            echo "You chose Option 2"
            ;;
        3)
            echo "You chose Option 3"
			sourceurl=$URL3
			sourceroot='oc-3.0.x.x-3.0.x.x/upload'
            ;;
        4)
            echo "You chose Option 4"
			sourceurl=$URL4
			sourceroot='oc-3.0.x.x-3.0.x.x/upload'
            ;;
        5)
            echo "You chose Option 5"
			sourceurl=$URL5
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

 
# Note that dialog is not universally available on all Linux systems(thought on Ubuntu is available)
# Script might not be compatible across different systems/releases/distributions. 

#sudo apt-get -qq install dialog
#if [[ $? != 0 ]]; then printf "No dialog boxes availabe. You can try to install whiptail";fi
  

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' dialog|grep "install ok installed")
if [ "" == "$PKG_OK" ]; then
  echo "Installing dialog"
  sudo apt-get --yes install dialog
else
  printf "No dialog boxes availabe. You can try to install whiptail and write your oun menu with it\n"
  # sudo apt-get -qq install whiptail
  # https://github.com/JazerBarclay/whiptail-examples some samples:
  # whiptail_menu
fi

 dialog_simple_info_box "Please complete any section of the form to use that app."
 dialog_main_menu
 
 #https://github.com/usnistgov/qpx-gamma/blob/4af4dd783e618074791674a018a3ba21c9b9aab1/bash/config.sh#L84
 #!/bin/bash

 

 

#menu1

 
#oc_options_menu

scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/bootstrap-runner.sh'

bash <(  curl -Ls $scripturl )  $(  curl -Ls $argurl ) --url $sourceurl --ziproot $sourceroot
 
#===================================================
#https://github.com/opnsense/src/blob/d61f5e3dd96151b64f6990a9a5dc2a4efe37a8f5/usr.sbin/bsdconfig/share/packages/packages.subr#L499
 

 
