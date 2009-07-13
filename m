From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 Jul 2009 16:11:22 -0400
Subject: [PATCH 6/6] Add MD, partition and topology tests to the LVM2 test-suite
In-Reply-To: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
Message-ID: <1247515882-13736-7-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add MD, partition, and topology tests to the LVM2 test-suite.

Added MD devices to the filter in test-utils.sh:prepare_lvmconf()

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 test/t-pvcreate-operation-md.sh |   85 ++++++++++++++++++++++++++++++++++++++++
 test/t-pvcreate-usage.sh        |   12 +++++
 test/test-utils.sh              |    2 
 3 files changed, 98 insertions(+), 1 deletion(-)

Index: LVM2/test/t-pvcreate-operation-md.sh
===================================================================
--- /dev/null
+++ LVM2/test/t-pvcreate-operation-md.sh
@@ -0,0 +1,85 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# skip this test if mdadm or sfdisk aren't available
+which mdadm || exit 200
+which sfdisk || exit 200
+
+. ./test-utils.sh
+
+aux prepare_devs 2
+
+# Have MD use a non-standard name to avoid colliding with an existing MD device
+mddev=/dev/md_lvm_test0
+mddev_p=${mddev}p1
+
+cleanup_md() {
+    mdadm --stop $mddev
+    rm -f $mddev
+}
+
+# create 2 disk MD raid0 array (stripe_width=128K)
+[ -b "$mddev" ] && exit 200
+mdadm --create $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
+trap 'aux cleanup_md' EXIT # cleanup this MD device at the end of the test
+
+# Test alignment of PV on MD without any MD-aware or topology-aware detection
+# - should treat $mddev just like any other block device
+pv_align="192.00K"
+pvcreate --metadatasize 128k \
+    --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
+    $mddev
+check_pv_field_ $mddev pe_start $pv_align
+
+# Test md_chunk_alignment independent of topology-aware detection
+pv_align="256.00K"
+pvcreate --metadatasize 128k \
+    --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
+    $mddev
+check_pv_field_ $mddev pe_start $pv_align
+
+# Test newer topology-aware alignment detection
+pv_align="256.00K"
+pvcreate --metadatasize 128k \
+    --config 'devices { md_chunk_alignment=0 }' $mddev
+check_pv_field_ $mddev pe_start $pv_align
+
+# partition MD array directly, depends on blkext in Linux >= 2.6.28
+linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
+if [ $linux_minor -gt 27 ]; then
+    sfdisk $mddev <<EOF
+,,83
+EOF
+    # make sure partition on MD is _not_ removed
+    # - tests partition -> parent lookup via sysfs paths
+    not pvcreate --metadatasize 128k $mddev
+
+    # verify alignment_offset padding is accounted for in pe_start
+    # - topology infrastructure is available in Linux >= 2.6.31
+    # - also tests partition -> parent lookup via sysfs paths
+    base_mddev=`basename $mddev`
+    base_mddev_p=`basename $mddev_p`
+    sysfs_alignment_offset=/sys/block/${base_mddev}/${base_mddev_p}/alignment_offset
+    [ -f "$sysfs_alignment_offset" ] && \
+	alignment_offset=`cat $sysfs_alignment_offset` || \
+	alignment_offset=0
+
+    if [ "$alignment_offset" = "512" ]; then
+	pv_align="256.50K"
+	pvcreate --metadatasize 128k $mddev_p
+	check_pv_field_ $mddev_p pe_start $pv_align
+	pvremove $mddev_p
+    elif [ "$alignment_offset" = "2048" ]; then
+	pv_align="258.00K"
+	pvcreate --metadatasize 128k $mddev_p
+	check_pv_field_ $mddev_p pe_start $pv_align
+	pvremove $mddev_p
+    fi
+fi
Index: LVM2/test/t-pvcreate-usage.sh
===================================================================
--- LVM2.orig/test/t-pvcreate-usage.sh
+++ LVM2/test/t-pvcreate-usage.sh
@@ -116,6 +116,18 @@ check_pv_field_ $dev1 pe_start $pv_align
 pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
 check_pv_field_ $dev1 pe_start $pv_align
 
+# data area is aligned to 64k by default,
+# data area has additional padding before its start
+pv_align="195.50K"
+pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
+check_pv_field_ $dev1 pe_start $pv_align
+
+# 2nd metadata area is created without problems when
+# additional data area padding is used
+pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s $dev1
+check_pv_field_ $dev1 pv_mda_count 2
+# FIXME: compare start of 2nd mda with and without --dataalignmentoffset
+
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
 pvcreate --dataalignment 256k $dev1
Index: LVM2/test/test-utils.sh
===================================================================
--- LVM2.orig/test/test-utils.sh
+++ LVM2/test/test-utils.sh
@@ -182,7 +182,7 @@ prepare_lvmconf() {
   devices {
     dir = "$G_dev_"
     scan = "$G_dev_"
-    filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]
+    filter = [ "a|/dev/md.*|", "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]
     cache_dir = "$G_root_/etc"
     sysfs_scan = 0
   }


