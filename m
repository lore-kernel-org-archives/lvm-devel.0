From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 08 Apr 2013 20:45:56 -0500
Subject: [PATCH 3 of 4] LVM RAID: Add ability to report RAID 'Mismatches'
Message-ID: <1365471956.13988.5.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'lvs':  Add ability to report the 'Mismatches' in RAID volumes

'lvchange' can be used to initiate RAID scrubbing operations.  The number
of discrepancies found or repaired by a scrubbing operation are called
"mismatches".  This patch allows the user to query the mismatch count and
display it via 'lvs'.

Index: lvm2/lib/report/columns.h
===================================================================
--- lvm2.orig/lib/report/columns.h
+++ lvm2/lib/report/columns.h
@@ -80,6 +80,7 @@ FIELD(LVS, lv, NUM, "Snap%", lvid, 6, sn
 FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -936,6 +936,24 @@ no_copypercent:
 	return 1;
 }
 
+static int _mismatch_count_disp(struct dm_report *rh __attribute__((unused)),
+				struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data,
+				void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t mismatch_count;
+
+	if (!(lv->status & RAID) ||
+	    !lv_raid_mismatch_count(lv, &mismatch_count)) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	return  dm_report_field_uint64(rh, field, &mismatch_count);
+}
+
 static int _dtpercent_disp(int metadata, struct dm_report *rh,
 			   struct dm_pool *mem,
 			   struct dm_report_field *field,
Index: lvm2/man/lvs.8.in
===================================================================
--- lvm2.orig/man/lvs.8.in
+++ lvm2/man/lvs.8.in
@@ -97,6 +97,7 @@ lv_time,
 lv_uuid,
 metadata_lv,
 mirror_log,
+mismatches,
 modules,
 move_pv,
 origin,
Index: lvm2/lib/report/properties.c
===================================================================
--- lvm2.orig/lib/report/properties.c
+++ lvm2/lib/report/properties.c
@@ -93,6 +93,14 @@ static percent_t _copy_percent(const str
 	return perc;
 }
 
+static uint64_t _mismatches(const struct logical_volume *lv) {
+	uint64_t cnt;
+
+	if (!lv_raid_mismatch_count(lv, &cnt))
+		return 0;
+	return cnt;
+}
+
 static percent_t _snap_percent(const struct logical_volume *lv) {
 	percent_t perc;
 
@@ -195,6 +203,8 @@ GET_LV_NUM_PROPERTY_FN(copy_percent, _co
 #define _copy_percent_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(sync_percent, _copy_percent(lv))
 #define _sync_percent_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
+#define _mismatches_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))



