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

#declare_terminal() {
# Application constants
declare -r snmp_oid_oc_ip=1.3.6.1.4.1.52535.121.100
declare -r caption_online='✅Online'
declare -r caption_offline='➖Unreachable'
declare -r caption_unknown='❔Undetermined'
declare -r conf_file="$HOME/.terminal-config.txt"
declare -r self_exe="$0"
declare -r -a daemon_names=('HTTP server' 'HTTPS server' 'DNS server' 'Mail server' 'Telnet server' 'SNMP server' 'QOTD')
declare -r -A main_menu_key_labels=(
  ['config']='💾 Configure oc server address and more'
  ['email']='📮 Read and send Emails'
  ['phone']='📠 Make calls and send SMS'
  ['tweet']='🐦 Read and post tweets'
  ['info']='🌐 Get the latest news / weather / facts'
  ['book']='📝 2FA code / password book / text search'
  ['cmd']='💻 Run commands and inspect server status'
)
 

# Runtime data
connection_report_file="$(mktemp -p /tmp terminal-connection-report-XXXXX)"
last_reqresp_file="$(mktemp -p /tmp terminal-last-reqresp-XXXXX)"
app_cmd_out_file="$(mktemp -p /tmp terminal-app-cmd-output-XXXXX)"
form_submission_file="$(mktemp -p /tmp terminal-form-submission-XXXXX)"
 
echo -en "\nStarted: $(date --rfc-3339=seconds)" >> "$connection_report_file"
echo -en "\nStatus: started" >> "$last_reqresp_file"
 
# Application configuration read from and persisted into a text file
sample_host="${sample_host:-}"


# Clean up after temporary files and background jobs on exit
clean_up_before_exit() {
  rm -f "$connection_report_file" "$last_reqresp_file" "$app_cmd_out_file" "$form_submission_file" || true
}
on_exit() {
  clean_up_before_exit
  # The temrinal program is not expected to exit using the exit code of external command "dialog"
  exit 0
}
trap on_exit EXIT INT TERM


#}


################################################################################
# Dialog - application configuration
################################################################################
dialog_config() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 25 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 25 \
    --and-widget --keep-window --begin 2 30 --title '💾 Configure oc server address and more' --mixedform "The settings for connecting to your oc server are saved to $conf_file" 21 70 12 \
      'What is the server hostname/IP?' 1 0 "$oc_host"     1 32 200 0 0 \
      '' 2 0 '' 2 0 0 0 0 \
      'On which port does the server run... (leave empty if unsed)' 3 0 '' 3 0 0 0 0 \
      'HTTP port'                      4 0 "$port_httpd"       4 32 8 0 0 \
      'HTTPS port'                     5 0 "$port_httpsd"      5 32 8 0 0 \
      'DNS port'                       6 0 "$port_dnsd"        6 32 8 0 0 \
      'SMTP port'                      7 0 "$port_smtpd"       7 32 8 0 0 \
      'SNMP port'                      8 0 "$port_snmpd"       8 32 8 0 0 \
      'Telnet - plain socket port'     9 0 "$port_plainsocket" 9 32 8 0 0 \
      'Simple IP service - QOTD port' 10 0 "$port_qotd"       10 32 8 0 0 \
      '' 11 0 '' 11 0 0 0 0 \
      'In order to execute app commands on your oc server...' 12 0 '' 12 0 0 0 0 \
      'Command processor password'    13 0 "$app_cmd_pass"     13 32 200 0 0 \
      'App command execution API URL' 14 0 "$app_cmd_endpoint" 14 32 200 0 0 \
      '' 15 0 '' 15 0 0 0 0 \
      'What is the community string for probing SNMP?' 16 0 '' 16 0 0 0 0 \
      'Leave empty if unused'       17 0 "$snmp_community_string" 17 32 200 0 0 \
      '' 18 0 '' 18 0 0 0 0 \
      'Low bandwidth mode works better over satellite (reduce security)' 19 0 '' 19 0 0 0 0 \
      'Use low bandwidth mode? (y/n)' 20 0 "$low_bandwidth_mode" 20 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  if [ -s "$form_submission_file" ]; then
    readarray -t form_fields < "$form_submission_file"
    cat << EOF > "$conf_file"
oc_host="${form_fields[0]}"
port_httpd="${form_fields[1]}"
port_httpsd="${form_fields[2]}"
port_dnsd="${form_fields[3]}"
port_smtpd="${form_fields[4]}"
port_snmpd="${form_fields[5]}"
port_plainsocket="${form_fields[6]}"
port_qotd="${form_fields[7]}"
app_cmd_pass="${form_fields[8]}"
app_cmd_endpoint="${form_fields[9]}"
snmp_community_string="${form_fields[10]}"
low_bandwidth_mode="${form_fields[11]}"
EOF
 
  fi
}
################################################################################
# Dialog - app commands and related
################################################################################
dialog_app_command_in_progress() {
  local bandwidth_mode
  bandwidth_mode='aaaaaa'
 
  dialog \
    --sleep 1 \
    --backtitle 'Opencart Terminal' \
    --begin 2 50 --title "Running app command $bandwidth_mode" --infobox "Please wait, this may take couple of seconds." 10 45 || true
}

dialog_app_command_done() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title 'Command result (scroll with Left/Right/Up/Down)' --textbox "$app_cmd_out_file" 21 70 || true
}

dialog_simple_info_box() {
  local info_box_txt
  info_box_txt="$1"
  dialog \
    --sleep 3 \
    --backtitle 'Opencart Terminal' \
    --begin 2 50 --title 'Notice' --infobox "$info_box_txt" 10 45 || true
}

################################################################################
# Dialog - read and send Emails
################################################################################
dialog_email() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title '📮 Read and send Emails' --mixedform '' 21 70 14 \
      'List Emails'                       1 0 ''     1  0   0 0 0 \
      'Email account nick name'           2 0 ''     2 32 200 0 0 \
      'Skip latest N Emails'              3 0 '0'    3 32 200 0 0 \
      'And then list N Emails'            4 0 '10'   4 32 200 0 0 \
      '------------------------------'    5 0 ''     5 0    0 0 0 \
      'Read Email'                        6 0 ''     6  0   0 0 0 \
      'Email account nick name'           7 0 ''     7 32 200 0 0 \
      'Email message number'              8 0 ''     8 32 200 0 0 \
      '------------------------------'    9 0 ''     9  0   0 0 0 \
      'Send Email'                       10 0 ''    10  0   0 0 0 \
      'To address'                       11 0 ''    11 32 200 0 0 \
      'Subject'                          12 0 ''    12 32 200 0 0 \
      'Content'                          13 0 ''    13 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  }

################################################################################
# Dialog - make calls and send SMS
################################################################################
dialog_phone() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title '📠 Make calls and send SMS' --mixedform '' 21 70 14 \
      'Dial a number and speak a message' 1 0 ''     1  0   0 0 0 \
      'Dial phone number (+35812345)'     2 0 ''     2 32 200 0 0 \
      'Speak message'                     3 0 ''     3 32 200 0 0 \
      '------------------------------'    4 0 ''     4 0    0 0 0 \
      'Send an SMS'                       5 0 ''     5  0   0 0 0 \
      'To number (+35812345)'             6 0 ''     6 32 200 0 0 \
      'Text message'                      7 0 ''     7 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  }
  
  ################################################################################
# Dialog - read and post tweets
################################################################################
dialog_tweet() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title '🐦 Read and post tweets' --mixedform '' 21 70 14 \
      'Read latest tweets from home timeline' 1 0 ''     1  0   0 0 0 \
      'Skip latest N tweets'                  2 0 '0'    2 32 200 0 0 \
      'And then read N tweets'                3 0 '10'   3 32 200 0 0 \
      '------------------------------'        4 0 ''     4 0    0 0 0 \
      'Post a tweet'                          5 0 ''     5  0   0 0 0 \
      'Content'                               6 0 ''     6 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  }
  
  ################################################################################
# Dialog - get the latest news / weather / facts
################################################################################
dialog_info() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title '🌐 Get the latest news / weather / facts' --mixedform '' 21 70 14 \
      'Get the latest news from RSS'        1 0 ''     1  0   0 0 0 \
      'Skip latest N news articles'         2 0 '0'    2 32 200 0 0 \
      'And then read N articles'            3 0 '10'   3 32 200 0 0 \
      '------------------------------'      4 0 ''     4 0    0 0 0 \
      'Ask WolframAlpha for weather/facts'  5 0 ''     5  0   0 0 0 \
      'Inquiry (free form text)'            6 0 ''     6 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  }
  
  ################################################################################
# Dialog - 2FA code / password book / text search
################################################################################
dialog_book() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title '📝 2FA code / password book / text search' --mixedform '' 21 70 14 \
      'Get 2FA authentication code'         1 0 ''     1  0   0 0 0 \
      'The remaining decryption key'        2 0 ''     2 32 200 0 0 \
      'Search for account'                  3 0 ''     3 32 200 0 0 \
      '------------------------------'      4 0 ''     4  0   0 0 0 \
      'Find in encrypted text'              5 0 ''     5  0   0 0 0 \
      'File shortcut word'                  6 0 ''     6 32 200 0 0 \
      'The remaining decryption key'        7 0 ''     7 32 200 0 0 \
      'Search for'                          8 0 ''     8 32 200 0 0 \
      '------------------------------'      9 0 ''     9  0   0 0 0 \
      'Find in plain text'                 10 0 ''    10  0   0 0 0 \
      'File shortcut word'                 11 0 ''    11 32 200 0 0 \
      'Search for'                         12 0 ''    12 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  }
  
  ################################################################################
# Dialog - run commands and inspect server status
################################################################################
dialog_cmd() {
  dialog \
    --backtitle 'Opencart Terminal' \
    --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
    --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
    --and-widget --keep-window --begin 2 50 --title '💻 Run commands and inspect server status' --mixedform '' 21 70 14 \
      'Select one of the following by entering Y' 1 0 ''     1  0   0 0 0 \
      'Get the latest server info'                2 0 'y'    2 32 200 0 0 \
      'Get the latest server log'                 3 0 ''     3 32 200 0 0 \
      'Get the latest server warnings'            4 0 ''     4 32 200 0 0 \
      'Server emergency lock (careful)'           5 0 ''     5 32 200 0 0 \
      '------------------------------'            6 0 ''     6 0    0 0 0 \
      'Run this app command'                      7 0 ''     7 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  }
  
  ################################################################################
# Main menu
################################################################################
dialog_main_menu() {
  while true; do
    exec 5>&1
    main_menu_choice=$(
    dialog \
      --backtitle 'Opencart Terminal' \
      --keep-window --begin 2 2 --title "Connection - $oc_host" --tailboxbg "$connection_report_file" 12 45 \
      --and-widget --begin 16 2 --title 'Last contact' --tailboxbg "$last_reqresp_file" 7 45 \
      --and-widget --keep-window --begin 2 50 --title "App Menu" --radiolist "Welcome to oc terminal! What can I do for you?" 21 70 10 \
        "${main_menu_key_labels['config']}" '' 'ON' \
        "${main_menu_key_labels['email']}" '' '' \
        "${main_menu_key_labels['phone']}" '' '' \
        "${main_menu_key_labels['tweet']}" '' '' \
        "${main_menu_key_labels['info']}" '' '' \
        "${main_menu_key_labels['book']}" '' '' \
        "${main_menu_key_labels['cmd']}" '' '' \
    2>&1 1>&5 || true
    )
    exec 5>&-
    if [ ! "$main_menu_choice" ]; then
      echo 'Thanks for using oc terminal, see you next time!'
      exit 0
    fi

    case "$main_menu_choice" in
      "${main_menu_key_labels['config']}")
        dialog_config
        ;;
      "${main_menu_key_labels['email']}")
        dialog_email
        ;;
      "${main_menu_key_labels['phone']}")
        dialog_phone
        ;;
      "${main_menu_key_labels['tweet']}")
        dialog_tweet
        ;;
      "${main_menu_key_labels['info']}")
        dialog_info
        ;;
      "${main_menu_key_labels['book']}")
        dialog_book
        ;;
      "${main_menu_key_labels['cmd']}")
        dialog_cmd
        ;;
      *)
        echo "unexpected menu choice \"$main_menu_choice\", this is a programming error." >&2
        exit 1
        ;;
    esac
  done
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
 SHOW_DESC=
# Inherit SHOW_DESC value if set, otherwise default to 1 :
[ "${SHOW_DESC+set}" ] || SHOW_DESC=1
 

 

#menu1

 
#oc_options_menu

scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/bootstrap-runner.sh'

bash <(  curl -Ls $scripturl )  $(  curl -Ls $argurl ) --url $sourceurl --ziproot $sourceroot
 
#===================================================
#https://github.com/opnsense/src/blob/d61f5e3dd96151b64f6990a9a5dc2a4efe37a8f5/usr.sbin/bsdconfig/share/packages/packages.subr#L499
 

 
