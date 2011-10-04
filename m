From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 04 Oct 2011 11:41:35 +0200
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <1317130971-24173-2-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-2-git-send-email-lczerner@redhat.com>
Message-ID: <4E8AD4CF.3080609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> This commit adds new functionality in the form of new commands. Namely
> it is create, list, add and remove. This commit also changes the way how
> are commands recognised an executed. The new approach is more suitable
> for bigger number of commands.
>
> Resize command is also significantly reworked. Unlike in the old
> approach fsadm will always attempt to resize the logical volume as well,
> since this is what it is expected. Leave the --lvresize option for
> backwards compatibility, but remove it from the help. If no file system
> resides on the logical volume, only the volume will be resized.
>
> * Create command provides the functionality of creating a new logical
>    volumes including defined file system.
> * List command provides the functionality of listing useful information
>    about the logical volumes, file systems and devices.
> * Add command allows to add devices into volume groups (pool).
> * Remove command allows to remove the volumes or volume groups from the
>    system.
>
> Signed-off-by: Lukas Czerner<lczerner@redhat.com>

> @@ -96,7 +109,6 @@ tool_usage() {
>   	echo "    -e | --ext-offline  unmount filesystem before ext2/ext3/ext4 resize"
>   	echo "    -f | --force        Bypass sanity checks"
>   	echo "    -n | --dry-run      Print commands without running them"
> -	echo "    -l | --lvresize     Resize given device (if it is LVM device)"
>   	echo "    -y | --yes          Answer \"yes\" at any prompts"
>   	echo
>   	echo "  new_size - Absolute number of filesystem blocks to be in the filesystem,"


Again - no way to remove already supported option.



> @@ -115,13 +127,37 @@ error() {
>   	cleanup 1
>   }
>
> -dry() {
> +warn() {
> +	echo "$TOOL: $@">&2
> +}
> +
> +dry_nofail() {
>   	if [ "$DRY" -ne 0 ]; then
>   		verbose "Dry execution $@"
>   		return 0
>   	fi
>   	verbose "Executing $@"
> -	$@
> +	local IFS=" "
> +	eval "$*"
> +}


That looks weird ?
Dry execution has it's limits - if something fails - it cannot be be 
simulated. Going with _nofail seems to be dangerous.

So for now skip it.



> +float_math() {
> +	if [ $# -le 0 ]; then
> +		return
> +	fi
> +	result=$(LANG=C echo "scale=2; $@" | "$BC" -q 2>  /dev/null)
> +	echo "$result"
> +}
> +
> +is_natural() {
> +	case "$1" in
> +		"" | *[!0-9]*) return 1;;
> +		*) return 0;;
> +	esac
>   }


Please - split whole float_math in separate patch - I think this one could be 
easily upstreamed. Though it's adding new deps - however 'bc' is very common 
command available probably everywhere - so it should not present a problem.

(Though needs new packaging deps to be properly handled - wondering how we 
could make this easier for package maintainers)





>
>   cleanup() {
> @@ -132,54 +168,140 @@ cleanup() {
>   		verbose "Remounting unmounted filesystem back"
>   		dry "$MOUNT" "$VOLUME" "$MOUNTED"
>   	fi
> -	IFS=$IFS_OLD
>   	trap 2
>
>   	test "$1" -eq 2&&  verbose "Break detected"
>
> -	if [ "$DO_LVRESIZE" -eq 2 ]; then
> -		# start LVRESIZE with the filesystem modification flag
> -		# and allow recursive call of fsadm
> -		_FSADM_YES=$YES
> -		export _FSADM_YES
> -		unset FSADM_RUNNING
> -		test -n "$LVM_BINARY"&&  PATH=$_SAVEPATH
> -		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b "$VOLUME_ORIG"
> -	fi
> -

Again - please do not remove things you do not understand.

And also thing like this needs to be in a separate patch - not bundled in 
hundreds patch lines.




>   	# error exit status for break
>   	exit ${1:-1}
>   }
>
> +#####################################
> +# Convet the size into human readable
> +# form. size in Bytes expected
> +#####################################
> +humanize_size() {
> +	size="$1"
> +	count=0
> +	while [ ${size%%.*} -ge 1024 ]&&  [ $count -lt 7 ]; do
> +		size=$(float_math $size/1024)
> +		count=$(($count+1))
> +	done
> +	case $count in
> +		0) unit="B" ;;
> +		1) unit="KiB" ;;
> +		2) unit="MiB" ;;
> +		3) unit="GiB" ;;
> +		4) unit="TiB" ;;
> +		5) unit="PiB" ;;
> +		6) unit="EiB" ;;
> +		7) unit="ZiB" ;;
> +		8) unit="YiB" ;;
> +		*) unit="???" ;;
> +	esac
> +	echo "$size $unit"
> +}
> +

We need to make sure - using are handled in the very same way by both commands
(lvm & fsadm -  might probably require to parse lvm.conf  for 
'si_unit_consistency' option - so the user will not be confused.
(As fsadm is part of lvm2 package and this nice extensions might bring some 
unwanted confusion to users with differently configure lvm2).



> +#############################
> +# Get size of entN filesystem
> +# by reading tune2fs output
> +#############################
> +get_ext_size() {
> +	local IFS=$NL
> +	for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
> +		case "$i" in
> +			"Block size"*) bsize=${i##*  } ;;
> +			"Block count"*) bcount=${i##*  } ;;
> +			"Reserved block count"*) rbcount=${i##*  } ;;
> +			"Free blocks"*) fbcount=${i##*  } ;;
> +		esac
> +	done
> +
> +	total=$(($bcount*$bsize))
> +	TOTAL=$(humanize_size $total)
> +	used=$((($bcount-$fbcount)*$bsize))
> +	USED=$(humanize_size $used)
> +	free=$((($fbcount-$rbcount)*$bsize))
> +	FREE=$(humanize_size $free)
> +}
> +
> +############################
> +# Get size of xfs file system
> +# by reading the df output or
> +# examine file system with
> +# xfs_db tool
> +#############################
> +get_xfs_size() {
> +	local IFS=$NL
> +	if [ -z "$MOUNTED" ]; then
> +
> +		for i in $(LANG=C xfs_db -c 'sb' -c 'print blocksize fdblocks dblocks logblocks agcount' $VOLUME); do

"$XFS_DB"

"$VOLUME"


> +	line=$("$DF" -k "$VOLUME" | "$GREP" -e "$MOUNTED$" | sed -e 's/  */ /g')

"$SED"


> +	line=${line#* }
> +	total=$(echo $line | cut -d' ' -f1)

"$CUT"

Though maybe there is proably native shell way to extract things like this 
without extra execution command.


> +detect_fs_size() {
> +	if [ -z "$FSTYPE" ]; then
> +		return
> +	fi

Why ?
(Imho it's handled by case below via return 1


> +	case "$FSTYPE" in
> +		ext[234]) get_ext_size ;;
> +		xfs) get_xfs_size ;;
> +		*) return 1 ;;
> +	esac
> +	return 0
> +}
> +
>   # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
>   # (2^(60/50/40/30/20/10/0))
>   decode_size() {
>   	case "$1" in
> -	 *[eE]) NEWSIZE=$(( ${1%[eE]} * 1152921504606846976 )) ;;
> -	 *[pP]) NEWSIZE=$(( ${1%[pP]} * 1125899906842624 )) ;;
> -	 *[tT]) NEWSIZE=$(( ${1%[tT]} * 1099511627776 )) ;;
> -	 *[gG]) NEWSIZE=$(( ${1%[gG]} * 1073741824 )) ;;
> -	 *[mM]) NEWSIZE=$(( ${1%[mM]} * 1048576 )) ;;
> -	 *[kK]) NEWSIZE=$(( ${1%[kK]} * 1024 )) ;;
> +	 *[eE]) NEWSIZE=$(float_math "${1%[eE]} * 1152921504606846976") ;;
> +	 *[pP]) NEWSIZE=$(float_math "${1%[pP]} * 1125899906842624") ;;
> +	 *[tT]) NEWSIZE=$(float_math "${1%[tT]} * 1099511627776") ;;
> +	 *[gG]) NEWSIZE=$(float_math "${1%[gG]} * 1073741824") ;;
> +	 *[mM]) NEWSIZE=$(float_math "${1%[mM]} * 1048576") ;;
> +	 *[kK]) NEWSIZE=$(float_math "${1%[kK]} * 1024") ;;
>   	 *[bB]) NEWSIZE=${1%[bB]} ;;
>   	     *) NEWSIZE=$(( $1 * $2 )) ;;

Yep - separate patch for math operation.


>   	esac
> -	#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
> -	NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
>
> -	if [ $DO_LVRESIZE -eq 1 ]; then
> -		# start lvresize, but first cleanup mounted dirs
> -		DO_LVRESIZE=2
> -		cleanup 0
> -	fi

Recursion stays for now.


> +	NEWSIZE=${NEWSIZE%%.*}
> +	NEWBLOCKCOUNT=$(float_math "$NEWSIZE / $2")
> +	NEWBLOCKCOUNT=${NEWBLOCKCOUNT%%.*}
>   }
>
>   # detect filesystem on the given device
>   # dereference device name if it is symbolic link
>   detect_fs() {
> -	VOLUME_ORIG=$1
> +	VOLUME_ORIG="$1"
>   	VOLUME=${1/#"${DM_DEV_DIR}/"/}
> -	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""
> +	VOLUME=$("$READLINK" "$READLINK_E" "$DM_DEV_DIR/$VOLUME") || error "Cannot get readlink \"$1\""

Do not modify same thing in multiple patches
(The advantage of shuffling these things in front of the whole set.)




> -	MOUNTED=$("$GREP" ^"$VOLUME" "$PROCMOUNTS")
> +	MOUNTED=$("$GREP" -e "^$VOLUME " "$PROCMOUNTS")

Candidate for separate patch in front.
Assuming we currently do not handle well VGs starting with letter '-'.
So it's hidden bugfix (grep -e)


> @@ -295,17 +417,19 @@ resize_ext() {
>   	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
>   		detect_mounted&&  verbose "$RESIZE_EXT needs unmounted filesystem"&&  try_umount
>   		REMOUNT=$MOUNTED
> -		if test -n "$MOUNTED" ; then
> -			# Forced fsck -f for umounted extX filesystem.
> -			case "$-" in
> -			  *i*) dry "$FSCK" $YES -f "$VOLUME" ;;
> -			  *) dry "$FSCK" -f -p "$VOLUME" ;;
> -			esac
> -		fi
> +	fi
> +
> +	# We should really do the fsck before every resize.

Well user is always the master - if he is brave to go without it, let him do 
what he wants (i.e. destroy his fs).


> -		dry "$RESIZE_REISER" -s $NEWSIZE "$VOLUME"
> +		dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"

If a variable is under our full control, and we know the content could never 
have a space inside - we do not need to put all of them to "".
Though I do not really mind about this one.


> +make_ext() {
> +	device="$1"
> +	fstyp="$2"
> +	bsize=4
> +
> +	if [ "$YES" ]; then
> +		force="-F"
> +	fi
> +
> +	dry "mkfs.$fstyp" "$force" -b "$(($bsize*1024))" $device

I'd prefer to stay with upper case shell variable names.


>   ####################
>   # Resize filesystem
>   ####################
> -resize() {
> +resize_fs() {
>   	NEWSIZE=$2
> -	detect_fs "$1"
> +	detect_fs "$1" ||  error "Cannot get FSTYPE of \"$VOLUME\""
> +	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
> +	if [ "$NEWSIZE" ]; then
> +		is_natural $NEWSIZE ||  error "$NEWSIZE is not valid number for file system size"
> +	fi
>   	detect_device_size
>   	verbose "Device \"$VOLUME\" size is $DEVSIZE bytes"
>   	# if the size parameter is missing use device size
>   	#if [ -n "$NEWSIZE" -a $NEWSIZE<
>   	test -z "$NEWSIZE"&&  NEWSIZE=${DEVSIZE}b
> -	IFS=$NL
> +	local IFS=$NL
>   	case "$FSTYPE" in
>   	  "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
>   	  "reiserfs") resize_reiser $NEWSIZE ;;
>   	  "xfs") resize_xfs $NEWSIZE ;;
>   	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
>   	esac || error "Resize $FSTYPE failed"
> -	cleanup 0


Your recursion removal patch must be separate patch proposal.


> +		case $i in
> +			"size="*)		[ -z "$size" ]&&  size=${i##*=};;
> +			[[:digit:]]*)		[ -z "$size" ]&&  size=${i##*=};;
> +			+[[:digit:]]*)		[ -z "$size" ]&&  size=${i##*=};;
> +			-[[:digit:]]*)		[ -z "$size" ]&&  size=${i##*=};;
> +			*) error "Wrong option $i. (see: $TOOL --help)";;
> +		esac

Another separate patch - to add support  for  +-


> +
> +		[ "$GROUP" ]&&  [ "$GROUP" != "$vgname" ]&&  error "Some devices are in different"\
> +								   "group than the logical volume"\
> +								   "($lvname). Please provide unused"\

test -n  -a   !=  &&


> +	# Avoid callinf lvresize in recurse
> +	if [ "$FSADM_RESIZE_RECURSE" ]; then
> +		error "Recursive lvresize call detected! Exiting."
> +	fi

Recursion - separate patch...



> +#################################
> +# Check the device list to detect
> +# if there is not multiple groups

are

> +#################################
> +detect_device_group() {
> +	ret=0
> +	prev_vgname=""
> +	vgs=""
> +	tmp=$(mktemp)
> +
> +	LANG=C "$LVM" vgs -o vg_name,pv_name --separator ' ' --noheadings --nosuffix 2>  /dev/null | sed -e 's/^ *//' | sort | uniq>  $tmp
> +	NOT_IN_GROUP=
> +	IN_GROUP=
> +	for i in "$@"; do
> +		cur_vgname=$("$GREP" -e "$i$" "$tmp" | cut -d' ' -f1)
> +
> +		if [ -z "$cur_vgname" ]; then
> +			NOT_IN_GROUP+="$i "
> +			continue
> +		else
> +			IN_GROUP+="$i "
> +		fi
> +
> +		if [ -z "$prev_vgname" ]; then
> +			prev_vgname=$cur_vgname
> +			vgs=$cur_vgname
> +			continue;
> +		fi
> +
> +		if [ "$cur_vgname" != "$prev_vgname" ]; then
> +			ret=1
> +			vgs+=" $cur_vgname"

Avoid using bashisms as much as you could - I think we could make the shell 
script usable with traditional posix shell.

(look for checkbashism perl script)
i.e.   vgs="$vgs $cur_name"  - like you do elsewhere.



> +		if [ $lines -eq 1 ]; then
> +			vgname=$(echo $vgroups | sed -e 's/^ *//' | cut -d' ' -f1)

Assuming shell has enough power to do this on its own.

> +	dmnumber=$(cat "$PROCDEVICES" | "$GREP" device-mapper | sed -e 's/^  *//')

"$CAT"


