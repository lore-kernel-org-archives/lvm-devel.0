From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Sep 2011 16:41:23 -0000
Subject: LVM2 lib/format_text/flags.c lib/metadata/lv_m ...
Message-ID: <20110908164123.17665.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-08 16:41:20

Modified files:
	lib/format_text: flags.c 
	lib/metadata   : lv_manip.c merge.c metadata-exported.h 
	                 metadata.h thin_manip.c 
	lib/thin       : thin.c 
	tools          : lvcreate.c 

Log message:
	lvcreate/remove thin_pool and thin volumes (--driverloaded n only)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.282&r2=1.283
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.208&r2=1.209
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.254&r2=1.255
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.239&r2=1.240

--- LVM2/lib/format_text/flags.c	2011/08/30 14:55:17	1.47
+++ LVM2/lib/format_text/flags.c	2011/09/08 16:41:18	1.48
@@ -71,6 +71,10 @@
 	{VIRTUAL_ORIGIN, NULL, 0},
 	{REPLICATOR, NULL, 0},
 	{REPLICATOR_LOG, NULL, 0},
+	{THIN_VOLUME, NULL, 0},
+	{THIN_POOL, NULL, 0},
+	{THIN_POOL_DATA, NULL, 0},
+	{THIN_POOL_METADATA, NULL, 0},
 	{0, NULL, 0}
 };
 
--- LVM2/lib/metadata/lv_manip.c	2011/09/06 22:43:56	1.282
+++ LVM2/lib/metadata/lv_manip.c	2011/09/08 16:41:18	1.283
@@ -255,13 +255,8 @@
 	if (thin_pool_lv && !attach_pool_lv(seg, thin_pool_lv))
 		return_NULL;
 
-	if (log_lv) {
-		if (thin_pool_lv) {
-			if (!attach_pool_metadata_lv(seg, log_lv))
-				return_NULL;
-		} else if (!attach_mirror_log(seg, log_lv))
-			return_NULL;
-	}
+	if (log_lv && !attach_mirror_log(seg, log_lv))
+		return_NULL;
 
 	return seg;
 }
@@ -310,6 +305,11 @@
 		return;
 	}
 
+	if (seg_lv(seg, s)->status & THIN_POOL_DATA) {
+		lv_reduce(seg_lv(seg, s), area_reduction);
+		return;
+	}
+
 	if (seg_lv(seg, s)->status & RAID_IMAGE) {
 		/*
 		 * FIXME: Use lv_reduce not lv_remove
@@ -510,6 +510,12 @@
 			/* FIXME Check this is safe */
 			if (seg->log_lv && !lv_remove(seg->log_lv))
 				return_0;
+			if (seg->pool_metadata_lv && !lv_remove(seg->pool_metadata_lv))
+				return_0;
+
+			if (seg->pool_lv && !detach_pool_lv(seg))
+				return_0;
+
 			dm_list_del(&seg->list);
 			reduction = seg->len;
 		} else
@@ -770,7 +776,14 @@
 			 * RAID device's metadata_area
 			 */
 			ah->new_extents += (ah->log_len * ah->area_multiple);
+		} else {
+			ah->log_area_count = 0;
+			ah->log_len = 0;
 		}
+	} else if (segtype_is_thin_pool(segtype)) {
+		ah->log_area_count = metadata_area_count;
+// FIXME Calculate thin metadata area size
+		ah->log_len = 1;
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -2314,7 +2327,7 @@
 {
 	struct logical_volume *sub_lv;
 	uint32_t i;
-	uint64_t status = 0;
+	uint64_t sub_lv_status = 0;
 	const char *layer_name;
 	size_t len = strlen(lv->name) + 32;
 	char img_name[len];
@@ -2328,15 +2341,14 @@
 
 	if (segtype_is_raid(segtype)) {
 		lv->status |= RAID;
-		status = RAID_IMAGE;
+		sub_lv_status = RAID_IMAGE;
 		layer_name = "rimage";
 	} else if (segtype_is_mirrored(segtype)) {
 		lv->status |= MIRRORED;
-		status = MIRROR_IMAGE;
+		sub_lv_status = MIRROR_IMAGE;
 		layer_name = "mimage";
 	} else if (segtype_is_thin_pool(segtype)) {
-		// lv->status |= THIN_POOL;
-		// status = THIN_IMAGE;
+		lv->status |= THIN_POOL;
 		layer_name = "tpool";
 	} else
 		return_0;
@@ -2356,37 +2368,52 @@
 	 */
 	for (i = 0; i < devices; i++) {
 		/* Data LVs */
-		if (dm_snprintf(img_name, len, "%s_%s_%u",
-				lv->name, layer_name, i) < 0)
-			return_0;
-
-		sub_lv = lv_create_empty(img_name, NULL,
-					 LVM_READ | LVM_WRITE | status,
-					 lv->alloc, lv->vg);
+		if (devices > 1) {
+			if (dm_snprintf(img_name, len, "%s_%s_%u",
+					lv->name, layer_name, i) < 0)
+				return_0;
+		} else {
+			if (dm_snprintf(img_name, len, "%s_%s",
+					lv->name, layer_name) < 0)
+				return_0;
+		}
 
-		if (!sub_lv)
+		/* FIXME Should use ALLOC_INHERIT here and inherit from parent LV */
+		if (!(sub_lv = lv_create_empty(img_name, NULL,
+					 LVM_READ | LVM_WRITE,
+					 lv->alloc, lv->vg)))
 			return_0;
-		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))
+
+		if (segtype_is_thin_pool(segtype)) {
+			if (!attach_pool_data_lv(mapseg, sub_lv))
+				return_0;
+		} else if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, sub_lv_status))
 			return_0;
-		if (!segtype_is_raid(segtype))
+
+		/* Metadata LVs for raid or thin pool */
+		if (segtype_is_raid(segtype)) {
+			if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
+				return_0;
+		} else if (segtype_is_thin_pool(segtype)) {
+			if (dm_snprintf(img_name, len, "%s_tmeta", lv->name) < 0)
+				return_0;
+		} else
 			continue;
 
-		/* RAID meta LVs */
-		if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
+		/* FIXME Should use ALLOC_INHERIT here and inherit from parent LV */
+		if (!(sub_lv = lv_create_empty(img_name, NULL,
+					       LVM_READ | LVM_WRITE,
+					       lv->alloc, lv->vg)))
 			return_0;
 
-		sub_lv = lv_create_empty(img_name, NULL,
-					 LVM_READ | LVM_WRITE | RAID_META,
-					 lv->alloc, lv->vg);
-		if (!sub_lv)
-			return_0;
-		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
-			return_0;
+		if (segtype_is_thin_pool(segtype)) {
+			if (!attach_pool_metadata_lv(mapseg, sub_lv))
+				return_0;
+		} else if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
+				return_0;
 	}
 	dm_list_add(&lv->segments, &mapseg->list);
 
-// FIXME If thin pool, create one "log_lv" as tmeta here lv->metadata_lv
-
 	return 1;
 }
 
@@ -2509,9 +2536,22 @@
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	int r = 1;
-	int raid_logs = 0;
+	int log_count = 0;
 	struct alloc_handle *ah;
-	uint32_t dev_count = mirrors * stripes + segtype->parity_devs;
+	uint32_t sub_lv_count;
+
+	/*
+	 * For RAID, all the devices are AREA_LV.
+	 * However, for 'mirror on stripe' using non-RAID targets,
+	 * the mirror legs are AREA_LV while the stripes underneath
+	 * are AREA_PV.  
+	 */
+	if (segtype_is_raid(segtype))
+		sub_lv_count = mirrors * stripes + segtype->parity_devs;
+	else if (segtype_is_thin_pool(segtype))
+		sub_lv_count = 1;
+	else
+		sub_lv_count = mirrors;
 
 	log_very_verbose("Extending segment type, %s", segtype->name);
 
@@ -2519,12 +2559,14 @@
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
 	if (segtype_is_raid(segtype) && !lv->le_count)
-		raid_logs = mirrors * stripes;
+		log_count = mirrors * stripes;
 
-// For thin pool, ensure space for "log_lv" ->metadata_lv is allocated simultaneously here
+	if (segtype_is_thin_pool(segtype))
+		log_count = 1;
 
+	/* Thin pool allocation treats its metadata device like a mirror log. */
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
-				    raid_logs, region_size, extents,
+				    log_count, region_size, extents,
 				    allocatable_pvs, alloc, NULL)))
 		return_0;
 
@@ -2532,27 +2574,20 @@
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, 0u, 0);
 	else {
-		/*
-		 * For RAID, all the devices are AREA_LV.
-		 * However, for 'mirror on stripe' using non-RAID targets,
-		 * the mirror legs are AREA_LV while the stripes underneath
-		 * are AREA_PV.  So if this is not RAID, reset dev_count to
-		 * just 'mirrors' - the necessary sub_lv count.
-		 */
-		if (!segtype_is_raid(segtype))
-			dev_count = mirrors;
-
 		if (!lv->le_count &&
 		    !_lv_insert_empty_sublvs(lv, segtype, stripe_size,
-					     region_size, dev_count)) {
+					     region_size, sub_lv_count)) {
 			log_error("Failed to insert layer for %s", lv->name);
 			alloc_destroy(ah);
 			return 0;
 		}
 
-// For thin_pool, populate tmeta here too
 		r = _lv_extend_layered_lv(ah, lv, extents, 0,
 					  stripes, stripe_size);
+
+		if (r && segtype_is_thin_pool(segtype))
+			r = lv_add_segment(ah, ah->area_count, 1, first_seg(lv)->pool_metadata_lv,
+					   get_segtype_from_string(lv->vg->cmd, "striped"), 0, 0, 0);
 	}
 	alloc_destroy(ah);
 	return r;
@@ -3872,6 +3907,7 @@
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
+	/* Does LV need to be zeroed?  Thin handles this as a per-pool in-kernel setting. */
 	if (lp->zero && !segtype_is_thin(lp->segtype) && !activation()) {
 		log_error("Can't wipe start of new LV without using "
 			  "device-mapper kernel driver");
@@ -3945,7 +3981,7 @@
 		}
 	}
 
-	if (!lp->thin && !lp->extents) {
+	if (!seg_is_thin_volume(lp) && !lp->extents) {
 		log_error("Unable to create new logical volume with no extents");
 		return NULL;
 	}
@@ -3975,7 +4011,8 @@
 		log_error("Can't create %s without using "
 			  "device-mapper kernel driver.",
 			  segtype_is_raid(lp->segtype) ? lp->segtype->name :
-			  "mirror");
+			  segtype_is_mirrored(lp->segtype) ?  "mirror" :
+			  "thin volume");
 		return NULL;
 	}
 
@@ -4073,7 +4110,7 @@
 		   (lp->activate == CHANGE_AE && !activate_lv_excl(cmd, lv)) ||
 		   (lp->activate == CHANGE_ALY && !activate_lv_local(cmd, lv))) {
 		log_error("Failed to activate new LV.");
-		if (lp->zero)
+		if (lp->zero && !seg_is_thin(lp))
 			goto deactivate_and_revert_new_lv;
 		return NULL;
 	}
--- LVM2/lib/metadata/merge.c	2011/09/06 22:43:57	1.47
+++ LVM2/lib/metadata/merge.c	2011/09/08 16:41:18	1.48
@@ -75,6 +75,40 @@
 	struct replicator_site *rsite;
 	struct replicator_device *rdev;
 
+	/* Check LV flags match first segment type */
+	if (complete_vg) {
+		if (lv_is_thin_volume(lv) &&
+		    (!(seg2 = first_seg(lv)) || !seg_is_thin_volume(seg2))) {
+			log_error("LV %s is thin volume without first thin volume segment",
+				  lv->name);
+			inc_error_count;
+		}
+
+		if (lv_is_thin_pool(lv) &&
+		    (!(seg2 = first_seg(lv)) || !seg_is_thin_pool(seg2))) {
+			log_error("LV %s is thin pool without first thin pool segment",
+				  lv->name);
+			inc_error_count;
+		}
+
+		if (lv_is_thin_pool_data(lv) &&
+		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
+		     seg2->area_count != 1 || seg_type(seg2, 0) != AREA_LV ||
+		     seg_lv(seg2, 0) != lv)) {
+			log_error("LV %s: segment 1 pool data LV does not point back to same LV",
+				  lv->name);
+			inc_error_count;
+		}
+
+		if (lv_is_thin_pool_metadata(lv) &&
+		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
+		     seg2->pool_metadata_lv != lv)) {
+			log_error("LV %s: segment 1 pool metadata LV does not point back to same LV",
+				  lv->name);
+			inc_error_count;
+		}
+	}
+
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
 		if (seg->le != le) {
@@ -132,6 +166,80 @@
 			}
 		}
 
+		/* Check the various thin segment types */
+		if (complete_vg) {
+			if (seg_is_thin_pool(seg)) {
+				if (!lv_is_thin_pool(lv)) {
+					log_error("LV %s is missing thin pool flag for segment %u",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+
+				if (lv_is_thin_volume(lv)) {
+					log_error("LV %s is a thin volume that must not contain thin pool segment %u",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+
+				if (seg->area_count != 1 || seg_type(seg, 0) != AREA_LV) {
+					log_error("LV %s: thin pool segment %u is missing a pool data LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				} else if (!(seg2 = first_seg(seg_lv(seg, 0))) || find_pool_seg(seg2) != seg) {
+					log_error("LV %s: thin pool segment %u data LV does not refer back to pool LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+
+				if (!seg->pool_metadata_lv) {
+					log_error("LV %s: thin pool segment %u is missing a pool metadata LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				} else if (!(seg2 = first_seg(seg->pool_metadata_lv)) ||
+					   find_pool_seg(seg2) != seg) {
+					log_error("LV %s: thin pool segment %u metadata LV does not refer back to pool LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+			} else {
+				if (seg->pool_metadata_lv) {	
+					log_error("LV %s: segment %u must not have thin pool metadata LV set",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+			}
+
+			if (seg_is_thin_volume(seg)) {
+				if (!lv_is_thin_volume(lv)) {
+					log_error("LV %s is missing thin volume flag for segment %u",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+
+				if (lv_is_thin_pool(lv)) {
+					log_error("LV %s is a thin pool that must not contain thin volume segment %u",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+
+				if (!seg->pool_lv) {	
+					log_error("LV %s: segment %u is missing thin pool LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				} else if (!lv_is_thin_pool(seg->pool_lv)) {
+					log_error("LV %s: thin volume segment %u pool LV is not flagged as a pool LV",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+			} else {
+				if (seg->pool_lv) {	
+					log_error("LV %s: segment %u must not have thin pool LV set",
+						  lv->name, seg_count);
+					inc_error_count;
+				}
+			}
+		}
+
 		if (seg_is_snapshot(seg)) {
 			if (seg->cow && seg->cow == seg->origin) {
 				log_error("LV %s: segment %u has same LV %s for "
@@ -250,6 +358,8 @@
 				seg_found++;
 		if (seg->log_lv == lv)
 			seg_found++;
+		if (seg->pool_metadata_lv == lv || seg->pool_lv == lv)
+			seg_found++;
 		if (!seg_found) {
 			log_error("LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
 				  ", but missing ptr from %s to %s",
--- LVM2/lib/metadata/metadata-exported.h	2011/09/07 08:34:22	1.208
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/08 16:41:18	1.209
@@ -85,8 +85,8 @@
 
 #define THIN_VOLUME		UINT64_C(0x0000001000000000)	/* LV */
 #define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV */
-#define THIN_POOL_DATA		UINT64_C(0x0000002000000000)	/* LV */
-#define THIN_POOL_METADATA	UINT64_C(0x0000004000000000)	/* LV */
+#define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
+#define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
 
 #define LVM_READ		0x00000100U	/* LV VG 32-bit */
 #define LVM_WRITE		0x00000200U	/* LV VG 32-bit */
@@ -327,7 +327,6 @@
 
 	struct lv_segment_area *areas;
 	struct lv_segment_area *meta_areas;	/* For RAID */
-	struct logical_volume *pool_data_lv;	/* For thin_pool */
 	struct logical_volume *pool_metadata_lv;/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool */
 	uint32_t zero_new_blocks;		/* For thin_pool */
--- LVM2/lib/metadata/metadata.h	2011/09/06 22:43:57	1.254
+++ LVM2/lib/metadata/metadata.h	2011/09/08 16:41:19	1.255
@@ -371,6 +371,9 @@
 /* Find LV segment containing given LE */
 struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 
+/* Find pool LV segment given a thin pool data or metadata segment. */
+struct lv_segment *find_pool_seg(struct lv_segment *seg);
+
 /*
  * Remove a dev_dir if present.
  */
@@ -447,6 +450,7 @@
 int attach_pool_data_lv(struct lv_segment *seg,
 			struct logical_volume *pool_data_lv);
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv);
+int detach_pool_lv(struct lv_segment *seg);
 
 /*
  * Begin skeleton for external LVM library
--- LVM2/lib/metadata/thin_manip.c	2011/09/06 22:43:57	1.2
+++ LVM2/lib/metadata/thin_manip.c	2011/09/08 16:41:19	1.3
@@ -14,6 +14,8 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "segtype.h"
+#include "lv_alloc.h"
 
 int attach_pool_metadata_lv(struct lv_segment *seg, struct logical_volume *pool_metadata_lv)
 {
@@ -26,17 +28,55 @@
 
 int attach_pool_data_lv(struct lv_segment *seg, struct logical_volume *pool_data_lv)
 {
-	seg->pool_data_lv = pool_data_lv;
-	pool_data_lv->status |= THIN_POOL_DATA;
+	if (!set_lv_segment_area_lv(seg, 0, pool_data_lv, 0, THIN_POOL_DATA))
+		return_0;
+
         lv_set_hidden(pool_data_lv);
 
-        return add_seg_to_segs_using_this_lv(pool_data_lv, seg);
+        return 1;
 }
 
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv)
 {
+	if (!lv_is_thin_pool(pool_lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not a thin pool",
+			  pool_lv->name);
+		return 0;
+	}
+
 	seg->pool_lv = pool_lv;
-	pool_lv->status |= THIN_POOL;
+	seg->lv->status |= THIN_VOLUME;
 
         return add_seg_to_segs_using_this_lv(pool_lv, seg);
 }
+
+int detach_pool_lv(struct lv_segment *seg)
+{
+	if (!lv_is_thin_pool(seg->pool_lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not a thin pool",
+			  seg->pool_lv->name);
+		return 0;
+	}
+
+	return remove_seg_from_segs_using_this_lv(seg->pool_lv, seg);
+}
+
+struct lv_segment *find_pool_seg(struct lv_segment *seg)
+{
+        struct lv_segment *pool_seg;
+
+        pool_seg = get_only_segment_using_this_lv(seg->lv);
+
+        if (!pool_seg) {
+                log_error("Failed to find pool_seg for %s", seg->lv->name);
+                return NULL;
+        }
+
+        if (!seg_is_thin_pool(pool_seg)) {
+                log_error("%s on %s is not a pool segment",
+                          pool_seg->lv->name, seg->lv->name);
+                return NULL;
+        }
+
+        return pool_seg;
+}
--- LVM2/lib/thin/thin.c	2011/09/06 22:43:57	1.11
+++ LVM2/lib/thin/thin.c	2011/09/08 16:41:19	1.12
@@ -61,10 +61,10 @@
 	if (!(pool_metadata_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown metadata %s in", lv_name);
 
-	if (!attach_pool_metadata_lv(seg, pool_metadata_lv))
+	if (!attach_pool_data_lv(seg, pool_data_lv))
 		return_0;
 
-	if (!attach_pool_data_lv(seg, pool_data_lv))
+	if (!attach_pool_metadata_lv(seg, pool_metadata_lv))
 		return_0;
 
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
@@ -74,12 +74,22 @@
 	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
 
+	seg->lv->status |= THIN_POOL;
+
+	return 1;
+}
+
+static int _thin_pool_text_import_area_count(const struct dm_config_node *sn,
+					     uint32_t *area_count)
+{
+	*area_count = 1;
+
 	return 1;
 }
 
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "pool = \"%s\"", seg->pool_data_lv->name);
+	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 	if (seg->zero_new_blocks)
@@ -182,6 +192,7 @@
 static struct segtype_handler _thin_pool_ops = {
 	.name = _thin_pool_name,
 	.text_import = _thin_pool_text_import,
+	.text_import_area_count = _thin_pool_text_import_area_count,
 	.text_export = _thin_pool_text_export,
 	.modules_needed = _thin_modules_needed,
 	.destroy = _thin_destroy,
--- LVM2/tools/lvcreate.c	2011/09/07 09:25:51	1.239
+++ LVM2/tools/lvcreate.c	2011/09/08 16:41:19	1.240
@@ -590,6 +590,11 @@
 
 	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
 
+	if (seg_unknown(lp)) {
+		log_error("Unable to create LV with unknown segment type %s.", arg_str_value(cmd, type_ARG, segtype_str));
+		return 0;
+	}
+
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
 	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;


