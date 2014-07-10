From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 11:38:48 +0000 (UTC)
Subject: master - cleanup: also use values.h for final dm_report_reserved_value array composition
Message-ID: <20140710113848.43B30610BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=175de52deddbd0727c42d7a3e34d27b6f70f2deb
Commit:        175de52deddbd0727c42d7a3e34d27b6f70f2deb
Parent:        f598aa38aeee369be912153a2a577520f69e8d88
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 13:37:26 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 13:37:40 2014 +0200

cleanup: also use values.h for final dm_report_reserved_value array composition

---
 lib/report/report.c |   64 +++++++++++------------------------------------
 lib/report/values.h |   68 +++++++++++++++++++++++++-------------------------
 2 files changed, 49 insertions(+), 83 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 1d70016..63b1647 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -73,9 +73,9 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
  * All names listed are synonyms recognized in selection criteria.
  * For binary-based values we map all reserved names listed onto value 1, blank onto value 0.
  *
- * TYPE_RESERVED_VALUE(type, reserved_value_id, value, reserved name, ...)
- * FIELD_RESERVED_VALUE(field_id, reserved_value_id, value, reserved name, ...)
- * FIELD_RESERVED_BINARY_VALUE(field_id, reserved_value_id, value, reserved name for 1, ...)
+ * TYPE_RESERVED_VALUE(type, reserved_value_id, description, value, reserved name, ...)
+ * FIELD_RESERVED_VALUE(field_id, reserved_value_id, description, value, reserved name, ...)
+ * FIELD_RESERVED_BINARY_VALUE(field_id, reserved_value_id, description, reserved name for 1, ...)
  *
  * Note: FIELD_RESERVED_BINARY_VALUE creates:
  * 		- 'reserved_value_id_y' (for 1)
@@ -86,17 +86,17 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
 
 #define NUM uint64_t
 
-#define TYPE_RESERVED_VALUE(type, id, value, ...) \
+#define TYPE_RESERVED_VALUE(type, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
 	static const type _reserved_ ## id = value;
 
-#define FIELD_RESERVED_VALUE(field_id, id, value, ...) \
+#define FIELD_RESERVED_VALUE(field_id, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
 	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
 
-#define FIELD_RESERVED_BINARY_VALUE(field_id, id, ...) \
-	FIELD_RESERVED_VALUE(field_id, id ## _y, _one64, __VA_ARGS__, _str_yes) \
-	FIELD_RESERVED_VALUE(field_id, id ## _n, _zero64, __VA_ARGS__, _str_no)
+#define FIELD_RESERVED_BINARY_VALUE(field_id, id, desc, ...) \
+	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, _one64, __VA_ARGS__, _str_yes) \
+	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, _zero64, __VA_ARGS__, _str_no)
 
 #include "values.h"
 
@@ -110,54 +110,20 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
  * dm_report_init_with_selection function that initializes report with
  * selection criteria. Selection code then recognizes these reserved values
  * when parsing selection criteria.
- *
- * TYPE_RESERVED_VALUE_REG(report_type, reserved_value_id, description)
- * FIELD_RESERVED_VALUE_REG(reserved_value_id, description)
- * FIELD_RESERVED_BINARY_BALUE_REG(reserved_value_id, description)
- */
+*/
 
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 
-#define TYPE_RESERVED_VALUE_REG(type, id, description) {type, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+#define TYPE_RESERVED_VALUE(type, id, desc, value, ...) {type, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
-#define FIELD_RESERVED_VALUE_REG(id, description) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+#define FIELD_RESERVED_VALUE(field_id, id, desc, value, ...) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
-#define FIELD_RESERVED_BINARY_VALUE_REG(id, description) \
-	FIELD_RESERVED_VALUE_REG(id ## _y, description) \
-	FIELD_RESERVED_VALUE_REG(id ## _n, description)
+#define FIELD_RESERVED_BINARY_VALUE(field_id, id, desc, ...) \
+	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, _one64, __VA_ARGS__) \
+	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, _zero64, __VA_ARGS__)
 
 static const struct dm_report_reserved_value _report_reserved_values[] = {
-	TYPE_RESERVED_VALUE_REG(NUM, number_undef_64, "Reserved value for undefined numeric value.")
-	FIELD_RESERVED_BINARY_VALUE_REG(pv_allocatable, "pv_allocatable reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(pv_exported, "pv_exported reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(pv_missing, "pv_missing reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(vg_extendable, "vg_extendable reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(vg_exported, "vg_exported reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(vg_partial, "vg_partial reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(vg_clustered, "vg_clustered reserved values")
-	FIELD_RESERVED_VALUE_REG(vg_permissions_rw, "vg_permissions reserved values (writeable)")
-	FIELD_RESERVED_VALUE_REG(vg_permissions_r, "vg_permissions reserved values (read-only)")
-	FIELD_RESERVED_VALUE_REG(vg_mda_copies, "vg_mda_copies reserved values (unmanaged)")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_initial_image_sync, "lv_initial_image_sync reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_image_synced, "lv_image_synced reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_merging, "lv_merging reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_converting, "lv_converting reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_allocation_locked, "lv_allocation_locked reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_fixed_minor, "lv_fixed_minor reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_active_locally, "lv_active_locally reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_active_remotely, "lv_active_remotelly reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_active_exclusively, "lv_active_exclusively reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_merge_failed, "lv_merge_failed reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_snapshot_invalid, "lv_snapshot_invalid reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_suspended, "lv_suspended reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_live_table, "lv_live_table reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_inactive_table, "lv_inactive_table reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_device_open, "lv_device_open reserved values")
-	FIELD_RESERVED_BINARY_VALUE_REG(lv_skip_activation, "lv_inactive_table reserved values")
-	FIELD_RESERVED_VALUE_REG(lv_permissions_rw, "lv_permissions reserved values (writeable)")
-	FIELD_RESERVED_VALUE_REG(lv_permissions_r, "lv_permissions reserved values (read-only)")
-	FIELD_RESERVED_VALUE_REG(lv_permissions_r_override,  "lv_permissions reserved values (read-only-override)")
-	FIELD_RESERVED_VALUE_REG(lv_read_ahead, "lv_read_ahead reserved values (auto)")
+	#include "values.h"
 	{0, NULL, NULL}
 };
 
diff --git a/lib/report/values.h b/lib/report/values.h
index 5c4b5ab..3ee6192 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -34,50 +34,50 @@
  */
 
 /*
- * TYPE_RESERVED_VALUE(type, id, value, reserved_name, ...)
- * FIELD_RESERVED_VALUE(field_id, reserved_value_id, value, reserved_name, ...)
- * FIELD_BINARY_RESERVED_VALUE(field_id, reserved_value_id, reserved_name, ...)
+ * TYPE_RESERVED_VALUE(type, reserved_value_id, description, value, reserved_name, ...)
+ * FIELD_RESERVED_VALUE(field_id, reserved_value_id, description, value, reserved_name, ...)
+ * FIELD_BINARY_RESERVED_VALUE(field_id, reserved_value_id, description, reserved_name for 1, ...)
  */
 
 /* *INDENT-OFF* */
 
 /* Per-type reserved values usable for all fields of certain type. */
-TYPE_RESERVED_VALUE(NUM, number_undef_64, UINT64_C(-1), "-1", "unknown", "undefined", "undef");
+TYPE_RESERVED_VALUE(NUM, number_undef_64, "", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
 
 /* Reserved values for PV fields */
-FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "allocatable")
-FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "exported")
-FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "missing")
+FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "", "allocatable")
+FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "", "exported")
+FIELD_RESERVED_BINARY_VALUE(pv_missing, pv_missing, "", "missing")
 
 /* Reserved values for VG fields */
-FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "extendable")
-FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "exported")
-FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "partial")
-FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "clustered")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, RESERVED(number_undef_64), "unmanaged")
+FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "", "extendable")
+FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "", "exported")
+FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "", "partial")
+FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "", "clustered")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, "", FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, "", FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, "", RESERVED(number_undef_64), "unmanaged")
 
 /* Reserved values for LV fields */
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
-FIELD_RESERVED_BINARY_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, "snapshot invalid", "invalid")
-FIELD_RESERVED_BINARY_VALUE(lv_suspended, lv_suspended, "suspended")
-FIELD_RESERVED_BINARY_VALUE(lv_live_table, lv_live_table, "live table present", "live table", "live")
-FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "inactive table present", "inactive table", "inactive")
-FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "open")
-FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "skip activation", "skip")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, RESERVED(number_undef_64), "auto")
+FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "", "initial image sync", "sync")
+FIELD_RESERVED_BINARY_VALUE(lv_image_synced, lv_image_synced, "", "image synced", "synced")
+FIELD_RESERVED_BINARY_VALUE(lv_merging, lv_merging, "", "merging")
+FIELD_RESERVED_BINARY_VALUE(lv_converting, lv_converting, "", "converting")
+FIELD_RESERVED_BINARY_VALUE(lv_allocation_locked, lv_allocation_locked, "", "allocation locked", "locked")
+FIELD_RESERVED_BINARY_VALUE(lv_fixed_minor, lv_fixed_minor, "", "fixed minor", "fixed")
+FIELD_RESERVED_BINARY_VALUE(lv_active_locally, lv_active_locally, "", "active locally", "active", "locally")
+FIELD_RESERVED_BINARY_VALUE(lv_active_remotely, lv_active_remotely, "", "active remotely", "active", "remotely")
+FIELD_RESERVED_BINARY_VALUE(lv_active_exclusively, lv_active_exclusively, "", "active exclusively", "active", "exclusively")
+FIELD_RESERVED_BINARY_VALUE(lv_merge_failed, lv_merge_failed, "", "merge failed", "failed")
+FIELD_RESERVED_BINARY_VALUE(lv_snapshot_invalid, lv_snapshot_invalid, "", "snapshot invalid", "invalid")
+FIELD_RESERVED_BINARY_VALUE(lv_suspended, lv_suspended, "", "suspended")
+FIELD_RESERVED_BINARY_VALUE(lv_live_table, lv_live_table, "", "live table present", "live table", "live")
+FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "", "inactive table present", "inactive table", "inactive")
+FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
+FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", FIRST_NAME(lv_permissions_r), "", "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", FIRST_NAME(lv_permissions_r_override), "", "read-only-override", "ro-override", "r-override", "R")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, "", RESERVED(number_undef_64), "auto")
 
 /* *INDENT-ON* */


