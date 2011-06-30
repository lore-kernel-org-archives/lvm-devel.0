From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2011 01:17:38 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110630011738.29368.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-30 01:17:38

Modified files:
	test/lib       : aux.sh 

Log message:
	Try to remove any stray loop devices left behind by earlier aborted tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/test/lib/aux.sh	2011/06/30 00:57:29	1.20
+++ LVM2/test/lib/aux.sh	2011/06/30 01:17:37	1.21
@@ -90,10 +90,13 @@
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
 
-	# Remove any loop devices that failed to get torn down
-	losetup -a
-	echo losetup -d `losetup -a | grep $COMMON_PREFIX | cut -d: -f1` 2>/dev/null || true
-	losetup -a
+	# Remove any loop devices that failed to get torn down if earlier tests aborted
+        STRAY_LOOPS=`losetup -a | grep $COMMON_PREFIX | cut -d: -f1`
+        if test -n "$STRAY_LOOPS"; then
+                echo "Removing stray loop devices containing $COMMON_PREFIX:"
+                losetup -a | grep $COMMON_PREFIX
+                losetup -d $STRAY_LOOPS 2>/dev/null || true
+        fi
 }
 
 teardown() {


