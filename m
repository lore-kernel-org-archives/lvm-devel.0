From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jun 2015 16:52:39 +0000 (UTC)
Subject: master - thin: support unaligned size of external origin and thin pool
Message-ID: <20150618165239.BD64460F08@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3e0d830bde952a83da3ba60936fff2fa7b40966
Commit:        a3e0d830bde952a83da3ba60936fff2fa7b40966
Parent:        6f2a617c318d3e7b4535563b72ddcaad67da62ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 18 14:38:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 18 18:50:36 2015 +0200

thin: support unaligned size of external origin and thin pool

With thin-pool kernel target module 1.13 it's now support usage of
external origin with sizes which are not 'alligned' with chunk size
of thin-pool.

Enable lvm2 support for this and also fix reporting of data_percent
usage for case sizes are not alligned.
---
 WHATS_NEW                                 |    1 +
 lib/metadata/thin_manip.c                 |    9 +--
 lib/thin/thin.c                           |   10 ++-
 test/shell/lvcreate-thin-external-size.sh |   90 +++++++++++++++++++++++++++++
 4 files changed, 102 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 42a2571..8d6e7f2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.122 - 
 =================================
+  Support thins with size of external origin unaligned with thin pool chunk.
   Allow to extend reduced thin volumes with external origins.
   Consider snapshot and origin LV as unusable if its component is suspended.
   Fix lvmconfig segfault on settings with undefined default value (2.02.120).
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index e617b3c..1620d62 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -243,12 +243,11 @@ int pool_supports_external_origin(const struct lv_segment *pool_seg, const struc
 {
 	uint32_t csize = pool_seg->chunk_size;
 
-	if ((external_lv->size < csize) || (external_lv->size % csize)) {
-		/* TODO: Validate with thin feature flag once, it will be supported */
-		log_error("Can't use \"%s/%s\" as external origin with \"%s/%s\" pool. "
+	if (((external_lv->size < csize) || (external_lv->size % csize)) &&
+	    !thin_pool_feature_supported(pool_seg->lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
+		log_error("Can't use \"%s\" as external origin with \"%s\" pool. "
 			  "Size %s is not a multiple of pool's chunk size %s.",
-			  external_lv->vg->name, external_lv->name,
-			  pool_seg->lv->vg->name, pool_seg->lv->name,
+			  display_lvname(external_lv), display_lvname(pool_seg->lv),
 			  display_size(external_lv->vg->cmd, external_lv->size),
 			  display_size(external_lv->vg->cmd, csize));
 		return 0;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index e250603..e098744 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -609,14 +609,18 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 				uint64_t *total_denominator)
 {
 	struct dm_status_thin *s;
+	uint64_t csize;
 
 	/* Status for thin device is in sectors */
 	if (!dm_get_status_thin(mem, params, &s))
 		return_0;
 
 	if (seg) {
-		*percent = dm_make_percent(s->mapped_sectors, seg->lv->size);
-		*total_denominator += seg->lv->size;
+		/* Pool allocates whole chunk so round-up to nearest one */
+		csize = first_seg(seg->pool_lv)->chunk_size;
+		csize = ((seg->lv->size + csize - 1) / csize) * csize;
+		*percent = dm_make_percent(s->mapped_sectors, csize);
+		*total_denominator += csize;
 	} else {
 		/* No lv_segment info here */
 		*percent = DM_PERCENT_INVALID;
@@ -645,8 +649,8 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
 		{ 1, 10, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
-		{ 9, 11, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND, "external_origin_extend" },
 		{ 1, 10, THIN_FEATURE_ERROR_IF_NO_SPACE, "error_if_no_space" },
+		{ 1, 13, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND, "external_origin_extend" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";
diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
new file mode 100644
index 0000000..73e36ea
--- /dev/null
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -0,0 +1,90 @@
+#!/bin/sh
+
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test unaligned size of external origin and thin pool chunk size
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+test -e LOCAL_LVMPOLLD && skip
+
+which cmp || skip
+
+#
+# Main
+#
+aux have_thin 1 3 0 || skip
+
+aux prepare_pvs 2 640
+
+# Use 8K extent size
+vgcreate $vg -s 8K $(cat DEVICES)
+
+# Prepare some numeric pattern with ~64K size
+seq -s ' ' -w 0 10922 > 64K
+
+d1="$DM_DEV_DIR/$vg/$lv1"
+d2="$DM_DEV_DIR/$vg/$lv2"
+
+# Prepare external origin LV with size not being a multiple of thin pool chunk size
+lvcreate -l47 -n $lv1 $vg
+
+# Fill end with pattern
+dd if=64K of="$d1" bs=8192 seek=45 count=2
+
+# Switch to read-only volume
+lvchange -an $vg/$lv1
+lvchange -pr $vg/$lv1
+
+lvcreate -L2M -T $vg/pool -c 192K
+lvcreate -s $vg/$lv1 --name $lv2 --thinpool $vg/pool
+
+# Check the tail of $lv2 matches $lv1
+dd if="$d2" of=16K bs=8192 skip=45 count=2
+cmp -n 16384 -l 64K 16K
+
+# Now extend and rewrite
+lvextend -l+2 $vg/$lv2
+
+dd if=64K of="$d2" bs=8192 seek=46 count=3 oflag=direct
+dd if="$d2" of=24K bs=8192 skip=46 count=3 iflag=direct
+cmp -n 24576 -l 64K 24K
+
+# Consumes 2 192K chunks -> 66.67%
+check lv_field $vg/$lv2 data_percent "66.67"
+
+lvreduce -f -l-24 $vg/$lv2
+
+dd if=64K of="$d2" bs=8192 seek=24 count=1 oflag=direct
+dd if="$d2" of=8K bs=8192 skip=24 count=1 iflag=direct
+cmp -n 8192 -l 64K 8K
+
+# Check extension still works
+lvextend -l+2 $vg/$lv2
+
+lvremove -f $vg/pool
+
+lvcreate -L256M -T $vg/pool -c 64M
+lvcreate -s $vg/$lv1 --name $lv2 --thinpool $vg/pool
+lvextend -l+2 $vg/$lv2
+
+dd if=64K of="$d2" bs=8192 seek=45 count=4 oflag=direct
+dd if="$d2" of=32K bs=8192 skip=45 count=4 iflag=direct
+cmp -n 32768 -l 64K 32K
+
+lvextend -L+64M $vg/$lv2
+
+# Consumes 64M chunk -> 50%
+check lv_field $vg/$lv2 data_percent "50.00"
+
+vgremove -ff $vg


