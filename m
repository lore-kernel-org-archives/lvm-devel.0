From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 06:02:28 -0000
Subject: LVM2/test t-activate-missing.sh
Message-ID: <20100512060228.22474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 06:02:28

Added files:
	test           : t-activate-missing.sh 

Log message:
	Add a test for activation in presence of missing devices. This partially covers
	the robustness requirements for system startup that we have.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-missing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-activate-missing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-activate-missing.sh
+++ -	2010-05-12 06:02:28.606758000 +0000
@@ -0,0 +1,73 @@
+#!/bin/bash
+
+# Test activation behaviour with devices missing.
+# - snapshots and their origins are only activated together; if one fails, both
+#   fail
+# - partial mirrors are not activated (but maybe they should? maybe we should
+#   instead lvconvert --repair them?)
+# - linear LVs with bits missing are not activated
+
+. ./test-utils.sh
+
+prepare_vg 4
+
+lvcreate -l1 -n linear1 $vg $dev1
+lvcreate -l1 -n linear2 $vg $dev2
+lvcreate -l2 -n linear12 $vg $dev1:4 $dev2:4
+
+lvcreate -l1 -n origin1 $vg $dev1
+lvcreate -s $vg/origin1 -l1 -n s_napshot2 $dev2
+
+lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg $dev1 $dev2
+lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
+
+vgchange -a n $vg
+disable_dev $dev1
+not vgchange -a y $vg
+
+check inactive $vg linear1
+check active $vg linear2
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg linear12
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+enable_dev $dev1
+disable_dev $dev2
+not vgchange -a y $vg
+
+check active $vg linear1
+check inactive $vg linear2
+check inactive $vg linear12
+check inactive $vg origin1
+check inactive $vg s_napshot2
+check inactive $vg mirror12
+check inactive $vg mirror123
+
+vgchange -a n $vg
+enable_dev $dev2
+disable_dev $dev3
+not vgchange -a y $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check inactive $vg mirror123
+check active $vg mirror12
+
+vgchange -a n $vg
+enable_dev $dev3
+disable_dev $dev4
+vgchange -a y $vg
+
+check active $vg origin1
+check active $vg s_napshot2
+check active $vg linear1
+check active $vg linear2
+check active $vg linear12
+check active $vg mirror12
+check active $vg mirror123


