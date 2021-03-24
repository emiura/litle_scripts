#!/bin/bash

DIALOG="zenity "

# get local users
local_users=$(grep home /etc/passwd | cut -d ":" -f 1)

# prepare user list
for user in $local_users; do
	output=$(xfs_quota -x -c "report -h /home" 2> /dev/null| grep "^$user" )
	username=$(echo $output | cut -d " " -f 1)
	usage=$(echo $output | cut -d " " -f 2)
	soft=$(echo $output | cut -d " " -f 3)
	hard=$(echo $output | cut -d " " -f 4)
	url="$url $username $usage $soft $hard"
done

# ask user input
selection=$($DIALOG --title "Selecione usuario" --list --column "Usuario" --column "Usado" --column "Soft" --column "Hard" $url)
if [ $? -eq 1 ]; then
       echo "canceled"
       exit 	
fi

# select quota
soft_quota=$($DIALOG --title "Soft quota" --text "K,M,G,T" --entry)
if [ $? -eq 1 ]; then
       echo "canceled"
       exit 	
fi

hard_quota=$($DIALOG --title "Hard quota" --text "K,M,G,T" --entry)
if [ $? -eq 1 ]; then
       echo "canceled"
       exit 	
fi

xfs_quota -x -c "limit bsoft=$soft_quota bhard=$hard_quota $selection" /home
output=$(xfs_quota -x -c "report -h /home" 2> /dev/null| grep "^$selection" )
username=$(echo $output | cut -d " " -f 1)
usage=$(echo $output | cut -d " " -f 2)
soft=$(echo $output | cut -d " " -f 3)
hard=$(echo $output | cut -d " " -f 4)
$DIALOG --title "Novos valores" --info --width=400 --height=200 --text "Usuario: $username Uso: $usage Softquota: $soft Hardquota: $hard"

