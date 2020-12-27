# backupTool
======
Backup script written in bash for my system (Arch Linux) and personal datas.

## Project history
> This project was born after a bad manipulation and the removal of the "Luks" header from my personal hard drive. In short, sad story!

>I refuse to use Cloud services such as Google Drive.

## The tool
Here is a script to save the desired data if a .backUp folder is present in the removable disk.

$sudo ./backup.sh personal /mnt/Datas/
-> Create a "some/dir/.backUp/Arch-personal-(date).tar.gz" file

$sudo ./backup.sh encrypt personal /mnt/Datas/
>- Encrypt the file (And check if it exists or not)


**Copyright (c) @n3rada **

