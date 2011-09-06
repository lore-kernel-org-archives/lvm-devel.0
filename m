From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 00:26:45 -0000
Subject: LVM2 lib/format1/import-extents.c lib/format_p ...
Message-ID: <20110906002645.18489.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 00:26:44

Modified files:
	lib/format1    : import-extents.c 
	lib/format_pool: import_export.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : lv_alloc.h lv_manip.c merge.c 
	                 metadata-exported.h 
	lib/misc       : lvm-string.c 
	lib/thin       : thin.c 
	man            : lvcreate.8.in 
	tools          : args.h commands.h lvcreate.c lvresize.c 

Log message:
	lvcreate parsing for thin provisioning.
	The rest is incomplete so this isn't usable yet.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.277&r2=1.278
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.203&r2=1.204
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.234&r2=1.235
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/lib/format1/import-extents.c	2011/03/30 12:30:39	1.40
+++ LVM2/lib/format1/import-extents.c	2011/09/06 00:26:42	1.41
@@ -223,7 +223,7 @@
 		len = _area_length(lvm, le);
 
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv, le,
-					     len, 0, 0, NULL, 1, len, 0, 0, 0, NULL))) {
+					     len, 0, 0, NULL, NULL, 1, len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate linear segment.");
 			return 0;
 		}
@@ -295,7 +295,7 @@
 		if (!(seg = alloc_lv_segment(cmd->mem, segtype, lvm->lv,
 					     lvm->stripes * first_area_le,
 					     lvm->stripes * area_len,
-					     0, lvm->stripe_size, NULL,
+					     0, lvm->stripe_size, NULL, NULL,
 					     lvm->stripes,
 					     area_len, 0, 0, 0, NULL))) {
 			log_error("Failed to allocate striped segment.");
--- LVM2/lib/format_pool/import_export.c	2010/12/01 13:05:07	1.33
+++ LVM2/lib/format_pool/import_export.c	2011/09/06 00:26:42	1.34
@@ -195,7 +195,7 @@
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 				     area_len * usp->num_devs, 0,
-				     usp->striping, NULL, usp->num_devs,
+				     usp->striping, NULL, NULL, usp->num_devs,
 				     area_len, 0, 0, 0, NULL))) {
 		log_error("Unable to allocate striped lv_segment structure");
 		return 0;
@@ -235,7 +235,7 @@
 
 		if (!(seg = alloc_lv_segment(mem, segtype, lv, *le_cur,
 					     area_len, 0, usp->striping,
-					     NULL, 1, area_len,
+					     NULL, NULL, 1, area_len,
 					     POOL_PE_SIZE, 0, 0, NULL))) {
 			log_error("Unable to allocate linear lv_segment "
 				  "structure");
--- LVM2/lib/format_text/import_vsn1.c	2011/08/31 15:19:19	1.92
+++ LVM2/lib/format_text/import_vsn1.c	2011/09/06 00:26:43	1.93
@@ -329,7 +329,7 @@
 		return_0;
 
 	if (!(seg = alloc_lv_segment(mem, segtype, lv, start_extent,
-				     extent_count, 0, 0, NULL, area_count,
+				     extent_count, 0, 0, NULL, NULL, area_count,
 				     extent_count, 0, 0, 0, NULL))) {
 		log_error("Segment allocation failed");
 		return 0;
--- LVM2/lib/metadata/lv_alloc.h	2011/07/19 16:37:42	1.29
+++ LVM2/lib/metadata/lv_alloc.h	2011/09/06 00:26:43	1.30
@@ -22,6 +22,7 @@
 				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
+				    struct logical_volume *thin_pool_lv,
 				    uint32_t area_count,
 				    uint32_t area_len,
 				    uint32_t chunk_size,
@@ -72,7 +73,9 @@
 int lv_add_log_segment(struct alloc_handle *ah, uint32_t first_area,
 		       struct logical_volume *log_lv, uint64_t status);
 int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
-                           uint32_t extents, const struct segment_type *segtype);
+                           uint32_t extents,
+			   const struct segment_type *segtype,
+			   const char *thin_pool_name);
 
 void alloc_destroy(struct alloc_handle *ah);
 
--- LVM2/lib/metadata/lv_manip.c	2011/08/30 14:55:17	1.277
+++ LVM2/lib/metadata/lv_manip.c	2011/09/06 00:26:43	1.278
@@ -198,6 +198,22 @@
 	return i;
 }
 
+static int _attach_pool_metadata(struct lv_segment *seg, struct logical_volume *thin_pool_metadata)
+{
+	// FIXME Housekeeping needed here (cf attach_mirror_log)
+	seg->metadata_lv = thin_pool_metadata;
+
+	return 1;
+}
+
+static int _attach_pool_lv(struct lv_segment *seg, struct logical_volume *thin_pool_lv)
+{
+	// FIXME Housekeeping needed here (cf attach_mirror_log)
+	seg->thin_pool_lv = thin_pool_lv;
+
+	return 1;
+}
+
 /*
  * All lv_segments get created here.
  */
@@ -208,6 +224,7 @@
 				    uint64_t status,
 				    uint32_t stripe_size,
 				    struct logical_volume *log_lv,
+				    struct logical_volume *thin_pool_lv,
 				    uint32_t area_count,
 				    uint32_t area_len,
 				    uint32_t chunk_size,
@@ -248,13 +265,20 @@
 	seg->chunk_size = chunk_size;
 	seg->region_size = region_size;
 	seg->extents_copied = extents_copied;
-	seg->log_lv = log_lv;
 	seg->pvmove_source_seg = pvmove_source_seg;
 	dm_list_init(&seg->tags);
 
-	if (log_lv && !attach_mirror_log(seg, log_lv))
+	if (thin_pool_lv && !_attach_pool_lv(seg, thin_pool_lv))
 		return_NULL;
 
+	if (log_lv) {
+		if (thin_pool_lv) {
+			if (!_attach_pool_metadata(seg, log_lv))
+				return_NULL;
+		} else if (!attach_mirror_log(seg, log_lv))
+			return_NULL;
+	}
+
 	return seg;
 }
 
@@ -272,7 +296,7 @@
 
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv, old_le_count,
 				     lv->le_count - old_le_count, status, 0,
-				     NULL, 0, lv->le_count - old_le_count,
+				     NULL, NULL, 0, lv->le_count - old_le_count,
 				     0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new snapshot segment.");
 		return NULL;
@@ -559,9 +583,7 @@
 
 	/* FIXME: Should we bug if we find a log_lv attached? */
 
-	if (!lv_add_virtual_segment(lv, 0, len,
-				    get_segtype_from_string(lv->vg->cmd,
-							    "error")))
+	if (!lv_add_virtual_segment(lv, 0, len, get_segtype_from_string(lv->vg->cmd, "error"), NULL))
 		return_0;
 
 	return 1;
@@ -917,7 +939,7 @@
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count,
 				     aa[0].len * area_multiple,
-				     status, stripe_size, NULL,
+				     status, stripe_size, NULL, NULL,
 				     area_count,
 				     aa[0].len, 0u, region_size, 0u, NULL))) {
 		log_error("Couldn't allocate new LV segment.");
@@ -1987,13 +2009,25 @@
 }
 
 int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
-			   uint32_t extents, const struct segment_type *segtype)
+			   uint32_t extents, const struct segment_type *segtype,
+			   const char *thin_pool_name)
 {
 	struct lv_segment *seg;
+	struct logical_volume *thin_pool_lv = NULL;
+	struct lv_list *lvl;
+
+	if (thin_pool_name) {
+		if (!(lvl = find_lv_in_vg(lv->vg, thin_pool_name))) {
+			log_error("Unable to find existing pool LV %s in VG %s.",
+				  thin_pool_name, lv->vg->name);
+			return 0;
+		}
+		thin_pool_lv = lvl->lv;
+	}
 
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
 				     lv->le_count, extents, status, 0,
-				     NULL, 0, extents, 0, 0, 0, NULL))) {
+				     NULL, thin_pool_lv, 0, extents, 0, 0, 0, NULL))) {
 		log_error("Couldn't allocate new zero segment.");
 		return 0;
 	}
@@ -2129,7 +2163,7 @@
 					get_segtype_from_string(seg->lv->vg->cmd, "mirror"),
 					seg->lv, seg->le, seg->len,
 					seg->status, seg->stripe_size,
-					log_lv,
+					log_lv, NULL,
 					seg->area_count, seg->area_len,
 					seg->chunk_size, region_size,
 					seg->extents_copied, NULL))) {
@@ -2316,14 +2350,18 @@
 		lv->status |= MIRRORED;
 		status = MIRROR_IMAGE;
 		layer_name = "mimage";
-	} else
+	} else if (segtype_is_thin_pool(segtype)) {
+		// lv->status |= THIN_POOL;
+		// status = THIN_IMAGE;
+		layer_name = "tdata";
+	}
 		return_0;
 
 	/*
 	 * First, create our top-level segment for our top-level LV
 	 */
 	if (!(mapseg = alloc_lv_segment(lv->vg->cmd->mem, segtype,
-					lv, 0, 0, lv->status, stripe_size, NULL,
+					lv, 0, 0, lv->status, stripe_size, NULL, NULL,
 					devices, 0, 0, region_size, 0, NULL))) {
 		log_error("Failed to create mapping segment for %s", lv->name);
 		return 0;
@@ -2363,6 +2401,8 @@
 	}
 	dm_list_add(&lv->segments, &mapseg->list);
 
+// FIXME If thin pool, create one "log_lv" as tmeta here lv->metadata_lv
+
 	return 1;
 }
 
@@ -2481,7 +2521,7 @@
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
-	      uint32_t extents,
+	      uint32_t extents, const char *thin_pool_name,
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	int r = 1;
@@ -2492,17 +2532,19 @@
 	log_very_verbose("Extending segment type, %s", segtype->name);
 
 	if (segtype_is_virtual(segtype))
-		return lv_add_virtual_segment(lv, 0u, extents, segtype);
+		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
 	if (segtype_is_raid(segtype) && !lv->le_count)
 		raid_logs = mirrors * stripes;
 
+// For thin pool, ensure space for "log_lv" ->metadata_lv is allocated simultaneously here
+
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    raid_logs, region_size, extents,
 				    allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype))
+	if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype) && !segtype_is_thin_pool(segtype))
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, 0u, 0);
 	else {
@@ -2524,6 +2566,7 @@
 			return 0;
 		}
 
+// For thin_pool, populate tmeta here too
 		r = _lv_extend_layered_lv(ah, lv, extents, 0,
 					  stripes, stripe_size);
 	}
@@ -3372,7 +3415,7 @@
 
 	/* Replace the empty layer with error segment */
 	segtype = get_segtype_from_string(lv->vg->cmd, "error");
-	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype))
+	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype, NULL))
 		return_0;
 
 	return 1;
@@ -3425,7 +3468,7 @@
 
 		segtype = get_segtype_from_string(cmd, "error");
 
-		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype)) {
+		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype, NULL)) {
 			log_error("Creation of transient LV %s for mirror conversion in VG %s failed.", name, lv_where->vg->name);
 			return NULL;
 		}
@@ -3466,7 +3509,7 @@
 	/* allocate a new linear segment */
 	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
 					lv_where, 0, layer_lv->le_count,
-					status, 0, NULL, 1, layer_lv->le_count,
+					status, 0, NULL, NULL, 1, layer_lv->le_count,
 					0, 0, 0, NULL)))
 		return_NULL;
 
@@ -3510,7 +3553,7 @@
 	if (!(mapseg = alloc_lv_segment(layer_lv->vg->cmd->mem, segtype,
 					layer_lv, layer_lv->le_count,
 					seg->area_len, status, 0,
-					NULL, 1, seg->area_len, 0, 0, 0, seg)))
+					NULL, NULL, 1, seg->area_len, 0, 0, 0, seg)))
 		return_0;
 
 	/* map the new segment to the original underlying are */
@@ -3737,7 +3780,6 @@
 	return 1;
 }
 
-
 static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 						     struct volume_group *vg,
 						     const char *lv_name,
@@ -3766,7 +3808,7 @@
 		return_NULL;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, 0, voriginextents,
-		       NULL, ALLOC_INHERIT))
+		       NULL, NULL, ALLOC_INHERIT))
 		return_NULL;
 
 	/* store vg on disk(s) */
@@ -3778,8 +3820,14 @@
 	return lv;
 }
 
-int lv_create_single(struct volume_group *vg,
-		     struct lvcreate_params *lp)
+/* Thin notes:
+ * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
+ * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
+ *   If lp->activate is AY*, activate it.
+ *   If lp->activate was AN* and the pool was originally inactive, deactivate it.
+ */
+static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct lvcreate_params *lp,
+					       const char *new_lv_name)
 {
 	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
@@ -3788,24 +3836,24 @@
 	int origin_active = 0;
 	struct lvinfo info;
 
-	if (lp->lv_name && find_lv_in_vg(vg, lp->lv_name)) {
+	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
-			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
-		return 0;
+			  "volume group \"%s\"", new_lv_name, lp->vg_name);
+		return NULL;
 	}
 
 	if (vg_max_lv_reached(vg)) {
 		log_error("Maximum number of logical volumes (%u) reached "
 			  "in volume group %s", vg->max_lv, vg->name);
-		return 0;
+		return NULL;
 	}
 
 	if ((segtype_is_mirrored(lp->segtype) ||
-	     segtype_is_raid(lp->segtype)) &&
+	     segtype_is_raid(lp->segtype) || segtype_is_thin(lp->segtype)) &&
 	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
-		log_error("Metadata does not support %s.",
-			  segtype_is_raid(lp->segtype) ? "RAID" : "mirroring");
-		return 0;
+		log_error("Metadata does not support %s segments.",
+			  lp->segtype->name);
+		return NULL;
 	}
 
 	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
@@ -3813,7 +3861,7 @@
 	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
 	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
 		log_error("Metadata only supports readahead values between 2 and 120.");
-		return 0;
+		return NULL;
 	}
 
 	if (lp->stripe_size > vg->extent_size) {
@@ -3830,7 +3878,7 @@
 	    (lp->stripe_size > STRIPE_SIZE_MAX)) {
 		log_error("Stripe size may not exceed %s",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_MAX));
-		return 0;
+		return NULL;
 	}
 
 	if ((size_rest = lp->extents % lp->stripes)) {
@@ -3840,19 +3888,20 @@
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 
-	if (lp->zero && !activation()) {
+	if (lp->zero && !segtype_is_thin(lp->segtype) && !activation()) {
 		log_error("Can't wipe start of new LV without using "
 			  "device-mapper kernel driver");
-		return 0;
+		return NULL;
 	}
 
 	status |= lp->permission | VISIBLE_LV;
 
+	/* FIXME Thin snapshots are different */
 	if (lp->snapshot) {
 		if (!activation()) {
 			log_error("Can't create snapshot without using "
 				  "device-mapper kernel driver");
-			return 0;
+			return NULL;
 		}
 
 		/* Must zero cow */
@@ -3865,27 +3914,27 @@
 			if (!(org = find_lv(vg, lp->origin))) {
 				log_error("Couldn't find origin volume '%s'.",
 					  lp->origin);
-				return 0;
+				return NULL;
 			}
 			if (lv_is_virtual_origin(org)) {
 				log_error("Can't share virtual origins. "
 					  "Use --virtualsize.");
-				return 0;
+				return NULL;
 			}
 			if (lv_is_cow(org)) {
 				log_error("Snapshots of snapshots are not "
 					  "supported yet.");
-				return 0;
+				return NULL;
 			}
 			if (org->status & LOCKED) {
 				log_error("Snapshots of locked devices are not "
 					  "supported yet");
-				return 0;
+				return NULL;
 			}
 			if (lv_is_merging_origin(org)) {
 				log_error("Snapshots of an origin that has a "
 					  "merging snapshot is not supported");
-				return 0;
+				return NULL;
 			}
 			if ((org->status & MIRROR_IMAGE) ||
 			    (org->status & MIRROR_LOG)) {
@@ -3893,13 +3942,13 @@
 					  "are not supported",
 					  (org->status & MIRROR_LOG) ?
 					  "log" : "image");
-				return 0;
+				return NULL;
 			}
 
 			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
 				log_error("Check for existence of snapshot "
 					  "origin '%s' failed.", org->name);
-				return 0;
+				return NULL;
 			}
 			origin_active = info.exists;
 
@@ -3907,19 +3956,19 @@
 			    !lv_is_active_exclusive_locally(org)) {
 				log_error("%s must be active exclusively to"
 					  " create snapshot", org->name);
-				return 0;
+				return NULL;
 			}
 		}
 	}
 
-	if (!lp->extents) {
+	if (!lp->thin && !lp->extents) {
 		log_error("Unable to create new logical volume with no extents");
-		return 0;
+		return NULL;
 	}
 
 	if (lp->snapshot && (lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
 		log_error("Unable to create a snapshot smaller than 2 chunks.");
-		return 0;
+		return NULL;
 	}
 
 	if (!seg_is_virtual(lp) &&
@@ -3927,38 +3976,38 @@
 		log_error("Volume group \"%s\" has insufficient free space "
 			  "(%u extents): %u required.",
 			  vg->name, vg->free_count, lp->extents);
-		return 0;
+		return NULL;
 	}
 
 	if (lp->stripes > dm_list_size(lp->pvh) && lp->alloc != ALLOC_ANYWHERE) {
 		log_error("Number of stripes (%u) must not exceed "
 			  "number of physical volumes (%d)", lp->stripes,
 			  dm_list_size(lp->pvh));
-		return 0;
+		return NULL;
 	}
 
 	if ((segtype_is_mirrored(lp->segtype) ||
-	     segtype_is_raid(lp->segtype)) && !activation()) {
+	     segtype_is_raid(lp->segtype) || seg_is_thin_volume(lp)) && !activation()) {
 		log_error("Can't create %s without using "
 			  "device-mapper kernel driver.",
 			  segtype_is_raid(lp->segtype) ? lp->segtype->name :
 			  "mirror");
-		return 0;
+		return NULL;
 	}
 
 	/* The snapshot segment gets created later */
 	if (lp->snapshot &&
 	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
-		return_0;
+		return_NULL;
 
 	if (!archive(vg))
-		return 0;
+		return_NULL;
 
 	if (!dm_list_empty(&lp->tags)) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
 				  vg->name);
-			return 0;
+			return NULL;
 		}
 	}
 
@@ -3973,16 +4022,16 @@
 		}
 	}
 
-	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
+	if (!(lv = lv_create_empty(new_lv_name ? : "lvol%d", NULL,
 				   status, lp->alloc, vg)))
-		return_0;
+		return_NULL;
 
 	if (lp->read_ahead != lv->read_ahead) {
 		log_verbose("Setting read ahead sectors");
 		lv->read_ahead = lp->read_ahead;
 	}
 
-	if (lp->minor >= 0) {
+	if (!seg_is_thin_pool(lp) && lp->minor >= 0) {
 		lv->major = lp->major;
 		lv->minor = lp->minor;
 		lv->status |= FIXED_MINOR;
@@ -4000,8 +4049,12 @@
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors, lp->region_size,
-		       lp->extents, lp->pvh, lp->alloc))
-		return_0;
+		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
+		       seg_is_thin_volume(lp) ? lp->pool : NULL, lp->pvh, lp->alloc))
+		return_NULL;
+
+	if (seg_is_thin_pool(lp) && lp->zero)
+		first_seg(lv)->zero_new_blocks = 1;
 
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
@@ -4015,7 +4068,7 @@
 
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
+		return_NULL;
 
 	backup(vg);
 
@@ -4038,12 +4091,12 @@
 		log_error("Failed to activate new LV.");
 		if (lp->zero)
 			goto deactivate_and_revert_new_lv;
-		return 0;
+		return NULL;
 	}
 
-	if (!lp->zero && !lp->snapshot)
+	if (!seg_is_thin(lp) && !lp->zero && !lp->snapshot)
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
+	else if (!seg_is_thin(lp) && !set_lv(cmd, lv, UINT64_C(0), 0)) {
 		log_error("Aborting. Failed to wipe %s.",
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");
@@ -4059,7 +4112,7 @@
 		if (!origin_active && !deactivate_lv(cmd, lv)) {
 			log_error("Aborting. Couldn't deactivate snapshot "
 				  "COW area. Manual intervention required.");
-			return 0;
+			return NULL;
 		}
 
 		/* A virtual origin must be activated explicitly. */
@@ -4085,40 +4138,33 @@
 
 		/* store vg on disk(s) */
 		if (!vg_write(vg))
-			return_0;
+			return_NULL;
 
 		if (!suspend_lv(cmd, org)) {
 			log_error("Failed to suspend origin %s", org->name);
 			vg_revert(vg);
-			return 0;
+			return NULL;
 		}
 
 		if (!vg_commit(vg))
-			return_0;
+			return_NULL;
 
 		if (!resume_lv(cmd, org)) {
 			log_error("Problem reactivating origin %s", org->name);
-			return 0;
+			return NULL;
 		}
 	}
 	/* FIXME out of sequence */
 	backup(vg);
 
 out:
-	log_print("Logical volume \"%s\" created", lv->name);
-
-	/*
-	 * FIXME: as a sanity check we could try reading the
-	 * last block of the device ?
-	 */
-
-	return 1;
+	return lv;
 
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate failed new LV. "
 			  "Manual intervention required.");
-		return 0;
+		return NULL;
 	}
 
 revert_new_lv:
@@ -4129,6 +4175,37 @@
 	else
 		backup(vg);
 
-	return 0;
+	return NULL;
 }
 
+int lv_create_single(struct volume_group *vg,
+		     struct lvcreate_params *lp)
+{
+	struct logical_volume *lv;
+
+	/* Create thin pool first if necessary */
+	if (lp->create_thin_pool) {
+		if (!seg_is_thin_pool(lp) &&
+		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin_pool")))
+			return_0;
+		
+		if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
+			return_0;
+
+		if (!lp->thin)
+			goto out;
+
+		lp->pool = lv->name;
+	
+		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+		return_0;
+	}
+
+	if (!(lv = _lv_create_an_lv(vg, lp, lp->lv_name)))
+		return_0;
+
+out:
+	log_print("Logical volume \"%s\" created", lv->name);
+
+	return 1;
+}
--- LVM2/lib/metadata/merge.c	2011/08/02 22:07:22	1.45
+++ LVM2/lib/metadata/merge.c	2011/09/06 00:26:43	1.46
@@ -313,7 +313,7 @@
 	if (!(split_seg = alloc_lv_segment(lv->vg->vgmem, seg->segtype,
 					   seg->lv, seg->le, seg->len,
 					   seg->status, seg->stripe_size,
-					   seg->log_lv,
+					   seg->log_lv, seg->thin_pool_lv,
 					   seg->area_count, seg->area_len,
 					   seg->chunk_size, seg->region_size,
 					   seg->extents_copied, seg->pvmove_source_seg))) {
--- LVM2/lib/metadata/metadata-exported.h	2011/08/26 17:40:53	1.203
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/06 00:26:43	1.204
@@ -513,7 +513,7 @@
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
-	      uint32_t extents,
+	      uint32_t extents, const char *thin_pool_name,
 	      struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
 /* lv must be part of lv->vg->lvs */
@@ -556,8 +556,8 @@
 	int activation_monitoring; /* all */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 
-	char *origin; /* snap */
-	char *pool;   /* thin */
+	const char *origin; /* snap */
+	const char *pool;   /* thin */
 	const char *vg_name; /* all */
 	const char *lv_name; /* all */
 
--- LVM2/lib/misc/lvm-string.c	2011/08/30 14:55:18	1.29
+++ LVM2/lib/misc/lvm-string.c	2011/09/06 00:26:43	1.30
@@ -137,6 +137,18 @@
 		return 0;
 	}
 
+	if (strstr(name, "_tdata")) {
+		log_error("Names including \"_tpool\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_tmeta")) {
+		log_error("Names including \"_tpool\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	return 1;
 }
 
--- LVM2/lib/thin/thin.c	2011/09/01 10:16:32	1.7
+++ LVM2/lib/thin/thin.c	2011/09/06 00:26:43	1.8
@@ -201,7 +201,8 @@
 		uint32_t flags;
 	} reg_segtypes[] = {
 		{ &_thin_pool_ops, "thin_pool", SEG_THIN_POOL },
-		{ &_thin_ops, "thin", SEG_THIN_VOLUME }
+		/* FIXME Maybe use SEG_THIN_VOLUME instead of SEG_VIRTUAL */
+		{ &_thin_ops, "thin", SEG_THIN_VOLUME | SEG_VIRTUAL }
 	};
 
 	struct segment_type *segtype;
--- LVM2/man/lvcreate.8.in	2011/08/17 15:15:37	1.21
+++ LVM2/man/lvcreate.8.in	2011/09/06 00:26:43	1.22
@@ -32,11 +32,13 @@
 [\-\-noudevsync]
 [\-\-ignoremonitoring]
 [\-\-monitor {y|n}]
-\-n|\-\-name SnapshotLogicalVolumeName
+[--thinpool ThinPoolLogicalVolumeName]
+[\-n|\-\-name SnapshotLogicalVolumeName]
 {{\-s|\-\-snapshot}
 OriginalLogicalVolumePath | 
 [\-s|\-\-snapshot]
-VolumeGroupName \-V|\-\-virtualsize VirtualSize}
+VolumeGroupName \-V|\-\-virtualsize VirtualSize |
+-T VolumeGroupName[/ThinPoolLogicalVolumeName] \-V|\-\-virtualsize VirtualSize}
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .B vgcreate(8), vgchange(8)
--- LVM2/tools/args.h	2011/08/18 19:38:27	1.83
+++ LVM2/tools/args.h	2011/09/06 00:26:43	1.84
@@ -71,6 +71,7 @@
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
+arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
@@ -133,6 +134,7 @@
 arg(stdin_ARG, 's', "stdin", NULL, 0)
 arg(snapshot_ARG, 's', "snapshot", NULL, 0)
 arg(short_ARG, 's', "short", NULL, 0)
+arg(thin_ARG, 'T', "thin", NULL, 0)
 arg(test_ARG, 't', "test", NULL, 0)
 arg(uuid_ARG, 'u', "uuid", NULL, 0)
 arg(uuidstr_ARG, 'u', "uuid", string_arg, 0)
--- LVM2/tools/commands.h	2011/08/18 19:38:27	1.161
+++ LVM2/tools/commands.h	2011/09/06 00:26:43	1.162
@@ -177,6 +177,8 @@
    "lvcreate \n"
    "\t{ {-s|--snapshot} OriginalLogicalVolume[Path] |\n"
    "\t  [-s|--snapshot] VolumeGroupName[Path] -V|--virtualsize VirtualSize}\n"
+   "\t  {-T|--thin} VolumeGroupName[Path][/PoolLogicalVolume] \n"
+   "\t              -V|--virtualsize VirtualSize}\n"
    "\t[-c|--chunksize]\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"
@@ -195,6 +197,7 @@
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
+   "\t[--thinpool] PoolLogicalVolume\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
 
@@ -205,7 +208,8 @@
    minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG, name_ARG, nosync_ARG,
    noudevsync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
+   test_ARG, thin_ARG, thinpool_ARG, type_ARG, virtualoriginsize_ARG,
+   virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- LVM2/tools/lvcreate.c	2011/08/12 02:16:46	1.234
+++ LVM2/tools/lvcreate.c	2011/09/06 00:26:43	1.235
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -25,6 +25,24 @@
 	int pv_count;
 };
 
+static int _set_vg_name(struct lvcreate_params *lp, const char *vg_name)
+{
+	/* Can't do anything */
+	if (!vg_name)
+		return 1;
+
+	/* If VG name already known, ensure this 2nd copy is identical */
+	if (lp->vg_name && strcmp(lp->vg_name, vg_name)) {
+		log_error("Inconsistent volume group names "
+			  "given: \"%s\" and \"%s\"",
+			  lp->vg_name, vg_name);
+		return 0;
+	}
+	lp->vg_name = vg_name;
+
+	return 1;
+}
+
 static int _lvcreate_name_params(struct lvcreate_params *lp,
 				 struct cmd_context *cmd,
 				 int *pargc, char ***pargv)
@@ -33,38 +51,88 @@
 	char **argv = *pargv, *ptr;
 	const char *vg_name;
 
+	lp->pool = arg_str_value(cmd, thinpool_ARG, NULL);
+
+	/* If --thinpool contains VG name, extract it. */
+	if (lp->pool && strchr(lp->pool, '/')) {
+		if (!(lp->vg_name = extract_vgname(cmd, lp->pool)))
+			return 0;
+		/* Strip VG from pool */
+		if ((ptr = strrchr(lp->pool, (int) '/')))
+			lp->pool = ptr + 1;
+	}
+
 	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
 
+	/* If --name contains VG name, extract it. */
+	if (lp->lv_name && strchr(lp->lv_name, '/')) {
+		if (!_set_vg_name(lp, extract_vgname(cmd, lp->lv_name)))
+			return_0;
+
+		/* Strip VG from lv_name */
+		if ((ptr = strrchr(lp->lv_name, (int) '/')))
+			lp->lv_name = ptr + 1;
+	}
+
+	/* Need an origin? */
 	if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
+		/* argv[0] might be origin or vg/origin */
 		if (!argc) {
 			log_error("Please specify a logical volume to act as "
 				  "the snapshot origin.");
 			return 0;
 		}
 
-		lp->origin = argv[0];
-		(*pargv)++, (*pargc)--;
-		if (!(lp->vg_name = extract_vgname(cmd, lp->origin))) {
+		lp->origin = skip_dev_dir(cmd, argv[0], NULL);
+		if (strrchr(lp->origin, '/')) {
+			if (!_set_vg_name(lp, extract_vgname(cmd, lp->origin)))
+				return_0;
+
+			/* Strip the volume group from the origin */
+			if ((ptr = strrchr(lp->origin, (int) '/')))
+				lp->origin = ptr + 1;
+		}
+
+		if (!lp->vg_name) {
 			log_error("The origin name should include the "
 				  "volume group.");
 			return 0;
 		}
 
-		/* Strip the volume group from the origin */
-		if ((ptr = strrchr(lp->origin, (int) '/')))
-			lp->origin = ptr + 1;
+		(*pargv)++, (*pargc)--;
+	} else if (seg_is_thin(lp) && !lp->pool && argc) {
+		/* argv[0] might be vg or vg/Pool */
+
+		vg_name = skip_dev_dir(cmd, argv[0], NULL);
+		if (!strrchr(vg_name, '/')) {
+			if (!_set_vg_name(lp, vg_name))
+				return_0;
+		} else {
+			lp->pool = vg_name;
+			if (!_set_vg_name(lp, extract_vgname(cmd, lp->pool)))
+				return_0;
+	
+			if (!lp->vg_name) {
+				log_error("The pool name should include the "
+					  "volume group.");
+				return 0;
+			}
+
+			/* Strip the volume group */
+			if ((ptr = strrchr(lp->pool, (int) '/')))
+				lp->pool = ptr + 1;
+		}
 
+		(*pargv)++, (*pargc)--;
 	} else {
 		/*
-		 * If VG not on command line, try -n arg and then
-		 * environment.
+		 * If VG not on command line, try environment default.
 		 */
 		if (!argc) {
-			if (!(lp->vg_name = extract_vgname(cmd, lp->lv_name))) {
+			if (!lp->vg_name && !(lp->vg_name = extract_vgname(cmd, NULL))) {
 				log_error("Please provide a volume group name");
 				return 0;
 			}
-
 		} else {
 			vg_name = skip_dev_dir(cmd, argv[0], NULL);
 			if (strrchr(vg_name, '/')) {
@@ -73,25 +141,9 @@
 				return 0;
 			}
 
-			/*
-			 * Ensure lv_name doesn't contain a
-			 * different VG.
-			 */
-			if (lp->lv_name && strchr(lp->lv_name, '/')) {
-				if (!(lp->vg_name =
-				      extract_vgname(cmd, lp->lv_name)))
-					return 0;
-
-				if (strcmp(lp->vg_name, vg_name)) {
-					log_error("Inconsistent volume group "
-						  "names "
-						  "given: \"%s\" and \"%s\"",
-						  lp->vg_name, vg_name);
-					return 0;
-				}
-			}
+			if (!_set_vg_name(lp, vg_name))
+				return_0;
 
-			lp->vg_name = vg_name;
 			(*pargv)++, (*pargc)--;
 		}
 	}
@@ -103,9 +155,6 @@
 	}
 
 	if (lp->lv_name) {
-		if ((ptr = strrchr(lp->lv_name, '/')))
-			lp->lv_name = ptr + 1;
-
 		if (!apply_lvname_restrictions(lp->lv_name))
 			return_0;
 
@@ -116,6 +165,54 @@
 		}
 	}
 
+	if (lp->pool) {
+		if (!apply_lvname_restrictions(lp->pool))
+			return_0;
+
+		if (!validate_name(lp->pool)) {
+			log_error("Logical volume name \"%s\" is invalid",
+				  lp->pool);
+			return 0;
+		}
+
+		if (lp->lv_name && !strcmp(lp->lv_name, lp->pool)) {
+			log_error("Logical volume name %s and pool name %s must be different.", 
+				  lp->lv_name, lp->pool);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Normal snapshot or thinly-provisioned snapshot?
+ */
+static int _determine_snapshot_type(struct volume_group *vg,
+				  struct lvcreate_params *lp)
+{
+	struct lv_list *lvl;
+	struct lv_segment *seg;
+
+	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
+		log_error("Snapshot origin LV %s not found in Volume group %s.", lp->origin, vg->name);
+		return 0;
+	}
+
+	/* FIXME Replace with lv_is_thin_volume() once more flags are added */
+	if (seg_is_thin_volume(seg = first_seg(lvl->lv))) {
+		lp->thin = 1;
+		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+			return_0;
+
+		lp->pool = seg->thin_pool_lv->name;
+	}
+
+	if (!lp->thin && !arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
+		log_error("Please specify either size or extents with snapshots.");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -195,11 +292,16 @@
 			     struct lvcreate_cmdline_params *lcp,
 			     struct cmd_context *cmd)
 {
-	if (arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) != 1) {
+	if (arg_count(cmd, extents_ARG) && arg_count(cmd, size_ARG)) {
 		log_error("Please specify either size or extents (not both)");
 		return 0;
 	}
 
+	if (!lp->thin && !lp->snapshot && !arg_count(cmd, extents_ARG) && !arg_count(cmd, size_ARG)) {
+		log_error("Please specify either size or extents");
+		return 0;
+	}
+
 	if (arg_count(cmd, extents_ARG)) {
 		if (arg_sign_value(cmd, extents_ARG, 0) == SIGN_MINUS) {
 			log_error("Negative number of extents is invalid");
@@ -219,8 +321,16 @@
 		lcp->percent = PERCENT_NONE;
 	}
 
+	/* If size/extents given with thin, then we are creating a thin pool */
+	if (lp->thin && (arg_count(cmd, size_ARG) || arg_count(cmd, extents_ARG)))
+		lp->create_thin_pool = 1;
+
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, virtualsize_ARG)) {
+		if (seg_is_thin_pool(lp)) {
+			log_error("Virtual size in incompatible with thin_pool segment type.");
+			return 0;
+		}
 		if (arg_sign_value(cmd, virtualsize_ARG, 0) == SIGN_MINUS) {
 			log_error("Negative virtual origin size is invalid");
 			return 0;
@@ -231,6 +341,12 @@
 			log_error("Virtual origin size may not be zero");
 			return 0;
 		}
+	} else {
+		/* No virtual size given, so no thin LV to create. */
+		if (!seg_is_thin_pool(lp) && !(lp->segtype = get_segtype_from_string(cmd, "thin_pool")))
+			return_0;
+
+		lp->thin = 0;
 	}
 
 	return 1;
@@ -357,7 +473,87 @@
 	 * that by checking and warning if they aren't set.
 	 */
 	if (!lp->region_size) {
-		log_error("Programmer error: lp->region_size not set.");
+		log_error(INTERNAL_ERROR "region_size not set.");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd)
+{
+	unsigned pagesize;
+
+	lp->activate = arg_uint_value(cmd, available_ARG, CHANGE_AY);
+
+	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
+		if (lp->zero && !seg_is_thin(lp)) {
+			log_error("--available n requires --zero n");
+			return 0;
+		}
+	}
+
+	/*
+	 * Read ahead.
+	 */
+	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
+					cmd->default_settings.read_ahead);
+	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
+	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    lp->read_ahead != DM_READ_AHEAD_NONE &&
+	    lp->read_ahead % pagesize) {
+		if (lp->read_ahead < pagesize)
+			lp->read_ahead = pagesize;
+		else
+			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
+		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
+			    "of %uK page size.", lp->read_ahead, pagesize >> 1);
+	}
+
+	/*
+	 * Permissions.
+	 */
+	lp->permission = arg_uint_value(cmd, permission_ARG,
+					LVM_READ | LVM_WRITE);
+
+	if (lp->thin && !(lp->permission & LVM_WRITE)) {
+		log_error("Read-only thin volumes are not currently supported.");
+		return 0;
+	}
+
+	/* Must not zero read only volume */
+	if (!(lp->permission & LVM_WRITE))
+		lp->zero = 0;
+
+	lp->minor = arg_int_value(cmd, minor_ARG, -1);
+	lp->major = arg_int_value(cmd, major_ARG, -1);
+
+	/* Persistent minor */
+	if (arg_count(cmd, persistent_ARG)) {
+		if (lp->create_thin_pool && !lp->thin) {
+			log_error("--persistent is not permitted when creating a thin pool device.");
+			return 0;
+		}
+		if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
+			if (lp->minor == -1) {
+				log_error("Please specify minor number with "
+					  "--minor when using -My");
+				return 0;
+			}
+			if (lp->major == -1) {
+				log_error("Please specify major number with "
+					  "--major when using -My");
+				return 0;
+			}
+		} else {
+			if ((lp->minor != -1) || (lp->major != -1)) {
+				log_error("--major and --minor incompatible "
+					  "with -Mn");
+				return 0;
+			}
+		}
+	} else if (arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) {
+		log_error("--major and --minor require -My");
 		return 0;
 	}
 
@@ -370,7 +566,6 @@
 			    int argc, char **argv)
 {
 	int contiguous;
-	unsigned pagesize;
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
@@ -382,16 +577,36 @@
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
-	segtype_str = "striped";
+	if (arg_count(cmd, thin_ARG) && arg_count(cmd,mirrors_ARG)) {
+		log_error("--thin and --mirrors are incompatible.");
+		return 0;
+	}
+
+	/* Set default segtype */
 	if (arg_count(cmd, mirrors_ARG))
 		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
+		segtype_str = "thin";
+	else
+		segtype_str = "striped";
 
 	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
 
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
-	    arg_count(cmd, virtualsize_ARG))
+	    (!seg_is_thin(lp) && arg_count(cmd, virtualsize_ARG)))
 		lp->snapshot = 1;
 
+	if (seg_is_thin_pool(lp)) {
+		if (lp->snapshot) {
+			log_error("Snapshots are incompatible with thin_pool segment_type.");
+			return 0;
+		}
+		lp->create_thin_pool = 1;
+	}
+
+	if (seg_is_thin_volume(lp))
+		lp->thin = 1;
+
 	lp->mirrors = 1;
 
 	/* Default to 2 mirrored areas if '--type mirror|raid1' */
@@ -408,31 +623,9 @@
 		}
 	}
 
-	if (lp->snapshot) {
-		if (arg_count(cmd, zero_ARG)) {
-			log_error("-Z is incompatible with snapshots");
-			return 0;
-		}
-		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
-			log_error("Negative chunk size is invalid");
-			return 0;
-		}
-		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
-		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-		    (lp->chunk_size & (lp->chunk_size - 1))) {
-			log_error("Chunk size must be a power of 2 in the "
-				  "range 4K to 512K");
-			return 0;
-		}
-		log_verbose("Setting chunksize to %d sectors.", lp->chunk_size);
-
-		if (!(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
-			return_0;
-	} else {
-		if (arg_count(cmd, chunksize_ARG)) {
-			log_error("-c is only available with snapshots");
-			return 0;
-		}
+	if (lp->snapshot && arg_count(cmd, zero_ARG)) {
+		log_error("-Z is incompatible with snapshots");
+		return 0;
 	}
 
 	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
@@ -476,34 +669,39 @@
 	    !_read_raid_params(lp, cmd))
 		return_0;
 
-	lp->activate = arg_uint_value(cmd, available_ARG, CHANGE_AY);
-
-	/*
-	 * Should we zero the lv.
-	 */
-	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
-		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
+	if (lp->snapshot && lp->thin && arg_count(cmd, chunksize_ARG))
+		log_warn("WARNING: Ignoring --chunksize with thin snapshots.");
+	else if (lp->thin && !lp->create_thin_pool) {
+		if (arg_count(cmd, chunksize_ARG))
+			log_warn("WARNING: Ignoring --chunksize when using an existing pool.");
+	} else if (lp->snapshot || lp->create_thin_pool) {
+		if (arg_sign_value(cmd, chunksize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative chunk size is invalid");
+			return 0;
+		}
+		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
+		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
+		    (lp->chunk_size & (lp->chunk_size - 1))) {
+			log_error("Chunk size must be a power of 2 in the "
+				  "range 4K to 512K");
+			return 0;
+		}
+		log_verbose("Setting chunksize to %d sectors.", lp->chunk_size);
 
-	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
-		if (lp->zero) {
-			log_error("--available n requires --zero n");
+		if (!lp->thin && lp->snapshot && !(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+			return_0;
+	} else {
+		if (arg_count(cmd, chunksize_ARG)) {
+			log_error("-c is only available with snapshots and thin pools");
 			return 0;
 		}
 	}
 
 	/*
-	 * Alloc policy
+	 * Should we zero the lv.
 	 */
-	contiguous = strcmp(arg_str_value(cmd, contiguous_ARG, "n"), "n");
-
-	lp->alloc = contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
-
-	lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
-
-	if (contiguous && (lp->alloc != ALLOC_CONTIGUOUS)) {
-		log_error("Conflicting contiguous and alloc arguments");
-		return 0;
-	}
+	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
+		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
 
 	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Only up to %d images in mirror supported currently.",
@@ -511,58 +709,20 @@
 		return 0;
 	}
 
-	/*
-	 * Read ahead.
-	 */
-	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
-					cmd->default_settings.read_ahead);
-	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
-	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
-	    lp->read_ahead != DM_READ_AHEAD_NONE &&
-	    lp->read_ahead % pagesize) {
-		if (lp->read_ahead < pagesize)
-			lp->read_ahead = pagesize;
-		else
-			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
-		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
-			    "of %uK page size.", lp->read_ahead, pagesize >> 1);
-	}
+	if (!_read_activation_params(lp, cmd))
+		return_0;
 
 	/*
-	 * Permissions.
+	 * Allocation parameters
 	 */
-	lp->permission = arg_uint_value(cmd, permission_ARG,
-					LVM_READ | LVM_WRITE);
+	contiguous = strcmp(arg_str_value(cmd, contiguous_ARG, "n"), "n");
 
-	/* Must not zero read only volume */
-	if (!(lp->permission & LVM_WRITE))
-		lp->zero = 0;
+	lp->alloc = contiguous ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
 
-	lp->minor = arg_int_value(cmd, minor_ARG, -1);
-	lp->major = arg_int_value(cmd, major_ARG, -1);
+	lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
 
-	/* Persistent minor */
-	if (arg_count(cmd, persistent_ARG)) {
-		if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "y")) {
-			if (lp->minor == -1) {
-				log_error("Please specify minor number with "
-					  "--minor when using -My");
-				return 0;
-			}
-			if (lp->major == -1) {
-				log_error("Please specify major number with "
-					  "--major when using -My");
-				return 0;
-			}
-		} else {
-			if ((lp->minor != -1) || (lp->major != -1)) {
-				log_error("--major and --minor incompatible "
-					  "with -Mn");
-				return 0;
-			}
-		}
-	} else if (arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) {
-		log_error("--major and --minor require -My");
+	if (contiguous && (lp->alloc != ALLOC_CONTIGUOUS)) {
+		log_error("Conflicting contiguous and alloc arguments");
 		return 0;
 	}
 
@@ -576,10 +736,10 @@
 		}
 
 		if (!str_list_add(cmd->mem, &lp->tags, tag)) {
-                	log_error("Unable to allocate memory for tag %s", tag);
+			log_error("Unable to allocate memory for tag %s", tag);
 			return 0;
 		}
-        }
+	}
 
 	lcp->pv_count = argc;
 	lcp->pvs = argv;
@@ -587,6 +747,140 @@
 	return 1;
 }
 
+static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_params *lp,
+				  struct lvcreate_cmdline_params *lcp)
+{
+	struct lv_list *lvl;
+
+	if (!lp->thin && !lp->create_thin_pool) {
+		log_error("Please specify device size(s).");
+		return 0;
+	}
+
+	if (lp->thin && !lp->create_thin_pool) {
+		if (arg_count(vg->cmd, chunksize_ARG)) {
+			log_error("Only specify --chunksize when originally creating the thin pool.");
+			return 0;
+		}
+
+		if (lcp->pv_count) {
+			log_error("Only specify Physical volumes when allocating the thin pool.");
+			return 0;
+		}
+
+		if (arg_count(vg->cmd, alloc_ARG)) {
+			log_error("--alloc may only be specified when allocating the thin pool.");
+			return 0;
+		}
+
+		if (arg_count(vg->cmd, stripesize_ARG)) {
+			log_error("--stripesize may only be specified when allocating the thin pool.");
+			return 0;
+		}
+
+		if (arg_count(vg->cmd, stripes_ARG)) {
+			log_error("--stripes may only be specified when allocating the thin pool.");
+			return 0;
+		}
+
+		if (arg_count(vg->cmd, contiguous_ARG)) {
+			log_error("--contiguous may only be specified when allocating the thin pool.");
+			return 0;
+		}
+
+		if (arg_count(vg->cmd, zero_ARG)) {
+			log_error("--zero may only be specified when allocating the thin pool.");
+			return 0;
+		}
+	}
+
+	if (lp->create_thin_pool && lp->pool) {
+		if (find_lv_in_vg(vg, lp->pool)) {
+			log_error("Pool %s already exists in Volume group %s.", lp->pool, vg->name);
+			return 0;
+		}
+	} else if (lp->pool) {
+		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
+			log_error("Pool %s not found in Volume group %s.", lp->pool, vg->name);
+			return 0;
+		}
+		/* FIXME Use lv_is_thin_pool() */
+		if (!seg_is_thin_pool(first_seg(lvl->lv))) {
+			log_error("Logical volume %s is not a thin pool.", lp->pool);
+			return 0;
+		}
+	} else if (!lp->create_thin_pool) {
+		log_error("Please specify name of existing pool.");
+		return 0;
+	}
+
+	if (!lp->thin && lp->lv_name) {
+		log_error("--name may only be given when creating a new thin Logical volume or snapshot.");
+		return 0;
+	}
+
+	if (!lp->thin) {
+		if (arg_count(vg->cmd, readahead_ARG)) {
+			log_error("--readhead may only be given when creating a new thin Logical volume or snapshot.");
+			return 0;
+		}
+		if (arg_count(vg->cmd, permission_ARG)) {
+			log_error("--permission may only be given when creating a new thin Logical volume or snapshot.");
+			return 0;
+		}
+		if (arg_count(vg->cmd, persistent_ARG)) {
+			log_error("--persistent may only be given when creating a new thin Logical volume or snapshot.");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Ensure the set of thin parameters extracted from the command line is consistent.
+ */
+static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
+{
+	int r = 1;
+
+	/*
+	   The final state should be one of:
+	   thin  create_thin_pool  snapshot   origin   pool  
+	     1          1             0          0      y/n    - create new pool and a thin LV in it
+	     1          0             0          0      y      - create new thin LV in existing pool
+	     0          1             0          0      y/n    - create new pool only
+	     1          0             1          1      y      - create thin snapshot of existing thin LV
+	*/
+
+	if (!lp->create_thin_pool && !lp->pool) {
+		log_error(INTERNAL_ERROR "--thinpool not identified.");
+		r = 0;
+	}
+
+	if ((lp->snapshot && !lp->origin) || (!lp->snapshot && lp->origin)) {
+		log_error(INTERNAL_ERROR "Inconsistent snapshot and origin parameters identified.");
+		r = 0;
+	}
+
+	if (lp->snapshot && (lp->create_thin_pool || !lp->thin)) {
+		log_error(INTERNAL_ERROR "Inconsistent thin and snapshot parameters identified.");
+		r = 0;
+	}
+
+	if (!lp->thin && !lp->create_thin_pool) {
+		log_error(INTERNAL_ERROR "Failed to identify what type of thin target to use.");
+		r = 0;
+	}
+
+	if (seg_is_thin_pool(lp) && lp->thin) {
+		log_error(INTERNAL_ERROR "Thin volume cannot be created with thin pool segment type.");
+		r = 0;
+	}
+
+	return r;
+}
+
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	int r = ECMD_PROCESSED;
@@ -605,11 +899,43 @@
 		return ECMD_FAILED;
 	}
 
+	if (lp.snapshot && !_determine_snapshot_type(vg, &lp)) {
+		r = ECMD_FAILED;
+		goto_out;
+	}
+
+	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp)) {
+		r = ECMD_FAILED;
+		goto_out;
+	}
+
 	if (!_update_extents_params(vg, &lp, &lcp)) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
 
+	if (seg_is_thin(&lp) && !_validate_internal_thin_processing(&lp)) {
+		r = ECMD_FAILED;
+		goto_out;
+	}
+
+	if (lp.create_thin_pool)
+		log_verbose("Making thin pool %s in VG %s using segtype %s",
+			    lp.pool ? : "with generated name", lp.vg_name, lp.segtype->name);
+
+	if (lp.thin)
+		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
+			    lp.lv_name ? : "with generated name",
+			    lp.pool, lp.vg_name, lp.snapshot ? " as snapshot of " : "",
+			    lp.snapshot ? lp.origin : "", lp.segtype->name);
+
+	/* FIXME Remove when thin snapshots are supported. */
+	if (lp.thin && lp.snapshot) {
+		log_error("Thin snapshots are not yet supported.");
+		r = ECMD_FAILED;
+		goto_out;
+	}
+
 	if (!lv_create_single(vg, &lp)) {
 		stack;
 		r = ECMD_FAILED;
--- LVM2/tools/lvresize.c	2011/08/10 20:25:31	1.134
+++ LVM2/tools/lvresize.c	2011/09/06 00:26:43	1.135
@@ -707,7 +707,7 @@
 		   !lv_extend(lv, lp->segtype,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
-			      lp->extents - lv->le_count,
+			      lp->extents - lv->le_count, NULL,
 			      pvh, alloc)) {
 		stack;
 		return ECMD_FAILED;


