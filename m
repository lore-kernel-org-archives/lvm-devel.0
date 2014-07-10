From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 07:44:00 +0000 (UTC)
Subject: master - report: add values.h for per-field reserved value declaration
Message-ID: <20140710074400.040E2611F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4e798bd304253b91b906ca77988b11576685d72
Commit:        a4e798bd304253b91b906ca77988b11576685d72
Parent:        be75076dfc842945a03fa42073e9e03f51bd3a3c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 09:22:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 09:41:21 2014 +0200

report: add values.h for per-field reserved value declaration

---
 lib/report/report.c |   78 +++++++++++++++++++++------------------------------
 lib/report/values.h |   74 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+), 46 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index a2f4541..d3dbefc 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -68,17 +68,6 @@ static const char const _str_unknown[] = "unknown";
  */
 static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 
-#define FIRST_NAME(id) _reserved_ ## id ## _names[0]
-#define TYPE_RESERVED_VALUE(type, id, value, ...) \
-	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
-	static const type _reserved_ ## id = value;
-#define FIELD_RESERVED_VALUE(field_id, id, value, ...) \
-	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
-	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
-#define FIELD_RESERVED_BINARY_VALUE(field_id, id, ...) \
-	FIELD_RESERVED_VALUE(field_id, id ## _y, _one64, __VA_ARGS__, _str_yes) \
-	FIELD_RESERVED_VALUE(field_id, id ## _n, _zero64, __VA_ARGS__, _str_no)
-
 /*
  * Reserved values and their assigned names.
  * The first name is the one that is also used for reporting.
@@ -89,51 +78,44 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
  * FIELD_RESERVED_VALUE(field_id, reserved_value_id, value, reserved name, ...)
  * FIELD_RESERVED_BINARY_VALUE(field_id, reserved_value_id, value, reserved name for 1, ...)
  *
+ * Note: FIELD_RESERVED_BINARY_VALUE creates:
+ * 		- 'reserved_value_id_y' (for 1)
+ * 		- 'reserved_value_id_n' (for 0)
  */
+#define FIRST_NAME(id) _reserved_ ## id ## _names[0]
+#define TYPE_RESERVED_VALUE(type, id, value, ...) \
+	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
+	static const type _reserved_ ## id = value;
+#define FIELD_RESERVED_VALUE(field_id, id, value, ...) \
+	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
+	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
+#define FIELD_RESERVED_BINARY_VALUE(field_id, id, ...) \
+	FIELD_RESERVED_VALUE(field_id, id ## _y, _one64, __VA_ARGS__, _str_yes) \
+	FIELD_RESERVED_VALUE(field_id, id ## _n, _zero64, __VA_ARGS__, _str_no)
 
 TYPE_RESERVED_VALUE(uint64_t, number_undef_64, UINT64_C(-1), _str_minus_one, _str_unknown, "undefined", "undef");
-FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "allocatable")
-FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "exported")
-FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "missing")
-FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "extendable")
-FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "exported")
-FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "partial")
-FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "clustered")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read_write")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, _reserved_number_undef_64, "unmanaged")
-FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "initial image sync", "sync")
-FIELD_RESERVED_BINARY_VALUE(lv_image_synced, lv_image_synced, "image synced", "synced")
-FIELD_RESERVED_BINARY_VALUE(lv_merging, lv_merging, "merging")
-FIELD_RESERVED_BINARY_VALUE(lv_converting, lv_converting, "converting")
-FIELD_RESERVED_BINARY_VALUE(lv_allocation_locked, lv_allocation_locked, "allocation locked", "locked")
-FIELD_RESERVED_BINARY_VALUE(lv_fixed_minor, lv_fixed_minor, "fixed minor", "fixed")
-FIELD_RESERVED_BINARY_VALUE(lv_active_locally, lv_active_locally, "active locally", "active", "locally")
-FIELD_RESERVED_BINARY_VALUE(lv_active_remotely, lv_active_remotely, "active remotely", "active", "remotely")
-FIELD_RESERVED_BINARY_VALUE(lv_active_exclusively, lv_active_exclusively, "active exclusively", "active", "exclusively")
-FIELD_RESERVED_BINARY_VALUE(lv_merge_failed, lv_merge_failed, "merge failed", "failed")
-FIELD_RESERVED_BINARY_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, "snapsot invalid", "invalid")
-FIELD_RESERVED_BINARY_VALUE(lv_suspended, lv_suspended, "suspended")
-FIELD_RESERVED_BINARY_VALUE(lv_live_table, lv_live_table, "live table present", "live table", "live")
-FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "inactive table present", "inactive table", "inactive")
-FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "open")
-FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "skip activation", "skip")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, _reserved_number_undef_64, "auto")
+#include "values.h"
 
+#undef TYPE_RESERVED_VALUE
+#undef FIELD_RESERVED_VALUE
+#undef FIELD_RESERVED_BINARY_VALUE
+
+/*
+ * Create array of reserved values to be registered with reporting code via
+ * dm_report_init_with_selection function that initializes report with
+ * selection criteria. Selection code then recognizes these reserved values
+ * when parsing selection criteria.
+ *
+ * TYPE_RESERVED_VALUE_REG(report_type, reserved_value_id, description)
+ * FIELD_RESERVED_VALUE_REG(reserved_value_id, description)
+ * FIELD_RESERVED_BINARY_BALUE_REG(reserved_value_id, description)
+ */
 #define TYPE_RESERVED_VALUE_REG(type, id, description) {DM_REPORT_FIELD_TYPE_ ## type, &_reserved_ ## id, _reserved_ ## id ## _names, description},
 #define FIELD_RESERVED_VALUE_REG(id, description) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, description},
 #define FIELD_RESERVED_BINARY_VALUE_REG(id, description) \
 	FIELD_RESERVED_VALUE_REG(id ## _y, description) \
 	FIELD_RESERVED_VALUE_REG(id ## _n, description)
 
-/*
- * Create array of reserved values to be passed for dm_report_init_with_selection
- * function that initializes report with selection criteria. Selection code then
- * recognizes these reserved values when parsing selection criteria.
- */
 static const struct dm_report_reserved_value _report_reserved_values[] = {
 	TYPE_RESERVED_VALUE_REG(NUMBER, number_undef_64, "Reserved value for undefined numeric value.")
 	FIELD_RESERVED_BINARY_VALUE_REG(pv_allocatable, "pv_allocatable reserved values")
@@ -169,6 +151,10 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 	{0, NULL, NULL}
 };
 
+#undef TYPE_RESERVED_VALUE_REG
+#undef FIELD_RESERVED_VALUE_REG
+#undef FIELD_RESERVED_BINARY_VALUE_REG
+
 static int _field_set_value(struct dm_report_field *field, const void *data, const void *sort)
 {
 	dm_report_field_set_value(field, data, sort);
diff --git a/lib/report/values.h b/lib/report/values.h
new file mode 100644
index 0000000..4566057
--- /dev/null
+++ b/lib/report/values.h
@@ -0,0 +1,74 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This file defines reserved names for field values.
+ *
+ * This is used for registering reserved names with reporting code that
+ * uses the exact value defined whenever the reserved name is hit, for
+ * example during selection criteria processing.
+ *
+ * FIELD_RESERVED_VALUE can be used for any field.
+ *
+ * FIELD_BINARY_RESERVED_VALUE is specifically designed for fields with
+ * binary values where the reserved names given denote the value 1.
+ * The first reserved_name given is also used for reporting,
+ * others are synonyms.
+ *
+ */
+
+/*
+ * FIELD_RESERVED_VALUE(field_id, reserved_value_id, reserved_name, ...)
+ * FIELD_BINARY_RESERVED_VALUE(field_id, reserved_value_id, reserved_name, ...)
+ */
+
+/* *INDENT-OFF* */
+
+/* Reserved values for PV fields */
+FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "allocatable")
+FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "exported")
+FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "missing")
+
+/* Reserved values for VG fields */
+FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "extendable")
+FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "exported")
+FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "partial")
+FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "clustered")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, _reserved_number_undef_64, "unmanaged")
+
+/* Reserved values for LV fields */
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
+FIELD_RESERVED_BINARY_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, "snapshot invalid", "invalid")
+FIELD_RESERVED_BINARY_VALUE(lv_suspended, lv_suspended, "suspended")
+FIELD_RESERVED_BINARY_VALUE(lv_live_table, lv_live_table, "live table present", "live table", "live")
+FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "inactive table present", "inactive table", "inactive")
+FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "open")
+FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "skip activation", "skip")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, _reserved_number_undef_64, "auto")
+
+/* *INDENT-ON* */


