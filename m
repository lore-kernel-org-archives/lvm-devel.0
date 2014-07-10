From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 09:54:46 +0000 (UTC)
Subject: master - cleanup: report reserved value macros
Message-ID: <20140710095447.0024361229@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f598aa38aeee369be912153a2a577520f69e8d88
Commit:        f598aa38aeee369be912153a2a577520f69e8d88
Parent:        fafd10d564151b91e814f6be3e735bdf0b7d33dd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 11:54:37 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 11:54:37 2014 +0200

cleanup: report reserved value macros

---
 lib/report/report.c |   57 ++++++++++++++++++++++++++++++--------------------
 lib/report/values.h |   23 ++++++++++++++------
 2 files changed, 50 insertions(+), 30 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index d3dbefc..1d70016 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -58,7 +58,6 @@ static const char const _str_zero[] = "0";
 static const char const _str_one[] = "1";
 static const char const _str_no[] = "no";
 static const char const _str_yes[] = "yes";
-static const char const _str_minus_one[] = "-1";
 static const char const _str_unknown[] = "unknown";
 
 /*
@@ -82,20 +81,26 @@ static const int32_t _reserved_number_undef_32 = INT32_C(-1);
  * 		- 'reserved_value_id_y' (for 1)
  * 		- 'reserved_value_id_n' (for 0)
  */
+#define RESERVED(id) _reserved_ ## id
 #define FIRST_NAME(id) _reserved_ ## id ## _names[0]
+
+#define NUM uint64_t
+
 #define TYPE_RESERVED_VALUE(type, id, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
 	static const type _reserved_ ## id = value;
+
 #define FIELD_RESERVED_VALUE(field_id, id, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__ , NULL}; \
 	static const struct dm_report_field_reserved_value _reserved_ ## id = {field_ ## field_id, &value};
+
 #define FIELD_RESERVED_BINARY_VALUE(field_id, id, ...) \
 	FIELD_RESERVED_VALUE(field_id, id ## _y, _one64, __VA_ARGS__, _str_yes) \
 	FIELD_RESERVED_VALUE(field_id, id ## _n, _zero64, __VA_ARGS__, _str_no)
 
-TYPE_RESERVED_VALUE(uint64_t, number_undef_64, UINT64_C(-1), _str_minus_one, _str_unknown, "undefined", "undef");
 #include "values.h"
 
+#undef NUM
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
@@ -110,14 +115,19 @@ TYPE_RESERVED_VALUE(uint64_t, number_undef_64, UINT64_C(-1), _str_minus_one, _st
  * FIELD_RESERVED_VALUE_REG(reserved_value_id, description)
  * FIELD_RESERVED_BINARY_BALUE_REG(reserved_value_id, description)
  */
-#define TYPE_RESERVED_VALUE_REG(type, id, description) {DM_REPORT_FIELD_TYPE_ ## type, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+
+#define NUM DM_REPORT_FIELD_TYPE_NUMBER
+
+#define TYPE_RESERVED_VALUE_REG(type, id, description) {type, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+
 #define FIELD_RESERVED_VALUE_REG(id, description) {DM_REPORT_FIELD_TYPE_NONE, &_reserved_ ## id, _reserved_ ## id ## _names, description},
+
 #define FIELD_RESERVED_BINARY_VALUE_REG(id, description) \
 	FIELD_RESERVED_VALUE_REG(id ## _y, description) \
 	FIELD_RESERVED_VALUE_REG(id ## _n, description)
 
 static const struct dm_report_reserved_value _report_reserved_values[] = {
-	TYPE_RESERVED_VALUE_REG(NUMBER, number_undef_64, "Reserved value for undefined numeric value.")
+	TYPE_RESERVED_VALUE_REG(NUM, number_undef_64, "Reserved value for undefined numeric value.")
 	FIELD_RESERVED_BINARY_VALUE_REG(pv_allocatable, "pv_allocatable reserved values")
 	FIELD_RESERVED_BINARY_VALUE_REG(pv_exported, "pv_exported reserved values")
 	FIELD_RESERVED_BINARY_VALUE_REG(pv_missing, "pv_missing reserved values")
@@ -151,6 +161,7 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 	{0, NULL, NULL}
 };
 
+#undef NUM
 #undef TYPE_RESERVED_VALUE_REG
 #undef FIELD_RESERVED_VALUE_REG
 #undef FIELD_RESERVED_BINARY_VALUE_REG
@@ -190,9 +201,9 @@ static int _binary_undef_disp(struct dm_report *rh, struct dm_pool *mem __attrib
 	const struct cmd_context *cmd = (const struct cmd_context *) private;
 
 	if (cmd->report_binary_values_as_numeric)
-		return _field_set_value(field, FIRST_NAME(number_undef_64), &_reserved_number_undef_64);
+		return _field_set_value(field, FIRST_NAME(number_undef_64), &RESERVED(number_undef_64));
 	else
-		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+		return _field_set_value(field, _str_unknown, &RESERVED(number_undef_64));
 }
 
 static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -317,7 +328,7 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (lvi->info && lvi->info->exists && lvi->info->major >= 0)
 		return dm_report_field_int(rh, field, &lvi->info->major);
 
-	return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
+	return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -329,7 +340,7 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	if (lvi->info && lvi->info->exists && lvi->info->minor >= 0)
 		return dm_report_field_int(rh, field, &lvi->info->minor);
 
-	return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
+	return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
@@ -654,7 +665,7 @@ static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
-		return _field_set_value(field, "auto", &_reserved_number_undef_64);
+		return _field_set_value(field, "auto", &RESERVED(number_undef_64));
 
 	return _size32_disp(rh, mem, field, &lv->read_ahead, private);
 }
@@ -667,7 +678,7 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_with_info *lvi = (const struct lv_with_info *) data;
 
 	if (!lvi->info || !lvi->info->exists)
-		return dm_report_field_int32(rh, field, &_reserved_number_undef_32);
+		return dm_report_field_int32(rh, field, &RESERVED(number_undef_32));
 
 	return _size32_disp(rh, mem, field, &lvi->info->read_ahead, private);
 }
@@ -755,7 +766,7 @@ static int _transactionid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_pool(seg))
 		return dm_report_field_uint64(rh, field, &seg->transaction_id);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -767,7 +778,7 @@ static int _thinid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_volume(seg))
 		return dm_report_field_uint32(rh, field, &seg->device_id);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -933,7 +944,7 @@ static int _vgmdacopies_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint32_t count = vg_mda_copies(vg);
 
 	if (count == VGMETADATACOPIES_UNMANAGED)
-		return _field_set_value(field, "unmanaged", &_reserved_number_undef_64);
+		return _field_set_value(field, "unmanaged", &RESERVED(number_undef_64));
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
@@ -1095,7 +1106,7 @@ static int _raidmismatchcount_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid(lv) && lv_raid_mismatch_count(lv, &mismatch_count))
 		return dm_report_field_uint64(rh, field, &mismatch_count);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
@@ -1109,7 +1120,7 @@ static int _raidwritebehind_disp(struct dm_report *rh __attribute__((unused)),
 	if (lv_is_raid_type(lv) && first_seg(lv)->writebehind)
 		return dm_report_field_uint32(rh, field, &first_seg(lv)->writebehind);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1124,7 +1135,7 @@ static int _raidminrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->min_recovery_rate);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)),
@@ -1139,7 +1150,7 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 		return dm_report_field_uint32(rh, field,
 					      &first_seg(lv)->max_recovery_rate);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 /* Called only with lv_is_thin_pool/volume */
@@ -1192,7 +1203,7 @@ static int _metadatapercent_disp(struct dm_report *rh,
 	if (lv_is_thin_pool(lv))
 		return _dtpercent_disp(1, rh, field, data, private);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1207,7 +1218,7 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _size64_disp(rh, mem, field, &size, private);
 	}
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1222,7 +1233,7 @@ static int _thincount_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _uint32_disp(rh, mem, field, &count, private);
 	}
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
@@ -1518,7 +1529,7 @@ static int _lvmergefailed_disp(struct dm_report *rh, struct dm_pool *mem,
 	int merge_failed;
 
 	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &snap_percent))
-		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+		return _field_set_value(field, _str_unknown, &RESERVED(number_undef_64));
 
 	merge_failed = snap_percent == LVM_PERCENT_MERGE_FAILED;
 	return _binary_disp(rh, mem, field, merge_failed, FIRST_NAME(lv_merge_failed_y), private);
@@ -1533,7 +1544,7 @@ static int _lvsnapshotinvalid_disp(struct dm_report *rh, struct dm_pool *mem,
 	int snap_invalid;
 
 	if (!lv_is_cow(lv))
-		return _field_set_value(field, _str_unknown, &_reserved_number_undef_64);
+		return _field_set_value(field, _str_unknown, &RESERVED(number_undef_64));
 
 	snap_invalid = !lv_snapshot_percent(lv, &snap_percent) || snap_percent == DM_PERCENT_INVALID;
 	return _binary_disp(rh, mem, field, snap_invalid, FIRST_NAME(lv_snapshot_invalid_y), private);
@@ -1619,7 +1630,7 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_thin_pool(seg))
 		return _uint32_disp(rh, mem, field, &seg->zero_new_blocks, private);
 
-	return _field_set_value(field, "", &_reserved_number_undef_64);
+	return _field_set_value(field, "", &RESERVED(number_undef_64));
 }
 
 static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/lib/report/values.h b/lib/report/values.h
index 4566057..5c4b5ab 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -19,22 +19,31 @@
  * uses the exact value defined whenever the reserved name is hit, for
  * example during selection criteria processing.
  *
- * FIELD_RESERVED_VALUE can be used for any field.
+ * TYPE_RESERVED_VALUE defines reserved value that is not bound to any field,
+ * but rather it's bound to a certain type. This can be used as a reserved
+ * value for all fields of that type then.
  *
- * FIELD_BINARY_RESERVED_VALUE is specifically designed for fields with
- * binary values where the reserved names given denote the value 1.
+ * FIELD_RESERVED_VALUE defines reserved value bound to a single field.
+ *
+ * FIELD_BINARY_RESERVED_VALUE is similar to FIELD_RESERVED_VALUE but it
+ * is specifically designed for defintion of reserved names for fields
+ * with binary values where the reserved names given denote value 1.
  * The first reserved_name given is also used for reporting,
- * others are synonyms.
+ * others are synonyms which are recognized in addition.
  *
  */
 
 /*
- * FIELD_RESERVED_VALUE(field_id, reserved_value_id, reserved_name, ...)
+ * TYPE_RESERVED_VALUE(type, id, value, reserved_name, ...)
+ * FIELD_RESERVED_VALUE(field_id, reserved_value_id, value, reserved_name, ...)
  * FIELD_BINARY_RESERVED_VALUE(field_id, reserved_value_id, reserved_name, ...)
  */
 
 /* *INDENT-OFF* */
 
+/* Per-type reserved values usable for all fields of certain type. */
+TYPE_RESERVED_VALUE(NUM, number_undef_64, UINT64_C(-1), "-1", "unknown", "undefined", "undef");
+
 /* Reserved values for PV fields */
 FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "allocatable")
 FIELD_RESERVED_BINARY_VALUE(pv_exported, pv_exported, "exported")
@@ -47,7 +56,7 @@ FIELD_RESERVED_BINARY_VALUE(vg_partial, vg_partial, "partial")
 FIELD_RESERVED_BINARY_VALUE(vg_clustered, vg_clustered, "clustered")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_rw, FIRST_NAME(vg_permissions_rw), "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(vg_permissions, vg_permissions_r, FIRST_NAME(vg_permissions_r), "read-only", "r", "ro")
-FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, _reserved_number_undef_64, "unmanaged")
+FIELD_RESERVED_VALUE(vg_mda_copies, vg_mda_copies, RESERVED(number_undef_64), "unmanaged")
 
 /* Reserved values for LV fields */
 FIELD_RESERVED_BINARY_VALUE(lv_initial_image_sync, lv_initial_image_sync, "initial image sync", "sync")
@@ -69,6 +78,6 @@ FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "skip activa
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, FIRST_NAME(lv_permissions_rw), "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, FIRST_NAME(lv_permissions_r), "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, FIRST_NAME(lv_permissions_r_override), "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, _reserved_number_undef_64, "auto")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead, RESERVED(number_undef_64), "auto")
 
 /* *INDENT-ON* */


