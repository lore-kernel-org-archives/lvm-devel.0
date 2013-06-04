From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:00 +0000 (UTC)
Subject: dev-mornfall-activate - RAID: Add writemostly/writebehind support for RAID1
Message-ID: <20130604192400.B12FB60E4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e0740f7ef420c7b981bc67cb606d180701b8c1d
Commit:        2e0740f7ef420c7b981bc67cb606d180701b8c1d
Parent:        dce8d06af7e5a14a1507bea0e64e6cc27556cbc7
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Apr 15 13:59:46 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Apr 15 13:59:46 2013 -0500

RAID:  Add writemostly/writebehind support for RAID1

'lvchange' is used to alter a RAID 1 logical volume's write-mostly and
write-behind characteristics.  The '--writemostly' parameter takes a
PV as an argument with an optional trailing character to specify whether
to set ('y'), unset ('n'), or toggle ('t') the value.  If no trailing
character is given, it will set the flag.
Synopsis:
        lvchange [--writemostly <PV>:{t|y|n}] [--writebehind <count>] vg/lv
Example:
        lvchange --writemostly /dev/sdb1:y --writebehind 512 vg/raid1_lv

The last character in the 'lv_attr' field is used to show whether a device
has the WriteMostly flag set.  It is signified with a 'w'.  If the device
has failed, the 'p'artial flag has priority.

Example ("nosync" raid1 with mismatch_cnt and writemostly):
[~]# lvs -a --segment vg
  LV                VG   Attr      #Str Type   SSize
  raid1             vg   Rwi---r-m    2 raid1  500.00m
  [raid1_rimage_0]  vg   Iwi---r--    1 linear 500.00m
  [raid1_rimage_1]  vg   Iwi---r-w    1 linear 500.00m
  [raid1_rmeta_0]   vg   ewi---r--    1 linear   4.00m
  [raid1_rmeta_1]   vg   ewi---r--    1 linear   4.00m

Example (raid1 with mismatch_cnt, writemostly - but failed drive):
[~]# lvs -a --segment vg
  LV                VG   Attr      #Str Type   SSize
  raid1             vg   rwi---r-p    2 raid1  500.00m
  [raid1_rimage_0]  vg   Iwi---r--    1 linear 500.00m
  [raid1_rimage_1]  vg   Iwi---r-p    1 linear 500.00m
  [raid1_rmeta_0]   vg   ewi---r--    1 linear   4.00m
  [raid1_rmeta_1]   vg   ewi---r-p    1 linear   4.00m

A new reportable field has been added for writebehind as well.  If
write-behind has not been set or the LV is not RAID1, the field will
be blank.
Example (writebehind is set):
[~]# lvs -a -o name,attr,writebehind vg
  LV            Attr      WBehind
  lv            rwi-a-r--     512
  [lv_rimage_0] iwi-aor-w
  [lv_rimage_1] iwi-aor--
  [lv_rmeta_0]  ewi-aor--
  [lv_rmeta_1]  ewi-aor--

Example (writebehind is not set):
[~]# lvs -a -o name,attr,writebehind vg
  LV            Attr      WBehind
  lv            rwi-a-r--
  [lv_rimage_0] iwi-aor-w
  [lv_rimage_1] iwi-aor--
  [lv_rmeta_0]  ewi-aor--
  [lv_rmeta_1]  ewi-aor--
---
 WHATS_NEW                        |    1 +
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv.c                |    8 ++-
 lib/metadata/lv_manip.c          |   85 ++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    8 ++
 lib/metadata/raid_manip.c        |   94 +++------------------------
 lib/raid/raid.c                  |   43 ++++++++++++-
 lib/report/columns.h             |    1 +
 lib/report/properties.c          |    6 ++
 lib/report/report.c              |   18 +++++-
 libdm/libdevmapper.h             |   30 +++++++++
 libdm/libdm-deptree.c            |   58 +++++++++++++----
 man/lvchange.8.in                |   21 ++++++
 man/lvs.8.in                     |    6 +-
 scripts/gdbinit                  |    5 ++
 test/shell/lvchange-raid.sh      |   99 ++++++++++++++++++++++++++++-
 tools/args.h                     |    2 +
 tools/commands.h                 |    4 +-
 tools/lvchange.c                 |  132 ++++++++++++++++++++++++++++++++++++++
 19 files changed, 514 insertions(+), 108 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 31c33fe..76347e9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add writemostly/writebehind support for RAID1
   Add lv_change_activate() for common activation code in vg/lvchange.
   Revert change that allowed identical table reload for RAID.
   New lvchange arg, '--syncaction' allows scrubbing of RAID LVs.
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 2a6b7a5..28a7dc4 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -58,6 +58,7 @@ static const struct flag _lv_flags[] = {
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
+	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 5cb87c3..6afa468 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -604,9 +604,11 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		uint64_t n;
 		if (!_lv_raid_healthy(lv))
 			repstr[8] = 'r';  /* RAID needs 'r'efresh */
-		else if ((lv->status & RAID) &&
-			 lv_raid_mismatch_count(lv, &n) && n)
-			repstr[8] = 'm';  /* RAID contains 'm'ismatches */
+		else if (lv->status & RAID) {
+			if (lv_raid_mismatch_count(lv, &n) && n)
+				repstr[8] = 'm';  /* RAID has 'm'ismatches */
+		} else if (lv->status & LV_WRITEMOSTLY)
+			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
 	}
 
 out:
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 10331c3..fc316e8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -73,6 +73,91 @@ struct lv_names {
 };
 
 /*
+ * lv_is_on_pv
+ * @lv:
+ * @pv:
+ *
+ * If any of the component devices of the LV are on the given PV, 1
+ * is returned; otherwise 0.  For example if one of the images of a RAID
+ * (or its metadata device) is on the PV, 1 would be returned for the
+ * top-level LV.
+ * If you wish to check the images themselves, you should pass them.
+ *
+ * FIXME:  This should be made more generic, possibly use 'for_each_sub_lv'.
+ * 'for_each_sub_lv' does not yet allow us to short-circuit execution or
+ * pass back the values we need yet though...
+ *
+ * Returns: 1 if LV (or part of LV) is on PV, 0 otherwise
+ */
+int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
+{
+	uint32_t s;
+	struct physical_volume *pv2;
+	struct lv_segment *seg;
+
+	if (!lv)
+		return 0;
+
+	seg = first_seg(lv);
+	if (!seg)
+		return 0;
+
+	/* Check mirror log */
+	if (lv_is_on_pv(seg->log_lv, pv))
+		return 1;
+
+	/* Check stack of LVs */
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) == AREA_PV) {
+				pv2 = seg_pv(seg, s);
+				if (id_equal(&pv->id, &pv2->id))
+					return 1;
+				if (pv->dev && pv2->dev &&
+				    (pv->dev->dev == pv2->dev->dev))
+					return 1;
+			}
+
+			if ((seg_type(seg, s) == AREA_LV) &&
+			    lv_is_on_pv(seg_lv(seg, s), pv))
+				return 1;
+
+			if (!seg_is_raid(seg))
+				continue;
+
+			/* This is RAID, so we know the meta_area is AREA_LV */
+			if (lv_is_on_pv(seg_metalv(seg, s), pv))
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+/*
+ * lv_is_on_pvs
+ * @lv
+ * @pvs
+ *
+ * Returns 1 if the LV (or part of the LV) is on any of the pvs
+ * in the list, 0 otherwise.
+ */
+int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, pvs)
+		if (lv_is_on_pv(lv, pvl->pv)) {
+			log_debug_metadata("%s is on %s", lv->name,
+					   pv_dev_name(pvl->pv));
+			return 1;
+		} else
+			log_debug_metadata("%s is not on %s", lv->name,
+					   pv_dev_name(pvl->pv));
+	return 0;
+}
+
+/*
  * get_default_region_size
  * @cmd
  *
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index df21759..a4ffe26 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -90,6 +90,8 @@
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
 
+#define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
+
 #define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
 #define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
 
@@ -334,6 +336,7 @@ struct lv_segment {
 
 	/* FIXME Fields depend on segment type */
 	uint32_t stripe_size;	/* For stripe and RAID - in sectors */
+	uint32_t writebehind;   /* For RAID (RAID1 only) */
 	uint32_t area_count;
 	uint32_t area_len;
 	uint32_t chunk_size;	/* For snapshots/thin_pool.  In sectors. */
@@ -696,6 +699,11 @@ const char *find_vgname_from_pvname(struct cmd_context *cmd,
 				    const char *pvname);
 const char *find_vgname_from_pvid(struct cmd_context *cmd,
 				  const char *pvid);
+
+int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv);
+int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs);
+
+
 /* Find LV segment containing given LE */
 struct lv_segment *first_seg(const struct logical_volume *lv);
 struct lv_segment *last_seg(const struct logical_volume *lv);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 43cf14e..38ea2c2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -93,81 +93,6 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 	return 1;
 }
 
-/*
- * _lv_is_on_pv
- * @lv:
- * @pv:
- *
- * If any of the component devices of the LV are on the given PV, 1
- * is returned; otherwise 0.  For example if one of the images of a RAID
- * (or its metadata device) is on the PV, 1 would be returned for the
- * top-level LV.
- * If you wish to check the images themselves, you should pass them.
- *
- * FIXME:  This should be made more generic, possibly use 'for_each_sub_lv',
- * and be put in lv_manip.c.  'for_each_sub_lv' does not yet allow us to
- * short-circuit execution or pass back the values we need yet though...
- */
-static int _lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
-{
-	uint32_t s;
-	struct physical_volume *pv2;
-	struct lv_segment *seg;
-
-	if (!lv)
-		return 0;
-
-	seg = first_seg(lv);
-	if (!seg)
-		return 0;
-
-	/* Check mirror log */
-	if (_lv_is_on_pv(seg->log_lv, pv))
-		return 1;
-
-	/* Check stack of LVs */
-	dm_list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) == AREA_PV) {
-				pv2 = seg_pv(seg, s);
-				if (id_equal(&pv->id, &pv2->id))
-					return 1;
-				if (pv->dev && pv2->dev &&
-				    (pv->dev->dev == pv2->dev->dev))
-					return 1;
-			}
-
-			if ((seg_type(seg, s) == AREA_LV) &&
-			    _lv_is_on_pv(seg_lv(seg, s), pv))
-				return 1;
-
-			if (!seg_is_raid(seg))
-				continue;
-
-			/* This is RAID, so we know the meta_area is AREA_LV */
-			if (_lv_is_on_pv(seg_metalv(seg, s), pv))
-				return 1;
-		}
-	}
-
-	return 0;
-}
-
-static int _lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
-{
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, pvs)
-		if (_lv_is_on_pv(lv, pvl->pv)) {
-			log_debug_metadata("%s is on %s", lv->name,
-					   pv_dev_name(pvl->pv));
-			return 1;
-		} else
-			log_debug_metadata("%s is not on %s", lv->name,
-					   pv_dev_name(pvl->pv));
-	return 0;
-}
-
 static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
 {
 	uint32_t s;
@@ -1009,8 +934,8 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 				  seg_metalv(seg, s)->name, seg_lv(seg, s)->name);
 		} else {
 			/* Conditions for second pass */
-			if (!_lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
-			    !_lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
+			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 				continue;
 
 			if (!_raid_in_sync(lv) &&
@@ -1069,7 +994,8 @@ static int _raid_remove_images(struct logical_volume *lv,
 				  " after linear conversion");
 			return 0;
 		}
-		lv->status &= ~LV_NOTSYNCED;
+		lv->status &= ~(LV_NOTSYNCED | LV_WRITEMOSTLY);
+		first_seg(lv)->writebehind = 0;
 	}
 
 	if (!vg_write(lv->vg)) {
@@ -1211,7 +1137,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	 * complete the split of the tracking sub-LV
 	 */
 	if (_lv_is_raid_with_tracking(lv, &tracking)) {
-		if (!_lv_is_on_pvs(tracking, splittable_pvs)) {
+		if (!lv_is_on_pvs(tracking, splittable_pvs)) {
 			log_error("Unable to split additional image from %s "
 				  "while tracking changes for %s",
 				  lv->name, tracking->name);
@@ -1344,7 +1270,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	}
 
 	for (s = seg->area_count - 1; s >= 0; s--) {
-		if (!_lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
+		if (!lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;
 		lv_set_visible(seg_lv(seg, s));
 		seg_lv(seg, s)->status &= ~LVM_WRITE;
@@ -1677,8 +1603,8 @@ int lv_raid_replace(struct logical_volume *lv,
 
 		if (lv_is_virtual(seg_lv(raid_seg, s)) ||
 		    lv_is_virtual(seg_metalv(raid_seg, s)) ||
-		    _lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
-		    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
+		    lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
+		    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs))
 			match_count++;
 	}
 
@@ -1706,8 +1632,8 @@ int lv_raid_replace(struct logical_volume *lv,
 			s = i % raid_seg->area_count;
 			if (!(i % copies))
 				rebuilds_per_group = 0;
-			if (_lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
-			    _lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs) ||
+			if (lv_is_on_pvs(seg_lv(raid_seg, s), remove_pvs) ||
+			    lv_is_on_pvs(seg_metalv(raid_seg, s), remove_pvs) ||
 			    lv_is_virtual(seg_lv(raid_seg, s)) ||
 			    lv_is_virtual(seg_metalv(raid_seg, s)))
 				rebuilds_per_group++;
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 1e28c73..7f453f9 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -121,6 +121,14 @@ static int _raid_text_import(struct lv_segment *seg,
 			return 0;
 		}
 	}
+	if (dm_config_has_node(sn, "writebehind")) {
+		if (!dm_config_get_uint32(sn, "writebehind", &seg->writebehind)) {
+			log_error("Couldn't read 'writebehind' for "
+				  "segment %s of logical volume %s.",
+				  dm_config_parent_name(sn), seg->lv->name);
+			return 0;
+		}
+	}
 	if (!dm_config_get_list(sn, "raids", &cv)) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
@@ -145,6 +153,8 @@ static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
 		outf(f, "region_size = %" PRIu32, seg->region_size);
 	if (seg->stripe_size)
 		outf(f, "stripe_size = %" PRIu32, seg->stripe_size);
+	if (seg->writebehind)
+		outf(f, "writebehind = %" PRIu32, seg->writebehind);
 
 	return out_areas(f, seg, "raid");
 }
@@ -161,6 +171,10 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 	uint32_t s;
 	uint64_t flags = 0;
 	uint64_t rebuilds = 0;
+	uint64_t writemostly = 0;
+	struct dm_tree_node_raid_params params;
+
+	memset(&params, 0, sizeof(params));
 
 	if (!seg->area_count) {
 		log_error(INTERNAL_ERROR "_raid_add_target_line called "
@@ -187,12 +201,35 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 		if (seg_lv(seg, s)->status & LV_REBUILD)
 			rebuilds |= 1 << s;
 
+	for (s = 0; s < seg->area_count; s++)
+		if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
+			writemostly |= 1 << s;
+
 	if (mirror_in_sync())
 		flags = DM_NOSYNC;
 
-	if (!dm_tree_node_add_raid_target(node, len, _raid_name(seg),
-					  seg->region_size, seg->stripe_size,
-					  rebuilds, flags))
+	params.raid_type = _raid_name(seg);
+	if (seg->segtype->parity_devs) {
+		/* RAID 4/5/6 */
+		params.mirrors = 1;
+		params.stripes = seg->area_count - seg->segtype->parity_devs;
+	} else if (strcmp(seg->segtype->name, "raid10")) {
+		/* RAID 10 only supports 2 mirrors now */
+		params.mirrors = 2;
+		params.stripes = seg->area_count / 2;
+	} else {
+		/* RAID 1 */
+		params.mirrors = seg->area_count;
+		params.stripes = 1;
+		params.writebehind = seg->writebehind;
+	}
+	params.region_size = seg->region_size;
+	params.stripe_size = seg->stripe_size;
+	params.rebuilds = rebuilds;
+	params.writemostly = writemostly;
+	params.flags = flags;
+
+	if (!dm_tree_node_add_raid_target_with_params(node, len, &params))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index b6dc483..42858f1 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -82,6 +82,7 @@ FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, m
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
+FIELD(LVS, lv, NUM, "WBehind", lvid, 7, write_behind, writebehind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c04a6a1..71b3cb1 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -109,6 +109,10 @@ static char *_sync_action(const struct logical_volume *lv) {
 	return action;
 }
 
+static uint32_t _writebehind(const struct logical_volume *lv) {
+	return first_seg(lv)->writebehind;
+}
+
 static percent_t _snap_percent(const struct logical_volume *lv) {
 	percent_t perc;
 
@@ -213,6 +217,8 @@ GET_LV_NUM_PROPERTY_FN(sync_percent, _copy_percent(lv))
 #define _sync_percent_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
 #define _mismatches_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(writebehind, _writebehind(lv))
+#define _writebehind_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
 #define _syncaction_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index 4b0ebef..8578ff7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -969,7 +969,23 @@ static int _mismatch_count_disp(struct dm_report *rh __attribute__((unused)),
 		return 1;
 	}
 
-	return  dm_report_field_uint64(rh, field, &mismatch_count);
+	return dm_report_field_uint64(rh, field, &mismatch_count);
+}
+
+static int _write_behind_disp(struct dm_report *rh __attribute__((unused)),
+			      struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data,
+			      void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (!lv_is_raid_type(lv) || !first_seg(lv)->writebehind) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 }
 
 static int _dtpercent_disp(int metadata, struct dm_report *rh,
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b3ba24d..b729846 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -643,6 +643,36 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 uint64_t rebuilds,
 				 uint64_t flags);
 
+struct dm_tree_node_raid_params {
+	const char *raid_type;
+
+	uint32_t stripes;
+	uint32_t mirrors;
+	uint32_t region_size;
+	uint32_t stripe_size;
+
+	/*
+	 * 'rebuilds' and 'writemostly' are bitfields that signify
+	 * which devices in the array are to be rebuilt or marked
+	 * writemostly.  By choosing a 'uint64_t', we limit ourself
+	 * to RAID arrays with 64 devices.
+	 */
+	uint64_t rebuilds;
+	uint64_t writemostly;
+	uint32_t writebehind;       /* I/Os (kernel default COUNTER_MAX / 2) */
+	uint32_t sync_daemon_sleep; /* ms (kernel default = 5sec) */
+	uint32_t max_recovery_rate; /* kB/sec/disk */
+	uint32_t min_recovery_rate; /* kB/sec/disk */
+	uint32_t stripe_cache;      /* sectors */
+
+	uint64_t flags;             /* [no]sync */
+	uint64_t reserved2;
+};
+
+int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
+					     uint64_t size,
+					     struct dm_tree_node_raid_params *p);
+
 /*
  * Replicator operation mode
  * Note: API for Replicator is not yet stable
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 9f82174..b084bc0 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -184,6 +184,8 @@ struct load_segment {
 	uint64_t rdevice_index;		/* Replicator-dev */
 
 	uint64_t rebuilds;	      /* raid */
+	uint64_t writemostly;	      /* raid */
+	uint32_t writebehind;	      /* raid */
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
@@ -2128,10 +2130,17 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	if (seg->region_size)
 		param_count += 2;
 
+	if (seg->writebehind)
+		param_count += 2;
+
 	/* rebuilds is 64-bit */
 	param_count += 2 * hweight32(seg->rebuilds & 0xFFFFFFFF);
 	param_count += 2 * hweight32(seg->rebuilds >> 32);
 
+	/* rebuilds is 64-bit */
+	param_count += 2 * hweight32(seg->writemostly & 0xFFFFFFFF);
+	param_count += 2 * hweight32(seg->writemostly >> 32);
+
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");
 
@@ -2150,6 +2159,13 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (seg->rebuilds & (1 << i))
 			EMIT_PARAMS(pos, " rebuild %u", i);
 
+	for (i = 0; i < (seg->area_count / 2); i++)
+		if (seg->writemostly & (1 << i))
+			EMIT_PARAMS(pos, " write_mostly %u", i);
+
+	if (seg->writebehind)
+		EMIT_PARAMS(pos, " writebehind %u", seg->writebehind);
+
 	/* Print number of metadata/data device pairs */
 	EMIT_PARAMS(pos, " %u", seg->area_count/2);
 
@@ -2826,19 +2842,15 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 	return 1;
 }
 
-int dm_tree_node_add_raid_target(struct dm_tree_node *node,
-				 uint64_t size,
-				 const char *raid_type,
-				 uint32_t region_size,
-				 uint32_t stripe_size,
-				 uint64_t rebuilds,
-				 uint64_t flags)
+int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
+					     uint64_t size,
+					     struct dm_tree_node_raid_params *p)
 {
 	int i;
 	struct load_segment *seg = NULL;
 
 	for (i = 0; dm_segtypes[i].target && !seg; i++)
-		if (!strcmp(raid_type, dm_segtypes[i].target))
+		if (!strcmp(p->raid_type, dm_segtypes[i].target))
 			if (!(seg = _add_segment(node,
 						 dm_segtypes[i].type, size)))
 				return_0;
@@ -2846,15 +2858,37 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 	if (!seg)
 		return_0;
 
-	seg->region_size = region_size;
-	seg->stripe_size = stripe_size;
+	seg->region_size = p->region_size;
+	seg->stripe_size = p->stripe_size;
 	seg->area_count = 0;
-	seg->rebuilds = rebuilds;
-	seg->flags = flags;
+	seg->rebuilds = p->rebuilds;
+	seg->writemostly = p->writemostly;
+	seg->writebehind = p->writebehind;
+	seg->flags = p->flags;
 
 	return 1;
 }
 
+int dm_tree_node_add_raid_target(struct dm_tree_node *node,
+				 uint64_t size,
+				 const char *raid_type,
+				 uint32_t region_size,
+				 uint32_t stripe_size,
+				 uint64_t rebuilds,
+				 uint64_t flags)
+{
+	struct dm_tree_node_raid_params params;
+
+	memset(&params, 0, sizeof(params));
+	params.raid_type = raid_type;
+	params.region_size = region_size;
+	params.stripe_size = stripe_size;
+	params.rebuilds = rebuilds;
+	params.flags = flags;
+
+	return dm_tree_node_add_raid_target_with_params(node, size, &params);
+}
+
 
 /*
  * Various RAID status versions include:
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 295eea2..80747d3 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -42,6 +42,8 @@ lvchange \- change attributes of a logical volume
 .RB [ \-\-refresh ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
+.RB [ \-\-writebehind BehindCount ]
+.RB [ \-\-writemostly PhysicalVolume ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
 .I LogicalVolumePath
@@ -169,6 +171,25 @@ This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
 .TP
+.BR \-\-writebehind " BehindCount"
+Specify the maximum number of outstanding writes that are allowed to
+devices in a RAID 1 logical volume that are marked as \fIwrite-mostly\fP.
+Once this value is exceeded, writes become synchronous (i.e. all writes
+to the constituent devices must complete before the array signals the
+write has completed).  Setting the value to zero clears the preference
+and allows the system to choose the value arbitrarily.
+.TP
+.BR \-\-writemostly " PhysicalVolume[:{t|y|n}]"
+Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
+to these drives will be avoided unless absolutely necessary.  This keeps
+the number of I/Os to the drive to a minimum.  The default behavior is to
+set the write-mostly attribute for the specified physical volume in the
+logical volume.  It is possible to also remove the write-mostly flag by
+appending a ":n" to the physical volume or to toggle the value by specifying
+":t".  The \fI--writemostly\fP argument can be specified more than one time
+in a single command; making it possible to toggle the write-mostly attributes
+for all the physical volumes in a logical volume at once.
+.TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting zero to
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 727353b..1626e17 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -118,6 +118,7 @@ sync_action,
 sync_percent,
 thin_count,
 transaction_id,
+writebehind,
 zero.
 .IP
 With \fB\-\-segments\fP, any "seg_" prefixes are optional;
@@ -161,7 +162,7 @@ snapshots of thin volumes using the new thin provisioning driver appear as (t).
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .IP 9 3
-Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist.
+Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist, (w)ritemostly.
 (p)artial signifies that one or more of the Physical Volumes this Logical
 Volume uses is missing from the system.  (r)efresh signifies that one or
 more of the Physical Volumes this RAID Logical Volume uses had suffered a
@@ -172,7 +173,8 @@ has portions of the array that are not coherent or that the array has
 recently repaired inconsistencies.  An additional "check" after a "repair"
 of a RAID logical volume will clear this flag if no additional discrepancies
 are found.  ("check" and "repair" of a RAID Logical Volume can be done via
-the 'lvchange' command.)
+the 'lvchange' command.)  (w)ritemostly signifies the devices in a RAID 1
+logical volume that have been marked write-mostly.
 .RE
 .TP
 .BR \-O ", " \-\-sort
diff --git a/scripts/gdbinit b/scripts/gdbinit
index fa58948..83d1c8e 100644
--- a/scripts/gdbinit
+++ b/scripts/gdbinit
@@ -324,6 +324,11 @@ define __status
 		set $_s_status = $_s_status & ~0x10000000U
 		printf " MERGING"
 	end
+#	if ($_s_status & LV_WRITEMOSTLY)
+	if ($_s_status & 0x10000000000U)
+		set $_s_status = $_s_status & ~0x10000000000U
+		printf " LV_WRITEMOSTLY"
+	end
 
 	if ($_s_status)
 		printf " 0x%x", $_s_status
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index a1c9540..0ef00b3 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -14,11 +14,102 @@
 
 . lib/test
 
-# dm-raid v1.5.0+ contains RAID scrubbing support
-aux target_at_least dm-raid 1 5 0 || skip
+# dm-raid v1.4.1+ contains RAID10 support
+aux target_at_least dm-raid 1 4 1 || skip
 
 aux prepare_vg 5
 
+# run_writemostly_check <VG> <LV>
+run_writemostly_check() {
+	d0=`lvs -a --noheadings -o devices $1/${2}_rimage_0 | sed s/\(.\)//`
+	d0=$(sed s/^[[:space:]]*// <<< "$d0")
+	d1=`lvs -a --noheadings -o devices $1/${2}_rimage_1 | sed s/\(.\)//`
+	d1=$(sed s/^[[:space:]]*// <<< "$d1")
+
+	# No writemostly flag should be there yet.
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+
+	if [ `lvs --noheadings -o segtype $1/$2` != "raid1" ]; then
+		not lvchange --writemostly $d0 $1/$2
+		return
+	fi
+
+	# Set the flag
+	lvchange --writemostly $d0 $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Running again should leave it set (not toggle)
+	lvchange --writemostly $d0 $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Running again with ':y' should leave it set
+	lvchange --writemostly $d0:y $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# ':n' should unset it
+	lvchange --writemostly $d0:n $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+
+	# ':n' again should leave it unset
+	lvchange --writemostly $d0:n $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+
+	# ':t' toggle to set
+	lvchange --writemostly $d0:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# ':t' toggle to unset
+	lvchange --writemostly $d0:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+
+	# ':y' to set
+	lvchange --writemostly $d0:y $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Toggle both at once
+	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w$'
+
+	# Toggle both@once again
+	lvchange --writemostly $d0:t --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+
+	# Toggle one, unset the other
+	lvchange --writemostly $d0:n --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*w$'
+
+	# Toggle one, set the other
+	lvchange --writemostly $d0:y --writemostly $d1:t $1/$2
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+
+	# Partial flag supercedes writemostly flag
+	aux disable_dev $d0
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*p$'
+	aux enable_dev $d0
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*w$'
+
+	# Catch Bad writebehind values
+	not lvchange --writebehind "invalid" $1/$2
+	not lvchange --writebehind -256 $1/$2
+
+	# Set writebehind
+	[ ! `lvs --noheadings -o writebehind $1/$2` ]
+	lvchange --writebehind 512 $1/$2
+	[ `lvs --noheadings -o writebehind $1/$2` -eq 512 ]
+
+	# Converting to linear should clear flags and writebehind
+	lvconvert -m 0 $1/$2 $d1
+	lvconvert --type raid1 -m 1 $1/$2 $d1
+	[ ! `lvs --noheadings -o writebehind $1/$2` ]
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-$'
+	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-$'
+}
+
 # run_syncaction_check <VG> <LV>
 run_syncaction_check() {
 	local device
@@ -109,6 +200,10 @@ run_refresh_check() {
 }
 
 run_checks() {
+	if aux target_at_least dm-raid 1 1 0; then
+		run_writemostly_check $1 $2
+	fi
+
 	if aux target_at_least dm-raid 1 5 0; then
 		run_syncaction_check $1 $2
 	fi
diff --git a/tools/args.h b/tools/args.h
index 81793a5..bfcc5b9 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -87,6 +87,8 @@ arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
 arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)
+arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
+arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 3124a13..ace077f 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -96,6 +96,8 @@ xx(lvchange,
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
    "\t[--version]\n"
+   "\t[--writebehind BehindCount\n"
+   "\t[--writemostly PhysicalVolume]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
@@ -104,7 +106,7 @@ xx(lvchange,
    major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
    permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
-   yes_ARG, zero_ARG)
+   yes_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 834ae0f..7b0a517 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -699,6 +699,125 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int
 	return 1;
 }
 
+static int lvchange_writemostly(struct logical_volume *lv)
+{
+	int s, pv_count, i = 0;
+	char **pv_names;
+	const char *tmp_str;
+	struct pv_list *pvl;
+	struct arg_value_group_list *group;
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct lv_segment *raid_seg = first_seg(lv);
+
+	if (strcmp(raid_seg->segtype->name, "raid1")) {
+		log_error("--write%s can only be used with 'raid1' segment type",
+			  arg_count(cmd, writemostly_ARG) ? "mostly" : "behind");
+		return 0;
+	}
+
+	if (arg_count(cmd, writebehind_ARG))
+		raid_seg->writebehind = arg_uint_value(cmd, writebehind_ARG, 0);
+
+	if (arg_count(cmd, writemostly_ARG)) {
+		/* writemostly can be specified more than once */
+		pv_count = arg_count(cmd, writemostly_ARG);
+		pv_names = dm_pool_alloc(cmd->mem, sizeof(char *) * pv_count);
+		if (!pv_names)
+			return_0;
+
+		dm_list_iterate_items(group, &cmd->arg_value_groups) {
+			if (!grouped_arg_is_set(group->arg_values,
+						writemostly_ARG))
+				continue;
+
+			if (!(tmp_str = grouped_arg_str_value(group->arg_values,
+							      writemostly_ARG,
+							      NULL)))
+				return_0;
+
+			/*
+			 * Writemostly PV specifications can be:
+			 *   <PV>   - Turn on writemostly
+			 *   <PV>:t - Toggle writemostly
+			 *   <PV>:n - Turn off writemostly
+			 *   <PV>:y - Turn on writemostly
+			 *
+			 * We allocate strlen + 3 to add our own ':{t|n|y}' if
+			 * not present plus the trailing '\0'.
+			 */
+			if (!(pv_names[i] = dm_pool_zalloc(cmd->mem,
+							   strlen(tmp_str) + 3)))
+				return_0;
+
+			if ((tmp_str[strlen(tmp_str) - 2] != ':') &&
+			    ((tmp_str[strlen(tmp_str) - 1] != 't') ||
+			     (tmp_str[strlen(tmp_str) - 1] != 'y') ||
+			     (tmp_str[strlen(tmp_str) - 1] != 'n')))
+				/* Default to 'y' if no mode specified */
+				sprintf(pv_names[i], "%s:y", tmp_str);
+			else
+				sprintf(pv_names[i], "%s", tmp_str);
+			i++;
+		}
+
+		for (i = 0; i < pv_count; i++)
+			pv_names[i][strlen(pv_names[i]) - 2] = '\0';
+
+		for (i = 0; i < pv_count; i++) {
+			if (!(pvl = find_pv_in_vg(lv->vg, pv_names[i]))) {
+				log_error("%s not found in volume group, %s",
+					  pv_names[i], lv->vg->name);
+				return 0;
+			}
+
+			for (s = 0; s < raid_seg->area_count; s++) {
+				/*
+				 * We don't bother checking the metadata area,
+				 * since writemostly only affects the data areas.
+				 */
+				if ((seg_type(raid_seg, s) == AREA_UNASSIGNED))
+					continue;
+
+				if (lv_is_on_pv(seg_lv(raid_seg, s), pvl->pv)) {
+					if (pv_names[i][strlen(pv_names[i]) + 1] == 'y')
+						seg_lv(raid_seg, s)->status |=
+							LV_WRITEMOSTLY;
+					else if (pv_names[i][strlen(pv_names[i]) + 1] == 'n')
+						seg_lv(raid_seg, s)->status &=
+							~LV_WRITEMOSTLY;
+					else if (pv_names[i][strlen(pv_names[i]) + 1] == 't')
+						seg_lv(raid_seg, s)->status ^=
+							LV_WRITEMOSTLY;
+					else
+						return_0;
+				}
+			}
+		}
+	}
+
+	if (!vg_write(lv->vg))
+		return_0;
+
+	if (!suspend_lv(cmd, lv)) {
+		vg_revert(lv->vg);
+		return_0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		if (!resume_lv(cmd, lv))
+			stack;
+		return_0;
+	}
+
+	log_very_verbose("Updating writemostly for \"%s\" in kernel", lv->name);
+	if (!resume_lv(cmd, lv)) {
+		log_error("Problem reactivating %s", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
@@ -870,6 +989,17 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+	/* change writemostly/writebehind */
+	if (arg_count(cmd, writemostly_ARG) || arg_count(cmd, writebehind_ARG)) {
+		if (!archived && !archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		archived = 1;
+		doit += lvchange_writemostly(lv);
+		docmds++;
+	}
+
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed", lv->name);
 
@@ -945,6 +1075,8 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
 		arg_count(cmd, syncaction_ARG) ||
+		arg_count(cmd, writebehind_ARG) ||
+		arg_count(cmd, writemostly_ARG) ||
 		arg_count(cmd, zero_ARG);
 	int update = update_partial_safe || update_partial_unsafe;
 


