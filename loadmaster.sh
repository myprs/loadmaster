#!/bin/sh


DEBUG=${DEBUG:-0}

RSYNCBIN="/usr/bin/rsync"
GREPBIN="/bin/grep"

CALLNAME="`basename "$0"`"
CALLDIR="`dirname "$0"`"

STARTNAME="startcontainer.sh"
DEFAULTLOADINGPLAN="/etc/loadmaster/loading.plan"


processline () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function processwline should never be calles with an empty parameterset. This should never happen by design. aborting!"; exoit -100 ; }

	case "$1" in 
		"SETVAR")
			echo "tobeimpemented: $1"
		;;
		"RENEWFILE")
			echo "tobeimpemented: $1"
		;;
		"PUBLISHDIR")
			echo "tobeimpemented: $1"
		;;
		"STARTCMD")
			echo "tobeimpemented: $1"
		;;
		*)
			echo "ERROR: Unknown command \"$1\" in loadingplan file \"$LOADINGPLAN\" on line $LINECOUNTER. Aborting! "
			exit 101
		;;
	esac

}

readloadingplan () {

	[ $DEBUG -ge 2 ] && echo "DEBUG: I am in mode $MODE!"

	[ $DEBUG -ge 2 ] && echo "DEBUG: Calldir is \"$CALLDIR\""


	# reading in the file and calling procline function per line


	ORIGIFS="$IFS"
	IFS="
"
	LINECOUNTER=0
	while read  LINE; 
	do
		LINECOUNTER=$(( $LINECOUNTER+1 ))
		
		[ $DEBUG -ge 2 ] && echo "DEBUG2: Processing line no $LINECOUNTER: \"$LINE\""
		
		# decomment line
		LINE=`echo "$LINE"|"$GREPBIN" -v "^[[:space:]]*#.*" | "$GREPBIN" -v "^[[:space:]]*$"`
		IFS="$ORIGIFS"
		
		if [ -n "$LINE" ]; 
		then
			processline $LINE
		fi
	done <"$LOADINGPLAN"


}


checkprerequisites () {

	# Is rsync installed?
	[ -x "$RSYNCBIN" ] || { echo "ERROR: rsync binary \"$RSYNCBIN\"not found. Aborting!"; exit 2; } 

	# Is the loadingplan accessible?
	LOADINGPLAN=${1:-"$DEFAULTLOADINGPLAN"}
	[ $DEBUG -ge 1 ] && echo "DEBUG: Loadingplan is \"$LOADINGPLAN\"."
	
	[ -r "$LOADINGPLAN" ] || { echo "ERROR: Loadingplan \"$LOADINGPLAN\" is not accessible. Not existent file or no read rights? Aborting!" ; exit 3 ; }

	# Is the link present?
	if [ ! -L "$CALLDIR/$STARTNAME" ] ;
	then
		local DIRSTASH="`cd`"
		cd "$CALLDIR"
		[ $DEBUG -ge 1 ] && echo "DEBUG: Creating link \"$STARTNAME\" in directory \"$CALLDIR\"."
		ln -s "$CALLNAME" "$STARTNAME"
		[ $DEBUG -ge 1 ] && echo "DEBUG: Returning to original workdir \"$DIRSTASH\"."
		cd "$DIRSTASH"
	fi

}


checkprerequisites $1



case "$CALLNAME" in 
	"loadmaster.sh")
		MODE=loadit
	;;
	"$STARTNAME")
		MODE=shipit
	;;
	*)
		echo "ERROR: Unknown callname \"$CALLNAME\". Aborting!"
		exit 1
	;;
esac

readloadingplan

