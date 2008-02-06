From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Feb 2008 12:45:32 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh tools/lvresize.c
Message-ID: <20080206124532.19537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-02-06 12:45:32

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 
	tools          : lvresize.c 

Log message:
	Fix lvresize to support /dev/mapper prefix in the lvname
	Fix unfilled paramater passed to fsadm from lvresize
	Update fsadm to call lvresize if the partition size differs (with option -l)
	Fix fsadm to support vg/lv name (like the rest of lv-tools)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.788&r2=1.789
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW	2008/02/05 09:38:04	1.788
+++ LVM2/WHATS_NEW	2008/02/06 12:45:32	1.789
@@ -2,6 +2,10 @@
 ===================================
   Update usage message for clvmd.
   Fix clvmd man page printing <br>, clarified debug options.
+  Fix lvresize to support /dev/mapper prefix in the lvname
+  Fix unfilled paramater passed to fsadm from lvresize
+  Update fsadm to call lvresize if the partition size differs (with option -l)
+  Fix fsadm to support vg/lv name (like the rest of lv-tools)
 
 Version 2.02.33 - 31st January 2008
 ===================================
--- LVM2/scripts/fsadm.sh	2008/01/08 16:45:43	1.4
+++ LVM2/scripts/fsadm.sh	2008/02/06 12:45:32	1.5
@@ -47,11 +47,14 @@
 FSCK=fsck
 XFS_CHECK=xfs_check
 
+LVRESIZE=lvresize
+
 YES=
 DRY=0
-VERB=0
+VERB=
 FORCE=
 EXTOFF=0
+DO_LVRESIZE=0
 FSTYPE=unknown
 VOLUME=unknown
 TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$/m"
@@ -78,6 +81,7 @@
 	echo "    -e | --ext-offline  unmount filesystem before Ext2/3 resize"
 	echo "    -f | --force        Bypass sanity checks"
 	echo "    -n | --dry-run      Print commands without running them"
+	echo "    -l | --lvresize     Resize given device (if it is LVM device)"
 	echo "    -y | --yes          Answer \"yes\" at any prompts"
 	echo
 	echo "  new_size - Absolute number of filesystem blocks to be in the filesystem,"
@@ -88,7 +92,7 @@
 }
 
 verbose() {
-	test "$VERB" -eq 1 && echo "$TOOL: $@" || true
+	test -n "$VERB" && echo "$TOOL: $@" || true
 }
 
 error() {
@@ -115,7 +119,12 @@
 	fi
 	IFS=$IFS_OLD
 	trap 2
-	exit $1
+
+	# start LVRESIZE with the filesystem modification flag
+	# and allow recursive call of fsadm
+	unset FSADM_RUNNING
+	test "$DO_LVRESIZE" -eq 2 && exec $LVRESIZE $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
+	exit ${1:-0}
 }
 
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
@@ -133,12 +142,19 @@
 	esac
 	#NEWBLOCKCOUNT=$(round_block_size $NEWSIZE $2)
 	NEWBLOCKCOUNT=$(( $NEWSIZE / $2 ))
+
+	if [ $DO_LVRESIZE -eq 1 ]; then
+		# start lvresize, but first cleanup mounted dirs
+		DO_LVRESIZE=2
+		cleanup 0
+	fi
 }
 
 # detect filesystem on the given device
 # dereference device name if it is symbolic link
 detect_fs() {
-	VOLUME=$($READLINK -e -n "$1") || error "Cannot get readlink $1"
+        VOLUME=${1#/dev/}
+	VOLUME=$($READLINK -e -n "/dev/$VOLUME") || error "Cannot get readlink $1"
 	# use /dev/null as cache file to be sure about the result
 	FSTYPE=$($BLKID -c /dev/null -o value -s TYPE "$VOLUME") || error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
@@ -291,11 +307,12 @@
 # Resize filesystem
 ####################
 resize() {
+	NEWSIZE=$2
 	detect_fs "$1"
 	detect_device_size
 	verbose "Device \"$VOLUME\" has $DEVSIZE bytes"
 	# if the size parameter is missing use device size
-	NEWSIZE=$2
+	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
 	trap cleanup 2
 	#IFS=$'\n'  # don't use bash-ism ??
@@ -306,7 +323,7 @@
 	  "xfs") resize_xfs $NEWSIZE ;;
 	  *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool" ;;
 	esac || error "Resize $FSTYPE failed"
-	cleanup
+	cleanup 0
 }
 
 ###################
@@ -325,11 +342,15 @@
 # - parsing parameters
 #############################
 
+# test if we are not invoked recursively
+test -n "$FSADM_RUNNING" && exit 0
+
 # test some prerequisities
 test -n "$TUNE_EXT" -a -n "$RESIZE_EXT" -a -n "$TUNE_REISER" -a -n "$RESIZE_REISER" \
   -a -n "$TUNE_XFS" -a -n "$RESIZE_XFS" -a -n "$MOUNT" -a -n "$UMOUNT" -a -n "$MKDIR" \
   -a -n "$RMDIR" -a -n "$BLOCKDEV" -a -n "$BLKID" -a -n "$GREP" -a -n "$READLINK" \
-  -a -n "$FSCK" -a -n "$XFS_CHECK" || error "Required command definitions in the script are missing!"
+  -a -n "$FSCK" -a -n "$XFS_CHECK" -a -n "LVRESIZE" \
+  || error "Required command definitions in the script are missing!"
 $($READLINK -e -n / >/dev/null 2>&1) || error "$READLINK does not support options -e -n"
 TEST64BIT=$(( 1000 * 1000000000000 ))
 test $TEST64BIT -eq 1000000000000000 || error "Shell does not handle 64bit arithmetic"
@@ -344,11 +365,12 @@
 do
 	case "$1" in
 	 "-h"|"--help") tool_usage ;;
-	 "-v"|"--verbose") VERB=1 ;;
+	 "-v"|"--verbose") VERB="-v" ;;
 	 "-n"|"--dry-run") DRY=1 ;;
 	 "-f"|"--force") FORCE="-f" ;;
 	 "-e"|"--ext-offline") EXTOFF=1 ;;
 	 "-y"|"--yes") YES="-y" ;;
+	 "-l"|"--lvresize") DO_LVRESIZE=1 ;;
 	 "check") shift; CHECK=$1 ;;
 	 "resize") shift; RESIZE=$1; shift; NEWSIZE=$1 ;;
 	 *) error "Wrong argument \"$1\". (see: $TOOL --help)"
@@ -359,6 +381,7 @@
 if [ -n "$CHECK" ]; then
 	check "$CHECK"
 elif [ -n "$RESIZE" ]; then
+	export FSADM_RUNNING="fsadm"
 	resize "$RESIZE" "$NEWSIZE"
 else
 	error "Missing command. (see: $TOOL --help)"
--- LVM2/tools/lvresize.c	2008/01/30 14:00:02	1.92
+++ LVM2/tools/lvresize.c	2008/02/06 12:45:32	1.93
@@ -166,6 +166,7 @@
 {
 	const char *cmd_name;
 	char *st;
+	unsigned dev_dir_found = 0;
 
 	lp->sign = SIGN_NONE;
 	lp->resize = LV_ANY;
@@ -228,11 +229,12 @@
 	argv++;
 	argc--;
 
-	if (!(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
+	if (!(lp->lv_name = skip_dev_dir(cmd, lp->lv_name, &dev_dir_found))
+	    || (!(lp->vg_name = extract_vgname(cmd, lp->lv_name)))) {
 		log_error("Please provide a volume group name");
 		return 0;
 	}
-	
+
 	if (!validate_name(lp->vg_name)) {
 		log_error("Volume group name %s has invalid characters",
 			  lp->vg_name);
@@ -267,7 +269,6 @@
 	uint32_t sz, str;
 	struct list *pvh = NULL;
 	char size_buf[SIZE_BUF];
-	char lv_path[PATH_MAX];
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
@@ -622,6 +623,14 @@
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND)) {
+		char lv_path[PATH_MAX];
+
+		if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
+				lp->vg_name, lp->lv_name) < 0) {
+			log_error("Couldn't create LV path for %s",
+				  lp->lv_name);
+			return ECMD_FAILED;
+		}
 		if (!exec_cmd("fsadm", "resize", lv_path, size_buf)) {
 			stack;
 			return ECMD_FAILED;


