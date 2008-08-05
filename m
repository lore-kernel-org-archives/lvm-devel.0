From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Aug 2008 12:33:42 -0000
Subject: LVM2/test t-pool-labels.sh t-pvcreate-metadata0.sh
Message-ID: <20080805123342.12461.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-05 12:33:41

Added files:
	test           : t-pool-labels.sh t-pvcreate-metadata0.sh 

Log message:
	add test for pool labels gfs
	add test for metadatacopies0 and snapshot manipulation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pool-labels.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-metadata0.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-pool-labels.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pool-labels.sh
+++ -	2008-08-05 12:33:42.090894000 +0000
@@ -0,0 +1,49 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test lvm functionality with GFS pool labels'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  rm -f "$f1" "$f2"
+}
+
+# create the old GFS pool labeled linear devices
+create_pool_label_()
+{
+  echo -en "\x01\x16\x70\x06\x5f\xcf\xff\xb9\xf8\x24\x8apool1" | dd of=$2 bs=5 seek=1 conv=notrunc
+  echo -en "\x04\x01\x03\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x0$1\x68\x01\x16\x70\x00\x00\x00\x00\x00\x06\x5f\xd0" | dd of=$2 bs=273 seek=1 conv=notrunc
+}
+
+test_expect_success "set up temp files, loopback devices, pool labels" \
+  'f1=$(pwd)/0 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/1 && d2=$(loop_setup_ "$f2") &&
+   create_pool_label_ 0 "$d1"             &&
+   create_pool_label_ 1 "$d2"'
+
+test_expect_failure "check that pvcreate fails without -ff on the pool device" \
+  'pvcreate "$d1"'
+
+test_expect_success "check that vgdisplay and pvcreate -ff works with the pool device" \
+  'vgdisplay                         &&
+   test -n "$d2" && losetup -d "$d2" &&
+   vgdisplay                         &&
+   pvcreate -ff -y "$d1"'
+
+test_done
+
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
/cvs/lvm2/LVM2/test/t-pvcreate-metadata0.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pvcreate-metadata0.sh
+++ -	2008-08-05 12:33:42.174626000 +0000
@@ -0,0 +1,49 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Testcase for bugzilla #450651
+# also checks that vgremove properly removes all lv devices in the right order
+#
+test_description='Test pvcreate without metadata on all pvs'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  rm -f "$f1" "$f2"
+}
+
+test_expect_success "set up temp files, loopback devices" \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   vg=$(this_test_)-test-vg-$$            &&
+   lv=$(this_test_)-test-lv-$$            &&
+   lv_snap=$(this_test_)-test-lv-snap-$$  &&
+   pvcreate "$d1"                         &&
+   pvcreate --metadatacopies 0 "$d2"'
+
+test_expect_success "check lv snapshot" \
+  'vgcreate -c n "$vg" "$d1" "$d2"                  &&
+   lvcreate -n "$lv" -l 60%FREE "$vg"               &&
+   lvcreate -s -n "$lv_snap" -l 10%FREE "$vg"/"$lv" &&
+   pvdisplay                                        &&
+   lvdisplay                                        &&
+   vgremove -f "$vg"'
+
+test_done
+
+# Local Variables:
+# indent-tabs-mode: nil
+# End:


