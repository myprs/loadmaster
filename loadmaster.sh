#!/bin/sh


RSYNC="/bin/rsync"


CALLNAME="`basename "$0"`"
CALLDIR="`dirname "$0"`"

STARTNAME="startcontainer.sh"

loadcontainer () {

	echo "I am the loadmaster!"

	echo "$CALLDIR"

	[ -L "$CALLDIR/$STARTNAME" ] || ln -s "$CALLDIR/$CALLNAME" "$CALLDIR/$STARTNAME"



}

shipcontainer () {

	echo "Ship Ahoi!"
}


case "$CALLNAME" in 
	"loadmaster.sh")
		loadcontainer
	;;
	"$STARTNAME")
		shipcontainer
	;;
	*)
	;;
esac


