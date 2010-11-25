From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Nov 2010 17:15:54 -0000
Subject: LVM2 tools/lvconvert.c test/t-lvconvert-twostep.sh
Message-ID: <20101125171554.6287.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-25 17:15:48

Modified files:
	tools          : lvconvert.c 
Added files:
	test           : t-lvconvert-twostep.sh 

Log message:
	Disallow certain lvconvert operations that need to both allocate and free
	extents, while physical volumes are specified. Fixes BZ 640051.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

/cvs/lvm2/LVM2/test/t-lvconvert-twostep.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-twostep.sh
+++ -	2010-11-25 17:15:51.043330000 +0000
@@ -0,0 +1,21 @@
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
+aux prepare_vg 4
+lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
+not lvconvert -m 2 --mirrorlog core $vg/mirror $dev3 2>&1 | tee errs
+grep "two steps" errs
+lvconvert -m 2 $vg/mirror $dev3
+lvconvert --mirrorlog core $vg/mirror
+not lvconvert -m 1 --mirrorlog disk $vg/mirror $dev3 2>&1 | tee errs
+grep "two steps" errs
--- LVM2/tools/lvconvert.c	2010/10/13 21:26:38	1.148
+++ LVM2/tools/lvconvert.c	2010/11/25 17:15:47	1.149
@@ -1345,6 +1345,15 @@
 					     &new_mimage_count, &new_log_count))
 		return 0;
 
+        if (((old_mimage_count < new_mimage_count && old_log_count > new_log_count) ||
+             (old_mimage_count > new_mimage_count && old_log_count < new_log_count)) &&
+            lp->pv_count) {
+		log_error("Cannot both allocate and free extents when specifying physical"
+			  " volumes to use.");
+		log_error("Please specify the operation in two steps.");
+		return 0;
+        }
+
 	/* Nothing to do?  (Probably finishing collapse.) */
 	if ((old_mimage_count == new_mimage_count) &&
 	    (old_log_count == new_log_count) && !repair)


