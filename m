From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Apr 2014 12:21:47 +0000 (UTC)
Subject: master - tests: add separate test file for bootloader area support and enhance tests
Message-ID: <20140410122147.E671A609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05eb6a167e312679ec8d730f7736023168e77da0
Commit:        05eb6a167e312679ec8d730f7736023168e77da0
Parent:        6c79556f4f836118516a2f1a15056f81e3fc52f6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 10 14:18:59 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 10 14:18:59 2014 +0200

tests: add separate test file for bootloader area support and enhance tests

Enahnce bootloader area test to check whether restoring values from
backup works correctly.
---
 lib/format_text/format-text.c         |    6 ++--
 test/shell/pvcreate-bootloaderarea.sh |   59 +++++++++++++++++++++++++++++++++
 test/shell/pvcreate-usage.sh          |   22 ------------
 3 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 071d2b3..9b894fa 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1536,11 +1536,11 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		/*
 		 * Calculate new PE start and bootloader area start value.
 		 * Make sure both are properly aligned!
-		 * If PE start can't be aligned because EA is taking
+		 * If PE start can't be aligned because BA is taking
 		 * the whole space, make PE start equal to the PV size
 		 * which effectively disables DA - it will have zero size.
 		 * This needs to be done as we can't have a PV without any DA.
-		 * But we still want to support a PV with EA only!
+		 * But we still want to support a PV with BA only!
 		 */
 		if (rp->ba_size) {
 			pv->ba_start = final_alignment;
@@ -1556,7 +1556,7 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		/*
 		 * Try to keep the value of PE start set to a firm value if
 		 * requested. This is useful when restoring existing PE start
-		 * value (e.g. backups). Also, if creating an EA, try to place
+		 * value (e.g. backups). Also, if creating a BA, try to place
 		 * it in between the final alignment and existing PE start
 		 * if possible.
 		 */
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
new file mode 100644
index 0000000..0fa6022
--- /dev/null
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -0,0 +1,59 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Test pvcreate bootloader area support'
+
+. lib/test
+
+aux prepare_devs 1
+aux lvmconf 'global/suffix=0'
+aux lvmconf 'global/units="b"'
+
+#COMM 'pvcreate sets/aligns bootloader area correctly'
+pvcreate --dataalignment 262144b --bootloaderareasize 614400b "$dev1"
+# ba_start must be aligned based on dataalignment
+# pe_start starts at next dataalignment multiple
+# ba_size is the whole space in between ba_start and pe_start
+check pv_field "$dev1" ba_start "262144"
+check pv_field "$dev1" ba_size "786432"
+check pv_field "$dev1" pe_start "1048576"
+
+#COMM 'pvcreate with booloader area size - test corner cases'
+dev_size=$(pvs -o pv_size --noheadings $dev1)
+pv_size=$[dev_size - 1048576] # device size - 1m pe_start = area for data
+
+# try to use the whole data area for bootloader area, remaining data area is zero then (pe_start = pv_size)
+pvcreate --bootloaderareasize ${pv_size}b --dataalignment 1048576b "$dev1"
+check pv_field "$dev1" pe_start $dev_size
+check pv_field "$dev1" ba_start 1048576
+check pv_field "$dev1" ba_size $pv_size
+
+# try to use the whole data area for bootloader area only and add one more byte - this must error out
+not pvcreate --bootloaderareasize $[pv_size + 1] --dataalignment 1048576b "$dev1" 2>err
+grep "Bootloader area with data-aligned start must not exceed device size" err
+
+# restoring the PV should also restore the bootloader area correctly
+pvremove -ff "$dev1"
+pvcreate --dataalignment 256k --bootloaderareasize 600k "$dev1"
+vgcreate $vg "$dev1"
+vgcfgbackup -f $TESTDIR/vg_with_ba_backup $vg
+pv_uuid=$(get pv_field "$dev1" pv_uuid)
+vgremove -ff $vg
+pvremove -ff "$dev1"
+pvcreate --dataalignment 256k --restorefile $TESTDIR/vg_with_ba_backup --uuid "$pv_uuid" "$dev1"
+check pv_field "$dev1" ba_start "262144"
+check pv_field "$dev1" ba_size "786432"
+check pv_field "$dev1" pe_start "1048576"
+
+# error out when restoring the PV and trying to use overlapping bootloader area
+pvremove -ff "$dev1"
+not pvcreate --restorefile $TESTDIR/vg_with_ba_backup --uuid "$pv_uuid" --bootloaderareasize 1m "$dev1" 2>err
+grep "Bootloader area would overlap data area" err
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 378f8b5..251746d 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -187,25 +187,3 @@ for ignore in y n; do
 done
 done
 done
-
-#COMM 'pvcreate sets/aligns bootloader area correctly'
-pvcreate --dataalignment 256k --bootloaderareasize 600k "$dev1"
-# ba_start must be aligned based on dataalignment
-# pe_start starts at next dataalignment multiple
-# ba_size is the whole space in between ba_start and pe_start
-check pv_field "$dev1" ba_start "256.00k"
-check pv_field "$dev1" ba_size "768.00k"
-check pv_field "$dev1" pe_start "1.00m"
-
-aux lvmconf 'global/suffix=0'
-aux lvmconf 'global/units="b"'
-#COMM 'pvcreate with booloader area size - test corner cases
-dev_size=$(pvs -o pv_size --noheadings $dev1)
-pv_size=$[dev_size - 1048576] # device size - 1m pe_start = area for data
-# try to use the whole data area for bootloader area
-pvcreate --bootloaderareasize ${pv_size}b --dataalignment 1048576b "$dev1"
-check pv_field "$dev1" pe_start $dev_size
-check pv_field "$dev1" ba_start 1048576
-check pv_field "$dev1" ba_size ${pv_size}
-not pvcreate --bootloaderareasize $[pv_size + 1] --dataalignment 1048576b "$dev1" 2>err
-grep "Bootloader area with data-aligned start must not exceed device size" err


