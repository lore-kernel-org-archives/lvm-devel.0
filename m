From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  1 Dec 2016 13:56:51 +0000 (UTC)
Subject: master - report: order fields by type for field defintions in columns.h
Message-ID: <20161201135651.2B21060E4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07f9889b53eb3314e3ca816ffbeb72d087e9282a
Commit:        07f9889b53eb3314e3ca816ffbeb72d087e9282a
Parent:        bb5eb324e3d503bf6dd8923531f63d3e1933ff0d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 1 14:39:21 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 1 14:55:29 2016 +0100

report: order fields by type for field defintions in columns.h

When displaying <reporting_command> -o help, we'd like to have fields
grouped nicely, not starting having groups interleaved as it was before.
The code that displays the help output for fields takes the order as
written in columns.h file - this caused output like:

$ lvs -o help

Logical Volume Fields
---------------------
...field list...

Logical Volume Device Info and Status Combined Fields
-----------------------------------------------------
...field list...

Logical Volume Fields
---------------------
...field list...

Logical Volume Device Status Fields
-----------------------------------
...field list...

Logical Volume Fields
---------------------
...field list...

Instead, let's have it without groups interleaved which may be
a bit confusing, so:

Logical Volume Fields
---------------------
...field list...

Logical Volume Device Status Fields
-----------------------------------
...field list...

Logical Volume Device Info and Status Combined Fields
-----------------------------------------------------
...field list...

..and so on.
---
 lib/report/columns.h |   77 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 71 insertions(+), 6 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 212f9ed..ffc92c0 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -21,9 +21,19 @@
  * determines the order the entries appear in this file.
  *
  * When adding new entries take care to use the existing style.
+ *
+ * Do not interleave fields from different report types - for example,
+ * if you have a field of type "LVS" add it in between "LVS type fields"
+ * and "End of LVS type fields" comment. If you interleaved fields of
+ * different types here in this file, they would end up interleaved in
+ * the <reporting_command> -o help output too which may be confusing
+ * for users.
+ *
  * Displayed fields names normally have a type prefix and use underscores.
+ *
  * Field-specific internal functions names normally match the displayed
  * field names but without underscores.
+ *
  * Help text ends with a full stop.
  */
 
@@ -32,13 +42,15 @@
  */
 
 /* *INDENT-OFF* */
+/*
+ * LVS type fields
+ */
 FIELD(LVS, lv, STR, "LV UUID", lvid, 38, lvuuid, lv_uuid, "Unique identifier.", 0)
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for internal use are enclosed in brackets.", 0)
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV including its VG, namely VG/LV.", 0)
 FIELD(LVS, lv, STR, "Path", lvid, 0, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
 FIELD(LVS, lv, STR, "DMPath", lvid, 0, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 0, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
-FIELD(LVSINFOSTATUS, lv, STR, "Attr", lvid, 0, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR_LIST, "Layout", lvid, 10, lvlayout, lv_layout, "LV layout.", 0)
 FIELD(LVS, lv, STR_LIST, "Role", lvid, 10, lvrole, lv_role, "LV role.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
@@ -69,11 +81,6 @@ FIELD(LVS, lv, STR_LIST, "Ancestors", lvid, 0, lvancestors, lv_ancestors, "LV an
 FIELD(LVS, lv, STR_LIST, "FAncestors", lvid, 0, lvfullancestors, lv_full_ancestors, "LV ancestors including stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "Descendants", lvid, 0, lvdescendants, lv_descendants, "LV descendants ignoring any stored history of the ancestry chain.", 0)
 FIELD(LVS, lv, STR_LIST, "FDescendants", lvid, 0, lvfulldescendants, lv_full_descendants, "LV descendants including stored history of the ancestry chain.", 0)
-FIELD(LVSSTATUS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot, cache and thin pools and volumes, the percentage full if LV is active.", 0)
-FIELD(LVSSTATUS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
-FIELD(LVSSTATUS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For cache and thin pools, the percentage of metadata full if LV is active.", 0)
-FIELD(LVSSTATUS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, copy_percent, "For Cache, RAID, mirrors and pvmove, current percentage in-sync.", 0)
-FIELD(LVSSTATUS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, sync_percent, "For Cache, RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, NUM, "Mismatches", lvid, 0, raidmismatchcount, raid_mismatch_count, "For RAID, number of mismatches found or repaired.", 0)
 FIELD(LVS, lv, STR, "SyncAction", lvid, 0, raidsyncaction, raid_sync_action, "For RAID, the current synchronization action being performed.", 0)
 FIELD(LVS, lv, NUM, "WBehind", lvid, 0, raidwritebehind, raid_write_behind, "For RAID1, the number of outstanding writes allowed to writemostly devices.", 0)
@@ -99,7 +106,13 @@ FIELD(LVS, lv, TIM, "RTime", lvid, 26, lvtimeremoved, lv_time_removed, "Removal
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 0, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 FIELD(LVS, lv, BIN, "Historical", lvid, 0, lvhistorical, lv_historical, "Set if the LV is historical.", 0)
+/*
+ * End of LVS type fields
+ */
 
+/*
+ * LVSINFO type fields
+ */
 FIELD(LVSINFO, lv, SNUM, "KMaj", lvid, 0, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, SNUM, "KMin", lvid, 0, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, SIZ, "KRahead", lvid, 0, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
@@ -108,7 +121,18 @@ FIELD(LVSINFO, lv, BIN, "Suspended", lvid, 10, lvsuspended, lv_suspended, "Set i
 FIELD(LVSINFO, lv, BIN, "LiveTable", lvid, 20, lvlivetable, lv_live_table, "Set if LV has live table present.", 0)
 FIELD(LVSINFO, lv, BIN, "InactiveTable", lvid, 20, lvinactivetable, lv_inactive_table, "Set if LV has inactive table present.", 0)
 FIELD(LVSINFO, lv, BIN, "DevOpen", lvid, 10, lvdeviceopen, lv_device_open, "Set if LV device is open.", 0)
+/*
+ * End of LVSINFO type fields
+ */
 
+/*
+ * LVSSTATUS type fields
+ */
+FIELD(LVSSTATUS, lv, PCT, "Data%", lvid, 6, datapercent, data_percent, "For snapshot, cache and thin pools and volumes, the percentage full if LV is active.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For cache and thin pools, the percentage of metadata full if LV is active.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, copy_percent, "For Cache, RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVSSTATUS, lv, PCT, "Cpy%Sync", lvid, 0, copypercent, sync_percent, "For Cache, RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheTotalBlocks", lvid, 0, cache_total_blocks, cache_total_blocks, "Total cache blocks.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheUsedBlocks", lvid, 16, cache_used_blocks, cache_used_blocks, "Used cache blocks.", 0)
 FIELD(LVSSTATUS, lv, NUM, "CacheDirtyBlocks", lvid, 0, cache_dirty_blocks, cache_dirty_blocks, "Dirty cache blocks.", 0)
@@ -121,7 +145,21 @@ FIELD(LVSSTATUS, lv, STR, "KCachePolicy", lvid, 18, kernel_cache_policy, kernel_
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 0, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
 FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools and cache volumes, whether metadata check is needed.", 0)
+/*
+ * End of LVSSTATUS type fields
+ */
 
+/*
+ * LVSINFOSTATUS type fields
+ */
+FIELD(LVSINFOSTATUS, lv, STR, "Attr", lvid, 0, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+/*
+ * End of LVSINFOSTATUS type fields
+ */
+
+/*
+ * LABEL type fields
+ */
 FIELD(LABEL, label, STR, "Fmt", type, 0, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, SIZ, "DevSize", dev, 0, devsize, dev_size, "Size of underlying device in current units.", 0)
@@ -131,7 +169,13 @@ FIELD(LABEL, label, STR, "Min", dev, 0, devminor, pv_minor, "Device minor number
 FIELD(LABEL, label, SIZ, "PMdaFree", type, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
 FIELD(LABEL, label, SIZ, "PMdaSize", type, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
 FIELD(LABEL, label, NUM, "PExtVsn", type, 0, pvextvsn, pv_ext_vsn, "PV header extension version.", 0)
+/*
+ * End of LABEL type fields
+ */
 
+/*
+ * PVS type fields
+ */
 FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
 FIELD(PVS, pv, SIZ, "PSize", id, 0, pvsize, pv_size, "Size of PV in current units.", 0)
 FIELD(PVS, pv, SIZ, "PFree", id, 0, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
@@ -149,7 +193,13 @@ FIELD(PVS, pv, SIZ, "BA Start", ba_start, 0, size64, pv_ba_start, "Offset to the
 FIELD(PVS, pv, SIZ, "BA Size", ba_size, 0, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
 FIELD(PVS, pv, BIN, "PInUse", id, 0, pvinuse, pv_in_use, "Set if PV is used.", 0)
 FIELD(PVS, pv, BIN, "Duplicate", id, 0, pvduplicate, pv_duplicate, "Set if PV is an unchosen duplicate.", 0)
+/*
+ * End of PVS type fields
+ */
 
+/*
+ * VGS type fields
+ */
 FIELD(VGS, vg, STR, "Fmt", cmd, 0, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
 FIELD(VGS, vg, STR, "VG", name, 0, string, vg_name, "Name.", 0)
@@ -183,7 +233,13 @@ FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 0, vgmdasused, vg_mda_used_count, "Number o
 FIELD(VGS, vg, SIZ, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
 FIELD(VGS, vg, SIZ, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 0, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
+/*
+ * End of VGS type fields
+ */
 
+/*
+ * SEGS type fields
+ */
 FIELD(SEGS, seg, STR, "Type", list, 0, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 0, uint32, stripes, "Number of stripes or mirror legs.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 0, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
@@ -208,7 +264,16 @@ FIELD(SEGS, seg, STR_LIST, "Metadata Devs", list, 0, metadatadevices, metadata_d
 FIELD(SEGS, seg, STR, "Monitor", list, 0, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
 FIELD(SEGS, seg, STR, "CachePolicy", list, 0, cache_policy, cache_policy, "The cache policy (cached segments only).", 0)
 FIELD(SEGS, seg, STR_LIST, "CacheSettings", list, 0, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
+/*
+ * End of SEGS type fields
+ */
 
+/*
+ * PVSEGS type fields
+ */
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 0, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 0, uint32, pvseg_size, "Number of extents in segment.", 0)
+/*
+ * End of PVSEGS type fields
+ */
 /* *INDENT-ON* */


