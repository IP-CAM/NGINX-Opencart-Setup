#!/bin/bash
# Bash Menu Script  
 
 
 
# thanks to https://askubuntu.com/posts/1386907/revisions
function choose_from_menu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    printf "$prompt\n"
    while true
    do
        # list all options (option list is zero-based)
        index=0 
        for o in "${options[@]}"
        do
            if [ "$index" == "$cur" ]
            then echo -e " >\e[7m$o\e[0m" # mark & highlight the current option
            else echo "  $o"
            fi
            (( index++ ))
        done
        read -s -n3 key # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]] # up arrow
        then (( cur-- )); (( cur < 0 )) && (( cur = 0 ))
        elif [[ $key == $esc[B ]] # down arrow
        then (( cur++ )); (( cur >= count )) && (( cur = count - 1 ))
        elif [[ $key == "" ]] # nothing, i.e the read delimiter - ENTER
        then break
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render
    done
    # export the selection to the requested output variable
    printf -v $outvar "${options[$cur]}"
}

#https://askubuntu.com/questions/1705/how-can-i-create-a-select-menu-in-a-shell-script

# Note that dialog is not universally available on all Linux systems(thought on Ubuntu is available)
# Script might not be compatible across different systems/releases/distributions. 
sudo apt-get -qq install dialog1
if [[ $? == 0 ]]; then
  printf "No dialog boxes availabe. Falling back to simple menu"
fi  

HEIGHT=30
WIDTH=80
CHOICE_HEIGHT=4

choose_oc() {
BACKTITLE="Please select opencart source"
TITLE="Select opencart source"
MENU="Choose one of the following options:"

OPTIONS=(1 "v.3: Official Maintainence Branch 3.0.x.x (3.0.4.1)"
         2 "v.3: DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)"
         3 "v.3: Custom Branch 3.0.x.x (3.0.4.1)"
         4 "v.3: Custom DEV Branch 3.0.x.x towards newest PHP (3.2.0.0)"
         5 "v.4: Official latest release 4.x.x"
         6 "Exit, terminate, next time, no choice"		 
		 )

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
				--output-separator '-------string1-----' \
				--checklist 'text1' 5 40 10 [ 'tag1' 'item1' 0 ] [ 'tag2' 'item2' 1 ] \
				--separator '----------string2------' \
				--inputbox 'text2' 7 40 ['init2'] \
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
			exit 1
            ;;			
esac
}

choose_oc

scripturl='https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/bootstrap-runner.sh'

bash <(  curl -Ls $scripturl )  $(  curl -Ls $argurl ) --url $sourceurl --ziproot $sourceroot