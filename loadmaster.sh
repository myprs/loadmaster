#!/bin/sh


DEBUG=${DEBUG:-0}

RSYNCBIN="/usr/bin/rsync"
RSYNCOPTS="-a  --ignore-existing --progress"

GREPBIN="/bin/grep"
FINDBIN="/usr/bin/find"
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

	# actions	
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
				eval $COMMAND
			fi
		;;
		*)
			echo "ERROR: internal error: in function \"parse_RENEWFILE_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac
	
}

parse_MOVEFILE_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_MOVEFILE_line\" should never be called with an empty parameter set. This should never happen by design. aborting!"; exit -240 ; }

	# parse 
	shift
	local SRCFILE="$1"
	[ -z "$SRCFILE" ] && { echo "ERROR: no source file given in MOVEFILE statement in line $LINECOUNTER. Aborting!"; exit 241; }
	[ $DEBUG -ge 2 ] && echo "DEBUG2: MOVEFILE SRCFILE was set to \"$SRCFILE\""

	shift
	# normalise directory
	local DESTDIR="`dirname "$1"`/`basename "$1"`"
	[ -z "$DESTDIR" ] && { echo "ERROR: no destination directory given in MOVEFILE statement in line $LINECOUNTER. Aborting!"; exit 242; }

	shift
	# check for excess information
	[ -n "$1" ] && { echo "ERROR: superfluous characters \"$*\" at end of line $LINECOUNTER", Aborting; exit 243; }

	[ $DEBUG -ge 2 ] && echo "DEBUG2: MOVEDIR COMAND was set to \"$DESTDIR\""

	case "$MODE" in
		"loadit")
			[ -d "$SRCFILE" ] && { echo "ERROR: source file \"$SRCFILE\ must not be a directory. Aborting!"; exit 244; }
			[ -L "$SRCFILE" ] && { echo "ERROR: source file \"$SRCFILE\ must not be a link. Aborting!"; exit 245; }
			[ -r "$SRCFILE" ] || { echo "ERROR: no source file \"$SRCFILE\" found or inaccessible for me. Aborting!"; exit 246; }
			[ -d "$DESTDIR" ] || { mkdir -p "$DESTDIR"; echo "INFO: MOVEDIR: created destination directory \"$DESTDIR\"."; }
		;;
		"shipit")
			[ -L "$SRCFILE" ] && { echo "ERROR: source file \"$SRCFILE\ must not be a link. Aborting!"; exit 245; }
			
			# move file to destination
			[ $DEBUG -ge 2 ] && echo "DEBUG2: MOVEDIR COMAND: moving file \"$SRCFILE\" to \"$DESTDIR\""
			mv "$SRCFILE" "$DESTDIR/."

			# create link
			[ $DEBUG -ge 2 ] && echo "DEBUG2: MOVEDIR COMAND: linked \"$SRCFILE\" to \"$DESTDIR/`basename "$SRCFILE"`\""
			ln -s "$DESTDIR/`basename "$SRCFILE"`" "$SRCFILE"
		;;
		*)
			echo "ERROR: internal error: in function \"parse_MOVEFILE_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
		;;
	esac

}

parse_MOVEDIR_line () {

	[ -z "$1" ] && { echo "ERROR: Internal Error: Function \"parse_MOVEDIR_line\" should never be called with an empty parameter set. This should never happen by design. aborting!"; exit -220 ; }
	
	# parse 
	shift
	# normalise directory
	local SRCDIR="`dirname "$1"`/`basename "$1"`"
	[ -z "$SRCDIR" ] && { echo "ERROR: no source directory given in MOVEDIR statement in line $LINECOUNTER. Aborting!"; exit 221; }
	[ $DEBUG -ge 2 ] && echo "DEBUG2: MOVEDIR SRCDIR was set to \"$SRCDIR\""

	shift
	# normalise directory
	local DESTDIR="`dirname "$1"`/`basename "$1"`"
	[ -z "$DESTDIR" ] && { echo "ERROR: no destination directory given in MOVEDIR statement in line $LINECOUNTER. Aborting!"; exit 222; }

	shift
	# check for excess information
	[ -n "$1" ] && { echo "ERROR: superfluous characters \"$*\" at end of line $LINECOUNTER", Aborting; exit 223; }

	[ $DEBUG -ge 2 ] && echo "DEBUG2: MOVEDIR COMAND was set to \"$DESTDIR\""

	case "$MODE" in
		"loadit")
			[ -d "$SRCDIR" ] || { echo "ERROR: source directory \"$SRCDIR\" in MOVEDIR statement in line $LINECOUNTER found. Aborting!"; exit 224; }
			[ -d "$DESTDIR" ] || { mkdir -p "$DESTDIR"; echo "INFO: MOVEDIR: created destination directory \"$DESTDIR\"."; }
		;;
		"shipit")
			# rsync
			"$RSYNCBIN" $RSYNCOPTS "$SRCDIR" "$DESTDIR"

			if [ -d "$SRCDIR" ] ;
			then
				# remove source if not already a link to the right destination and link it 
				rm -rf "$SRCDIR"
				ln -s "$DESTDIR/`basename "$SRCDIR"`" "$SRCDIR" 
			else
				if [ -L "$SRCDIR" ] ;
				then
					# check if link points to the correct location
					FOUND=`$FINDBIN / -name "$SRCDIR" -lname "^$DESTDIR$" | wc -l`
					if [ $RESULT -ne 1 ] ;
					then
						# link points to the wrong location, abort!
						echo "ERROR: MOVEDIR found that link \"$SRCDIR\" points to the wrong location. Please check manually. Aborting!"

					fi
				fi
			fi
		;;
		*)
			echo "ERROR: internal error: in function \"parse_MOVEDIR_line\" variable mode did have an unknown value of \"$MODE\". Aborting!"
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
		"MOVEFILE")
			parse_MOVEFILE_line $*
		;;
		"MOVEDIR")
			parse_MOVEDIR_line $*
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
		eval $STARTCMD 
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

