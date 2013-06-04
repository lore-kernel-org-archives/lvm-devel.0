From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:16 +0000 (UTC)
Subject: dev-mornfall-activate - Fix alignment of PV data area if detected alignment less than 1 MB
Message-ID: <20130604192616.AF4A161084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ad7865b421459553a05e220f992ba2d26bd60e6
Commit:        8ad7865b421459553a05e220f992ba2d26bd60e6
Parent:        6fc67f5509fda25a91536fbeeb7099f8327ff3d8
Author:        Mike Snitzer <snitzer@redhat.com>
AuthorDate:    Mon May 13 15:56:47 2013 -0400
Committer:     Mike Snitzer <snitzer@redhat.com>
CommitterDate: Mon May 13 15:56:47 2013 -0400

Fix alignment of PV data area if detected alignment less than 1 MB

This fixes a long standing regression since LVM2 2.02.74 (commit 4efb1d9c,
"Update heuristic used for default and detected data alignment.")

The default PE alignment could be used (via MAX()) even if it was
determined that the device's MD stripe width, or minimal_io_size or
optimal_io_size were not factors of the default PE alignment (either 64K
or the newer default of 1MB, etc).  This bug would manifest if the
default PE alignment was larger than the overriding hint that the
device provided (e.g. default of 1MB vs optimal_io_size of 768K).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW                      |    1 +
 lib/metadata/metadata.c        |    6 +++---
 test/shell/topology-support.sh |   27 +++++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 11d3e6f..513210c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix alignment of PV data area if detected alignment less than 1 MB (2.02.74).
   Fix memory resource leak in memlocking error path.
   Fix premature DM version checking which caused useless mapper/control access.
   Add "active" LV reporting field to show activation state.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bde1cb0..357e849 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -86,7 +86,7 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (find_config_tree_bool(pv->fmt->cmd, devices_md_chunk_alignment_CFG)) {
 		temp_pe_align = dev_md_stripe_width(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
+			pv->pe_align = temp_pe_align;
 	}
 
 	/*
@@ -99,11 +99,11 @@ unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignm
 	if (find_config_tree_bool(pv->fmt->cmd, devices_data_alignment_detection_CFG)) {
 		temp_pe_align = dev_minimum_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
+			pv->pe_align = temp_pe_align;
 
 		temp_pe_align = dev_optimal_io_size(pv->fmt->cmd->sysfs_dir, pv->dev);
 		if (_alignment_overrides_default(temp_pe_align, default_pe_align))
-			pv->pe_align = MAX(pv->pe_align, temp_pe_align);
+			pv->pe_align = temp_pe_align;
 	}
 
 out:
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index e952dc0..df73c6a 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -23,6 +23,16 @@ check_logical_block_size() {
     fi
 }
 
+check_optimal_io_size() {
+    local DEV_=$(cat SCSI_DEBUG_DEV)
+    # Verify optimal_io_size
+    SYSFS_OPTIMAL_IO_SIZE=$(echo /sys/block/$(basename $DEV_)/queue/optimal_io_size)
+    if [ -f "$SYSFS_OPTIMAL_IO_SIZE" ] ; then
+	ACTUAL_OPTIMAL_IO_SIZE=$(cat $SYSFS_OPTIMAL_IO_SIZE)
+	test $ACTUAL_OPTIMAL_IO_SIZE = $1
+    fi
+}
+
 lvdev_() {
     echo "$DM_DEV_DIR/$1/$2"
 }
@@ -103,3 +113,20 @@ aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate -c n $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
+
+aux cleanup_scsi_debug_dev
+
+# ---------------------------------------------
+# Create "enterprise-class" 512 drive w/ HW raid stripe_size = 768K
+# (logical_block_size=512, physical_block_size=512, alignment_offset=0):
+# - tests case where optimal_io_size=768k < default PE alignment=1MB
+LOGICAL_BLOCK_SIZE=512
+aux prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE opt_blks=1536
+check_logical_block_size $LOGICAL_BLOCK_SIZE
+check_optimal_io_size 786432
+
+aux prepare_pvs 1 $PER_DEV_SIZE
+check pv_field $(cat DEVICES) pe_start 768.00k
+
+aux cleanup_scsi_debug_dev


