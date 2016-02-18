From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 15:50:27 +0000 (UTC)
Subject: master - tests: checking thin flags
Message-ID: <20160218155027.0A84560C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcf7f80791d8bcee20056fd371b7f1557d5c1649
Commit:        bcf7f80791d8bcee20056fd371b7f1557d5c1649
Parent:        485bce1ae398d6764dd238dc2451e4089281284f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 16:44:42 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 16:49:38 2016 +0100

tests: checking thin flags

Test various  (D/M/F) attrs for thin-pool/thin
---
 test/shell/thin-flags.sh |  114 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
new file mode 100644
index 0000000..336e541
--- /dev/null
+++ b/test/shell/thin-flags.sh
@@ -0,0 +1,114 @@
+#!/bin/bash
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# test presence of various thin-pool/thin flags
+
+SKIP_WITH_LVMPOLLD=1
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+
+# TODO - aux/get support for this....
+fake_metadata_() {
+	echo '<superblock uuid="" time="0" transaction="'$2'" data_block_size="128" nr_data_blocks="3200">'
+	echo ' <device dev_id="1" mapped_blocks="0" transaction="0" creation_time="0" snap_time="0">'
+	echo ' </device>'
+	for i in $(seq 10 $1)
+	do
+		echo ' <device dev_id="'$i'" mapped_blocks="30" transaction="0" creation_time="0" snap_time="0">'
+		echo '  <range_mapping origin_begin="0" data_begin="0" length="29" time="0"/>'
+		echo ' </device>'
+		set +x
+	done
+	echo "</superblock>"
+	set -x
+}
+
+
+. lib/inittest
+
+#
+# Main
+#
+aux have_thin 1 3 0 || skip
+
+aux prepare_vg 2 256
+
+###############################################
+#  Testing failing thin-pool metadata device  #
+###############################################
+
+lvcreate -T -L1M --errorwhenfull y $vg/pool
+lvcreate -V2 -n $lv2 $vg/pool
+
+aux error_dev  "$dev2" 2054:2
+check lv_attr_bit health $vg/pool "F"
+check lv_attr_bit health $vg/$lv2 "F"
+aux enable_dev "$dev2"
+
+lvchange -an $vg
+
+# Overfill data area
+lvchange -ay $vg
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=2
+check lv_attr_bit health $vg/pool "D"
+# TODO use spaces ??
+check lv_field $vg/pool lv_health_status "out_of_data"
+
+lvremove -ff $vg
+
+
+#######################################################
+#  Testing what happens on system without thin-check  #
+#######################################################
+
+lvcreate -L200M --errorwhenfull y -T $vg/pool
+lvcreate -V2 -n $lv2 $vg/pool
+lvchange -an $vg
+
+# Drop usage of  thin_check
+aux lvmconf 'global/thin_check_executable = ""'
+
+# Prepare some fake metadata prefilled to ~100%
+lvcreate -L2 -n $lv1 $vg # tmp for metadata
+fake_metadata_ 500 1 >data
+"$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
+
+# Swap volume with restored fake metadata
+lvconvert -y --thinpool $vg/pool --poolmetadata $vg/$lv1
+
+lvchange -ay $vg
+
+lvchange -ay $vg/$lv2
+# Provisiong and last free bits in metadata
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=32K count=1
+
+check lv_attr_bit health $vg/pool "M"
+check lv_attr_bit state $vg/pool "c"
+check lv_field $vg/pool lv_check_needed "check needed"
+# TODO - use spaces ??
+check lv_field $vg/pool lv_health_status "metadata_read_only"
+
+check lv_attr_bit health $vg/$lv2 "-"
+
+dmsetup suspend $vg-pool-tpool
+
+# suspended  thin-pool with Capital 'c'
+check lv_attr_bit state $vg/pool "C"
+
+dmsetup resume $vg-pool-tpool
+
+lvresize -L+2M $vg/pool_tmeta
+
+# still require thin_check
+check lv_attr_bit state $vg/pool "c"
+
+vgremove -ff $vg


