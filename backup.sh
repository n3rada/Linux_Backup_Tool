#!/bin/bash

#####################################################
#- Backup script for my system and personal datas
#- executed by cron with param "personal" each day and 
#- with "system" each week 
#-- IF HARD DRIVE ARE PRESENT , of course
#
# .backUp need to be at max depth 2 of external drive.
#
# !! Don't forget to use the exclude-list.txt !!
#
#--- By n3rada, free to use
#--- December 2020
#####################################################


# To check if is currently running as root or not

if [[ $EUID -ne 0 ]] ; then
    echo "Please run as root."
    exit 0
fi

# Help menu
help="\n
________________________________________________\n
Please be sure to have an hard drive connected.\n
Parameters:\n
\t > personal <personalDatasPath> - for personal backup\n
\t > system - for system backup\n
\t > encrypt <otherCommand> - to encrypt your backup\n
\t > gpgDecrypt <fileWanted> - to decrypt backup\n
________________________________________________\n
"


# Parameters verification
params="encrypt personal system gpgDecrypt"

# "$params" != *"$1"* is to verify if parameter is available
if [[ $# -gt 3 || $# -eq 0 || "$params" != *"$1"* ]] ; then
    clear
    echo -e " Bad arguments."
    echo -e $help
    exit 0
fi
########
# CORE #
########

backupDir=".backUp"

date=$(date +%F)
distro=$(cat /etc/*-release | grep "DISTRIB_ID" | awk -F "=" '{print $2}') #e.g mine is Arch

media=/run/media/

execDir=$PWD
from=$2

password="yourpassword"


# Scan to see if good hardrive are plugged
cd $media

# If no hardrive are plugged, then too bad, next time !
if [[ ! $(ls) ]] ; then
    echo "No hardrive are plugged."
    exit 0
fi

for d in */ ; do
    cd $d
    
    # To locate the directory everywhere on the disk.
    newCd=$(find $PWD -maxdepth 2 -type d -name $backupDir)
    
    # If backup found , stop looping across everything dumply.
    if [[ -n $newCd ]] ; then
        echo "Backup found !"
        break
    else
        echo "No backup found."
        exit 0
    fi
done

# Backup found ! Let's continue
cd $newCd



if [[ "$1" == "system" ]] || [[ "$1" == "encrypt" && "$2" == "system" ]] ; then
    
    backupfile="$newCd/$distro-systemIntegrity-$date.tar.gz"
    
    cd $execDir
    
    # backup from root
    #rsync -aAX -s -z --update --inplace  --delete / $newCd --exclude-from='exclude-list.txt' --quiet &>/dev/null
    
    if [[ ! -e $backupfile ]] ; then
        echo "System integrity is in saving process ..."
        tar --exclude-from='exclude-list.txt' --acls --xattrs -cpf $backupfile /
    else
        echo "Backup $backupfile already exist."
        if [[ "$1" != "encrypt" ]] ; then
            exit 1
        fi
    fi
    
    if [[ "$1" == "encrypt" ]] ; then
        echo "Encrypting $backupfile ..."
        #From version 2 of GPG, the option --batch is needed to ensure no prompt
        gpg -o "$backupfile.gpg" -c --batch --yes --passphrase $password  $backupfile &>/dev/null
    fi
    
    
    echo "System integrity saved."
    echo "You can go and check to $newCd dir."
    
    exit 1
    
elif [[ "$1" == "personal" ]] || [[ "$1" == "encrypt" && "$2" == "personal" ]] ; then
    backupfile="$newCd/$distro-personal-$date.tar.gz"
    
    cd ${@: -1} && cd ..
    
    backupFrom=$(echo ${@: -1} | rev | cut -d "/" -f2 | rev)
    
    # Backup from $2
    #rsync -aAX -s -v --inplace --quiet --delete "$2" $newCd --exclude="lost+found" --exclude=.Trash* &>/dev/null
    
    if [[ ! -e $backupfile ]] ; then
        echo "Saving personal datas ..."
        tar --exclude="lost+found" --exclude=".Trash*" --acls --xattrs -cpf $backupfile $backupFrom
    else
        echo "Backup $backupfile already exist."
        if [[ "$1" != "encrypt" ]] ; then
            exit 1
        fi
    fi
    
    if [[ "$1" == "encrypt" ]] ; then
        echo "Encrypting $backupfile ..."
        #From version 2 of GPG, the option --batch is needed to ensure no prompt
        gpg -o "$backupfile.gpg" -c --batch --yes --passphrase $password  $backupfile &>/dev/null
    fi
    
    echo "Personal datas have been saved."
    
    echo "You can go and check to $newCd dir."
    
    exit 1
    
elif [[ "$1" == "gpgDecrypt" ]] ; then
    echo "Trying to decrypt $2 data(s)."
    
    gpged=$(find $PWD -maxdepth 2 -name *$2*)
    
    # If file found , stop looping across everything dumply.
    if [[ -n $gpged ]] ; then
        gpgName=$(echo $gpged | rev | cut -d "/" -f1 | rev)
        gzName=$(echo $gpgName | cut -d"." -f-3)
        
        echo "$gpgName found !"
        
        #-f - specifies that the file being unarchived is being piped in.
        gpg --output $gzName --decrypt --batch --yes --passphrase $password $gpgName 
        
        #If you want to untar, uncomment the following line
        #tar --acls --xattrs -xpf $gzName
        
        echo "Done"
        exit 1
    else
        echo "No $2 file found, nothing to decrypt."
        exit 0
    fi
    
fi




