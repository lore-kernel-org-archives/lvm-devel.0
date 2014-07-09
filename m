From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Jul 2014 13:57:55 +0000 (UTC)
Subject: master - report: also recognize 'yes'/'no' for selection criteria on binary fields
Message-ID: <20140709135755.E145360F59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46ea315f09306836cc10826b0e94da4685351d1c
Commit:        46ea315f09306836cc10826b0e94da4685351d1c
Parent:        c1bed36b670660527caf70182c39080764df71d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 9 15:10:43 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 9 15:57:05 2014 +0200

report: also recognize 'yes'/'no' for selection criteria on binary fields

We have 1/"descriptive word"/"yes" for 1 and 0/"no" for 0.
For example (the new recognized values are "yes" and "no"):

$ lvs -o name,device_open fedora vg/lvol1 vg/lvol2
  LV    DevOpen
  root        open
  swap        open
  lvol1       open
  lvol2

$ lvs -o name,device_open fedora vg/lvol1 vg/lvol2 -S 'device_open=open'
  LV    DevOpen
  root        open
  swap        open
  lvol1       open

$ lvs -o name,device_open fedora vg/lvol1 vg/lvol2 -S 'device_open=1'
  LV    DevOpen
  root        open
  swap        open
  lvol1       open

$ lvs -o name,device_open fedora vg/lvol1 vg/lvol2 -S 'device_open=yes'
  LV    DevOpen
  root        open
  swap        open
  lvol1       open

$ lvs -o name,device_open fedora vg/lvol1 vg/lvol2 -S 'device_open=0'
  LV    DevOpen
  lvol2

$ lvs -o name,device_open fedora vg/lvol1 vg/lvol2 -S 'device_open=no'
  LV    DevOpen
  lvol2
---
 lib/report/report.c |  144 +++++++++++++++++++++++++++------------------------
 1 files changed, 77 insertions(+), 67 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 198fdfa..a2f4541 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -56,6 +56,8 @@ static const uint64_t _zero64 = UINT64_C(0);
 static const uint64_t _one64 = UINT64_C(1);
 static const char const _str_zero[] = "0";
 static const char const _str_one[] = "1";
+static const char const _str_no[] = "no";
+static const char const _str_yes[] = "yes";
 static const char const _str_minus_one[] = "-1";
 static const char const _str_unknown[] = "unknown";
 
@@ -73,6 +75,9 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 #define FIELD_RESERVED_VALUE(field_id, id, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
 	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
+#define FIELD_RESERVED_BINARY_VALUE(field_id, id, ...) \
+	FIELD_RESERVED_VALUE(field_id, id ## _y, _one64, __VA_ARGS__, _str_yes) \
+	FIELD_RESERVED_VALUE(field_id, id ## _n, _zero64, __VA_ARGS__, _str_no)
 
 /*
  * Reserved values and their assigned names.
@@ -82,35 +87,37 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
  *
  * TYPE_RESERVED_VALUE(type, reserved_value_id, value, reserved name, ...)
  * FIELD_RESERVED_VALUE(field_id, reserved_value_id, value, reserved name, ...)
+ * FIELD_RESERVED_BINARY_VALUE(field_id, reserved_value_id, value, reserved name for 1, ...)
  *
  */
+
 TYPE_RESERVED_VALUE(uint64_t, number_undef_64, UINT64_C(-1), _str_minus_one, _str_unknown, "undefined", "undef");
-FIELD_RESERVED_VALUE(pv_allocatable, pv_allocatable, _one64, "allocatable")
-FIELD_RESERVED_VALUE(pv_exported, pv_exported, _one64, "exported")
-FIELD_RESERVED_VALUE(pv_missing, pv_missing, _one64, "missing")
-FIELD_RESERVED_VALUE(vg_extendable, vg_extendable, _one64, "extendable")
-FIELD_RESERVED_VALUE(vg_exported, vg_exported, _one64, "exported")
-FIELD_RESERVED_VALUE(vg_partial, vg_partial, _one64, "partial")
-FIELD_RESERVED_VALUE(vg_clustered, vg_clustered, _one64, "clustered")
+FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "allocatable")
+FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "exported")
+FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "missing")
+FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "extendable")
+FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "exported")
+FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "partial")
+FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "clustered")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read_write")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, _reserved_number_undef_64, "unmanaged")
-FIELD_RESERVED_VALUE(lv_initial_image_sync, lv_initial_image_sync, _one64, "initial image sync", "sync")
-FIELD_RESERVED_VALUE(lv_image_synced, lv_image_synced, _one64, "image synced", "synced")
-FIELD_RESERVED_VALUE(lv_merging, lv_merging, _one64, "merging")
-FIELD_RESERVED_VALUE(lv_converting, lv_converting, _one64, "converting")
-FIELD_RESERVED_VALUE(lv_allocation_locked, lv_allocation_locked, _one64, "allocation locked", "locked")
-FIELD_RESERVED_VALUE(lv_fixed_minor, lv_fixed_minor, _one64, "fixed minor", "fixed")
-FIELD_RESERVED_VALUE(lv_active_locally, lv_active_locally, _one64, "active locally", "active", "locally")
-FIELD_RESERVED_VALUE(lv_active_remotely, lv_active_remotely, _one64, "active remotely", "active", "remotely")
-FIELD_RESERVED_VALUE(lv_active_exclusively, lv_active_exclusively, _one64, "active exclusively", "active", "exclusively")
-FIELD_RESERVED_VALUE(lv_merge_failed, lv_merge_failed, _one64, "merge failed", "failed")
-FIELD_RESERVED_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, _one64, "snapsot invalid", "invalid")
-FIELD_RESERVED_VALUE(lv_suspended, lv_suspended, _one64, "suspended")
-FIELD_RESERVED_VALUE(lv_live_table, lv_live_table, _one64, "live table present", "live table", "live")
-FIELD_RESERVED_VALUE(lv_inactive_table, lv_inactive_table, _one64, "inactive table present", "inactive table", "inactive")
-FIELD_RESERVED_VALUE(lv_device_open, lv_device_open, _one64, "open")
-FIELD_RESERVED_VALUE(lv_skip_activation, lv_skip_activation, _one64, "skip activation", "skip")
+FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "initial image sync", "sync")
+FIELD_RESERVED_BINARY_VALUE(lv_image_synced, lv_image_synced, "image synced", "synced")
+FIELD_RESERVED_BINARY_VALUE(lv_merging, lv_merging, "merging")
+FIELD_RESERVED_BINARY_VALUE(lv_converting, lv_converting, "converting")
+FIELD_RESERVED_BINARY_VALUE(lv_allocation_locked, lv_allocation_locked, "allocation locked", "locked")
+FIELD_RESERVED_BINARY_VALUE(lv_fixed_minor, lv_fixed_minor, "fixed minor", "fixed")
+FIELD_RESERVED_BINARY_VALUE(lv_active_locally, lv_active_locally, "active locally", "active", "locally")
+FIELD_RESERVED_BINARY_VALUE(lv_active_remotely, lv_active_remotely, "active remotely", "active", "remotely")
+FIELD_RESERVED_BINARY_VALUE(lv_active_exclusively, lv_active_exclusively, "active exclusively", "active", "exclusively")
+FIELD_RESERVED_BINARY_VALUE(lv_merge_failed, lv_merge_failed, "merge failed", "failed")
+FIELD_RESERVED_BINARY_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, "snapsot invalid", "invalid")
+FIELD_RESERVED_BINARY_VALUE(lv_suspended, lv_suspended, "suspended")
+FIELD_RESERVED_BINARY_VALUE(lv_live_table, lv_live_table, "live table present", "live table", "live")
+FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "inactive table present", "inactive table", "inactive")
+FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "open")
+FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "skip activation", "skip")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
@@ -118,6 +125,9 @@ FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, _reserved_number_undef_64, "a
 
 #define TYPE_RESERVED_VALUE_REG(type, id, description) {DM_REPORT_FIELD_TYPE_ ## type, &_reserved_ ## id, _reserved_ ## id ## _names, description},
 #define FIELD_RESERVED_VALUE_REG(id, description) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+#define FIELD_RESERVED_BINARY_VALUE_REG(id, description) \
+	FIELD_RESERVED_VALUE_REG(id ## _y, description) \
+	FIELD_RESERVED_VALUE_REG(id ## _n, description)
 
 /*
  * Create array of reserved values to be passed for dm_report_init_with_selection
@@ -126,32 +136,32 @@ FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, _reserved_number_undef_64, "a
  */
 static const struct dm_report_reserved_value _report_reserved_values[] = {
 	TYPE_RESERVED_VALUE_REG(NUMBER, number_undef_64, "Reserved value for undefined numeric value.")
-	FIELD_RESERVED_VALUE_REG(pv_allocatable, "pv_allocatable reserved values")
-	FIELD_RESERVED_VALUE_REG(pv_exported, "pv_exported reserved values")
-	FIELD_RESERVED_VALUE_REG(pv_missing, "pv_missing reserved values")
-	FIELD_RESERVED_VALUE_REG(vg_extendable, "vg_extendable reserved values")
-	FIELD_RESERVED_VALUE_REG(vg_exported, "vg_exported reserved values")
-	FIELD_RESERVED_VALUE_REG(vg_partial, "vg_partial reserved values")
-	FIELD_RESERVED_VALUE_REG(vg_clustered, "vg_clustered reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(pv_allocatable, "pv_allocatable reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(pv_exported, "pv_exported reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(pv_missing, "pv_missing reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(vg_extendable, "vg_extendable reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(vg_exported, "vg_exported reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(vg_partial, "vg_partial reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(vg_clustered, "vg_clustered reserved values")
 	FIELD_RESERVED_VALUE_REG(vg_permissions_rw, "vg_permissions reserved values (writeable)")
 	FIELD_RESERVED_VALUE_REG(vg_permissions_r, "vg_permissions reserved values (read-only)")
 	FIELD_RESERVED_VALUE_REG(vg_mda_copies, "vg_mda_copies reserved values (unmanaged)")
-	FIELD_RESERVED_VALUE_REG(lv_initial_image_sync, "lv_initial_image_sync reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_image_synced, "lv_image_synced reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_merging, "lv_merging reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_converting, "lv_converting reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_allocation_locked, "lv_allocation_locked reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_fixed_minor, "lv_fixed_minor reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_active_locally, "lv_active_locally reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_active_remotely, "lv_active_remotelly reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_active_exclusively, "lv_active_exclusively reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_merge_failed, "lv_merge_failed reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_snapshot_invalid, "lv_snapshot_invalid reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_suspended, "lv_suspended reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_live_table, "lv_live_table reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_inactive_table, "lv_inactive_table reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_device_open, "lv_device_open reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_skip_activation, "lv_inactive_table reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_initial_image_sync, "lv_initial_image_sync reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_image_synced, "lv_image_synced reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_merging, "lv_merging reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_converting, "lv_converting reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_allocation_locked, "lv_allocation_locked reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_fixed_minor, "lv_fixed_minor reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_active_locally, "lv_active_locally reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_active_remotely, "lv_active_remotelly reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_active_exclusively, "lv_active_exclusively reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_merge_failed, "lv_merge_failed reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_snapshot_invalid, "lv_snapshot_invalid reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_suspended, "lv_suspended reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_live_table, "lv_live_table reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_inactive_table, "lv_inactive_table reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_device_open, "lv_device_open reserved values")
+	FIELD_RESERVED_BINARY_VALUE_REG(lv_skip_activation, "lv_inactive_table reserved values")
 	FIELD_RESERVED_VALUE_REG(lv_permissions_rw, "lv_permissions reserved values (writeable)")
 	FIELD_RESERVED_VALUE_REG(lv_permissions_r, "lv_permissions reserved values (read-only)")
 	FIELD_RESERVED_VALUE_REG(lv_permissions_r_override,  "lv_permissions reserved values (read-only-override)")
@@ -1270,7 +1280,7 @@ static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
 			       const void *data, void *private)
 {
 	int allocatable = (((const struct physical_volume *) data)->status & ALLOCATABLE_PV) != 0;
-	return _binary_disp(rh, mem, field, allocatable, FIRST_NAME(pv_allocatable), private);
+	return _binary_disp(rh, mem, field, allocatable, FIRST_NAME(pv_allocatable_y), private);
 }
 
 static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1278,7 +1288,7 @@ static int _pvexported_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	int exported = (((const struct physical_volume *) data)->status & EXPORTED_VG) != 0;
-	return _binary_disp(rh, mem, field, exported, FIRST_NAME(pv_exported), private);
+	return _binary_disp(rh, mem, field, exported, FIRST_NAME(pv_exported_y), private);
 }
 
 static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1286,7 +1296,7 @@ static int _pvmissing_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	int missing = (((const struct physical_volume *) data)->status & MISSING_PV) != 0;
-	return _binary_disp(rh, mem, field, missing, FIRST_NAME(pv_missing), private);
+	return _binary_disp(rh, mem, field, missing, FIRST_NAME(pv_missing_y), private);
 }
 
 static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1303,7 +1313,7 @@ static int _vgextendable_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	int extendable = (vg_is_resizeable((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, extendable, FIRST_NAME(vg_extendable), private);
+	return _binary_disp(rh, mem, field, extendable, FIRST_NAME(vg_extendable_y),private);
 }
 
 static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1311,7 +1321,7 @@ static int _vgexported_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	int exported = (vg_is_exported((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, exported, FIRST_NAME(vg_exported), private);
+	return _binary_disp(rh, mem, field, exported, FIRST_NAME(vg_exported_y), private);
 }
 
 static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1319,7 +1329,7 @@ static int _vgpartial_disp(struct dm_report *rh, struct dm_pool *mem,
 			   const void *data, void *private)
 {
 	int partial = (vg_missing_pv_count((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, partial, FIRST_NAME(vg_partial), private);
+	return _binary_disp(rh, mem, field, partial, FIRST_NAME(vg_partial_y), private);
 }
 
 static int _vgallocationpolicy_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1335,7 +1345,7 @@ static int _vgclustered_disp(struct dm_report *rh, struct dm_pool *mem,
 			     const void *data, void *private)
 {
 	int clustered = (vg_is_clustered((const struct volume_group *) data)) != 0;
-	return _binary_disp(rh, mem, field, clustered, FIRST_NAME(vg_clustered), private);
+	return _binary_disp(rh, mem, field, clustered, FIRST_NAME(vg_clustered_y), private);
 }
 
 static int _lvvolumetype_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1358,7 +1368,7 @@ static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		initial_image_sync = 0;
 
-	return _binary_disp(rh, mem, field, initial_image_sync, FIRST_NAME(lv_initial_image_sync), private);
+	return _binary_disp(rh, mem, field, initial_image_sync, FIRST_NAME(lv_initial_image_sync_y), private);
 }
 
 static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1375,7 +1385,7 @@ static int _lvimagesynced_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		image_synced = 0;
 
-	return _binary_disp(rh, mem, field, image_synced, FIRST_NAME(lv_image_synced), private);
+	return _binary_disp(rh, mem, field, image_synced, FIRST_NAME(lv_image_synced_y), private);
 }
 
 static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1394,7 +1404,7 @@ static int _lvmerging_disp(struct dm_report *rh, struct dm_pool *mem,
 	else
 		merging = 0;
 
-	return _binary_disp(rh, mem, field, merging, FIRST_NAME(lv_merging), private);
+	return _binary_disp(rh, mem, field, merging, FIRST_NAME(lv_merging_y), private);
 }
 
 static int _lvconverting_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1440,7 +1450,7 @@ static int _lvallocationlocked_disp(struct dm_report *rh, struct dm_pool *mem,
 				    const void *data, void *private)
 {
 	int alloc_locked = (((const struct logical_volume *) data)->status & LOCKED) != 0;
-	return _binary_disp(rh, mem, field, alloc_locked, FIRST_NAME(lv_allocation_locked), private);
+	return _binary_disp(rh, mem, field, alloc_locked, FIRST_NAME(lv_allocation_locked_y), private);
 }
 
 static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1448,7 +1458,7 @@ static int _lvfixedminor_disp(struct dm_report *rh, struct dm_pool *mem,
 			      const void *data, void *private)
 {
 	int fixed_minor = (((const struct logical_volume *) data)->status & FIXED_MINOR) != 0;
-	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor), private);
+	return _binary_disp(rh, mem, field, fixed_minor, FIRST_NAME(lv_fixed_minor_y), private);
 }
 
 static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1478,7 +1488,7 @@ static int _lvactivelocally_disp(struct dm_report *rh, struct dm_pool *mem,
 	} else
 		active_locally = lv_is_active(lv);
 
-	return _binary_disp(rh, mem, field, active_locally, FIRST_NAME(lv_active_locally), private);
+	return _binary_disp(rh, mem, field, active_locally, FIRST_NAME(lv_active_locally_y), private);
 }
 
 static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1494,7 +1504,7 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
 	} else
 		active_remotely = 0;
 
-	return _binary_disp(rh, mem, field, active_remotely, FIRST_NAME(lv_active_remotely), private);
+	return _binary_disp(rh, mem, field, active_remotely, FIRST_NAME(lv_active_remotely_y), private);
 }
 
 static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1510,7 +1520,7 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
 	} else
 		active_exclusively = lv_is_active(lv);
 
-	return _binary_disp(rh, mem, field, active_exclusively, FIRST_NAME(lv_active_exclusively), private);
+	return _binary_disp(rh, mem, field, active_exclusively, FIRST_NAME(lv_active_exclusively_y), private);
 }
 
 static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1525,7 +1535,7 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
 
 	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
-	return _binary_disp(rh, mem, field, merge_failed, FIRST_NAME(lv_merge_failed), private);
+	return _binary_disp(rh, mem, field, merge_failed, FIRST_NAME(lv_merge_failed_y), private);
 }
 
 static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1540,7 +1550,7 @@ static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
 
 	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
-	return _binary_disp(rh, mem, field, snap_invalid, FIRST_NAME(lv_snapshot_invalid), private);
+	return _binary_disp(rh, mem, field, snap_invalid, FIRST_NAME(lv_snapshot_invalid_y), private);
 }
 
 static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1550,7 +1560,7 @@ static int _lvsuspended_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->suspended, FIRST_NAME(lv_suspended), private);
+		return _binary_disp(rh, mem, field, lvi->info->suspended, FIRST_NAME(lv_suspended_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1562,7 +1572,7 @@ static int _lvlivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->live_table, FIRST_NAME(lv_live_table), private);
+		return _binary_disp(rh, mem, field, lvi->info->live_table, FIRST_NAME(lv_live_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1574,7 +1584,7 @@ static int _lvinactivetable_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->inactive_table, FIRST_NAME(lv_inactive_table), private);
+		return _binary_disp(rh, mem, field, lvi->info->inactive_table, FIRST_NAME(lv_inactive_table_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
@@ -1586,7 +1596,7 @@ static int _lvdeviceopen_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (lvi->info->exists)
-		return _binary_disp(rh, mem, field, lvi->info->open_count, FIRST_NAME(lv_device_open), private);
+		return _binary_disp(rh, mem, field, lvi->info->open_count, FIRST_NAME(lv_device_open_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }


