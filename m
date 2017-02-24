From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:00 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063200.9CD3060AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2354ea344c248ede9faa872c260d46985830c0f
Commit:        e2354ea344c248ede9faa872c260d46985830c0f
Parent:        ffe3ca26e05f9bb10f004bafe6866b189d7ac385
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 00:50:00 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces infrastructure prerequisites to be used
by raid_manip.c extensions in followup patches.

This base is needed for allocation of out-of-place
reshape space required by the MD raid personalities to
avoid writing over data in-place when reading off the
current RAID layout or number of legs and writing out
the new layout or to a different number of legs
(i.e. restripe)

Changes:
- add members reshape_len to 'struct lv_segment' to store
  out-of-place reshape length per component rimage
- add member data_copies to struct lv_segment
  to support more than 2 raid10 data copies
- make alloc_lv_segment() aware of both reshape_len and data_copies
- adjust all alloc_lv_segment() callers to the new API
- add functions to retrieve the current data offset (needed for
  out-of-place reshaping space allocation) and the devices count
  from the kernel
- make libdm deptree code aware of reshape_len
- add LV flags for disk add/remove reshaping
- support import/export of the new 'struct lv_segment' members
- enhance lv_extend/_lv_reduce to cope with reshape_len
- add seg_is_*/segtype_is_* macros related to reshaping
- add target version check for reshaping
- grow rebuilds/writemostly bitmaps to 246 bit to support kernel maximal
- enhance libdm deptree code to support data_offset (out-of-place reshaping)
  and delta_disk (legs add/remove reshaping) target arguments

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/activate/activate.c          |   60 ++++++++++++++++++-
 lib/activate/activate.h          |    2 +
 lib/activate/dev_manager.c       |   19 ++++--
 lib/format1/import-extents.c     |   10 ++--
 lib/format_pool/import_export.c  |   10 ++--
 lib/format_text/export.c         |    6 +-
 lib/format_text/flags.c          |    5 +-
 lib/format_text/import_vsn1.c    |   16 ++++-
 lib/metadata/lv.c                |    5 +-
 lib/metadata/lv_alloc.h          |    4 +-
 lib/metadata/lv_manip.c          |   76 ++++++++++++++--------
 lib/metadata/merge.c             |   22 +++---
 lib/metadata/metadata-exported.h |   15 ++++-
 lib/metadata/raid_manip.c        |   12 ++--
 lib/metadata/segtype.c           |    3 +-
 lib/metadata/segtype.h           |    7 ++
 lib/metadata/snapshot_manip.c    |    4 +-
 lib/raid/raid.c                  |  126 ++++++++++++++++++++++++++------------
 libdm/libdevmapper.h             |   20 ++++--
 libdm/libdm-common.h             |    2 +
 libdm/libdm-deptree.c            |  119 +++++++++++++++++++++++++----------
 libdm/libdm-targets.c            |   18 ++++++
 tools/lvconvert.c                |   34 ++++++++---
 23 files changed, 430 insertions(+), 165 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ea56735..a3978ad 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -272,10 +272,18 @@ int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent)
 {
 	return 0;
 }
+int lv_raid_data_offset(const struct logical_volume *lv, uint64_t *data_offset)
+{
+	return 0;
+}
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 {
 	return 0;
 }
+int lv_raid_dev_count(const struct logical_volume *lv, uint32_t *dev_cnt)
+{
+	return 0;
+}
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 {
 	return 0;
@@ -984,6 +992,30 @@ int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent)
 	return lv_mirror_percent(lv->vg->cmd, lv, 0, percent, NULL);
 }
 
+int lv_raid_data_offset(const struct logical_volume *lv, uint64_t *data_offset)
+{
+	int r;
+	struct dev_manager *dm;
+	struct dm_status_raid *status;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
+		return 0;
+
+	log_debug_activation("Checking raid data offset and dev sectors for LV %s/%s",
+			     lv->vg->name, lv->name);
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_raid_status(dm, lv, &status)))
+		stack;
+
+	*data_offset = status->data_offset;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 {
 	int r;
@@ -1013,6 +1045,32 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	return r;
 }
 
+int lv_raid_dev_count(const struct logical_volume *lv, uint32_t *dev_cnt)
+{
+	struct dev_manager *dm;
+	struct dm_status_raid *status;
+
+	*dev_cnt = 0;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
+		return 0;
+
+	log_debug_activation("Checking raid device count for LV %s/%s",
+			     lv->vg->name, lv->name);
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_raid_status(dm, lv, &status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+	*dev_cnt = status->dev_count;
+
+	dev_manager_destroy(dm);
+
+	return 1;
+}
+
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
 {
 	struct dev_manager *dm;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 85c1521..09d25c5 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -168,6 +168,8 @@ int lv_snapshot_percent(const struct logical_volume *lv, dm_percent_t *percent);
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, dm_percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, dm_percent_t *percent);
+int lv_raid_dev_count(const struct logical_volume *lv, uint32_t *dev_cnt);
+int lv_raid_data_offset(const struct logical_volume *lv, uint64_t *data_offset);
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cde026e..49d9ad3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -214,6 +214,14 @@ typedef enum {
 	STATUS, /* DM_DEVICE_STATUS ioctl */
 } info_type_t;
 
+/* Return length of segment depending on type and reshape_len */
+static uint32_t _seg_len(const struct lv_segment *seg)
+{
+	uint32_t reshape_len = seg_is_raid(seg) ? ((seg->area_count - seg->segtype->parity_devs) * seg->reshape_len) : 0;
+
+	return seg->len - reshape_len;
+}
+
 static int _info_run(const char *dlid, struct dm_info *dminfo,
 		     uint32_t *read_ahead,
 		     struct lv_seg_status *seg_status,
@@ -250,7 +258,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	if (seg_status && dminfo->exists) {
 		start = length = seg_status->seg->lv->vg->extent_size;
 		start *= seg_status->seg->le;
-		length *= seg_status->seg->len;
+		length *= _seg_len(seg_status->seg);
 
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
@@ -2214,7 +2222,7 @@ static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *d
 	struct lv_segment *seg_i;
 	struct dm_info info;
 	int segno = -1, i = 0;
-	uint64_t size = (uint64_t) seg->len * seg->lv->vg->extent_size;
+	uint64_t size = (uint64_t) _seg_len(seg) * seg->lv->vg->extent_size;
 
 	dm_list_iterate_items(seg_i, &seg->lv->segments) {
 		if (seg == seg_i) {
@@ -2500,7 +2508,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 	return seg->segtype->ops->add_target_line(dm, dm->mem, dm->cmd,
 						  &dm->target_state, seg,
 						  laopts, dnode,
-						  extent_size * seg->len,
+						  extent_size * _seg_len(seg),
 						  &dm->pvmove_mirror_count);
 }
 
@@ -2693,7 +2701,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		/* Replace target and all its used devs with error mapping */
 		log_debug_activation("Using error for pending delete %s.",
 				     display_lvname(seg->lv));
-		if (!dm_tree_node_add_error_target(dnode, (uint64_t)seg->lv->vg->extent_size * seg->len))
+		if (!dm_tree_node_add_error_target(dnode, (uint64_t)seg->lv->vg->extent_size * _seg_len(seg)))
 			return_0;
 	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
 		return_0;
@@ -3165,7 +3173,6 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		log_error(INTERNAL_ERROR "_tree_action: Action %u not supported.", action);
 		goto out;
 	}
-
 	r = 1;
 
 out:
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index 3ab3ac4..4c259c1 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -225,8 +225,8 @@ static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
 	while (le < lvm->lv->le_count) {
 		len = _area_length(lvm, le);
 
-		if (!(seg = alloc_lv_segment(segtype, lvm->lv, le, len, 0, 0,
-					     NULL, 1, len, 0, 0, 0, NULL))) {
+		if (!(seg = alloc_lv_segment(segtype, lvm->lv, le, len, 0, 0, 0,
+					     NULL, 1, len, 0, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate linear segment.");
 			return 0;
 		}
@@ -297,10 +297,10 @@ static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
 
 		if (!(seg = alloc_lv_segment(segtype, lvm->lv,
 					     lvm->stripes * first_area_le,
-					     lvm->stripes * area_len,
+					     lvm->stripes * area_len, 0,
 					     0, lvm->stripe_size, NULL,
 					     lvm->stripes,
-					     area_len, 0, 0, 0, NULL))) {
+					     area_len, 0, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate striped segment.");
 			return 0;
 		}
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 2f0f2eb..f4097a7 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -192,9 +192,9 @@ static int _add_stripe_seg(struct dm_pool *mem,
 		return_0;
 
 	if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
-				     area_len * usp->num_devs, 0,
+				     area_len * usp->num_devs, 0, 0,
 				     usp->striping, NULL, usp->num_devs,
-				     area_len, 0, 0, 0, NULL))) {
+				     area_len, 0, 0, 0, 0, NULL))) {
 		log_error("Unable to allocate striped lv_segment structure");
 		return 0;
 	}
@@ -232,8 +232,8 @@ static int _add_linear_seg(struct dm_pool *mem,
 		area_len = (usp->devs[j].blocks) / POOL_PE_SIZE;
 
 		if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
-					     area_len, 0, usp->striping,
-					     NULL, 1, area_len,
+					     area_len, 0, 0, usp->striping,
+					     NULL, 1, area_len, 0,
 					     POOL_PE_SIZE, 0, 0, NULL))) {
 			log_error("Unable to allocate linear lv_segment "
 				  "structure");
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 199c185..899ff45 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -583,8 +583,10 @@ static int _print_segment(struct formatter *f, struct volume_group *vg,
 	outf(f, "start_extent = %u", seg->le);
 	outsize(f, (uint64_t) seg->len * vg->extent_size,
 		"extent_count = %u", seg->len);
-
 	outnl(f);
+	if (seg->reshape_len)
+		outsize(f, (uint64_t) seg->reshape_len * vg->extent_size,
+			"reshape_count = %u", seg->reshape_len);
 	outf(f, "type = \"%s\"", seg->segtype->name);
 
 	if (!_out_list(f, &seg->tags, "tags"))
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 75b9054..716e632 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -61,6 +61,9 @@ static const struct flag _lv_flags[] = {
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
+	{LV_RESHAPE_DELTA_DISKS_PLUS, "RESHAPE_DELTA_DISKS_PLUS", STATUS_FLAG},
+	{LV_RESHAPE_DELTA_DISKS_MINUS, "RESHAPE_DELTA_DISKS_MINUS", STATUS_FLAG},
+	{LV_REMOVE_AFTER_RESHAPE, "REMOVE_AFTER_RESHAPE", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 00caf21..e545008 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -354,7 +354,7 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 	struct lv_segment *seg;
 	const struct dm_config_node *sn_child = sn->child;
 	const struct dm_config_value *cv;
-	uint32_t start_extent, extent_count;
+	uint32_t area_extents, start_extent, extent_count, reshape_count, data_copies;
 	struct segment_type *segtype;
 	const char *segtype_str;
 
@@ -375,6 +375,12 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 		return 0;
 	}
 
+	if (!_read_int32(sn_child, "reshape_count", &reshape_count))
+		reshape_count = 0;
+
+	if (!_read_int32(sn_child, "data_copies", &data_copies))
+		data_copies = 1;
+
 	segtype_str = SEG_TYPE_NAME_STRIPED;
 
 	if (!dm_config_get_str(sn_child, "type", &segtype_str)) {
@@ -389,9 +395,11 @@ static int _read_segment(struct logical_volume *lv, const struct dm_config_node
 	    !segtype->ops->text_import_area_count(sn_child, &area_count))
 		return_0;
 
+	area_extents = segtype->parity_devs ?
+		       raid_rimage_extents(segtype, extent_count, area_count - segtype->parity_devs, data_copies) : extent_count;
 	if (!(seg = alloc_lv_segment(segtype, lv, start_extent,
-				     extent_count, 0, 0, NULL, area_count,
-				     extent_count, 0, 0, 0, NULL))) {
+				     extent_count, reshape_count, 0, 0, NULL, area_count,
+				     area_extents, data_copies, 0, 0, 0, NULL))) {
 		log_error("Segment allocation failed");
 		return 0;
 	}
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8587902..b54e391 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1278,6 +1278,9 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
 		} else if (lv->status & LV_WRITEMOSTLY)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
+		else if (lv->status & LV_REMOVE_AFTER_RESHAPE)
+			repstr[8] = 'R';  /* sub-LV got freed from raid set by reshaping
+					     and has to be 'R'emoved */
 	} else if (lvdm->seg_status.type == SEG_STATUS_CACHE) {
 		if (lvdm->seg_status.cache->fail)
 			repstr[8] = 'F';
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index f7bc713..cf2c579 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,11 +21,13 @@
 struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
+				    uint32_t reshape_len,
 				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
 				    uint32_t area_count,
 				    uint32_t area_len,
+				    uint32_t data_copies,
 				    uint32_t chunk_size,
 				    uint32_t region_size,
 				    uint32_t extents_copied,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 78cc30e..f3cad09 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -912,11 +912,13 @@ static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t exte
 struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
+				    uint32_t reshape_len,
 				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
 				    uint32_t area_count,
 				    uint32_t area_len,
+				    uint32_t data_copies,
 				    uint32_t chunk_size,
 				    uint32_t region_size,
 				    uint32_t extents_copied,
@@ -950,10 +952,12 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	seg->lv = lv;
 	seg->le = le;
 	seg->len = len;
+	seg->reshape_len = reshape_len;
 	seg->status = status;
 	seg->stripe_size = stripe_size;
 	seg->area_count = area_count;
 	seg->area_len = area_len;
+	seg->data_copies = data_copies ? : 0; // lv_raid_data_copies(segtype, area_count);
 	seg->chunk_size = chunk_size;
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
@@ -1047,11 +1051,10 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	if (lv_is_raid_image(lv)) {
 		/* Calculate the amount of extents to reduce per rmate/rimage LV */
 		uint32_t rimage_extents;
+		struct lv_segment *seg1 = first_seg(lv);
 
-		/* FIXME: avoid extra seg_is_*() conditonals */
-		area_reduction =_round_to_stripe_boundary(lv->vg, area_reduction,
-							  (seg_is_raid1(seg) || seg_is_any_raid0(seg)) ? 0 : _raid_stripes_count(seg), 0);
-		rimage_extents = raid_rimage_extents(seg->segtype, area_reduction, seg_is_any_raid0(seg) ? 0 : _raid_stripes_count(seg),
+		/* FIXME: avoid extra seg_is_*() conditionals here */
+		rimage_extents = raid_rimage_extents(seg1->segtype, area_reduction, seg_is_any_raid0(seg) ? 0 : _raid_stripes_count(seg),
 						     seg_is_raid10(seg) ? 1 :_raid_data_copies(seg));
 		if (!rimage_extents)
 			return 0;
@@ -1258,7 +1261,7 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 	 *          the 'stripes' argument will always need to
 	 *          be given.
 	 */
-	if (!strcmp(segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
+	if (segtype_is_raid10(segtype)) {
 		if (!stripes)
 			return area_count / 2;
 		return stripes;
@@ -1278,16 +1281,17 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 {
 	uint32_t area_reduction, s;
+	uint32_t areas = (seg->area_count / (seg_is_raid10(seg) ? seg->data_copies : 1)) - seg->segtype->parity_devs;
 
 	/* Caller must ensure exact divisibility */
-	if (seg_is_striped(seg)) {
-		if (reduction % seg->area_count) {
+	if (seg_is_striped(seg) || seg_is_striped_raid(seg)) {
+		if (reduction % areas) {
 			log_error("Segment extent reduction %" PRIu32
 				  " not divisible by #stripes %" PRIu32,
 				  reduction, seg->area_count);
 			return 0;
 		}
-		area_reduction = (reduction / seg->area_count);
+		area_reduction = reduction / areas;
 	} else
 		area_reduction = reduction;
 
@@ -1296,7 +1300,11 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 			return_0;
 
 	seg->len -= reduction;
-	seg->area_len -= area_reduction;
+
+	if (seg_is_raid(seg))
+		seg->area_len = seg->len;
+	else
+		seg->area_len -= area_reduction;
 
 	return 1;
 }
@@ -1306,11 +1314,13 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
  */
 static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 {
-	struct lv_segment *seg;
+	struct lv_segment *seg = first_seg(lv);;
 	uint32_t count = extents;
 	uint32_t reduction;
 	struct logical_volume *pool_lv;
 	struct logical_volume *external_lv = NULL;
+	int is_raid10 = seg_is_any_raid10(seg) && seg->reshape_len;
+	uint32_t data_copies = seg->data_copies;
 
 	if (lv_is_merging_origin(lv)) {
 		log_debug_metadata("Dropping snapshot merge of %s to removed origin %s.",
@@ -1373,7 +1383,15 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 		count -= reduction;
 	}
 
-	lv->le_count -= extents;
+	seg = first_seg(lv);
+
+	if (is_raid10) {
+		lv->le_count -= extents * data_copies;
+		if (seg)
+			seg->len = seg->area_len = lv->le_count;
+	} else
+		lv->le_count -= extents;
+
 	lv->size = (uint64_t) lv->le_count * lv->vg->extent_size;
 
 	if (!delete)
@@ -1793,10 +1811,10 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	area_multiple = _calc_area_multiple(segtype, area_count, 0);
 	extents = aa[0].len * area_multiple;
 
-	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
+	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents, 0,
 				     status, stripe_size, NULL,
 				     area_count,
-				     aa[0].len, 0u, region_size, 0u, NULL))) {
+				     aa[0].len, 0, 0u, region_size, 0u, NULL))) {
 		log_error("Couldn't allocate new LV segment.");
 		return 0;
 	}
@@ -3234,9 +3252,9 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 		seg->area_len += extents;
 		seg->len += extents;
 	} else {
-		if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
+		if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents, 0,
 					     status, 0, NULL, 0,
-					     extents, 0, 0, 0, NULL))) {
+					     extents, 0, 0, 0, 0, NULL))) {
 			log_error("Couldn't allocate new %s segment.", segtype->name);
 			return 0;
 		}
@@ -3562,10 +3580,10 @@ static struct lv_segment *_convert_seg_to_mirror(struct lv_segment *seg,
 	}
 
 	if (!(newseg = alloc_lv_segment(get_segtype_from_string(seg->lv->vg->cmd, SEG_TYPE_NAME_MIRROR),
-					seg->lv, seg->le, seg->len,
+					seg->lv, seg->le, seg->len, 0,
 					seg->status, seg->stripe_size,
 					log_lv,
-					seg->area_count, seg->area_len,
+					seg->area_count, seg->area_len, 0,
 					seg->chunk_size, region_size,
 					seg->extents_copied, NULL))) {
 		log_error("Couldn't allocate converted LV segment.");
@@ -3667,8 +3685,8 @@ int lv_add_segmented_mirror_image(struct alloc_handle *ah,
 		}
 
 		if (!(new_seg = alloc_lv_segment(segtype, copy_lv,
-						 seg->le, seg->len, PVMOVE, 0,
-						 NULL, 1, seg->len,
+						 seg->le, seg->len, 0, PVMOVE, 0,
+						 NULL, 1, seg->len, 0,
 						 0, 0, 0, NULL)))
 			return_0;
 
@@ -3863,9 +3881,9 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 	/*
 	 * First, create our top-level segment for our top-level LV
 	 */
-	if (!(mapseg = alloc_lv_segment(segtype, lv, 0, 0, lv->status,
+	if (!(mapseg = alloc_lv_segment(segtype, lv, 0, 0, 0, lv->status,
 					stripe_size, NULL,
-					devices, 0, 0, region_size, 0, NULL))) {
+					devices, 0, 0, 0, region_size, 0, NULL))) {
 		log_error("Failed to create mapping segment for %s.",
 			  display_lvname(lv));
 		return 0;
@@ -4063,8 +4081,11 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 			lv_set_hidden(seg_metalv(seg, s));
 	}
 
-	seg->area_len += extents / area_multiple;
 	seg->len += extents;
+	if (seg_is_raid(seg))
+		seg->area_len = seg->len;
+	else
+		seg->area_len += extents / area_multiple;
 
 	if (!_setup_lv_size(lv, lv->le_count + extents))
 		return_0;
@@ -6309,7 +6330,6 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 
 	log_very_verbose("Updating logical volume %s on disk(s)%s.",
 			 display_lvname(lock_lv), origin_only ? " (origin only)": "");
-
 	if (!vg_write(vg))
 		return_0;
 
@@ -6776,8 +6796,8 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		return_NULL;
 
 	/* allocate a new linear segment */
-	if (!(mapseg = alloc_lv_segment(segtype, lv_where, 0, layer_lv->le_count,
-					status, 0, NULL, 1, layer_lv->le_count,
+	if (!(mapseg = alloc_lv_segment(segtype, lv_where, 0, layer_lv->le_count, 0,
+					status, 0, NULL, 1, layer_lv->le_count, 0,
 					0, 0, 0, NULL)))
 		return_NULL;
 
@@ -6833,8 +6853,8 @@ static int _extend_layer_lv_for_segment(struct logical_volume *layer_lv,
 
 	/* allocate a new segment */
 	if (!(mapseg = alloc_lv_segment(segtype, layer_lv, layer_lv->le_count,
-					seg->area_len, status, 0,
-					NULL, 1, seg->area_len, 0, 0, 0, seg)))
+					seg->area_len, 0, status, 0,
+					NULL, 1, seg->area_len, 0, 0, 0, 0, seg)))
 		return_0;
 
 	/* map the new segment to the original underlying are */
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 6311818..f82e1e7 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -236,7 +236,7 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	if (!seg->areas)
 		raid_seg_error("zero areas");
 
-	if (seg->extents_copied > seg->area_len)
+	if (seg->extents_copied > seg->len)
 		raid_seg_error_val("extents_copied too large", seg->extents_copied);
 
 	/* Default < 10, change once raid1 split shift and rename SubLVs works! */
@@ -475,7 +475,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	struct lv_segment *seg, *seg2;
 	uint32_t le = 0;
 	unsigned seg_count = 0, seg_found, external_lv_found = 0;
-	uint32_t area_multiplier, s;
+	uint32_t data_rimage_count, s;
 	struct seg_list *sl;
 	struct glv_list *glvl;
 	int error_count = 0;
@@ -498,13 +498,13 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			inc_error_count;
 		}
 
-		area_multiplier = segtype_is_striped(seg->segtype) ?
-					seg->area_count : 1;
-
-		if (seg->area_len * area_multiplier != seg->len) {
-			log_error("LV %s: segment %u has inconsistent "
-				  "area_len %u",
-				  lv->name, seg_count, seg->area_len);
+		data_rimage_count = seg->area_count - seg->segtype->parity_devs;
+		/* FIXME: raid varies seg->area_len? */
+		if (seg->len != seg->area_len &&
+		    seg->len != seg->area_len * data_rimage_count) {
+			log_error("LV %s: segment %u with len=%u "
+				  " has inconsistent area_len %u",
+				  lv->name, seg_count, seg->len, seg->area_len);
 			inc_error_count;
 		}
 
@@ -766,10 +766,10 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 	/* Clone the existing segment */
 	if (!(split_seg = alloc_lv_segment(seg->segtype,
-					   seg->lv, seg->le, seg->len,
+					   seg->lv, seg->le, seg->len, seg->reshape_len,
 					   seg->status, seg->stripe_size,
 					   seg->log_lv,
-					   seg->area_count, seg->area_len,
+					   seg->area_count, seg->area_len, seg->data_copies,
 					   seg->chunk_size, seg->region_size,
 					   seg->extents_copied, seg->pvmove_source_seg))) {
 		log_error("Couldn't allocate cloned LV segment.");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e4d2267..11fb247 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -137,7 +137,11 @@
 									e.g. to prohibit allocation of a RAID image
 									on a PV already holing an image of the RAID set */
 #define LOCKD_SANLOCK_LV	UINT64_C(0x0080000000000000)	/* LV - Internal use only */
-/* Next unused flag:		UINT64_C(0x0100000000000000)    */
+#define LV_RESHAPE_DELTA_DISKS_PLUS		UINT64_C(0x0100000000000000)    /* LV reshape flag delta disks plus image(s) */
+#define LV_RESHAPE_DELTA_DISKS_MINUS		UINT64_C(0x0200000000000000)    /* LV reshape flag delta disks minus image(s) */
+
+#define LV_REMOVE_AFTER_RESHAPE	UINT64_C(0x0400000000000000)	/* LV needs to be removed after a shrinking reshape */
+/* Next unused flag:		UINT64_C(0x0800000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -446,6 +450,7 @@ struct lv_segment {
 	const struct segment_type *segtype;
 	uint32_t le;
 	uint32_t len;
+	uint32_t reshape_len;   /* For RAID: user hidden additional out of place reshaping length off area_len and len */
 
 	uint64_t status;
 
@@ -454,6 +459,7 @@ struct lv_segment {
 	uint32_t writebehind;   /* For RAID (RAID1 only) */
 	uint32_t min_recovery_rate; /* For RAID */
 	uint32_t max_recovery_rate; /* For RAID */
+	uint32_t data_offset;	/* For RAID: data offset in sectors on each data component image */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
@@ -464,6 +470,7 @@ struct lv_segment {
 	struct logical_volume *cow;
 	struct dm_list origin_list;
 	uint32_t region_size;	/* For mirrors, replicators - in sectors */
+	uint32_t data_copies;	/* For RAID: number of data copies (e.g. 3 for RAID 6 */
 	uint32_t extents_copied;/* Number of extents synced for raids/mirrors */
 	struct logical_volume *log_lv;
 	struct lv_segment *pvmove_source_seg;
@@ -1205,7 +1212,8 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
-			       uint32_t new_count, struct dm_list *allocate_pvs);
+			       uint32_t new_count,
+			       struct dm_list *allocate_pvs);
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs);
 int lv_raid_split_and_track(struct logical_volume *lv,
@@ -1233,6 +1241,7 @@ uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t r
 int lv_raid_change_region_size(struct logical_volume *lv,
                                int yes, int force, uint32_t new_region_size);
 int lv_raid_in_sync(const struct logical_volume *lv);
+uint32_t lv_raid_data_copies(const struct segment_type *segtype, uint32_t area_count);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b6215a2..9ecc410 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1952,9 +1952,9 @@ static int _alloc_and_add_new_striped_segment(struct logical_volume *lv,
 
 	/* Allocate a segment with seg->area_count areas */
 	if (!(new_seg = alloc_lv_segment(striped_segtype, lv, le, area_len * seg->area_count,
-					 0,
+					 0, 0,
 					 seg->stripe_size, NULL, seg->area_count,
-					 area_len, seg->chunk_size, 0, 0, NULL)))
+					 area_len, 0, seg->chunk_size, 0, 0, NULL)))
 		return_0;
 
 	dm_list_add(new_segments, &new_seg->list);
@@ -2510,8 +2510,8 @@ static int _striped_to_raid0_move_segs_to_raid0_lvs(struct logical_volume *lv,
 			if (!(seg_new = alloc_lv_segment(segtype, dlv,
 							 le, seg_from->area_len,
 							 status,
-							 0 /* stripe_size */, NULL, 1 /* area_count */,
-							 seg_from->area_len,
+							 0, 0 /* stripe_size */, NULL, 1 /* area_count */,
+							 seg_from->area_len, 0,
 							 0 /* chunk_size */, 0 /* region_size */, 0, NULL)))
 				return_0;
 
@@ -2726,9 +2726,9 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	seg = first_seg(dm_list_item(dm_list_first(&data_lvs), struct lv_list)->lv);
 	if (!(raid0_seg = alloc_lv_segment(segtype, lv,
 					   0 /* le */, lv->le_count /* len */,
-					   0,
+					   0, 0,
 					   stripe_size, NULL /* log_lv */,
-					   area_count, area_len,
+					   area_count, area_len, 0,
 					   0 /* chunk_size */,
 					   0 /* seg->region_size */, 0u /* extents_copied */ ,
 					   NULL /* pvmove_source_seg */))) {
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index b66ab02..d0508ca 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -43,7 +43,8 @@ struct segment_type *get_segtype_from_flag(struct cmd_context *cmd, uint64_t fla
 {
 	struct segment_type *segtype;
 
-	dm_list_iterate_items(segtype, &cmd->segtypes)
+	/* Iterate backwards to provide aliases; e.g. raid5 instead of raid5_ls */
+	dm_list_iterate_back_items(segtype, &cmd->segtypes)
 		if (flag & segtype->flags)
 			return segtype;
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 9212824..bea7141 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -140,7 +140,11 @@ struct dev_manager;
 #define segtype_is_any_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10_near(segtype)	segtype_is_raid10(segtype)
+/* FIXME: once raid10_offset supported */
+#define segtype_is_raid10_offset(segtype)	0 // ((segtype)->flags & SEG_RAID10_OFFSET ? 1 : 0)
 #define segtype_is_raid_with_meta(segtype)	(segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
+#define segtype_is_striped_raid(segtype)        (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))
+#define segtype_is_reshapable_raid(segtype)     ((segtype_is_striped_raid(segtype) && !segtype_is_any_raid0(segtype)) || segtype_is_raid10_near(segtype) || segtype_is_raid10_offset(segtype))
 #define segtype_is_snapshot(segtype)	((segtype)->flags & SEG_SNAPSHOT ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
@@ -190,6 +194,8 @@ struct dev_manager;
 #define seg_is_raid10(seg)	segtype_is_raid10((seg)->segtype)
 #define seg_is_raid10_near(seg)	segtype_is_raid10_near((seg)->segtype)
 #define seg_is_raid_with_meta(seg)	segtype_is_raid_with_meta((seg)->segtype)
+#define seg_is_striped_raid(seg)	segtype_is_striped_raid((seg)->segtype)
+#define	seg_is_reshapable_raid(seg)	segtype_is_reshapable_raid((seg)->segtype)
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_snapshot(seg)	segtype_is_snapshot((seg)->segtype)
@@ -280,6 +286,7 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 #define RAID_FEATURE_RAID0			(1U << 1) /* version 1.7 */
 #define RAID_FEATURE_RESHAPING			(1U << 2) /* version 1.8 */
 #define RAID_FEATURE_RAID4			(1U << 3) /* ! version 1.8 or 1.9.0 */
+#define RAID_FEATURE_RESHAPE			(1U << 4) /* version 1.10.2 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index b5fb60c..57fbef9 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -238,8 +238,8 @@ static struct lv_segment *_alloc_snapshot_seg(struct logical_volume *lv)
 		return NULL;
 	}
 
-	if (!(seg = alloc_lv_segment(segtype, lv, 0, lv->le_count, 0, 0,
-				     NULL, 0, lv->le_count, 0, 0, 0, NULL))) {
+	if (!(seg = alloc_lv_segment(segtype, lv, 0, lv->le_count, 0, 0, 0,
+				     NULL, 0, lv->le_count, 0, 0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new snapshot segment.");
 		return NULL;
 	}
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index c679207..398e8b0 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -137,6 +137,7 @@ static int _raid_text_import(struct lv_segment *seg,
 	} raid_attr_import[] = {
 		{ "region_size",	&seg->region_size },
 		{ "stripe_size",	&seg->stripe_size },
+		{ "data_copies",	&seg->data_copies },
 		{ "writebehind",	&seg->writebehind },
 		{ "min_recovery_rate",	&seg->min_recovery_rate },
 		{ "max_recovery_rate",	&seg->max_recovery_rate },
@@ -146,6 +147,10 @@ static int _raid_text_import(struct lv_segment *seg,
 	for (i = 0; i < DM_ARRAY_SIZE(raid_attr_import); i++, aip++) {
 		if (dm_config_has_node(sn, aip->name)) {
 			if (!dm_config_get_uint32(sn, aip->name, aip->var)) {
+				if (!strcmp(aip->name, "data_copies")) {
+					*aip->var = 0;
+					continue;
+				}
 				log_error("Couldn't read '%s' for segment %s of logical volume %s.",
 					  aip->name, dm_config_parent_name(sn), seg->lv->name);
 				return 0;
@@ -165,6 +170,9 @@ static int _raid_text_import(struct lv_segment *seg,
 		return 0;
 	}
 
+	if (seg->data_copies < 2)
+		seg->data_copies = 0; // lv_raid_data_copies(seg->segtype, seg->area_count);
+
 	if (seg_is_any_raid0(seg))
 		seg->area_len /= seg->area_count;
 
@@ -183,18 +191,31 @@ static int _raid_text_export_raid0(const struct lv_segment *seg, struct formatte
 
 static int _raid_text_export_raid(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "device_count = %u", seg->area_count);
+	int raid0 = seg_is_any_raid0(seg);
+
+	if (raid0)
+		outfc(f, (seg->area_count == 1) ? "# linear" : NULL,
+		      "stripe_count = %u", seg->area_count);
+
+	else {
+		outf(f, "device_count = %u", seg->area_count);
+		if (seg_is_any_raid10(seg) && seg->data_copies > 0)
+			outf(f, "data_copies = %" PRIu32, seg->data_copies);
+		if (seg->region_size)
+			outf(f, "region_size = %" PRIu32, seg->region_size);
+	}
 
 	if (seg->stripe_size)
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
-	if (seg->region_size)
-		outf(f, "region_size = %" PRIu32, seg->region_size);
-	if (seg->writebehind)
-		outf(f, "writebehind = %" PRIu32, seg->writebehind);
-	if (seg->min_recovery_rate)
-		outf(f, "min_recovery_rate = %" PRIu32, seg->min_recovery_rate);
-	if (seg->max_recovery_rate)
-		outf(f, "max_recovery_rate = %" PRIu32, seg->max_recovery_rate);
+
+	if (!raid0) {
+		if (seg_is_raid1(seg) && seg->writebehind)
+			outf(f, "writebehind = %" PRIu32, seg->writebehind);
+		if (seg->min_recovery_rate)
+			outf(f, "min_recovery_rate = %" PRIu32, seg->min_recovery_rate);
+		if (seg->max_recovery_rate)
+			outf(f, "max_recovery_rate = %" PRIu32, seg->max_recovery_rate);
+	}
 
 	return out_areas(f, seg, "raid");
 }
@@ -216,14 +237,16 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
+	int delta_disks = 0, delta_disks_minus = 0, delta_disks_plus = 0, data_offset = 0;
 	uint32_t s;
 	uint64_t flags = 0;
-	uint64_t rebuilds = 0;
-	uint64_t writemostly = 0;
+	uint64_t rebuilds[RAID_BITMAP_SIZE];
+	uint64_t writemostly[RAID_BITMAP_SIZE];
 	struct dm_tree_node_raid_params params;
-	int raid0 = seg_is_any_raid0(seg);
 
 	memset(&params, 0, sizeof(params));
+	memset(&rebuilds, 0, sizeof(rebuilds));
+	memset(&writemostly, 0, sizeof(writemostly));
 
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "
@@ -232,63 +255,84 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	}
 
 	/*
-	 * 64 device restriction imposed by kernel as well.  It is
-	 * not strictly a userspace limitation.
+	 * 253 device restriction imposed by kernel due to MD and dm-raid bitfield limitation in superblock.
+	 * It is not strictly a userspace limitation.
 	 */
-	if (seg->area_count > 64) {
-		log_error("Unable to handle more than 64 devices in a "
-			  "single RAID array");
+	if (seg->area_count > DEFAULT_RAID_MAX_IMAGES) {
+		log_error("Unable to handle more than %u devices in a "
+			  "single RAID array", DEFAULT_RAID_MAX_IMAGES);
 		return 0;
 	}
 
-	if (!raid0) {
+	if (!seg_is_any_raid0(seg)) {
 		if (!seg->region_size) {
-			log_error("Missing region size for mirror segment.");
+			log_error("Missing region size for raid segment in %s.",
+				  seg_lv(seg, 0)->name);
 			return 0;
 		}
 
-		for (s = 0; s < seg->area_count; s++)
-			if (seg_lv(seg, s)->status & LV_REBUILD)
-				rebuilds |= 1ULL << s;
+		for (s = 0; s < seg->area_count; s++) {
+			uint64_t status = seg_lv(seg, s)->status;
+
+			if (status & LV_REBUILD)
+				rebuilds[s/64] |= 1ULL << (s%64);
+
+			if (status & LV_RESHAPE_DELTA_DISKS_PLUS) {
+				delta_disks++;
+				delta_disks_plus++;
+			} else if (status & LV_RESHAPE_DELTA_DISKS_MINUS) {
+				delta_disks--;
+				delta_disks_minus++;
+			}
+
+			if (delta_disks_plus && delta_disks_minus) {
+				log_error(INTERNAL_ERROR "Invalid request for delta disks minus and delta disks plus!");
+				return 0;
+			}
+
+			if (status & LV_WRITEMOSTLY)
+				writemostly[s/64] |= 1ULL << (s%64);
+		}
 
-		for (s = 0; s < seg->area_count; s++)
-			if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
-				writemostly |= 1ULL << s;
+		data_offset = seg->data_offset;
 
 		if (mirror_in_sync())
 			flags = DM_NOSYNC;
 	}
 
 	params.raid_type = lvseg_name(seg);
-	params.stripe_size = seg->stripe_size;
-	params.flags = flags;
 
-	if (raid0) {
-		params.mirrors = 1;
-		params.stripes = seg->area_count;
-	} else if (seg->segtype->parity_devs) {
+	if (seg->segtype->parity_devs) {
 		/* RAID 4/5/6 */
 		params.mirrors = 1;
 		params.stripes = seg->area_count - seg->segtype->parity_devs;
-	} else if (seg_is_raid10(seg)) {
-		/* RAID 10 only supports 2 mirrors now */
-		params.mirrors = 2;
-		params.stripes = seg->area_count / 2;
+	} else if (seg_is_any_raid0(seg)) {
+		params.mirrors = 1;
+		params.stripes = seg->area_count;
+	} else if (seg_is_any_raid10(seg)) {
+		params.data_copies = seg->data_copies;
+		params.stripes = seg->area_count;
 	} else {
 		/* RAID 1 */
-		params.mirrors = seg->area_count;
+		params.mirrors = seg->data_copies;
 		params.stripes = 1;
 		params.writebehind = seg->writebehind;
+		memcpy(params.writemostly, writemostly, sizeof(params.writemostly));
 	}
 
-	if (!raid0) {
+	/* RAID 0 doesn't have a bitmap, thus no region_size, rebuilds etc. */
+	if (!seg_is_any_raid0(seg)) {
 		params.region_size = seg->region_size;
-		params.rebuilds = rebuilds;
-		params.writemostly = writemostly;
+		memcpy(params.rebuilds, rebuilds, sizeof(params.rebuilds));
 		params.min_recovery_rate = seg->min_recovery_rate;
 		params.max_recovery_rate = seg->max_recovery_rate;
+		params.delta_disks = delta_disks;
+		params.data_offset = data_offset;
 	}
 
+	params.stripe_size = seg->stripe_size;
+	params.flags = flags;
+
 	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
 		return_0;
 
@@ -450,6 +494,10 @@ static int _raid_target_present(struct cmd_context *cmd,
 		else
 			log_very_verbose("Target raid does not support %s.",
 					 SEG_TYPE_NAME_RAID4);
+
+		if (maj > 1 ||
+		    (maj == 1 && (min > 10 || (min == 10 && patchlevel >= 2))))
+			_raid_attrs |= RAID_FEATURE_RESHAPE;
 	}
 
 	if (attributes)
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 9a10252..7fccac5 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -331,6 +331,7 @@ struct dm_status_raid {
 	char *dev_health;
 	/* idle, frozen, resync, recover, check, repair */
 	char *sync_action;
+	uint64_t data_offset; /* RAID out-of-place reshaping */
 };
 
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
@@ -1719,7 +1720,7 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 const char *raid_type,
 				 uint32_t region_size,
 				 uint32_t stripe_size,
-				 uint64_t rebuilds,
+				 uint64_t *rebuilds,
 				 uint64_t flags);
 
 /*
@@ -1738,6 +1739,8 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
  */
 #define DM_CACHE_METADATA_MAX_SECTORS DM_THIN_METADATA_MAX_SECTORS
 
+#define	RAID_BITMAP_SIZE 4
+
 struct dm_tree_node_raid_params {
 	const char *raid_type;
 
@@ -1746,18 +1749,23 @@ struct dm_tree_node_raid_params {
 	uint32_t region_size;
 	uint32_t stripe_size;
 
+	int delta_disks; /* +/- number of disks to add/remove (reshaping) */
+	int data_offset; /* data offset to set (out-of-place reshaping) */
+
 	/*
 	 * 'rebuilds' and 'writemostly' are bitfields that signify
 	 * which devices in the array are to be rebuilt or marked
-	 * writemostly.  By choosing a 'uint64_t', we limit ourself
-	 * to RAID arrays with 64 devices.
+	 * writemostly.  The kernel supports up to 253 legs.
+	 * We limit ourselvs by choosing a lower value
+	 * for DEFAULT_RAID_MAX_IMAGES.
 	 */
-	uint64_t rebuilds;
-	uint64_t writemostly;
-	uint32_t writebehind;       /* I/Os (kernel default COUNTER_MAX / 2) */
+	uint64_t rebuilds[RAID_BITMAP_SIZE];
+	uint64_t writemostly[RAID_BITMAP_SIZE];
+	uint32_t writebehind;	    /* I/Os (kernel default COUNTER_MAX / 2) */
 	uint32_t sync_daemon_sleep; /* ms (kernel default = 5sec) */
 	uint32_t max_recovery_rate; /* kB/sec/disk */
 	uint32_t min_recovery_rate; /* kB/sec/disk */
+	uint32_t data_copies;	    /* RAID # of data copies */
 	uint32_t stripe_cache;      /* sectors */
 
 	uint64_t flags;             /* [no]sync */
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index 4dc1870..a064db8 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -23,6 +23,8 @@
 #define DEV_NAME(dmt) (dmt->mangled_dev_name ? : dmt->dev_name)
 #define DEV_UUID(DMT) (dmt->mangled_uuid ? : dmt->uuid)
 
+#define RAID_BITMAP_SIZE	4
+
 int mangle_string(const char *str, const char *str_name, size_t len,
 		  char *buf, size_t buf_len, dm_string_mangling_t mode);
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d658bf9..a26cfcc 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -205,11 +205,14 @@ struct load_segment {
 	struct dm_tree_node *replicator;/* Replicator-dev */
 	uint64_t rdevice_index;		/* Replicator-dev */
 
-	uint64_t rebuilds;		/* raid */
-	uint64_t writemostly;		/* raid */
+	int delta_disks;		/* raid reshape number of disks */
+	int data_offset;		/* raid reshape data offset on disk to set */
+	uint64_t rebuilds[RAID_BITMAP_SIZE];	/* raid */
+	uint64_t writemostly[RAID_BITMAP_SIZE];	/* raid */
 	uint32_t writebehind;		/* raid */
 	uint32_t max_recovery_rate;	/* raid kB/sec/disk */
 	uint32_t min_recovery_rate;	/* raid kB/sec/disk */
+	uint32_t data_copies;		/* raid10 data_copies */
 
 	struct dm_tree_node *metadata;	/* Thin_pool + Cache */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
@@ -2353,16 +2356,21 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	return 1;
 }
 
-/* Is parameter non-zero? */
-#define PARAM_IS_SET(p) ((p) ? 1 : 0)
+static int _2_if_value(unsigned p)
+{
+	return p ? 2 : 0;
+}
 
-/* Return number of bits assuming 4 * 64 bit size */
-static int _get_params_count(uint64_t bits)
+/* Return number of bits passed in @bits assuming 2 * 64 bit size */
+static int _get_params_count(uint64_t *bits)
 {
 	int r = 0;
+	int i = RAID_BITMAP_SIZE;
 
-	r += 2 * hweight32(bits & 0xFFFFFFFF);
-	r += 2 * hweight32(bits >> 32);
+	while (i--) {
+		r += 2 * hweight32(bits[i] & 0xFFFFFFFF);
+		r += 2 * hweight32(bits[i] >> 32);
+	}
 
 	return r;
 }
@@ -2373,32 +2381,60 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 				   size_t paramsize)
 {
 	uint32_t i;
+	uint32_t area_count = seg->area_count / 2;
 	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
 	int pos = 0;
-	unsigned type = seg->type;
+	unsigned type;
+
+	if (seg->area_count % 2)
+		return 0;
 
 	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
 		param_count++;
 
-	param_count += 2 * (PARAM_IS_SET(seg->region_size) +
-			    PARAM_IS_SET(seg->writebehind) +
-			    PARAM_IS_SET(seg->min_recovery_rate) +
-			    PARAM_IS_SET(seg->max_recovery_rate));
+	param_count += _2_if_value(seg->data_offset) +
+		       _2_if_value(seg->delta_disks) +
+		       _2_if_value(seg->region_size) +
+		       _2_if_value(seg->writebehind) +
+		       _2_if_value(seg->min_recovery_rate) +
+		       _2_if_value(seg->max_recovery_rate) +
+		       _2_if_value(seg->data_copies > 1);
 
-	/* rebuilds and writemostly are 64 bits */
+	/* rebuilds and writemostly are BITMAP_SIZE * 64 bits */
 	param_count += _get_params_count(seg->rebuilds);
 	param_count += _get_params_count(seg->writemostly);
 
-	if ((type == SEG_RAID1) && seg->stripe_size)
-		log_error("WARNING: Ignoring RAID1 stripe size");
+	if ((seg->type == SEG_RAID1) && seg->stripe_size)
+		log_info("WARNING: Ignoring RAID1 stripe size");
 
 	/* Kernel only expects "raid0", not "raid0_meta" */
+	type = seg->type;
 	if (type == SEG_RAID0_META)
 		type = SEG_RAID0;
+#if 0
+	/* Kernel only expects "raid10", not "raid10_{far,offset}" */
+	else if (type == SEG_RAID10_FAR ||
+		 type == SEG_RAID10_OFFSET) {
+		param_count += 2;
+		type = SEG_RAID10_NEAR;
+	}
+#endif
 
-	EMIT_PARAMS(pos, "%s %d %u", _dm_segtypes[type].target,
+	EMIT_PARAMS(pos, "%s %d %u",
+		    // type == SEG_RAID10_NEAR ? "raid10" : _dm_segtypes[type].target,
+		    type == SEG_RAID10 ? "raid10" : _dm_segtypes[type].target,
 		    param_count, seg->stripe_size);
 
+#if 0
+	if (seg->type == SEG_RAID10_FAR)
+		EMIT_PARAMS(pos, " raid10_format far");
+	else if (seg->type == SEG_RAID10_OFFSET)
+		EMIT_PARAMS(pos, " raid10_format offset");
+#endif
+
+	if (seg->data_copies > 1 && type == SEG_RAID10)
+		EMIT_PARAMS(pos, " raid10_copies %u", seg->data_copies);
+
 	if (seg->flags & DM_NOSYNC)
 		EMIT_PARAMS(pos, " nosync");
 	else if (seg->flags & DM_FORCESYNC)
@@ -2407,27 +2443,38 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	if (seg->region_size)
 		EMIT_PARAMS(pos, " region_size %u", seg->region_size);
 
-	for (i = 0; i < (seg->area_count / 2); i++)
-		if (seg->rebuilds & (1ULL << i))
-			EMIT_PARAMS(pos, " rebuild %u", i);
+	/* If seg-data_offset == 1, kernel needs a zero offset to adjust to it */
+	if (seg->data_offset)
+		EMIT_PARAMS(pos, " data_offset %d", seg->data_offset == 1 ? 0 : seg->data_offset);
 
-	if (seg->min_recovery_rate)
-		EMIT_PARAMS(pos, " min_recovery_rate %u",
-			    seg->min_recovery_rate);
+	if (seg->delta_disks)
+		EMIT_PARAMS(pos, " delta_disks %d", seg->delta_disks);
 
-	if (seg->max_recovery_rate)
-		EMIT_PARAMS(pos, " max_recovery_rate %u",
-			    seg->max_recovery_rate);
+	for (i = 0; i < area_count; i++)
+		if (seg->rebuilds[i/64] & (1ULL << (i%64)))
+			EMIT_PARAMS(pos, " rebuild %u", i);
 
-	for (i = 0; i < (seg->area_count / 2); i++)
-		if (seg->writemostly & (1ULL << i))
+	for (i = 0; i < area_count; i++)
+		if (seg->writemostly[i/64] & (1ULL << (i%64)))
 			EMIT_PARAMS(pos, " write_mostly %u", i);
 
 	if (seg->writebehind)
 		EMIT_PARAMS(pos, " max_write_behind %u", seg->writebehind);
 
+	/*
+	 * Has to be before "min_recovery_rate" or the kernels
+	 * check will fail when both set and min > previous max
+	 */
+	if (seg->max_recovery_rate)
+		EMIT_PARAMS(pos, " max_recovery_rate %u",
+			    seg->max_recovery_rate);
+
+	if (seg->min_recovery_rate)
+		EMIT_PARAMS(pos, " min_recovery_rate %u",
+			    seg->min_recovery_rate);
+
 	/* Print number of metadata/data device pairs */
-	EMIT_PARAMS(pos, " %u", seg->area_count/2);
+	EMIT_PARAMS(pos, " %u", area_count);
 
 	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
 		return_0;
@@ -3267,11 +3314,14 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 	seg->region_size = p->region_size;
 	seg->stripe_size = p->stripe_size;
 	seg->area_count = 0;
-	seg->rebuilds = p->rebuilds;
-	seg->writemostly = p->writemostly;
+	seg->delta_disks = p->delta_disks;
+	seg->data_offset = p->data_offset;
+	memcpy(seg->rebuilds, p->rebuilds, sizeof(seg->rebuilds));
+	memcpy(seg->writemostly, p->writemostly, sizeof(seg->writemostly));
 	seg->writebehind = p->writebehind;
 	seg->min_recovery_rate = p->min_recovery_rate;
 	seg->max_recovery_rate = p->max_recovery_rate;
+	seg->data_copies = p->data_copies;
 	seg->flags = p->flags;
 
 	return 1;
@@ -3282,17 +3332,18 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 const char *raid_type,
 				 uint32_t region_size,
 				 uint32_t stripe_size,
-				 uint64_t rebuilds,
+				 uint64_t *rebuilds,
 				 uint64_t flags)
 {
 	struct dm_tree_node_raid_params params = {
 		.raid_type = raid_type,
 		.region_size = region_size,
 		.stripe_size = stripe_size,
-		.rebuilds = rebuilds,
 		.flags = flags
 	};
 
+	memcpy(params.rebuilds, rebuilds, sizeof(params.rebuilds));
+
 	return dm_tree_node_add_raid_target_with_params(node, size, &params);
 }
 
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index c94e057..6b83372 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -89,6 +89,8 @@ static unsigned _count_fields(const char *p)
  *   <raid_type> <#devs> <health_str> <sync_ratio>
  * Versions 1.5.0+  (6 fields):
  *   <raid_type> <#devs> <health_str> <sync_ratio> <sync_action> <mismatch_cnt>
+ * Versions 1.9.0+  (7 fields):
+ *   <raid_type> <#devs> <health_str> <sync_ratio> <sync_action> <mismatch_cnt> <data_offset>
  */
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status)
@@ -147,6 +149,22 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 	if (sscanf(p, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2)
 		goto_bad;
 
+	if (num_fields < 7)
+		goto out;
+
+	/*
+	 * All pre-1.9.0 version parameters are read.  Now we check
+	 * for additional 1.9.0+ parameters (i.e. nr_fields@least 7).
+	 *
+	 * Note that data_offset will be 0 if the
+	 * kernel returns a pre-1.9.0 status.
+	 */
+	msg_fields = "<data_offset>";
+	if (!(p = _skip_fields(params, 6))) /* skip pre-1.9.0 params */
+		goto bad;
+	if (sscanf(p, "%" PRIu64, &s->data_offset) != 1)
+		goto bad;
+
 out:
 	*status = s;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b9e0665..abec04a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1228,6 +1228,9 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
 				    const struct segment_type *to_segtype)
 {
+	if (!from_segtype)
+		return 1;
+
 	if (from_segtype == to_segtype)
 		return 1;
 
@@ -1356,7 +1359,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
 				return 0;
 			}
-			if (!lv_raid_change_image_count(lv, image_count, lp->pvh))
+			if (!lv_raid_change_image_count(lv, image_count, /* lp->region_size, */ lp->pvh))
 				return_0;
 
 			log_print_unless_silent("Logical volume %s successfully converted.",
@@ -1365,10 +1368,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!*lp->type_str || seg->segtype == lp->segtype) {
+	}
+#if 0
+	} else if ((!*lp->type_str || seg->segtype == lp->segtype) && !lp->stripe_size_supplied) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}
+#endif
 
 	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
 	    (lp->type_str && lp->type_str[0])) {
@@ -1390,10 +1396,14 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
+		/* FIXME This needs changing globally. */
 		if (!arg_is_set(cmd, stripes_long_ARG))
 			lp->stripes = 0;
+		if (!arg_is_set(cmd, type_ARG))
+		       lp->segtype = NULL;
 
-		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
+		if (!lv_raid_convert(lv, lp->segtype,
+				     lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
 				     lp->region_size, lp->pvh))
 			return_0;
 
@@ -1410,12 +1420,16 @@ try_new_takeover_or_reshape:
 	/* FIXME This needs changing globally. */
 	if (!arg_is_set(cmd, stripes_long_ARG))
 		lp->stripes = 0;
+	if (!arg_is_set(cmd, type_ARG))
+	       lp->segtype = NULL;
 
 	/* Only let raid4 through for now. */
-	if (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
-	    ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
-	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp)))) {
-		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
+	if (!lp->segtype ||
+	    (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
+	     ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
+	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp))))) {
+		if (!lv_raid_convert(lv, lp->segtype,
+				     lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
 				     lp->region_size, lp->pvh))
 			return_0;
 
@@ -1700,6 +1714,8 @@ static int _lvconvert_raid_types(struct cmd_context *cmd, struct logical_volume
 	/* FIXME This is incomplete */
 	if (_mirror_or_raid_type_requested(cmd, lp->type_str) || _raid0_type_requested(lp->type_str) ||
 	    _striped_type_requested(lp->type_str) || lp->mirrorlog || lp->corelog) {
+		if (!arg_is_set(cmd, type_ARG))
+			lp->segtype = first_seg(lv)->segtype;
 		/* FIXME Handle +/- adjustments too? */
 		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
 			goto_out;
@@ -2990,9 +3006,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	}
 
 	/* Allocate a new pool segment */
-	if (!(seg = alloc_lv_segment(pool_segtype, pool_lv, 0, data_lv->le_count,
+	if (!(seg = alloc_lv_segment(pool_segtype, pool_lv, 0, data_lv->le_count, 0,
 				     pool_lv->status, 0, NULL, 1,
-				     data_lv->le_count, 0, 0, 0, NULL)))
+				     data_lv->le_count, 0, 0, 0, 0, NULL)))
 		return_0;
 
 	/* Add the new segment to the layer LV */


