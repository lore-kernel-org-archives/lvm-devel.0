From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 27 Oct 2014 10:37:47 +0000 (UTC)
Subject: master - report: selection: fix selection criteria to not match reserved values when using >, <, >=, <
Message-ID: <20141027103747.8600A6055C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f7f6932dcd450ba75fe590aba8c09838d2618dc
Commit:        2f7f6932dcd450ba75fe590aba8c09838d2618dc
Parent:        e223c801fc3eb12c2a4502aee471f18a0b903de8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 27 11:25:08 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 27 11:25:08 2014 +0100

report: selection: fix selection criteria to not match reserved values when using >, <, >=, <

Some values are reserved for special purpose like 'undefined', 'unmanaged' etc.
When using >, <, >= and < comparison operators where the range is considered,
do not include reserved values as proper values in this range which
would otherwise result in not so obvious criteria match (as the reserved value is
actually transparent for the user). It's incorrect.

Example scenario:
$ vgs -o vg_name,vg_mda_copies vg1 vg2
  VG   #VMdaCps
  vg1          1
  vg2  unmanaged

The "unmanaged" is actually mapped onto reserved value
18446744073709551615 (2^64 - 1) internally.

Such reseved value is already caught on selection criteria input
properly:

$ vgs -o name,vg_mda_copies vg1 vg2 -S 'vg_mda_copies=18446744073709551615'
  Numeric value 18446744073709551615 found in selection is reserved.

However, we still need to fix situaton where the reserved value may be
included in resulting range:

Before this patch:
$ vgs -o vg_name,vg_mda_copies vg1 vg2 -S 'vg_mda_copies >= 1'
  VG   #VMdaCps
  vg1          1
  vg2  unmanaged

With this patch applied:
$ vgs -o vg_name,vg_mda_copies vg1 vg2 -S 'vg_mda_copies >= 1'
  VG   #VMdaCps
  vg1         1

>From the examples above, we can see that without this patch applied,
the vg_mda_copies >= 1 also matched the reserved value 18446744073709551615
(which is represented by the "unamanged" string on report). When
applying the operators, such values must be skipped! They're meant to
be matched only against their string representation only, e.g.:

$ vgs -o name,vg_mda_copies vg1 vg2 -S 'vg_mda_copies=unmanaged'
  VG   #VMdaCps
  vg2  unmanaged

...or any synonyms:

$ vgs -o name,vg_mda_copies vg1 vg2 -S 'vg_mda_copies=undefined'
  VG   #VMdaCps
  vg2  unmanaged
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |  118 ++++++++++++++++++++++++++------------------------
 2 files changed, 62 insertions(+), 57 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5ab34c1..6981f8f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Fix selection criteria to not match reserved values when using >, <, >=, <.
   Add DM_LIST_HEAD_INIT macro to libdevmapper.h
   Fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 8c27c5b..f68aa85 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1234,7 +1234,49 @@ static void *_report_get_implicit_field_data(struct dm_report *rh __attribute__(
 	return NULL;
 }
 
-static int _cmp_field_int(const char *field_id, uint64_t a, uint64_t b, uint32_t flags)
+static int _close_enough(double d1, double d2)
+{
+	return fabs(d1 - d2) < DBL_EPSILON;
+}
+
+/*
+ * Used to check whether a value of certain type used in selection is reserved.
+ */
+static int _check_value_is_reserved(struct dm_report *rh, unsigned type, const void *value)
+{
+	const struct dm_report_reserved_value *iter = rh->reserved_values;
+
+	if (!iter)
+		return 0;
+
+	while (iter->type) {
+		if (iter->type & type) {
+			switch (type) {
+				case DM_REPORT_FIELD_TYPE_NUMBER:
+					if (*(uint64_t *)iter->value == *(uint64_t *)value)
+						return 1;
+					break;
+				case DM_REPORT_FIELD_TYPE_STRING:
+					if (!strcmp((const char *)iter->value, (const char *) value))
+						return 1;
+					break;
+				case DM_REPORT_FIELD_TYPE_SIZE:
+					if (_close_enough(*(double *)iter->value, *(double *) value))
+						return 1;
+					break;
+				case DM_REPORT_FIELD_TYPE_STRING_LIST:
+					// TODO: add comparison for string list
+					break;
+			}
+		}
+		iter++;
+	}
+
+	return 0;
+}
+
+static int _cmp_field_int(struct dm_report *rh, const char *field_id,
+			  uint64_t a, uint64_t b, uint32_t flags)
 {
 	switch(flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
@@ -1242,13 +1284,13 @@ static int _cmp_field_int(const char *field_id, uint64_t a, uint64_t b, uint32_t
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
 			return a != b;
 		case FLD_CMP_NUMBER|FLD_CMP_GT:
-			return a > b;
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a > b;
 		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
-			return a >= b;
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a >= b;
 		case FLD_CMP_NUMBER|FLD_CMP_LT:
-			return a < b;
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a < b;
 		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
-			return a <= b;
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a <= b;
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_int: unsupported number "
 				  "comparison type for field %s", field_id);
@@ -1257,12 +1299,8 @@ static int _cmp_field_int(const char *field_id, uint64_t a, uint64_t b, uint32_t
 	return 0;
 }
 
-static int _close_enough(double d1, double d2)
-{
-	return fabs(d1 - d2) < DBL_EPSILON;
-}
-
-static int _cmp_field_double(const char *field_id, double a, double b, uint32_t flags)
+static int _cmp_field_double(struct dm_report *rh, const char *field_id,
+			     double a, double b, uint32_t flags)
 {
 	switch(flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
@@ -1270,13 +1308,13 @@ static int _cmp_field_double(const char *field_id, double a, double b, uint32_t
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
 			return !_close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_GT:
-			return (a > b) && !_close_enough(a, b);
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : (a > b) && !_close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
-			return (a > b) || _close_enough(a, b);
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : (a > b) || _close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_LT:
-			return (a < b) && !_close_enough(a, b);
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : (a < b) && !_close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
-			return a < b || _close_enough(a, b);
+			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : a < b || _close_enough(a, b);
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_double: unsupported number "
 				  "comparison type for selection field %s", field_id);
@@ -1285,7 +1323,8 @@ static int _cmp_field_double(const char *field_id, double a, double b, uint32_t
 	return 0;
 }
 
-static int _cmp_field_string(const char *field_id, const char *a, const char *b, uint32_t flags)
+static int _cmp_field_string(struct dm_report *rh __attribute__((unused)), const char *field_id,
+			     const char *a, const char *b, uint32_t flags)
 {
 	switch (flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
@@ -1377,7 +1416,8 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 	return 0;
 }
 
-static int _cmp_field_string_list(const char *field_id,
+static int _cmp_field_string_list(struct dm_report *rh __attribute__((unused)),
+				  const char *field_id,
 				  const struct str_list_sort_value *value,
 				  const struct selection_str_list *selection, uint32_t flags)
 {
@@ -1447,16 +1487,16 @@ static int _compare_selection_field(struct dm_report *rh,
 					return 0;
 				/* fall through */
 			case DM_REPORT_FIELD_TYPE_NUMBER:
-				r = _cmp_field_int(field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
+				r = _cmp_field_int(rh, field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				r = _cmp_field_double(field_id, *(const uint64_t *) f->sort_value, fs->v.d, fs->flags);
+				r = _cmp_field_double(rh, field_id, *(const uint64_t *) f->sort_value, fs->v.d, fs->flags);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING:
-				r = _cmp_field_string(field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
+				r = _cmp_field_string(rh, field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
-				r = _cmp_field_string_list(field_id, (const struct str_list_sort_value *) f->sort_value,
+				r = _cmp_field_string_list(rh, field_id, (const struct str_list_sort_value *) f->sort_value,
 							   fs->v.l, fs->flags);
 				break;
 			default:
@@ -1851,42 +1891,6 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 	return s;
 }
 
-/*
- * Used to check whether a value of certain type used in selection is reserved.
- */
-static int _check_value_is_reserved(struct dm_report *rh, unsigned type, const void *value)
-{
-	const struct dm_report_reserved_value *iter = rh->reserved_values;
-
-	if (!iter)
-		return 0;
-
-	while (iter->type) {
-		if (iter->type & type) {
-			switch (type) {
-				case DM_REPORT_FIELD_TYPE_NUMBER:
-					if (*(uint64_t *)iter->value == *(uint64_t *)value)
-						return 1;
-					break;
-				case DM_REPORT_FIELD_TYPE_STRING:
-					if (!strcmp((const char *)iter->value, (const char *) value))
-						return 1;
-					break;
-				case DM_REPORT_FIELD_TYPE_SIZE:
-					if (_close_enough(*(double *)iter->value, *(double *) value))
-						return 1;
-					break;
-				case DM_REPORT_FIELD_TYPE_STRING_LIST:
-					// TODO: add comparison for string list
-					break;
-			}
-		}
-		iter++;
-	}
-
-	return 0;
-}
-
 float dm_percent_to_float(dm_percent_t percent)
 {
 	return (float) percent / DM_PERCENT_1;


