From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Apr 2010 18:18:59 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100420181859.1573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-04-20 18:18:59

Modified files:
	test           : test-utils.sh 

Log message:
	Re-enable t-topology-support.sh
	
	Reintroduce split teardown (teardown() calls teardown_devs()) because
	t-topology-support.sh only needs the teardown_devs() subset of the full
	teardown() between each iteration of the topology tests -- in particular
	the $TESTDIR must not get removed between each topology test iteration.
	
	prepare_loop() must return if prepare_scsi_debug_dev() already
	established $LOOP.
	
	Also fix (and simplify) the unsafe scsi-debug device discovery in
	prepare_scsi_debug_dev().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/test/test-utils.sh	2010/04/14 12:04:23	1.37
+++ LVM2/test/test-utils.sh	2010/04/20 18:18:59	1.38
@@ -92,16 +92,7 @@
 	done
 }
 
-teardown() {
-	echo $LOOP
-	echo $PREFIX
-
-	test -n "$LOCAL_CLVMD" && {
-		kill "$LOCAL_CLVMD"
-		sleep .1
-		kill -9 "$LOCAL_CLVMD" || true
-	}
-
+teardown_devs() {
 	test -n "$PREFIX" && {
 		rm -rf $TESTDIR/dev/$PREFIX*
 
@@ -124,6 +115,19 @@
 		test -n "$LOOPFILE" && rm -f $LOOPFILE
 	fi
 	unset devs # devs is set in prepare_devs()
+}
+
+teardown() {
+	echo $LOOP
+	echo $PREFIX
+
+	test -n "$LOCAL_CLVMD" && {
+		kill "$LOCAL_CLVMD"
+		sleep .1
+		kill -9 "$LOCAL_CLVMD" || true
+	}
+
+	teardown_devs
 
 	test -n "$TESTDIR" && {
 		cd $OLDPWD
@@ -145,6 +149,11 @@
 	size=$1
 	test -n "$size" || size=32
 
+	# skip if prepare_scsi_debug_dev() was used
+	if [ -n "$SCSI_DEBUG_DEV" -a -n "$LOOP" ]; then
+		return 0
+	fi
+
 	test -z "$LOOP"
 	test -n "$DM_DEV_DIR"
 
@@ -183,71 +192,50 @@
 	exit 1 # should not happen
 }
 
-get_sd_devs_()
-{
-    # prepare_scsi_debug_dev() requires the ability to lookup
-    # the scsi_debug created SCSI device in /dev/
-    local _devs=$(lvmdiskscan --config 'devices { filter = [ "a|/dev/sd.*|", "r|.*|" ] scan = "/dev/" }' | grep /dev/sd | awk '{ print $1 }')
-    echo $_devs
-}
-
 # A drop-in replacement for prepare_loop() that uses scsi_debug to create
 # a ramdisk-based SCSI device upon which all LVM devices will be created
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
 prepare_scsi_debug_dev()
 {
-    # FIXME this is extremely fragile and can cause data loss if an unrelated
-    # SCSI device appears at a wrong time... we need the code to reliably
-    # identify the scsi_debug device it has created before we can re-include
-    # this in the testsuite
-    exit 200
-
     local DEV_SIZE="$1"
     shift
     local SCSI_DEBUG_PARAMS="$@"
 
     test -n "$SCSI_DEBUG_DEV" && return 0
+    test -z "$LOOP"
+    test -n "$DM_DEV_DIR"
+
     trap_teardown
 
     # Skip test if awk isn't available (required for get_sd_devs_)
     which awk || exit 200
 
     # Skip test if scsi_debug module is unavailable or is already in use
-    modinfo scsi_debug || exit 200
+    modprobe --dry-run scsi_debug || exit 200
     lsmod | grep -q scsi_debug && exit 200
 
     # Create the scsi_debug device and determine the new scsi device's name
-    local devs_before=`get_sd_devs_`
     # NOTE: it will _never_ make sense to pass num_tgts param;
     # last param wins.. so num_tgts=1 is imposed
     modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || exit 200
     sleep 2 # allow for async Linux SCSI device registration
 
-    local devs_after=`get_sd_devs_`
-    for dev1 in $devs_after; do
-	FOUND=0
-	for dev2 in $devs_before; do
-	    if [ "$dev1" = "$dev2" ]; then
-		FOUND=1
-		break
-	    fi
-	done
-	if [ $FOUND -eq 0 ]; then
-	    # Create symlink to scsi_debug device in $DM_DEV_DIR
-	    SCSI_DEBUG_DEV=$DM_DEV_DIR/$(basename $dev1)
-	    # Setting $LOOP provides means for prepare_devs() override
-	    LOOP=$SCSI_DEBUG_DEV
-	    ln -snf $dev1 $SCSI_DEBUG_DEV
-	    return 0
-	fi
-    done
-    exit 1 # should not happen
+    local DEBUG_DEV=/dev/$(grep scsi_debug /sys/block/*/device/model | cut -f4 -d /)
+    [ -b $DEBUG_DEV ] || exit 1 # should not happen
+
+    # Create symlink to scsi_debug device in $DM_DEV_DIR
+    SCSI_DEBUG_DEV=$DM_DEV_DIR/$(basename $DEBUG_DEV)
+    # Setting $LOOP provides means for prepare_devs() override
+    LOOP=$SCSI_DEBUG_DEV
+    ln -snf $DEBUG_DEV $SCSI_DEBUG_DEV
+    return 0
 }
 
 cleanup_scsi_debug_dev()
 {
-    aux teardown
+    aux teardown_devs
     unset SCSI_DEBUG_DEV
+    unset LOOP
 }
 
 prepare_devs() {


