# backupTool
Backup script written in bash for my system (Arch Linux) and personal datas.

## Project history
This project was born after a bad manipulation and the removal of the "Luks" header from my personal hard drive. In short, sad story!

## The tool
Here is a script to save the desired data if a .backUp folder is present in the removable disk.

I use a specific .txt file where all excluded patterns are written down there (for system integrity save).

$sudo ./backup.sh personal /mnt/Datas/
>- Create a "some/dir/.backUp/<yourDistro>-personal-(date).tar.gz" file

$sudo ./backup.sh encrypt personal /mnt/Datas/
>- Encrypt the file with aes and delete the zipped one.

$sudo ./backup.sh decrypt personal
>- If the personal backup exist, then decrypt it !


## Other things
The password is entered in clear text in the backup creation file.
I don't care because the ".sh" file is stored in a hard drive encrypted by LUKS.


I am open to any changes and suggestions for improvement.


**Copyright (c) @n3rada **

