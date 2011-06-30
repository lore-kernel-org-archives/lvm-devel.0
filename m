From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2011 09:15:53 -0000
Subject: LVM2 ./WHATS_NEW test/lib/aux.sh
Message-ID: <20110630091553.19618.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-30 09:15:53

Modified files:
	.              : WHATS_NEW 
	test/lib       : aux.sh 

Log message:
	teardown stray filesystems too

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2031&r2=1.2032
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2011/06/29 17:05:53	1.2031
+++ LVM2/WHATS_NEW	2011/06/30 09:15:53	1.2032
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Teardown any stray devices with $COMMON_PREFIX during test runs.
   Reinstate correct permissions when creating mirrors. [2.02.85]
   Append 'm' attribute to pv_attr for missing PVs.
   Annotate CLVMD_CMD_SYNC_NAMES in decode_cmd.
--- LVM2/test/lib/aux.sh	2011/06/30 09:08:22	1.23
+++ LVM2/test/lib/aux.sh	2011/06/30 09:15:53	1.24
@@ -90,34 +90,47 @@
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
 
-	# Try to remove test devices
-	# resume any linears to be sure we do not deadlock
-	STRAY_DEVS=$(dmsetup table | grep linear | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
-	for dm in $STRAY_DEVS ; do
-		# FIXME: only those really suspended
-		dmsetup resume $dm 2>/dev/null
-	done
-
-	# Now try to remove devices
-	finish=0
-	while [ $finish -eq 0 ] ; do
-		finish=1
+	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
+	test -n "$COMMON_PREFIX" && {
+		# Resume any linears to be sure we do not deadlock
 		STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
 		for dm in $STRAY_DEVS ; do
-			echo "Trying to remove stalled $dm"
-			dmsetup remove $dm 2>/dev/null
-			# Sucessful remove means repeat the loop once more
-			[ $? -eq 0 ] && finish=0
+			# FIXME: only those really suspended
+			echo dmsetup resume $dm
+			dmsetup resume $dm || true
 		done
-	done
 
-	# Remove any loop devices that failed to get torn down if earlier tests aborted
-        STRAY_LOOPS=`losetup -a | grep $COMMON_PREFIX | cut -d: -f1`
-        if test -n "$STRAY_LOOPS"; then
-                echo "Removing stray loop devices containing $COMMON_PREFIX:"
-                losetup -a | grep $COMMON_PREFIX
-                losetup -d $STRAY_LOOPS 2>/dev/null || true
-        fi
+		STRAY_MOUNTS=`mount | grep $COMMON_PREFIX | cut -d\  -f1`
+		if test -n "$STRAY_MOUNTS"; then
+			echo "Removing stray mounted devices containing $COMMON_PREFIX:"
+			mount | grep $COMMON_PREFIX
+			umount -fl $STRAY_MOUNTS || true
+			sleep 2
+		fi
+
+		init_udev_transaction
+		NUM_REMAINING_DEVS=999
+		while NUM_DEVS=`dmsetup table | grep ^$COMMON_PREFIX | wc -l` && \
+		    test $NUM_DEVS -lt $NUM_REMAINING_DEVS -a $NUM_DEVS -ne 0; do
+			echo "Removing $NUM_DEVS stray mapped devices with names beginning with $COMMON_PREFIX:"
+			STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
+			dmsetup info -c | grep ^$COMMON_PREFIX
+			for dm in $STRAY_DEVS ; do
+				echo dmsetup remove $dm
+				dmsetup remove $dm || true
+			done
+			NUM_REMAINING_DEVS=$NUM_DEVS
+		done
+		finish_udev_transaction
+		udev_wait
+
+        	STRAY_LOOPS=`losetup -a | grep $COMMON_PREFIX | cut -d: -f1`
+        	if test -n "$STRAY_LOOPS"; then
+                	echo "Removing stray loop devices containing $COMMON_PREFIX:"
+                	losetup -a | grep $COMMON_PREFIX
+                	losetup -d $STRAY_LOOPS || true
+        	fi
+	}
 }
 
 teardown() {


