From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 30 Jun 2011 08:50:11 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110630085011.8187.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-30 08:50:10

Modified files:
	test/lib       : aux.sh 

Log message:
	Try to force remove dm devices in after test fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/test/lib/aux.sh	2011/06/30 01:17:37	1.21
+++ LVM2/test/lib/aux.sh	2011/06/30 08:50:10	1.22
@@ -90,6 +90,27 @@
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
 
+	# Try to remove test devices
+	# resume any linears to be sure we do not deadlock
+	STRAY_DEVS=$(dmsetup table | grep linear | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
+	for dm in $STRAY_DEVS ; do
+		# FIXME: only those really suspended
+		dmsetup resume $dm 2>/dev/null
+	done
+
+	# Now try to remove devices
+	finish=0
+	while [ $finish -eq 0 ] ; do
+		finish=1
+		STRAY_DEVS=$(dmsetup table | sed 's/:.*//' | grep $COMMON_PREFIX | cut -d' '  -f 1)
+		for dm in $STRAY_DEVS ; do
+			echo "Trying to remove stalled $dm"
+			dmsetup remove $dm 2>/dev/null
+			# Sucessful remove means repeat the loop once more
+			[ $? -eq 0 ] && finish=0
+		done
+	done
+
 	# Remove any loop devices that failed to get torn down if earlier tests aborted
         STRAY_LOOPS=`losetup -a | grep $COMMON_PREFIX | cut -d: -f1`
         if test -n "$STRAY_LOOPS"; then


