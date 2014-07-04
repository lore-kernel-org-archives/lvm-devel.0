From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:27 +0000 (UTC)
Subject: master - report: define reserved values/synonyms for some attribute fields
Message-ID: <20140704140027.19AFC60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7021c8f1a483d91a58ce2abc52583e73e2910da7
Commit:        7021c8f1a483d91a58ce2abc52583e73e2910da7
Parent:        0956fd230fea550707acb2889223438996102de4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 4 12:08:52 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:50:50 2014 +0200

report: define reserved values/synonyms for some attribute fields

All binary attr fields have synonyms so selection criteria can use
either 0/1 or words to match against the field value (base type
for these binary fields is numeric one - DM_REPORT_FIELD_TYPE_NUMBER
so words are registered as reserved values):

pv_allocatable          - "allocatable"
pv_exported             - "exported"
pv_missing              - "missing"

vg_extendable           - "extendable"
vg_exported             - "exported"
vg_partial              - "partial"
vg_clustered            - "clustered"

lv_initial_image_sync   - "initial image sync", "sync"
lv_image_synced_names   - "image synced", "synced"
lv_merging_names        - "merging"
lv_converting_names     - "converting"
lv_allocation_locked    - "allocation locked", "locked"
lv_fixed_minor          - "fixed minor", "fixed"
lv_merge_failed         - "merge failed", "failed"

For example, these three are all equivalent:

$ lvs -o name,fixed_minor -S 'fixed_minor=fixed'
  LV    FixMin
  lvol8 fixed minor

$ lvs -o name,fixed_minor -S 'fixed_minor="fixed minor"'
  LV    FixMin
  lvol8 fixed minor

$ lvs -o name,fixed_minor -S 'fixed_minor=1'
  LV    FixMin
  lvol8 fixed minor

The same with binary output - it has no effect on this functionality:

$ lvs -o name,fixed_minor --binary -S 'fixed_minor=fixed'
  LV    FixMin
  lvol8          1

$ lvs -o name,fixed_minor --binary -S 'fixed_minor="fixed
minor"'
  LV    FixMin
  lvol8          1

[1] f20/~ # lvs -o name,fixed_minor --binary -S 'fixed_minor=1'
  LV    FixMin
  lvol8          1
---
 lib/report/report.c |  142 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 131 insertions(+), 11 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 284a718..7cc3599 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -41,15 +41,27 @@ struct lvm_report_object {
 	struct label *label;
 };
 
+/* Enum for field_num index to use in per-field reserved value definition. */
+#define FIELD(type, strct, sorttype, head, field_name, width, func, id, desc, writeable) field_ ## id,
+enum {
+#include "columns.h"
+};
+#undef FIELD
+
+
 static const uint64_t _zero64 = UINT64_C(0);
 static const uint64_t _one64 = UINT64_C(1);
 static const char * const _str_zero = "0";
 static const char * const _str_one = "1";
 
-static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
-static const uint64_t _reserved_number_unmanaged_64 = UINT64_C(-2);
-static const uint64_t _reserved_size_auto_64 = UINT64_C(-1);
+/*
+ * TODO: try to automate reserved value definition and declare reserved values
+ *       using FIELD macro directly. The FIELD macro should be able to define
+ *       proper structures automatically then.
+ */
 
+/* Per-type reserved values. */
+static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
 /*
  * 32 bit signed is casted to 64 bit unsigned in dm_report_field internally!
  * So when stored in the struct, the _reserved_number_undef_32 is actually
@@ -57,17 +69,125 @@ static const uint64_t _reserved_size_auto_64 = UINT64_C(-1);
  */
 static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 
+/* Per-field reserved values. */
+static const struct dm_report_field_reserved_value _reserved_pv_allocatable = {field_pv_allocatable, &_one64};
+static const struct dm_report_field_reserved_value _reserved_pv_exported = {field_pv_exported, &_one64};
+static const struct dm_report_field_reserved_value _reserved_pv_missing = {field_pv_missing, &_one64};
+static const struct dm_report_field_reserved_value _reserved_vg_extendable = {field_vg_extendable, &_one64};
+static const struct dm_report_field_reserved_value _reserved_vg_exported = {field_vg_exported, &_one64};
+static const struct dm_report_field_reserved_value _reserved_vg_partial = {field_vg_partial, &_one64};
+static const struct dm_report_field_reserved_value _reserved_vg_clustered = {field_vg_clustered, &_one64};
+static const struct dm_report_field_reserved_value _reserved_vg_permissions_rw = {field_vg_permissions, "writeable"};
+static const struct dm_report_field_reserved_value _reserved_vg_permissions_r = {field_vg_permissions, "read-only"};
+static const struct dm_report_field_reserved_value _reserved_vg_mda_copies = {field_vg_mda_copies, &_reserved_number_undef_64};
+static const struct dm_report_field_reserved_value _reserved_lv_initial_image_sync = {field_lv_initial_image_sync, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_image_synced = {field_lv_image_synced, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_merging = {field_lv_merging, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_converting = {field_lv_converting, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_allocation_locked = {field_lv_allocation_locked, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_fixed_minor = {field_lv_fixed_minor, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_merge_failed = {field_lv_merge_failed, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_snapshot_invalid = {field_lv_snapshot_invalid, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_suspended = {field_lv_suspended, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_live_table = {field_lv_live_table, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_inactive_table = {field_lv_inactive_table, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_device_open = {field_lv_device_open, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_skip_activation = {field_lv_skip_activation, &_one64};
+static const struct dm_report_field_reserved_value _reserved_lv_permissions_rw = {field_lv_permissions, "writeable"};
+static const struct dm_report_field_reserved_value _reserved_lv_permissions_r = {field_lv_permissions, "read-only"};
+static const struct dm_report_field_reserved_value _reserved_lv_permissions_r_override = {field_lv_permissions, "read-only-override"};
+static const struct dm_report_field_reserved_value _reserved_lv_read_ahead = {field_lv_read_ahead, &_reserved_number_undef_64};
+
+/* Per-type reserved names. */
 static const char const *_reserved_number_undef_64_names[]={"-1", "undefined", "undef", "unknown", NULL};
-static const char const *_reserved_number_unmanaged_64_names[]={"unmanaged", NULL};
-static const char const *_reserved_size_auto_64_names[]={"auto", NULL};
 
+/* Per-field reserved names. */
+static const char *_reserved_pv_allocatable_names[]={"allocatable", NULL};
+static const char *_reserved_pv_exported_names[]={"exported", NULL};
+static const char *_reserved_pv_missing_names[]={"missing", NULL};
+static const char *_reserved_vg_extendable_names[]={"extendable", NULL};
+static const char *_reserved_vg_exported_names[]={"exported", NULL};
+static const char *_reserved_vg_partial_names[]={"partial", NULL};
+static const char *_reserved_vg_clustered_names[]={"clustered", NULL};
+static const char *_reserved_vg_permissions_rw_names[]={"writeable", "rw", "read-write", NULL};
+static const char *_reserved_vg_permissions_r_names[]={"read-only", "r", "ro", NULL};
+static const char *_reserved_vg_mda_copies_names[]={"unmanaged", NULL};
+static const char *_reserved_lv_initial_image_sync_names[]={"initial image sync", "sync", NULL};
+static const char *_reserved_lv_image_synced_names[]={"image synced", "synced", NULL};
+static const char *_reserved_lv_merging_names[]={"merging", NULL};
+static const char *_reserved_lv_converting_names[]={"converting", NULL};
+static const char *_reserved_lv_allocation_locked_names[]={"allocation locked", "locked", NULL};
+static const char *_reserved_lv_fixed_minor_names[]={"fixed minor", "fixed", NULL};
+static const char *_reserved_lv_merge_failed_names[]={"merge failed", "failed", NULL};
+static const char *_reserved_lv_snapshot_invalid_names[]={"snapsot invalid", "invalid", NULL};
+static const char *_reserved_lv_suspended_names[]={"suspended", NULL};
+static const char *_reserved_lv_live_table_names[]={"live table present", "live table", "live", NULL};
+static const char *_reserved_lv_inactive_table_names[]={"inactive table present", "inactive table", "inactive", NULL};
+static const char *_reserved_lv_device_open_names[]={"open", NULL};
+static const char *_reserved_lv_skip_activation_names[]={"skip activation", "skip", NULL};
+static const char *_reserved_lv_permissions_rw_names[]={"writeable", "rw", "read-write", NULL};
+static const char *_reserved_lv_permissions_r_names[]={"read-only", "r", "ro", NULL};
+static const char *_reserved_lv_permissions_r_override_names[]={"read-only-override", "ro-override", "r-override", "R", NULL};
+static const char *_reserved_lv_read_ahead_names[]={"auto", NULL};
+
+/* Put together arrays of reserved names with their reserved values. */
 static const struct dm_report_reserved_value _report_reserved_values[] = {
 	{DM_REPORT_FIELD_TYPE_NUMBER, &_reserved_number_undef_64, _reserved_number_undef_64_names,
 		"Reserved value for undefined numeric value."},
-	{DM_REPORT_FIELD_TYPE_NUMBER, &_reserved_number_unmanaged_64, _reserved_number_unmanaged_64_names,
-		"Reserved value for unmanaged number of metadata copies in VG."},
-	{DM_REPORT_FIELD_TYPE_SIZE, &_reserved_size_auto_64, _reserved_size_auto_64_names,
-		"Reserved value for size that is automatically calculated."},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_pv_allocatable, _reserved_pv_allocatable_names,
+		"pv_allocatable reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_pv_exported, _reserved_pv_exported_names,
+		"pv_exported reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_pv_missing, _reserved_pv_missing_names,
+		"pv_missing reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_extendable, _reserved_vg_extendable_names,
+		"vg_extendable reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_exported, _reserved_vg_exported_names,
+		"vg_exported reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_partial, _reserved_vg_partial_names,
+		"vg_partial reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_clustered, _reserved_vg_clustered_names,
+		"vg_clustered reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_permissions_rw, _reserved_vg_permissions_rw_names,
+		"vg_permissions reserved values (writeable)"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_permissions_r, _reserved_vg_permissions_r_names,
+		"vg_permissions reserved values (read-only)"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_vg_mda_copies, _reserved_vg_mda_copies_names,
+		"vg_mda_copies reserved values (unmanaged)"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_initial_image_sync, _reserved_lv_initial_image_sync_names,
+		"lv_initial_image_sync reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_image_synced, _reserved_lv_image_synced_names,
+		"lv_image_synced reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_merging, _reserved_lv_merging_names,
+		"lv_merging reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_converting, _reserved_lv_converting_names,
+		"lv_converting reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_allocation_locked, _reserved_lv_allocation_locked_names,
+		"lv_allocation_locked reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_fixed_minor, _reserved_lv_fixed_minor_names,
+		"lv_fixed_minor reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_merge_failed, _reserved_lv_merge_failed_names,
+		"lv_merge_failed reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_snapshot_invalid, _reserved_lv_snapshot_invalid_names,
+		"lv_snapshot_invalid reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_suspended, _reserved_lv_suspended_names,
+		"lv_suspended reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_live_table, _reserved_lv_live_table_names,
+		"lv_live_table reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_inactive_table, _reserved_lv_inactive_table_names,
+		"lv_inactive_table reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_device_open, _reserved_lv_device_open_names,
+		"lv_device_open reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_skip_activation, _reserved_lv_skip_activation_names,
+		"lv_inactive_table reserved values"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_permissions_rw, _reserved_lv_permissions_rw_names,
+		"lv_permissions reserved values (writeable)"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_permissions_r, _reserved_lv_permissions_r_names,
+		"lv_permissions reserved values (read-only)"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_permissions_r_override, _reserved_lv_permissions_r_override_names,
+		"lv_permissions reserved values (read-only-override)"},
+	{DM_REPORT_FIELD_TYPE_NONE, &_reserved_lv_read_ahead, _reserved_lv_read_ahead_names,
+		"lv_read_ahead reserved values (auto)"},
 	{0, NULL, NULL}
 };
 
@@ -542,7 +662,7 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
-		return _field_set_value(field, "auto", &_reserved_size_auto_64);
+		return _field_set_value(field, "auto", &_reserved_number_undef_64);
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -833,7 +953,7 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint32_t count = vg_mda_copies(vg);
 
 	if (count == VGMETADATACOPIES_UNMANAGED)
-		return _field_set_value(field, "unmanaged", &_reserved_number_unmanaged_64);
+		return _field_set_value(field, "unmanaged", &_reserved_number_undef_64);
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }


