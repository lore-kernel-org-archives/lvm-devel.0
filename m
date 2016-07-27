From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 27 Jul 2016 16:21:12 +0000 (UTC)
Subject: master - vg_validate: segment check enhancements for raids to catch bogus metadata
Message-ID: <20160727162112.4951D60BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f62b7bfe56c25efbbff5fea26ce29ac6378f08a
Commit:        8f62b7bfe56c25efbbff5fea26ce29ac6378f08a
Parent:        9ad30b0b38a212a51af5c25b0783cb595fa3ab76
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jul 27 18:17:29 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jul 27 18:17:29 2016 +0200

vg_validate: segment check enhancements for raids to catch bogus metadata

General RAID and RAID segment type specific checks are added
to merge.c. New static _check_raid_seg() is called on each segment
of a RaidLV (which have just one) from check_lv_segments().

New checks caught some unititialized segment members
which are addressed here as well:

- initialize seg->region_size to 0 in lvcreate.c for raid0/raid0_meta

- initialize list seg->origin_list in lv_manip.c
---
 lib/metadata/lv_manip.c |    1 +
 lib/metadata/merge.c    |  248 +++++++++++++++++++++++++++++++++++++++++++++++
 tools/lvcreate.c        |    4 +-
 3 files changed, 252 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2a55be7..a465c4c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -949,6 +949,7 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	seg->extents_copied = extents_copied;
 	seg->pvmove_source_seg = pvmove_source_seg;
 	dm_list_init(&seg->tags);
+	dm_list_init(&seg->origin_list);
 	dm_list_init(&seg->thin_messages);
 
 	if (log_lv && !attach_mirror_log(seg, log_lv))
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 7aed002..8e7d107 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -14,6 +14,7 @@
  */
 
 #include "lib.h"
+#include <defaults.h>
 #include "metadata.h"
 #include "lv_alloc.h"
 #include "pv_alloc.h"
@@ -71,6 +72,249 @@ int lv_merge_segments(struct logical_volume *lv)
 		goto out
 
 /*
+ * RAID segment property checks.
+ *
+ * Checks in here shall catch any
+ * bogus segment structure setup.
+ */
+#define raid_seg_error(msg) { \
+	log_error("LV %s invalid: %s for %s segment", \
+		  seg->lv->name, (msg), lvseg_name(seg)); \
+	if ((*error_count)++ > ERROR_MAX) \
+		return; \
+}
+
+#define raid_seg_error_val(msg, val) { \
+	log_error("LV %s invalid: %s (is %u) for %s segment", \
+		  seg->lv->name, (msg), (val), lvseg_name(seg)); \
+	if ((*error_count)++ > ERROR_MAX) \
+		return; \
+}
+
+/* Check raid0 segment properties in @seg */
+static void _check_raid0_seg(struct lv_segment *seg, int *error_count)
+{
+	if (seg_is_raid0_meta(seg) &&
+	    !seg->meta_areas)
+		raid_seg_error("no meta areas");
+	if (!seg->stripe_size)
+		raid_seg_error("zero stripe size");
+	if (!is_power_of_2(seg->stripe_size))
+		raid_seg_error_val("non power of 2 stripe size", seg->stripe_size);
+	if (seg->region_size)
+		raid_seg_error_val("non-zero region_size", seg->region_size);
+	if (seg->writebehind)
+		raid_seg_error_val("non-zero write behind", seg->writebehind);
+	if (seg->min_recovery_rate)
+		raid_seg_error_val("non-zero min recovery rate", seg->min_recovery_rate);
+	if (seg->max_recovery_rate)
+		raid_seg_error_val("non-zero max recovery rate", seg->max_recovery_rate);
+}
+
+/* Check RAID @seg for non-zero, power of 2 region size and min recovery rate <= max */
+static void _check_raid_region_recovery(struct lv_segment *seg, int *error_count)
+{
+	if (!seg->region_size)
+		raid_seg_error("zero region_size");
+	if (!is_power_of_2(seg->region_size))
+		raid_seg_error_val("non power of 2 region size", seg->region_size);
+	/* min/max recovery rate may be zero but min may not be larger than max*/
+	if (seg->min_recovery_rate > seg->max_recovery_rate)
+		raid_seg_error_val("min recovery larger than max recovery larger", seg->min_recovery_rate);
+}
+
+/* Check raid1 segment properties in @seg */
+static void _check_raid1_seg(struct lv_segment *seg, int *error_count)
+{
+	if (!seg->meta_areas)
+		raid_seg_error("no meta areas");
+	if (seg->stripe_size)
+		raid_seg_error_val("non-zero stripe size", seg->stripe_size);
+	_check_raid_region_recovery(seg, error_count);
+}
+
+/* Check raid4/5/6/10 segment properties in @seg */
+static void _check_raid45610_seg(struct lv_segment *seg, int *error_count)
+{
+	/* Checks applying to any raid4/5/6/10 */
+	if (!seg->meta_areas)
+		raid_seg_error("no meta areas");
+	if (!seg->stripe_size)
+		raid_seg_error("zero stripe size");
+	if (!is_power_of_2(seg->stripe_size))
+		raid_seg_error_val("non power of 2 stripe size", seg->stripe_size);
+	_check_raid_region_recovery(seg, error_count);
+	/* END: checks applying to any raid4/5/6/10 */
+
+	/* Specific checks per raid level */
+	if (seg_is_raid4(seg) ||
+	    seg_is_any_raid5(seg)) {
+		/*
+		 * To allow for takeover between the MD raid1 and
+		 * raid4/5 personalities, exactly 2 areas (i.e. DataLVs)
+		 * can be mirrored by all raid1, raid4 and raid5 personalities.
+		 * Hence allow a minimum of 2 areas.
+		 */
+		if (seg->area_count < 2)
+			raid_seg_error_val("minimum 2 areas required", seg->area_count);
+	} else if (seg_is_any_raid6(seg)) {
+		/*
+		 * FIXME: MD raid6 supports a minimum of 4 areas.
+		 *	  LVM requests a minimum of 5 due to easier
+		 *	  processing of SubLVs to replace.
+		 *
+		 *	  Once that obstacle got removed, allow for a minimum of 4.
+		 */
+		if (seg->area_count < 5)
+			raid_seg_error_val("minimum 5 areas required", seg->area_count);
+	} else if (seg_is_raid10(seg)) {
+		/*
+		 * FIXME: raid10 area_count minimum has to change to 2 once we
+		 *	  support data_copies and odd numbers of stripes
+		 */
+		if (seg->area_count < 4)
+			raid_seg_error_val("minimum 4 areas required", seg->area_count);
+		if (seg->writebehind)
+			raid_seg_error_val("non-zero writebehind", seg->writebehind);
+	}
+}
+
+/* Check any non-RAID segment struct members in @seg and increment @error_count for any bogus ones */
+static void _check_non_raid_seg_members(struct lv_segment *seg, int *error_count)
+{
+	if (seg->origin) /* snap and thin */
+		raid_seg_error("non-zero origin LV");
+	if (seg->indirect_origin) /* thin */
+		raid_seg_error("non-zero indirect_origin LV");
+	if (seg->merge_lv) /* thin */
+		raid_seg_error("non-zero merge LV");
+	if (seg->cow) /* snap */
+		raid_seg_error("non-zero cow LV");
+	if (!dm_list_empty(&seg->origin_list)) /* snap */
+		raid_seg_error("non-zero origin_list");
+	if (seg->extents_copied)
+		raid_seg_error("non-zero extents_copied");
+	if (seg->log_lv)
+		raid_seg_error("non-zero log LV");
+	if (seg->segtype_private)
+		raid_seg_error("non-zero segtype_private");
+	/* thin members */
+	if (seg->metadata_lv)
+		raid_seg_error("non-zero metadata LV");
+	if (seg->transaction_id)
+		raid_seg_error("non-zero transaction_id");
+	if (seg->zero_new_blocks)
+		raid_seg_error("non-zero zero_new_blocks");
+	if (seg->discards)
+		raid_seg_error("non-zero discards");
+	if (!dm_list_empty(&seg->thin_messages))
+		raid_seg_error("non-zero thin_messages list");
+	if (seg->external_lv)
+		raid_seg_error("non-zero external LV");
+	if (seg->pool_lv)
+		raid_seg_error("non-zero pool LV");
+	if (seg->device_id)
+		raid_seg_error("non-zero device_id");
+	/* cache members */
+	if (seg->cache_mode)
+		raid_seg_error("non-zero cache_mode");
+	if (seg->policy_name)
+		raid_seg_error("non-zero policy_name");
+	if (seg->policy_settings)
+		raid_seg_error("non-zero policy_settings");
+	if (seg->cleaner_policy)
+		raid_seg_error("non-zero cleaner_policy");
+	/* replicator members (deprecated) */
+	if (seg->replicator)
+		raid_seg_error("non-zero replicator");
+	if (seg->rlog_lv)
+		raid_seg_error("non-zero rlog LV");
+	if (seg->rlog_type)
+		raid_seg_error("non-zero rlog type");
+	if (seg->rdevice_index_highest)
+		raid_seg_error("non-zero rdevice_index_highests");
+	if (seg->rsite_index_highest)
+		raid_seg_error("non-zero rsite_index_highests");
+	/* .... more members? */
+}
+
+/*
+ * Check RAID segment sruct members of @seg for acceptable
+ * properties and increment @error_count for any bogus ones.
+ */
+static void _check_raid_seg(struct lv_segment *seg, int *error_count)
+{
+	uint32_t area_len, s;
+
+	/* General checks applying to all RAIDs */
+	if (!seg_is_raid(seg))
+		raid_seg_error("erroneous RAID check");
+
+	if (!seg->area_count)
+		raid_seg_error("zero area count");
+
+	if (!seg->areas)
+		raid_seg_error("zero areas");
+
+	/* Default still 8, change! */
+	if (seg->area_count > DEFAULT_RAID_MAX_IMAGES) {
+		log_error("LV %s invalid: maximum supported areas %u (is %u) for %s segment",
+			  seg->lv->name, DEFAULT_RAID_MAX_IMAGES, seg->area_count, lvseg_name(seg));
+			if ((*error_count)++ > ERROR_MAX)
+				return;
+	}
+
+	if (seg->chunk_size)
+		raid_seg_error_val("non-zero chunk_size", seg->chunk_size);
+
+	/* FIXME: should we check any non-RAID segment struct members at all? */
+	_check_non_raid_seg_members(seg, error_count);
+
+	/* Check for any DataLV flaws like non-existing ones or size variations */
+	for (area_len = s = 0; s < seg->area_count; s++) {
+		if (seg_type(seg, s) != AREA_LV)
+			raid_seg_error("no DataLV");
+		if (!lv_is_raid_image(seg_lv(seg, s)))
+			raid_seg_error("DataLV without RAID image flag");
+		if (area_len &&
+		    area_len != seg_lv(seg, s)->le_count) {
+				raid_seg_error_val("DataLV size variations",
+		    				   seg_lv(seg, s)->le_count);
+		} else
+			area_len = seg_lv(seg, s)->le_count;
+	}
+
+	/* Check for any MetaLV flaws like non-existing ones or size variations */
+	if (seg->meta_areas)
+		for (area_len = s = 0; s < seg->area_count; s++) {
+			if (seg_metatype(seg, s) != AREA_LV)
+				raid_seg_error("no MetaLV");
+			if (!lv_is_raid_metadata(seg_metalv(seg, s)))
+				raid_seg_error("MetaLV without RAID metadata flag");
+			if (area_len &&
+			    area_len != seg_metalv(seg, s)->le_count) {
+				raid_seg_error_val("MetaLV size variations",
+		    				   seg_metalv(seg, s)->le_count);
+			} else
+				area_len = seg_metalv(seg, s)->le_count;
+		}
+	/* END: general checks applying to all RAIDs */
+
+	/* Specific segment type checks from here on */
+	if (seg_is_any_raid0(seg))
+		_check_raid0_seg(seg, error_count);
+	else if (seg_is_raid1(seg))
+		_check_raid1_seg(seg, error_count);
+	else if (seg_is_raid4(seg) ||
+		 seg_is_any_raid5(seg) ||
+		 seg_is_raid10(seg))
+		_check_raid45610_seg(seg, error_count);
+	else
+		raid_seg_error("bogus RAID segment type");
+}
+/* END: RAID segment property checks. */
+
+/*
  * Verify that an LV's segments are consecutive, complete and don't overlap.
  */
 int check_lv_segments(struct logical_volume *lv, int complete_vg)
@@ -143,6 +387,10 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
+
+		if (seg_is_raid(seg))
+			 _check_raid_seg(seg, &error_count);
+		
 		if (seg->le != le) {
 			log_error("LV %s invalid: segment %u should begin at "
 				  "LE %" PRIu32 " (found %" PRIu32 ").",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a365fe9..88e43e4 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -506,7 +506,9 @@ static int _read_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!seg_is_any_raid0(lp)) {
+	if (seg_is_any_raid0(lp))
+		lp->region_size = 0;
+	else {
 		/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
 		lp->min_recovery_rate = arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
 		lp->max_recovery_rate = arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;


