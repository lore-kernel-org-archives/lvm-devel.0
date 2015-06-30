From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Jun 2015 08:50:25 +0000 (UTC)
Subject: master - select: add support for range reserved values and flagging named-only values
Message-ID: <20150630085025.4FF506124D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8996a17d1a0605cebfcf926a7a8d0e6b7fc1fcc
Commit:        d8996a17d1a0605cebfcf926a7a8d0e6b7fc1fcc
Parent:        77f0e7a450dc2bc3e42bb4854e1032873d661c58
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 30 10:13:35 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 30 10:47:50 2015 +0200

select: add support for range reserved values and flagging named-only values

This patch allows for registration and recognition of reserved
values which are ranges, so they're composed of two values actually
to denote the lower and upper bound for the range (stored as an array
with exactly two items to define the boundaries).

Also, this patch allows for flagging reserved values as named-only
which means that such values are not strictly reserved. The strictly
reserved values are reserved values as used before this patch.

Distinction between strictly-reserved and named-only values
is clearly visible with comparisons. Normally, strictly reserved
value is not accounted for if we do "greater than" or "lower than"
comparisons, for example:

1  2  3 ....
   |
  abc

- we have "abc" as reserved value for field with value "2"
- the value reported for the field is "abc" (or "2", it doesn't matter here)
- the selection we're processing is -S 'field < abc'
- the result of the selection gives nothing as "abc" is strictly
reserved value (bound to "2") and there's no order defined for
it and it would only match if we directly compared the value
(so -S 'field = abc' would match)

With named-only values, the "abc" is named-only value for "2",
so selection -S 'field < abc" is the same as using -S 'field < 2'.
The "abc" is just an alias for some value so the value or its
assigned name can be used equally in selection criteria.
---
 WHATS_NEW_DM         |    2 +
 lib/report/report.c  |   32 +++--
 lib/report/values.h  |   32 +++---
 libdm/libdevmapper.h |   29 +++--
 libdm/libdm-report.c |  348 ++++++++++++++++++++++++++++++++++++--------------
 5 files changed, 304 insertions(+), 139 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ce10238..75e572a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.100 - 
 ================================
+  Support report reserved value ranges: DM_REPORT_FIELD_RESERVED_VALUE_RANGE.
+  Support report reserved value names: DM_REPORT_FIELD_RESERVED_VALUE_NAMED.
   Add DM_CONFIG_VALUE_FMT_{INT_OCTAL,STRING_NO_QUOTES} config value format flag.
   Add DM_CONFIG_VALUE_FMT_COMMON_{ARRAY,EXTRA_SPACE} config value format flag.
   Add dm_config_value_{get,set}_format_flags to get and set config value format.
diff --git a/lib/report/report.c b/lib/report/report.c
index 30b3767..1c741e4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -96,24 +96,28 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
  * 		- 'reserved_value_id_n' (for 0)
  */
 #define NUM uint64_t
-#define SIZ double
+#define NOFLAG 0
+#define NAMED DM_REPORT_FIELD_RESERVED_VALUE_NAMED
+#define RANGE DM_REPORT_FIELD_RESERVED_VALUE_RANGE
 
-#define TYPE_RESERVED_VALUE(type, id, desc, value, ...) \
+#define TYPE_RESERVED_VALUE(type, flags, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
 	static const type _reserved_ ## id = value;
 
-#define FIELD_RESERVED_VALUE(field_id, id, desc, value, ...) \
+#define FIELD_RESERVED_VALUE(flags, field_id, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
 	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, value};
 
 #define FIELD_RESERVED_BINARY_VALUE(field_id, id, desc, ...) \
-	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, &_one64, __VA_ARGS__, _str_yes) \
-	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, &_zero64, __VA_ARGS__, _str_no)
+	FIELD_RESERVED_VALUE(NAMED, field_id, id ## _y, desc, &_one64, __VA_ARGS__, _str_yes) \
+	FIELD_RESERVED_VALUE(NAMED, field_id, id ## _n, desc, &_zero64, __VA_ARGS__, _str_no)
 
 #include "values.h"
 
 #undef NUM
-#undef SIZ
+#undef NOFLAG
+#undef NAMED
+#undef RANGE
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
@@ -126,15 +130,17 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 */
 
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define SIZ DM_REPORT_FIELD_TYPE_SIZE
+#define NOFLAG 0
+#define NAMED DM_REPORT_FIELD_RESERVED_VALUE_NAMED
+#define RANGE DM_REPORT_FIELD_RESERVED_VALUE_RANGE
 
-#define TYPE_RESERVED_VALUE(type, id, desc, value, ...) {type, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
+#define TYPE_RESERVED_VALUE(type, flags, id, desc, value, ...) {type | flags, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
-#define FIELD_RESERVED_VALUE(field_id, id, desc, value, ...) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
+#define FIELD_RESERVED_VALUE(flags, field_id, id, desc, value, ...) {DM_REPORT_FIELD_TYPE_NONE | flags, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
 #define FIELD_RESERVED_BINARY_VALUE(field_id, id, desc, ...) \
-	FIELD_RESERVED_VALUE(field_id, id ## _y, desc, &_one64, __VA_ARGS__) \
-	FIELD_RESERVED_VALUE(field_id, id ## _n, desc, &_zero64, __VA_ARGS__)
+	FIELD_RESERVED_VALUE(NAMED, field_id, id ## _y, desc, &_one64, __VA_ARGS__) \
+	FIELD_RESERVED_VALUE(NAMED, field_id, id ## _n, desc, &_zero64, __VA_ARGS__)
 
 static const struct dm_report_reserved_value _report_reserved_values[] = {
 	#include "values.h"
@@ -142,7 +148,9 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 };
 
 #undef NUM
-#undef SIZ
+#undef NOFLAG
+#undef NAMED
+#undef RANGE
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
diff --git a/lib/report/values.h b/lib/report/values.h
index dd20caf..742cb50 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -38,15 +38,15 @@
  */
 
 /*
- * TYPE_RESERVED_VALUE(type, reserved_value_id, description, value, reserved_name, ...)
- * FIELD_RESERVED_VALUE(field_id, reserved_value_id, description, value, reserved_name, ...)
+ * TYPE_RESERVED_VALUE(type, flags, reserved_value_id, description, value, reserved_name, ...)
+ * FIELD_RESERVED_VALUE(field_id, flags, reserved_value_id, description, value, reserved_name, ...)
  * FIELD_BINARY_RESERVED_VALUE(field_id, reserved_value_id, description, reserved_name for 1, ...)
  */
 
 /* *INDENT-OFF* */
 
 /* Per-type reserved values usable for all fields of certain type. */
-TYPE_RESERVED_VALUE(NUM, num_undef_64, "Reserved value for undefined numeric value.", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
+TYPE_RESERVED_VALUE(NUM, NOFLAG, num_undef_64, "Reserved value for undefined numeric value.", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
 
 /* Reserved values for PV fields */
 FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "", "allocatable")
@@ -58,9 +58,9 @@ FIELD_RESERVED_BINARY_VALUE(vg_extendable, vg_extendable, "", "extendable")
 FIELD_RESERVED_BINARY_VALUE(vg_exported, vg_exported, "", "exported")
 FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "", "partial")
 FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "", "clustered")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, "", "read-only", "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies_unmanaged, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "unmanaged")
+FIELD_RESERVED_VALUE(NAMED, vg_permissions, vg_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(NAMED, vg_permissions, vg_permissions_r, "", "read-only", "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(NOFLAG, vg_mda_copies, vg_mda_copies_unmanaged, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "unmanaged")
 
 /* Reserved values for LV fields */
 FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "", "initial image sync", "sync")
@@ -80,18 +80,18 @@ FIELD_RESERVED_BINARY_VALUE(lv_inactive_table, lv_inactive_table, "", "inactive
 FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
 FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
 FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &_siz_max, "auto")
-FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_error, "", "error", "error", "error when full", "error if no space")
-FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
-FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
+FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
+FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
+FIELD_RESERVED_VALUE(NOFLAG, lv_read_ahead, lv_read_ahead_auto, "", &_siz_max, "auto")
+FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_error, "", "error", "error", "error when full", "error if no space")
+FIELD_RESERVED_VALUE(NAMED, lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
+FIELD_RESERVED_VALUE(NOFLAG, lv_when_full, lv_when_full_undef, "", "", "", "undefined")
 
 /* Reserved values for SEG fields */
-FIELD_RESERVED_VALUE(cache_policy, cache_policy_undef, "", "", "", "undefined")
-FIELD_RESERVED_VALUE(seg_monitor, seg_monitor_undef, "", "", "", "undefined")
-FIELD_RESERVED_VALUE(lv_health_status, health_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NOFLAG, cache_policy, cache_policy_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NOFLAG, seg_monitor, seg_monitor_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NOFLAG, lv_health_status, health_undef, "", "", "", "undefined")
 /* TODO the following 2 need STR_LIST support for reserved values
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined") */
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 7476aef..38f42aa 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1671,17 +1671,22 @@ struct dm_report_field;
 /*
  * dm_report_field_type flags
  */
-#define DM_REPORT_FIELD_MASK			0x00000FFF
-#define DM_REPORT_FIELD_ALIGN_MASK		0x0000000F
-#define DM_REPORT_FIELD_ALIGN_LEFT		0x00000001
-#define DM_REPORT_FIELD_ALIGN_RIGHT		0x00000002
-#define DM_REPORT_FIELD_TYPE_MASK		0x00000FF0
-#define DM_REPORT_FIELD_TYPE_NONE		0x00000000
-#define DM_REPORT_FIELD_TYPE_STRING		0x00000010
-#define DM_REPORT_FIELD_TYPE_NUMBER		0x00000020
-#define DM_REPORT_FIELD_TYPE_SIZE		0x00000040
-#define DM_REPORT_FIELD_TYPE_PERCENT		0x00000080
-#define DM_REPORT_FIELD_TYPE_STRING_LIST	0x00000100
+#define DM_REPORT_FIELD_MASK				0x00000FFF
+#define DM_REPORT_FIELD_ALIGN_MASK			0x0000000F
+#define DM_REPORT_FIELD_ALIGN_LEFT			0x00000001
+#define DM_REPORT_FIELD_ALIGN_RIGHT			0x00000002
+#define DM_REPORT_FIELD_TYPE_MASK			0x00000FF0
+#define DM_REPORT_FIELD_TYPE_NONE			0x00000000
+#define DM_REPORT_FIELD_TYPE_STRING			0x00000010
+#define DM_REPORT_FIELD_TYPE_NUMBER			0x00000020
+#define DM_REPORT_FIELD_TYPE_SIZE			0x00000040
+#define DM_REPORT_FIELD_TYPE_PERCENT			0x00000080
+#define DM_REPORT_FIELD_TYPE_STRING_LIST		0x00000100
+
+/* For use with reserved values only! */
+#define DM_REPORT_FIELD_RESERVED_VALUE_MASK		0x0000000F
+#define DM_REPORT_FIELD_RESERVED_VALUE_NAMED		0x00000001 /* only named value, less strict form of reservation */
+#define DM_REPORT_FIELD_RESERVED_VALUE_RANGE		0x00000002 /* value is range - low and high value defined */
 
 #define DM_REPORT_FIELD_TYPE_ID_LEN 32
 #define DM_REPORT_FIELD_TYPE_HEADING_LEN 32
@@ -1728,7 +1733,7 @@ struct dm_report_field_reserved_value {
  * selection enabled (see also dm_report_init_with_selection function).
  */
 struct dm_report_reserved_value {
-	const unsigned type;		/* DM_REPORT_FIELD_TYPE_* */
+	const uint32_t type;		/* DM_REPORT_FIELD_RESERVED_VALUE_* and DM_REPORT_FIELD_TYPE_*  */
 	const void *value;		/* reserved value:
 						struct dm_report_field_reserved_value for DM_REPORT_FIELD_TYPE_NONE
 						uint64_t for DM_REPORT_FIELD_TYPE_NUMBER
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index def72fe..401e87a 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -162,9 +162,7 @@ struct selection_str_list {
 	struct dm_list *list;
 };
 
-struct field_selection {
-	struct field_properties *fp;
-	uint32_t flags;
+struct field_selection_value {
 	union {
 		const char *s;
 		uint64_t i;
@@ -172,6 +170,13 @@ struct field_selection {
 		struct dm_regex *r;
 		struct selection_str_list *l;
 	} v;
+	struct field_selection_value *next;
+};
+
+struct field_selection {
+	struct field_properties *fp;
+	uint32_t flags;
+	struct field_selection_value *value;
 };
 
 struct selection_node {
@@ -1257,30 +1262,98 @@ static void *_report_get_implicit_field_data(struct dm_report *rh __attribute__(
 	return NULL;
 }
 
-static int _close_enough(double d1, double d2)
+static int _dbl_equal(double d1, double d2)
 {
 	return fabs(d1 - d2) < DBL_EPSILON;
 }
 
-static int _do_check_value_is_reserved(unsigned type, const void *reserved_value,
-				       const void *value1, const void *value2)
+static int _dbl_greater(double d1, double d2)
+{
+	return (d1 > d2) && !_dbl_equal(d1, d2);
+}
+
+static int _dbl_less(double d1, double d2)
+{
+	return (d1 < d2) && !_dbl_equal(d1, d2);
+}
+
+static int _dbl_greater_or_equal(double d1, double d2)
+{
+	return _dbl_greater(d1, d2) || _dbl_equal(d1, d2);
+}
+
+static int _dbl_less_or_equal(double d1, double d2)
 {
-	switch (type) {
+	return _dbl_less(d1, d2) || _dbl_equal(d1, d2);
+}
+
+#define _uint64 *(uint64_t *)
+#define _uint64arr(var,index) ((uint64_t *)var)[index]
+#define _str (const char *)
+#define _dbl *(double *)
+#define _dblarr(var,index) ((double *)var)[index]
+
+static int _do_check_value_is_strictly_reserved(unsigned type, const void *res_val, int res_range,
+						const void *val, struct field_selection *fs)
+{
+	int sel_range = fs ? fs->value->next != NULL : 0;
+
+	switch (type & DM_REPORT_FIELD_TYPE_MASK) {
 		case DM_REPORT_FIELD_TYPE_NUMBER:
-			if ((*(uint64_t *)value1 == *(uint64_t *) reserved_value) ||
-			    (value2 && (*(uint64_t *)value2 == *(uint64_t *) reserved_value)))
-				return 1;
+			if (res_range && sel_range) {
+				/* both reserved value and selection value are ranges */
+				if (((_uint64 val >= _uint64arr(res_val,0)) && (_uint64 val <= _uint64arr(res_val,1))) ||
+				    (fs && ((fs->value->v.i == _uint64arr(res_val,0)) && (fs->value->next->v.i == _uint64arr(res_val,1)))))
+					return 1;
+			} else if (res_range) {
+				/* only reserved value is a range */
+				if (((_uint64 val >= _uint64arr(res_val,0)) && (_uint64 val <= _uint64arr(res_val,1))) ||
+				    (fs && ((fs->value->v.i >= _uint64arr(res_val,0)) && (fs->value->v.i <= _uint64arr(res_val,1)))))
+					return 1;
+			} else if (sel_range) {
+				/* only selection value is a range */
+				if (((_uint64 val >= _uint64 res_val) && (_uint64 val <= _uint64 res_val)) ||
+				    (fs && ((fs->value->v.i >= _uint64 res_val) && (fs->value->next->v.i <= _uint64 res_val))))
+					return 1;
+			} else {
+				/* neither selection value nor reserved value is a range */
+				if ((_uint64 val == _uint64 res_val) ||
+				    (fs && (fs->value->v.i == _uint64 res_val)))
+					return 1;
+			}
 			break;
+
 		case DM_REPORT_FIELD_TYPE_STRING:
-			if ((!strcmp((const char *)value1, (const char *) reserved_value)) ||
-			    (value2 && (!strcmp((const char *)value2, (const char *) reserved_value))))
+			/* there are no ranges for string type yet */
+			if ((!strcmp(_str val, _str res_val)) ||
+			    (fs && (!strcmp(fs->value->v.s, _str res_val))))
 				return 1;
 			break;
+
 		case DM_REPORT_FIELD_TYPE_SIZE:
-			if ((_close_enough(*(double *)value1, *(double *) reserved_value)) ||
-			    (value2 && (_close_enough(*(double *)value2, *(double *) reserved_value))))
-				return 1;
+			if (res_range && sel_range) {
+				/* both reserved value and selection value are ranges */
+				if ((_dbl_greater_or_equal(_dbl val, _dblarr(res_val,0)) && _dbl_less_or_equal(_dbl val, _dblarr(res_val,1))) ||
+				    (fs && (_dbl_equal(fs->value->v.d, _dblarr(res_val,0)) && (_dbl_equal(fs->value->next->v.d, _dblarr(res_val,1))))))
+					return 1;
+			} else if (res_range) {
+				/* only reserved value is a range */
+				if ((_dbl_greater_or_equal(_dbl val, _dblarr(res_val,0)) && _dbl_less_or_equal(_dbl val, _dblarr(res_val,1))) ||
+				    (fs && (_dbl_greater_or_equal(fs->value->v.d, _dblarr(res_val,0)) && _dbl_less_or_equal(fs->value->v.d, _dblarr(res_val,1)))))
+					return 1;
+			} else if (sel_range) {
+				/* only selection value is a range */
+				if ((_dbl_greater_or_equal(_dbl val, _dbl res_val) && (_dbl_less_or_equal(_dbl val, _dbl res_val))) ||
+				    (fs && (_dbl_greater_or_equal(fs->value->v.d, _dbl res_val) && _dbl_less_or_equal(fs->value->next->v.d, _dbl res_val))))
+					return 1;
+			} else {
+				/* neither selection value nor reserved value is a range */
+				if ((_dbl_equal(_dbl val, _dbl res_val)) ||
+				    (fs && (_dbl_equal(fs->value->v.d, _dbl res_val))))
+					return 1;
+			}
 			break;
+
 		case DM_REPORT_FIELD_TYPE_STRING_LIST:
 			/* FIXME Add comparison for string list */
 			break;
@@ -1292,22 +1365,27 @@ static int _do_check_value_is_reserved(unsigned type, const void *reserved_value
 /*
  * Used to check whether a value of certain type used in selection is reserved.
  */
-static int _check_value_is_reserved(struct dm_report *rh, uint32_t field_num, unsigned type,
-				    const void *value1, const void *value2)
+static int _check_value_is_strictly_reserved(struct dm_report *rh, uint32_t field_num, unsigned type,
+					     const void *val, struct field_selection *fs)
 {
 	const struct dm_report_reserved_value *iter = rh->reserved_values;
 	const struct dm_report_field_reserved_value *frv;
+	int res_range;
 
 	if (!iter)
 		return 0;
 
 	while (iter->value) {
-		if (iter->type == DM_REPORT_FIELD_TYPE_NONE) {
-			frv = (const struct dm_report_field_reserved_value *) iter->value;
-			if (frv->field_num == field_num && _do_check_value_is_reserved(type, frv->value, value1, value2))
+		/* Only check strict reserved values, not the weaker form ("named" reserved value). */
+		if (!(iter->type & DM_REPORT_FIELD_RESERVED_VALUE_NAMED)) {
+			res_range = iter->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE;
+			if ((iter->type & DM_REPORT_FIELD_TYPE_MASK) == DM_REPORT_FIELD_TYPE_NONE) {
+				frv = (const struct dm_report_field_reserved_value *) iter->value;
+				if (frv->field_num == field_num && _do_check_value_is_strictly_reserved(type, frv->value, res_range, val, fs))
+					return 1;
+			} else if (iter->type & type && _do_check_value_is_strictly_reserved(type, iter->value, res_range, val, fs))
 				return 1;
-		} else if (iter->type & type && _do_check_value_is_reserved(type, iter->value, value1, value2))
-			return 1;
+		}
 		iter++;
 	}
 
@@ -1315,21 +1393,39 @@ static int _check_value_is_reserved(struct dm_report *rh, uint32_t field_num, un
 }
 
 static int _cmp_field_int(struct dm_report *rh, uint32_t field_num, const char *field_id,
-			  uint64_t a, uint64_t b, uint32_t flags)
+			  uint64_t val, struct field_selection *fs)
 {
-	switch(flags & FLD_CMP_MASK) {
+	int range = fs->value->next != NULL;
+	const uint64_t sel1 = fs->value->v.i;
+	const uint64_t sel2 = range ? fs->value->next->v.i : 0;
+
+	switch(fs->flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
-			return a == b;
+			return range ? ((val >= sel1) && (val <= sel2)) : val == sel1;
+
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
-			return a != b;
+			return range ? !((val >= sel1) && (val <= sel2)) : val != sel1;
+
 		case FLD_CMP_NUMBER|FLD_CMP_GT:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a > b;
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &val, fs))
+				return 0;
+			return range ? val > sel2 : val > sel1;
+
 		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a >= b;
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &val, fs))
+				return 0;
+			return val >= sel1;
+
 		case FLD_CMP_NUMBER|FLD_CMP_LT:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a < b;
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &val, fs))
+				return 0;
+			return val < sel1;
+
 		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a <= b;
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &val, fs))
+				return 0;
+			return range ? val <= sel2 : val <= sel1;
+
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_int: unsupported number "
 				  "comparison type for field %s", field_id);
@@ -1339,21 +1435,42 @@ static int _cmp_field_int(struct dm_report *rh, uint32_t field_num, const char *
 }
 
 static int _cmp_field_double(struct dm_report *rh, uint32_t field_num, const char *field_id,
-			     double a, double b, uint32_t flags)
+			     double val, struct field_selection *fs)
 {
-	switch(flags & FLD_CMP_MASK) {
+	int range = fs->value->next != NULL;
+	double sel1 = fs->value->v.d;
+	double sel2 = range ? fs->value->next->v.d : 0;
+
+	switch(fs->flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
-			return _close_enough(a, b);
+			return range ? (_dbl_greater_or_equal(val, sel1) && _dbl_less_or_equal(val, sel2))
+				     : _dbl_equal(val, sel1);
+
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
-			return !_close_enough(a, b);
+			return range ? !(_dbl_greater_or_equal(val, sel1) && _dbl_less_or_equal(val, sel2))
+				     : !_dbl_equal(val, sel1);
+
 		case FLD_CMP_NUMBER|FLD_CMP_GT:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : (a > b) && !_close_enough(a, b);
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &val, fs))
+				return 0;
+			return range ? _dbl_greater(val, sel2)
+				     : _dbl_greater(val, sel1);
+
 		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : (a > b) || _close_enough(a, b);
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &val, fs))
+				return 0;
+			return _dbl_greater_or_equal(val, sel1);
+
 		case FLD_CMP_NUMBER|FLD_CMP_LT:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : (a < b) && !_close_enough(a, b);
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &val, fs))
+				return 0;
+			return _dbl_less(val, sel1);
+
 		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : a < b || _close_enough(a, b);
+			if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &val, fs))
+				return 0;
+			return range ? _dbl_less_or_equal(val, sel2) : _dbl_less_or_equal(val, sel1); 
+
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_double: unsupported number "
 				  "comparison type for selection field %s", field_id);
@@ -1364,13 +1481,15 @@ static int _cmp_field_double(struct dm_report *rh, uint32_t field_num, const cha
 
 static int _cmp_field_string(struct dm_report *rh __attribute__((unused)),
 			     uint32_t field_num, const char *field_id,
-			     const char *a, const char *b, uint32_t flags)
+			     const char *val, struct field_selection *fs)
 {
-	switch (flags & FLD_CMP_MASK) {
+	const char *sel = fs->value->v.s;
+
+	switch (fs->flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
-			return !strcmp(a, b);
+			return _check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, val, fs) ? 0 : !strcmp(val, sel);
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
-			return strcmp(a, b);
+			return _check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, val, fs) ? 0 : strcmp(val, sel);
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_string: unsupported string "
 				  "comparison type for selection field %s", field_id);
@@ -1458,12 +1577,13 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 
 static int _cmp_field_string_list(struct dm_report *rh __attribute__((unused)),
 				  uint32_t field_num, const char *field_id,
-				  const struct str_list_sort_value *value,
-				  const struct selection_str_list *selection, uint32_t flags)
+				  const struct str_list_sort_value *val,
+				  struct field_selection *fs)
 {
+	const struct selection_str_list *sel = fs->value->v.l;
 	int subset, r;
 
-	switch (selection->type & SEL_LIST_MASK) {
+	switch (sel->type & SEL_LIST_MASK) {
 		case SEL_LIST_LS:
 			subset = 0;
 			break;
@@ -1475,13 +1595,13 @@ static int _cmp_field_string_list(struct dm_report *rh __attribute__((unused)),
 			return 0;
 	}
 
-	switch (selection->type & SEL_MASK) {
+	switch (sel->type & SEL_MASK) {
 		case SEL_AND:
-			r = subset ? _cmp_field_string_list_subset_all(value, selection)
-				   : _cmp_field_string_list_strict_all(value, selection);
+			r = subset ? _cmp_field_string_list_subset_all(val, sel)
+				   : _cmp_field_string_list_strict_all(val, sel);
 			break;
 		case SEL_OR:
-			r = _cmp_field_string_list_any(value, selection);
+			r = _cmp_field_string_list_any(val, sel);
 			break;
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_string_list: unsupported string "
@@ -1490,13 +1610,13 @@ static int _cmp_field_string_list(struct dm_report *rh __attribute__((unused)),
 			return 0;
 	}
 
-	return flags & FLD_CMP_NOT ? !r : r;
+	return fs->flags & FLD_CMP_NOT ? !r : r;
 }
 
-static int _cmp_field_regex(const char *s, struct dm_regex *r, uint32_t flags)
+static int _cmp_field_regex(const char *s, struct field_selection *fs)
 {
-	int match = dm_regex_match(r, s) >= 0;
-	return flags & FLD_CMP_NOT ? !match : match;
+	int match = dm_regex_match(fs->value->v.r, s) >= 0;
+	return fs->flags & FLD_CMP_NOT ? !match : match;
 }
 
 static int _compare_selection_field(struct dm_report *rh,
@@ -1515,7 +1635,7 @@ static int _compare_selection_field(struct dm_report *rh,
 	}
 
 	if (fs->flags & FLD_CMP_REGEX)
-		r = _cmp_field_regex((const char *) f->sort_value, fs->v.r, fs->flags);
+		r = _cmp_field_regex((const char *) f->sort_value, fs);
 	else {
 		switch(f->props->flags & DM_REPORT_FIELD_TYPE_MASK) {
 			case DM_REPORT_FIELD_TYPE_PERCENT:
@@ -1527,17 +1647,16 @@ static int _compare_selection_field(struct dm_report *rh,
 					return 0;
 				/* fall through */
 			case DM_REPORT_FIELD_TYPE_NUMBER:
-				r = _cmp_field_int(rh, f->props->field_num, field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
+				r = _cmp_field_int(rh, f->props->field_num, field_id, *(const uint64_t *) f->sort_value, fs);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				r = _cmp_field_double(rh, f->props->field_num, field_id, *(double *) f->sort_value, fs->v.d, fs->flags);
+				r = _cmp_field_double(rh, f->props->field_num, field_id, *(double *) f->sort_value, fs);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING:
-				r = _cmp_field_string(rh, f->props->field_num, field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
+				r = _cmp_field_string(rh, f->props->field_num, field_id, (const char *) f->sort_value, fs);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
-				r = _cmp_field_string_list(rh, f->props->field_num, field_id, (const struct str_list_sort_value *) f->sort_value,
-							   fs->v.l, fs->flags);
+				r = _cmp_field_string_list(rh, f->props->field_num, field_id, (const struct str_list_sort_value *) f->sort_value, fs);
 				break;
 			default:
 				log_error(INTERNAL_ERROR "_compare_selection_field: unknown field type for field %s", field_id);
@@ -1978,7 +2097,7 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 		return s;
 
 	while (iter->value) {
-		if (!iter->type) {
+		if (!(iter->type & DM_REPORT_FIELD_TYPE_MASK)) {
 			/* DM_REPORT_FIELD_TYPE_NONE - per-field reserved value */
 			if (((((const struct dm_report_field_reserved_value *) iter->value)->field_num) == field_num) &&
 			    (name = _reserved_name(iter->names, tmp_begin, tmp_end - tmp_begin)))
@@ -2041,6 +2160,11 @@ static int _check_reserved_values_supported(const struct dm_report_field_type fi
 						   DM_REPORT_FIELD_TYPE_SIZE |
 						   DM_REPORT_FIELD_TYPE_PERCENT |
 						   DM_REPORT_FIELD_TYPE_STRING;
+	static uint32_t supported_reserved_types_with_range = DM_REPORT_FIELD_RESERVED_VALUE_RANGE |
+							      DM_REPORT_FIELD_TYPE_NUMBER |
+							      DM_REPORT_FIELD_TYPE_SIZE |
+							      DM_REPORT_FIELD_TYPE_PERCENT;
+
 
 	if (!reserved_values)
 		return 1;
@@ -2048,8 +2172,10 @@ static int _check_reserved_values_supported(const struct dm_report_field_type fi
 	iter = reserved_values;
 
 	while (iter->value) {
-		if (iter->type) {
-			if (!(iter->type & supported_reserved_types)) {
+		if (iter->type & DM_REPORT_FIELD_TYPE_MASK) {
+			if (!(iter->type & supported_reserved_types) ||
+			    ((iter->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE) &&
+			     !(iter->type & supported_reserved_types_with_range))) {
 				log_error(INTERNAL_ERROR "_check_reserved_values_supported: "
 					  "global reserved value for type 0x%x not supported",
 					   iter->type);
@@ -2058,7 +2184,9 @@ static int _check_reserved_values_supported(const struct dm_report_field_type fi
 		} else {
 			field_res = (const struct dm_report_field_reserved_value *) iter->value;
 			field = &fields[field_res->field_num];
-			if (!(field->flags & supported_reserved_types)) {
+			if (!(field->flags & supported_reserved_types) ||
+			    ((iter->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE) &&
+			     !(iter->type & supported_reserved_types_with_range))) {
 				log_error(INTERNAL_ERROR "_check_reserved_values_supported: "
 					  "field-specific reserved value of type 0x%x for "
 					  "field %s not supported",
@@ -2427,7 +2555,7 @@ static const char *_tok_field_name(const char *s,
 
 static const void *_get_reserved_value(const struct dm_report_reserved_value *reserved)
 {
-	if (reserved->type)
+	if (reserved->type & DM_REPORT_FIELD_TYPE_MASK)
 		return reserved->value;
 	else
 		return ((const struct dm_report_field_reserved_value *) reserved->value)->value;
@@ -2443,10 +2571,12 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       void *custom)
 {
 	static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
+	static const char *_field_selection_value_alloc_failed_msg = "dm_report: struct field_selection_value allocation failed for selection field %s";
 	const struct dm_report_field_type *fields = implicit ? _implicit_report_fields
 							     : rh->fields;
 	struct field_properties *fp, *found = NULL;
 	struct field_selection *fs;
+	const void *reserved_value;
 	const char *field_id;
 	uint64_t factor;
 	char *s;
@@ -2479,9 +2609,23 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 			  "allocation failed for selection field %s", field_id);
 		return NULL;
 	}
+
+	if (!(fs->value = dm_pool_zalloc(rh->selection->mem, sizeof(struct field_selection_value)))) {
+		log_error(_field_selection_value_alloc_failed_msg, field_id);
+		goto error;
+	}
+
+	if (reserved && (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE) &&
+	    !(fs->value->next = dm_pool_zalloc(rh->selection->mem, sizeof(struct field_selection_value)))) {
+		log_error(_field_selection_value_alloc_failed_msg, field_id);
+		goto error;
+	}
+
 	fs->fp = found;
 	fs->flags = flags;
 
+	reserved_value = reserved ? _get_reserved_value(reserved) : NULL;
+
 	/* store comparison operand */
 	if (flags & FLD_CMP_REGEX) {
 		/* REGEX */
@@ -2493,92 +2637,98 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		memcpy(s, v, len);
 		s[len] = '\0';
 
-		fs->v.r = dm_regex_create(rh->selection->mem, (const char **) &s, 1);
+		fs->value->v.r = dm_regex_create(rh->selection->mem, (const char **) &s, 1);
 		dm_free(s);
-		if (!fs->v.r) {
+		if (!fs->value->v.r) {
 			log_error("dm_report: failed to create regex "
 				  "matcher for selection field %s", field_id);
 			goto error;
 		}
 	} else {
 		/* STRING, NUMBER, SIZE or STRING_LIST */
-		if (!(s = dm_pool_alloc(rh->selection->mem, len + 1))) {
-			log_error("dm_report: dm_pool_alloc failed to store "
-				  "value for selection field %s", field_id);
+		if (!(s = dm_pool_strndup(rh->selection->mem, v, len))) {
+			log_error("dm_report: dm_pool_strndup for value "
+				  "of selection field %s", field_id);
 			goto error;
 		}
-		memcpy(s, v, len);
-		s[len] = '\0';
 
 		switch (flags & DM_REPORT_FIELD_TYPE_MASK) {
 			case DM_REPORT_FIELD_TYPE_STRING:
-				if (reserved) {
-					fs->v.s = (const char *) _get_reserved_value(reserved);
+				if (reserved_value) {
+					fs->value->v.s = (const char *) reserved_value;
+					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.s = (((const char **) reserved_value)[1]);
 					dm_pool_free(rh->selection->mem, s);
 				} else {
-					fs->v.s = s;
-					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, fs->v.s, NULL)) {
-						log_error("String value %s found in selection is reserved.", fs->v.s);
+					fs->value->v.s = s;
+					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, fs->value->v.s, NULL)) {
+						log_error("String value %s found in selection is reserved.", fs->value->v.s);
 						goto error;
 					}
 				}
 				break;
 			case DM_REPORT_FIELD_TYPE_NUMBER:
-				if (reserved)
-					fs->v.i = *(uint64_t *) _get_reserved_value(reserved);
-				else {
-					if (((fs->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
+				if (reserved_value) {
+					fs->value->v.i = *(uint64_t *) reserved_value;
+					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.i = (((uint64_t *) reserved_value)[1]);
+				} else {
+					if (((fs->value->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
 						 (errno == ERANGE)) {
 						log_error(_out_of_range_msg, s, field_id);
 						goto error;
 					}
-					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &fs->v.i, NULL)) {
-						log_error("Numeric value %" PRIu64 " found in selection is reserved.", fs->v.i);
+					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &fs->value->v.i, NULL)) {
+						log_error("Numeric value %" PRIu64 " found in selection is reserved.", fs->value->v.i);
 						goto error;
 					}
 				}
 				dm_pool_free(rh->selection->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				if (reserved)
-					fs->v.d = *(double *) _get_reserved_value(reserved);
-				else {
-					fs->v.d = strtod(s, NULL);
+				if (reserved_value) {
+					fs->value->v.d = *(double *) reserved_value;
+					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.d = (((double *) reserved_value)[1]);
+				} else {
+					fs->value->v.d = strtod(s, NULL);
 					if (errno == ERANGE) {
 						log_error(_out_of_range_msg, s, field_id);
 						goto error;
 					}
 					if (custom && (factor = *((uint64_t *)custom)))
-						fs->v.d *= factor;
-					fs->v.d /= 512; /* store size in sectors! */
-					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &fs->v.d, NULL)) {
-						log_error("Size value %f found in selection is reserved.", fs->v.d);
+						fs->value->v.d *= factor;
+					fs->value->v.d /= 512; /* store size in sectors! */
+					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &fs->value->v.d, NULL)) {
+						log_error("Size value %f found in selection is reserved.", fs->value->v.d);
 						goto error;
 					}
 				}
 				dm_pool_free(rh->selection->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_PERCENT:
-				if (reserved)
-					fs->v.i = *(uint64_t *) _get_reserved_value(reserved);
-				else {
-					fs->v.d = strtod(s, NULL);
-					if ((errno == ERANGE) || (fs->v.d < 0) || (fs->v.d > 100)) {
+				if (reserved_value) {
+					fs->value->v.i = *(uint64_t *) reserved_value;
+					if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
+						fs->value->next->v.i = (((uint64_t *) reserved_value)[1]);
+				} else {
+					fs->value->v.d = strtod(s, NULL);
+					if ((errno == ERANGE) || (fs->value->v.d < 0) || (fs->value->v.d > 100)) {
 						log_error(_out_of_range_msg, s, field_id);
 						goto error;
 					}
 
-					fs->v.i = (dm_percent_t) (DM_PERCENT_1 * fs->v.d);
+					fs->value->v.i = (dm_percent_t) (DM_PERCENT_1 * fs->value->v.d);
 
-					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_PERCENT, &fs->v.i, NULL)) {
+					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_PERCENT, &fs->value->v.i, NULL)) {
 						log_error("Percent value %s found in selection is reserved.", s);
 						goto error;
 					}
 				}
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
-				fs->v.l = *(struct selection_str_list **)custom;
-				if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->v.l, NULL)) {
+				fs->value->v.l = *(struct selection_str_list **)custom;
+				if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->value->v.l, NULL)) {
 					log_error("String list value found in selection is reserved.");
 					goto error;
 				}


