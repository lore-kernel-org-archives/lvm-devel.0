From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:02:59 +0000 (UTC)
Subject: master - report: use same info also for lv_attr
Message-ID: <20150120140259.BB5B060D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3a348c03c67b490ad1a8517168454dc6d5563da
Commit:        b3a348c03c67b490ad1a8517168454dc6d5563da
Parent:        e34b004422f0d51263e0d34f4064556cfc9148f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 13:14:16 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 14:58:41 2015 +0100

report: use same info also for  lv_attr

Recently the single 'status' code has been used for number of cache
features.

Extend the API a little bit to allow usage also for lv_attr_dup.

As the function itself is used in lvm2api - add a new function:
lv_attr_dup_with_info_and_seg_status() that is able to use
grabbed info & status information.

report_init() is now using directly passed lvdm struct pointer
which holds the infomation whether lv_info() was correctly obtained or
there was some error when trying to read it.

Move 'healt' attribute to status.
TODO convert raid function to use the already known status.
---
 lib/activate/activate.h    |    8 ++++++-
 lib/activate/dev_manager.c |   21 ++++++++---------
 lib/metadata/lv.c          |   50 +++++++++++++++++++++++++++----------------
 lib/metadata/lv.h          |    3 ++
 lib/report/columns.h       |    4 +-
 lib/report/report.c        |   35 ++++++++++++------------------
 6 files changed, 67 insertions(+), 54 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 7cb8271..306ebd8 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -44,7 +44,13 @@ struct lv_seg_status {
 	struct dm_pool *mem;			/* input */
 	const struct lv_segment *seg;		/* input */
 	lv_seg_status_type_t type;		/* output */
-	const void *status; /* struct dm_status_* */	/* output */
+	union {
+		struct dm_status_cache *cache;
+		struct dm_status_raid *raid;
+		struct dm_status_snapshot *snapshot;
+		struct dm_status_thin *thin;
+		struct dm_status_thin_pool *thin_pool;
+	};
 };
 
 struct lv_with_info_and_seg_status {
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index f310a67..015af5b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -121,6 +121,7 @@ static int _get_segment_status_from_target_params(const char *target_name,
 {
 	struct segment_type *segtype;
 
+	seg_status->type = SEG_STATUS_UNKNOWN;
 	/*
 	 * TODO: Add support for other segment types too!
 	 * The segment to report status for must be properly
@@ -142,30 +143,28 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	}
 
 	if (!strcmp(segtype->name, "cache")) {
-		if (!dm_get_status_cache(seg_status->mem, params,
-			(struct dm_status_cache **) &seg_status->status))
-				return_0;
+		if (!dm_get_status_cache(seg_status->mem, params, &(seg_status->cache)))
+			return_0;
 		seg_status->type = SEG_STATUS_CACHE;
 	} else if (!strcmp(segtype->name, "raid")) {
-		if (!dm_get_status_raid(seg_status->mem, params,
-					(struct dm_status_raid **) &seg_status->status))
+		if (!dm_get_status_raid(seg_status->mem, params, &seg_status->raid))
 			return_0;
 		seg_status->type = SEG_STATUS_RAID;
 	} else if (!strcmp(segtype->name, "thin")) {
-		if (!dm_get_status_thin(seg_status->mem, params,
-					(struct dm_status_thin **) &seg_status->status))
+		if (!dm_get_status_thin(seg_status->mem, params, &seg_status->thin))
 			return_0;
 		seg_status->type = SEG_STATUS_THIN;
 	} else if (!strcmp(segtype->name, "thin-pool")) {
-		if (!dm_get_status_thin_pool(seg_status->mem, params,
-					     (struct dm_status_thin_pool **) &seg_status->status))
+		if (!dm_get_status_thin_pool(seg_status->mem, params, &seg_status->thin_pool))
 			return_0;
 		seg_status->type = SEG_STATUS_THIN_POOL;
 	} else if (!strcmp(segtype->name, "snapshot")) {
-		if (!dm_get_status_snapshot(seg_status->mem, params,
-					    (struct dm_status_snapshot **) &seg_status->status))
+		if (!dm_get_status_snapshot(seg_status->mem, params, &seg_status->snapshot))
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
+	} else {
+		log_error(INTERNAL_ERROR "Unsupported segment type %s.", segtype->name);
+		return 0;
 	}
 
 	return 1;
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8682535..cb6577d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -644,12 +644,11 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	return 1;
 }
 
-char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
+char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm)
 {
 	dm_percent_t snap_percent;
-	struct lvinfo info;
+	const struct logical_volume *lv = lvdm->lv;
 	struct lv_segment *seg;
-	struct lv_seg_status seg_status;
 	char *repstr;
 
 	if (!(repstr = dm_pool_zalloc(mem, 11))) {
@@ -722,30 +721,30 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
-	if (!activation() || !lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
+	if (!activation() || !lvdm->info_ok) {
 		repstr[4] = 'X';		/* Unknown */
 		repstr[5] = 'X';		/* Unknown */
-	} else if (info.exists) {
-		if (info.suspended)
+	} else if (lvdm->info.exists) {
+		if (lvdm->info.suspended)
 			repstr[4] = 's';	/* Suspended */
-		else if (info.live_table)
+		else if (lvdm->info.live_table)
 			repstr[4] = 'a';	/* Active */
-		else if (info.inactive_table)
+		else if (lvdm->info.inactive_table)
 			repstr[4] = 'i';	/* Inactive with table */
 		else
 			repstr[4] = 'd';	/* Inactive without table */
 
 		/* Snapshot dropped? */
-		if (info.live_table && lv_is_cow(lv)) {
+		if (lvdm->info.live_table && lv_is_cow(lv)) {
 			if (!lv_snapshot_percent(lv, &snap_percent) ||
 			    snap_percent == DM_PERCENT_INVALID) {
-				if (info.suspended)
+				if (lvdm->info.suspended)
 					repstr[4] = 'S'; /* Susp Inv snapshot */
 				else
 					repstr[4] = 'I'; /* Invalid snapshot */
 			}
 			else if (snap_percent == LVM_PERCENT_MERGE_FAILED) {
-				if (info.suspended)
+				if (lvdm->info.suspended)
 					repstr[4] = 'M'; /* Susp snapshot merge failed */
 				else
 					repstr[4] = 'm'; /* snapshot merge failed */
@@ -756,10 +755,10 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		 * 'R' indicates read-only activation of a device that
 		 * does not have metadata flagging it as read-only.
 		 */
-		if (repstr[1] != 'r' && info.read_only)
+		if (repstr[1] != 'r' && lvdm->info.read_only)
 			repstr[1] = 'R';
 
-		repstr[5] = (info.open_count) ? 'o' : '-';
+		repstr[5] = (lvdm->info.open_count) ? 'o' : '-';
 	} else {
 		repstr[4] = '-';
 		repstr[5] = '-';
@@ -803,15 +802,15 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
 		} else if (lv->status & LV_WRITEMOSTLY)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
-	} else if (lv_is_thin_pool(lv)) {
-		seg_status.mem = lv->vg->cmd->mem;
-		if (!lv_status(lv->vg->cmd, first_seg(lv), &seg_status))
+	} else if (lv_is_thin_pool(lv) &&
+		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
+		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
 			repstr[8] = 'X'; /* Unknown */
-		else if (((struct dm_status_thin_pool *)seg_status.status)->fail)
+		else if (lvdm->seg_status.thin_pool->fail)
 			repstr[8] = 'F';
-		else if (((struct dm_status_thin_pool *)seg_status.status)->out_of_data_space)
+		else if (lvdm->seg_status.thin_pool->out_of_data_space)
 			repstr[8] = 'D';
-		else if (((struct dm_status_thin_pool *)seg_status.status)->read_only)
+		else if (lvdm->seg_status.thin_pool->read_only)
 			repstr[8] = 'M';
 	}
 
@@ -824,6 +823,19 @@ out:
 	return repstr;
 }
 
+/* backward compatible internal API for lvm2api, TODO improve it */
+char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct lv_with_info_and_seg_status status = {
+		.seg_status.type = SEG_STATUS_NONE
+	};
+
+	if (!lv_info_with_seg_status(lv->vg->cmd, lv, first_seg(lv), 1, &status, 1, 1))
+		return_NULL;
+
+	return lv_attr_dup_with_info_and_seg_status(mem, &status);
+}
+
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 6c6df73..cb5885d 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -54,8 +54,11 @@ struct logical_volume {
 	const char *hostname;
 };
 
+struct lv_with_info_and_seg_status;
+
 uint64_t lv_size(const struct logical_volume *lv);
 uint64_t lv_metadata_size(const struct logical_volume *lv);
+char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 9f64ac8..fbbbe9d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -38,7 +38,7 @@ FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV in
 FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
-FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+FIELD(LVSSTATUS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR_LIST, "Layout", lvid, 10, lvlayout, lv_layout, "LV layout.", 0)
 FIELD(LVS, lv, STR_LIST, "Role", lvid, 10, lvrole, lv_role, "LV role.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
@@ -50,7 +50,6 @@ FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_loc
 FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV has fixed minor number assigned.", 0)
 FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
 FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
-FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, BIN, "WhenFull", lvid, 15, lverrorwhenfull, lv_error_when_full, "For thin pools, behavior when full.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
@@ -103,6 +102,7 @@ FIELD(LVSSTATUS, lv, NUM, "CacheReadHits", lvid, 16, cache_read_hits, cache_read
 FIELD(LVSSTATUS, lv, NUM, "CacheReadMisses", lvid, 16, cache_read_misses, cache_read_misses, "Cache read misses.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteHits", lvid, 16, cache_write_hits, cache_write_hits, "Cache write hits.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 16, cache_write_misses, cache_write_misses, "Cache write misses.", 0)
+FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 1b1ccca..4338190 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -415,10 +415,10 @@ static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct d
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 	char *repstr;
 
-	if (!(repstr = lv_attr_dup(mem, lv)))
+	if (!(repstr = lv_attr_dup_with_info_and_seg_status(mem, lvdm)))
 		return_0;
 
 	return _field_set_value(field, repstr, NULL);
@@ -1770,8 +1770,8 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 				struct dm_report_field *field,
 				const void *data, void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lv_seg_status seg_status;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+	const struct logical_volume *lv = lvdm->lv;
 	const char *health = "";
 	uint64_t n;
 
@@ -1787,15 +1787,15 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 				health = "mismatches exist";
 		} else if (lv->status & LV_WRITEMOSTLY)
 			health = "writemostly";
-	} else if (lv_is_thin_pool(lv)) {
-		seg_status.mem = lv->vg->cmd->mem;
-		if (!lv_status(lv->vg->cmd, first_seg(lv), &seg_status))
-			health = "unknown";
-		else if (((struct dm_status_thin_pool *)seg_status.status)->fail)
+	} else if (lv_is_thin_pool(lv) && (lvdm->seg_status.type != SEG_STATUS_NONE)) {
+		if (lvdm->seg_status.type != SEG_STATUS_THIN_POOL)
+			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
+						GET_FIELD_RESERVED_VALUE(health_undef));
+		else if (lvdm->seg_status.thin_pool->fail)
 			health = "failed";
-		else if (((struct dm_status_thin_pool *)seg_status.status)->out_of_data_space)
+		else if (lvdm->seg_status.thin_pool->out_of_data_space)
 			health = "out_of_data";
-		else if (((struct dm_status_thin_pool *)seg_status.status)->read_only)
+		else if (lvdm->seg_status.thin_pool->read_only)
 			health = "metadata_read_only";
 	}
 
@@ -1824,7 +1824,7 @@ static int _cache_ ## cache_status_field_name ## _disp (struct dm_report *rh, \
 	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data; \
 	if (lvdm->seg_status.type != SEG_STATUS_CACHE) \
 		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
-	return dm_report_field_uint64(rh, field, (void *) ((char *) lvdm->seg_status.status + offsetof(struct dm_status_cache, cache_status_field_name))); \
+	return dm_report_field_uint64(rh, field, &lvdm->seg_status.cache->cache_status_field_name); \
 }
 
 GENERATE_CACHE_STATUS_DISP_FN(total_blocks)
@@ -1997,27 +1997,20 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 int report_object(void *handle, const struct volume_group *vg,
 		  const struct logical_volume *lv, const struct physical_volume *pv,
 		  const struct lv_segment *seg, const struct pv_segment *pvseg,
-		  const struct lvinfo *lvinfo,  const struct lv_seg_status *lv_seg_status,
+		  const struct lv_with_info_and_seg_status *lvdm,
 		  const struct label *label)
 {
 	struct device dummy_device = { .dev = 0 };
 	struct label dummy_label = { .dev = &dummy_device };
-	struct lv_with_info_and_seg_status lvdm = { .lv = lv };
 	struct lvm_report_object obj = {
 		.vg = (struct volume_group *) vg,
-		.lvdm = &lvdm,
+		.lvdm = (struct lv_with_info_and_seg_status *) lvdm,
 		.pv = (struct physical_volume *) pv,
 		.seg = (struct lv_segment *) seg,
 		.pvseg = (struct pv_segment *) pvseg,
 		.label = (struct label *) (label ? : (pv ? pv_label(pv) : NULL))
 	};
 
-	if (lvinfo)
-		lvdm.info = *lvinfo;
-
-	if (lv_seg_status)
-		lvdm.seg_status = *lv_seg_status;
-
 	/* FIXME workaround for pv_label going through cache; remove once struct
 	 * physical_volume gains a proper "label" pointer */
 	if (!obj.label) {


