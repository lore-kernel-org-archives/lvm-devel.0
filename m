From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Aug 2008 13:49:07 -0000
Subject: LVM2/test t-covercmd.sh t-metadata.sh
Message-ID: <20080813134907.22474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-13 13:49:07

Added files:
	test           : t-covercmd.sh t-metadata.sh 

Log message:
	added test for coverage improvement
	added test for metadata type 1

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-covercmd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-covercmd.sh
+++ -	2008-08-13 13:49:07.689607000 +0000
@@ -0,0 +1,98 @@
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
+# tests basic functionality of read-ahead and ra regressions
+#
+
+test_description='Test coverage'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  vgremove -f "$vg" 2>/dev/null || true
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  test -n "$d3" && losetup -d "$d3"
+  test -n "$d4" && losetup -d "$d4"
+  test -n "$d5" && losetup -d "$d5"
+  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
+}
+
+get_lvs_()
+{
+  case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
+    *$2) true ;;
+    *) false ;;
+  esac
+}
+
+test_expect_success "set up temp files, loopback devices" \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
+   vg=$(this_test_)-test-vg-$$            &&
+   lv=$(this_test_)-test-lv-$$
+   pvcreate "$d1"                                    &&
+   pvcreate --metadatacopies 0 "$d2"                 &&
+   pvcreate --metadatacopies 0 "$d3"                 &&
+   pvcreate "$d4"                                    &&
+   pvcreate --metadatacopies 0 "$d5"                 &&
+   vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
+   lvcreate -n "$lv" -l 1%FREE -i5 -I256 "$vg"'
+
+test_expect_success "test *scan and *display tools" \
+  'pvscan &&
+   vgscan &&
+   lvscan &&
+   for i in b k m g t p e H B K M G T P E ; do pvdisplay --units $i ; done &&
+   vgdisplay --units k &&
+   lvdisplay --units g'
+
+test_expect_success "test vgexport vgimport tools" \
+  'vgchange -an "$vg" &&
+   vgexport "$vg" &&
+   vgimport "$vg" &&
+   vgchange -ay "$vg"'
+
+# "-persistent y --major 254 --minor 20"
+test_expect_success "test various lvm utils" \
+  'lvmdiskscan &&
+   for i in dumpconfig formats segtypes ; do lvm $i ; done &&
+   for i in pr pw an ay -refresh  "-monitor y" "-monitor n" \
+      "-persistent n" -resync \
+      "-addtag MYTAG" "-deltag MYTAG"; \
+      do lvchange -$i "$vg"/"$lv" ; done &&
+   pvck "$d1" &&
+   vgck "$vg" &&
+   lvrename "$vg" "$lv" "$lv-rename" &&
+   vgcfgbackup -f $(pwd)/backup.$$ "$vg"  &&
+   vgchange -an "$vg" &&
+   pvdisplay &&
+   vgcfgrestore  -f $(pwd)/backup.$$ "$vg" &&
+   vgremove -f "$vg" &&
+   pvresize --setphysicalvolumesize 10M "$d1"'
+
+test_expect_failure "test various errors and obsoleted tools" \
+  'lvmchange          ||
+   lvrename "$vg"     ||
+   lvrename "$vg-xxx" ||
+   lvrename "$vg"  "$vg"/"$lv-rename" "$vg"/"$lv"'
+
+test_done
+
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
/cvs/lvm2/LVM2/test/t-metadata.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-metadata.sh
+++ -	2008-08-13 13:49:07.813408000 +0000
@@ -0,0 +1,68 @@
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
+# tests basic functionality of read-ahead and ra regressions
+#
+
+test_description='Test --metadatatype 1'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+   vgremove -f "$vg"
+   test -n "$d1" && losetup -d "$d1"
+   test -n "$d2" && losetup -d "$d2"
+   test -n "$d3" && losetup -d "$d3"
+   test -n "$d4" && losetup -d "$d4"
+   test -n "$d5" && losetup -d "$d5"
+   rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
+}
+
+test_expect_success "set up temp files, loopback devices" \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
+   vg=$(this_test_)-test-vg-$$            &&
+   lv=$(this_test_)-test-lv-$$
+   pvcreate "$d1"                                    &&
+   pvcreate --metadatacopies 0 "$d2"                 &&
+   pvcreate --metadatacopies 0 "$d3"                 &&
+   pvcreate "$d4"                                    &&
+   pvcreate --metadatacopies 0 "$d5"                 &&
+   vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
+   lvcreate -n "$lv" -l 1%FREE -i5 -I256 "$vg"'
+
+test_expect_success "test medatasize 0" \
+  'pvchange -x n "$d1"   &&
+   pvchange -x y "$d1"   &&
+   vgchange -a n "$vg"   &&
+   pvchange --uuid "$d1" &&
+   pvchange --uuid "$d2" &&
+   vgremove -f "$vg"'
+
+
+test_expect_success "test metadatatype 1" \
+  'pvcreate -M1 "$d1"    &&
+   pvcreate -M1 "$d2"    &&
+   pvcreate -M1 "$d3"    &&
+   vgcreate -M1 "$vg" "$d1" "$d2" "$d3" &&
+   pvchange --uuid "$d1"'
+
+test_done
+
+# Local Variables:
+# indent-tabs-mode: nil
+# End:


