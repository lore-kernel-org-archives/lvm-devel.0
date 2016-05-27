From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:54 +0000 (UTC)
Subject: master - report: convert more options to use single status
Message-ID: <20160527134754.0B0DE607A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecfb90de7405e55d79239d70838a31c66f2e926a
Commit:        ecfb90de7405e55d79239d70838a31c66f2e926a
Parent:        80603ad49aeec70c9a3f391236668f212342d10a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 25 16:26:10 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

report: convert more options to use single status

Convert fields into using a single status ioctl call per LV.
This is a bit tricky since when there are more complicated
stacks, at this moment its undefined which values should be shown.

It's clear we need to cache more then single ioctl per LV,
but also we need to define more explicitely relation between
reported values for snapshots.

This patch is not a final state, rather a transitional step.
It should not be giving more 'worst' values then previous
many-ioctl-calls-per-lv solution.
---
 WHATS_NEW            |    1 +
 lib/report/columns.h |   16 +++++-----
 lib/report/report.c  |   82 +++++++++++++------------------------------------
 3 files changed, 31 insertions(+), 68 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9f270c6..7eac3a7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  When reporting Data%,Snap%,Meta%,Cpy%Sync use single ioctl per LV.
   Add lvseg_percent_with_info_and_seg_status() for percent retrieval.
   Enhance internal seg_status handling to understand snapshots better.
   When refresh failed in suspend, call resume upon error path.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index a17b3eb..212f9ed 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -62,18 +62,18 @@ FIELD(LVS, lv, SIZ, "Rahead", lvid, 0, lvreadahead, lv_read_ahead, "Read ahead s
 FIELD(LVS, lv, SIZ, "LSize", size, 0, size64, lv_size, "Size of LV in current units.", 0)
 FIELD(LVS, lv, SIZ, "MSize", lvid, 0, lvmetadatasize, lv_metadata_size, "For thin and cache pools, the size of the LV that holds the metadata.", 0)
 FIELD(LVS, lv, NUM, "#Seg", lvid, 0, lvsegcount, seg_count, "Number of segments in LV.", 0)
-FIELD(LVS, lv, STR, "Origin", lvid, 0, origin, origin, "For snapshots, the origin device of this LV.", 0)
-FIELD(LVS, lv, STR, "Origin UUID", lvid, 38, originuuid, origin_uuid, "For snapshots, the UUID of origin device of this LV.", 0)
+FIELD(LVS, lv, STR, "Origin", lvid, 0, origin, origin, "For snapshots and thins, the origin device of this LV.", 0)
+FIELD(LVS, lv, STR, "Origin UUID", lvid, 38, originuuid, origin_uuid, "For snapshots and thins, the UUID of origin device of this LV.", 0)
 FIELD(LVS, lv, SIZ, "OSize", lvid, 0, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
 FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 0, lvancestors, lv_ancestors, "LV ancestors ignoring any stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "FAncestors", lvid, 0, lvfullancestors, lv_full_ancestors, "LV ancestors including stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 0, lvdescendants, lv_descendants, "LV descendants ignoring any stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "FDescendants", lvid, 0, lvfulldescendants, lv_full_descendants, "LV descendants including stored history of the ancestry chain.", 0)
-FIELD(LVS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
-FIELD(LVS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
-FIELD(LVS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
-FIELD(LVS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
-FIELD(LVS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot, cache and thin pools and volumes, the percentage full if LV is active.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For cache and thin pools, the percentage of metadata full if LV is active.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, copy_percent, "For Cache, RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, sync_percent, "For Cache, RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 0, raidmismatchcount, raid_mismatch_count, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 0, raidsyncaction, raid_sync_action, "For RAID, the current synchronization action being performed.", 0)
 FIELD(LVS, lv, NUM, "WBehind", lvid, 0, raidwritebehind, raid_write_behind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
@@ -120,7 +120,7 @@ FIELD(LVSSTATUS, lv, STR_LIST, "KCacheSettings", lvid, 18, kernel_cache_settings
 FIELD(LVSSTATUS, lv, STR, "KCachePolicy", lvid, 18, kernel_cache_policy, kernel_cache_policy, "Cache policy used in kernel.", 0)
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 0, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
-FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools, whether metadata check is needed.", 0)
+FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools and cache volumes, whether metadata check is needed.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 0, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index fd084f1..56c6f5b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2812,28 +2812,11 @@ static int _snpercent_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 			   struct dm_report_field *field,
 			   const void *data, void *private __attribute__((unused)))
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	dm_percent_t snap_percent;
-
-	if ((lv_is_cow(lv) || lv_is_merging_origin(lv)) &&
-	    lv_snapshot_percent(lv, &snap_percent)) {
-		if ((snap_percent != DM_PERCENT_INVALID) &&
-		    (snap_percent != LVM_PERCENT_MERGE_FAILED))
-			return dm_report_field_percent(rh, field, &snap_percent);
-
-		if (!lv_is_merging_origin(lv)) {
-			snap_percent = DM_PERCENT_100;
-			return dm_report_field_percent(rh, field, &snap_percent);
-		}
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-		/*
-		 * on activate merge that hasn't started yet would
-		 * otherwise display incorrect snap% in origin
-		 */
-	}
+	dm_percent_t percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_DATA);
 
-	snap_percent = DM_PERCENT_INVALID;
-	return dm_report_field_percent(rh, field, &snap_percent);
+	return dm_report_field_percent(rh, field, &percent);
 }
 
 static int _copypercent_disp(struct dm_report *rh,
@@ -2841,20 +2824,20 @@ static int _copypercent_disp(struct dm_report *rh,
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute__((unused)))
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lv_status_cache *status;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	const struct logical_volume *lv = lvdm->lv;
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
-	if (((lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv)) && lv_raid_percent(lv, &percent)) ||
-	     (lv_is_mirror(lv) && lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
-	    (percent != DM_PERCENT_INVALID)) {
+	/* TODO: just cache passes through lvseg_percent... */
+	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv))
+		percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_DIRTY);
+	else if (((lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv)) &&
+		   lv_raid_percent(lv, &percent)) ||
+		  (lv_is_mirror(lv) &&
+		   lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
+		 (percent != DM_PERCENT_INVALID))
 		percent = copy_percent(lv);
-	} else if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
-		if (lv_cache_status(lv, &status)) {
-			percent = status->dirty_usage;
-			dm_pool_destroy(status->mem);
-		}
-	}
 
 	return dm_report_field_percent(rh, field, &percent);
 }
@@ -2937,22 +2920,9 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data, void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	dm_percent_t percent = DM_PERCENT_INVALID;
-	struct lv_status_cache *status;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (lv_is_cow(lv))
-		return _snpercent_disp(rh, mem, field, data, private);
-	else if (lv_is_thin_pool(lv))
-		(void) lv_thin_pool_percent(lv, 0, &percent);
-	else if (lv_is_thin_volume(lv))
-		(void) lv_thin_percent(lv, 0, &percent);
-	else if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
-		if (lv_cache_status(lv, &status)) {
-			percent = status->data_usage;
-			dm_pool_destroy(status->mem);
-		}
-	}
+	dm_percent_t percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_DATA);
 
 	return dm_report_field_percent(rh, field, &percent);
 }
@@ -2962,20 +2932,12 @@ static int _metadatapercent_disp(struct dm_report *rh,
 				 struct dm_report_field *field,
 				 const void *data, void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 	dm_percent_t percent = DM_PERCENT_INVALID;
-	struct lv_status_cache *status;
 
-	if (lv_is_thin_pool(lv))
-		(void) lv_thin_pool_percent(lv, 1, &percent);
-	else if (lv_is_thin_volume(lv))
-		(void) lv_thin_percent(lv, 1, &percent);
-	else if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
-		if (lv_cache_status(lv, &status)) {
-			percent = status->metadata_usage;
-			dm_pool_destroy(status->mem);
-		}
-	}
+	if (lv_is_thin_pool(lvdm->lv) ||
+	    lv_is_used_cache_pool(lvdm->lv))
+		percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_METADATA);
 
 	return dm_report_field_percent(rh, field, &percent);
 }


