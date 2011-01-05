From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 01:00:35 -0000
Subject: LVM2/test t-metadata-dirs.sh
Message-ID: <20110105010035.10630.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 01:00:34

Added files:
	test           : t-metadata-dirs.sh 

Log message:
	Add a test for RHBZ 640621 (metadata/dirs + no PV MDAs broken).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-dirs.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-metadata-dirs.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-metadata-dirs.sh
+++ -	2011-01-05 01:00:34.976299000 +0000
@@ -0,0 +1,43 @@
+#!/bin/sh
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
+aux prepare_devs 3
+pvcreate --metadatacopies 0 $(cat DEVICES)
+
+not vgcreate $vg $(cat DEVICES)
+
+aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\" ]"
+
+vgcreate $vg $dev1
+check vg_field $vg vg_mda_count 1
+vgremove -ff $vg
+
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 1
+
+vgremove -ff $vg
+pvcreate --metadatacopies 1 --metadataignore y $dev1
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 2
+
+vgremove -ff $vg
+pvcreate --metadatacopies 1 --metadataignore n $dev1
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 2
+
+vgremove -ff $vg
+pvcreate --metadatacopies 0 $dev1
+
+aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\", \"$TESTDIR/mda2\" ]"
+vgcreate $vg $(cat DEVICES)
+check vg_field $vg vg_mda_count 2


