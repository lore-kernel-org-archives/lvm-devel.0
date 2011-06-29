From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 18:14:08 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110629181408.31490.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 18:14:08

Modified files:
	test/lib       : aux.sh 

Log message:
	teardown aborts if it hits an error, so better teardown semaphores earlier
	as we need them later in the teardown process

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/test/lib/aux.sh	2011/06/29 17:37:30	1.17
+++ LVM2/test/lib/aux.sh	2011/06/29 18:14:08	1.18
@@ -61,6 +61,9 @@
 }
 
 teardown_devs() {
+	# Delete any remaining dm/udev semaphores
+	dmsetup udevcomplete_all -y
+
 	test -n "$PREFIX" && {
 		rm -rf $TESTDIR/dev/$PREFIX*
 
@@ -87,9 +90,6 @@
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
 
-	# Delete any remaining dm/udev semaphores
-	dmsetup udevcomplete_all -y
-
 	# Display any loop devices that failed to get torn down
 	losetup -a
 }


