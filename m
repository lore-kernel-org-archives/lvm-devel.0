From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 13:52:55 -0000
Subject: LVM2 lib/metadata/lv_manip.c test/t-lvcreate-s ...
Message-ID: <20101013135255.20233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 13:52:54

Modified files:
	lib/metadata   : lv_manip.c 
Added files:
	test           : t-lvcreate-small-snap.sh 

Log message:
	Give correct error message when creating a too-small snapshot (BZ 587063)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.232&r2=1.233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-small-snap.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/lib/metadata/lv_manip.c	2010/08/17 16:25:33	1.232
+++ LVM2/lib/metadata/lv_manip.c	2010/10/13 13:52:53	1.233
@@ -3123,6 +3123,11 @@
 		return 0;
 	}
 
+	if (lp->snapshot && (lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
+		log_error("Unable to create a snapshot smaller than 2 chunks.");
+		return 0;
+	}
+
 	if (!seg_is_virtual(lp) &&
 	    vg->free_count < lp->extents) {
 		log_error("Insufficient free extents (%u) in volume group %s: "
/cvs/lvm2/LVM2/test/t-lvcreate-small-snap.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvcreate-small-snap.sh
+++ -	2010-10-13 13:52:54.866996000 +0000
@@ -0,0 +1,30 @@
+#!/bin/bash
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
+. ./test-utils.sh
+
+aux prepare_pvs 3
+
+vgcreate -c n -s 1k $vg $devs
+
+lvcreate -n one -l 10 $vg
+lvcreate -s -l 8 -n snapA $vg/one
+lvcreate -s -c 4k -l 8 -n snapX1 $vg/one
+lvcreate -s -c 8k -l 16 -n snapX2 $vg/one
+
+# Check that snapshots that are too small are caught with correct error.
+not lvcreate -s -c 8k -l 8 -n snapX3 $vg/one 2>&1 | tee lvcreate.out
+not grep "suspend origin one" lvcreate.out
+grep "Unable to create a snapshot" lvcreate.out
+
+not lvcreate -s -l 4 -n snapB $vg/one 2>&1 | tee lvcreate.out
+not grep "suspend origin one" lvcreate.out
+grep "Unable to create a snapshot" lvcreate.out


