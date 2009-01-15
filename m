From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jan 2009 17:14:39 -0000
Subject: LVM2/test t-fsadm.sh
Message-ID: <20090115171439.7368.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-15 17:14:38

Added files:
	test           : t-fsadm.sh 

Log message:
	Add skeleton of fsadm nightly test but skip (doesn't work yet).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-fsadm.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-fsadm.sh
+++ -	2009-01-15 17:14:39.057222000 +0000
@@ -0,0 +1,25 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
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
+exit 200
+# doesn't work right now
+aux prepare_pvs 2
+aux pvcreate --metadatacopies 0 $dev1
+vgcreate -cn $vg $devs
+
+# Test for block sizes != 1024 (rhbz #480022)
+lvcreate -n$lv1 -L 64M $vg
+mke2fs -b4096 -j $G_dev_/$vg/$lv1
+e2fsck -f -y $G_dev_/$vg/$lv1
+fsadm --lvresize resize $G_dev_/$vg/$lv1 128M
+vgremove -ff $vg


