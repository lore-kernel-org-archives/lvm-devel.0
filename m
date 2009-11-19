From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Nov 2009 13:55:41 -0000
Subject: LVM2/test t-snapshots-of-mirrors.sh
Message-ID: <20091119135541.957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-19 13:55:40

Added files:
	test           : t-snapshots-of-mirrors.sh 

Log message:
	Add a basic test for snapshots of mirrors, thanks to Jon Brassow.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-snapshots-of-mirrors.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-snapshots-of-mirrors.sh
+++ -	2009-11-19 13:55:40.942022000 +0000
@@ -0,0 +1,35 @@
+. ./test-utils.sh
+
+prepare_vg 4
+
+# Create snapshot of a mirror origin
+lvcreate -m 1 -L 10M -n lv $vg
+lvcreate -s $vg/lv -L 10M -n snap
+
+# Down-convert (mirror -> linear) under a snapshot
+lvconvert -m0 $vg/lv
+
+# Up-convert (linear -> mirror)
+lvconvert -m2 $vg/lv
+
+# Down-convert (mirror -> mirror)
+lvconvert -m1 $vg/lv
+
+# Up-convert (mirror -> mirror) -- Not supported!
+not lvconvert -m2 $vg/lv
+
+# Log conversion (disk -> core)
+lvconvert --mirrorlog core $vg/lv
+
+# Log conversion (core -> redundant) -- Not available yet!
+not lvconvert --mirrorlog redundant $vg/lv
+
+# Log conversion (redundant -> core) -- Not available yet!
+# Note: Uncomment this command when the above works
+# not lvconvert --mirrorlog core $vg/lv
+
+# Log conversion (core -> disk)
+lvconvert --mirrorlog disk $vg/lv
+
+# Clean-up
+lvremove -ff $vg


