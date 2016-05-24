#!/bin/sh


DEBUG=${DEBUG:-0}

RSYNCBIN="/usr/bin/rsync"


CALLNAME="`basename "$0"`"
CALLDIR="`dirname "$0"`"

STARTNAME="startcontainer.sh"
DEFAULTLOADINGPLAN="/etc/loadmaster/loading.plan"


readloadingplan () {

	[ $DEBUG -ge 1 ] && echo "DEBUG: I am in mode $MODE!"

	[ $DEBUG -ge 1 ] && echo "DEBUG: Calldir is \"$CALLDIR\""


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

