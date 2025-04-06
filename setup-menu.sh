#!/bin/bash
# Bash Menu Script  
 
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
 
whiptail_menu() {
whiptail --title "Menu example" --menu "Choose an option" 25 78 16 \
"<-- Back" "Return to the main menu." \
"Modify Group" "Modify a group and its list of members. Very loooooooooooong string" \
"List Groups" "List all groups on the system."

eval `resize`
whiptail --title "Menu example" --menu "Choose an option" $LINES $COLUMNS $(( $LINES - 8 )) \
"<-- Back" "Return to the main menu." \
"Modify Group" "Modify a group and its list of members. Very loooooooooooong string" \
"List Groups" "List all groups on the system."
 
PASSWORD=$(whiptail --passwordbox "Enter your new password" 8 70 --title "New Password" 3>&1 1>&2 2>&3)
echo "Welcome to Bash $BASH_VERSION" > test_textbox

# filename height width
whiptail --textbox test_textbox 12 80

COLOR=$(whiptail --inputbox "What is your favorite Color?" 8 78 Blue --title "Example Dialog" 3>&1 1>&2 2>&3)
# The `3>&1 1>&2 2>&3` above is a small trick to swap the stderr with stdout

whiptail --title "Example Title" --yesno "This is an example yes/no box." 8 70
whiptail --title "Example Title" --msgbox "This is an example message box. Press OK to continue." 8 70
whiptail --title "Example Title" --infobox "This is an example info box." 8 70
TERM=ansi whiptail --title "Example Title" --infobox "This is an example info box" 8 70
 
 whiptail --title "Check list example" --checklist \
"Choose user's permissions" 20 78 4 \
"NET_OUTBOUND" "Allow connections to other hosts" ON \
"NET_INBOUND" "Allow connections from other hosts" OFF \
"LOCAL_MOUNT" "Allow mounting of local devices" OFF \
"REMOTE_MOUNT" "Allow mounting of remote devices" OFF

whiptail --title "Radio list example" --radiolist \
"Choose user's permissions" 20 78 4 \
"NET_OUTBOUND" "Allow connections to other hosts" ON \
"NET_INBOUND" "Allow connections from other hosts" OFF \
"LOCAL_MOUNT" "Allow mounting of local devices" OFF \
"REMOTE_MOUNT" "Allow mounting of remote devices" OFF

#!/bin/bash
{
    for ((i = 0 ; i <= 100 ; i+=5)); do
        sleep 0.1
        echo $i
    done
} | whiptail --gauge "Please wait while we are sleeping..." 6 50 0

}

# Note that dialog is not universally available on all Linux systems(thought on Ubuntu is available)
# Script might not be compatible across different systems/releases/distributions. 

#echo get debconf/frontend | debconf-communicate
# output: 0 Dialog
# whiptail -h 2>/dev/null
sudo apt-get -qq install dialog1
if [[ $? != 0 ]]; then
  printf "No dialog boxes availabe. Falling back to simple menu\n"
  sudo apt-get -qq install whiptail
  # https://github.com/JazerBarclay/whiptail-examples
  whiptail_menu
fi  
menu1

 
#oc_options_menu

scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/bootstrap-runner.sh'

bash <(  curl -Ls $scripturl )  $(  curl -Ls $argurl ) --url $sourceurl --ziproot $sourceroot