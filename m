From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jul 2008 21:32:39 -0000
Subject: LVM2 lib/format_text/format-text.c ./WHATS_NEW ...
Message-ID: <20080716213239.7402.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-16 21:32:39

Modified files:
	lib/format_text: format-text.c 
	.              : WHATS_NEW 
Added files:
	test           : t-pvcreate-usage.sh 

Log message:
	Add pvcreate sanity tests, check for label_write() failure in _text_pv_write().
	
	Failure to check for label_write() return code caused the following test
	to indicate it passed when it really failed:
	pvcreate rejects labelsector > 1000000000000

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.930&r2=1.931

--- LVM2/lib/format_text/format-text.c	2008/03/17 16:51:31	1.90
+++ LVM2/lib/format_text/format-text.c	2008/07/16 21:32:38	1.91
@@ -1363,7 +1363,10 @@
 		}
 	}
 
-	label_write(pv->dev, label);
+	if (!label_write(pv->dev, label)) {
+		dev_close(pv->dev);
+		return_0;
+	}
 
 	if (!dev_close(pv->dev))
 		return_0;
/cvs/lvm2/LVM2/test/t-pvcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pvcreate-usage.sh
+++ -	2008-07-16 21:32:39.280246000 +0000
@@ -0,0 +1,115 @@
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
+test_description='Test pvcreate option values'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  test -n "$d3" && losetup -d "$d3"
+  test -n "$d4" && losetup -d "$d4"
+  rm -f "$f1" "$f2" "$f3" "$f4"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, vgname' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4")'
+
+# x. negative setphysicalvolumesize, metadatasize
+test_expect_success \
+  'pvcreate rejects negative setphysicalvolumesize' \
+  'pvcreate --setphysicalvolumesize -1024 $d1;
+   status=$?; echo status=$status; test $status != 0'
+
+test_expect_success \
+  'pvcreate rejects negative metadatasize' \
+  'pvcreate --metadatasize -1024 $d1;
+   status=$?; echo status=$status; test $status != 0'
+
+# x. metadatasize 0, defaults to 255
+# FIXME: unable to check default value, not in reporting cmds
+# should default to 255 according to code
+#   check_pv_field_ pv_mda_size 255 &&
+test_expect_success \
+  'pvcreate accepts metadatasize 0' \
+  'pvcreate --metadatasize 0 $d1 &&
+   pvremove $d1'
+
+# x. metadatasize too large
+# For some reason we allow this, even though there's no room for data?
+#test_expect_success \
+#  'pvcreate rejects metadatasize too large' \
+#  'pvcreate --metadatasize 100000000000000 $d1;
+#   status=$?; echo status=$status; test $status != 0'
+
+# x. metadatacopies < 0, defaults to 1
+test_expect_success \
+  'pvcreate rejects metadatacopies < 0' \
+  'pvcreate --metadatacopies -1 $d1;
+   status=$?; echo status=$status; test $status != 0'
+
+# x. metadatacopies = 0, 1, 2 pass, > 2 fail
+test_expect_success \
+  'pvcreate accepts metadatacopies = 0, 1, 2' \
+  'pvcreate --metadatacopies 0 $d1 &&
+   pvcreate --metadatacopies 1 $d2 &&
+   pvcreate --metadatacopies 2 $d3 &&
+   check_pv_field_ $d1 pv_mda_count 0 &&
+   check_pv_field_ $d2 pv_mda_count 1 &&
+   check_pv_field_ $d3 pv_mda_count 2 &&
+   pvremove $d1 &&
+   pvremove $d2 &&
+   pvremove $d3'
+
+# x. metadatacopies > 2 fail
+test_expect_success \
+  'pvcreate rejects metadatacopies > 2' \
+  'pvcreate --metadatacopies 3 $d1 &&
+   status=$?; echo status=$status; test $status != 0'
+
+# x. bogus device given
+test_expect_success \
+  'pvcreate rejects invalid device' \
+  'pvcreate $d1bogus &&
+   status=$?; echo status=$status; test $status != 0'
+
+# x. labelsector out of range (< 0 or > deviceSizeInSectors)
+test_expect_success \
+  'pvcreate rejects labelsector < 0' \
+  'pvcreate --labelsector -1 $d1;
+   status=$?; echo status=$status; test $status != 0'
+
+test_expect_success \
+  'pvcreate rejects labelsector > 1000000000000' \
+  'pvcreate --labelsector 1000000000000 $d1;
+   status=$?; echo status=$status; test $status != 0'
+
+# other possibilites based on code inspection (not sure how hard)
+# x. device too small (min of 512 * 1024 KB)
+# x. device filtered out
+# x. unable to open /dev/urandom RDONLY
+# x. device too large (pe_count > UINT32_MAX)
+# x. device read-only
+# x. unable to open device readonly
+# x. BLKGETSIZE64 fails
+# x. set size to value inconsistent with device / PE size
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/WHATS_NEW	2008/07/16 10:46:12	1.930
+++ LVM2/WHATS_NEW	2008/07/16 21:32:38	1.931
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Add pvcreate sanity tests, check for label_write() failure in _text_pv_write().
   Fix pvchange -M1 -u to preserve existing extent locations when there's a VG.
   Cease recognising snapshot-in-use percentages returned by early devt kernels.
   Add backward-compatible flags field to on-disk format_text metadata.


