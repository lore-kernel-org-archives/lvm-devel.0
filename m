From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2010 16:14:05 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101110161405.12477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-10 16:14:03

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	fsadm fix for downsize of unmounted fs
	
	Fix for the last commit as $MOUNTED is not only used as bool flag,
	but also store mounted location for remount - so parsing output
	from mount differently then from /proc/mounts.
	
	Prefix calls of 'tunefs' tools with LANG=C to be sure we always do get
	some nonlocalized strings.
	
	Avoid using forced 'resize2fs' for cleanly unmounted filesystems and
	run regular fsck -f for this case as required by resize2fs.
	
	'fsadm check' uses date difference for extX filesystems between
	the last mount and last check of 'fsck -f' execution and if the mount
	was later run 'fsck' with -f so resize2fs is happy and user does not
	need to pass '-f' flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1794&r2=1.1795
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2010/11/10 10:05:27	1.1794
+++ LVM2/WHATS_NEW	2010/11/10 16:14:02	1.1795
@@ -1,6 +1,7 @@
 Version 2.02.77 -
 ===================================
-  Fix regression in detection of mounted filesystem for older systems (2.0.75).
+  Fix fsadm need of using '-f' for downsize of unmounted filesystem.
+  Fix fsadm regression in detection of mounted filesystem for older systems (2.0.75).
   Extend cling allocation policy to recognise PV tags (cling_by_tags).
   Add allocation/cling_tag_list to lvm.conf.
   Regenerate configure with 'autoreconf' for --enable-ocf. (2.02.76)
--- LVM2/scripts/fsadm.sh	2010/11/10 10:03:07	1.22
+++ LVM2/scripts/fsadm.sh	2010/11/10 16:14:03	1.23
@@ -199,14 +199,19 @@
 	# for empty string try again with real volume name
 	test -z "$MOUNTED" && MOUNTED=$($GREP ^"$RVOLUME" $PROCMOUNTS)
 
-	# for systems with different device names - check also mount output
-	test -z "$MOUNTED" && MOUNTED=$($MOUNT | $GREP ^"$VOLUME")
-	test -z "$MOUNTED" && MOUNTED=$($MOUNT | $GREP ^"$RVOLUME")
-
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
 	MOUNTED=${MOUNTED#* }
 	MOUNTED=$(echo -n -e ${MOUNTED%% *})
+
+	# for systems with different device names - check also mount output
+	if test -z "$MOUNTED" ; then
+		MOUNTED=$(LANG=C $MOUNT | $GREP ^"$VOLUME")
+		test -z "$MOUNTED" && MOUNTED=$(LANG=C $MOUNT | $GREP ^"$RVOLUME")
+		MOUNTED=${MOUNTED##* on }
+		MOUNTED=${MOUNTED% type *} # allow type in the mount name
+	fi
+
 	test -n "$MOUNTED"
 }
 
@@ -271,7 +276,7 @@
 ####################################
 resize_ext() {
 	verbose "Parsing $TUNE_EXT -l \"$VOLUME\""
-	for i in $($TUNE_EXT -l "$VOLUME"); do
+	for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
 		case "$i" in
 		  "Block size"*) BLOCKSIZE=${i##*  } ;;
 		  "Block count"*) BLOCKCOUNT=${i##*  } ;;
@@ -284,8 +289,13 @@
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
 		detect_mounted && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
-		# CHECKME: after umount resize2fs requires fsck or -f flag.
-		FSFORCE="-f"
+		if test -n "$MOUNTED" ; then
+			# Forced fsck -f for umounted extX filesystem.
+			case "$-" in
+			  *i*) dry $FSCK $YES -f "$VOLUME" ;;
+			  *) dry $FSCK -f -p "$VOLUME" ;;
+			esac
+		fi
 	fi
 
 	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
@@ -301,7 +311,7 @@
 	detect_mounted && verbose "ReiserFS resizes only unmounted filesystem" && try_umount
 	REMOUNT=$MOUNTED
 	verbose "Parsing $TUNE_REISER \"$VOLUME\""
-	for i in $($TUNE_REISER "$VOLUME"); do
+	for i in $(LANG=C $TUNE_REISER "$VOLUME"); do
 		case "$i" in
 		  "Blocksize"*) BLOCKSIZE=${i##*: } ;;
 		  "Count of blocks"*) BLOCKCOUNT=${i##*: } ;;
@@ -330,7 +340,7 @@
 		temp_mount || error "Cannot mount Xfs filesystem"
 	fi
 	verbose "Parsing $TUNE_XFS \"$MOUNTPOINT\""
-	for i in $($TUNE_XFS "$MOUNTPOINT"); do
+	for i in $(LANG=C $TUNE_XFS "$MOUNTPOINT"); do
 		case "$i" in
 		  "data"*) BLOCKSIZE=${i##*bsize=} ; BLOCKCOUNT=${i##*blocks=} ;;
 		esac
@@ -370,6 +380,15 @@
 	cleanup 0
 }
 
+####################################
+# Calclulate diff between two dates
+#  LANG=C input is expected the
+#  only one supported
+####################################
+diff_dates() {
+         echo $(( $(date -u -d"$1" +%s 2>/dev/null) - $(date -u -d"$2" +%s 2>/dev/null) ))
+}
+
 ###################
 # Check filesystem
 ###################
@@ -379,6 +398,30 @@
 		verbose "Skipping filesystem check for device \"$VOLUME\" as the filesystem is mounted on $MOUNTED";
 		cleanup 3
 	fi
+
+	case "$FSTYPE" in
+	  "ext2"|"ext3"|"ext4")
+		IFS_CHECK=$IFS
+		IFS=$NL
+		for i in $(LANG=C $TUNE_EXT -l "$VOLUME"); do
+			case "$i" in
+			  "Last mount"*) LASTMOUNT=${i##*: } ;;
+			  "Last checked"*) LASTCHECKED=${i##*: } ;;
+			esac
+		done
+		case "$LASTMOUNT" in
+		  *"n/a") ;; # nothing to do - system was not mounted yet
+		  *)
+			LASTDIFF=$(diff_dates $LASTMOUNT $LASTCHECKED)
+			if test "$LASTDIFF" -gt 0 ; then
+				verbose "Filesystem has not been checked after the last mount, using fsck -f"
+				FORCE="-f"
+			fi
+			;;
+		esac
+		IFS=$IFS_CHECK
+	esac
+
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
 	  *)    # check if executed from interactive shell environment


