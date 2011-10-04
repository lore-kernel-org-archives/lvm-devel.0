From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 4 Oct 2011 14:13:13 +0200 (CEST)
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <4E8AD4CF.3080609@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-2-git-send-email-lczerner@redhat.com>
	<4E8AD4CF.3080609@redhat.com>
Message-ID: <alpine.LFD.2.00.1110041336440.4206@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 4 Oct 2011, Zdenek Kabelac wrote:

> Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> > This commit adds new functionality in the form of new commands. Namely
> > it is create, list, add and remove. This commit also changes the way how
> > are commands recognised an executed. The new approach is more suitable
> > for bigger number of commands.
> > 
> > Resize command is also significantly reworked. Unlike in the old
> > approach fsadm will always attempt to resize the logical volume as well,
> > since this is what it is expected. Leave the --lvresize option for
> > backwards compatibility, but remove it from the help. If no file system
> > resides on the logical volume, only the volume will be resized.
> > 
> > * Create command provides the functionality of creating a new logical
> >    volumes including defined file system.
> > * List command provides the functionality of listing useful information
> >    about the logical volumes, file systems and devices.
> > * Add command allows to add devices into volume groups (pool).
> > * Remove command allows to remove the volumes or volume groups from the
> >    system.
> > 
> > Signed-off-by: Lukas Czerner<lczerner@redhat.com>
> 
> > @@ -96,7 +109,6 @@ tool_usage() {
> >   	echo "    -e | --ext-offline  unmount filesystem before ext2/ext3/ext4
> > resize"
> >   	echo "    -f | --force        Bypass sanity checks"
> >   	echo "    -n | --dry-run      Print commands without running them"
> > -	echo "    -l | --lvresize     Resize given device (if it is LVM
> > device)"
> >   	echo "    -y | --yes          Answer \"yes\" at any prompts"
> >   	echo
> >   	echo "  new_size - Absolute number of filesystem blocks to be in the
> > filesystem,"
> 
> 
> Again - no way to remove already supported option.

This is only removed from the tool_usage(), as you can see. I am not
removing it from the code, but only from the documentation since it is
not needed in the new code.

> 
> 
> 
> > @@ -115,13 +127,37 @@ error() {
> >   	cleanup 1
> >   }
> > 
> > -dry() {
> > +warn() {
> > +	echo "$TOOL: $@">&2
> > +}
> > +
> > +dry_nofail() {
> >   	if [ "$DRY" -ne 0 ]; then
> >   		verbose "Dry execution $@"
> >   		return 0
> >   	fi
> >   	verbose "Executing $@"
> > -	$@
> > +	local IFS=" "
> > +	eval "$*"
> > +}
> 
> 
> That looks weird ?
> Dry execution has it's limits - if something fails - it cannot be be
> simulated. Going with _nofail seems to be dangerous.

Actually what looks weird that we call function we are executing
commands with "dry()" because it really is dry only if --dry-run has
been specified. I only coped with that, but I would be really in favour
of changing it to run() or similar.

dry_nofail() is different from dry() only in the way it handles failures
of invoked command. In dry() we are calling error() in that case, but
dry_nofail() is not calling error, but rather report the return value,
so its user can handle the failure by himself. Please see where it is
used.

> 
> So for now skip it.
> 
> 
> 
> > +float_math() {
> > +	if [ $# -le 0 ]; then
> > +		return
> > +	fi
> > +	result=$(LANG=C echo "scale=2; $@" | "$BC" -q 2>  /dev/null)
> > +	echo "$result"
> > +}
> > +
> > +is_natural() {
> > +	case "$1" in
> > +		"" | *[!0-9]*) return 1;;
> > +		*) return 0;;
> > +	esac
> >   }
> 
> 
> Please - split whole float_math in separate patch - I think this one could be
> easily upstreamed. Though it's adding new deps - however 'bc' is very common
> command available probably everywhere - so it should not present a problem.

I can do that, however it is just one step in allowing float math in
fsadm. I have done that so we have easier work in the future and because
it is useful, but I have no intention of making fsadm fully float number
aware, at least for now.

> 
> (Though needs new packaging deps to be properly handled - wondering how we
> could make this easier for package maintainers)
> 
> 
> 
> 
> 
> > 
> >   cleanup() {
> > @@ -132,54 +168,140 @@ cleanup() {
> >   		verbose "Remounting unmounted filesystem back"
> >   		dry "$MOUNT" "$VOLUME" "$MOUNTED"
> >   	fi
> > -	IFS=$IFS_OLD
> >   	trap 2
> > 
> >   	test "$1" -eq 2&&  verbose "Break detected"
> > 
> > -	if [ "$DO_LVRESIZE" -eq 2 ]; then
> > -		# start LVRESIZE with the filesystem modification flag
> > -		# and allow recursive call of fsadm
> > -		_FSADM_YES=$YES
> > -		export _FSADM_YES
> > -		unset FSADM_RUNNING
> > -		test -n "$LVM_BINARY"&&  PATH=$_SAVEPATH
> > -		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b
> > "$VOLUME_ORIG"
> > -	fi
> > -
> 
> Again - please do not remove things you do not understand.

Oh, but I do understand. Please read the new code, before trying to
insult me. But maybe it would be better to separate resize command
changes into separate patch.

> 
> And also thing like this needs to be in a separate patch - not bundled in
> hundreds patch lines.
> 
> 
> 
> 
> >   	# error exit status for break
> >   	exit ${1:-1}
> >   }
> > 
> > +#####################################
> > +# Convet the size into human readable
> > +# form. size in Bytes expected
> > +#####################################
> > +humanize_size() {
> > +	size="$1"
> > +	count=0
> > +	while [ ${size%%.*} -ge 1024 ]&&  [ $count -lt 7 ]; do
> > +		size=$(float_math $size/1024)
> > +		count=$(($count+1))
> > +	done
> > +	case $count in
> > +		0) unit="B" ;;
> > +		1) unit="KiB" ;;
> > +		2) unit="MiB" ;;
> > +		3) unit="GiB" ;;
> > +		4) unit="TiB" ;;
> > +		5) unit="PiB" ;;
> > +		6) unit="EiB" ;;
> > +		7) unit="ZiB" ;;
> > +		8) unit="YiB" ;;
> > +		*) unit="???" ;;
> > +	esac
> > +	echo "$size $unit"
> > +}
> > +
> 
> We need to make sure - using are handled in the very same way by both commands
> (lvm & fsadm -  might probably require to parse lvm.conf  for
> 'si_unit_consistency' option - so the user will not be confused.
> (As fsadm is part of lvm2 package and this nice extensions might bring some
> unwanted confusion to users with differently configure lvm2).

Regardless on what I think of this "option" I'll try to look at this.

> 
> 
> 
> > +#############################
> > +# Get size of entN filesystem
> > +# by reading tune2fs output
> > +#############################
> > +get_ext_size() {
> > +	local IFS=$NL
> > +	for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
> > +		case "$i" in
> > +			"Block size"*) bsize=${i##*  } ;;
> > +			"Block count"*) bcount=${i##*  } ;;
> > +			"Reserved block count"*) rbcount=${i##*  } ;;
> > +			"Free blocks"*) fbcount=${i##*  } ;;
> > +		esac
> > +	done
> > +
> > +	total=$(($bcount*$bsize))
> > +	TOTAL=$(humanize_size $total)
> > +	used=$((($bcount-$fbcount)*$bsize))
> > +	USED=$(humanize_size $used)
> > +	free=$((($fbcount-$rbcount)*$bsize))
> > +	FREE=$(humanize_size $free)
> > +}
> > +
> > +############################
> > +# Get size of xfs file system
> > +# by reading the df output or
> > +# examine file system with
> > +# xfs_db tool
> > +#############################
> > +get_xfs_size() {
> > +	local IFS=$NL
> > +	if [ -z "$MOUNTED" ]; then
> > +
> > +		for i in $(LANG=C xfs_db -c 'sb' -c 'print blocksize fdblocks
> > dblocks logblocks agcount' $VOLUME); do
> 
> "$XFS_DB"
> 
> "$VOLUME"
> 
> 
> > +	line=$("$DF" -k "$VOLUME" | "$GREP" -e "$MOUNTED$" | sed -e 's/  */
> > /g')
> 
> "$SED"
> 
> 
> > +	line=${line#* }
> > +	total=$(echo $line | cut -d' ' -f1)
> 
> "$CUT"
> 
> Though maybe there is proably native shell way to extract things like this
> without extra execution command.
> 
> 
> > +detect_fs_size() {
> > +	if [ -z "$FSTYPE" ]; then
> > +		return
> > +	fi
> 
> Why ?
> (Imho it's handled by case below via return 1
> 
> 
> > +	case "$FSTYPE" in
> > +		ext[234]) get_ext_size ;;
> > +		xfs) get_xfs_size ;;
> > +		*) return 1 ;;
> > +	esac
> > +	return 0
> > +}
> > +
> >   # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
> >   # (2^(60/50/40/30/20/10/0))
> >   decode_size() {
> >   	case "$1" in
> > -	 *[eE]) NEWSIZE=$(( ${1%[eE]} * 1152921504606846976 )) ;;
> > -	 *[pP]) NEWSIZE=$(( ${1%[pP]} * 1125899906842624 )) ;;
> > -	 *[tT]) NEWSIZE=$(( ${1%[tT]} * 1099511627776 )) ;;
> > -	 *[gG]) NEWSIZE=$(( ${1%[gG]} * 1073741824 )) ;;
> > -	 *[mM]) NEWSIZE=$(( ${1%[mM]} * 1048576 )) ;;
> > -	 *[kK]) NEWSIZE=$(( ${1%[kK]} * 1024 )) ;;
> > +	 *[eE]) NEWSIZE=$(float_math "${1%[eE]} * 1152921504606846976") ;;
> > +	 *[pP]) NEWSIZE=$(float_math "${1%[pP]} * 1125899906842624") ;;
> > +	 *[tT]) NEWSIZE=$(float_math "${1%[tT]} * 1099511627776") ;;
> > +	 *[gG]) NEWSIZE=$(float_math "${1%[gG]} * 1073741824") ;;
> > +	 *[mM]) NEWSIZE=$(float_math "${1%[mM]} * 1048576") ;;
> > +	 *[kK]) NEWSIZE=$(float_math "${1%[kK]} * 1024") ;;
> >   	 *[bB]) NEWSIZE=${1%[bB]} ;;
> >   	     *) NEWSIZE=$(( $1 * $2 )) ;;
> 
> Yep - separate patch for math operation.
> 
> 
> >   	esac
> > -	#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
> > -	NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
> > 
> > -	if [ $DO_LVRESIZE -eq 1 ]; then
> > -		# start lvresize, but first cleanup mounted dirs
> > -		DO_LVRESIZE=2
> > -		cleanup 0
> > -	fi
> 
> Recursion stays for now.
> 
> 
> > +	NEWSIZE=${NEWSIZE%%.*}
> > +	NEWBLOCKCOUNT=$(float_math "$NEWSIZE / $2")
> > +	NEWBLOCKCOUNT=${NEWBLOCKCOUNT%%.*}
> >   }
> > 
> >   # detect filesystem on the given device
> >   # dereference device name if it is symbolic link
> >   detect_fs() {
> > -	VOLUME_ORIG=$1
> > +	VOLUME_ORIG="$1"
> >   	VOLUME=${1/#"${DM_DEV_DIR}/"/}
> > -	VOLUME=$("$READLINK" $READLINK_E "$DM_DEV_DIR/$VOLUME") || error
> > "Cannot get readlink \"$1\""
> > +	VOLUME=$("$READLINK" "$READLINK_E" "$DM_DEV_DIR/$VOLUME") || error
> > "Cannot get readlink \"$1\""
> 
> Do not modify same thing in multiple patches
> (The advantage of shuffling these things in front of the whole set.)
> 
> 
> 
> 
> > -	MOUNTED=$("$GREP" ^"$VOLUME" "$PROCMOUNTS")
> > +	MOUNTED=$("$GREP" -e "^$VOLUME " "$PROCMOUNTS")
> 
> Candidate for separate patch in front.
> Assuming we currently do not handle well VGs starting with letter '-'.
> So it's hidden bugfix (grep -e)
> 
> 
> > @@ -295,17 +417,19 @@ resize_ext() {
> >   	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
> >   		detect_mounted&&  verbose "$RESIZE_EXT needs unmounted
> > filesystem"&&  try_umount
> >   		REMOUNT=$MOUNTED
> > -		if test -n "$MOUNTED" ; then
> > -			# Forced fsck -f for umounted extX filesystem.
> > -			case "$-" in
> > -			  *i*) dry "$FSCK" $YES -f "$VOLUME" ;;
> > -			  *) dry "$FSCK" -f -p "$VOLUME" ;;
> > -			esac
> > -		fi
> > +	fi
> > +
> > +	# We should really do the fsck before every resize.
> 
> Well user is always the master - if he is brave to go without it, let him do
> what he wants (i.e. destroy his fs).

You're missing the point, resize2fs requires that the file system is
checked with e2fsck -f prior the resize, if on of the conditions happen

1. file system was not cleanly umounted
2. file system contain errors, or is invalid
3. it was not checked since the last time it was mounted

It is just to make sure that the file system is consistent and we will
not make everything worse by messing with metadata further.

Thanks!
-Lukas


