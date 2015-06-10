From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 10 Jun 2015 13:35:23 +0000 (UTC)
Subject: master - Add support for raid0/raid0_meta raid types
Message-ID: <20150610133523.7F55860757@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2c0a029fe5fcb8585039073ca49c023d237a300
Commit:        c2c0a029fe5fcb8585039073ca49c023d237a300
Parent:        fd29c7f3a171174dcd47eb8b23ff42a145cdacc6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 9 19:56:02 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 9 19:56:02 2015 +0200

Add support for raid0/raid0_meta raid types

Supports creation of raid types raid0 and raid0_meta
with 'lvcreate --type (raid0|raid0_meta) ...' based on
functionality available in dm-raid target version 1.0.7

The raid0 type provides access via the MD raid0
personality without metadata devices

The raid0_meta type provides access via the MD raid0
personality _with_ metadata devices, i.e. it reserves
space for rmeta devices which is e.g. useful for future
functional enhancements supporting conversions between
raid0 and raid4/5/6/10 to ensure metadata space
on raid0_meta creation.

Conversion between striped/raid0/raid0_meta
LVs with striped LVs being restricted to one
stripe zone (i.e. no varying stripes) is possible
with 'lvconvert --type (striped|raid0|raid0_meta) ...'

lvconvert-striped-raid0.sh provides various tests
---
 WHATS_NEW                        |    1 +
 daemons/lvmetad/Makefile.in      |    3 +-
 daemons/lvmpolld/Makefile.in     |    3 +-
 lib/activate/dev_manager.c       |   14 +-
 lib/cache/lvmetad.c              |    4 -
 lib/cache/lvmetad.h              |   12 +-
 lib/config/defaults.h            |    2 +
 lib/format_text/export.c         |    6 +-
 lib/metadata/lv.c                |    1 +
 lib/metadata/lv.h                |    4 +-
 lib/metadata/lv_manip.c          |  362 ++++++----
 lib/metadata/merge.c             |    2 +-
 lib/metadata/metadata-exported.h |   12 +-
 lib/metadata/raid_manip.c        | 1483 +++++++++++++++++++++++++++++++-------
 lib/metadata/segtype.h           |  133 +++-
 lib/raid/raid.c                  |  213 +++---
 lib/uuid/uuid.c                  |    2 +-
 libdm/libdm-deptree.c            |   70 ++-
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |   60 +-
 tools/lvcreate.c                 |   75 ++-
 21 files changed, 1843 insertions(+), 621 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bfcc094..db48233 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -8,6 +8,7 @@ Version 2.02.121 -
   Do not fail polling when poll LV not found (already finished or removed).
   Replace poll_get_copy_vg/lv fns with vg_read() and find_lv() in polldaemon.
   Close all device fds only in before sleep call in polldaemon.
+  Support for raid types raid0 and raid0_meta
 
 Version 2.02.120 - 15th May 2015
 ================================
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 765128c..f9b997e 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -39,7 +39,8 @@ CFLAGS += $(EXTRA_EXEC_CFLAGS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
+	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
 # TODO: No idea. No idea how to test either.
 #ifneq ("$(CFLOW_CMD)", "")
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 8ebbb90..55f3dad 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -38,7 +38,8 @@ CFLAGS += $(DAEMON_CFLAGS)
 
 lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
+	$(DL_LIBS) $(LVMLIBS) $(LIBS)
 
 install_lvmpolld: lvmpolld
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1171f4c..38d76c4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2134,6 +2134,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			    !_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
 				return_0;
 			if (seg_is_raid(seg) &&
+			    seg->meta_areas && seg_metalv(seg, s) &&
 			    !_add_lv_to_dtree(dm, dtree, seg_metalv(seg, s), 0))
 				return_0;
 		}
@@ -2303,9 +2304,15 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 					return_0;
 				continue;
 			}
-			if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s), NULL)))
-				return_0;
-			if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_metale(seg, s)))
+
+			if (seg->meta_areas && seg_metalv(seg, s)) {
+				if (!(dlid = build_dm_uuid(dm->mem, seg_metalv(seg, s), NULL)))
+					return_0;
+				if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_metale(seg, s)))
+					return_0;
+
+			/* One for metadata area */
+			} else if (!dm_tree_node_add_null_area(node, 0))
 				return_0;
 
 			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s), NULL)))
@@ -2632,6 +2639,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 					  laopts, NULL))
 			return_0;
 		if (seg_is_raid(seg) &&
+		    seg->meta_areas && seg_metalv(seg, s) &&
 		    !_add_new_lv_to_dtree(dm, dtree, seg_metalv(seg, s),
 					  laopts, NULL))
 			return_0;
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index dd1219b..73a382c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -46,10 +46,6 @@ void lvmetad_init(struct cmd_context *cmd)
 	if (!_lvmetad_use && !access(getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE, F_OK))
 		log_warn("WARNING: lvmetad is running but disabled."
 			 " Restart lvmetad before enabling it!");
-
-	if (_lvmetad_connected)
-		log_debug(INTERNAL_ERROR "Refreshing lvmetad global handle while connection with the daemon is active");
-
 	_lvmetad_cmd = cmd;
 }
 
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 395bc41..6769f76 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -29,7 +29,8 @@ typedef int (*activation_handler) (struct cmd_context *cmd,
 
 #ifdef LVMETAD_SUPPORT
 /*
- * Sets up a global handle for our process.
+ * Initialise the communication with lvmetad. Normally called by
+ * lvmcache_init. Sets up a global handle for our process.
  */
 void lvmetad_init(struct cmd_context *);
 
@@ -58,9 +59,7 @@ int lvmetad_socket_present(void);
 
 /*
  * Check whether lvmetad is active (where active means both that it is running
- * and that we have a working connection with it). It opens new connection
- * with lvmetad in the process when lvmetad is supposed to be used and the
- * connection is not open yet.
+ * and that we have a working connection with it).
  */
 int lvmetad_active(void);
 
@@ -71,9 +70,8 @@ int lvmetad_active(void);
 void lvmetad_connect_or_warn(void);
 
 /*
- * Drop connection to lvmetad. A subsequent lvmetad_connect_or_warn or
- * lvmetad_active will re-establish the connection (possibly at a
- * different socket path).
+ * Drop connection to lvmetad. A subsequent lvmetad_init() will re-establish
+ * the connection (possibly at a different socket path).
  */
 void lvmetad_disconnect(void);
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6793d01..3b6a877 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -60,7 +60,9 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+#define DEFAULT_RAID_MAX_IMAGES 64 /* limited by kernel failed devices bitfield in superblock (raid4/5/6 max 253) */
 #define DEFAULT_RAID_FAULT_POLICY "warn"
+#define DEFAULT_RAID_STRIPE_SIZE	(64 * 2)
 
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 018772e..b340fc8 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -590,14 +590,14 @@ int out_areas(struct formatter *f, const struct lv_segment *seg,
 
 			/* RAID devices are laid-out in metadata/data pairs */
 			if (!lv_is_raid_image(seg_lv(seg, s)) ||
-			    !lv_is_raid_metadata(seg_metalv(seg, s))) {
+			    (seg->meta_areas && seg_metalv(seg, s) && !lv_is_raid_metadata(seg_metalv(seg, s)))) {
 				log_error("RAID segment has non-RAID areas");
 				return 0;
 			}
 
 			outf(f, "\"%s\", \"%s\"%s",
-			     seg_metalv(seg, s)->name, seg_lv(seg, s)->name,
-			     (s == seg->area_count - 1) ? "" : ",");
+			     (seg->meta_areas && seg_metalv(seg, s)) ? seg_metalv(seg, s)->name : "-",
+			     seg_lv(seg, s)->name, (s == seg->area_count - 1) ? "" : ",");
 
 			break;
 		case AREA_UNASSIGNED:
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 10ce906..5329b91 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -533,6 +533,7 @@ int lv_raid_image_in_sync(const struct logical_volume *lv)
 
 	if ((seg = first_seg(lv)))
 		raid_seg = get_only_segment_using_this_lv(seg->lv);
+
 	if (!raid_seg) {
 		log_error("Failed to find RAID segment for %s", lv->name);
 		return 0;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 4475085..3031196 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -35,8 +35,8 @@ struct logical_volume {
 	int32_t major;
 	int32_t minor;
 
-	uint64_t size;		/* Sectors */
-	uint32_t le_count;
+	uint64_t size;		/* Sectors visible */
+	uint32_t le_count;	/* Logical extents visible */
 
 	uint32_t origin_count;
 	uint32_t external_count;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1251a5d..729ec78 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -38,9 +38,6 @@ typedef enum {
 	NEXT_AREA
 } area_use_t;
 
-/* FIXME: remove RAID_METADATA_AREA_LEN macro after defining 'raid_log_extents'*/
-#define RAID_METADATA_AREA_LEN 1
-
 /* FIXME These ended up getting used differently from first intended.  Refactor. */
 /* Only one of A_CONTIGUOUS_TO_LVSEG, A_CLING_TO_LVSEG, A_CLING_TO_ALLOCED may be set */
 #define A_CONTIGUOUS_TO_LVSEG	0x01	/* Must be contiguous to an existing segment */
@@ -115,6 +112,8 @@ enum {
 	LV_TYPE_DATA,
 	LV_TYPE_SPARE,
 	LV_TYPE_VIRTUAL,
+	LV_TYPE_RAID0,
+	LV_TYPE_RAID0_META,
 	LV_TYPE_RAID1,
 	LV_TYPE_RAID10,
 	LV_TYPE_RAID4,
@@ -159,6 +158,8 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_DATA] =				"data",
 	[LV_TYPE_SPARE] =				"spare",
 	[LV_TYPE_VIRTUAL] =				"virtual",
+	[LV_TYPE_RAID0] =				SEG_TYPE_NAME_RAID0,
+	[LV_TYPE_RAID0_META] =				SEG_TYPE_NAME_RAID0_META,
 	[LV_TYPE_RAID1] =				SEG_TYPE_NAME_RAID1,
 	[LV_TYPE_RAID10] =				SEG_TYPE_NAME_RAID10,
 	[LV_TYPE_RAID4] =				SEG_TYPE_NAME_RAID4,
@@ -776,7 +777,7 @@ int get_default_region_size(struct cmd_context *cmd)
 
 	if (region_size & (region_size - 1)) {
 		region_size = _round_down_pow2(region_size);
-		log_verbose("Reducing mirror region size to %u kiB (power of 2).",
+		log_verbose("Reducing region size to %u kiB (power of 2).",
 			    region_size / 2);
 	}
 
@@ -923,10 +924,13 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
 
+	if (seg_is_any_raid0(first_seg(lv)))
+		return DM_PERCENT_INVALID;
+
 	dm_list_iterate_items(seg, &lv->segments) {
 		denominator += seg->area_len;
 
-	/* FIXME Generalise name of 'extents_copied' field */
+		/* FIXME Generalise name of 'extents_copied' field */
 		if ((seg_is_raid(seg) || seg_is_mirrored(seg)) &&
 		    (seg->area_count > 1))
 			numerator += seg->extents_copied;
@@ -934,7 +938,7 @@ dm_percent_t copy_percent(const struct logical_volume *lv)
 			numerator += seg->area_len;
 	}
 
-	return denominator ? dm_make_percent( numerator, denominator ) : 100.0;
+	return denominator ? dm_make_percent(numerator, denominator ) : 100.0;
 }
 
 /*
@@ -971,6 +975,7 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	}
 
 	if (segtype_is_raid(segtype) &&
+	    !segtype_is_raid0(segtype) &&
 	    !(seg->meta_areas = dm_pool_zalloc(mem, areas_sz))) {
 		dm_pool_free(mem, seg); /* frees everything alloced since seg */
 		return_NULL;
@@ -1003,6 +1008,24 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	return seg;
 }
 
+/* Round up @extents to next stripe boundary for number of @stripes */
+static uint32_t _round_to_stripe_boundary(struct logical_volume *lv, uint32_t extents, uint32_t stripes, int extend)
+{
+	uint32_t rest;
+
+	if (!stripes)
+		return extents;
+
+	/* Round up extents to stripe divisable amount */
+	if ((rest = extents % stripes)) {
+		extents += extend ? stripes - rest : -rest;
+		log_print_unless_silent("Rounding up size to full stripe size %s",
+			  		display_size(lv->vg->cmd, extents * lv->vg->extent_size));
+	}
+
+	return extents;
+}
+
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 				      uint64_t status, uint32_t old_le_count)
 {
@@ -1033,6 +1056,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 						uint32_t area_reduction, int with_discard)
 {
 	struct lv_segment *cache_seg;
+	struct logical_volume *lv = seg_lv(seg, s);
 
 	if (seg_type(seg, s) == AREA_UNASSIGNED)
 		return 1;
@@ -1050,10 +1074,10 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
-	if (lv_is_mirror_image(seg_lv(seg, s)) ||
-	    lv_is_thin_pool_data(seg_lv(seg, s)) ||
-	    lv_is_cache_pool_data(seg_lv(seg, s))) {
-		if (!lv_reduce(seg_lv(seg, s), area_reduction))
+	if (lv_is_mirror_image(lv) ||
+	    lv_is_thin_pool_data(lv) ||
+	    lv_is_cache_pool_data(lv)) {
+		if (!lv_reduce(lv, area_reduction))
 			return_0; /* FIXME: any upper level reporting */
 		return 1;
 	}
@@ -1067,33 +1091,28 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 			return_0;
 	}
 
-	if (lv_is_raid_image(seg_lv(seg, s))) {
-		/*
-		 * FIXME: Use lv_reduce not lv_remove
-		 *  We use lv_remove for now, because I haven't figured out
-		 *  why lv_reduce won't remove the LV.
-		lv_reduce(seg_lv(seg, s), area_reduction);
-		*/
-		if (area_reduction != seg->area_len) {
-			log_error("Unable to reduce RAID LV - operation not implemented.");
-			return_0;
-		} else {
-			if (!lv_remove(seg_lv(seg, s))) {
-				log_error("Failed to remove RAID image %s",
-					  seg_lv(seg, s)->name);
-				return 0;
-			}
-		}
+	if (lv_is_raid_image(lv)) {
+		if (seg->meta_areas) {
+			uint32_t meta_area_reduction;
+			struct logical_volume *mlv;
+			struct volume_group *vg = lv->vg;
 
-		/* Remove metadata area if image has been removed */
-		if (area_reduction == seg->area_len) {
-			if (!lv_reduce(seg_metalv(seg, s),
-				       seg_metalv(seg, s)->le_count)) {
-				log_error("Failed to remove RAID meta-device %s",
-					  seg_metalv(seg, s)->name);
+			if (!(mlv = seg_metalv(seg, s)))
 				return 0;
-			}
+
+			meta_area_reduction = raid_rmeta_extents_delta(vg->cmd, lv->le_count, lv->le_count - area_reduction,
+								       seg->region_size, vg->extent_size);
+			if (lv->le_count - area_reduction == 0)
+				meta_area_reduction = mlv->le_count;
+
+			if (meta_area_reduction &&
+			    !lv_reduce(mlv, meta_area_reduction))
+				return_0; /* FIXME: any upper level reporting */
 		}
+
+		if (!lv_reduce(lv, area_reduction))
+ 			return_0; /* FIXME: any upper level reporting */
+
 		return 1;
 	}
 
@@ -1101,9 +1120,9 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		log_very_verbose("Remove %s:%" PRIu32 "[%" PRIu32 "] from "
 				 "the top of LV %s:%" PRIu32,
 				 seg->lv->name, seg->le, s,
-				 seg_lv(seg, s)->name, seg_le(seg, s));
+				 lv->name, seg_le(seg, s));
 
-		if (!remove_seg_from_segs_using_this_lv(seg_lv(seg, s), seg))
+		if (!remove_seg_from_segs_using_this_lv(lv, seg))
 			return_0;
 		seg_lv(seg, s) = NULL;
 		seg_le(seg, s) = 0;
@@ -1239,6 +1258,36 @@ static int _lv_segment_add_areas(struct logical_volume *lv,
 	return 1;
 }
 
+/* Return @area_len for @extents based on @seg's properties (e.g. striped, ...) */
+static uint32_t _area_len(struct lv_segment *seg, uint32_t extents, uint32_t *area_len)
+{
+	/* Caller must ensure exact divisibility */
+	if (seg_is_striped(seg) || seg_is_striped_raid(seg)) {
+		uint32_t data_devs = seg->area_count - seg->segtype->parity_devs;
+
+		if (seg_is_raid10(seg) &&
+		    data_devs > 1) {
+			if (data_devs % 2) {
+				log_error("raid10 data devices not divisible by 2");
+				return 0;
+			}
+
+			data_devs /= 2;
+		}
+
+		if (extents % data_devs) {
+			/* HM FIXME: message not right for raid10 */
+			log_error("Extents %" PRIu32 " not divisible by #stripes %" PRIu32, extents, data_devs);
+			return 0;
+		}
+
+		*area_len = extents / data_devs;
+	} else
+		*area_len = extents;
+
+	return 1;
+}
+
 /*
  * Reduce the size of an lv_segment.  New size can be zero.
  */
@@ -1246,24 +1295,16 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 {
 	uint32_t area_reduction, s;
 
-	/* Caller must ensure exact divisibility */
-	if (seg_is_striped(seg)) {
-		if (reduction % seg->area_count) {
-			log_error("Segment extent reduction %" PRIu32
-				  " not divisible by #stripes %" PRIu32,
-				  reduction, seg->area_count);
-			return 0;
-		}
-		area_reduction = (reduction / seg->area_count);
-	} else
-		area_reduction = reduction;
+	if (!_area_len(seg, reduction, &area_reduction))
+		return 0;
 
 	for (s = 0; s < seg->area_count; s++)
 		if (!release_and_discard_lv_segment_area(seg, s, area_reduction))
 			return_0;
 
-	seg->len -= reduction;
-	seg->area_len -= area_reduction;
+ 	seg->len -= reduction;
+	seg->lv->size -= reduction * seg->lv->vg->extent_size;
+	seg->area_len -= seg_is_striped(seg) ? area_reduction : reduction;
 
 	return 1;
 }
@@ -1271,19 +1312,27 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 /*
  * Entry point for all LV reductions in size.
  */
+static uint32_t _calc_area_multiple(const struct segment_type *segtype,
+				    const uint32_t area_count,
+				    const uint32_t stripes);
 static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 {
-	struct lv_segment *seg;
-	uint32_t count = extents;
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t count;
 	uint32_t reduction;
 	struct logical_volume *pool_lv;
 
+	if (seg_is_striped(seg) || seg_is_striped_raid(seg))
+		extents = _round_to_stripe_boundary(lv, extents, _calc_area_multiple(seg->segtype, seg->area_count, 0), 0);
+
 	if (lv_is_merging_origin(lv)) {
 		log_debug_metadata("Dropping snapshot merge of %s to removed origin %s.",
 				   find_snapshot(lv)->lv->name, lv->name);
 		clear_snapshot_merge(lv);
 	}
 
+	count = extents;
+
 	dm_list_iterate_back_items(seg, &lv->segments) {
 		if (!count)
 			break;
@@ -1385,7 +1434,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 	 * that suggest it is anything other than "error".
 	 */
 	/* FIXME Check for other flags that need removing */
-	lv->status &= ~(MIRROR|MIRRORED|PVMOVE|LOCKED);
+	lv->status &= ~(MIRROR|MIRRORED|RAID|RAID_IMAGE|RAID_META|PVMOVE|LOCKED);
 
 	/* FIXME Check for any attached LVs that will become orphans e.g. mirror logs */
 
@@ -1434,11 +1483,12 @@ struct alloc_handle {
 	struct dm_pool *mem;
 
 	alloc_policy_t alloc;		/* Overall policy */
-	int approx_alloc;                /* get as much as possible up to new_extents */
+	int approx_alloc;		/* get as much as possible up to new_extents */
 	uint32_t new_extents;		/* Number of new extents required */
 	uint32_t area_count;		/* Number of parallel areas */
-	uint32_t parity_count;   /* Adds to area_count, but not area_multiple */
+	uint32_t parity_count;		/* Adds to area_count, but not area_multiple */
 	uint32_t area_multiple;		/* seg->len = area_len * area_multiple */
+	uint32_t area_multiple_check;	/* Check area_multiple in _allocate(); needed for striped image additions */
 	uint32_t log_area_count;	/* Number of parallel logs */
 	uint32_t metadata_area_count;   /* Number of parallel metadata areas */
 	uint32_t log_len;		/* Length of log/metadata_area */
@@ -1483,29 +1533,28 @@ static uint32_t _calc_area_multiple(const struct segment_type *segtype,
 	if (segtype_is_striped(segtype))
 		return area_count;
 
-	/* Parity RAID (e.g. RAID 4/5/6) */
-	if (segtype_is_raid(segtype) && segtype->parity_devs) {
+	/*
+	 * RAID10 - only has 2-way mirror right now.
+	 *          If we are to move beyond 2-way RAID10, then
+	 *          the 'stripes' argument will always need to
+	 *          be given.
+	 */
+	if (segtype_is_raid10(segtype))
+		return stripes ?: area_count / 2;
+
+	/* RAID0 and parity RAID (e.g. RAID 4/5/6) */
+	if (segtype_is_striped_raid(segtype)) {
 		/*
 		 * As articulated in _alloc_init, we can tell by
 		 * the area_count whether a replacement drive is
 		 * being allocated; and if this is the case, then
 		 * there is no area_multiple that should be used.
 		 */
+
 		if (area_count <= segtype->parity_devs)
 			return 1;
-		return area_count - segtype->parity_devs;
-	}
 
-	/*
-	 * RAID10 - only has 2-way mirror right now.
-	 *          If we are to move beyond 2-way RAID10, then
-	 *          the 'stripes' argument will always need to
-	 *          be given.
-	 */
-	if (!strcmp(segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
-		if (!stripes)
-			return area_count / 2;
-		return stripes;
+		return area_count - segtype->parity_devs;
 	}
 
 	/* Mirrored stripes */
@@ -1557,7 +1606,7 @@ static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 {
 	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
 	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
-	uint32_t metadata_extents_needed = (ah->alloc_and_split_meta) ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
+	uint32_t metadata_extents_needed =ah->metadata_area_count * ah->log_len;
 	uint32_t total_extents_needed = area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 
@@ -1700,9 +1749,9 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	struct lv_segment *seg;
 
 	area_multiple = _calc_area_multiple(segtype, area_count, 0);
+	extents = aa[0].len * area_multiple;
 
-	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count,
-				     aa[0].len * area_multiple,
+	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
 				     status, stripe_size, NULL,
 				     area_count,
 				     aa[0].len, 0u, region_size, 0u, NULL))) {
@@ -1718,7 +1767,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 
 	extents = aa[0].len * area_multiple;
 	lv->le_count += extents;
-	lv->size += (uint64_t) extents *lv->vg->extent_size;
+	lv->size += (uint64_t) extents * lv->vg->extent_size;
 
 	return 1;
 }
@@ -1884,7 +1933,7 @@ static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 		*max_seg_len = remaining_seg_len;
 
 	area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, 0);
-	area_len = remaining_seg_len / area_multiple ? : 1;
+	area_len = remaining_seg_len / (area_multiple ?: 1);
 
 	/* For striped mirrors, all the areas are counted, through the mirror layer */
 	if (top_level_area_index == -1)
@@ -2921,9 +2970,10 @@ static int _allocate(struct alloc_handle *ah,
 		return 1;
 	}
 
-        if (ah->area_multiple > 1 &&
+        if (ah->area_multiple_check &&
+	    ah->area_multiple > 1 &&
             (ah->new_extents - alloc_state.allocated) % ah->area_multiple) {
-		log_error("Number of extents requested (%d) needs to be divisible by %d.",
+		log_error("Number of extents requested (%u) needs to be divisible by %d.",
 			  ah->new_extents - alloc_state.allocated,
 			  ah->area_multiple);
 		return 0;
@@ -3075,6 +3125,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					struct dm_pool *mem,
 					const struct segment_type *segtype,
 					alloc_policy_t alloc, int approx_alloc,
+					int extend,
 					uint32_t existing_extents,
 					uint32_t new_extents,
 					uint32_t mirrors,
@@ -3102,10 +3153,9 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	size = sizeof(*ah);
 
 	/*
-	 * It is a requirement that RAID 4/5/6 are created with a number of
-	 * stripes that is greater than the number of parity devices.  (e.g
-	 * RAID4/5 must have at least 2 stripes and RAID6 must have at least
-	 * 3.)  It is also a constraint that, when replacing individual devices
+	 * It is a requirement that RAID 4/5/6 have to have at least 2 stripes.
+	 *
+	 * It is also a constraint that, when replacing individual devices
 	 * in a RAID 4/5/6 array, no more devices can be replaced than
 	 * there are parity devices.  (Otherwise, there would not be enough
 	 * redundancy to maintain the array.)  Understanding these two
@@ -3116,12 +3166,18 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * account for the extra parity devices because the array already
 	 * exists and they only want replacement drives.
 	 */
-	parity_count = (area_count <= segtype->parity_devs) ? 0 : segtype->parity_devs;
+
+	parity_count = extend ? segtype->parity_devs : 0;
 	alloc_count = area_count + parity_count;
-	if (segtype_is_raid(segtype) && metadata_area_count)
+	if (segtype_is_raid(segtype) && metadata_area_count) {
+		if (metadata_area_count != alloc_count) {
+			log_error(INTERNAL_ERROR "Bad metadata_area_count");
+			return 0;
+		}
+
 		/* RAID has a meta area for each device */
 		alloc_count *= 2;
-	else
+	} else
 		/* mirrors specify their exact log count */
 		alloc_count += metadata_area_count;
 
@@ -3159,30 +3215,29 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * is calculated from.  So, we must pass in the total count to get
 	 * a correct area_multiple.
 	 */
-	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
+	ah->area_multiple = _calc_area_multiple(segtype, area_count + segtype->parity_devs, stripes);
+
+	ah->area_multiple_check = extend ? 1 : 0;
+
 	//FIXME: s/mirror_logs_separate/metadata_separate/ so it can be used by others?
 	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG, NULL);
 
-	if (mirrors || stripes)
-		total_extents = new_extents;
-	else
-		total_extents = 0;
+	total_extents = new_extents;
 
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
-			if (metadata_area_count != area_count)
-				log_error(INTERNAL_ERROR
-					  "Bad metadata_area_count");
-			ah->metadata_area_count = area_count;
-			ah->alloc_and_split_meta = 1;
-
-			ah->log_len = RAID_METADATA_AREA_LEN;
-
+			ah->log_len = raid_rmeta_extents_delta(cmd,
+							       existing_extents / ah->area_multiple,
+							       (existing_extents + new_extents) / ah->area_multiple,
+							       region_size, extent_size);
+			ah->metadata_area_count = metadata_area_count;
+			ah->alloc_and_split_meta = !!ah->log_len;
 			/*
 			 * We need 'log_len' extents for each
 			 * RAID device's metadata_area
 			 */
-			total_extents += (ah->log_len * ah->area_multiple);
+			total_extents += ah->log_len * (ah->area_multiple > 1 ?
+							area_count / (segtype_is_raid10(segtype) ? mirrors : 1) : 1);
 		} else {
 			ah->log_area_count = 0;
 			ah->log_len = 0;
@@ -3261,6 +3316,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 				      alloc_policy_t alloc, int approx_alloc,
 				      struct dm_list *parallel_areas)
 {
+	int extend = lv ? 1 : 0;
 	struct alloc_handle *ah;
 
 	if (segtype_is_virtual(segtype)) {
@@ -3286,7 +3342,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 	if (alloc >= ALLOC_INHERIT)
 		alloc = vg->alloc;
 
-	if (!(ah = _alloc_init(vg->cmd, vg->vgmem, segtype, alloc, approx_alloc,
+	if (!(ah = _alloc_init(vg->cmd, vg->vgmem, segtype, alloc, approx_alloc, extend,
 			       lv ? lv->le_count : 0, extents, mirrors, stripes, log_count,
 			       vg->extent_size, region_size,
 			       parallel_areas)))
@@ -3704,7 +3760,7 @@ static int _lv_insert_empty_sublvs(struct logical_volume *lv,
 			return_0;
 
 		/* Metadata LVs for raid */
-		if (segtype_is_raid(segtype)) {
+		if (segtype_is_raid(segtype) && !segtype_is_raid0(segtype)) {
 			if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
 				return_0;
 		} else
@@ -3732,23 +3788,23 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 {
 	const struct segment_type *segtype;
 	struct logical_volume *sub_lv, *meta_lv;
-	struct lv_segment *seg;
+	struct lv_segment *seg = first_seg(lv);
 	uint32_t fa, s;
-	int clear_metadata = 0;
+	int clear_metadata = lv->le_count ? 0 : 1;
 
-	segtype = get_segtype_from_string(lv->vg->cmd, "striped");
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+		return_0;
 
 	/*
 	 * The component devices of a "striped" LV all go in the same
 	 * LV.  However, RAID has an LV for each device - making the
 	 * 'stripes' and 'stripe_size' parameters meaningless.
 	 */
-	if (seg_is_raid(first_seg(lv))) {
+	if (seg_is_raid(seg)) {
 		stripes = 1;
 		stripe_size = 0;
 	}
 
-	seg = first_seg(lv);
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
 			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents,
@@ -3767,13 +3823,10 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		}
 
 		/* Extend metadata LVs only on initial creation */
-		if (seg_is_raid(seg) && !lv->le_count) {
-			if (!seg->meta_areas) {
-				log_error("No meta_areas for RAID type");
-				return 0;
-			}
-
-			meta_lv = seg_metalv(seg, s);
+		if (seg_is_raid(seg) &&
+		    seg->meta_areas &&
+		    ah->log_len &&
+		    (meta_lv = seg_metalv(seg, s))) {
 			if (!lv_add_segment(ah, fa + seg->area_count, 1,
 					    meta_lv, segtype, 0,
 					    meta_lv->status, 0)) {
@@ -3781,14 +3834,16 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 					  meta_lv->name, lv->name);
 				return 0;
 			}
-			lv_set_visible(meta_lv);
-			clear_metadata = 1;
+
+			if (clear_metadata)
+				lv_set_visible(meta_lv);
 		}
 
 		fa += stripes;
 	}
 
-	if (clear_metadata) {
+	if (clear_metadata &&
+	    seg->meta_areas) {
 		/*
 		 * We must clear the metadata areas upon creation.
 		 */
@@ -3833,20 +3888,33 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 		}
 	}
 
+	seg = first_seg(lv);
 	seg->area_len += extents;
 	seg->len += extents;
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents * lv->vg->extent_size;
 
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+
 	/*
 	 * The MD bitmap is limited to being able to track 2^21 regions.
 	 * The region_size must be adjusted to meet that criteria.
 	 */
-	while (seg_is_raid(seg) && (seg->region_size < (lv->size / (1 << 21)))) {
-		seg->region_size *= 2;
-		log_very_verbose("Adjusting RAID region_size from %uS to %uS"
-				 " to support large LV size",
-				 seg->region_size/2, seg->region_size);
+	if (seg_is_striped_raid(seg) && !seg_is_any_raid0(seg)) {
+		int adjusted = 0;
+
+		/* HM FIXME: make it larger than just to suit the LV size */
+		while (seg->region_size < (lv->size / (1 << 21))) {
+			seg->region_size *= 2;
+			adjusted = 1;
+		}
+
+		if (adjusted)
+			log_very_verbose("Adjusting RAID region_size from %uS to %uS"
+				 	" to support large LV size",
+				 	seg->region_size/2, seg->region_size);
 	}
 
 	return 1;
@@ -3874,7 +3942,6 @@ int lv_extend(struct logical_volume *lv,
 	struct alloc_handle *ah;
 	uint32_t sub_lv_count;
 	uint32_t old_extents;
-	uint32_t new_extents;	/* Total logical size after extension. */
 
 	log_very_verbose("Adding segment of type %s to LV %s.", segtype->name, lv->name);
 
@@ -3887,19 +3954,24 @@ int lv_extend(struct logical_volume *lv,
 		 */
 		/* FIXME Support striped metadata pool */
 		log_count = 1;
-	} else if (segtype_is_raid(segtype) && !lv->le_count)
-		log_count = mirrors * stripes;
+	} else if (segtype_is_striped(segtype) || segtype_is_striped_raid(segtype)) {
+		extents = _round_to_stripe_boundary(lv, extents, stripes, 1);
+
+		/* Make sure metadata LVs are being extended as well */
+		if (!segtype_is_striped(segtype) && !segtype_is_raid0(segtype))
+			log_count = (mirrors ?: 1) * stripes + segtype->parity_devs;
+
+	}
+ 
 	/* FIXME log_count should be 1 for mirrors */
+	if (segtype_is_mirror(segtype))
+		log_count = 1;
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    log_count, region_size, extents,
 				    allocatable_pvs, alloc, approx_alloc, NULL)))
 		return_0;
 
-	new_extents = ah->new_extents;
-	if (segtype_is_raid(segtype))
-		new_extents -= ah->log_len * ah->area_multiple;
-
 	if (segtype_is_pool(segtype)) {
 		if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
 			stack;
@@ -3928,7 +4000,7 @@ int lv_extend(struct logical_volume *lv,
 			goto out;
 		}
 
-		if (!(r = _lv_extend_layered_lv(ah, lv, new_extents - lv->le_count, 0,
+		if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
 						stripes, stripe_size)))
 			goto_out;
 
@@ -4116,7 +4188,7 @@ static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
 				return_0;
 		}
 
-		if (!seg_is_raid(seg))
+		if (!seg_is_raid(seg) || !seg->meta_areas)
 			continue;
 
 		/* RAID has meta_areas */
@@ -4781,7 +4853,10 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			return 0;
 		}
 
-		if (!strcmp(mirr_seg->segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
+		if (!strcmp(mirr_seg->segtype->name, _lv_type_names[LV_TYPE_RAID0])) {
+			lp->stripes = mirr_seg->area_count;
+			lp->stripe_size = mirr_seg->stripe_size;
+		} else if (!strcmp(mirr_seg->segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
 			/* FIXME Warn if command line values are being overridden? */
 			lp->stripes = mirr_seg->area_count / seg_mirrors;
 			lp->stripe_size = mirr_seg->stripe_size;
@@ -4791,9 +4866,10 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			/* FIXME We will need to support resize for metadata LV as well,
 			 *       and data LV could be any type (i.e. mirror)) */
 			dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments : &lv->segments) {
-				/* Allow through "striped" and RAID 4/5/6/10 */
+				/* Allow through "striped" and RAID 0/4/5/6/10 */
 				if (!seg_is_striped(seg) &&
 				    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
+				    strcmp(seg->segtype->name, _lv_type_names[LV_TYPE_RAID0]) &&
 				    strcmp(seg->segtype->name, _lv_type_names[LV_TYPE_RAID10]))
 					continue;
 	
@@ -5122,7 +5198,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 				log_error("Filesystem check failed.");
 				return NULL;
 			}
-			/* some filesystems supports online resize */
+			/* some filesystems support online resize */
 		}
 
 		/* FIXME forks here */
@@ -5497,8 +5573,8 @@ struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 			return_NULL;
 
 		current_le = spvs->le + spvs->len;
-		raid_multiple = (seg->segtype->parity_devs) ?
-			seg->area_count - seg->segtype->parity_devs : 1;
+		raid_multiple = (seg_is_mirror(seg) || seg_is_raid1(seg)) ? 1 :
+				 seg->area_count - seg->segtype->parity_devs;
 	} while ((current_le * raid_multiple) < lv->le_count);
 
 	if (create_single_list) {
@@ -7034,14 +7110,16 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		/* FIXME This will not pass cluster lock! */
-		init_mirror_in_sync(lp->nosync);
+		if (!seg_is_any_raid0(lp)) {
+			/* FIXME: this will not pass cluster lock! */
+			init_mirror_in_sync(lp->nosync);
 
-		if (lp->nosync) {
-			log_warn("WARNING: New %s won't be synchronised. "
-				 "Don't read what you didn't write!",
-				 lp->segtype->name);
-			status |= LV_NOTSYNCED;
+			if (lp->nosync) {
+				log_warn("WARNING: New %s won't be synchronised. "
+					 "Don't read what you didn't write!",
+				 	  lp->segtype->name);
+				status |= LV_NOTSYNCED;
+			}
 		}
 
 		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
@@ -7208,8 +7286,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			goto revert_new_lv;
 		}
 	} else if (seg_is_raid(lp)) {
-		first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
-		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
+		if (!seg_is_any_raid0(first_seg(lv))) {
+			first_seg(lv)->min_recovery_rate = lp->min_recovery_rate;
+			first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
+		}
 	} else if (seg_is_thin_pool(lp)) {
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 7fd5a07..2b1c42d 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -412,7 +412,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				continue;
 			if (lv == seg_lv(seg, s))
 				seg_found++;
-			if (seg_is_raid(seg) && (lv == seg_metalv(seg, s)))
+			if (seg_is_raid(seg) && seg->meta_areas && (lv == seg_metalv(seg, s)))
 				seg_found++;
 		}
 		if (seg_is_replicator_dev(seg)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0e52153..9ed411a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1109,6 +1109,9 @@ struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
 /* --  metadata/replicator_manip.c */
 
 /* ++  metadata/raid_manip.c */
+uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
+				  uint32_t rimage_extents_cur, uint32_t rimage_extents_new,
+				  uint32_t region_size, uint32_t extent_size);
 int lv_is_raid_with_tracking(const struct logical_volume *lv);
 uint32_t lv_raid_image_count(const struct logical_volume *lv);
 int lv_raid_change_image_count(struct logical_volume *lv,
@@ -1118,8 +1121,13 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    struct dm_list *splittable_pvs);
 int lv_raid_merge(struct logical_volume *lv);
-int lv_raid_reshape(struct logical_volume *lv,
-		    const struct segment_type *new_segtype);
+int lv_raid_convert(struct logical_volume *lv,
+		    const struct segment_type *new_segtype,
+		    int yes, int force,
+		    const unsigned image_count,
+		    const unsigned stripes,
+		    const unsigned new_stripe_size,
+		    struct dm_list *allocate_pvs);
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 64cfb3f..aa3e250 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -22,6 +22,14 @@
 #include "lv_alloc.h"
 #include "lvm-string.h"
 
+#define	ARRAY_SIZE(a) (sizeof(a) / sizeof(*a))
+
+/* Return data images count for @total_rimages depending on @seg's type */
+static uint32_t _data_rimages_count(const struct lv_segment *seg, const uint32_t total_rimages)
+{
+	return total_rimages - seg->segtype->parity_devs;
+}
+
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
@@ -75,6 +83,26 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 }
 
 /*
+ * Deactivate and remove the LVs on @removal_lvs list from @vg
+ *
+ * Returns 1 on success or 0 on failure
+ */
+static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
+{
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, removal_lvs) {
+		if (!deactivate_lv(vg->cmd, lvl->lv))
+			return_0;
+
+		if (!lv_remove(lvl->lv))
+			return_0;
+	}
+
+	return 1;
+}
+
+/*
  * _raid_in_sync
  * @lv
  *
@@ -87,6 +115,10 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 static int _raid_in_sync(struct logical_volume *lv)
 {
 	dm_percent_t sync_percent;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg_is_striped(seg) || seg_is_any_raid0(seg))
+		return 1;
 
 	if (!lv_raid_percent(lv, &sync_percent)) {
 		log_error("Unable to determine sync status of %s/%s.",
@@ -249,6 +281,24 @@ static int _clear_lvs(struct dm_list *lv_list)
 	return 1;
 }
 
+/* HM
+ *
+ * Check for maximum supported raid devices imposed by the kernel MD
+ * maximum device limits _and_ dm-raid superblock bitfield constraints
+ *
+ * Returns 1 on success or 0 on failure
+ */
+static int _check_max_raid_devices(uint32_t image_count)
+{
+	if (image_count > DEFAULT_RAID_MAX_IMAGES) {
+		log_error("Unable to handle arrays with more than %u devices",
+			  DEFAULT_RAID_MAX_IMAGES);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * _shift_and_rename_image_components
  * @seg: Top-level RAID segment
@@ -361,277 +411,565 @@ static char *_generate_raid_name(struct logical_volume *lv,
 
 	return name;
 }
+
 /*
- * Create an LV of specified type.  Set visible after creation.
- * This function does not make metadata changes.
+ * Eliminate the extracted LVs on @removal_lvs from @vg incl. vg write, commit and backup 
  */
-static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
-						     const char *alt_base_name,
-						     struct alloc_handle *ah, uint32_t first_area,
-						     uint64_t type)
+static int _eliminate_extracted_lvs(struct volume_group *vg, struct dm_list *removal_lvs)
 {
-	uint64_t status;
-	char img_name[NAME_LEN];
-	const char *type_suffix;
-	struct logical_volume *tmp_lv;
-	const struct segment_type *segtype;
+	if (!removal_lvs || dm_list_empty(removal_lvs))
+		return 1;
 
-	if (!ah) {
-		log_error(INTERNAL_ERROR
-			  "Stand-alone %s area allocation not implemented",
-			  (type == RAID_META) ? "metadata" : "data");
-		return 0;
-	}
+	sync_local_dev_names(vg->cmd);
 
-	switch (type) {
-	case RAID_META:
-		type_suffix = "rmeta";
-		break;
-	case RAID_IMAGE:
-		type_suffix = "rimage";
-		break;
-	default:
-		log_error(INTERNAL_ERROR
-			  "Bad type provided to _alloc_raid_component.");
+	if (!_deactivate_and_remove_lvs(vg, removal_lvs))
 		return 0;
-	}
 
-	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
-			(alt_base_name) ? : lv->name, type_suffix) < 0)
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	status = LVM_READ | LVM_WRITE | LV_REBUILD | type;
-	if (!(tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg))) {
-		log_error("Failed to allocate new raid component, %s.", img_name);
-		return 0;
+	if (!backup(vg))
+		log_error("Backup of VG %s failed after removal of image component LVs", vg->name);
+
+	return 1;
+}
+
+/*
+ * _extract_image_component
+ * @seg
+ * @idx:  The index in the areas array to remove
+ * @data: != 0 to extract data dev / 0 extract metadata_dev
+ * @extracted_lv:  The displaced metadata/data LV
+ */
+static int _extract_image_component(struct lv_segment *seg,
+		uint64_t type, uint32_t idx,
+		struct logical_volume **extracted_lv)
+{
+	struct logical_volume *lv;
+
+	switch (type) {
+		case RAID_META:
+			lv = seg_metalv(seg, idx);
+			seg_metalv(seg, idx) = NULL;
+			seg_metatype(seg, idx) = AREA_UNASSIGNED;
+			break;
+		case RAID_IMAGE:
+			lv = seg_lv(seg, idx);
+			seg_lv(seg, idx) = NULL;
+			seg_type(seg, idx) = AREA_UNASSIGNED;
+			break;
+		default:
+			log_error(INTERNAL_ERROR "Bad type provided to %s.", __func__);
+			return 0;
 	}
 
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+	if (!lv)
+		return 0;
+
+	log_very_verbose("Extracting image component %s from %s", lv->name, lvseg_name(seg));
+	lv->status &= ~(type | RAID);
+	lv_set_visible(lv);
+
+	/* release lv areas */
+	if (!remove_seg_from_segs_using_this_lv(lv, seg))
 		return_0;
 
-	if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
-		log_error("Failed to add segment to LV, %s", img_name);
-		return 0;
-	}
+	if (!(lv->name = _generate_raid_name(lv, "extracted", -1)))
+		return_0;
 
-	lv_set_visible(tmp_lv);
+	if (!replace_lv_with_error_segment(lv))
+		return_0;
 
-	return tmp_lv;
+	*extracted_lv = lv;
+
+	return 1;
 }
 
-static int _alloc_image_components(struct logical_volume *lv,
-				   struct dm_list *pvs, uint32_t count,
-				   struct dm_list *new_meta_lvs,
-				   struct dm_list *new_data_lvs)
+/* Remove sublvs fo @type from @lv starting at @idx and put them on @removal_lvs */
+static int _extract_image_component_list(struct lv_segment *seg,
+					 uint64_t type, uint32_t idx,
+					 struct dm_list *removal_lvs)
 {
 	uint32_t s;
-	uint32_t region_size;
-	uint32_t extents;
-	struct lv_segment *seg = first_seg(lv);
-	const struct segment_type *segtype;
-	struct alloc_handle *ah;
-	struct dm_list *parallel_areas;
+	unsigned i;
 	struct lv_list *lvl_array;
 
-	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
-					sizeof(*lvl_array) * count * 2)))
-		return_0;
+	if (idx >= seg->area_count) {
+		log_error(INTERNAL_ERROR "area index too large for segment");
+		return 0;
+	}
 
-	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
+	if (!(lvl_array = dm_pool_alloc(seg_lv(seg, 0)->vg->vgmem, sizeof(*lvl_array) * (seg->area_count - idx))))
 		return_0;
 
-	if (seg_is_linear(seg))
-		region_size = get_default_region_size(lv->vg->cmd);
+	for (i = 0, s = idx; s < seg->area_count; s++) {
+		if (!_extract_image_component(seg, type, s, &lvl_array[i].lv))
+			return 0;
+
+		dm_list_add(removal_lvs, &lvl_array[i].list);
+		i++;
+	}
+
+	if (type == RAID_IMAGE)
+		seg->areas = NULL;
 	else
-		region_size = seg->region_size;
+		seg->meta_areas = NULL;
 
-	if (seg_is_raid(seg))
-		segtype = seg->segtype;
-	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
-		return_0;
+	return 1;
+}
 
-	/*
-	 * The number of extents is based on the RAID type.  For RAID1,
-	 * each of the rimages is the same size - 'le_count'.  However
-	 * for RAID 4/5/6, the stripes add together (NOT including the parity
-	 * devices) to equal 'le_count'.  Thus, when we are allocating
-	 * individual devies, we must specify how large the individual device
-	 * is along with the number we want ('count').
-	 */
-	extents = (segtype->parity_devs) ?
-		(lv->le_count / (seg->area_count - segtype->parity_devs)) :
-		lv->le_count;
+/* Add new @lvs to @lv at @area_offset */
+static int _add_image_component_list(struct lv_segment *seg, int delete_from_list,
+				     uint64_t lv_flags, struct dm_list *lvs, uint32_t area_offset)
+{
+	uint32_t s = area_offset;
+	struct lv_list *lvl, *tmp;
 
-	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
-				    region_size, extents, pvs,
-				    lv->alloc, 0, parallel_areas)))
-		return_0;
+	dm_list_iterate_items_safe(lvl, tmp, lvs) {
+		if (delete_from_list)
+			dm_list_del(&lvl->list);
 
-	for (s = 0; s < count; ++s) {
-		/*
-		 * The allocation areas are grouped together.  First
-		 * come the rimage allocated areas, then come the metadata
-		 * allocated areas.  Thus, the metadata areas are pulled
-		 * from 's + count'.
-		 */
-		if (!(lvl_array[s + count].lv =
-		      _alloc_image_component(lv, NULL, ah, s + count, RAID_META))) {
-			alloc_destroy(ah);
-			return_0;
-		}
-		dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
+		if (lv_flags & VISIBLE_LV)
+			lv_set_visible(lvl->lv);
+		else
+			lv_set_hidden(lvl->lv);
 
-		if (!(lvl_array[s].lv =
-		      _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE))) {
-			alloc_destroy(ah);
-			return_0;
+		if (lv_flags & LV_REBUILD)
+			lvl->lv->status |= LV_REBUILD;
+		else
+			lvl->lv->status &= ~LV_REBUILD;
+
+		if (!set_lv_segment_area_lv(seg, s++, lvl->lv, 0 /* le */,
+					lvl->lv->status)) {
+			log_error("Failed to add sublv %s", lvl->lv->name);
+			return 0;
 		}
-		dm_list_add(new_data_lvs, &(lvl_array[s].list));
 	}
 
-	alloc_destroy(ah);
-
 	return 1;
 }
 
+/* Calculate absolute amount of metadata device extens based on @rimage_extents, @region_size and @extens_size */
+static uint32_t _raid_rmeta_extents(struct cmd_context *cmd,
+		uint32_t rimage_extents, uint32_t region_size, uint32_t extent_size)
+{
+	uint64_t bytes, regions, sectors;
+
+	region_size = region_size ?: get_default_region_size(cmd);
+	regions = rimage_extents * extent_size / region_size;
+
+	/* raid and bitmap superblocks + region bytes */
+	bytes = 2 * 4096 + dm_div_up(regions, 8);
+	sectors = dm_div_up(bytes, 512);
+
+	return dm_div_up(sectors, extent_size);
+}
+
+/*
+ * Returns raid metadata device size _change_ in extents, algorithm from dm-raid ("raid" target) kernel code.
+ */
+uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
+		uint32_t rimage_extents_cur, uint32_t rimage_extents_new,
+		uint32_t region_size, uint32_t extent_size)
+{
+	uint32_t rmeta_extents_cur = _raid_rmeta_extents(cmd, rimage_extents_cur, region_size, extent_size);
+	uint32_t rmeta_extents_new = _raid_rmeta_extents(cmd, rimage_extents_new, region_size, extent_size);
+
+	/* Need minimum size on LV creation */
+	if (!rimage_extents_cur)
+		return rmeta_extents_new;
+
+	/* Need current size on LV deletion */
+	if (!rimage_extents_new)
+		return rmeta_extents_cur;
+
+	if (rmeta_extents_new == rmeta_extents_cur)
+		return 0;
+
+	/* Extending/reducing... */
+	return rmeta_extents_new > rmeta_extents_cur ?
+		rmeta_extents_new - rmeta_extents_cur :
+		rmeta_extents_cur - rmeta_extents_new;
+}
+
+
 /*
  * _alloc_rmeta_for_lv
  * @lv
  *
- * Allocate a RAID metadata device for the given LV (which is or will
+ * Allocate  RAID metadata device for the given LV (which is or will
  * be the associated RAID data device).  The new metadata device must
  * be allocated from the same PV(s) as the data device.
  */
+static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
+						     const char *alt_base_name,
+						     struct alloc_handle *ah, uint32_t first_area,
+						     uint64_t type);
 static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 			       struct logical_volume **meta_lv)
 {
+	int r = 1;
+	char *p;
 	struct dm_list allocatable_pvs;
 	struct alloc_handle *ah;
 	struct lv_segment *seg = first_seg(data_lv);
-	char *p, base_name[NAME_LEN];
 
 	dm_list_init(&allocatable_pvs);
 
 	if (!seg_is_linear(seg)) {
 		log_error(INTERNAL_ERROR "Unable to allocate RAID metadata "
-			  "area for non-linear LV, %s", data_lv->name);
+				"area for non-linear LV, %s", data_lv->name);
 		return 0;
 	}
 
-	(void) dm_strncpy(base_name, data_lv->name, sizeof(base_name));
-	if ((p = strstr(base_name, "_mimage_")))
+	if ((p = strstr(data_lv->name, "_mimage_")) ||
+	    (p = strstr(data_lv->name, "_rimage_")))
 		*p = '\0';
 
 	if (!get_pv_list_for_lv(data_lv->vg->cmd->mem,
 				data_lv, &allocatable_pvs)) {
-		log_error("Failed to build list of PVs for %s/%s",
-			  data_lv->vg->name, data_lv->name);
+		log_error("Failed to build list of PVs for %s", display_lvname(data_lv));
 		return 0;
 	}
 
-	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
-				    seg->region_size,
-				    1 /*RAID_METADATA_AREA_LEN*/,
-				    &allocatable_pvs, data_lv->alloc, 0, NULL)))
+	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype,
+					0, 1, 0,
+					seg->region_size,
+					_raid_rmeta_extents(data_lv->vg->cmd, data_lv->le_count,
+							    seg->region_size, data_lv->vg->extent_size),
+					&allocatable_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
-	if (!(*meta_lv = _alloc_image_component(data_lv, base_name, ah, 0, RAID_META))) {
-		alloc_destroy(ah);
-		return_0;
-	}
+	if (!(*meta_lv = _alloc_image_component(data_lv, data_lv->name, ah, 0, RAID_META)))
+		r = 0;
+
+	if (p)
+		*p = '_';
 
 	alloc_destroy(ah);
 
+	return r;
+}
+
+/*
+ * Allocate metadata devs for all @new_data_devs and link them to list @new_meta_lvs
+ */
+static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
+		struct dm_list *new_data_lvs,
+		struct dm_list *new_meta_lvs)
+{
+	uint32_t a = 0, raid_devs = 0;
+	struct dm_list *l;
+	struct lv_list *lvl, *lvl_array;
+
+	dm_list_iterate(l, new_data_lvs)
+		raid_devs++;
+
+	if (!raid_devs)
+		return 0;
+
+	if (!(lvl_array = dm_pool_zalloc(lv->vg->vgmem, raid_devs * sizeof(*lvl_array))))
+		return 0;
+
+	dm_list_iterate_items(lvl, new_data_lvs) {
+		log_debug_metadata("Allocating new metadata LV for %s",
+				lvl->lv->name);
+		if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv)) {
+			log_error("Failed to allocate metadata LV for %s in %s",
+					lvl->lv->name, lv->vg->name);
+			return 0;
+		}
+
+		dm_list_add(new_meta_lvs, &lvl_array[a].list);
+		a++;
+	}
+
 	return 1;
 }
 
-static int _raid_add_images(struct logical_volume *lv,
-			    uint32_t new_count, struct dm_list *pvs)
+/*
+ * Allocate metadata devs for all data devs of an LV
+ */
+static int _alloc_rmeta_devs_for_lv(struct logical_volume *lv, struct dm_list *meta_lvs)
 {
-	int rebuild_flag_cleared = 0;
 	uint32_t s;
-	uint32_t old_count = lv_raid_image_count(lv);
-	uint32_t count = new_count - old_count;
-	uint64_t status_mask = -1;
+	struct lv_list *lvl_array;
+	struct dm_list data_lvs;
 	struct lv_segment *seg = first_seg(lv);
-	struct dm_list meta_lvs, data_lvs;
-	struct lv_list *lvl;
-	struct lv_segment_area *new_areas;
 
-	if (lv->status & LV_NOTSYNCED) {
-		log_error("Can't add image to out-of-sync RAID LV:"
-			  " use 'lvchange --resync' first.");
+	dm_list_init(&data_lvs);
+
+	if (seg->meta_areas) {
+		log_error(INTERNAL_ERROR "Metadata LVs exists in %s", display_lvname(lv));
 		return 0;
 	}
 
-	if (!_raid_in_sync(lv)) {
-		log_error("Can't add image to RAID LV that"
-			  " is still initializing.");
+	if (!(seg->meta_areas = dm_pool_zalloc(lv->vg->vgmem,
+					seg->area_count * sizeof(*seg->meta_areas))))
 		return 0;
-	}
 
-	if (!archive(lv->vg))
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))
 		return_0;
 
-	dm_list_init(&meta_lvs); /* For image addition */
-	dm_list_init(&data_lvs); /* For image addition */
+	for (s = 0; s < seg->area_count; s++) {
+		lvl_array[s].lv = seg_lv(seg, s);
+		dm_list_add(&data_lvs, &lvl_array[s].list);
+	}
 
-	/*
-	 * If the segtype is linear, then we must allocate a metadata
-	 * LV to accompany it.
-	 */
-	if (seg_is_linear(seg)) {
-		/* A complete resync will be done, no need to mark each sub-lv */
-		status_mask = ~(LV_REBUILD);
+	if (!_alloc_rmeta_devs_for_rimage_devs(lv, &data_lvs, meta_lvs)) {
+		log_error("Failed to allocate metadata LVs for %s", lv->name);
+		return 0;
+	}
 
-		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
-			log_error("Memory allocation failed");
-			return 0;
-		}
+	return 1;
+}
 
-		if (!_alloc_rmeta_for_lv(lv, &lvl->lv))
-			return_0;
+/*
+ * Create an LV of specified type.  Set visible after creation.
+ * This function does not make metadata changes.
+ */
+static struct logical_volume *_alloc_image_component(struct logical_volume *lv, const char *alt_base_name,
+						     struct alloc_handle *ah, uint32_t first_area,
+						     uint64_t type)
+{
+	uint64_t status = RAID | LVM_READ | LVM_WRITE | type;
+	char img_name[NAME_LEN];
+	const char *type_suffix;
+	struct logical_volume *tmp_lv;
+	const struct segment_type *segtype;
 
-		dm_list_add(&meta_lvs, &lvl->list);
-	} else if (!seg_is_raid(seg)) {
-		log_error("Unable to add RAID images to %s of segment type %s",
-			  lv->name, lvseg_name(seg));
-		return 0;
+	switch (type) {
+		case RAID_META:
+			type_suffix = "rmeta";
+			break;
+		case RAID_IMAGE:
+			type_suffix = "rimage";
+			status |= LV_REBUILD;
+			break;
+		default:
+			log_error(INTERNAL_ERROR "Bad type provided to %s.", __func__);
+			return 0;
 	}
 
-	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs))
+	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
+				alt_base_name ?: lv->name, type_suffix) < 0)
 		return_0;
 
-	/*
-	 * If linear, we must correct data LV names.  They are off-by-one
-	 * because the linear volume hasn't taken its proper name of "_rimage_0"
-	 * yet.  This action must be done before '_clear_lvs' because it
-	 * commits the LVM metadata before clearing the LVs.
-	 */
-	if (seg_is_linear(seg)) {
-		struct dm_list *l;
-		struct lv_list *lvl_tmp;
 
-		dm_list_iterate(l, &data_lvs) {
-			if (l == dm_list_last(&data_lvs)) {
-				lvl = dm_list_item(l, struct lv_list);
-				if (!(lvl->lv->name = _generate_raid_name(lv, "rimage", count)))
-					return_0;
-				continue;
-			}
-			lvl = dm_list_item(l, struct lv_list);
-			lvl_tmp = dm_list_item(l->n, struct lv_list);
-			lvl->lv->name = lvl_tmp->lv->name;
-		}
+	if (!(tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg))) {
+		log_error("Failed to allocate new raid component, %s.", img_name);
+		return 0;
 	}
 
-	/* Metadata LVs must be cleared before being added to the array */
-	if (!_clear_lvs(&meta_lvs))
-		goto fail;
+	/* If no allocation requested, leave it to the empty LV (needed for striped -> raid0 takeover) */
+	if (ah) {
+		if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+			return_0;
 
-	if (seg_is_linear(seg)) {
-		first_seg(lv)->status |= RAID_IMAGE;
-		if (!insert_layer_for_lv(lv->vg->cmd, lv,
+		if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
+			log_error("Failed to add segment to LV, %s", img_name);
+			return 0;
+		}
+
+		first_seg(tmp_lv)->status |= SEG_RAID;
+	}
+
+	lv_set_visible(tmp_lv);
+
+	return tmp_lv;
+}
+
+/*
+ * Create @count new image component pairs for @lv and return them in
+ * @new_meta_lvs and @new_data_lvs allocating space if @allocate is set.
+ *
+ * Use @pvs list for allocation if set, else just create empty image LVs.
+ */
+static int _alloc_image_components(struct logical_volume *lv,
+				   struct dm_list *pvs, uint32_t count,
+				   struct dm_list *meta_lvs,
+				   struct dm_list *data_lvs)
+{
+	int r = 0;
+	uint32_t s, extents;
+	struct lv_segment *seg = first_seg(lv);
+	const struct segment_type *segtype;
+	struct alloc_handle *ah;
+	struct dm_list *parallel_areas;
+	struct lv_list *lvl_array;
+
+	if (!meta_lvs && !data_lvs)
+		return 0;
+
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * count * sizeof(*lvl_array))))
+		return_0;
+
+	/* If this is an image addition to an existing raid set, use its type... */
+	if (seg_is_raid(seg))
+		segtype = seg->segtype;
+
+	/* .. if not, set it to raid1 */
+	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
+		return_0;
+
+	/*
+	 * The number of extents is based on the RAID type.  For RAID1/10,
+	 * each of the rimages is the same size - 'le_count'.  However
+	 * for RAID 0/4/5/6, the stripes add together (NOT including the parity
+	 * devices) to equal 'le_count'.  Thus, when we are allocating
+	 * individual devices, we must specify how large the individual device
+	 * is along with the number we want ('count').
+	 */
+	if (pvs) {
+		uint32_t stripes, mirrors, metadata_area_count = count;
+
+		if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
+			return_0;
+
+
+		/* Amount of extents for the rimage device(s) */
+		if (segtype_is_striped_raid(seg->segtype)) {
+			stripes = count;
+			mirrors = 1;
+			extents = count * (lv->le_count / _data_rimages_count(seg, seg->area_count));
+
+		} else {
+			stripes = 1;
+			mirrors = count;
+			extents = lv->le_count;
+		}
+
+		if (!(ah = allocate_extents(lv->vg, NULL, segtype,
+						stripes, mirrors, metadata_area_count,
+						seg->region_size, extents,
+						pvs, lv->alloc, 0, parallel_areas)))
+			return_0;
+
+	} else
+		ah = NULL;
+
+	for (s = 0; s < count; s++) {
+		/*
+		 * The allocation areas are grouped together.  First
+		 * come the rimage allocated areas, then come the metadata
+		 * allocated areas.  Thus, the metadata areas are pulled
+		 * from 's + count'.
+		 */
+
+		/*
+		 * If the segtype is raid0, we may avoid allocating metadata LVs
+		 * to accompany the data LVs by not passing in @meta_lvs
+		 */
+		if (meta_lvs) {
+			if (!(lvl_array[s + count].lv = _alloc_image_component(lv, NULL, ah, s + count, RAID_META)))
+				goto_bad;
+
+			dm_list_add(meta_lvs, &(lvl_array[s + count].list));
+		}
+
+		if (data_lvs) {
+			if (!(lvl_array[s].lv = _alloc_image_component(lv, NULL, ah, s, RAID_IMAGE)))
+				goto_bad;
+
+			dm_list_add(data_lvs, &(lvl_array[s].list));
+		}
+	}
+
+	r =  1;
+bad:
+	if (ah)
+		alloc_destroy(ah);
+
+	return r;
+}
+
+static int _raid_add_images(struct logical_volume *lv,
+			    uint32_t new_count, struct dm_list *pvs)
+{
+	int rebuild_flag_cleared = 0;
+	uint32_t s;
+	uint32_t old_count = lv_raid_image_count(lv);
+	uint32_t count = new_count - old_count;
+	uint64_t status_mask = -1;
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list meta_lvs, data_lvs;
+	struct lv_list *lvl;
+	struct lv_segment_area *new_areas;
+
+	if (lv->status & LV_NOTSYNCED) {
+		log_error("Can't add image to out-of-sync RAID LV:"
+			  " use 'lvchange --resync' first.");
+		return 0;
+	}
+
+	if (!_raid_in_sync(lv)) {
+		log_error("Can't add image to RAID LV that"
+			  " is still initializing.");
+		return 0;
+	}
+
+	if (!archive(lv->vg))
+		return_0;
+
+	dm_list_init(&meta_lvs); /* For image addition */
+	dm_list_init(&data_lvs); /* For image addition */
+
+	/*
+	 * If the segtype is linear, then we must allocate a metadata
+	 * LV to accompany it.
+	 */
+	if (seg_is_linear(seg)) {
+		/* A complete resync will be done, no need to mark each sub-lv */
+		status_mask = ~(LV_REBUILD);
+
+		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
+			log_error("Memory allocation failed");
+			return 0;
+		}
+
+		if (!_alloc_rmeta_for_lv(lv, &lvl->lv))
+			return_0;
+
+		dm_list_add(&meta_lvs, &lvl->list);
+	} else if (!seg_is_raid(seg)) {
+		log_error("Unable to add RAID images to %s of segment type %s",
+			  lv->name, lvseg_name(seg));
+		return 0;
+	}
+
+	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs))
+		return_0;
+
+	/*
+	 * If linear, we must correct data LV names.  They are off-by-one
+	 * because the linear volume hasn't taken its proper name of "_rimage_0"
+	 * yet.  This action must be done before '_clear_lvs' because it
+	 * commits the LVM metadata before clearing the LVs.
+	 */
+	if (seg_is_linear(seg)) {
+		struct dm_list *l;
+		struct lv_list *lvl_tmp;
+
+		dm_list_iterate(l, &data_lvs) {
+			if (l == dm_list_last(&data_lvs)) {
+				lvl = dm_list_item(l, struct lv_list);
+				if (!(lvl->lv->name = _generate_raid_name(lv, "rimage", count)))
+					return_0;
+				continue;
+			}
+			lvl = dm_list_item(l, struct lv_list);
+			lvl_tmp = dm_list_item(l->n, struct lv_list);
+			lvl->lv->name = lvl_tmp->lv->name;
+		}
+	}
+
+	/* Metadata LVs must be cleared before being added to the array */
+	if (!_clear_lvs(&meta_lvs))
+		goto fail;
+
+	if (seg_is_linear(seg)) {
+		first_seg(lv)->status |= RAID_IMAGE;
+		if (!insert_layer_for_lv(lv->vg->cmd, lv,
 					 RAID | LVM_READ | LVM_WRITE,
 					 "_rimage_0"))
 			return_0;
@@ -1069,6 +1407,41 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 	return _raid_add_images(lv, new_count, pvs);
 }
 
+/*
+ * Add/remove metadata areas to/from raid0
+ *
+ * Update metadata and reload mappings if @update_and_reload
+ */
+static int _alloc_and_add_rmeta_devs_for_lv(struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list meta_lvs;
+
+	dm_list_init(&meta_lvs);
+
+	log_debug_metadata("Allocating metadata LVs for %s", display_lvname(lv));
+	if (!_alloc_rmeta_devs_for_lv(lv, &meta_lvs)) {
+		log_error("Failed to allocate metadata LVs for %s", display_lvname(lv));
+		return_0;
+	}
+
+	/* Metadata LVs must be cleared before being added to the array */
+	log_debug_metadata("Clearing newly allocated metadata LVs for %s", display_lvname(lv));
+	if (!_clear_lvs(&meta_lvs)) {
+		log_error("Failed to initialize metadata LVs for %s", display_lvname(lv));
+		return_0;
+	}
+
+	/* Set segment areas for metadata sub_lvs */
+	log_debug_metadata("Adding newly allocated metadata LVs to %s", display_lvname(lv));
+	if (!_add_image_component_list(seg, 1, 0, &meta_lvs, 0)) {
+		log_error("Failed to add newly allocated metadata LVs to %s", display_lvname(lv));
+		return_0;
+	}
+
+	return 1;
+}
+
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs)
 {
@@ -1342,50 +1715,61 @@ int lv_raid_merge(struct logical_volume *image_lv)
 	return 1;
 }
 
-static int _convert_mirror_to_raid1(struct logical_volume *lv,
-				    const struct segment_type *new_segtype)
+/*
+ * Rename all data sub LVs of @lv to mirror
+ * or raid name depending on @direction
+ */
+enum mirror_raid_conv { mirror_to_raid1 = 0, raid1_to_mirror };
+static int _rename_data_lvs(struct logical_volume *lv, enum mirror_raid_conv direction)
 {
 	uint32_t s;
+	char *p;
 	struct lv_segment *seg = first_seg(lv);
-	struct lv_list lvl_array[seg->area_count], *lvl;
-	struct dm_list meta_lvs;
-	struct lv_segment_area *meta_areas;
-	char *new_name;
+	static struct {
+		char type_char;
+		uint64_t set_flag;
+		uint64_t reset_flag;
+	} conv[] = {
+		{ 'r', RAID_IMAGE  , MIRROR_IMAGE },
+		{ 'm', MIRROR_IMAGE, RAID_IMAGE }
+	};
 
-	dm_list_init(&meta_lvs);
+	for (s = 0; s < seg->area_count; ++s) {
+		struct logical_volume *dlv = seg_lv(seg, s);
 
-	if (!_raid_in_sync(lv)) {
-		log_error("Unable to convert %s/%s while it is not in-sync",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
+		if (!((p = strstr(dlv->name, "_mimage_")) ||
+		      (p = strstr(dlv->name, "_rimage_")))) {
+			log_error(INTERNAL_ERROR "name lags image part");
+			return 0;
+		}
 
-	if (!(meta_areas = dm_pool_zalloc(lv->vg->vgmem,
-					  lv_mirror_count(lv) * sizeof(*meta_areas)))) {
-		log_error("Failed to allocate meta areas memory.");
-		return 0;
+		*(p+1) = conv[direction].type_char;
+		log_debug_metadata("data lv renamed to %s", dlv->name);
+
+		dlv->status &= ~conv[direction].reset_flag;
+		dlv->status |= conv[direction].set_flag;
 	}
 
-	if (!archive(lv->vg))
-		return_0;
+	return 1;
+}
 
-	for (s = 0; s < seg->area_count; s++) {
-		log_debug_metadata("Allocating new metadata LV for %s",
-				   seg_lv(seg, s)->name);
-		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv))) {
-			log_error("Failed to allocate metadata LV for %s in %s",
-				  seg_lv(seg, s)->name, lv->name);
-			return 0;
-		}
-		dm_list_add(&meta_lvs, &(lvl_array[s].list));
-	}
+/*
+ * Convert @lv with "mirror" mapping to "raid1".
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int _convert_mirror_to_raid1(struct logical_volume *lv,
+				    const struct segment_type *new_segtype,
+				    int update_and_reload)
+{
+	struct lv_segment *seg = first_seg(lv);
 
-	log_debug_metadata("Clearing newly allocated metadata LVs");
-	if (!_clear_lvs(&meta_lvs)) {
-		log_error("Failed to initialize metadata LVs");
+	if (!seg_is_mirrored(seg)) {
+		log_error(INTERNAL_ERROR "mirror conversion supported only");
 		return 0;
 	}
 
+	/* Remove any mirror log */
 	if (seg->log_lv) {
 		log_debug_metadata("Removing mirror log, %s", seg->log_lv->name);
 		if (!remove_mirror_log(lv->vg->cmd, lv, NULL, 0)) {
@@ -1394,85 +1778,674 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		}
 	}
 
-	seg->meta_areas = meta_areas;
-	s = 0;
+	/* Allocate metadata devs for all mimage ones (writes+commits metadata) */
+	if (!_alloc_and_add_rmeta_devs_for_lv(lv))
+		return 0;
 
-	dm_list_iterate_items(lvl, &meta_lvs) {
-		log_debug_metadata("Adding %s to %s", lvl->lv->name, lv->name);
+	/* Rename all data sub lvs for "*_rimage_*" to "*_mimage_*" */
+	if (!_rename_data_lvs(lv, mirror_to_raid1))
+		return 0;
 
-		/* Images are known to be in-sync */
-		lvl->lv->status &= ~LV_REBUILD;
-		first_seg(lvl->lv)->status &= ~LV_REBUILD;
-		lv_set_hidden(lvl->lv);
+	init_mirror_in_sync(1);
 
-		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
-					    lvl->lv->status)) {
-			log_error("Failed to add %s to %s",
-				  lvl->lv->name, lv->name);
+	log_debug_metadata("Setting new segtype and status of %s", display_lvname(lv));
+	seg->segtype = new_segtype;
+	lv->status &= ~(MIRROR | MIRRORED);
+	lv->status |= RAID;
+	seg->status |= RAID;
+
+	return update_and_reload ? lv_update_and_reload(lv) : 1;
+}
+
+/* Begin: striped -> raid0 conversion */
+/*
+ *
+ * Helper: add/remove metadata areas to/from raid0
+ *
+ * Update metadata and reload mappings if @update_and_reload
+ */
+static int _raid0_add_or_remove_metadata_lvs(struct logical_volume *lv,
+					     int update_and_reload,
+					     struct dm_list *removal_lvs)
+{
+	const char *raid_type;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (seg->meta_areas) {
+		log_debug_metadata("Extracting metadata LVs");
+		if (!removal_lvs) {
+			log_error(INTERNAL_ERROR "Called with NULL removal LVs list");
 			return 0;
 		}
-		s++;
+
+		if (!_extract_image_component_list(seg, RAID_META, 0, removal_lvs)) {
+			log_error(INTERNAL_ERROR "Failed to extract metadata LVs");
+			return 0;
+		}
+
+		seg->meta_areas = NULL;
+		raid_type = SEG_TYPE_NAME_RAID0;
+
+	} else {
+		if (!_alloc_and_add_rmeta_devs_for_lv(lv))
+			return 0;
+
+		raid_type = SEG_TYPE_NAME_RAID0_META;
 	}
 
-	for (s = 0; s < seg->area_count; ++s) {
-		if (!(new_name = _generate_raid_name(lv, "rimage", s)))
+	if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, raid_type)))
+		return_0;
+
+	if (update_and_reload) {
+		if (!lv_update_and_reload_origin(lv))
 			return_0;
-		log_debug_metadata("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
-		seg_lv(seg, s)->name = new_name;
-		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
-		seg_lv(seg, s)->status |= RAID_IMAGE;
+
+		/* If any residual LVs, eliminate them, write VG, commit it and take a backup */
+		return _eliminate_extracted_lvs(lv->vg, removal_lvs);
 	}
-	init_mirror_in_sync(1);
 
-	log_debug_metadata("Setting new segtype for %s", lv->name);
-	seg->segtype = new_segtype;
-	lv->status &= ~MIRROR;
-	lv->status &= ~MIRRORED;
+	return 1;
+}
+
+/*
+ * Helper convert striped to raid0
+ *
+ * For @lv, empty hidden LVs in @data_lvs have been created by the caller.
+ *
+ * All areas from @lv segments are being moved to new
+ * segments allocated with area_count=1 for @data_lvs.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int _striped_to_raid0_move_segs_to_raid0_lvs(struct logical_volume *lv,
+						    struct dm_list *data_lvs)
+{
+	uint32_t s = 0, le;
+	struct logical_volume *dlv;
+	struct lv_segment *seg_from, *seg_new;
+	struct lv_list *lvl;
+	struct segment_type *segtype;
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	dm_list_iterate_items(lvl, data_lvs)  {
+		dlv = lvl->lv;
+		le = 0;
+		dm_list_iterate_items(seg_from, &lv->segments) {
+			uint64_t status = RAID | SEG_RAID | (seg_from->status & (LVM_READ | LVM_WRITE));
+
+			/* Allocate a segment with one area for each segment in the striped LV */
+			if (!(seg_new = alloc_lv_segment(segtype, dlv,
+							 le, seg_from->area_len,
+							 status,
+							 seg_from->stripe_size, NULL, 1 /* area_count */,
+							 seg_from->area_len, seg_from->chunk_size,
+							 0 /* region_size */, 0, NULL)))
+				return_0;
+
+			seg_type(seg_new, 0) = AREA_UNASSIGNED;
+			dm_list_add(&dlv->segments, &seg_new->list);
+			le += seg_from->area_len;
+
+			/* Move the respective area across to our new segment */
+			if (!move_lv_segment_area(seg_new, 0, seg_from, s))
+				return_0;
+		}
+
+		/* Adjust le count and lv size */
+		dlv->le_count = le;
+		dlv->size = (uint64_t) le * lv->vg->extent_size;
+		s++;
+	}
+
+	/* Remove the empty segments from the striped LV */
+	dm_list_init(&lv->segments);
+
+	return 1;
+}
+
+/* HM Helper: check that @lv has one stripe one, i.e. same stripe count in all of its segements */
+static int _lv_has_one_stripe_zone(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+	unsigned area_count = first_seg(lv)->area_count;
+
+	dm_list_iterate_items(seg, &lv->segments)
+		if (seg->area_count != area_count)
+			return 0;
+
+	return 1;
+}
+
+/*
+ * Helper: convert striped to raid0
+ *
+ * Inserts hidden LVs for all segments and the parallel areas in @lv and moves 
+ * given segments and areas across.
+ *
+ * Optionally allocates metadata devs if @alloc_metadata_devs
+ * Optionally updates metadata and reloads mappings if @update_and_reload
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
+						    int alloc_metadata_devs,
+						    int update_and_reload)
+{
+	struct lv_segment *seg = first_seg(lv), *raid0_seg;
+	unsigned area_count = seg->area_count;
+	struct segment_type *segtype;
+	struct dm_list data_lvs;
+
+	if (!seg_is_striped(seg)) {
+		log_error(INTERNAL_ERROR "Cannot convert non-%s LV %s to %s",
+			  SEG_TYPE_NAME_STRIPED, display_lvname(lv), SEG_TYPE_NAME_RAID0);
+		return NULL;
+	}
+
+	/* Check for not (yet) supported varying area_count on multi-segment striped LVs */
+	if (!_lv_has_one_stripe_zone(lv)) {
+		log_error("Cannot convert striped LV %s with varying stripe count to raid0",
+			  display_lvname(lv));
+		return NULL;
+	}
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID0)))
+		return_NULL;
+
+	/* Allocate empty rimage components */
+	dm_list_init(&data_lvs);
+	if (!_alloc_image_components(lv, NULL, area_count, NULL, &data_lvs)) {
+		log_error("Failed to allocate empty image components for raid0 LV %s.",
+			  display_lvname(lv));
+		return_NULL;
+	}
+
+	/* Move the AREA_PV areas across to the new rimage components; empties lv->segments */
+	if (!_striped_to_raid0_move_segs_to_raid0_lvs(lv, &data_lvs)) {
+		log_error("Failed to insert linear LVs underneath %s.", display_lvname(lv));
+		return_NULL;
+	}
+
+	/*
+	 * Allocate single segment to hold the image component
+	 * areas based on the first data LVs properties derived
+	 * from the first new raid0 LVs first segment
+	 */
+	seg = first_seg(dm_list_item(dm_list_first(&data_lvs), struct lv_list)->lv);
+	if (!(raid0_seg = alloc_lv_segment(segtype, lv,
+					   0 /* le */, lv->le_count /* len */,
+					   seg->status,
+					   seg->stripe_size, NULL /* log_lv */,
+					   area_count, lv->le_count, seg->chunk_size,
+					   0 /* seg->region_size */, 0u /* extents_copied */ ,
+					   NULL /* pvmove_source_seg */))) {
+		log_error("Failed to allocate new raid0 segement for LV %s.", display_lvname(lv));
+		return_NULL;
+	}
+
+	/* Add new single raid0 segment to emptied LV segments list */
+	dm_list_add(&lv->segments, &raid0_seg->list);
+
+	/* Add data lvs to the top-level lvs segment; resets LV_REBUILD flag on them */
+	if (!_add_image_component_list(raid0_seg, 1, 0, &data_lvs, 0))
+		return NULL;
+
 	lv->status |= RAID;
-	seg->status |= RAID;
 
-	if (!lv_update_and_reload(lv))
+	/* Allocate metadata lvs if requested */
+	if (alloc_metadata_devs && !_raid0_add_or_remove_metadata_lvs(lv, 0, NULL))
+		return NULL;
+
+	if (update_and_reload && !lv_update_and_reload(lv))
+		return NULL;
+
+	return raid0_seg;
+}
+/* End: striped -> raid0 conversion */
+
+/* Begin: raid0 -> striped conversion */
+/* HM Helper: walk the segment lvs of a segment @seg and find smallest area at offset @area_le */
+static uint32_t _smallest_segment_lvs_area(struct lv_segment *seg, uint32_t area_le)
+{
+	uint32_t r = ~0, s;
+
+	/* Find smallest segment of each of the data image lvs at offset area_le */
+	for (s = 0; s < seg->area_count; s++) {
+		struct lv_segment *seg1 = find_seg_by_le(seg_lv(seg, s), area_le);
+
+		r = min(r, seg1->le + seg1->len - area_le);
+	}
+
+	return r;
+}
+
+/* HM Helper: Split segments in segment LVs in all areas of @seg at offset @area_le */
+static int _split_area_lvs_segments(struct lv_segment *seg, uint32_t area_le)
+{
+	uint32_t s;
+
+	/* Make sure that there's segments starting at area_le in all data LVs */
+	for (s = 0; s < seg->area_count; s++)
+		if (area_le < seg_lv(seg, s)->le_count)
+			if (!lv_split_segment(seg_lv(seg, s), area_le)) {
+				log_error(INTERNAL_ERROR "splitting data lv segment");
+				return_0;
+			}
+
+	return 1;
+}
+
+/* HM Helper: allocate a new striped segment and add it to list @new_segments */
+static int _alloc_and_add_new_striped_segment(struct logical_volume *lv,
+					      uint32_t le, uint32_t area_len,
+					      struct dm_list *new_segments)
+{
+	struct lv_segment *seg = first_seg(lv), *new_seg;
+	struct segment_type *striped_segtype;
+
+	if (!(striped_segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	/* Allocate a segment with seg->area_count areas */
+	if (!(new_seg = alloc_lv_segment(striped_segtype, lv, le, area_len * seg->area_count,
+					 seg->status & ~RAID,
+					 seg->stripe_size, NULL, seg->area_count,
+					 area_len, seg->chunk_size, 0, 0, NULL)))
 		return_0;
 
+	dm_list_add(new_segments, &new_seg->list);
+
 	return 1;
 }
 
 /*
- * lv_raid_reshape
- * @lv
- * @new_segtype
+ * All areas from @lv image component LV's segments are
+ * being split at "striped" compatible boundaries and
+ * moved to @new_segments allocated.
  *
- * Convert an LV from one RAID type (or 'mirror' segtype) to another.
+ * The metadata+data component LVs are being mapped to an
+ * error target and linked to @removal_lvs for disposal
+ * by the caller.
  *
  * Returns: 1 on success, 0 on failure
  */
-int lv_raid_reshape(struct logical_volume *lv,
-		    const struct segment_type *new_segtype)
+static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv,
+						       struct dm_list *removal_lvs)
+{
+	uint32_t s, area_le, area_len, le;
+	struct lv_segment *data_seg, *seg = first_seg(lv), *seg_to;
+	struct dm_list new_segments;
+
+	dm_list_init(&new_segments);
+
+	/*
+	 * Walk all segments of all data LVs splitting them up at proper boundaries
+	 * and create the number of new striped segments we need to move them across
+	 */
+	area_le = le = 0;
+	while (le < lv->le_count) {
+		area_len = _smallest_segment_lvs_area(seg, area_le);
+		area_le += area_len;
+
+		if (!_split_area_lvs_segments(seg, area_le) ||
+		    !_alloc_and_add_new_striped_segment(lv, le, area_len, &new_segments))
+			return 0;
+
+		le += area_len * seg->area_count;
+	}
+
+	/* Now move the prepared split areas across to the new segments */
+	area_le = 0;
+	dm_list_iterate_items(seg_to, &new_segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			data_seg = find_seg_by_le(seg_lv(seg, s), area_le);
+
+			/* Move the respective area across to our new segments area */
+			if (!move_lv_segment_area(seg_to, s, data_seg, 0))
+				return_0;
+		}
+
+		/* Presumes all data LVs have equal size */
+		area_le += data_seg->len;
+	}
+
+	/* Extract any metadata LVs and the empty data LVs for disposal by the caller */
+	if ((seg->meta_areas && !_extract_image_component_list(seg, RAID_META,  0, removal_lvs)) ||
+	    !_extract_image_component_list(seg, RAID_IMAGE, 0, removal_lvs))
+		return_0;
+
+	/*
+	 * Remove the one segment holding the image component areas
+	 * from the top-level LV, then add the new segments to it
+	 */
+	dm_list_del(&seg->list);
+	dm_list_splice(&lv->segments, &new_segments);
+
+	return 1;
+}
+
+/*
+ * HM
+ *
+ * Helper convert raid0 to striped
+ *
+ * Convert a RAID0 set to striped
+ *
+ * Returns: 1 on success, 0 on failure
+ *
+ * HM FIXME: check last_seg(lv)->reshape_len and reduce LV aprropriately
+ */
+static int _convert_raid0_to_striped(struct logical_volume *lv,
+				     int update_and_reload,
+				     struct dm_list *removal_lvs)
+{
+	/* Caller should ensure, but... */
+	if (!seg_is_any_raid0(first_seg(lv))) {
+		log_error(INTERNAL_ERROR "Cannot convert non-%s LV %s to %s",
+			  SEG_TYPE_NAME_RAID0, display_lvname(lv), SEG_TYPE_NAME_STRIPED);
+		return 0;
+	}
+
+	/* Move the AREA_PV areas across to new top-level segments of type "striped" */
+	if (!_raid0_to_striped_retrieve_segments_and_lvs(lv, removal_lvs)) {
+		log_error("Failed to retrieve raid0 segments from %s.", lv->name);
+		return_0;
+	}
+
+	lv->status &= ~RAID;
+
+	if (!(first_seg(lv)->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	if (update_and_reload) {
+		if (!lv_update_and_reload(lv))
+			return_0;
+
+		/* Eliminate the residual LVs, write VG, commit it and take a backup */
+		return _eliminate_extracted_lvs(lv->vg, removal_lvs);
+	}
+
+	return 1;
+}
+/* End: raid0 -> striped conversion */
+
+/****************************************************************************/
+/* Begin: various conversions between layers (aka MD takeover) */
+/*
+ * takeover function argument list definition
+ *
+ * All takeover functions and helper functions
+ * to support them have this list of arguments
+ */
+#define TAKEOVER_FN_ARGUMENTS					\
+	struct logical_volume *lv,				\
+	int yes, int force,					\
+	const struct segment_type *new_segtype,			\
+	unsigned new_image_count,				\
+	const unsigned new_stripes,				\
+	unsigned new_stripe_size, struct dm_list *allocate_pvs
+
+/*
+ * a matrix with types from -> types to holds
+ * takeover function pointers this prototype
+ */
+typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGUMENTS);
+
+/* Return takeover function table index for @segtype */
+static int _takeover_fn_idx(const struct segment_type *segtype)
+{
+	static uint64_t _segtype_to_idx[] = {
+		SEG_AREAS_STRIPED,
+		SEG_MIRROR,
+		SEG_RAID0,
+		SEG_RAID0_META,
+		SEG_RAID1,
+	};
+	unsigned r = ARRAY_SIZE(_segtype_to_idx);
+
+	while (r-- > 0)
+		if (segtype->flags & _segtype_to_idx[r])
+			return r;
+
+	return -1;
+}
+
+/* Macro to define raid takeover helper function header */
+#define TAKEOVER_FN(function_name) \
+static int function_name(TAKEOVER_FN_ARGUMENTS)
+
+/*
+ * noop and error takoover handler functions
+ * to allow for logging that an lv already
+ * has the requested type or that the requested
+ * conversion is not possible
+ */
+/* Noop takeover handler for @lv: logs that LV already is of the requested type */
+TAKEOVER_FN(_noop)
+{
+	log_warn("Logical volume %s already is of requested type %s",
+		 display_lvname(lv), lvseg_name(first_seg(lv)));
+
+	return 1;
+}
+
+/* Error takeover handler for @lv: logs what's (im)possible to convert to (and mabye added later) */
+TAKEOVER_FN(_error)
 {
 	struct lv_segment *seg = first_seg(lv);
 
-	if (!new_segtype) {
-		log_error(INTERNAL_ERROR "New segtype not specified");
+	log_error("Converting the segment type for %s from %s to %s"
+		  " is not supported.", display_lvname(lv),
+		  lvseg_name(seg), new_segtype->name);
+
+	return 0;
+}
+
+
+/* Striped -> raid0 */
+TAKEOVER_FN(_s_r0)
+{
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _convert_striped_to_raid0(lv, 0 /* !alloc_metadata_devs */, 1 /* update_and_reload */) ? 1 : 0;
+}
+
+/* Striped -> raid0_meta */
+TAKEOVER_FN(_s_r0m)
+{
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _convert_striped_to_raid0(lv, 1 /* alloc_metadata_devs */, 1 /* update_and_reload */) ? 1 : 0;
+} 
+
+/* raid0 -> raid0_meta */
+TAKEOVER_FN(_r0_r0m)
+{
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _raid0_add_or_remove_metadata_lvs(lv, 1, NULL);
+}
+
+/* raid0_meta -> raid0 */
+TAKEOVER_FN(_r0m_r0)
+{
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _raid0_add_or_remove_metadata_lvs(lv, 1, &removal_lvs);
+}
+
+/* raid0_meta -> striped */
+TAKEOVER_FN(_r0m_s)
+{
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _convert_raid0_to_striped(lv, 1, &removal_lvs);
+}
+
+/* raid0 -> striped */
+TAKEOVER_FN(_r0_s)
+{
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+
+	return _convert_raid0_to_striped(lv, 1, &removal_lvs);
+}
+
+/* Mirror -> raid1 */
+TAKEOVER_FN(_m_r1)
+{
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	return _convert_mirror_to_raid1(lv, new_segtype, 1);
+}
+
+/*
+ * 2-dimensional takeover function matrix defining the
+ * FSM of possible/impossible or noop (i.e. requested
+ * conversion already given on the lv) conversions
+ *
+ * Rows define from segtype and columns to segtype
+ */
+static takeover_fn_t _takeover_fn[][5] = {
+	/* from |, to ->    striped   mirror   raid0    raid0_meta  raid1 */
+	/*      v */
+	/* striped     */ { _noop,   _error,  _s_r0,   _s_r0m,     _error },
+	/* mirror      */ { _error,  _noop,   _error,  _error,     _m_r1  },
+	/* raid0       */ { _r0_s,   _error,  _noop,   _r0_r0m,    _error },
+	/* raid0_meta  */ { _r0m_s,  _error,  _r0m_r0, _noop,      _error },
+};
+
+/* End: various conversions between layers (aka MD takeover) */
+/****************************************************************************/
+
+/*
+ * lv_raid_convert
+ * @lv
+ * @new_segtype
+ *
+ * Convert @lv from one RAID type (or 'mirror' segtype) to @new_segtype,
+ * change RAID algorithm (e.g. left symmetric to right asymmetric),
+ * add/remove LVs to/from a RAID LV or change stripe sectors
+ *
+ * Non dm-raid changes are factored in e.g. "mirror" and "striped" related
+ * fucntions called from here.
+ * All the rest of the raid <-> raid conversions go into a function
+ * _convert_raid_to_raid() of their own called from here.
+ *
+  * Returns: 1 on success, 0 on failure
+  */
+int lv_raid_convert(struct logical_volume *lv,
+		    const struct segment_type *new_segtype,
+		    int yes, int force,
+		    unsigned new_image_count,
+		    const unsigned new_stripes,
+		    const unsigned new_stripe_size,
+		    struct dm_list *allocate_pvs)
+ {
+	int from_idx, to_idx;
+	uint32_t stripes, stripe_size;
+ 	struct lv_segment *seg = first_seg(lv);
+	struct segment_type *striped_segtype;
+	struct dm_list removal_lvs;
+
+	dm_list_init(&removal_lvs);
+ 
+ 	if (!new_segtype) {
+ 		log_error(INTERNAL_ERROR "New segtype not specified");
+ 		return 0;
+ 	}
+ 
+	if (!(striped_segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
+		return_0;
+
+	/* Given segtype of @lv */
+	if (!seg_is_striped(seg) && /* Catches linear = "overloaded striped with one area" as well */
+	    !seg_is_mirror(seg) &&
+	    !seg_is_raid(seg))
+		goto err;
+
+	/* Requested segtype */
+	if (!segtype_is_linear(new_segtype) &&
+	    !segtype_is_striped(new_segtype) &&
+	    !segtype_is_mirror(new_segtype) &&
+	    !segtype_is_raid(new_segtype))
+		goto err;
+
+	/* Define new image count if not passed in */
+	new_image_count = new_image_count ?: seg->area_count;
+
+	if (!_check_max_raid_devices(new_image_count))
+		return 0;
+
+	/* Define new stripe size if not passed in */
+	stripe_size = new_stripe_size ?: seg->stripe_size;
+	stripes = new_stripes ?: _data_rimages_count(seg, seg->area_count);
+
+	/* @lv has to be active to perform raid conversion operatons */
+	if (!lv_is_active(lv)) {
+		log_error("%s must be active to perform this operation.",
+			  display_lvname(lv));
 		return 0;
 	}
 
-	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
-		log_error("%s/%s must be active exclusive locally to"
-			  " perform this operation.", lv->vg->name, lv->name);
+	/* If clustered VG, @lv has to be active locally */
+ 	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
+		log_error("%s must be active exclusive locally to"
+			  " perform this operation.", display_lvname(lv));
+ 		return 0;
+ 	}
+ 
+	/* Can't perfom any raid conversions on out of sync LVs */
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s while it is not in-sync",
+			  display_lvname(lv));
 		return 0;
 	}
 
-	if (!strcmp(seg->segtype->name, "mirror") &&
-	    (!strcmp(new_segtype->name, SEG_TYPE_NAME_RAID1)))
-	    return _convert_mirror_to_raid1(lv, new_segtype);
+	/*
+	 * Table driven takeover, i.e. conversions from one segment type to another
+	 */
+	from_idx = _takeover_fn_idx(seg->segtype);
+	to_idx = _takeover_fn_idx(new_segtype);
+	if ((from_idx < 0 || to_idx < 0) ||
+	    !_takeover_fn[from_idx][to_idx](lv, yes, force, new_segtype, new_image_count,
+					    stripes, stripe_size, allocate_pvs))
+		goto err;
+
+	log_print_unless_silent("Logical volume %s successfully converted", display_lvname(lv));
+	return 1;
 
-	log_error("Converting the segment type for %s/%s from %s to %s"
-		  " is not yet supported.", lv->vg->name, lv->name,
+err:
+	/* FIXME: enhance message */
+	log_error("Converting the segment type for %s from %s to %s"
+		  " is not supported.", display_lvname(lv),
 		  lvseg_name(seg), new_segtype->name);
 	return 0;
 }
 
-
 static int _remove_partial_multi_segment_image(struct logical_volume *lv,
 					       struct dm_list *remove_pvs)
 {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 4b2df78..ff2b3fc 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -28,28 +28,51 @@ struct dm_config_node;
 struct dev_manager;
 
 /* Feature flags */
-#define SEG_CAN_SPLIT		0x00000001U
-#define SEG_AREAS_STRIPED	0x00000002U
-#define SEG_AREAS_MIRRORED	0x00000004U
-#define SEG_SNAPSHOT		0x00000008U
-#define SEG_FORMAT1_SUPPORT	0x00000010U
-#define SEG_VIRTUAL		0x00000020U
-#define SEG_CANNOT_BE_ZEROED	0x00000040U
-#define SEG_MONITORED		0x00000080U
-#define SEG_REPLICATOR		0x00000100U
-#define SEG_REPLICATOR_DEV	0x00000200U
-#define SEG_RAID		0x00000400U
-#define SEG_THIN_POOL		0x00000800U
-#define SEG_THIN_VOLUME		0x00001000U
-#define SEG_CACHE		0x00002000U
-#define SEG_CACHE_POOL		0x00004000U
-#define SEG_MIRROR		0x00008000U
-#define SEG_ONLY_EXCLUSIVE	0x00010000U /* In cluster only exlusive activation */
-#define SEG_CAN_ERROR_WHEN_FULL	0x00020000U
-#define SEG_UNKNOWN		0x80000000U
+#define SEG_CAN_SPLIT		0x0000000000000001U
+#define SEG_AREAS_STRIPED	0x0000000000000002U
+#define SEG_AREAS_MIRRORED	0x0000000000000004U
+#define SEG_SNAPSHOT		0x0000000000000008U
+#define SEG_FORMAT1_SUPPORT	0x0000000000000010U
+#define SEG_VIRTUAL		0x0000000000000020U
+#define SEG_CANNOT_BE_ZEROED	0x0000000000000040U
+#define SEG_MONITORED		0x0000000000000080U
+#define SEG_REPLICATOR		0x0000000000000100U
+#define SEG_REPLICATOR_DEV	0x0000000000000200U
+#define SEG_RAID		0x0000000000000400U
+#define SEG_THIN_POOL		0x0000000000000800U
+#define SEG_THIN_VOLUME		0x0000000000001000U
+#define SEG_CACHE		0x0000000000002000U
+#define SEG_CACHE_POOL		0x0000000000004000U
+#define SEG_MIRROR		0x0000000000008000U
+#define SEG_ONLY_EXCLUSIVE	0x0000000000010000U /* In cluster only exlusive activation */
+#define SEG_CAN_ERROR_WHEN_FULL	0x0000000000020000U
+
+#define SEG_RAID0		0x0000000000040000U
+#define SEG_RAID0_META		0x0000000000080000U
+#define SEG_RAID1		0x0000000000100000U
+#define SEG_RAID10		0x0000000000200000U
+#define SEG_RAID4		0x0000000000400000U
+#define SEG_RAID5_N		0x0000000000800000U
+#define SEG_RAID5_LA		0x0000000001000000U
+#define SEG_RAID5_LS		0x0000000002000000U
+#define SEG_RAID5_RA		0x0000000004000000U
+#define SEG_RAID5_RS		0x0000000008000000U
+#define SEG_RAID5		SEG_RAID5_LS
+#define SEG_RAID6_NC		0x0000000010000000U
+#define SEG_RAID6_NR		0x0000000020000000U
+#define SEG_RAID6_ZR		0x0000000040000000U
+#define SEG_RAID6_LA_6		0x0000000080000000U
+#define SEG_RAID6_LS_6		0x0000000100000000U
+#define SEG_RAID6_RA_6		0x0000000200000000U
+#define SEG_RAID6_RS_6		0x0000000400000000U
+#define SEG_RAID6_N_6		0x0000000800000000U
+#define SEG_RAID6		SEG_RAID6_ZR
+
+#define SEG_UNKNOWN		0x8000000000000000U
 
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
+#define segtype_is_linear(segtype)	(!strcmp(segtype->name, "linear"))
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
@@ -86,7 +109,7 @@ struct dev_manager;
 struct segment_type {
 	struct dm_list list;		/* Internal */
 
-	uint32_t flags;
+	uint64_t flags;
 	uint32_t parity_devs;           /* Parity drives required by segtype */
 
 	struct segtype_handler *ops;
@@ -139,6 +162,8 @@ struct segtype_handler {
 
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 					     const char *str);
+struct segment_type *get_segtype_from_flag(struct cmd_context *cmd,
+					   uint64_t flag);
 
 struct segtype_library;
 int lvm_register_segtype(struct segtype_library *seglib,
@@ -152,23 +177,65 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 					  const char *name);
 
 #define RAID_FEATURE_RAID10			(1U << 0) /* version 1.3 */
+#define RAID_FEATURE_RAID0			(1U << 1) /* version 1.7 */
+#define RAID_FEATURE_RESHAPING			(1U << 2) /* version 1.8 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
-#define SEG_TYPE_NAME_RAID1	"raid1"
-#define SEG_TYPE_NAME_RAID10	"raid10"
-#define SEG_TYPE_NAME_RAID4	"raid4"
-#define SEG_TYPE_NAME_RAID5	"raid5"
-#define SEG_TYPE_NAME_RAID5_LA	"raid5_la"
-#define SEG_TYPE_NAME_RAID5_LS	"raid5_ls"
-#define SEG_TYPE_NAME_RAID5_RA	"raid5_ra"
-#define SEG_TYPE_NAME_RAID5_RS	"raid5_rs"
-#define SEG_TYPE_NAME_RAID6	"raid6"
-#define SEG_TYPE_NAME_RAID6_NC	"raid6_nc"
-#define SEG_TYPE_NAME_RAID6_NR	"raid6_nr"
-#define SEG_TYPE_NAME_RAID6_ZR	"raid6_zr"
+#define SEG_TYPE_NAME_MIRROR		"mirror"
+
+/* RAID specific seg and segtype checks */
+#define SEG_TYPE_NAME_LINEAR		"linear"
+#define SEG_TYPE_NAME_STRIPED		"striped"
+
+#define SEG_TYPE_NAME_RAID0		"raid0"
+#define SEG_TYPE_NAME_RAID0_META	"raid0_meta"
+#define SEG_TYPE_NAME_RAID1		"raid1"
+#define SEG_TYPE_NAME_RAID10		"raid10"
+#define SEG_TYPE_NAME_RAID4		"raid4"
+#define SEG_TYPE_NAME_RAID5		"raid5"
+#define SEG_TYPE_NAME_RAID5_LA		"raid5_la"
+#define SEG_TYPE_NAME_RAID5_LS		"raid5_ls"
+#define SEG_TYPE_NAME_RAID5_RA		"raid5_ra"
+#define SEG_TYPE_NAME_RAID5_RS		"raid5_rs"
+#define SEG_TYPE_NAME_RAID6		"raid6"
+#define SEG_TYPE_NAME_RAID6_NC		"raid6_nc"
+#define SEG_TYPE_NAME_RAID6_NR		"raid6_nr"
+#define SEG_TYPE_NAME_RAID6_ZR		"raid6_zr"
+
+#define segtype_is_raid0(segtype)	(((segtype)->flags & SEG_RAID0) ? 1 : 0)
+#define segtype_is_raid0_meta(segtype)	(((segtype)->flags & SEG_RAID0_META) ? 1 : 0)
+#define segtype_is_any_raid0(segtype)	(((segtype)->flags & (SEG_RAID0|SEG_RAID0_META)) ? 1 : 0)
+#define segtype_is_raid1(segtype)	(((segtype)->flags & SEG_RAID1) ? 1 : 0)
+#define segtype_is_raid10(segtype)	(((segtype)->flags & SEG_RAID10) ? 1 : 0)
+#define segtype_is_raid4(segtype)	(((segtype)->flags & SEG_RAID4) ? 1 : 0)
+#define segtype_is_raid5_ls(segtype)	(((segtype)->flags & SEG_RAID5_LS) ? 1 : 0)
+#define segtype_is_raid5_rs(segtype)	(((segtype)->flags & SEG_RAID5_RS) ? 1 : 0)
+#define segtype_is_raid5_la(segtype)	(((segtype)->flags & SEG_RAID5_LA) ? 1 : 0)
+#define segtype_is_raid5_ra(segtype)	(((segtype)->flags & SEG_RAID5_RA) ? 1 : 0)
+#define segtype_is_any_raid5(segtype)	(((segtype)->flags & \
+					 (SEG_RAID5_LS|SEG_RAID5_LA|SEG_RAID5_RS|SEG_RAID5_RA|SEG_RAID5_N)) ? 1 : 0)
+#define segtype_is_raid6_zr(segtype)	(((segtype)->flags & SEG_RAID6_ZR) ? 1 : 0)
+#define segtype_is_raid6_nc(segtype)	(((segtype)->flags & SEG_RAID6_NC) ? 1 : 0)
+#define segtype_is_raid6_nr(segtype)	(((segtype)->flags & SEG_RAID6_NR) ? 1 : 0)
+#define segtype_is_striped_raid(segtype)	(segtype_is_raid(segtype) && !segtype_is_raid1(segtype))
+
+#define seg_is_raid0(seg)		segtype_is_raid0((seg)->segtype)
+#define seg_is_raid0_meta(seg)		segtype_is_raid0_meta((seg)->segtype)
+#define seg_is_any_raid0(seg)		segtype_is_any_raid0((seg)->segtype)
+#define seg_is_raid1(seg)		segtype_is_raid1((seg)->segtype)
+#define seg_is_raid10(seg)		segtype_is_raid10((seg)->segtype)
+#define seg_is_raid4(seg)		segtype_is_raid4((seg)->segtype)
+#define seg_is_raid5_ls(seg)		segtype_is_raid5_ls((seg)->segtype)
+#define seg_is_raid5_rs(seg)		segtype_is_raid5_rs((seg)->segtype)
+#define seg_is_raid5_la(seg)		segtype_is_raid5_la((seg)->segtype)
+#define seg_is_raid5_ra(seg)		segtype_is_raid5_ra((seg)->segtype)
+#define seg_is_raid6_zr(seg)		segtype_is_raid6_zr((seg)->segtype)
+#define seg_is_raid6_nc(seg)		segtype_is_raid6_nc((seg)->segtype)
+#define seg_is_raid6_nr(seg)		segtype_is_raid6_nr((seg)->segtype)
+#define seg_is_striped_raid(seg)	segtype_is_striped_raid((seg)->segtype)
 
 #ifdef REPLICATOR_INTERNAL
 int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 39e3a06..9a8e1b0 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -34,8 +34,9 @@ static void _raid_display(const struct lv_segment *seg)
 		display_stripe(seg, s, "    ");
 	}
 
-	for (s = 0; s < seg->area_count; ++s)
-		log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
+	if (seg->meta_areas)
+		for (s = 0; s < seg->area_count; ++s)
+			log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
 
 	log_print(" ");
 }
@@ -43,8 +44,9 @@ static void _raid_display(const struct lv_segment *seg)
 static int _raid_text_import_area_count(const struct dm_config_node *sn,
 					uint32_t *area_count)
 {
-	if (!dm_config_get_uint32(sn, "device_count", area_count)) {
-		log_error("Couldn't read 'device_count' for "
+	if (!dm_config_get_uint32(sn, "device_count", area_count) &&
+	    !dm_config_get_uint32(sn, "stripe_count", area_count)) {
+		log_error("Couldn't read '(devicei|stripe)_count' for "
 			  "segment '%s'.", dm_config_parent_name(sn));
 		return 0;
 	}
@@ -56,7 +58,7 @@ static int _raid_text_import_areas(struct lv_segment *seg,
 				   const struct dm_config_value *cv)
 {
 	unsigned int s;
-	struct logical_volume *lv1;
+	struct logical_volume *lv;
 	const char *seg_name = dm_config_parent_name(sn);
 
 	if (!seg->area_count) {
@@ -70,29 +72,33 @@ static int _raid_text_import_areas(struct lv_segment *seg,
 			return 0;
 		}
 
-		if (!cv->next) {
-			log_error("Missing data device in areas array for segment %s.", seg_name);
-			return 0;
-		}
-
-		/* Metadata device comes first */
-		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
-			log_error("Couldn't find volume '%s' for segment '%s'.",
-				  cv->v.str ? : "NULL", seg_name);
-			return 0;
-		}
-		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_META))
+		/* Metadata device comes first unless RAID0 optionally w/o metadata dev */
+		if (strcmp(cv->v.str, "-")) {
+			if (!cv->next) {
+				log_error("Missing data device in areas array for segment %s.", seg_name);
+				return 0;
+			}
+
+			if  (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
+				log_error("Couldn't find volume '%s' for segment '%s'.",
+					  cv->v.str ? : "NULL", seg_name);
+				return 0;
+			}
+			if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_META))
 				return_0;
+		}
 
-		/* Data device comes second */
 		cv = cv->next;
-		if (!(lv1 = find_lv(seg->lv->vg, cv->v.str))) {
+
+		/* Data device comes second unless RAID0 */
+		if (!(lv = find_lv(seg->lv->vg, cv->v.str))) {
 			log_error("Couldn't find volume '%s' for segment '%s'.",
 				  cv->v.str ? : "NULL", seg_name);
 			return 0;
 		}
-		if (!set_lv_segment_area_lv(seg, s, lv1, 0, RAID_IMAGE))
-				return_0;
+
+		if (!set_lv_segment_area_lv(seg, s, lv, 0, RAID_IMAGE))
+			return_0;
 	}
 
 	/*
@@ -111,50 +117,29 @@ static int _raid_text_import(struct lv_segment *seg,
 			     const struct dm_config_node *sn,
 			     struct dm_hash_table *pv_hash)
 {
+	int i;
 	const struct dm_config_value *cv;
-
-	if (dm_config_has_node(sn, "region_size")) {
-		if (!dm_config_get_uint32(sn, "region_size", &seg->region_size)) {
-			log_error("Couldn't read 'region_size' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "stripe_size")) {
-		if (!dm_config_get_uint32(sn, "stripe_size", &seg->stripe_size)) {
-			log_error("Couldn't read 'stripe_size' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "writebehind")) {
-		if (!dm_config_get_uint32(sn, "writebehind", &seg->writebehind)) {
-			log_error("Couldn't read 'writebehind' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "min_recovery_rate")) {
-		if (!dm_config_get_uint32(sn, "min_recovery_rate",
-					  &seg->min_recovery_rate)) {
-			log_error("Couldn't read 'min_recovery_rate' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
-		}
-	}
-	if (dm_config_has_node(sn, "max_recovery_rate")) {
-		if (!dm_config_get_uint32(sn, "max_recovery_rate",
-					  &seg->max_recovery_rate)) {
-			log_error("Couldn't read 'max_recovery_rate' for "
-				  "segment %s of logical volume %s.",
-				  dm_config_parent_name(sn), seg->lv->name);
-			return 0;
+	const struct {
+		const char *name;
+		void *var;
+	} attr_import[] = {
+		{ "region_size",       &seg->region_size },
+		{ "stripe_size",       &seg->stripe_size },
+		{ "writebehind",       &seg->writebehind },
+		{ "min_recovery_rate", &seg->min_recovery_rate },
+		{ "max_recovery_rate", &seg->max_recovery_rate },
+	}, *aip = attr_import;
+
+	for (i = 0; i < DM_ARRAY_SIZE(attr_import); i++, aip++) {
+		if (dm_config_has_node(sn, aip->name)) {
+			if (!dm_config_get_uint32(sn, aip->name, aip->var)) {
+				log_error("Couldn't read '%s' for segment %s of logical volume %s.",
+					  aip->name, dm_config_parent_name(sn), seg->lv->name);
+				return 0;
+			}
 		}
 	}
+
 	if (!dm_config_get_list(sn, "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
@@ -163,7 +148,7 @@ static int _raid_text_import(struct lv_segment *seg,
 	}
 
 	if (!_raid_text_import_areas(seg, sn, cv)) {
-		log_error("Failed to import RAID images");
+		log_error("Failed to import RAID component pairs");
 		return 0;
 	}
 
@@ -174,17 +159,29 @@ static int _raid_text_import(struct lv_segment *seg,
 
 static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	outf(f, "device_count = %u", seg->area_count);
-	if (seg->region_size)
-		outf(f, "region_size = %" PRIu32, seg->region_size);
+	int raid0 = seg_is_any_raid0(seg);
+
+	if (raid0)
+		outfc(f, (seg->area_count == 1) ? "# linear" : NULL,
+		      "stripe_count = %u", seg->area_count);
+
+	else {
+		outf(f, "device_count = %u", seg->area_count);
+		if (seg->region_size)
+			outf(f, "region_size = %" PRIu32, seg->region_size);
+	}
+
 	if (seg->stripe_size)
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
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
@@ -222,28 +219,34 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		return 0;
 	}
 
-	if (!seg->region_size) {
-		log_error("Missing region size for mirror segment.");
-		return 0;
-	}
+	if (!seg_is_any_raid0(seg)) {
+		if (!seg->region_size) {
+			log_error("Missing region size for mirror segment.");
+			return 0;
+		}
 
-	for (s = 0; s < seg->area_count; s++)
-		if (seg_lv(seg, s)->status & LV_REBUILD)
-			rebuilds |= 1ULL << s;
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_lv(seg, s)->status & LV_REBUILD)
+				rebuilds |= 1ULL << s;
 
-	for (s = 0; s < seg->area_count; s++)
-		if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
-			writemostly |= 1ULL << s;
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
+				writemostly |= 1ULL << s;
 
-	if (mirror_in_sync())
-		flags = DM_NOSYNC;
+		if (mirror_in_sync())
+			flags = DM_NOSYNC;
+	}
 
 	params.raid_type = lvseg_name(seg);
+
 	if (seg->segtype->parity_devs) {
 		/* RAID 4/5/6 */
 		params.mirrors = 1;
 		params.stripes = seg->area_count - seg->segtype->parity_devs;
-	} else if (strcmp(seg->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	} else if (seg_is_any_raid0(seg)){
+		params.mirrors = 1;
+		params.stripes = seg->area_count;
+	} else if (seg_is_raid10(seg)) {
 		/* RAID 10 only supports 2 mirrors now */
 		params.mirrors = 2;
 		params.stripes = seg->area_count / 2;
@@ -252,13 +255,18 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		params.mirrors = seg->area_count;
 		params.stripes = 1;
 		params.writebehind = seg->writebehind;
+		params.writemostly = writemostly;
 	}
-	params.region_size = seg->region_size;
+
+	/* RAID 0 doesn't have a bitmap, thus no region_size, rebuilds etc. */
+	if (!seg_is_any_raid0(seg)) {
+		params.region_size = seg->region_size;
+		params.rebuilds = rebuilds;
+		params.min_recovery_rate = seg->min_recovery_rate;
+		params.max_recovery_rate = seg->max_recovery_rate;
+	}
+
 	params.stripe_size = seg->stripe_size;
-	params.rebuilds = rebuilds;
-	params.writemostly = writemostly;
-	params.min_recovery_rate = seg->min_recovery_rate;
-	params.max_recovery_rate = seg->max_recovery_rate;
 	params.flags = flags;
 
 	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
@@ -332,6 +340,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 		const char *feature;
 	} _features[] = {
 		{ 1, 3, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
+		{ 1, 7, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
 	};
 
 	static int _raid_checked = 0;
@@ -437,18 +446,20 @@ static const struct raid_type {
 	unsigned parity;
 	int extra_flags;
 } _raid_types[] = {
-	{ SEG_TYPE_NAME_RAID1,    0, SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID0,      0, SEG_RAID0 },
+	{ SEG_TYPE_NAME_RAID0_META, 0, SEG_RAID0_META },
+	{ SEG_TYPE_NAME_RAID1,    0, SEG_RAID1 | SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID10,   0, SEG_AREAS_MIRRORED },
-	{ SEG_TYPE_NAME_RAID4,    1 },
-	{ SEG_TYPE_NAME_RAID5,    1 },
-	{ SEG_TYPE_NAME_RAID5_LA, 1 },
-	{ SEG_TYPE_NAME_RAID5_LS, 1 },
-	{ SEG_TYPE_NAME_RAID5_RA, 1 },
-	{ SEG_TYPE_NAME_RAID5_RS, 1 },
-	{ SEG_TYPE_NAME_RAID6,    2 },
-	{ SEG_TYPE_NAME_RAID6_NC, 2 },
-	{ SEG_TYPE_NAME_RAID6_NR, 2 },
-	{ SEG_TYPE_NAME_RAID6_ZR, 2 }
+	{ SEG_TYPE_NAME_RAID4,    1, SEG_RAID4 },
+	{ SEG_TYPE_NAME_RAID5,    1, SEG_RAID5_LS },
+	{ SEG_TYPE_NAME_RAID5_LA, 1, SEG_RAID5_LA },
+	{ SEG_TYPE_NAME_RAID5_LS, 1, SEG_RAID5_LS },
+	{ SEG_TYPE_NAME_RAID5_RA, 1, SEG_RAID5_RA },
+	{ SEG_TYPE_NAME_RAID5_RS, 1, SEG_RAID5_RS },
+	{ SEG_TYPE_NAME_RAID6,    2, SEG_RAID6_ZR },
+	{ SEG_TYPE_NAME_RAID6_NC, 2, SEG_RAID6_NC },
+	{ SEG_TYPE_NAME_RAID6_NR, 2, SEG_RAID6_NR },
+	{ SEG_TYPE_NAME_RAID6_ZR, 2, SEG_RAID6_ZR }
 };
 
 static struct segment_type *_init_raid_segtype(struct cmd_context *cmd,
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index c85b822..67162dd 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -140,7 +140,7 @@ int id_valid(struct id *id)
 
 	for (i = 0; i < ID_LEN; i++)
 		if (!_inverse_c[id->uuid[i]]) {
-			log_error("UUID contains invalid character");
+			log_error("UUID contains invalid character '%c'", id->uuid[i]);
 			return 0;
 		}
 
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 578f645..c34d532 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -42,6 +42,8 @@ enum {
 	SEG_ZERO,
 	SEG_THIN_POOL,
 	SEG_THIN,
+	SEG_RAID0,
+	SEG_RAID0_META,
 	SEG_RAID1,
 	SEG_RAID10,
 	SEG_RAID4,
@@ -74,6 +76,8 @@ static const struct {
 	{ SEG_ZERO, "zero"},
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
+	{ SEG_RAID0, "raid0"},
+	{ SEG_RAID0_META, "raid0_meta"},
 	{ SEG_RAID1, "raid1"},
 	{ SEG_RAID10, "raid10"},
 	{ SEG_RAID4, "raid4"},
@@ -86,7 +90,7 @@ static const struct {
 	{ SEG_RAID6_NC, "raid6_nc"},
 
 	/*
-	 *WARNING: Since 'raid' target overloads this 1:1 mapping table
+	 * WARNING: Since 'raid' target overloads this 1:1 mapping table
 	 * for search do not add new enum elements past them!
 	 */
 	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
@@ -2089,6 +2093,8 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 					EMIT_PARAMS(*pos, "%s", synctype);
 			}
 			break;
+		case SEG_RAID0:
+		case SEG_RAID0_META:
 		case SEG_RAID1:
 		case SEG_RAID10:
 		case SEG_RAID4:
@@ -2286,6 +2292,26 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	return 1;
 }
 
+/* Return 2 if @p != 0 */
+static int _2_if_value(unsigned p)
+{
+	return p ? 2 : 0;
+}
+
+/* Return number of bits passed in @bits assuming 2 * 64 bit size */
+static int _get_params_count(uint64_t *bits)
+{
+	int r = 0;
+	int i = 4;
+
+	while (i--) {
+		r += 2 * hweight32(bits[i] & 0xFFFFFFFF);
+		r += 2 * hweight32(bits[i] >> 32);
+	}
+
+	return r;
+}
+
 static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 				   uint32_t minor, struct load_segment *seg,
 				   uint64_t *seg_start, char *params,
@@ -2294,34 +2320,32 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	uint32_t i;
 	int param_count = 1; /* mandatory 'chunk size'/'stripe size' arg */
 	int pos = 0;
+	unsigned type;
+
+	if (seg->area_count % 2)
+		return 0;
 
 	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
 		param_count++;
 
-	if (seg->region_size)
-		param_count += 2;
-
-	if (seg->writebehind)
-		param_count += 2;
+	param_count += _2_if_value(seg->region_size) +
+		       _2_if_value(seg->writebehind) +
+		       _2_if_value(seg->min_recovery_rate) +
+		       _2_if_value(seg->max_recovery_rate);
 
-	if (seg->min_recovery_rate)
-		param_count += 2;
-
-	if (seg->max_recovery_rate)
-		param_count += 2;
-
-	/* rebuilds is 64-bit */
-	param_count += 2 * hweight32(seg->rebuilds & 0xFFFFFFFF);
-	param_count += 2 * hweight32(seg->rebuilds >> 32);
-
-	/* rebuilds is 64-bit */
-	param_count += 2 * hweight32(seg->writemostly & 0xFFFFFFFF);
-	param_count += 2 * hweight32(seg->writemostly >> 32);
+	/* rebuilds and writemostly are 4 * 64 bits */
+	param_count += _get_params_count(&seg->rebuilds);
+	param_count += _get_params_count(&seg->writemostly);
 
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");
 
-	EMIT_PARAMS(pos, "%s %d %u", _dm_segtypes[seg->type].target,
+	/* Kernel only expects "raid0", not "raid0_meta" */
+	type = seg->type;
+	if (type == SEG_RAID0_META)
+		type = SEG_RAID0;
+
+	EMIT_PARAMS(pos, "%s %d %u", _dm_segtypes[type].target,
 		    param_count, seg->stripe_size);
 
 	if (seg->flags & DM_NOSYNC)
@@ -2525,6 +2549,8 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?
 			    seg->iv_offset : *seg_start);
 		break;
+	case SEG_RAID0:
+	case SEG_RAID0_META:
 	case SEG_RAID1:
 	case SEG_RAID10:
 	case SEG_RAID4:
@@ -4074,6 +4100,8 @@ int dm_tree_node_add_null_area(struct dm_tree_node *node, uint64_t offset)
 	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 
 	switch (seg->type) {
+	case SEG_RAID0:
+	case SEG_RAID0_META:
 	case SEG_RAID1:
 	case SEG_RAID4:
 	case SEG_RAID5_LA:
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e790ea0..0b5178d 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -720,7 +720,7 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
-	if (strcmp(raid_seg->segtype->name, SEG_TYPE_NAME_RAID1)) {
+	if (!seg_is_raid1(raid_seg)) {
 		log_error("--write%s can only be used with 'raid1' segment type",
 			  arg_count(cmd, writemostly_ARG) ? "mostly" : "behind");
 		return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fe8b761..a5c79e5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -239,6 +239,7 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 
 	/* FIXME: Check thin-pool and thin more thoroughly! */
 	if (!strcmp(type_str, "snapshot") ||
+	    !strcmp(type_str, "striped") ||
 	    !strncmp(type_str, "raid", 4) ||
 	    !strcmp(type_str, "cache-pool") || !strcmp(type_str, "cache") ||
 	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
@@ -378,6 +379,12 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	if (!_check_conversion_type(cmd, type_str))
 		return_0;
 
+	if (arg_count(cmd, type_ARG) &&
+	    !(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, NULL))))
+		return_0;
+	if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+		return_0;
+
 	if (arg_count(cmd, repair_ARG) &&
 	    arg_outside_list_is_set(cmd, "cannot be used with --repair",
 				    repair_ARG,
@@ -1160,7 +1167,8 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	*new_mimage_count = lp->mirrors;
 
 	/* Too many mimages? */
-	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+	if ((!arg_count(cmd, type_ARG) || strcmp(arg_str_value(cmd, type_ARG, NULL), SEG_TYPE_NAME_RAID1)) &&
+	    lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Only up to %d images in mirror supported currently.",
 			  DEFAULT_MIRROR_MAX_IMAGES);
 		return 0;
@@ -1254,7 +1262,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 	if ((lp->mirrors == 1) && !lv_is_mirrored(lv)) {
 		log_warn("Logical volume %s is already not mirrored.",
 			 lv->name);
-		return 1;
+		return 2; /* Indicate fact it's already converted to caller */
 	}
 
 	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
@@ -1577,7 +1585,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	int repair = arg_count(cmd, repair_ARG);
+	int r, repair = arg_count(cmd, repair_ARG);
 	uint32_t old_mimage_count;
 	uint32_t old_log_count;
 	uint32_t new_mimage_count;
@@ -1629,29 +1637,17 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	if (repair)
 		return _lvconvert_mirrors_repair(cmd, lv, lp);
 
-	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
-				    new_mimage_count, new_log_count))
+	if (!(r = _lvconvert_mirrors_aux(cmd, lv, lp, NULL,
+					 new_mimage_count, new_log_count)))
 		return 0;
 
-	if (!lp->need_polling)
+	if (r != 2 && !lp->need_polling)
 		log_print_unless_silent("Logical volume %s converted.", lv->name);
 
 	backup(lv->vg);
 	return 1;
 }
 
-static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
-				    const struct segment_type *to_segtype)
-{
-	if (from_segtype == to_segtype)
-		return 1;
-
-	if (!segtype_is_raid(from_segtype) && !segtype_is_raid(to_segtype))
-		return_0;  /* Not converting to or from RAID? */
-
-	return 1;
-}
-
 static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
 				       struct lvconvert_params *lp,
 				       int *replace_dev)
@@ -1701,13 +1697,6 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (!_lvconvert_validate_thin(lv, lp))
 		return_0;
 
-	if (!_is_valid_raid_conversion(seg->segtype, lp->segtype)) {
-		log_error("Unable to convert %s/%s from %s to %s",
-			  lv->vg->name, lv->name,
-			  lvseg_name(seg), lp->segtype->name);
-		return 0;
-	}
-
 	/* Change number of RAID1 images */
 	if (arg_count(cmd, mirrors_ARG) || arg_count(cmd, splitmirrors_ARG)) {
 		image_count = lv_raid_image_count(lv);
@@ -1739,8 +1728,21 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (arg_count(cmd, mirrors_ARG))
 		return lv_raid_change_image_count(lv, image_count, lp->pvh);
 
-	if (arg_count(cmd, type_ARG))
-		return lv_raid_reshape(lv, lp->segtype);
+	if ((seg_is_linear(seg) || seg_is_striped(seg) || seg_is_mirrored(seg) || lv_is_raid(lv)) &&
+	    (arg_count(cmd, type_ARG) ||
+	     image_count ||
+	     arg_count(cmd, stripes_long_ARG) ||
+	     arg_count(cmd, stripesize_ARG))) {
+		unsigned stripe_size = arg_count(cmd, stripesize_ARG) ? lp->stripe_size  : 0;
+
+		if (segtype_is_any_raid0(lp->segtype) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
+			log_error("RAID module does not support RAID0.");
+			return 0;
+		}
+
+		return lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, image_count, lp->stripes, stripe_size, lp->pvh);
+	}
 
 	if (arg_count(cmd, replace_ARG))
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
@@ -1754,7 +1756,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
-		if (!lv_raid_percent(lv, &sync_percent)) {
+		if (!seg_is_striped(seg) &&
+		    !seg_is_any_raid0(seg) &&
+		    !lv_raid_percent(lv, &sync_percent)) {
 			log_error("Unable to determine sync status of %s/%s.",
 				  lv->vg->name, lv->name);
 			return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e41f76c..d7383b0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -453,7 +453,7 @@ static int _read_mirror_params(struct cmd_context *cmd,
 static int _read_raid_params(struct cmd_context *cmd,
 			     struct lvcreate_params *lp)
 {
-	if ((lp->stripes < 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	if ((lp->stripes < 2) && segtype_is_raid10(lp->segtype)) {
 		if (arg_count(cmd, stripes_ARG)) {
 			/* User supplied the bad argument */
 			log_error("Segment type 'raid10' requires 2 or more stripes.");
@@ -467,8 +467,9 @@ static int _read_raid_params(struct cmd_context *cmd,
 	/*
 	 * RAID1 does not take a stripe arg
 	 */
-	if ((lp->stripes > 1) && seg_is_mirrored(lp) &&
-	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	if ((lp->stripes > 1) &&
+	    (seg_is_mirrored(lp) || segtype_is_raid1(lp->segtype)) &&
+	    !segtype_is_raid10(lp->segtype)) {
 		log_error("Stripe argument cannot be used with segment type, %s",
 			  lp->segtype->name);
 		return 0;
@@ -504,15 +505,26 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 
 	/* Common mirror and raid params */
 	if (arg_count(cmd, mirrors_ARG)) {
+		unsigned max_images;
+		const char *type;
+
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
+		if (segtype_is_raid1(lp->segtype)) {
+			type = SEG_TYPE_NAME_RAID1;
+			max_images = DEFAULT_RAID_MAX_IMAGES;
+		} else {
+			type = "mirror";
+			max_images = DEFAULT_MIRROR_MAX_IMAGES;
+		}
 
-		if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
-			log_error("Only up to " DM_TO_STRING(DEFAULT_MIRROR_MAX_IMAGES)
-				  " images in mirror supported currently.");
+		if (lp->mirrors > max_images) {
+			log_error("Only up to %u images in %s supported currently.",
+				  max_images, type);
 			return 0;
 		}
 
-		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+		if (lp->mirrors > 2 &&
+		    segtype_is_raid10(lp->segtype)) {
 			/*
 			 * FIXME: When RAID10 is no longer limited to
 			 *        2-way mirror, 'lv_mirror_count()'
@@ -534,6 +546,14 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
 
+	if (lp->stripes < 2 &&
+	    (segtype_is_any_raid0(lp->segtype) || segtype_is_raid10(lp->segtype)))
+		if (arg_count(cmd, stripes_ARG)) {
+			/* User supplied the bad argument */
+			log_error("Segment type 'raid(1)0' requires 2 or more stripes.");
+			return 0;
+		}
+
 	lp->nosync = arg_is_set(cmd, nosync_ARG);
 
 	if (!(lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0)) &&
@@ -548,6 +568,26 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/*
+	 * RAID1 does not take a stripe arg
+	 */
+	if ((lp->stripes > 1) &&
+	    (seg_is_mirrored(lp) || segtype_is_raid1(lp->segtype)) &&
+	    !segtype_is_any_raid0(lp->segtype) &&
+	    !segtype_is_raid10(lp->segtype)) {
+		log_error("Stripe argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	if (arg_count(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
+	    !segtype_is_raid1(lp->segtype) &&
+	    !segtype_is_raid10(lp->segtype)) {
+		log_error("Mirror argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
 	if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
 		log_error("Region size (%" PRIu32 ") must be a multiple of "
 			  "machine memory page size (%d)",
@@ -974,7 +1014,13 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10) &&
+		if (segtype_is_any_raid0(lp->segtype) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID0)) {
+			log_error("RAID module does not support RAID0.");
+			return 0;
+		}
+
+		if (segtype_is_raid10(lp->segtype) &&
 		    !(lp->target_attr & RAID_FEATURE_RAID10)) {
 			log_error("RAID module does not support RAID10.");
 			return 0;
@@ -1204,29 +1250,26 @@ static int _check_raid_parameters(struct volume_group *vg,
 	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
 	struct cmd_context *cmd = vg->cmd;
 
-	/*
-	 * If number of devices was not supplied, we can infer from
-	 * the PVs given.
-	 */
 	if (!seg_is_mirrored(lp)) {
 		if (!arg_count(cmd, stripes_ARG) &&
 		    (devs > 2 * lp->segtype->parity_devs))
-			lp->stripes = devs - lp->segtype->parity_devs;
+			lp->stripes = 2; /* Or stripe bomb with many devs given */
 
 		if (!lp->stripe_size)
 			lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 
-		if (lp->stripes <= lp->segtype->parity_devs) {
+		if (lp->stripes < 2) { // <= lp->segtype->parity_devs) {
 			log_error("Number of stripes must be at least %d for %s",
 				  lp->segtype->parity_devs + 1,
 				  lp->segtype->name);
 			return 0;
 		}
-	} else if (!strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+	} else if (segtype_is_any_raid0(lp->segtype) ||
+		   segtype_is_raid10(lp->segtype)) {
 		if (!arg_count(cmd, stripes_ARG))
 			lp->stripes = devs / lp->mirrors;
 		if (lp->stripes < 2) {
-			log_error("Unable to create RAID10 LV,"
+			log_error("Unable to create RAID(1)0 LV,"
 				  " insufficient number of devices.");
 			return 0;
 		}


