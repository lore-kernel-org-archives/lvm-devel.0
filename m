From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Jan 2010 21:27:49 -0000
Subject: LVM2/test t-snapshots-of-mirrors.sh
Message-ID: <20100111212749.16876.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-11 21:27:49

Modified files:
	test           : t-snapshots-of-mirrors.sh 

Log message:
	Add new test cases for mirrors that are under snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-snapshots-of-mirrors.sh	2009/11/19 13:55:40	1.1
+++ LVM2/test/t-snapshots-of-mirrors.sh	2010/01/11 21:27:49	1.2
@@ -21,12 +21,11 @@
 # Log conversion (disk -> core)
 lvconvert --mirrorlog core $vg/lv
 
-# Log conversion (core -> redundant) -- Not available yet!
-not lvconvert --mirrorlog redundant $vg/lv
+# Log conversion (core -> redundant)
+lvconvert --mirrorlog redundant $vg/lv
 
-# Log conversion (redundant -> core) -- Not available yet!
-# Note: Uncomment this command when the above works
-# not lvconvert --mirrorlog core $vg/lv
+# Log conversion (redundant -> core)
+lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> disk)
 lvconvert --mirrorlog disk $vg/lv


