From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:34 +0000 (UTC)
Subject: master - thin: enforce there is some free space in thin pool metadata
Message-ID: <20160919120134.9074B6050A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2c2721d0082d79fab98875dd20f03d6abf72bea
Commit:        c2c2721d0082d79fab98875dd20f03d6abf72bea
Parent:        776d5a25b4ab036103ec99291cb0056fa61490fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 16 21:50:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

thin: enforce there is some free space in thin pool metadata

Unconditionally guard there is at least 1/4 of metadata volume
free (<16Mib) or 4MiB - whichever value is smaller.

In case there is not enough free space do not let operation proceed and
recommend thin-pool metadata resize (in case user has not
enabled autoresize, manual 'lvextend --poolmetadatasize' is needed).
---
 WHATS_NEW                 |    1 +
 lib/metadata/lv_manip.c   |    6 +++++-
 lib/metadata/metadata.h   |    1 +
 lib/metadata/thin_manip.c |   34 +++++++++++++++++++++++++++++++++-
 man/lvcreate.8.in         |    3 +++
 5 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 649607b..ba14c6d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Enforce 4MiB or 25% metadata free space for thin pool operations.
   Fix lock-holder device for thin pool with inactive thin volumes.
   Use --alloc normal for mirror logs even if the mimages were stricter.
   Use O_DIRECT to gather metadata in lvmdump.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d6869e1..1ad85ed 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4515,6 +4515,7 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	dm_percent_t percent;
+	dm_percent_t min_threshold;
 	int policy_threshold, policy_amount;
 
 	*amount = *meta_amount = 0;
@@ -4562,7 +4563,10 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;
 
-		*meta_amount = _adjust_amount(percent, policy_threshold, policy_amount);
+		/* Resize below the minimal usable value */
+		min_threshold = pool_metadata_min_threshold(first_seg(lv)) / DM_PERCENT_1;
+		*meta_amount = _adjust_amount(percent, (min_threshold < policy_threshold) ?
+					      min_threshold : policy_threshold, policy_amount);
 
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index e6dc14a..a9eceaa 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -501,6 +501,7 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 int lv_is_merging_thin_snapshot(const struct logical_volume *lv);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
+int pool_metadata_min_threshold(const struct lv_segment *pool_seg);
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int pool_check_overprovisioning(const struct logical_volume *lv);
 int create_pool(struct logical_volume *lv, const struct segment_type *segtype,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 3b92909..a02a7e6 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -215,9 +215,29 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 	return (attr & feature) ? 1 : 0;
 }
 
+int pool_metadata_min_threshold(const struct lv_segment *pool_seg)
+{
+	/*
+	 * Hardcoded minimal requirment for thin pool target.
+	 *
+	 * In the metadata LV there should be minimum from either 4MiB of free space
+	 * or@least 25% of free space, which applies when the size of thin pool's
+	 * metadata is less then 16MiB.
+	 */
+	const dm_percent_t meta_min = DM_PERCENT_1 * 25;
+	dm_percent_t meta_free = dm_make_percent(((4096 * 1024) >> SECTOR_SHIFT),
+						pool_seg->metadata_lv->size);
+
+	if (meta_min < meta_free)
+		meta_free = meta_min;
+
+	return DM_PERCENT_100 - meta_free;
+}
+
 int pool_below_threshold(const struct lv_segment *pool_seg)
 {
 	dm_percent_t percent;
+	dm_percent_t min_threshold = pool_metadata_min_threshold(pool_seg);
 	dm_percent_t threshold = DM_PERCENT_1 *
 		find_config_tree_int(pool_seg->lv->vg->cmd, activation_thin_pool_autoextend_threshold_CFG,
 				     lv_config_profile(pool_seg->lv));
@@ -226,7 +246,7 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	if (!lv_thin_pool_percent(pool_seg->lv, 0, &percent))
 		return_0;
 
-	if (percent > threshold) {
+	if (percent > threshold || percent >= DM_PERCENT_100) {
 		log_debug("Threshold configured for free data space in "
 			  "thin pool %s has been reached (%.2f%% >= %.2f%%).",
 			  display_lvname(pool_seg->lv),
@@ -239,6 +259,18 @@ int pool_below_threshold(const struct lv_segment *pool_seg)
 	if (!lv_thin_pool_percent(pool_seg->lv, 1, &percent))
 		return_0;
 
+
+	if (percent >= min_threshold) {
+		log_warn("WARNING: Remaining free space in metadata of thin pool %s "
+			 "is too low (%.2f%% >= %.2f%%). "
+			 "Resize is recommended.",
+			 display_lvname(pool_seg->lv),
+			 dm_percent_to_float(percent),
+			 dm_percent_to_float(min_threshold));
+		return 0;
+	}
+
+
 	if (percent > threshold) {
 		log_debug("Threshold configured for free metadata space in "
 			  "thin pool %s has been reached (%.2f%% > %.2f%%).",
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index bf3c33f..84afbda 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -501,6 +501,9 @@ Supported values are in range between 2MiB and 16GiB for thin pool,
 and upto 16GiB for cache pool. The minimum value is computed from pool's
 data size.
 Default value for thin pool is (Pool_LV_size / Pool_LV_chunk_size * 64b).
+To work with a thin pool, there should be at least 25% of free space
+when the size of metadata is smaller then 16MiB,
+or at least 4MiB of free space otherwise.
 Default unit is megabytes.
 .
 .HP


