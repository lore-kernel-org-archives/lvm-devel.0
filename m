From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 1 Mar 2012 20:03:45 -0000
Subject: LVM2/test/shell lvmetad-pvs.sh
Message-ID: <20120301200345.2130.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-01 20:03:45

Added files:
	test/shell     : lvmetad-pvs.sh 

Log message:
	Add a regression test for the PSize bug in pvs/lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvmetad-pvs.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/shell/lvmetad-pvs.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/lvmetad-pvs.sh
+++ -	2012-03-01 20:03:45.923082000 +0000
@@ -0,0 +1,20 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+aux prepare_devs 1 20000
+pvcreate $dev1
+pvs | grep $dev1
+
+# check for PV size overflows
+pvs | grep 19.53g
+pvs | not grep 16.00e


