From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 10:36:26 -0000
Subject: LVM2/test t-vgextend-restoremissing.sh
Message-ID: <20101013103626.30285.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 10:36:26

Added files:
	test           : t-vgextend-restoremissing.sh 

Log message:
	Add a test for vgextend --restoremissing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-restoremissing.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-vgextend-restoremissing.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgextend-restoremissing.sh
+++ -	2010-10-13 10:36:26.608266000 +0000
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
+
+aux prepare_vg 3
+lvcreate -m 1 -l 1 -n mirror $vg
+lvchange -a n $vg/mirror
+lvcreate -l 1 -n lv1 $vg $dev1
+
+# try to just change metadata; we expect the new version (with MISSING_PV set
+# on the reappeared volume) to be written out to the previously missing PV
+disable_dev $dev1
+lvremove $vg/mirror
+enable_dev $dev1
+not vgck $vg 2>&1 | tee log
+grep "missing 1 physical volume" log
+not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
+vgextend --restore $vg $dev1 # restore the missing device
+vgck $vg
+lvcreate -m 1 -l 1 -n mirror $vg


