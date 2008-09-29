From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Sep 2008 16:04:57 -0000
Subject: LVM2/test t-partial-activate.sh
Message-ID: <20080929160457.20946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-29 16:04:57

Added files:
	test           : t-partial-activate.sh 

Log message:
	Add a simple test for partial activation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-partial-activate.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-partial-activate.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-partial-activate.sh
+++ -	2008-09-29 16:04:57.776087000 +0000
@@ -0,0 +1,12 @@
+. ./test-utils.sh
+
+aux prepare_vg 3
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+disable_dev $dev1
+
+# FIXME should this return an error code due to that big fat WARNING?
+vgreduce --removemissing $vg
+not lvchange -v -a y $vg/mirror
+lvchange -v --partial -a y $vg/mirror


