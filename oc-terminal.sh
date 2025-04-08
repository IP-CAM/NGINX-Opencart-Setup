#!/usr/bin/env bash


# https://stackoverflow.com/questions/16365130/what-is-the-difference-between-usr-bin-env-bash-and-usr-bin-bash

#  not forget remove CR : https://stackoverflow.com/questions/29045140/env-bash-r-no-such-file-or-directory
set -Eeuo pipefail

export PS4='#${BASH_SOURCE}:${LINENO} [${SHLVL},${BASH_SUBSHELL},$?]: '

# These symbols are defined to use in the sample shell scripts to make them
# more readable.  But they are (intentionally) not exported.  If they were
# exported, they would also be visible in the dialog program (a subprocess).

: "${SIG_NONE=0}"
: "${SIG_HUP=1}"
: "${SIG_INT=2}"
: "${SIG_QUIT=3}"
: "${SIG_KILL=9}"
: "${SIG_TERM=15}"

: "${DIALOG=dialog}"

# : "${DIALOG_OK=0}"
# : "${DIALOG_CANCEL=1}"
# : "${DIALOG_HELP=2}"
# : "${DIALOG_EXTRA=3}"
# : "${DIALOG_ITEM_HELP=4}"
# : "${DIALOG_ESC=255}"

# Application constants
declare -r snmp_oid_opencart_ip=1.3.6.1.4.1.52535.121.100
declare -r caption_online='✅Online'
declare -r caption_offline='👽Unreachable'
declare -r caption_unknown='❔Undetermined'
declare -r conf_file="$HOME/.opencart-terminal-config.txt"
declare -r self_exe="$0"
declare -r -a lemp_parts=('NGINX server' 'MySQL server' 'PHP stack' 'PHP-FMP module' 'SSL certbot' 'Site' 'Linux')

 BACKTITLE="Opencart Terminal"
 TITLE="Select opencart source"
 MENU="Choose one of the following options:"
 URL1='https://github.com/opencart/opencart/archive/refs/heads/3.0.x.x.zip'
 URL2='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
 URL3='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
 URL4='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'
 URL5='https://github.com/radiocab/oc-3.0.x.x/archive/refs/heads/3.0.x.x.zip'

# 🛠️⚙️🩼🔗⏳⌛🚀🏗️🌀🏃‍♂️🏃‍♀️🏃‍➡️😕😤👽🤔✴️🚼‼️⁉️🌐🛅🤌💻🆕🆗▶️⏭️🔽⏬⬇️↘️⤵️🔃↪️↩️🔜🔙🔚☑️✔️➕️🔄️↪️↩️⤵️ℹ️🔃🆖🆓🔀🔂⬇☑️🆙💫🚩🏳️🏴🚦🛸🌹🥀🥂⏰💻🖥️💣🩻🔩🔑🗝️🔒🪩🫵☝️👆✌️🐣🐥⚠


 # \Zx: 0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan and 7=white
 # \Zy: b=bold(perhaps bright) B=reset, r=reverse R=reset, u=Underline U=reset
 #  The settings are cumulative, e.g., "\Zb\Z1" makes the following text bold (perhaps bright) & red. 
 #  Restore normal settings with "\Zn".
 declare -r -a ACTIONS=(
  1 '🆙 Install Opencart \Zb\Z5🛒\Zn' 'Install Opencart \Zb\Z5🛒\Zn from scratch'
  2 '🔄 Reinstall Opencart \Zb\Z5🛒\Zn' 'Reinstall Opencart \Zb\Z5🛒\Zn with new database'
  3 '🌐 Install LEMP only 🆖' 'Install only LEMP with NGINX,MySQL,PHP and SSL Certbot'
  4 '🛅 Install ionCube only 🤑' 'Install only ionCube Loader for encrypted Opencart \Zb\Z5🛒\Zn modules'
  5 '🔒 Install SSL Lets Encrypt Certbot only 🔗' 'Initialize  SSL and install SSL LetsEncrypt Certbot'
  6 '📝 Install free OC template \Zb\Z5🛒\Zn' 'Install some sample Opencart \Zb\Z5🛒\Zn template'
  7 '🏃‍➡ Run some command on server' 'Run some command on server \Zb\Z5🏃‍➡\Zn' 
  8 '👋 Nothing, just exit \Zb\Z1🔚\Zn' 'I will try next time...'
  )

declare -r -A main_menu_key_labels=(
  ['inst_oc']='🆙 Install Opencart 🛒' 
  ['reinst_oc']='🔄 Reinstall Opencart 🛒'
  ['inst_lemp']='🌐Install LEMP only 🆖'
  ['inst_ioncube']='🛅 Install ionCube only 🤑'
  ['inst_ssl']='🔒 Install SSL Lets Encrypt Certbot only 🔗'
  ['inst_template']='📝 Install free OC template 🛒'
  ['cmd']='🏃‍➡ Run some command on server'  
  ['exit']='👋 Nothing, just exit 🔚'
)  

declare -r -a RELEASES=(
 1 "v.3:  Official Maintainence Branch 3.0.x.x (3.0.4.1)" "Official from opencart $URL1"
 2 "v.3:  DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)" "Development branch $URL2"
 3 "v.3:👌Custom Branch 3.0.x.x (3.0.4.1)" "Custom branch with some enhancements $URL3"
 4 "v.3:  Custom DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)" "Custom development branch $URL4"
 5 "v.4:  Official latest release 4.x.x" "Latest release from Opencart $URL5"
 6 "\Zb\Z1Exit, terminate\Zn, next time, no choice" "Do nothing, please exit"		 
 )

getArrayString () {
 arr=("$@")
 echo "Configuring: $(printf '%s|' "${arr[@]}" | awk -v var="$1" -F '|' '{print $var}')"
}
 	
Y_START=2
LMARGIN=2
DLGHEIGHT=15
DLGWIDTH=70

let TAILY_START=DLGHEIGHT+Y_START+2
TAIL1WIDTH=45
TAIL1HEIGHT=12
TAIL1SIZE="$TAIL1HEIGHT $TAIL1WIDTH"
TAIL2WIDTH=45
TAIL2HEIGHT=7
TAIL2SIZE="$TAIL2HEIGHT $TAIL2WIDTH"
TAIL1LMARGIN="$LMARGIN"
let TAIL2Y_START=TAIL1WIDTH+LMARGIN+3
 

TAIL1BEGIN="--begin $TAILY_START $LMARGIN"
TAIL2BEGIN="--begin $TAILY_START $TAIL2Y_START"
DLGBEGIN="--begin $Y_START $LMARGIN"
DLGSIZE="$DLGHEIGHT $DLGWIDTH"


	  
# Runtime data
connection_report_file="$(mktemp -p /tmp opencart-terminal-connection-report-XXXXX)"
last_reqresp_file="$(mktemp -p /tmp opencart-terminal-last-reqresp-XXXXX)"
app_cmd_out_file="$(mktemp -p /tmp opencart-terminal-app-cmd-output-XXXXX)"
form_submission_file="$(mktemp -p /tmp opencart-terminal-form-submission-XXXXX)"
tempfile=`(tempfile) 2>/dev/null` || tempfile=/tmp/test$$


declare -A lemp_status
for lemp_part in "${lemp_parts[@]}"; do
  lemp_status["$lemp_part"]="$caption_unknown"
done

# Application configuration read from and persisted into a text file
mydomain='reallymyopencart.site'
mydomain="${mydomain:-}"
port_plainsocket="${port_plainsocket:-}"
port_dnsd="${port_dnsd:-}"
port_smtpd="${port_smtpd:-}"
port_snmpd="${port_snmpd:-}"
port_httpd="${port_httpd:-}"
port_httpsd="${port_httpsd:-}"
port_qotd="${port_qotd:-}"
snmp_community_string="${snmp_community_string:-}"
app_cmd_pass="${app_cmd_pass:-}"
app_cmd_endpoint="${app_cmd_endpoint:-}"
low_bandwidth_mode="${low_bandwidth_mode:-}"


TAILBOXES=" --backtitle "$BACKTITLE" --keep-window $TAIL1BEGIN --title 'Connection mydomain'  --tailboxbg $connection_report_file $TAIL1SIZE --and-widget  $TAIL2BEGIN --title 'Last contact' --tailboxbg $last_reqresp_file $TAIL2SIZE"

TAIL1TITLE="Connection \Zb\Z5$mydomain\Zn 🌐"
TAIL2TITLE="Status report \Zb\Z2🌹\Zn"

# Clean up after temporary files and background jobs on exit
clean_up_before_exit() {
  rm -f "tempfile" \
        "$connection_report_file" "$last_reqresp_file" \
        "$app_cmd_out_file" "$form_submission_file" || true
#  readarray -t bg_jobs < <(jobs -p)
#  if [ "${#bg_jobs[@]}" -gt 0 ]; then
#    kill "${bg_jobs[@]}" &>/dev/null || true
#  fi
}
on_exit() {
  clean_up_before_exit
  # The terminal program is not expected to exit using the exit code of external command "dialog"
  exit 0
}
#trap on_exit EXIT INT TERM
trap on_exit 0 $SIG_NONE $SIG_HUP $SIG_INT $SIG_QUIT $SIG_TERM

################################################################################
# Main menu
################################################################################
dialog_main_menu() {
  while true; do
    exec 5>&1
    main_menu_choice=$(
    dialog    \
	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	  --title "Main Menu" \
	  --item-help \
	  --colors	\
	  --menu "Welcome to opencart terminal! What are we going to do?" \
	     $DLGSIZE 10 \
		"${ACTIONS[@]}" \
    2>&1 1>&5 || true
    )
    exec 5>&-
    if [ ! "$main_menu_choice" ]; then
      echo 'Thanks for using opencart terminal, see you next time!'
      exit 0
    fi

    case "$main_menu_choice" in
      1)dialog_inst_oc;;
      2)dialog_reinst_oc;;
      3)dialog_inst_lemp;;
      4)dialog_inst_ioncube;;
      5)dialog_inst_ssl;;
      6)dialog_inst_template;;
      7)dialog_cmd;;
      8)exit 1;;  
      *)
        echo "unexpected menu choice \"$main_menu_choice\", this is a programming error." >&2
        exit 1
        ;;
    esac
  done
}
################################################################################
# Main menu
################################################################################
dialog_main_menu1111() {
  while true; do
    exec 5>&1
    main_menu_choice=$(
    dialog    \
	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	  --title "Main Menu" \
	  --radiolist "Welcome to opencart terminal! What are we going to do?" \
	     $DLGSIZE 10 \
        "${main_menu_key_labels['inst_oc']}" '' 'ON' \
        "${main_menu_key_labels['reinst_oc']}" '' '' \
        "${main_menu_key_labels['inst_lemp']}" '' '' \
        "${main_menu_key_labels['inst_ioncube']}" '' '' \
        "${main_menu_key_labels['inst_ssl']}" '' '' \
        "${main_menu_key_labels['inst_template']}" '' '' \
        "${main_menu_key_labels['cmd']}" '' '' \
    2>&1 1>&5 || true
    )
    exec 5>&-
    if [ ! "$main_menu_choice" ]; then
      echo 'Thanks for using opencart terminal, see you next time!'
      exit 0
    fi

    case "$main_menu_choice" in
      "${main_menu_key_labels['inst_oc']}") dialog_inst_oc;;
      "${main_menu_key_labels['reinst_oc']}") dialog_reinst_oc;;
      "${main_menu_key_labels['inst_lemp']}") dialog_inst_lemp;;
      "${main_menu_key_labels['inst_ioncube']}") dialog_inst_ioncube ;;
      "${main_menu_key_labels['inst_ssl']}") dialog_inst_ssl;;
      "${main_menu_key_labels['inst_template']}") dialog_inst_template;;
      "${main_menu_key_labels['cmd']}") dialog_cmd;;
      "${main_menu_key_labels['exit']}") exit 1;;	  
      *)
        echo "unexpected menu choice \"$main_menu_choice\", this is a programming error." >&2
        exit 1
        ;;
    esac
  done
}


################################################################################
# Communicate with opencart server
################################################################################
invoke_app_command() {
  # cmd is the opencart app command without leading password PIN
  local cmd
  cmd="$1"
  echo -e "REQ: $cmd\nRESP: " > "$last_reqresp_file"
  local endpoint
  endpoint="https://$mydomain:$port_httpd""$app_cmd_endpoint"
  #if [ "$low_bandwidth_mode" ] && [ "$port_httpd" ] || [ ! "$port_httpsd" ]; then
  #  # In low bandwidth mode, sacrifice security for much shorter round trip by avoiding TLS handshake.
  #  endpoint="http://$mydomain:$port_httpd""$app_cmd_endpoint"
  #fi
  curl --no-progress-meter -X POST --max-time 90 "$endpoint" -F "cmd=$app_cmd_pass""$cmd" &> "$app_cmd_out_file" || true
  cat "$app_cmd_out_file" >> "$last_reqresp_file"
}

################################################################################
# Background connection status reporting
################################################################################
loop_get_latest_reqresp() {
  truncate -s 0 "$last_reqresp_file"
  printf 'Use the main Menu to get started' >> "$last_reqresp_file"
}

write_conn_status_file() {
  truncate -s 0 "$connection_report_file"
  for lemp_part in "${lemp_parts[@]}"; do
    printf '%-20s %s\n' "$lemp_part" "${lemp_status[$lemp_part]}" >> "$connection_report_file"
  done
  echo -en "\nTested at: $(date --rfc-3339=seconds)" >> "$connection_report_file"
}

loop_get_latest_conn_status() {
  while true; do
  # 'NGINX server' 'MySQL server' 'PHP stack' 'PHP-FMP module' 'SSL certbot' 'Site' 'Linux'
    if [ "$mydomain" ]; then
      timeout "$probe_timeout_sec" socat /dev/null "TCP:$mydomain:$port_httpd" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['NGINX server']=$port_status
      write_conn_status_file

      timeout "$probe_timeout_sec" socat /dev/null "TCP:$mydomain:$port_httpsd" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['MySQL server']=$port_status
      write_conn_status_file

      timeout "$probe_timeout_sec" nslookup "-port=$port_dnsd" 'github.com' "$mydomain" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['PHP stack']=$port_status
      write_conn_status_file

      timeout "$probe_timeout_sec" socat /dev/null "TCP:$mydomain:$port_smtpd" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['PHP-FMP module']=$port_status
      write_conn_status_file

      timeout "$probe_timeout_sec" socat /dev/null "TCP:$mydomain:$port_plainsocket" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['SSL certbot']=$port_status
      write_conn_status_file

      echo "$probe_timeout_sec" snmpwalk -v 2c -c "$snmp_community_string" "$mydomain:$port_snmpd" "$snmp_oid_opencart_ip" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['Site']=$port_status
      write_conn_status_file

      timeout "$probe_timeout_sec" socat /dev/null "TCP:$mydomain:$port_qotd" &>/dev/null && port_status=$caption_online || port_status=$caption_offline
      lemp_status['Linux']=$port_status
      write_conn_status_file
    else
      echo 'Please visit menu "Configure opencart"' > "$connection_report_file"
    fi
    sleep "$probe_timeout_sec"
  done
}

################################################################################
# Dialog - install Opencart
################################################################################
dialog_inst_oc() {

#TAILBOXES
  dialog \
	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
    --title '🛠️ Configure opencart and more' \
    --mixedform "The settings for your opencart server are saved to $conf_file" \
	   $DLGSIZE 9 \
      'What is your domain?' 1 0 "$mydomain"     1 32 200 0 0 \
      '' 2 0 '' 2 0 0 0 0 \
      'On which port does the server run... (leave empty if unused)' 3 0 '' 3 0 0 0 0 \
      'HTTP port'                      4 0 "$port_httpd"       4 32 8 0 0 \
      'HTTPS port'                     5 0 "$port_httpsd"      5 32 8 0 0 \
      'DNS port'                       6 0 "$port_dnsd"        6 32 8 0 0 \
      'SMTP port'                      7 0 "$port_smtpd"       7 32 8 0 0 \
      'SNMP port'                      8 0 "$port_snmpd"       8 32 8 0 0 \
      'Telnet - plain socket port'     9 0 "$port_plainsocket" 9 32 8 0 0 \
      'Simple IP service - QOTD port' 10 0 "$port_qotd"       10 32 8 0 0 \
      '' 11 0 '' 11 0 0 0 0 \
      'In order to execute app commands on your opencart server...' 12 0 '' 12 0 0 0 0 \
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
mydomain="${form_fields[0]}"
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
    # Re-execute this terminal program for background functions to pick up new configuration
    clean_up_before_exit
    exec "$self_exe"
  fi
}

################################################################################
# Dialog - commands and related
################################################################################
dialog_app_command_in_progress() {
  local bandwidth_mode
  bandwidth_mode=''
  if [ "$low_bandwidth_mode" ]; then
    bandwidth_mode='(low bandwidth mode)'
  fi
  dialog \
    --sleep 1 \
    --backtitle "$BACKTITLE" \
    --begin 2 50 --title "Running command $bandwidth_mode" \
	--infobox "Please wait, this may take couple of seconds." 10 45 || true
}

dialog_app_command_done() {
  dialog \
   	 --backtitle "$BACKTITLE" \
   	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
		--and-widget --keep-window --begin 2 50 --title 'Command result (scroll with Left/Right/Up/Down)' --textbox "$app_cmd_out_file" 21 70 || true
}

dialog_simple_info_box() {
  local info_box_txt
  info_box_txt="$1"
  dialog \
    --sleep 3 \
    --backtitle "$BACKTITLE" \
    --begin 2 50 --title 'Notice' --infobox "$info_box_txt" 10 45 || true
}

################################################################################
# Dialog - reinstall Opencart
################################################################################
dialog_reinst_oc() {
#       "${ACTIONS[1][1]}" '' '' \
  dialog \
 	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   --colors	\
	   --title "$(getArrayString "6" "${ACTIONS[@]}")" \
	   --mixedform "$(getArrayString "7" "${ACTIONS[@]}")" \
	  	 $DLGSIZE 9 \
      'List tests'                       1 0 ''     1  0   0 0 0 \
      'test account nick name'           2 0 ''     2 32 200 0 0 \
      'Skip latest N tests'              3 0 '0'    3 32 200 0 0 \
      'And then list N tests'            4 0 '10'   4 32 200 0 0 \
      '------------------------------'    5 0 ''     5 0    0 0 0 \
      'Read tests'                        6 0 ''     6  0   0 0 0 \
      'test account nick name'           7 0 ''     7 32 200 0 0 \
      'test message number'              8 0 ''     8 32 200 0 0 \
      '------------------------------'    9 0 ''     9  0   0 0 0 \
      'Send test'                       10 0 ''    10  0   0 0 0 \
      'To address'                       11 0 ''    11 32 200 0 0 \
      'Subject'                          12 0 ''    12 32 200 0 0 \
      'Content'                          13 0 ''    13 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  readarray -t form_fields < "$form_submission_file"
  if [ -s "$form_submission_file" ]; then
    list_acct_nick="${form_fields[0]}"
    list_skip_count="${form_fields[1]}"
    list_get_count="${form_fields[2]}"

    read_acct_nick="${form_fields[3]}"
    read_num="${form_fields[4]}"

    send_to_addr="${form_fields[5]}"
    send_subject="${form_fields[6]}"
    send_content="${form_fields[7]}"
    # Figure out which function user would like to use
    if [ "$list_acct_nick" ]; then
      invoke_app_command ".il $list_acct_nick $list_skip_count $list_get_count" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$read_acct_nick" ]; then
      invoke_app_command ".ir $read_acct_nick $read_num" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$send_to_addr" ]; then
      invoke_app_command ".m $send_to_addr \"$send_subject\" $send_content"
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    else
      dialog_simple_info_box "Please complete any section of the form to use that app."
      dialog_reinst_oc
    fi
  fi
}

################################################################################
# Dialog - install LEMP
################################################################################
dialog_inst_lemp() {
  dialog \
 	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	   --title "$(getArrayString "9" "${ACTIONS[@]}")" \
	   --mixedform "$(getArrayString "10" "${ACTIONS[@]}")" \
  	   $DLGSIZE 9 \
      'Sample1' 1 0 ''     1  0   0 0 0 \
      'Sample2'     2 0 ''     2 32 200 0 0 \
      'message'                     3 0 ''     3 32 200 0 0 \
      '------------------------------'    4 0 ''     4 0    0 0 0 \
      'Send Sample1'                       5 0 ''     5  0   0 0 0 \
      'To sample'             6 0 ''     6 32 200 0 0 \
      'Text message'                      7 0 ''     7 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  readarray -t form_fields < "$form_submission_file"
  if [ -s "$form_submission_file" ]; then
    dial_number="${form_fields[0]}"
    speak_message="${form_fields[1]}"

    send_to_number="${form_fields[2]}"
    text_message="${form_fields[3]}"
    # Figure out which function user would like to use
    if [ "$dial_number" ]; then
      invoke_app_command ".pc $dial_number $speak_message" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$send_to_number" ]; then
      invoke_app_command ".pt $send_to_number $text_message" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    else
      dialog_simple_info_box "Please complete any section of the form to use that app."
      dialog_inst_lemp
    fi
  fi
}

################################################################################
# Dialog - install ionCube Loader
################################################################################
dialog_inst_ioncube() {
  dialog \
     	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	   --title "$(getArrayString "12" "${ACTIONS[@]}")" \
	   --mixedform "$(getArrayString "13" "${ACTIONS[@]}")" \
  	   $DLGSIZE 9 \
      'Read latest inst_ioncubes from home timeline' 1 0 ''     1  0   0 0 0 \
      'Skip latest N inst_ioncubes'                  2 0 '0'    2 32 200 0 0 \
      'And then read N inst_ioncubes'                3 0 '10'   3 32 200 0 0 \
      '------------------------------'        4 0 ''     4 0    0 0 0 \
      'Post a inst_ioncube'                          5 0 ''     5  0   0 0 0 \
      'Content'                               6 0 ''     6 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  readarray -t form_fields < "$form_submission_file"
  if [ -s "$form_submission_file" ]; then
    skip_n_inst_ioncubes="${form_fields[0]}"
    read_n_inst_ioncubes="${form_fields[1]}"

    inst_ioncube_content="${form_fields[2]}"
    # Figure out which function user would like to use
    # The read inst_ioncube fields use default values, hence check posting of new inst_ioncube first.
    if [ "$inst_ioncube_content" ]; then
      invoke_app_command ".tp $inst_ioncube_content" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$read_n_inst_ioncubes" ]; then
      invoke_app_command ".tg $skip_n_inst_ioncubes $read_n_inst_ioncubes" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    else
      dialog_simple_info_box "Please complete any section of the form to use that app."
      dialog_inst_ioncube
    fi
  fi
}

################################################################################
# Dialog - install SSL and Certbot
################################################################################
dialog_inst_ssl() {
  dialog \
     	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	   --title "$(getArrayString "15" "${ACTIONS[@]}")" \
	   --mixedform "$(getArrayString "16" "${ACTIONS[@]}")" \
  	   $DLGSIZE 9 \
      'Get the latest ssl'        1 0 ''     1  0   0 0 0 \
      'Skip latest ssl'         2 0 '0'    2 32 200 0 0 \
      'And then read ssl'            3 0 '10'   3 32 200 0 0 \
      '------------------------------'      4 0 ''     4 0    0 0 0 \
      'Ask ssl'  5 0 ''     5  0   0 0 0 \
      'Inquiry (in free form text)'            6 0 ''     6 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  readarray -t form_fields < "$form_submission_file"
  if [ -s "$form_submission_file" ]; then
    skip_n_feeds="${form_fields[0]}"
    read_n_feeds="${form_fields[1]}"

    ssl_query="${form_fields[2]}"
    # Figure out which function user would like to use
    # The read  uses default values, hence check inquiry first.
    if [ "$ssl_query" ]; then
      invoke_app_command ".w $ssl_query" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$read_n_feeds" ]; then
      invoke_app_command ".r $skip_n_feeds $read_n_feeds" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    else
      dialog_simple_info_box "Please complete any section of the form to use that app."
      dialog_inst_ssl
    fi
  fi
}

################################################################################
# Dialog - install some useful Opencart template
################################################################################
dialog_inst_template() {
  dialog \
     	 --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	   --title "$(getArrayString "18" "${ACTIONS[@]}")" \
	   --mixedform "$(getArrayString "19" "${ACTIONS[@]}")" \
  	   $DLGSIZE 9 \
      'Get     authentication code'         1 0 ''     1  0   0 0 0 \
      'The remaining decryption key'        2 0 ''     2 32 200 0 0 \
      'Search for account'                  3 0 ''     3 32 200 0 0 \
      '------------------------------'      4 0 ''     4  0   0 0 0 \
      'Find in encrypted text'              5 0 ''     5  0   0 0 0 \
      'File shortcut word'                  6 0 ''     6 32 200 0 0 \
      'The remaining decryption key'        7 0 ''     7 32 200 0 0 \
      'Search for'                          8 0 ''     8 32 200 0 0 \
      '------------------------------'      9 0 ''     9  0   0 0 0 \
      'Find in plain text'                 10 0 ''    10  0   0 0 0 \
      'File word'                          11 0 ''    11 32 200 0 0 \
      'Search for'                         12 0 ''    12 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  readarray -t form_fields < "$form_submission_file"
  if [ -s "$form_submission_file" ]; then
    twofa_decrypt_key="${form_fields[0]}"
    twofa_search="${form_fields[1]}"

    enc_shortcut="${form_fields[2]}"
    enc_decrypt_key="${form_fields[3]}"
    enc_search="${form_fields[4]}"

    plain_shortcut="${form_fields[5]}"
    plain_search="${form_fields[6]}"
    # Figure out which function user would like to use
    if [ "$twofa_search" ]; then
      invoke_app_command ".2 $twofa_decrypt_key $twofa_search" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$enc_search" ]; then
      invoke_app_command ".a $enc_shortcut $enc_decrypt_key $enc_search" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$plain_search" ]; then
      invoke_app_command ".g $plain_shortcut $plain_search" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    else
      dialog_simple_info_box "Please complete any section of the form to use that app."
      dialog_inst_template
    fi
  fi
}

################################################################################
# Dialog - run command and inspect server status
################################################################################
dialog_cmd() {
  dialog \
       --backtitle "$BACKTITLE" \
	   --keep-window $TAIL1BEGIN --title "$TAIL1TITLE" --colors	\
  	   --tailboxbg $connection_report_file $TAIL1SIZE \
	   --and-widget  $TAIL2BEGIN --title "$TAIL2TITLE" --colors	\
	    --tailboxbg $last_reqresp_file $TAIL2SIZE \
	   --and-widget --keep-window $DLGBEGIN   \
	   --title "$(getArrayString "19" "${ACTIONS[@]}")" \
	   --mixedform "$(getArrayString "20" "${ACTIONS[@]}")" \
  	   $DLGSIZE 9 \
      'Select one of the following by entering Y' 1 0 ''     1  0   0 0 0 \
      'Get the latest server info'                2 0 'y'    2 32 200 0 0 \
      'Get the latest server log'                 3 0 ''     3 32 200 0 0 \
      'Get the latest server warnings'            4 0 ''     4 32 200 0 0 \
      'Server emergency lock (careful)'           5 0 ''     5 32 200 0 0 \
      '------------------------------'            6 0 ''     6 0    0 0 0 \
      'Run this app command'                      7 0 ''     7 32 200 0 0 \
      \
  2>"$form_submission_file" || return 0
  readarray -t form_fields < "$form_submission_file"
  if [ -s "$form_submission_file" ]; then
    select_get_info="${form_fields[0]}"
    select_get_log="${form_fields[1]}"
    select_get_warn="${form_fields[2]}"
    select_emer_lock="${form_fields[3]}"

    run_app_cmd="${form_fields[4]}"
    # Figure out which function user would like to use
    # The "get latest info" field uses default value, hence check app command input first.
    if [ "$run_app_cmd" ]; then
      invoke_app_command "$run_app_cmd" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$select_get_info" ]; then
      invoke_app_command ".einfo" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$select_get_log" ]; then
      invoke_app_command ".elog" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$select_get_warn" ]; then
      invoke_app_command ".ewarn" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    elif [ "$select_emer_lock" ]; then
      invoke_app_command ".elock" &
      local bg_pid=$!
      while kill -0 "$bg_pid"; do
        dialog_app_command_in_progress
      done
      dialog_app_command_done
    else
      dialog_simple_info_box "Please complete any section of the form to use that app."
      dialog_inst_lemp
    fi
  fi
}
###############################################################################

main() {
  for prog in curl dialog; do
    if ! command -v "$prog" &>/dev/null; then
      echo "opencart terminal depends on program $prog, please install it on the computer." >&2
      exit 1
    fi
  done

  # Read configuration file
  set -a
  if [ -r "$conf_file" ]; then
    # shellcheck source=/dev/null
    source "$conf_file"
  fi
  set +a

  if [ ! "$mydomain" ]; then
    # User has not configured the terminal yet, 
	#  use the default value to give them a good hint of how the values look.
    port_plainsocket="${port_plainsocket:-23}"
    port_dnsd="${port_dnsd:-53}"
    port_smtpd="${port_smtpd:-25}"
    port_snmpd="${port_snmpd:-161}"
    port_httpd="${port_httpd:-80}"
    port_httpsd="${port_httpsd:-443}"
    port_qotd="${port_qotd:-17}"
    snmp_community_string="${snmp_community_string:-}"
    app_cmd_pass="${app_cmd_pass:-PasswordPIN}"
    app_cmd_endpoint="${app_cmd_endpoint:-/very-secret-app-command-endpoint}"
    low_bandwidth_mode="${low_bandwidth_mode:-n}"
  fi

  probe_timeout_sec=5
  if [ "$low_bandwidth_mode" == 'y' ]; then
    probe_timeout_sec=20
  fi

  loop_get_latest_reqresp &
  loop_get_latest_conn_status &
  # The main menu takes configurations over from this point and onward
  dialog_main_menu
}

main "${@:-}"