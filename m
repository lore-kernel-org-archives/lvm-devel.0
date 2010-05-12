From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 05:59:25 -0000
Subject: LVM2/test t-activate-partial.sh t-partial-acti ...
Message-ID: <20100512055925.6115.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 05:59:25

Added files:
	test           : t-activate-partial.sh 
Removed files:
	test           : t-partial-activate.sh 

Log message:
	Rename t-partial-activate to t-activate-partial (more activation tests coming).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-partial.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-partial-activate.sh.diff?cvsroot=lvm2&r1=1.3&r2=NONE

/cvs/lvm2/LVM2/test/t-activate-partial.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-activate-partial.sh
+++ -	2010-05-12 05:59:25.208708000 +0000
@@ -0,0 +1,15 @@
+. ./test-utils.sh
+
+aux prepare_vg 3
+
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+disable_dev $dev1
+
+not vgreduce --removemissing $vg
+not lvchange -v -a y $vg/mirror
+lvchange -v --partial -a y $vg/mirror
+
+# also check that vgchange works
+vgchange -a n --partial $vg
+vgchange -a y --partial $vg


