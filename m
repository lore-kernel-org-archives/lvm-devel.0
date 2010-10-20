From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Oct 2010 15:32:15 -0000
Subject: LVM2/test t-vgchange-maxlv.sh
Message-ID: <20101020153215.19079.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-20 15:32:15

Added files:
	test           : t-vgchange-maxlv.sh 

Log message:
	Add a test for BZ 509182 (vgchange --monitor y breaks with max_lv).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-maxlv.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-vgchange-maxlv.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgchange-maxlv.sh
+++ -	2010-10-20 15:32:15.903509000 +0000
@@ -0,0 +1,31 @@
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
+prepare_dmeventd
+aux prepare_pvs 3
+
+vgcreate -c n -l 2 $vg $dev1 $dev2 $dev3
+lvcreate -n one -l 1 $vg
+lvcreate -n two -l 1 $vg
+not lvcreate -n three -l 1 $vg
+vgchange -an $vg
+vgremove -ff $vg
+
+vgcreate -c n -l 3 $vg $dev1 $dev2 $dev3
+lvcreate -n one -l 1 $vg
+lvcreate -n snap -s -l 1 $vg/one
+lvcreate -n two -l 1 $vg
+not lvcreate -n three -l 1 $vg
+vgchange --monitor y $vg
+vgchange -an $vg 2>&1 | tee vgchange.out
+not grep "event server" vgchange.out


