From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:35 -0400
Subject: master - vdo: introduce segment types and manip functions
Message-ID: <201807091334.w69DYZMr030641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8f84f78015326125c4884046014a5b93fded77f
Commit:        a8f84f78015326125c4884046014a5b93fded77f
Parent:        c66a960149ae28f057bc1a91d6974e92fc572c30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:11:14 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

vdo: introduce segment types and manip functions

Core functionality introducing lvm VDO support.
---
 lib/Makefile.in                  |    5 +
 lib/activate/activate.h          |    1 +
 lib/activate/dev_manager.c       |    6 +-
 lib/commands/toolcontext.c       |    5 +
 lib/format_text/flags.c          |    3 +
 lib/metadata/lv.c                |    3 +
 lib/metadata/lv_manip.c          |   93 +++++++-
 lib/metadata/metadata-exported.h |   29 ++-
 lib/metadata/segtype.h           |   12 +
 lib/metadata/vdo_manip.c         |  269 +++++++++++++++++++++
 lib/misc/lvm-string.c            |    2 +
 lib/vdo/vdo.c                    |  484 ++++++++++++++++++++++++++++++++++++++
 12 files changed, 903 insertions(+), 9 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index ead443e..737208b 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -77,6 +77,7 @@ SOURCES =\
 	metadata/segtype.c \
 	metadata/snapshot_manip.c \
 	metadata/thin_manip.c \
+	metadata/vdo_manip.c \
 	metadata/vg.c \
 	mirror/mirrored.c \
 	misc/crc.c \
@@ -126,6 +127,10 @@ ifeq ("@BUILD_LVMLOCKD@", "yes")
 	locking/lvmlockd.c
 endif
 
+ifeq ("@VDO@", "internal")
+  SOURCES += vdo/vdo.c
+endif
+
 LIB_NAME = liblvm-internal
 LIB_STATIC = $(LIB_NAME).a
 
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 5d77f40..09cd688 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -261,6 +261,7 @@ void fs_unlock(void);
 #define TARGET_NAME_STRIPED "striped"
 #define TARGET_NAME_THIN "thin"
 #define TARGET_NAME_THIN_POOL "thin-pool"
+#define TARGET_NAME_VDO "vdo"
 #define TARGET_NAME_ZERO "zero"
 
 #define MODULE_NAME_CLUSTERED_MIRROR "clog"
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3e4ec86..07fc93e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -45,7 +45,7 @@ typedef enum {
 } action_t;
 
 /* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
-const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", NULL};
+const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", "vdata", "vpool", NULL};
 
 struct dlid_list {
 	struct dm_list list;
@@ -275,6 +275,10 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		    (length > DM_THIN_MAX_METADATA_SIZE))
 			length = DM_THIN_MAX_METADATA_SIZE;
 
+		/* Uses virtual size with headers for VDO pool device */
+		if (lv_is_vdo_pool(seg_status->seg->lv))
+			length = get_vdo_pool_virtual_size(seg_status->seg);
+
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index eb15581..ec44bdb 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1399,6 +1399,11 @@ static int _init_segtypes(struct cmd_context *cmd)
 		return 0;
 #endif
 
+#ifdef VDO_INTERNAL
+	if (!init_vdo_segtypes(cmd, &seglib))
+		return_0;
+#endif
+
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 98894e7..6f5ff9f 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -98,6 +98,9 @@ static const struct flag _lv_flags[] = {
 	{CACHE_POOL, NULL, 0},
 	{CACHE_POOL_DATA, NULL, 0},
 	{CACHE_POOL_METADATA, NULL, 0},
+	{LV_VDO, NULL, 0},
+	{LV_VDO_POOL, NULL, 0},
+	{LV_VDO_POOL_DATA, NULL, 0},
 	{LV_PENDING_DELETE, NULL, 0}, /* FIXME Display like COMPATIBLE_FLAG */
 	{LV_REMOVED, NULL, 0},
 	{0, NULL, 0}
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 7ab06cb..cf6fafa 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -797,6 +797,9 @@ const char *lv_layer(const struct logical_volume *lv)
 	if (lv_is_thin_pool(lv))
 		return "tpool";
 
+	if (lv_is_vdo_pool(lv))
+		return "vpool";
+
 	if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		return "real";
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6bf851e..b731c2a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1034,6 +1034,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 
 	if (lv_is_mirror_image(lv) ||
 	    lv_is_thin_pool_data(lv) ||
+	    lv_is_vdo_pool_data(lv) ||
 	    lv_is_cache_pool_data(lv)) {
 		if (!lv_reduce(lv, area_reduction))
 			return_0; /* FIXME: any upper level reporting */
@@ -1102,6 +1103,10 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		seg_type(seg, s) = AREA_UNASSIGNED;
 	}
 
+	/* When removed last VDO user automatically removes VDO pool */
+	if (lv_is_vdo_pool(lv) && dm_list_empty(&(lv->segs_using_this_lv)))
+		return lv_remove(lv); /* FIXME: any upper level reporting */
+
 	return 1;
 }
 
@@ -3265,11 +3270,46 @@ static int _allocate(struct alloc_handle *ah,
 	return r;
 }
 
+/*
+ * FIXME: Add proper allocation function for VDO segment on top
+ *        of VDO pool with virtual size.
+ *
+ * Note: ATM lvm2 can't resize VDO device so it can add only a single segment.
+ */
+static int _lv_add_vdo_segment(struct logical_volume *lv, uint64_t status,
+			       uint32_t extents, const struct segment_type *segtype)
+{
+	struct lv_segment *seg;
+
+	if (!dm_list_empty(&lv->segments) &&
+	    (seg = last_seg(lv)) && (seg->segtype == segtype)) {
+		seg->area_len += extents;
+		seg->len += extents;
+	} else {
+		if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents, 0,
+					     status, 0, NULL, 1,
+					     extents, 0, 0, 0, 0, NULL))) {
+			log_error("Couldn't allocate new %s segment.", segtype->name);
+			return 0;
+		}
+		lv->status |= LV_VDO;
+		dm_list_add(&lv->segments, &seg->list);
+	}
+
+	lv->le_count += extents;
+	lv->size += (uint64_t) extents * lv->vg->extent_size;
+
+	return 1;
+}
+
 int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 			   uint32_t extents, const struct segment_type *segtype)
 {
 	struct lv_segment *seg;
 
+	if (segtype_is_vdo(segtype))
+		return _lv_add_vdo_segment(lv, 0u, extents, segtype);
+
 	if (!dm_list_empty(&lv->segments) &&
 	    (seg = last_seg(lv)) && (seg->segtype == segtype)) {
 		seg->area_len += extents;
@@ -4362,7 +4402,9 @@ static int _rename_cb(struct logical_volume *lv, void *data)
 
 static int _rename_skip_pools_externals_cb(struct logical_volume *lv, void *data)
 {
-	if (lv_is_pool(lv) || lv_is_external_origin(lv))
+	if (lv_is_pool(lv) ||
+	    lv_is_vdo_pool(lv) ||
+	    lv_is_external_origin(lv))
 		return -1; /* and skip subLVs */
 
 	return _rename_cb(lv, data);
@@ -4458,6 +4500,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	 * (thin pool is 'visible', but cache may not)
 	 */
 	if (!lv_is_pool(lv) &&
+	    !lv_is_vdo_pool(lv) &&
 	    !lv_is_visible(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
@@ -6351,6 +6394,13 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
 
+	if (lv_is_vdo_pool(lv)) {
+		if (!_lv_remove_segs_using_this_lv(cmd, lv, force, level, "VDO pool"))
+			return_0;
+		/* Last user removes VDO pool itself, lv no longer exists */
+		return 1;
+	}
+
 	if (lv_is_cache_pool(lv) && !lv_is_used_cache_pool(lv)) {
 		if (!deactivate_lv(cmd, first_seg(lv)->metadata_lv) ||
 		    !deactivate_lv(cmd, seg_lv(first_seg(lv),0))) {
@@ -6787,7 +6837,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   uint64_t status,
 					   const char *layer_suffix)
 {
-	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
+	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig", "_vdata" };
 	int r;
 	char name[NAME_LEN];
 	struct dm_str_list *sl;
@@ -7386,6 +7436,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		    seg_is_mirror(lp) ||
 		    (seg_is_raid(lp) && !seg_is_raid0(lp)) ||
 		    seg_is_thin(lp) ||
+		    seg_is_vdo(lp) ||
 		    lp->snapshot) {
 			/*
 			 * FIXME: For thin pool add some code to allow delayed
@@ -7451,7 +7502,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_pool(lp))
 		status |= LVM_WRITE; /* Pool is always writable */
-	else if (seg_is_cache(lp) || seg_is_thin_volume(lp)) {
+	else if (seg_is_cache(lp) || seg_is_thin_volume(lp) || seg_is_vdo(lp)) {
 		/* Resolve pool volume */
 		if (!lp->pool_name) {
 			/* Should be already checked */
@@ -7619,6 +7670,16 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		status |= LVM_WRITE;
 		lp->zero = 1;
 		lp->wipe_signatures = 0;
+	} else if (seg_is_vdo_pool(lp)) {
+		if (!lp->virtual_extents)
+			log_verbose("Virtual size matching available free logical size in VDO pool.");
+
+		if (!(create_segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_STRIPED)))
+			return_NULL;
+
+		/* Must zero and format data area */
+		status |= LVM_WRITE;
+		lp->zero = 1;
 	}
 
 	if (!segtype_is_virtual(create_segtype) && !lp->approx_alloc &&
@@ -7648,7 +7709,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		log_debug_metadata("Setting read ahead sectors %u.", lv->read_ahead);
 	}
 
-	if (!segtype_is_pool(create_segtype) && lp->minor >= 0) {
+	if (!segtype_is_pool(create_segtype) &&
+	    !segtype_is_vdo_pool(create_segtype) &&
+	    lp->minor >= 0) {
 		lv->major = lp->major;
 		lv->minor = lp->minor;
 		lv->status |= FIXED_MINOR;
@@ -7670,7 +7733,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
 		       segtype_is_pool(create_segtype) ? lp->pool_metadata_extents : lp->region_size,
-		       segtype_is_thin_volume(create_segtype) ? lp->virtual_extents : lp->extents,
+		       (segtype_is_thin_volume(create_segtype) ||
+			segtype_is_vdo(create_segtype)) ? lp->virtual_extents : lp->extents,
 		       lp->pvh, lp->alloc, lp->approx_alloc)) {
 		unlink_lv_from_vg(lv); /* Keep VG consistent and remove LV without any segment */
 		return_NULL;
@@ -7686,6 +7750,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 
+	if (segtype_is_vdo(create_segtype) && pool_lv) {
+		if (!set_lv_segment_area_lv(first_seg(lv), 0, pool_lv, 0, LV_VDO_POOL))
+			return_NULL;
+	}
+
 	if (lv_is_cache_pool(lv)) {
 		if (!cache_set_params(first_seg(lv),
 				      lp->chunk_size,
@@ -7886,7 +7955,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	}
 
-	if (seg_is_cache(lp) || (origin_lv && lv_is_cache_pool(lv))) {
+	if (seg_is_vdo_pool(lp)) {
+		if (!convert_vdo_pool_lv(lv, &lp->vdo_params, &lp->virtual_extents)) {
+			stack;
+			goto deactivate_and_revert_new_lv;
+		}
+	} else if (seg_is_cache(lp) || (origin_lv && lv_is_cache_pool(lv))) {
 		/* Finish cache conversion magic */
 		if (origin_lv) {
 			/* Convert origin to cached LV */
@@ -8047,6 +8121,13 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			log_print_unless_silent("Logical volume %s is now cached.",
 						display_lvname(lv));
 			return lv;
+		} else if (seg_is_vdo(lp)) {
+			/* The VDO segment needs VDO pool which is layer above created striped data LV */
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_VDO_POOL)))
+				return_NULL;
+
+			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
+				return_NULL;
 		} else {
 			log_error(INTERNAL_ERROR "Creation of pool for unsupported segment type %s.",
 				  lp->segtype->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 501d0fa..4a9f2e0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -145,7 +145,12 @@
 #define LV_RESHAPE		UINT64_C(0x1000000000000000)    /* Ongoing reshape (number of stripes, stripesize or raid algorithm change):
 								   used as SEGTYPE_FLAG to prevent activation on old runtime */
 #define LV_RESHAPE_DATA_OFFSET	UINT64_C(0x2000000000000000)    /* LV reshape flag data offset (out of place reshaping) */
-/* Next unused flag:		UINT64_C(0x8000000000000000)    */
+
+
+#define LV_VDO			UINT64_C(0x0000000020000000)    /* LV - Internal user only */
+#define LV_VDO_POOL		UINT64_C(0x0000000040000000)    /* LV - Internal user only */
+#define LV_VDO_POOL_DATA	UINT64_C(0x8000000000000000)    /* LV - Internal user only */
+
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -251,6 +256,11 @@
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 #define lv_is_lockd_sanlock_lv(lv)	(((lv)->status & LOCKD_SANLOCK_LV) ? 1 : 0)
 
+#define lv_is_vdo(lv)		(((lv)->status & LV_VDO) ? 1 : 0)
+#define lv_is_vdo_pool(lv)	(((lv)->status & LV_VDO_POOL) ? 1 : 0)
+#define lv_is_vdo_pool_data(lv)	(((lv)->status & LV_VDO_POOL_DATA) ? 1 : 0)
+#define lv_is_vdo_type(lv)	(((lv)->status & (LV_VDO | LV_VDO_POOL | LV_VDO_POOL_DATA)) ? 1 : 0)
+
 #define lv_is_removed(lv)	(((lv)->status & LV_REMOVED) ? 1 : 0)
 
 /* Recognize component LV (matching lib/misc/lvm-string.c _lvname_has_reserved_component_string()) */
@@ -487,6 +497,10 @@ struct lv_segment {
 	const char *policy_name;		/* For cache_pool */
 	struct dm_config_node *policy_settings;	/* For cache_pool */
 	unsigned cleaner_policy;		/* For cache */
+
+	struct dm_vdo_target_params vdo_params;	/* For VDO-pool */
+	uint32_t vdo_pool_header_size;		/* For VDO-pool */
+	uint32_t vdo_pool_virtual_extents;	/* For VDO-pool */
 };
 
 #define seg_type(seg, s)	(seg)->areas[(s)].type
@@ -950,6 +964,7 @@ struct lvcreate_params {
 	uint32_t read_ahead; /* all */
 	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
+	struct dm_vdo_target_params vdo_params; /* vdo */
 
 	struct dm_list tags;	/* all */
 
@@ -1232,6 +1247,16 @@ int lv_cache_remove(struct logical_volume *cache_lv);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
+
+/* ++  metadata/vdo_manip.c */
+
+uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
+struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
+					   const struct dm_vdo_target_params *vtp,
+					   uint32_t *virtual_extents);
+int get_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy);
+/* --  metadata/vdo_manip.c */
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint64_t lv_type);
 const struct logical_volume *find_pvmove_lv_in_lv(const struct logical_volume *lv);
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 5484c23..6fdf075 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -69,6 +69,8 @@ struct dev_manager;
 
 #define SEG_STRIPED_TARGET	(1ULL << 39)
 #define SEG_LINEAR_TARGET	(1ULL << 40)
+#define SEG_VDO			(1ULL << 41)
+#define SEG_VDO_POOL		(1ULL << 42)
 
 #define SEG_UNKNOWN		(1ULL << 63)
 
@@ -83,6 +85,8 @@ struct dev_manager;
 #define SEG_TYPE_NAME_ERROR		"error"
 #define SEG_TYPE_NAME_FREE		"free"
 #define SEG_TYPE_NAME_ZERO		"zero"
+#define SEG_TYPE_NAME_VDO		"vdo"
+#define SEG_TYPE_NAME_VDO_POOL		"vdo-pool"
 #define SEG_TYPE_NAME_RAID		"raid"
 #define SEG_TYPE_NAME_RAID0		"raid0"
 #define SEG_TYPE_NAME_RAID0_META	"raid0_meta"
@@ -151,6 +155,8 @@ struct dev_manager;
 #define segtype_is_thin(segtype)	((segtype)->flags & (SEG_THIN_POOL|SEG_THIN_VOLUME) ? 1 : 0)
 #define segtype_is_thin_pool(segtype)	((segtype)->flags & SEG_THIN_POOL ? 1 : 0)
 #define segtype_is_thin_volume(segtype)	((segtype)->flags & SEG_THIN_VOLUME ? 1 : 0)
+#define segtype_is_vdo(segtype)		((segtype)->flags & SEG_VDO ? 1 : 0)
+#define segtype_is_vdo_pool(segtype)	((segtype)->flags & SEG_VDO_POOL ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 #define segtype_is_unknown(segtype)	((segtype)->flags & SEG_UNKNOWN ? 1 : 0)
 
@@ -202,6 +208,8 @@ struct dev_manager;
 #define seg_is_thin(seg)	segtype_is_thin((seg)->segtype)
 #define seg_is_thin_pool(seg)	segtype_is_thin_pool((seg)->segtype)
 #define seg_is_thin_volume(seg)	segtype_is_thin_volume((seg)->segtype)
+#define seg_is_vdo(seg)		segtype_is_vdo((seg)->segtype)
+#define seg_is_vdo_pool(seg)	segtype_is_vdo_pool((seg)->segtype)
 #define seg_is_virtual(seg)	segtype_is_virtual((seg)->segtype)
 #define seg_unknown(seg)	segtype_is_unknown((seg)->segtype)
 #define seg_can_split(seg)	segtype_can_split((seg)->segtype)
@@ -329,6 +337,10 @@ int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#ifdef VDO_INTERNAL
+int init_vdo_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+#endif
+
 #define CACHE_FEATURE_POLICY_MQ			(1U << 0)
 #define CACHE_FEATURE_POLICY_SMQ		(1U << 1)
 #define CACHE_FEATURE_METADATA2			(1U << 2)
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
new file mode 100644
index 0000000..451c8bd
--- /dev/null
+++ b/lib/metadata/vdo_manip.c
@@ -0,0 +1,269 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/display/display.h"
+#include "lib/metadata/segtype.h"
+#include "lib/activate/activate.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/misc/lvm-exec.h"
+
+
+/*
+ * Size of VDO virtual LV is adding header_size in front and back of device
+ * to avoid colission with blkid checks.
+ */
+static uint64_t _get_virtual_size(uint32_t extents, uint32_t extent_size,
+				  uint32_t header_size)
+{
+	return (uint64_t) extents * extent_size + 2 * header_size;
+}
+
+uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg)
+{
+	return _get_virtual_size(vdo_pool_seg->vdo_pool_virtual_extents,
+				 vdo_pool_seg->lv->vg->extent_size,
+				 vdo_pool_seg->vdo_pool_header_size);
+}
+
+/*
+ * Formats data LV for a use as a VDO pool LV.
+ *
+ * Calls tool 'vdoformat' on the already active volume.
+ */
+static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
+				    const struct dm_vdo_target_params *vtp,
+				    uint64_t *logical_size)
+{
+	char *dpath;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	struct pipe_data pdata;
+	FILE *f;
+	uint64_t lb;
+	unsigned slabbits;
+	int args = 1;
+	char buf_args[5][128];
+	char buf[256]; /* buffer for short disk header (64B) */
+	const char *argv[19] = { /* Max supported args */
+		find_config_tree_str_allow_empty(data_lv->vg->cmd, global_vdo_format_executable_CFG, NULL)
+	};
+
+	if (!(dpath = lv_path_dup(data_lv->vg->cmd->mem, data_lv))) {
+		log_error("Failed to build device path for VDO formating of data volume %s.",
+			  display_lvname(data_lv));
+		return 0;
+	}
+
+	if (*logical_size) {
+		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--logical-size=" FMTu64 "K",
+			       (*logical_size / 2)) < 0)
+			return_0;
+
+		argv[args] = buf_args[args];
+		args++;
+	}
+
+	slabbits = 31 - clz(vtp->slab_size_mb / DM_VDO_BLOCK_SIZE * 512);
+	log_debug("Slab size %s converted to %u bits.",
+		  display_size(data_lv->vg->cmd, vtp->slab_size_mb * UINT64_C(2 * 1024)), slabbits);
+	if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--slab-bits=%u", slabbits) < 0)
+		return_0;
+
+	argv[args] = buf_args[args];
+	args++;
+
+	if (vtp->check_point_frequency) {
+		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-checkpoint-frequency=%u",
+				vtp->check_point_frequency) < 0)
+			return_0;
+		argv[args] = buf_args[args];
+		args++;
+	}
+
+	/* Convert size to GiB units or one of these strings: 0.25, 0.50, 0.75 */
+	if (vtp->index_memory_size_mb >= 1024) {
+		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-memory-size=%u",
+				vtp->index_memory_size_mb / 1024) < 0)
+			return_0;
+	} else if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-memory-size=0.%u",
+			       (vtp->index_memory_size_mb < 512) ? 25 :
+			       (vtp->index_memory_size_mb < 768) ? 50 : 75) < 0)
+		   return_0;
+
+	argv[args] = buf_args[args];
+	args++;
+
+	if (vtp->use_sparse_index)  {
+		if (dm_snprintf(buf_args[args], sizeof(buf_args[0]), "--uds-sparse") < 0)
+			return_0;
+
+		argv[args] = buf_args[args];
+		args++;
+	}
+
+	/* Any other user opts add here */
+	if (!(cn = find_config_tree_array(data_lv->vg->cmd, global_vdo_format_options_CFG, NULL))) {
+		log_error(INTERNAL_ERROR "Unable to find configuration for vdoformat command options.");
+		return 0;
+	}
+
+	for (cv = cn->v; cv && args < 16; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Invalid string in config file: "
+				  "global/vdoformat_options.");
+			return 0;
+		}
+		if (cv->v.str[0])
+			argv[++args] = cv->v.str;
+	}
+
+	/* Only unused VDO data LV could be activated and wiped */
+	if (!dm_list_empty(&data_lv->segs_using_this_lv)) {
+		log_error(INTERNAL_ERROR "Failed to wipe logical VDO data for volume %s.",
+			  display_lvname(data_lv));
+		return 0;
+	}
+
+	argv[args] = dpath;
+
+	if (!(f = pipe_open(data_lv->vg->cmd, argv, 0, &pdata))) {
+		log_error("WARNING: Cannot read output from %s.", argv[0]);
+		return 0;
+	}
+
+	if (!*logical_size)
+		while (fgets(buf, sizeof(buf), f)) {
+			/* TODO: Watch out for locales */
+			if (sscanf(buf, "Logical blocks defaulted to " FMTu64 " blocks", &lb) == 1) {
+				*logical_size = lb * DM_VDO_BLOCK_SIZE;
+				log_verbose("Available VDO logical blocks " FMTu64 " (%s).",
+					    lb, display_size(data_lv->vg->cmd, *logical_size));
+				break;
+			} else
+				log_warn("WARNING: Cannot parse output '%s' from %s.", buf, argv[0]);
+		}
+
+	if (!pipe_close(&pdata)) {
+		log_error("Command %s failed.", argv[0]);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * convert_vdo_pool_lv
+ * @data_lv
+ * @vtp
+ * @virtual_extents
+ *
+ * Convert given data LV and its target parameters into a VDO LV with VDO pool.
+ *
+ * Returns: old data LV on success (passed data LV becomes VDO LV), NULL on failure
+ */
+struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
+					   const struct dm_vdo_target_params *vtp,
+					   uint32_t *virtual_extents)
+{
+	const uint64_t header_size = DEFAULT_VDO_POOL_HEADER_SIZE;
+	const uint32_t extent_size = data_lv->vg->extent_size;
+	struct cmd_context *cmd = data_lv->vg->cmd;
+	struct logical_volume *vdo_pool_lv = data_lv;
+	const struct segment_type *vdo_pool_segtype;
+	struct lv_segment *vdo_pool_seg;
+	uint64_t vdo_logical_size = 0;
+	uint64_t adjust;
+
+	if (!(vdo_pool_segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_VDO_POOL)))
+		return_NULL;
+
+	adjust = (*virtual_extents * (uint64_t) extent_size) % DM_VDO_BLOCK_SIZE;
+	if (adjust) {
+		*virtual_extents += (DM_VDO_BLOCK_SIZE - adjust) / extent_size;
+		log_print_unless_silent("Rounding size up to 4,00 KiB VDO logical extent boundary: %s.",
+					display_size(data_lv->vg->cmd, *virtual_extents * (uint64_t) extent_size));
+	}
+
+	if (*virtual_extents)
+		vdo_logical_size =
+			_get_virtual_size(*virtual_extents, extent_size, header_size);
+
+	if (!dm_vdo_validate_target_params(vtp, vdo_logical_size))
+		return_0;
+
+	/* Format data LV as VDO volume */
+	if (!_format_vdo_pool_data_lv(data_lv, vtp, &vdo_logical_size)) {
+		log_error("Cannot format VDO pool volume %s.", display_lvname(data_lv));
+		return NULL;
+	}
+
+	if (!deactivate_lv(data_lv->vg->cmd, data_lv)) {
+		log_error("Aborting. Manual intervention required.");
+		return NULL;
+	}
+
+	vdo_logical_size -= 2 * header_size;
+
+	if (vdo_logical_size < extent_size) {
+		if (!*virtual_extents)
+			/* User has not specified size and@least 1 extent is necessary */
+			log_error("Cannot create fully fitting VDO volume, "
+				  "--virtualsize has to be specified.");
+
+		log_error("Size %s for VDO volume cannot be smaller then extent size %s.",
+			  display_size(data_lv->vg->cmd, vdo_logical_size),
+			  display_size(data_lv->vg->cmd, extent_size));
+		return NULL;
+	}
+
+	*virtual_extents = vdo_logical_size / extent_size;
+
+	/* Move segments from existing data_lv into LV_vdata */
+	if (!(data_lv = insert_layer_for_lv(cmd, vdo_pool_lv, 0, "_vdata")))
+		return_NULL;
+
+	vdo_pool_seg = first_seg(vdo_pool_lv);
+	vdo_pool_seg->segtype = vdo_pool_segtype;
+	vdo_pool_seg->vdo_params = *vtp;
+	vdo_pool_seg->vdo_pool_header_size = DEFAULT_VDO_POOL_HEADER_SIZE;
+	vdo_pool_seg->vdo_pool_virtual_extents = *virtual_extents;
+
+	vdo_pool_lv->status |= LV_VDO_POOL;
+	data_lv->status |= LV_VDO_POOL_DATA;
+
+	return data_lv;
+}
+
+int get_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy)
+{
+	if (strcasecmp(policy, "sync") == 0)
+		*vwp = DM_VDO_WRITE_POLICY_SYNC;
+	else if (strcasecmp(policy, "async") == 0)
+		*vwp = DM_VDO_WRITE_POLICY_ASYNC;
+	else if (strcasecmp(policy, "auto") == 0)
+		*vwp = DM_VDO_WRITE_POLICY_AUTO;
+	else {
+		log_error("Unknown VDO write policy %s.", policy);
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 1e9af66..689a6b5 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -258,6 +258,8 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			lv_is_thin_pool(lv) ? "pool" :
 			lv_is_thin_pool_data(lv) ? "tdata" :
 			lv_is_thin_pool_metadata(lv) ? "tmeta" :
+			lv_is_vdo_pool(lv) ? "vpool" :
+			lv_is_vdo_pool_data(lv) ? "vdata" :
 			NULL;
 	}
 
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
new file mode 100644
index 0000000..a32ffcd
--- /dev/null
+++ b/lib/vdo/vdo.c
@@ -0,0 +1,484 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib/misc/lib.h"
+#include "lib/activate/activate.h"
+#include "lib/activate/targets.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/log/lvm-logging.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/metadata/segtype.h"
+#include "base/memory/zalloc.h"
+
+static unsigned _feature_mask;
+
+static int _bad_field(const char *field)
+{
+	log_error("Couldn't read '%s' for VDO segment.", field);
+	return 0;
+}
+
+static int _import_bool(const struct dm_config_node *n,
+			const char *name, bool *b)
+{
+	uint32_t t;
+
+	if (dm_config_has_node(n, name)) {
+		if (!dm_config_get_uint32(n, name, &t))
+			return _bad_field(name);
+
+		if (t) {
+			*b = true;
+			return 1;
+		}
+	}
+
+	*b = false;
+
+	return 1;
+}
+
+static void _print_yes_no(const char *name, bool value)
+{
+	log_print("  %s\t%s", name, value ? "yes" : "no");
+}
+
+/*
+ * VDO linear mapping
+ */
+static const char *_vdo_name(const struct lv_segment *seg)
+{
+	return SEG_TYPE_NAME_VDO;
+}
+
+static int _vdo_text_import(struct lv_segment *seg,
+			    const struct dm_config_node *n,
+			    struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	struct logical_volume *vdo_pool_lv;
+	const char *str;
+	uint32_t vdo_offset;
+
+	if (!dm_config_has_node(n, "vdo_pool") ||
+	    !(str = dm_config_find_str(n, "vdo_pool", NULL)))
+		return _bad_field("vdo_pool");
+	if (!(vdo_pool_lv = find_lv(seg->lv->vg, str))) {
+		log_error("Unknown VDO pool logical volume %s.", str);
+		return 0;
+	}
+
+	if (!dm_config_get_uint32(n, "vdo_offset", &vdo_offset))
+		return _bad_field("vdo_offset");
+
+	if (!set_lv_segment_area_lv(seg, 0, vdo_pool_lv, vdo_offset, LV_VDO_POOL))
+		return_0;
+
+	seg->lv->status |= LV_VDO;
+
+	return 1;
+}
+
+static int _vdo_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+
+	if (!seg_is_vdo(seg)) {
+		log_error(INTERNAL_ERROR "Passed segment is not VDO type.");
+		return 0;
+	}
+
+	outf(f, "vdo_pool = \"%s\"", seg_lv(seg, 0)->name);
+	outf(f, "vdo_offset = %u", seg_le(seg, 0));
+
+	return 1;
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _vdo_target_status_compatible(const char *type)
+{
+	return (strcmp(type, TARGET_NAME_LINEAR) == 0);
+}
+
+static int _vdo_add_target_line(struct dev_manager *dm,
+				struct dm_pool *mem __attribute__((unused)),
+				struct cmd_context *cmd,
+				void **target_state __attribute__((unused)),
+				struct lv_segment *seg,
+				const struct lv_activate_opts *laopts __attribute__((unused)),
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	char *vdo_pool_uuid;
+
+	if (!(vdo_pool_uuid = build_dm_uuid(mem, seg_lv(seg, 0), lv_layer(seg_lv(seg, 0)))))
+		return_0;
+
+	if (!add_linear_area_to_dtree(node, len, seg->lv->vg->extent_size,
+				      cmd->use_linear_target,
+				      seg->lv->vg->name, seg->lv->name))
+		return_0;
+
+	if (!dm_tree_node_add_target_area(node, NULL, vdo_pool_uuid,
+					  first_seg(seg_lv(seg, 0))->vdo_pool_header_size +
+					  seg->lv->vg->extent_size * (uint64_t)seg_le(seg, 0)))
+		return_0;
+
+	return 1;
+}
+
+#endif
+
+/*
+ *  VDO pool
+ */
+static const char *_vdo_pool_name(const struct lv_segment *seg)
+{
+	return SEG_TYPE_NAME_VDO_POOL;
+}
+
+/* reused as _vdo_text_import_area_count */
+static int _vdo_pool_text_import_area_count(const struct dm_config_node *sn __attribute__((unused)),
+					    uint32_t *area_count)
+{
+	*area_count = 1;
+
+	return 1;
+}
+
+static int _vdo_pool_text_import(struct lv_segment *seg,
+				 const struct dm_config_node *n,
+				 struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	struct dm_vdo_target_params *vtp = &seg->vdo_params;
+	struct logical_volume *data_lv;
+	const char *str;
+
+	if (!dm_config_has_node(n, "data") ||
+	    !(str = dm_config_find_str(n, "data", NULL)))
+		return _bad_field("data");
+	if (!(data_lv = find_lv(seg->lv->vg, str))) {
+		log_error("Unknown logical volume %s.", str);
+		return 0;
+	}
+
+	/*
+	 * TODO: we may avoid printing settings with FIXED default values
+	 *       so it would generate smaller metadata.
+	 */
+	if (!dm_config_get_uint32(n, "header_size", &seg->vdo_pool_header_size))
+		return _bad_field("header_size");
+
+	if (!dm_config_get_uint32(n, "virtual_extents", &seg->vdo_pool_virtual_extents))
+		return _bad_field("virtual_extents");
+
+	memset(vtp, 0, sizeof(*vtp));
+
+	if (!_import_bool(n, "use_compression", &vtp->use_compression))
+		return_0;
+
+	if (!_import_bool(n, "use_deduplication", &vtp->use_deduplication))
+		return_0;
+
+	if (!_import_bool(n, "emulate_512_sectors", &vtp->emulate_512_sectors))
+		return_0;
+
+	if (!dm_config_get_uint32(n, "block_map_cache_size_mb", &vtp->block_map_cache_size_mb))
+		return _bad_field("block_map_cache_size_mb");
+
+	if (!dm_config_get_uint32(n, "block_map_period", &vtp->block_map_period))
+		return _bad_field("block_map_period");
+
+	if (!_import_bool(n, "use_sparse_index", &vtp->use_sparse_index))
+		return_0;
+
+	if (!dm_config_get_uint32(n, "index_memory_size_mb", &vtp->index_memory_size_mb))
+		return _bad_field("index_memory_size_mb");
+
+	if (!_import_bool(n, "use_read_cache", &vtp->use_read_cache))
+		return_0;
+
+	if (!dm_config_get_uint32(n, "read_cache_size_mb", &vtp->read_cache_size_mb))
+		return _bad_field("read_cache_size_mb");
+
+	if (!dm_config_get_uint32(n, "slab_size_mb", &vtp->slab_size_mb))
+		return _bad_field("slab_size_mb");
+
+	if (!dm_config_get_uint32(n, "ack_threads", &vtp->ack_threads))
+		return _bad_field("ack_threads");
+
+	if (!dm_config_get_uint32(n, "bio_threads", &vtp->bio_threads))
+		return _bad_field("bio_threads");
+
+	if (!dm_config_get_uint32(n, "bio_rotation", &vtp->bio_rotation))
+		return _bad_field("bio_rotation");
+
+	if (!dm_config_get_uint32(n, "cpu_threads", &vtp->cpu_threads))
+		return _bad_field("cpu_threads");
+
+	if (!dm_config_get_uint32(n, "hash_zone_threads", &vtp->hash_zone_threads))
+		return _bad_field("hash_zone_threads");
+
+	if (!dm_config_get_uint32(n, "logical_threads", &vtp->logical_threads))
+		return _bad_field("logical_threads");
+
+	if (!dm_config_get_uint32(n, "physical_threads", &vtp->physical_threads))
+		return _bad_field("physical_threads");
+
+
+	if (!set_lv_segment_area_lv(seg, 0, data_lv, 0, LV_VDO_POOL_DATA))
+		return_0;
+
+	seg->lv->status |= LV_VDO_POOL;
+	lv_set_hidden(data_lv);
+
+	return 1;
+}
+
+static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	const struct dm_vdo_target_params *vtp = &seg->vdo_params;
+
+	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
+	outsize(f, seg->vdo_pool_header_size, "header_size = %u\t",
+		seg->vdo_pool_header_size);
+	outsize(f, seg->vdo_pool_virtual_extents * (uint64_t) seg->lv->vg->extent_size,
+		"virtual_extents = %u\t", seg->vdo_pool_virtual_extents);
+
+	outnl(f);
+
+	if (vtp->use_compression)
+		outf(f, "use_compression = 1");
+	if (vtp->use_deduplication)
+		outf(f, "use_deduplication = 1");
+	if (vtp->emulate_512_sectors)
+		outf(f, "emulate_512_sectors = 1");
+
+	outsize(f, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024),
+		"block_map_cache_size_mb = %u", vtp->block_map_cache_size_mb);
+	outf(f, "block_map_period = %u", vtp->block_map_period);
+
+	if (vtp->use_sparse_index)
+		outf(f, "use_sparse_index = 1");
+	// TODO - conditionally
+	outsize(f, vtp->index_memory_size_mb * UINT64_C(2 * 1024),
+		"index_memory_size_mb = %u", vtp->index_memory_size_mb);
+
+	if (vtp->use_read_cache)
+		outf(f, "use_read_cache = 1");
+	// TODO - conditionally
+	outsize(f, vtp->read_cache_size_mb * UINT64_C(2 * 1024),
+		"read_cache_size_mb = %u", vtp->read_cache_size_mb);
+	outsize(f, vtp->slab_size_mb * UINT64_C(2 * 1024),
+		"slab_size_mb = %u", vtp->slab_size_mb);
+	outf(f, "ack_threads = %u", (unsigned) vtp->ack_threads);
+	outf(f, "bio_threads = %u", (unsigned) vtp->bio_threads);
+	outf(f, "bio_rotation = %u", (unsigned) vtp->bio_rotation);
+	outf(f, "cpu_threads = %u", (unsigned) vtp->cpu_threads);
+	outf(f, "hash_zone_threads = %u", (unsigned) vtp->hash_zone_threads);
+	outf(f, "logical_threads = %u", (unsigned) vtp->logical_threads);
+	outf(f, "physical_threads = %u", (unsigned) vtp->physical_threads);
+
+	return 1;
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _vdo_pool_target_status_compatible(const char *type)
+{
+	return (strcmp(type, TARGET_NAME_VDO) == 0);
+}
+
+static int _vdo_pool_add_target_line(struct dev_manager *dm,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct cmd_context *cmd __attribute__((unused)),
+				     void **target_state __attribute__((unused)),
+				     struct lv_segment *seg,
+				     const struct lv_activate_opts *laopts __attribute__((unused)),
+				     struct dm_tree_node *node, uint64_t len,
+				     uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	char *data_uuid;
+
+	if (!seg_is_vdo_pool(seg)) {
+		log_error(INTERNAL_ERROR "Passed segment is not VDO pool.");
+		return 0;
+	}
+
+	if (!(data_uuid = build_dm_uuid(mem, seg_lv(seg, 0), lv_layer(seg_lv(seg, 0)))))
+		return_0;
+
+	/* VDO uses virtual size instead of its physical size */
+	if (!dm_tree_node_add_vdo_target(node, get_vdo_pool_virtual_size(seg),
+					 data_uuid, &seg->vdo_params))
+		return_0;
+
+	return 1;
+}
+
+static int _vdo_target_present(struct cmd_context *cmd,
+			       const struct lv_segment *seg __attribute__((unused)),
+			       unsigned *attributes __attribute__((unused)))
+{
+	/* List of features with their kernel target version */
+	static const struct feature {
+		uint32_t maj;
+		uint32_t min;
+		unsigned vdo_feature;
+		const char *feature;
+	} _features[] = {
+		{ 1, 1, 0, "" },
+		//{ 9, 9, VDO_FEATURE_RESIZE, "resize" },
+	};
+	//static const char _lvmconf[] = "global/vdo_disabled_features";
+	static int _vdo_checked = 0;
+	static int _vdo_present = 0;
+	static unsigned _vdo_attrs = 0;
+	uint32_t i, maj, min, patchlevel;
+	const struct segment_type *segtype;
+
+	if (!activation())
+		return 0;
+
+	if (!_vdo_checked) {
+		_vdo_checked = 1;
+
+		if (!target_present_version(cmd, TARGET_NAME_VDO, 0,
+					    &maj, &min, &patchlevel)) {
+			/* Try to load kmod VDO module */
+			if (!module_present(cmd, MODULE_NAME_VDO) ||
+			    !target_version(TARGET_NAME_VDO, &maj, &min, &patchlevel))
+				return_0;
+		}
+
+		if (maj < 6 || (maj == 6 && min < 2)) {
+			log_warn("WARNING: VDO target version %u.%u.%u is too old.",
+				 maj, min, patchlevel);
+			return 0;
+		}
+
+		/* If stripe target was already detected, reuse its result */
+		if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)) ||
+		    !segtype->ops->target_present || !segtype->ops->target_present(cmd, NULL, NULL)) {
+			/* Linear/Stripe targer is for mapping LVs on top of single VDO volume. */
+			if (!target_present(cmd, TARGET_NAME_LINEAR, 0) ||
+			    !target_present(cmd, TARGET_NAME_STRIPED, 0))
+				return 0;
+		}
+
+		_vdo_present = 1;
+		/* Prepare for adding supported features */
+		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
+			if ((maj > _features[i].maj) ||
+			    (maj == _features[i].maj && min >= _features[i].min))
+				_vdo_attrs |= _features[i].vdo_feature;
+			else
+				log_very_verbose("Target %s does not support %s.",
+						 TARGET_NAME_VDO,
+						 _features[i].feature);
+	}
+
+	if (attributes) {
+		*attributes = _vdo_attrs & _feature_mask;
+	}
+
+	return _vdo_present;
+}
+
+static int _vdo_modules_needed(struct dm_pool *mem,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, MODULE_NAME_VDO)) {
+		log_error("String list allocation failed for VDO module.");
+		return 0;
+	}
+
+	return 1;
+}
+#endif
+
+/* reused as _vdo_destroy */
+static void _vdo_pool_destroy(struct segment_type *segtype)
+{
+	free((void *)segtype->dso);
+	free((void *)segtype);
+}
+
+static struct segtype_handler _vdo_ops = {
+	.name = _vdo_name,
+	.text_import = _vdo_text_import,
+	.text_import_area_count = _vdo_pool_text_import_area_count,
+	.text_export = _vdo_text_export,
+
+#ifdef DEVMAPPER_SUPPORT
+	.target_status_compatible = _vdo_target_status_compatible,
+	.add_target_line = _vdo_add_target_line,
+	.target_present = _vdo_target_present,
+	.modules_needed = _vdo_modules_needed,
+#endif
+	.destroy = _vdo_pool_destroy,
+};
+
+static struct segtype_handler _vdo_pool_ops = {
+	.name = _vdo_pool_name,
+	.text_import = _vdo_pool_text_import,
+	.text_import_area_count = _vdo_pool_text_import_area_count,
+	.text_export = _vdo_pool_text_export,
+
+#ifdef DEVMAPPER_SUPPORT
+	.target_status_compatible = _vdo_pool_target_status_compatible,
+	.add_target_line = _vdo_pool_add_target_line,
+	.target_present = _vdo_target_present,
+	.modules_needed = _vdo_modules_needed,
+#endif
+	.destroy = _vdo_pool_destroy,
+};
+
+int init_vdo_segtypes(struct cmd_context *cmd,
+		      struct segtype_library *seglib)
+{
+	struct segment_type *segtype, *pool_segtype;
+
+	if (!(segtype = zalloc(sizeof(*segtype))) ||
+	    !(pool_segtype = zalloc(sizeof(*segtype)))) {
+		log_error("Failed to allocate memory for VDO segtypes.");
+		free(segtype);
+		return 0;
+	}
+
+	segtype->name = SEG_TYPE_NAME_VDO;
+	segtype->flags = SEG_VDO | SEG_VIRTUAL | SEG_ONLY_EXCLUSIVE;
+	segtype->ops = &_vdo_ops;
+
+	if (!lvm_register_segtype(seglib, segtype)) {
+		free(pool_segtype);
+		return_0;
+	}
+
+	pool_segtype->name = SEG_TYPE_NAME_VDO_POOL;
+	pool_segtype->flags = SEG_VDO_POOL | SEG_ONLY_EXCLUSIVE;
+	pool_segtype->ops = &_vdo_pool_ops;
+
+	if (!lvm_register_segtype(seglib, pool_segtype))
+		return_0;
+
+	log_very_verbose("Initialised segtypes: %s, %s.", segtype->name, pool_segtype->name);
+
+	/* Reset mask for recalc */
+	_feature_mask = 0;
+
+	return 1;
+}


