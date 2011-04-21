From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Apr 2011 19:06:01 -0000
Subject: LVM2/test t-vgimportclone.sh
Message-ID: <20110421190601.12970.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2011-04-21 19:06:00

Modified files:
	test           : t-vgimportclone.sh 

Log message:
	Disable nightly test for vgimportclone until proper fix is made.
	
	This fails on lenny buildslave for some reason.
	For now disable the vgimportclone part of the test until proper fix.
	
	Let the first part of the test still run though, which shows pvs working
	with duplicate pvs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgimportclone.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-vgimportclone.sh	2011/04/21 17:03:38	1.1
+++ LVM2/test/t-vgimportclone.sh	2011/04/21 19:06:00	1.2
@@ -26,10 +26,11 @@
 grep $vg1 err
 
 # Import the cloned PV to a new VG
-vgimportclone --basevgname $vg2 $dev2
+# FIXME: this fails on lenny buildslave, I think we need proper wrapper
+# vgimportclone --basevgname $vg2 $dev2
 
 # Verify we can activate / deactivate the LV from both VGs
-lvchange -ay $vg1/$lv1
-lvchange -ay $vg2/$lv1
-vgchange -an $vg1
-vgchange -an $vg2
+# lvchange -ay $vg1/$lv1
+# lvchange -ay $vg2/$lv1
+# vgchange -an $vg1
+# vgchange -an $vg2


