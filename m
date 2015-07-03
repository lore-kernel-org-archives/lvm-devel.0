From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Jul 2015 14:19:07 +0000 (UTC)
Subject: master - thin: check for overprovisioning
Message-ID: <20150703141907.33A0C60297@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=622064f00fe41a02ab857ce02920a9e8818e610b
Commit:        622064f00fe41a02ab857ce02920a9e8818e610b
Parent:        9cee94372a7e45b6a40478ec17de1c142ed268d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 3 15:31:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 3 16:13:14 2015 +0200

thin: check for overprovisioning

---
 WHATS_NEW                           |    1 +
 lib/metadata/lv_manip.c             |    5 ++
 lib/metadata/metadata.h             |    1 +
 lib/metadata/thin_manip.c           |   88 +++++++++++++++++++++++++++++++++++
 test/shell/thin-overprovisioning.sh |   71 ++++++++++++++++++++++++++++
 5 files changed, 166 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6a33e6d..22fc42a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.124 -
 =================================
+  Report warning when pool is overprovisioned and not auto resized.
   Recognize free-form date/time values for lv_time field in selection criteria.
   Fix regression in select to match string fields if using synonyms (2.02.123).
   Fix regression when printing more lv names via display_lvname (2.02.122).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 87888a7..d23dd62 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5167,6 +5167,8 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 			      lp->extents - lv->le_count,
 			      pvh, alloc, lp->approx_alloc))
 		return_NULL;
+	else if (!pool_check_overprovisioning(lv))
+		return_NULL;
 
 	if (old_extents == lv->le_count)
 		log_print_unless_silent("Size of logical volume %s unchanged from %s (%" PRIu32 " extents).",
@@ -7293,6 +7295,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return_NULL;
 	}
 
+	if (!pool_check_overprovisioning(lv))
+		return_NULL;
+
 	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index abf6072..1a5306b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -485,6 +485,7 @@ int lv_is_merging_thin_snapshot(const struct logical_volume *lv);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
 int pool_below_threshold(const struct lv_segment *pool_seg);
+int pool_check_overprovisioning(const struct logical_volume *lv);
 int create_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 1620d62..1453f88 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -237,6 +237,94 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 }
 
 /*
+ * Detect overprovisioning and check lvm2 is configured for auto resize.
+ *
+ * If passed LV is thin volume/pool, check first only this one for overprovisiong.
+ * Lots of test combined together.
+ * Test is not detecting status of dmeventd, too complex for now...
+ */
+int pool_check_overprovisioning(const struct logical_volume *lv)
+{
+	const struct lv_list *lvl;
+	const struct seg_list *sl;
+	const struct logical_volume *pool_lv = NULL;
+	struct cmd_context *cmd = lv->vg->cmd;
+	const char *txt = "";
+	uint64_t thinsum = 0, poolsum = 0, sz = ~0;
+	int threshold, max_threshold = 0;
+	int percent, min_percent = 100;
+	int more_pools = 0;
+
+	/* When passed thin volume, check related pool first */
+	if (lv_is_thin_volume(lv))
+		pool_lv = first_seg(lv)->pool_lv;
+	else if (lv_is_thin_pool(lv))
+		pool_lv = lv;
+
+	if (pool_lv) {
+		poolsum += pool_lv->size;
+		dm_list_iterate_items(sl, &pool_lv->segs_using_this_lv)
+			thinsum += sl->seg->lv->size;
+
+		if (thinsum <= poolsum)
+			return 1; /* All thins fit into this thin pool */
+	}
+
+	/* Sum all thins and all thin pools in VG */
+	dm_list_iterate_items(lvl, &lv->vg->lvs) {
+		if (!lv_is_thin_pool(lvl->lv))
+			continue;
+
+		threshold = find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
+						 lv_config_profile(lvl->lv));
+		percent = find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG,
+					       lv_config_profile(lvl->lv));
+		if (threshold > max_threshold)
+			max_threshold = threshold;
+		if (percent < min_percent)
+			min_percent = percent;
+
+		if (lvl->lv == pool_lv)
+			continue; /* Skip iteration for already checked thin pool */
+
+		more_pools++;
+		poolsum += lvl->lv->size;
+		dm_list_iterate_items(sl, &lvl->lv->segs_using_this_lv)
+			thinsum += sl->seg->lv->size;
+	}
+
+	if (thinsum <= poolsum)
+		return 1; /* All fits for all pools */
+
+	if ((sz = vg_size(lv->vg)) < thinsum)
+		/* Thin sum size is above VG size */
+		txt = " and the size of whole volume group";
+	else if ((sz = vg_free(lv->vg)) < thinsum)
+		/* Thin sum size is more then free space in a VG */
+		txt = !sz ? "" : " and the amount of free space in volume group";
+	else if ((max_threshold > 99) || !min_percent)
+		/* There is some free space in VG, but it is not configured
+		 * for growing - threshold is 100% or percent is 0% */
+		sz = poolsum;
+
+	if (sz != ~0) {
+		log_warn("WARNING: Sum of all thin volume sizes (%s) exceeds the "
+			 "size of thin pool%s%s%s (%s)!",
+			 display_size(cmd, thinsum),
+			 more_pools ? "" : " ",
+			 more_pools ? "s" : display_lvname(pool_lv),
+			 txt,
+			 (sz > 0) ? display_size(cmd, sz) : "no free space in volume group");
+		if (max_threshold > 99)
+			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_threshold should be bellow 100.");
+		if (!min_percent)
+			log_print_unless_silent("For thin pool auto extension activation/thin_pool_autoextend_percent should be above 0.");
+	}
+
+	return 1;
+}
+
+/*
  * Validate given external origin could be used with thin pool
  */
 int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv)
diff --git a/test/shell/thin-overprovisioning.sh b/test/shell/thin-overprovisioning.sh
new file mode 100644
index 0000000..ac0b96c
--- /dev/null
+++ b/test/shell/thin-overprovisioning.sh
@@ -0,0 +1,71 @@
+#!/bin/sh
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
+# Test warns when thin pool is overprovisiong
+
+export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
+
+. lib/inittest
+
+aux have_thin 1 3 0 || skip
+
+# 2PVs by 32M
+aux prepare_vg 2 33
+
+lvcreate -L32 -T $vg/pool
+
+# leave 12M free space
+lvcreate -an -n $lv1 -L16 $vg 2>&1 | tee out
+vgs $vg
+
+lvcreate -n thin1 -V30 $vg/pool 2>&1 | tee out
+not grep "WARNING: Sum" out
+
+# Pool gets overprovisioned
+lvcreate -an -n thin2 -V4 $vg/pool 2>&1 | tee out
+grep "WARNING: Sum" out
+grep "amount of free space in volume group (12.00 MiB)" out
+
+# Eat all space in VG
+lvcreate -an -n $lv2 -L12 $vg 2>&1 | tee out
+grep "WARNING: Sum" out
+grep "no free space in volume group" out
+
+lvcreate -an -n thin3 -V1G $vg/pool 2>&1 | tee out
+grep "WARNING: Sum" out
+grep "the size of whole volume group" out
+
+lvremove -ff $vg/thin2 $vg/thin3 $vg/$lv2
+
+# Create 2nd thin pool in a VG
+
+lvcreate -L4 -T $vg/pool2
+lvcreate -V4 -n thin2 $vg/pool2 2>&1 | tee out
+not grep "WARNING: Sum" out
+
+lvcreate -an -V4 -n thin3 $vg/pool2 2>&1 | tee out
+grep "WARNING: Sum of all thin volume sizes (38.00 MiB)" out
+grep "free space in volume group (6.00 MiB)" out
+
+lvcreate -an -L6 -n $lv3 $vg 2>&1 | tee out
+grep "no free space in volume group" out
+
+lvremove -ff $vg/thin2 $vg/thin3
+
+lvcreate -an -V4 -n thin2 $vg/pool2 2>&1 | tee out
+not grep "WARNING: Sum" out
+
+# Check if resize notices problem
+lvextend -L+8 $vg/thin2
+
+vgs $vg
+
+vgremove -ff $vg


