#!/bin/bash


# author: @b00010111
# Inspired by https://www.us-cert.gov/ncas/alerts/TA18-074A and the usage of remote IconLocation within windows shortcut files.
# exiftool needs to be installed, as it is needed to parase out the metadata from the .lnk files.
# to install exiftool running "sudo apt install libimage-exiftool-perl" should work on most linux systems
# please note, an amtomated install of exiftool is not part of this script 
# USAGE:
# If run without parameter debug output will not be shown and the default search path / will be searched
#-d enable debug output
#-v enable verbose output, which gives you the full exif output
#-p [search path] path to search, absolute path should be used in order to get the best results, relative path is possible though
#-f force to treat every file in the given directory (no recursive search) as .lnk file. This option should only be used against folder containing suspect files. Running it against a mounted image of a complete systems seems pointless.


#function to check for exiftool
function exiftoolcheck(){
	which exiftool &>/dev/null
	res=$?
	if [ $res -eq 1 ]
	then
		echo "exiftool not on path"
		echo "please install exiftool, or change your path to include exiftool"
		echo "under most linux systems running \"sudo apt install libimage-exiftool-perl\" should install exiftool."
		echo "Please note, an automated system is not part of this script"
		echo "exiting without searching for remote Icons in lnk files"
		exit 1
	fi
}


#funciton print usage
function usage(){
	echo "USAGE:"
	echo "if run without parameter debug output will not be shown and the default search path / will be searched"
	echo -e "-d \t\t\tenable debug output "
	echo -e "-v \t\t\tenable verbose output, which gives you the full exif output "
	echo -e "-p [search path]\tpath to search, absolute path should be used in order to get the best results, relative path is possible though"
	echo -e "-f \t\t\tforce script to treat every file under the given directory (recursive search) as .lnk file. This option should only be used against folder containing suspect files. Running it against a mounted image of a complete systems seems pointless.\n\t\t\tAnd it will most likely run for a long time, as exiftool is run against every single file."
	exit 1
}

debug=0
searchpath="/"
verbose=0
forcemode=0

#check if exiftool is in path
exiftoolcheck

# get arguments
while getopts 'dp:vf' c
do
  case $c in
    d) debug=1 ;;
    p) searchpath=$OPTARG ;;
    v) verbose=1 ;;
    f) forcemode=1 ;;
    *) usage ;;
  esac
done

pathcheck=$(echo $searchpath | grep -Ec '/$')
if [ $pathcheck -eq 0 ]
then
	echo "path given mustend with \"/\""
	echo "exiting"
	exit 1
fi


# avoid problems with whitespaces in filenames
OIFS="$IFS"
IFS=$'\n'

if [ $forcemode -eq 1 ]
then
	filelist=$(find $searchpath -type f 2>/dev/null)
else
	filelist=$(find $searchpath -iname *.lnk 2>/dev/null)
fi

for a in $filelist
do 
	if [ $debug -eq 1 ]
	then
		echo "#############################DEBUG#############################"
		ls -al $a
		echo "#############################DEBUG#############################"
	fi
	full_exif=$(exiftool $a)
	if [ $debug -eq 1 ]
	then
		echo "#############################DEBUG#############################"
		echo "$full_exif"
		echo "#############################DEBUG#############################"
	fi
	flag_iconfile=$(grep -cE '^Flags.*:.*IconFile.*$' <<< "$full_exif")
	if [ $flag_iconfile == 1 ]
	then
		if [ $debug -eq 1 ]
		then
			echo "#############################DEBUG#############################"
			echo $flag_iconfile
			echo "#############################DEBUG#############################"
		fi
		iconfilename=$(grep -E '^Icon\ File\ Name.*$' <<< "$full_exif"  | cut -d ' ' -f 22-)
		#echo $iconfilename
		remoteIcon=$(grep -c '^//' <<< $iconfilename)
		if [ $remoteIcon -ge 1 ]
		then
			echo "possible remote ICON found"
			echo "File: $a"
			echo -e "Icon Path: $iconfilename\n"
			if [ $verbose -eq 1 ]
			then
				echo "$full_exif"
				echo -e "\n\n"
			fi
		fi
	fi
done

# rebuild IFS
IFS="$OIFS"
