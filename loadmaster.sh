#!/bin/sh


DEBUG=${DEBUG:-0}

RSYNCBIN="/usr/bin/rsync"
GREPBIN="/bin/grep"

CALLNAME="`basename "$0"`"
CALLDIR="`dirname "$0"`"

STARTNAME="startcontainer.sh"
DEFAULTLOADINGPLAN="/etc/loadmaster/loading.plan"


parse_SETVAR_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_SETVAR_line\" should never be called with an empty parameter set. This should never happen by design. Aborting!"; exit -200 ; }


	case "$MODE" in
		"loadit")
			echo "tobeimpemented: $1; mode \"$MODE\""
		;;
		"shipit")
			echo "tobeimpemented: $1; mode \"$MODE\""
		;;
		*)
			echo "ERROR: internal error: in function \"parse_SETVAR_LINE\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac
	
}

parse_RENEWFILE_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_RENEWFILE_line\" should never be calles with an empty parameterset. This should never happen by design. aborting!"; exit -210 ; }

	# parse 
	shift
	local FILENAME="$1"
	[ -z "$FILENAME" ] && { echo "ERROR: no filename given in RENEWFILE statement in line $LINECOUNTER. Aborting!"; exit 211; }
	[ $DEBUG -ge 2 ] && echo "DEBUG2: RENEWFILE FILENAME was set to \"$FILENAME\""

	shift
	local COMMAND="$*"
	[ -z "$COMMAND" ] && { echo "ERROR: no command given in RENEWFILE statement in line $LINECOUNTER. Aborting!"; exit 212; }
	[ $DEBUG -ge 2 ] && echo "DEBUG2: RENEWFILE COMAND was set to \"$COMAND\""
	
	case "$MODE" in
		"loadit")
			# delete the file
			[ ! -e "$FILENAME" ] && { echo "ERROR: given file \"$FILENAME\" in RENEWFILE statement in line $LINECOUNTER does not exist. Aborting!"; exit 213; }
			[ $DEBUG -ge 1 ] && echo "DEBUG: RENEWFILE is deleting \"$FILENAME\""
			rm -f "$FILENAME"
		;;
		"shipit")
			# recreate the file if missing
			if [ -e "$FILENAME" ] ;
			then
				 echo "INFO: RENEWFILE \"$FILENAME\" found, so just keeping it."
			else
				[ $DEBUG -ge 1 ] && echo "DEBUG: RENEWFILE is executing \"$COMMAND\""
				$COMMAND
			fi
		;;
		*)
			echo "ERROR: internal error: in function \"parse_RENEWFILE_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac
	
}

parse_PUBLISHFILE_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_PUBLISHFILE_line\" should never be called with an empty parameter set. This should never happen by design. aborting!"; exit -220 ; }
	
	case "$MODE" in
		"loadit")
			echo "tobeimpemented: $1; mode \"$MODE\""
		;;
		"shipit")
			echo "tobeimpemented: $1; mode \"$MODE\""
		;;
		*)
			echo "ERROR: internal error: in function \"parse_PUBLISHFILE_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac
	
}

parse_PUBLISHDIR_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_PUBLISHDIR_line\" should never be called with an empty parameter set. This should never happen by design. aborting!"; exit -220 ; }
	
	case "$MODE" in
		"loadit")
			echo "tobeimpemented: $1; mode \"$MODE\""
		;;
		"shipit")
			echo "tobeimpemented: $1; mode \"$MODE\""
		;;
		*)
			echo "ERROR: internal error: in function \"parse_PUBLISHDIR_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac
	
}

parse_STARTCMD_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_STARTCMD_line\" should never be called with an empty parameter set. This should never happen by design. aborting!"; exit -230 ; }
	
	case "$MODE" in
		"loadit")
			[ $DEBUG -ge 3 ] && echo "DEBUG3: Entered $1; mode \"$MODE\""
		;;
		"shipit")
			[ $DEBUG -ge 3 ] && echo "DEBUG3: Entered $1; mode \"$MODE\""
		;;
		*)
			echo "ERROR: internal error: in function \"parse_STARTCMD_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac

	if [ -n "$STARTCMD" ] ; 
	then

		# this seems not to be the fist invocation, so exit
		echo "ERROR: Second definition of a STARTCMD line in loadingplan \"$LOADINGPLAN\" on line $LINECOUNTER found, but only up to one is allowed. Aborting! "
		exit 231
	fi

	shift 1
	STARTCMD="$*"
	[ $DEBUG -ge 2 ] && echo "DEBUG2: STARTCMD was set to \"$STARTCMD\""
	
}

processline () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"processline\" should never be called with an empty parameter set. This should never happen by design. aborting!"; exit -100 ; }

	case "$1" in 
		"SETVAR")
			parse_SETVAR_line $*
		;;
		"RENEWFILE")
			parse_RENEWFILE_line $*
		;;
		"PUBLISHFILE")
			parse_PUBLISHFILE_line $*
		;;
		"PUBLISHDIR")
			parse_PUBLISHDIR_line $*
		;;
		"STARTCMD")
			parse_STARTCMD_line $*
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
		
		# uncomment line
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


runstartcmd () {

	
	if [ "$MODE" = "loadit" ] ; 
	then
		# on loadit we just issue a warning if we do not have defined a STARTCMD
		[ -z "$STARTCMD" ] && echo "WARNING: You seem not to have any STARTCMD line in your loadingplan! Please note that this is OK as long as you take care of starting a process in your container in your dockerfile. But please make sure that you also run loadmaster through the \"$STARTNAME\" link to make sure on every start of your container that defaults are moved and initialisations are done! Otherwise using loadmaster does not make any sense. Please see the docs on loadmaster for further information on how to use the script."
	else
		# run the command 
		{ $STARTCMD ; }
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


runstartcmd

