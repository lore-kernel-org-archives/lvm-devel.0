From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Jul 2014 13:57:49 +0000 (UTC)
Subject: master - report: 'whether' -> 'set if' in field description
Message-ID: <20140709135749.A7A40600EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6ac8819f694d0b28fc592e89f01a8cf8e4f1802
Commit:        b6ac8819f694d0b28fc592e89f01a8cf8e4f1802
Parent:        ccab185aa7accd348409b9c0261bc3200570710d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 9 13:41:25 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 9 15:57:05 2014 +0200

report: 'whether' -> 'set if' in field description

---
 lib/report/columns.h |   40 ++++++++++++++++++++--------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 21ca585..5013834 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -40,18 +40,18 @@ FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-ma
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR, "Type", lvid, 10, lvvolumetype, lv_volume_type, "LV volume type.", 0)
-FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Whether mirror/RAID images underwent initial resynchronization.", 0)
-FIELD(LVS, lv, BIN, "ImgSynced", lvid, 10, lvimagesynced, lv_image_synced, "Whether mirror/RAID image is synchronized.", 0)
-FIELD(LVS, lv, BIN, "Merging", lvid, 10, lvmerging, lv_merging, "Whether snapshot LV is being merged to origin.", 0)
-FIELD(LVS, lv, BIN, "Converting", lvid, 10, lvconverting, lv_converting, "Whether LV is being converted.", 0)
+FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
+FIELD(LVS, lv, BIN, "ImgSynced", lvid, 10, lvimagesynced, lv_image_synced, "Set if mirror/RAID image is synchronized.", 0)
+FIELD(LVS, lv, BIN, "Merging", lvid, 10, lvmerging, lv_merging, "Set if snapshot LV is being merged to origin.", 0)
+FIELD(LVS, lv, BIN, "Converting", lvid, 10, lvconverting, lv_converting, "Set if LV is being converted.", 0)
 FIELD(LVS, lv, STR, "AllocPol", lvid, 10, lvallocationpolicy, lv_allocation_policy, "LV allocation policy.", 0)
-FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_locked, "Whether LV is locked against allocation changes.", 0)
-FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Whether LV has fixed minor number assigned.", 0)
-FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Whether snapshot merge failed.", 0)
-FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Whether snapshot LV is invalid.", 0)
+FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_locked, "Set if LV is locked against allocation changes.", 0)
+FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Set if LV has fixed minor number assigned.", 0)
+FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
+FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
 FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kernel target type the LV is related to.", 0)
 FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
-FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Whether LV is skipped on activation.", 0)
+FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Set if LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
@@ -87,10 +87,10 @@ FIELD(LVSINFO, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently ass
 FIELD(LVSINFO, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
 FIELD(LVSINFO, lv, STR, "LPerms", lvid, 8, lvpermissions, lv_permissions, "LV permissions.", 0)
-FIELD(LVSINFO, lv, BIN, "Suspended", lvid, 10, lvsuspended, lv_suspended, "Whether LV is suspended.", 0)
-FIELD(LVSINFO, lv, BIN, "LiveTable", lvid, 20, lvlivetable, lv_live_table, "Whether LV has live table present.", 0)
-FIELD(LVSINFO, lv, BIN, "InactiveTable", lvid, 20, lvinactivetable, lv_inactive_table, "Whether LV has inactive table present.", 0)
-FIELD(LVSINFO, lv, BIN, "DevOpen", lvid, 10, lvdeviceopen, lv_device_open, "Whether LV device is open.", 0)
+FIELD(LVSINFO, lv, BIN, "Suspended", lvid, 10, lvsuspended, lv_suspended, "Set if LV is suspended.", 0)
+FIELD(LVSINFO, lv, BIN, "LiveTable", lvid, 20, lvlivetable, lv_live_table, "Set if LV has live table present.", 0)
+FIELD(LVSINFO, lv, BIN, "InactiveTable", lvid, 20, lvinactivetable, lv_inactive_table, "Set if LV has inactive table present.", 0)
+FIELD(LVSINFO, lv, BIN, "DevOpen", lvid, 10, lvdeviceopen, lv_device_open, "Set if LV device is open.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
@@ -104,9 +104,9 @@ FIELD(PVS, pv, SIZ, "PSize", id, 5, pvsize, pv_size, "Size of PV in current unit
 FIELD(PVS, pv, SIZ, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
 FIELD(PVS, pv, SIZ, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
 FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
-FIELD(PVS, pv, BIN, "Allocatable", id, 10, pvallocatable, pv_allocatable, "Whether this device can be used for allocation.", 0)
-FIELD(PVS, pv, BIN, "Exported", id, 10, pvexported, pv_exported, "Whether this device is exported.", 0)
-FIELD(PVS, pv, BIN, "Missing", id, 10, pvmissing, pv_missing, "Whether this device is missing in system.", 0)
+FIELD(PVS, pv, BIN, "Allocatable", id, 10, pvallocatable, pv_allocatable, "Set if this device can be used for allocation.", 0)
+FIELD(PVS, pv, BIN, "Exported", id, 10, pvexported, pv_exported, "Set if this device is exported.", 0)
+FIELD(PVS, pv, BIN, "Missing", id, 10, pvmissing, pv_missing, "Set if this device is missing in system.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
 FIELD(PVS, pv, STR_LIST, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
@@ -120,11 +120,11 @@ FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
 FIELD(VGS, vg, STR, "VG", name, 4, string, vg_name, "Name.", 0)
 FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, vg_attr, "Various attributes - see man page.", 0)
 FIELD(VGS, vg, STR, "VPerms", cmd, 10, vgpermissions, vg_permissions, "VG permissions.", 0)
-FIELD(VGS, vg, BIN, "Extendable", cmd, 10, vgextendable, vg_extendable, "Whether VG is extendable.", 0)
-FIELD(VGS, vg, BIN, "Exported", cmd, 10, vgexported, vg_exported, "Whether VG is exported.", 0)
-FIELD(VGS, vg, BIN, "Partial", cmd, 10, vgpartial, vg_partial, "Whether VG is partial.", 0)
+FIELD(VGS, vg, BIN, "Extendable", cmd, 10, vgextendable, vg_extendable, "Set if VG is extendable.", 0)
+FIELD(VGS, vg, BIN, "Exported", cmd, 10, vgexported, vg_exported, "Set if VG is exported.", 0)
+FIELD(VGS, vg, BIN, "Partial", cmd, 10, vgpartial, vg_partial, "Set if VG is partial.", 0)
 FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_policy, "VG allocation policy.", 0)
-FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Whether VG is clustered.", 0)
+FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Set if VG is clustered.", 0)
 FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
 FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)


