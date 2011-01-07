From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 14:56:11 -0000
Subject: LVM2/test t-lvconvert-repair-transient-dmeventd.sh
Message-ID: <20110107145611.26071.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 14:56:10

Added files:
	test           : t-lvconvert-repair-transient-dmeventd.sh 

Log message:
	Add a test for the interaction of transient errors and dmeventd mirror repair.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-lvconvert-repair-transient-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair-transient-dmeventd.sh
+++ -	2011-01-07 14:56:11.157984000 +0000
@@ -0,0 +1,27 @@
+#!/bin/bash
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+aux prepare_dmeventd
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvchange --monitor y $vg/4way
+aux disable_dev $dev2 $dev4
+mkfs.ext3 $DM_DEV_DIR/$vg/4way
+aux enable_dev $dev2 $dev4
+sleep 10
+lvs -a -o +devices | not grep unknown
+check mirror $vg 4way
+check mirror_legs $vg 4way 2
+lvs -a -o +devices | should not grep mimage_1
+lvs -a -o +devices | should not grep mimage_3


