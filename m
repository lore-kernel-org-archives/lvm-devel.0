From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Jul 2013 00:31:41 +0000 (UTC)
Subject: master - reporting: tidy recent new fields
Message-ID: <20130719003141.6D4C260D70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da79fe4c1db8936667954403e6f690df464fc638
Commit:        da79fe4c1db8936667954403e6f690df464fc638
Parent:        1a005b40a4ce9cc1f54a564f8f74917935cb35c4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 19 01:30:02 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 19 01:30:02 2013 +0100

reporting: tidy recent new fields

Add underscores and prefixes to recently-added fields.
(Might add more alias functionality in future.)
---
 WHATS_NEW                   |    4 +++
 lib/report/columns.h        |   33 +++++++++++++++++++-----------
 lib/report/properties.c     |   46 +++++++++++++++++++++---------------------
 lib/report/report.c         |   10 ++++----
 test/shell/lvchange-raid.sh |   16 +++++++-------
 5 files changed, 61 insertions(+), 48 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9102613..0b96df0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.02.99 - 
 ===================================
+  Add LV reporting fields raid_mismatch_count, raid_sync_action, raid_write_behind.
+  Add LV reporting fields raid_min_recovery_rate, raid_max_recovery_rate.
+  Add sync_percent as alias for copy_percent LV reporting field.
+  Add lv_ prefix to modules reporting field.
   Use units B or b (never E) with no decimal places when displaying sizes < 1k.
   Add support for poolmetadataspare LV, that will be used for pool recovery.
   Improve activation order when creating thin pools in non-clustered VG.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 4c0bca2..9bb99d3 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -16,6 +16,15 @@
 /*
  * This file defines the fields (columns) for the reporting commands
  * (pvs/vgs/lvs).
+ *
+ * The preferred order of the field descriptions in the help text
+ * determines the order the entries appear in this file.
+ *
+ * When adding new entries take care to use the existing style.
+ * Displayed fields names normally have a type prefix and use underscores.
+ * Field-specific internal functions names normally match the displayed
+ * field names but without underscores.
+ * Help text ends with a full stop.
  */
 
 /* *INDENT-OFF* */
@@ -23,6 +32,7 @@ FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, lv_uuid, "Unique identifier
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for internal use are enclosed in brackets.", 0)
 FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
@@ -39,23 +49,22 @@ FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, t
 FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
-FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, mismatch_count, mismatches, "For RAID, number of mismatches found or repaired.", 0)
-FIELD(LVS, lv, STR, "SyncAction", lvid, 10, sync_action, syncaction, "For RAID, the current synchronization action being performed.", 0)
-FIELD(LVS, lv, NUM, "WBehind", lvid, 7, write_behind, writebehind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
-FIELD(LVS, lv, NUM, "MinSync", lvid, 7, min_recovery_rate, minrecoveryrate, "For RAID1, the minimum recovery I/O load in kiB/sec/disk.", 0)
-FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, max_recovery_rate, maxrecoveryrate, "For RAID1, the maximum recovery I/O load in kiB/sec/disk.", 0)
+FIELD(LVS, lv, NUM, "Mismatches", lvid, 10, raidmismatchcount, raid_mismatch_count, "For RAID, number of mismatches found or repaired.", 0)
+FIELD(LVS, lv, STR, "SyncAction", lvid, 10, raidsyncaction, raid_sync_action, "For RAID, the current synchronization action being performed.", 0)
+FIELD(LVS, lv, NUM, "WBehind", lvid, 7, raidwritebehind, raid_write_behind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
+FIELD(LVS, lv, NUM, "MinSync", lvid, 7, raidminrecoveryrate, raid_min_recovery_rate, "For RAID1, the minimum recovery I/O load in kiB/sec/disk.", 0)
+FIELD(LVS, lv, NUM, "MaxSync", lvid, 7, raidmaxrecoveryrate, raid_max_recovery_rate, "For RAID1, the maximum recovery I/O load in kiB/sec/disk.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
 FIELD(LVS, lv, STR, "Data", lvid, 4, datalv, data_lv, "For thin pools, the LV holding the associated data.", 0)
 FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin pools, the LV holding the associated metadata.", 0)
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
-FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
+FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
 FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
-FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, modules, "Kernel device-mapper modules required for this LV.", 0)
-FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV", 0)
+FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
@@ -74,8 +83,8 @@ FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Tota
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
-FIELD(PVS, pv, NUM, "BA start", ba_start, 8, size64, ba_start, "Offset to the start of PV Bootloader Area on the underlying device.", 0)
-FIELD(PVS, pv, NUM, "BA size", ba_size, 7, size64, ba_size, "Size of PV Bootloader Area in current units.", 0)
+FIELD(PVS, pv, NUM, "BA start", ba_start, 8, size64, pv_ba_start, "Offset to the start of PV Bootloader Area on the underlying device in current units.", 0)
+FIELD(PVS, pv, NUM, "BA size", ba_size, 7, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
@@ -94,12 +103,12 @@ FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, lv_count, "Number of LVs.", 0)
 FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, snap_count, "Number of snapshots.", 0)
 FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, vg_seqno, "Revision number of internal metadata.  Incremented whenever it changes.", 0)
 FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, vg_tags, "Tags, if any.", 0)
+FIELD(VGS, vg, STR, "VProfile", cmd, 8, vgprofile, vg_profile, "Configuration profile attached to this VG.", 0)
 FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, vg_mda_count, "Number of metadata areas on this VG.", 0)
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number of metadata areas in use on this VG.", 0)
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
-FIELD(VGS, vg, STR, "VProfile", cmd, 8, vgprofile, vg_profile, "Configuration profile attached to this VG", 0)
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
@@ -119,7 +128,7 @@ FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in c
 FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
-FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, monitor, "Dmeventd monitoring status of the segment.", 0)
+FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index a4832af..3eeb78a 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -58,7 +58,7 @@ static percent_t _copy_percent(const struct logical_volume *lv)
 	return percent;
 }
 
-static uint64_t _mismatches(const struct logical_volume *lv)
+static uint64_t _raidmismatchcount(const struct logical_volume *lv)
 {
 	uint64_t cnt;
 
@@ -67,7 +67,7 @@ static uint64_t _mismatches(const struct logical_volume *lv)
 	return cnt;
 }
 
-static char *_sync_action(const struct logical_volume *lv)
+static char *_raidsyncaction(const struct logical_volume *lv)
 {
 	char *action;
 
@@ -77,17 +77,17 @@ static char *_sync_action(const struct logical_volume *lv)
 	return action;
 }
 
-static uint32_t _writebehind(const struct logical_volume *lv)
+static uint32_t _raidwritebehind(const struct logical_volume *lv)
 {
 	return first_seg(lv)->writebehind;
 }
 
-static uint32_t _minrecoveryrate(const struct logical_volume *lv)
+static uint32_t _raidminrecoveryrate(const struct logical_volume *lv)
 {
 	return first_seg(lv)->min_recovery_rate;
 }
 
-static uint32_t _maxrecoveryrate(const struct logical_volume *lv)
+static uint32_t _raidmaxrecoveryrate(const struct logical_volume *lv)
 {
 	return first_seg(lv)->max_recovery_rate;
 }
@@ -155,10 +155,10 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
 #define _pv_mda_count_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
 #define _pv_mda_used_count_set prop_not_implemented_set
-GET_PV_NUM_PROPERTY_FN(ba_start, SECTOR_SIZE * pv->ba_start)
-#define _ba_start_set prop_not_implemented_set
-GET_PV_NUM_PROPERTY_FN(ba_size, SECTOR_SIZE * pv->ba_size)
-#define _ba_size_set prop_not_implemented_set
+GET_PV_NUM_PROPERTY_FN(pv_ba_start, SECTOR_SIZE * pv->ba_start)
+#define _pv_ba_start_set prop_not_implemented_set
+GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
+#define _pv_ba_size_set prop_not_implemented_set
 
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
@@ -195,16 +195,16 @@ GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
 #define _copy_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(sync_percent, _copy_percent(lv))
 #define _sync_percent_set prop_not_implemented_set
-GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
-#define _mismatches_set prop_not_implemented_set
-GET_LV_NUM_PROPERTY_FN(writebehind, _writebehind(lv))
-#define _writebehind_set prop_not_implemented_set
-GET_LV_NUM_PROPERTY_FN(minrecoveryrate, _minrecoveryrate(lv))
-#define _minrecoveryrate_set prop_not_implemented_set
-GET_LV_NUM_PROPERTY_FN(maxrecoveryrate, _maxrecoveryrate(lv))
-#define _maxrecoveryrate_set prop_not_implemented_set
-GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
-#define _syncaction_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(raid_mismatch_count, _raidmismatchcount(lv))
+#define _raid_mismatch_count_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(raid_write_behind, _raidwritebehind(lv))
+#define _raid_write_behind_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(raid_min_recovery_rate, _raidminrecoveryrate(lv))
+#define _raid_min_recovery_rate_set prop_not_implemented_set
+GET_LV_NUM_PROPERTY_FN(raid_max_recovery_rate, _raidmaxrecoveryrate(lv))
+#define _raid_max_recovery_rate_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(raid_sync_action, _raidsyncaction(lv))
+#define _raid_sync_action_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
@@ -213,8 +213,8 @@ GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set prop_not_implemented_set
-GET_LV_STR_PROPERTY_FN(modules, lv_modules_dup(lv->vg->vgmem, lv))
-#define _modules_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_modules, lv_modules_dup(lv->vg->vgmem, lv))
+#define _lv_modules_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(data_lv, lv_data_lv_dup(lv->vg->vgmem, lv))
 #define _data_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(metadata_lv, lv_metadata_lv_dup(lv->vg->vgmem, lv))
@@ -322,8 +322,8 @@ GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
 #define _seg_pe_ranges_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 #define _devices_set prop_not_implemented_set
-GET_LVSEG_STR_PROPERTY_FN(monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
-#define _monitor_set prop_not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
+#define _seg_monitor_set prop_not_implemented_set
 
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
diff --git a/lib/report/report.c b/lib/report/report.c
index 8b5455b..77332a2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -977,7 +977,7 @@ no_copypercent:
 	return 1;
 }
 
-static int _sync_action_disp(struct dm_report *rh __attribute__((unused)),
+static int _raidsyncaction_disp(struct dm_report *rh __attribute__((unused)),
 			     struct dm_pool *mem,
 			     struct dm_report_field *field,
 			     const void *data,
@@ -995,7 +995,7 @@ static int _sync_action_disp(struct dm_report *rh __attribute__((unused)),
 	return _string_disp(rh, mem, field, &sync_action, private);
 }
 
-static int _mismatch_count_disp(struct dm_report *rh __attribute__((unused)),
+static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
 				struct dm_pool *mem,
 				struct dm_report_field *field,
 				const void *data,
@@ -1013,7 +1013,7 @@ static int _mismatch_count_disp(struct dm_report *rh __attribute__((unused)),
 	return dm_report_field_uint64(rh, field, &mismatch_count);
 }
 
-static int _write_behind_disp(struct dm_report *rh __attribute__((unused)),
+static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
 			      struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data,
@@ -1029,7 +1029,7 @@ static int _write_behind_disp(struct dm_report *rh __attribute__((unused)),
 	return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 }
 
-static int _min_recovery_rate_disp(struct dm_report *rh __attribute__((unused)),
+static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
 				   struct dm_pool *mem,
 				   struct dm_report_field *field,
 				   const void *data,
@@ -1046,7 +1046,7 @@ static int _min_recovery_rate_disp(struct dm_report *rh __attribute__((unused)),
 				      &first_seg(lv)->min_recovery_rate);
 }
 
-static int _max_recovery_rate_disp(struct dm_report *rh __attribute__((unused)),
+static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
 				   struct dm_pool *mem,
 				   struct dm_report_field *field,
 				   const void *data,
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index d7878a7..291928a 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -100,14 +100,14 @@ run_writemostly_check() {
 	not lvchange --writebehind -256 $1/$2
 
 	# Set writebehind
-	[ ! `lvs --noheadings -o writebehind $1/$2` ]
+	[ ! `lvs --noheadings -o raid_write_behind $1/$2` ]
 	lvchange --writebehind 512 $1/$2
-	[ `lvs --noheadings -o writebehind $1/$2` -eq 512 ]
+	[ `lvs --noheadings -o raid_write_behind $1/$2` -eq 512 ]
 
 	# Converting to linear should clear flags and writebehind
 	lvconvert -m 0 $1/$2 $d1
 	lvconvert --type raid1 -m 1 $1/$2 $d1
-	[ ! `lvs --noheadings -o writebehind $1/$2` ]
+	[ ! `lvs --noheadings -o raid_write_behind $1/$2` ]
 	lvs -a --noheadings -o lv_attr $1/${2}_rimage_0 | grep '.*-.$'
 	lvs -a --noheadings -o lv_attr $1/${2}_rimage_1 | grep '.*-.$'
 }
@@ -142,7 +142,7 @@ run_syncaction_check() {
 
 	# Check all is normal
 	if ! lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$' ||
-		[ `lvs --noheadings -o mismatches $1/$2` != 0 ]; then
+		[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]; then
 
 		# I think this is a kernel bug.  It happens randomly after
 		# a RAID device creation.  I think the mismatch count
@@ -160,7 +160,7 @@ run_syncaction_check() {
 	fi
 
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
-	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
+	[ `lvs --noheadings -o raid_mismatch_count $1/$2` == 0 ]
 
 	# Overwrite the last half of one of the PVs with crap
 	dd if=/dev/urandom of=$device bs=1k count=$size seek=$seek
@@ -174,20 +174,20 @@ run_syncaction_check() {
 	lvchange --syncaction check $1/$2
 	aux wait_for_sync $1 $2
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
-	[ `lvs --noheadings -o mismatches $1/$2` != 0 ]
+	[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]
 
 	# "repair" will fix discrepancies and record number fixed
 	lvchange --syncaction repair $1/$2
 	aux wait_for_sync $1 $2
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*m.$'
-	[ `lvs --noheadings -o mismatches $1/$2` != 0 ]
+	[ `lvs --noheadings -o raid_mismatch_count $1/$2` != 0 ]
 
 	# Final "check" should show no mismatches
 	# 'lvs' should show results
 	lvchange --syncaction check $1/$2
 	aux wait_for_sync $1 $2
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*-.$'
-	[ `lvs --noheadings -o mismatches $1/$2` == 0 ]
+	[ `lvs --noheadings -o raid_mismatch_count $1/$2` == 0 ]
 }
 
 # run_refresh_check <VG> <LV>


