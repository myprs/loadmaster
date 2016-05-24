#!/bin/sh


RSYNC="/bin/rsync"


CALLNAME="`basename "$0"`"
CALLDIR="`dirname "$0"`"

STARTNAME="startcontainer.sh"



readloadingplan () {

	echo "I am in mode $MODE!"

	echo "$CALLDIR"


}


checkprerequisites () {

	# Is rsync installed?

	# Is the loadingplan accessible?

	# Is the link present?
	if [ ! -L "$CALLDIR/$STARTNAME" ] ;
	then
		local DIRSTASH="`cd`"
		cd "$CALLDIR"
		ln -s "$CALLNAME" "$STARTNAME"
		cd "$DIRSTASH"
	fi

}


checkprerequisites



case "$CALLNAME" in 
	"loadmaster.sh")
		MODE=loadit
	;;
	"$STARTNAME")
		MODE=shipit
	;;
	*)
		echo "ERROR: Unknown callname \"$CALLNAME\". Aborting!"
		exit -1
	;;
esac

readloadingplan

