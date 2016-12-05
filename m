From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:01 +0000 (UTC)
Subject: master - snapshot: reporting uses statusinfo
Message-ID: <20161205161501.ABC3C607BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=254f73e3efe27e55637e8d3c23abf607564650d7
Commit:        254f73e3efe27e55637e8d3c23abf607564650d7
Parent:        07f9889b53eb3314e3ca816ffbeb72d087e9282a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 17:58:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:01:15 2016 +0100

snapshot: reporting uses statusinfo

Convert lvs -o lv_merge_failed,lv_snapshot_invalid to use
lv_info_and_status function.

This makes it equal to attr value showing this info
(as they were different since they were derived from
different data set and different logic as well).

Also saves couple extra ioctl that were needed to obtain this info.
---
 WHATS_NEW            |    1 +
 lib/report/columns.h |    4 ++--
 lib/report/report.c  |   20 ++++++++------------
 3 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3e551ec..82222d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Use status info to report merge failed and snapshot invalid lvs fields.
 
 Version 2.02.168 - 30th November 2016
 =====================================
diff --git a/lib/report/columns.h b/lib/report/columns.h
index ffc92c0..6d9b851 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -60,8 +60,6 @@ FIELD(LVS, lv, BIN, "Converting", lvid, 0, lvconverting, lv_converting, "Set if
 FIELD(LVS, lv, STR, "AllocPol", lvid, 10, lvallocationpolicy, lv_allocation_policy, "LV allocation policy.", 0)
 FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_locked, "Set if LV is locked against allocation changes.", 0)
 FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV has fixed minor number assigned.", 0)
-FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
-FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
 FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "WhenFull", lvid, 15, lvwhenfull, lv_when_full, "For thin pools, behavior when full.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 0, lvactive, lv_active, "Active state of the LV.", 0)
@@ -145,6 +143,8 @@ FIELD(LVSSTATUS, lv, STR, "KCachePolicy", lvid, 18, kernel_cache_policy, kernel_
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 0, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
 FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools and cache volumes, whether metadata check is needed.", 0)
+FIELD(LVSSTATUS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
+FIELD(LVSSTATUS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
 /*
  * End of LVSSTATUS type fields
  */
diff --git a/lib/report/report.c b/lib/report/report.c
index 1ca4dfb..358ae94 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3363,30 +3363,26 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	dm_percent_t snap_percent;
-	int merge_failed;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &snap_percent))
+	if (lvdm->seg_status.type != SEG_STATUS_SNAPSHOT)
 		return _binary_undef_disp(rh, mem, field, private);
 
-	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
-	return _binary_disp(rh, mem, field, merge_failed, GET_FIRST_RESERVED_NAME(lv_merge_failed_y), private);
+	return _binary_disp(rh, mem, field, lvdm->seg_status.snapshot->merge_failed,
+			    GET_FIRST_RESERVED_NAME(lv_merge_failed_y), private);
 }
 
 static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 				   struct dm_report_field *field,
 				   const void *data, void *private)
 {
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-	dm_percent_t snap_percent;
-	int snap_invalid;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
 
-	if (!lv_is_cow(lv))
+	if (lvdm->seg_status.type != SEG_STATUS_SNAPSHOT)
 		return _binary_undef_disp(rh, mem, field, private);
 
-	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
-	return _binary_disp(rh, mem, field, snap_invalid, GET_FIRST_RESERVED_NAME(lv_snapshot_invalid_y), private);
+	return _binary_disp(rh, mem, field, lvdm->seg_status.snapshot->invalid,
+			    GET_FIRST_RESERVED_NAME(lv_snapshot_invalid_y), private);
 }
 
 static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,


