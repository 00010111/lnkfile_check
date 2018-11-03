# lnkfile_check
bash script searches a given path and determines if .lnk files with remote IconLocation are present and print them to std out

author: @b00010111<br>
Inspired by https://www.us-cert.gov/ncas/alerts/TA18-074A and the usage of remote IconLocation within windows shortcut files.<br>
exiftool needs to be installed, as it is needed to parase out the metadata from the .lnk files.<br>
To install exiftool running "sudo apt install libimage-exiftool-perl" should work on most linux systems please note, an amtomated install of exiftool is not part of this script.<br>
USAGE:
* If run without parameter debug output will not be shown and the default search path / will be searched
* -d enable debug output
* -v enable verbose output, which gives you the full exif output
* -p [search path] path to search, absolute path should be used in order to get the best results, relative path is possible though
* -f force to treat every file in the given directory (no recursive search) as .lnk file. This option should only be used against folder containing suspect files. Running it against a mounted image of a complete systems seems pointless.

Example Usage:
lnkfile_check.sh -dvfp /evidence/suspicious_files/
* debug output -> like running exiftool against all files + additional debugging output
* verbose output -> show full exiftool output for lnk files with possible remote icon path
* force mode -> reat every file under the given directory (recursive search) as .lnk file
* path -> files /evidence/suspicious_files/ are checked by tool

lnkfile_check.sh -vp /evidence/suspicious_files/
* verbose output -> show full exiftool output for lnk files with possible remote icon path
* path -> files /evidence/suspicious_files/ are checked by tool, only files with .lnk extenstion are checked

lnkfile_check.sh -p /mnt/ntfs/vol1/
* check the mounted drive at /mnt/ntfs/vol1/
* only check files with .lnk file extentions
* show standard output:
* possible remote ICON found
* File: /mnt/ntfs/vol1/TEST.lnk
* Icon Path: //172.1.1.1/remoteIcon

lnkfile_check.sh -h
* show usage

