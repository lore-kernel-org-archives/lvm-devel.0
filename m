From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:20 +0000 (UTC)
Subject: master - report: add separate fields for PV/VG/LV attributes
Message-ID: <20140704140020.AFCC760612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2af4f84c94cb8202565ac32c5f1df673cd92e0c
Commit:        d2af4f84c94cb8202565ac32c5f1df673cd92e0c
Parent:        4b9b1f23199edb7e02230481a5e53ac1fa548384
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 2 11:09:14 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:40:17 2014 +0200

report: add separate fields for PV/VG/LV attributes

Physical Volume Fields:
  pv_allocatable         - Whether this device can be used for allocation.
  pv_exported            - Whether this device is exported.
  pv_missing             - Whether this device is missing in system.

Volume Group Fields:
  vg_permissions         - VG permissions.
  vg_extendable          - Whether VG is extendable.
  vg_exported            - Whether VG is exported.
  vg_partial             - Whether VG is partial.
  vg_allocation_policy   - VG allocation policy.
  vg_clustered           - Whether VG is clustered.

Logical Volume Fields:
  lv_volume_type         - LV volume type.
  lv_initial_image_sync  - Whether mirror/RAID images underwent initial resynchronization.
  lv_image_synced        - Whether mirror/RAID image is synchronized.
  lv_merging             - Whether snapshot LV is being merged to origin.
  lv_converting          - Whether LV is being converted.
  lv_allocation_policy   - LV allocation policy.
  lv_allocation_locked   - Whether LV is locked against allocation changes.
  lv_fixed_minor         - Whether LV has fixed minor number assigned.
  lv_merge_failed        - Whether snapshot merge failed.
  lv_snapshot_invalid    - Whether snapshot LV is invalid.
  lv_target_type         - Kernel target type the LV is related to.
  lv_health_status       - LV health status.
  lv_skip_activation     - Whether LV is skipped on activation.

Logical Volume Info Fields
  lv_permissions         - LV permissions.
  lv_suspended           - Whether LV is suspended.
  lv_live_table          - Whether LV has live table present.
  lv_inactive_table      - Whether LV has inactive table present.
  lv_device_open         - Whether LV device is open.
---
 lib/properties/prop_common.h |    9 +-
 lib/report/columns.h         |   27 ++++
 lib/report/properties.c      |   60 ++++++++
 lib/report/report.c          |  333 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 425 insertions(+), 4 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index 6d4c2e4..d7d01af 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -122,12 +122,13 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 
 #define STR 1
 #define NUM 2
-#define SIZ 3
-#define PCT 4
-#define STR_LIST 5
+#define BIN 3
+#define SIZ 4
+#define PCT 5
+#define STR_LIST 6
 
 #define FIELD_MODIFIABLE 0x00000001
 #define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == SIZ) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, settable, field_type == STR, ((field_type == NUM) || (field_type == BIN) || (field_type == SIZ) || (field_type == PCT)), { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 #endif
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 96c30d4..2769c2d 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -35,6 +35,19 @@ FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Bla
 FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+FIELD(LVS, lv, STR, "Type", lvid, 10, lvvolumetype, lv_volume_type, "LV volume type.", 0)
+FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Whether mirror/RAID images underwent initial resynchronization.", 0)
+FIELD(LVS, lv, BIN, "ImgSynced", lvid, 10, lvimagesynced, lv_image_synced, "Whether mirror/RAID image is synchronized.", 0)
+FIELD(LVS, lv, BIN, "Merging", lvid, 10, lvmerging, lv_merging, "Whether snapshot LV is being merged to origin.", 0)
+FIELD(LVS, lv, BIN, "Converting", lvid, 10, lvconverting, lv_converting, "Whether LV is being converted.", 0)
+FIELD(LVS, lv, STR, "AllocPol", lvid, 10, lvallocationpolicy, lv_allocation_policy, "LV allocation policy.", 0)
+FIELD(LVS, lv, BIN, "AllocLock", lvid, 10, lvallocationlocked, lv_allocation_locked, "Whether LV is locked against allocation changes.", 0)
+FIELD(LVS, lv, BIN, "FixMin", lvid, 10, lvfixedminor, lv_fixed_minor, "Whether LV has fixed minor number assigned.", 0)
+FIELD(LVS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Whether snapshot merge failed.", 0)
+FIELD(LVS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Whether snapshot LV is invalid.", 0)
+FIELD(LVS, lv, STR, "TargetType", lvid, 10, lvtargettype, lv_target_type, "Kernel target type the LV is related to.", 0)
+FIELD(LVS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
+FIELD(LVS, lv, BIN, "SkipAct", lvid, 15, lvskipactivation, lv_skip_activation, "Whether LV is skipped on activation.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
@@ -69,6 +82,11 @@ FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device
 FIELD(LVSINFO, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
 FIELD(LVSINFO, lv, SIZ, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
+FIELD(LVSINFO, lv, STR, "LPerms", lvid, 8, lvpermissions, lv_permissions, "LV permissions.", 0)
+FIELD(LVSINFO, lv, BIN, "Suspended", lvid, 10, lvsuspended, lv_suspended, "Whether LV is suspended.", 0)
+FIELD(LVSINFO, lv, BIN, "LiveTable", lvid, 20, lvlivetable, lv_live_table, "Whether LV has live table present.", 0)
+FIELD(LVSINFO, lv, BIN, "InactiveTable", lvid, 20, lvinactivetable, lv_inactive_table, "Whether LV has inactive table present.", 0)
+FIELD(LVSINFO, lv, BIN, "DevOpen", lvid, 10, lvdeviceopen, lv_device_open, "Whether LV device is open.", 0)
 
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
@@ -82,6 +100,9 @@ FIELD(PVS, pv, SIZ, "PSize", id, 5, pvsize, pv_size, "Size of PV in current unit
 FIELD(PVS, pv, SIZ, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
 FIELD(PVS, pv, SIZ, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
 FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
+FIELD(PVS, pv, BIN, "Allocatable", id, 10, pvallocatable, pv_allocatable, "Whether this device can be used for allocation.", 0)
+FIELD(PVS, pv, BIN, "Exported", id, 10, pvexported, pv_exported, "Whether this device is exported.", 0)
+FIELD(PVS, pv, BIN, "Missing", id, 10, pvmissing, pv_missing, "Whether this device is missing in system.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
 FIELD(PVS, pv, STR_LIST, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
@@ -94,6 +115,12 @@ FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
 FIELD(VGS, vg, STR, "VG", name, 4, string, vg_name, "Name.", 0)
 FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, vg_attr, "Various attributes - see man page.", 0)
+FIELD(VGS, vg, STR, "VPerms", cmd, 10, vgpermissions, vg_permissions, "VG permissions.", 0)
+FIELD(VGS, vg, BIN, "Extendable", cmd, 10, vgextendable, vg_extendable, "Whether VG is extendable.", 0)
+FIELD(VGS, vg, BIN, "Exported", cmd, 10, vgexported, vg_exported, "Whether VG is exported.", 0)
+FIELD(VGS, vg, BIN, "Partial", cmd, 10, vgpartial, vg_partial, "Whether VG is partial.", 0)
+FIELD(VGS, vg, STR, "AllocPol", cmd, 10, vgallocationpolicy, vg_allocation_policy, "VG allocation policy.", 0)
+FIELD(VGS, vg, BIN, "Clustered", cmd, 10, vgclustered, vg_clustered, "Whether VG is clustered.", 0)
 FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
 FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index d6f14f1..8fb1e92 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -159,6 +159,65 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_start, SECTOR_SIZE * pv->ba_start)
 GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_ba_size_set prop_not_implemented_set
 
+#define _pv_allocatable_set prop_not_implemented_set
+#define _pv_allocatable_get prop_not_implemented_get
+#define _pv_exported_set prop_not_implemented_set
+#define _pv_exported_get prop_not_implemented_get
+#define _pv_missing_set prop_not_implemented_set
+#define _pv_missing_get prop_not_implemented_get
+
+#define _vg_permissions_set prop_not_implemented_set
+#define _vg_permissions_get prop_not_implemented_get
+#define _vg_extendable_set prop_not_implemented_set
+#define _vg_extendable_get prop_not_implemented_get
+#define _vg_exported_set prop_not_implemented_set
+#define _vg_exported_get prop_not_implemented_get
+#define _vg_partial_set prop_not_implemented_set
+#define _vg_partial_get prop_not_implemented_get
+#define _vg_allocation_policy_set prop_not_implemented_set
+#define _vg_allocation_policy_get prop_not_implemented_get
+#define _vg_clustered_set prop_not_implemented_set
+#define _vg_clustered_get prop_not_implemented_get
+
+#define _lv_volume_type_set prop_not_implemented_set
+#define _lv_volume_type_get prop_not_implemented_get
+#define _lv_initial_image_sync_set prop_not_implemented_set
+#define _lv_initial_image_sync_get prop_not_implemented_get
+#define _lv_image_synced_get prop_not_implemented_get
+#define _lv_image_synced_set prop_not_implemented_set
+#define _lv_image_synced_get prop_not_implemented_get
+#define _lv_merging_set prop_not_implemented_set
+#define _lv_merging_get prop_not_implemented_get
+#define _lv_converting_set prop_not_implemented_set
+#define _lv_converting_get prop_not_implemented_get
+#define _lv_permissions_set prop_not_implemented_set
+#define _lv_permissions_get prop_not_implemented_get
+#define _lv_allocation_policy_set prop_not_implemented_set
+#define _lv_allocation_policy_get prop_not_implemented_get
+#define _lv_allocation_locked_set prop_not_implemented_set
+#define _lv_allocation_locked_get prop_not_implemented_get
+#define _lv_fixed_minor_set prop_not_implemented_set
+#define _lv_fixed_minor_get prop_not_implemented_get
+#define _lv_merge_failed_set prop_not_implemented_set
+#define _lv_merge_failed_get prop_not_implemented_get
+#define _lv_snapshot_invalid_set prop_not_implemented_set
+#define _lv_snapshot_invalid_get prop_not_implemented_get
+#define _lv_suspended_set prop_not_implemented_set
+#define _lv_suspended_get prop_not_implemented_get
+#define _lv_live_table_set prop_not_implemented_set
+#define _lv_live_table_get prop_not_implemented_get
+#define _lv_inactive_table_set prop_not_implemented_set
+#define _lv_inactive_table_get prop_not_implemented_get
+#define _lv_device_open_set prop_not_implemented_set
+#define _lv_device_open_get prop_not_implemented_get
+#define _lv_target_type_set prop_not_implemented_set
+#define _lv_target_type_get prop_not_implemented_get
+#define _lv_health_status_set prop_not_implemented_set
+#define _lv_health_status_get prop_not_implemented_get
+#define _lv_target_type_get prop_not_implemented_get
+#define _lv_skip_activation_set prop_not_implemented_set
+#define _lv_skip_activation_get prop_not_implemented_get
+
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set prop_not_implemented_set
@@ -348,6 +407,7 @@ struct lvm_property_type _properties[] = {
 
 #undef STR
 #undef NUM
+#undef BIN
 #undef SIZ
 #undef PCT
 #undef STR_LIST
diff --git a/lib/report/report.c b/lib/report/report.c
index 27d2de7..d74321e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -42,6 +42,7 @@ struct lvm_report_object {
 };
 
 static const uint64_t _zero64 = UINT64_C(0);
+static const uint64_t _one64 = UINT64_C(1);
 
 static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
 static const uint64_t _reserved_number_unmanaged_64 = UINT64_C(-2);
@@ -68,6 +69,8 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 	{0, NULL, NULL}
 };
 
+static const char *_str_unknown = "unknown";
+
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
 	dm_report_field_set_value(field, data, sort);
@@ -1168,6 +1171,334 @@ static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
+/* PV/VG/LV Attributes */
+
+static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+			struct dm_report_field *field, int bin_value, const char *word,
+			void *private)
+{
+	return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
+}
+
+static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	int allocatable = (((const struct physical_volume *) data)->status & ALLOCATABLE_PV) != 0;
+	return _binary_disp(rh, mem, field, allocatable, "allocatable", private);
+}
+
+static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	int exported = (((const struct physical_volume *) data)->status & EXPORTED_VG) != 0;
+	return _binary_disp(rh, mem, field, exported, "exported", private);
+}
+
+static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	int missing = (((const struct physical_volume *) data)->status & MISSING_PV) != 0;
+	return _binary_disp(rh, mem, field, missing, "missing", private);
+}
+
+static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	const char *perms = ((const struct volume_group *) data)->status & LVM_WRITE ? "writeable" : "read-only";
+	return _string_disp(rh, mem, field, &perms, private);
+}
+
+static int _vgextendable_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	int extendable = (vg_is_resizeable((const struct volume_group *) data)) != 0;
+	return _binary_disp(rh, mem, field, extendable, "extendable", private);
+}
+
+static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	int exported = (vg_is_exported((const struct volume_group *) data)) != 0;
+	return _binary_disp(rh, mem, field, exported, "exported", private);
+}
+
+static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	int partial = (vg_missing_pv_count((const struct volume_group *) data)) != 0;
+	return _binary_disp(rh, mem, field, partial, "partial", private);
+}
+
+static int _vgallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const char *alloc_policy = get_alloc_string(((const struct volume_group *) data)->alloc) ? : _str_unknown;
+	return _string_disp(rh, mem, field, &alloc_policy, private);
+}
+
+static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	int clustered = (vg_is_clustered((const struct volume_group *) data)) != 0;
+	return _binary_disp(rh, mem, field, clustered, "clustered", private);
+}
+
+static int _lvvolumetype_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const char *type = lv_type_name((const struct logical_volume *) data);
+	return _string_disp(rh, mem, field, &type, private);
+}
+
+static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int initial_image_sync;
+
+	if (lv_is_raid(lv) || lv_is_mirrored(lv))
+		initial_image_sync = (lv->status & LV_NOTSYNCED) == 0;
+	else
+		initial_image_sync = 0;
+
+	return _binary_disp(rh, mem, field, initial_image_sync, "initial image sync", private);
+}
+
+static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int image_synced;
+
+	if (lv_is_raid_image(lv))
+		image_synced = !lv_is_visible(lv) && lv_raid_image_in_sync(lv);
+	else if (lv_is_mirror_image(lv))
+		image_synced = lv_mirror_image_in_sync(lv);
+	else
+		image_synced = 0;
+
+	return _binary_disp(rh, mem, field, image_synced, "image synced", private);
+}
+
+static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	int merging;
+
+	if (lv_is_origin(lv) || lv_is_external_origin(lv))
+		merging = lv_is_merging_origin(lv);
+	else if (lv_is_cow(lv))
+		merging = lv_is_merging_cow(lv);
+	else if (lv_is_thin_volume(lv))
+		merging = lv_is_merging_thin_snapshot(lv);
+	else
+		merging = 0;
+
+	return _binary_disp(rh, mem, field, merging, "merging", private);
+}
+
+static int _lvconverting_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	int converting = (((const struct logical_volume *) data)->status & CONVERTING) != 0;
+	return _binary_disp(rh, mem, field, converting, "converting", private);
+}
+
+static int _lvpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+	const char *perms = "";
+
+	if (!(lvi->lv->status & PVMOVE)) {
+		if (lvi->lv->status & LVM_WRITE) {
+			if (lvi->info->read_only)
+				perms = "read-only-override";
+			else
+				perms = "writeable";
+		} else if (lvi->lv->status & LVM_READ)
+			perms = "read-only";
+		else
+			perms = _str_unknown;
+	}
+
+	return _string_disp(rh, mem, field, &perms, private);
+}
+
+static int _lvallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const char *alloc_policy = get_alloc_string(((const struct logical_volume *) data)->alloc) ? : _str_unknown;
+	return _string_disp(rh, mem, field, &alloc_policy, private);
+}
+
+static int _lvallocationlocked_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	int alloc_locked = (((const struct logical_volume *) data)->status & LOCKED) != 0;
+	return _binary_disp(rh, mem, field, alloc_locked, "allocation locked", private);
+}
+
+static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	int fixed_minor = (((const struct logical_volume *) data)->status & FIXED_MINOR) != 0;
+	return _binary_disp(rh, mem, field, fixed_minor, "fixed minor", private);
+}
+
+static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	dm_percent_t snap_percent;
+	int merge_failed;
+
+	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &snap_percent))
+		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+
+	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
+	return _binary_disp(rh, mem, field, merge_failed, "merge failed", private);
+}
+
+static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	dm_percent_t snap_percent;
+	int snap_invalid;
+
+	if (!lv_is_cow(lv))
+		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+
+	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
+	return _binary_disp(rh, mem, field, snap_invalid, "snapshot invalid", private);
+}
+
+static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+
+	if (lvi->info->exists)
+		return _binary_disp(rh, mem, field, lvi->info->suspended, "suspended", private);
+
+	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+}
+
+static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
+{
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+
+	if (lvi->info->exists)
+		return _binary_disp(rh, mem, field, lvi->info->live_table, "live table present", private);
+
+	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+}
+
+static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+
+	if (lvi->info->exists)
+		return _binary_disp(rh, mem, field, lvi->info->inactive_table, "inactive table present", private);
+
+	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+}
+
+static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
+
+	if (lvi->info->exists)
+		return _binary_disp(rh, mem, field, lvi->info->open_count, "open", private);
+
+	return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+}
+
+static int _lvtargettype_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const char *target_type = "unknown";
+
+	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
+		target_type = "thin";
+	else if (lv_is_cache_type(lv))
+		target_type = "cache";
+	else if (lv_is_raid_type(lv))
+		target_type = "raid";
+	else if (lv_is_mirror_type(lv))
+		target_type = "mirror";
+	else if (lv_is_cow(lv) || lv_is_origin(lv))
+		target_type = "snapshot";
+	else if (lv_is_virtual(lv))
+		target_type = "virtual";
+
+	return _string_disp(rh, mem, field, &target_type, private);
+}
+
+static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+				struct dm_report_field *field,
+				const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const char *health = "";
+	uint64_t n;
+
+	if (lv->status & PARTIAL_LV)
+		health = "partial";
+	else if (lv_is_raid_type(lv)) {
+		if (!activation())
+			health = "unknown";
+		else if (!lv_raid_healthy(lv))
+			health = "refresh needed";
+		else if (lv_is_raid(lv)) {
+			if (lv_raid_mismatch_count(lv, &n) && n)
+				health = "mismatches exist";
+		} else if (lv->status & LV_WRITEMOSTLY)
+			health = "writemostly";
+	}
+
+	return _string_disp(rh, mem, field, &health, private);
+}
+
+static int _lvskipactivation_disp(struct dm_report *rh, struct dm_pool *mem,
+				  struct dm_report_field *field,
+				  const void *data, void *private)
+{
+	int skip_activation = (((const struct logical_volume *) data)->status & LV_ACTIVATION_SKIP) != 0;
+	return _binary_disp(rh, mem, field, skip_activation, "skip activation", private);
+}
+
 /* Report object types */
 
 /* necessary for displaying something for PVs not belonging to VG */
@@ -1249,6 +1580,7 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
+#define BIN DM_REPORT_FIELD_TYPE_NUMBER
 #define SIZ DM_REPORT_FIELD_TYPE_SIZE
 #define PCT DM_REPORT_FIELD_TYPE_PERCENT
 #define STR_LIST DM_REPORT_FIELD_TYPE_STRING_LIST
@@ -1277,6 +1609,7 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 
 #undef STR
 #undef NUM
+#undef BIN
 #undef SIZ
 #undef STR_LIST
 #undef FIELD


