#!/bin/bash

fake=$(mktemp -d)

abspath=$(realpath "$0")
path_to_seatermusb_dir="${abspath%/*}"

if [ -d "$fake" ]
then
	echo "fake root directory is at : $fake"
	
	# yeah, so SeatermUSB-SBE56.jar expects a few directories to show up, so we fake them !
	
	# Java expects ftd2xxj library to be found in java.library.path, which is ok
	# But SeatermUSB-SBE56.jar also (wrongly ?) expect "ftd2xxj.dll" to be in the _working dir_ ("user.dir")
	# I'm not a huge fan of overriding the working directory location because of
	# the side effect on relative paths, but absolute locations seems to be working
	# notably this seems to break the webserver for display the help file

	mkdir -p "$fake/userprofile"
	mkdir -p "$fake/system32"
	
	touch "$fake/system32/ftd2xx.dll"
	touch "$fake/system32/ftd2xx64.dll"
	
	ldpreload=''
	if [ -e "$1" ]
	then
		ldpreload="$1"
	fi
	
	LD_PRELOAD="$ldpreload" LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"$path_to_seatermusb_dir" userprofile="$fake/userprofile" USERPROFILE="$fake/userprofile" SystemRoot="$fake" java \
		-Djava.library.path="$path_to_seatermusb_dir" \
		-Duser.dir="$path_to_seatermusb_dir" \
		-jar "$path_to_seatermusb_dir/SeatermUSB-SBE56.jar"

	# clean up
	rm -Rf "$fake"
fi