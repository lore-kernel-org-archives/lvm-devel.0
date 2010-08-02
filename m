From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Aug 2010 13:18:42 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100802131842.9157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-02 13:18:42

Modified files:
	test           : test-utils.sh 

Log message:
	Using count=0 is sufficient for creation of zeroed files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/test/test-utils.sh	2010/05/24 17:19:50	1.46
+++ LVM2/test/test-utils.sh	2010/08/02 13:18:42	1.47
@@ -186,7 +186,7 @@
 	done
 
 	LOOPFILE="$PWD/test.img"
-	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=1 seek=$(($size-1))
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size-1))
 	if LOOP=`losetup -s -f "$LOOPFILE" 2>/dev/null`; then
 		return 0
 	elif LOOP=`losetup -f` && losetup $LOOP "$LOOPFILE"; then


