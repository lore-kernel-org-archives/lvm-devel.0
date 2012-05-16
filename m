From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 May 2012 10:44:36 -0000
Subject: LVM2/test/shell activate-missing-segment.sh
Message-ID: <20120516104436.28074.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-05-16 10:44:36

Added files:
	test/shell     : activate-missing-segment.sh 

Log message:
	Add a (currently failing) test for RHBZ 816672.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-missing-segment.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/shell/activate-missing-segment.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/activate-missing-segment.sh
+++ -	2012-05-16 10:44:36.820286000 +0000
@@ -0,0 +1,30 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test activation behaviour with devices missing.
+# - snapshots and their origins are only activated together; if one fails, both
+#   fail
+# - partial mirrors are not activated (but maybe they should? maybe we should
+#   instead lvconvert --repair them?)
+# - linear LVs with bits missing are not activated
+
+. lib/test
+
+aux prepare_vg 2
+aux expect_failure
+
+lvcreate -l100%FREE -n span $vg
+vgchange -a n $vg
+
+aux disable_dev "$dev1"
+not vgchange -a y $vg
+vgchange -a y --partial $vg
+check active $vg span


