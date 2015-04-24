From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Apr 2015 07:57:14 +0000 (UTC)
Subject: master - select: fix matching reserved values while <, <=, >, >= is used in selection criteria
Message-ID: <20150424075714.1E02060AAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82f6dbfaf7b62c044cd765c207bd8eb1db0edc5a
Commit:        82f6dbfaf7b62c044cd765c207bd8eb1db0edc5a
Parent:        de0ce46361d65af7fb58699e4aba0b649551a6a8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 24 09:47:25 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 24 09:48:57 2015 +0200

select: fix matching reserved values while <,<=,>,>= is used in selection criteria

Scenario:

$ vgs -o+vg_mda_copies
  VG     #PV #LV #SN Attr   VSize VFree #VMdaCps
  fedora   1   2   0 wz--n- 9.51g    0  unmanaged
  vg      16   9   0 wz--n- 1.94g 1.83g         2

$ lvs -o+read_ahead vg/lvol6 vg/lvol7
  LV    VG   Attr       LSize Pool Origin Data%  Rahead
  lvol6 vg   Vwi-a-tz-- 1.00g pool lvol5  0.00      auto
  lvol7 vg   Vwi---tz-k 1.00g pool lvol6         256.00k

Before this patch:

$vgs -o vg_name,vg_mda_copies -S 'vg_mda_copies < unmanaged'
  VG   #VMdaCps
  vg          2

Problem:
Reserved values can be only used with exact match = or !=, not <,<=,>,>=.
In the example above, the "unamanaged" is internally represented as
18446744073709551615, but this should be ignored while not comparing
field directly with "unmanaged" reserved name with = or !=. Users
should not be aware of this internal mapping of the reserved value
name to its internal value and hence it doesn't make sense for such
reserved value to take place in results of <,<=,> and >=.
There's no order defined for reserved values!!! It's a special
*reserved* value that is taken out of the usual value range
of that type.

This is very similar to what we have already fixed with
2f7f6932dcd450ba75fe590aba8c09838d2618dc, but it's the other way round
now - we're using reserved value name in selection criteria now
(in the patch 2f7f693, we had concrete value and we compared it
with the reserved value). So this patch completes patch 2f7f693.

This patch also fixes this problem:

$ lvs -o+read_ahead vg/lvol6 vg/lvol7 -S 'read_ahead > 32k'
  LV    VG   Attr       LSize Pool Origin Data%  Rahead
  lvol6 vg   Vwi-a-tz-- 1.00g pool lvol5  0.00      auto
  lvol7 vg   Vwi---tz-k 1.00g pool lvol6         256.00k

Problem:
In the example above, the internal reserved value "auto" is in the
range of selection "> 32k" - it shouldn't match as well. Here the
"auto" is internally represented as MAX_DBL and of course, numerically,
MAX_DBL > 256k. But for users, the reserved value should be uncomparable
to any number so the mapping of the reserved value name to its interna
 value is transparent to users. Again, there's no order defined for
reserved values and hence it should never match if using <,<=,>,>=
operators.

This is actually exactly the same problem as already described in
2f7f6932dcd450ba75fe590aba8c09838d2618dc, but that patch failed for
size field types because of incorrect internal representation used.

With this patch applied, both problematic scenarios mentioned
above are fixed now:

$ vgs -o vg_name,vg_mda_copies -S 'vg_mda_copies < unmanaged'
(blank)

$ lvs -o+read_ahead vg/lvol6 vg/lvol7 -S 'read_ahead > 32k'
  LV    VG   Attr       LSize Pool Origin Rahead
  lvol7 vg   Vwi---tz-k 1.00g pool lvol6  256.00k
---
 WHATS_NEW_DM         |    2 +
 lib/report/report.c  |   18 ++++++---
 lib/report/values.h  |    2 +-
 libdm/libdm-report.c |  103 +++++++++++++++++++++++++++++---------------------
 4 files changed, 75 insertions(+), 50 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index cead126..dda91a2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.96 - 
 =================================
+  Fix selection to not match if using reserved value in criteria with >,<,>=,<.
+  Fix selection to not match reserved values for size fields if using >,<,>=,<.
   Include uuid or device number in log message after ioctl failure.
   Add DM_INTERNAL_SUSPEND_FLAG to dm-ioctl.h.
   Install blkdeactivate script and its man page with make install_device-mapper.
diff --git a/lib/report/report.c b/lib/report/report.c
index 86b0a54..c29acdb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -26,6 +26,7 @@
 #include "str_list.h"
 
 #include <stddef.h> /* offsetof() */
+#include <float.h> /* DBL_MAX */
 
 struct lvm_report_object {
 	struct volume_group *vg;
@@ -54,6 +55,7 @@ static const char _str_one[] = "1";
 static const char _str_no[] = "no";
 static const char _str_yes[] = "yes";
 static const char _str_unknown[] = "unknown";
+static const double _siz_max = DBL_MAX;
 
 /*
  * 32 bit signed is casted to 64 bit unsigned in dm_report_field internally!
@@ -94,6 +96,7 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
  * 		- 'reserved_value_id_n' (for 0)
  */
 #define NUM uint64_t
+#define SIZ double
 
 #define TYPE_RESERVED_VALUE(type, id, desc, value, ...) \
 	static const char *_reserved_ ## id ## _names[] = { __VA_ARGS__, NULL}; \
@@ -110,6 +113,7 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 #include "values.h"
 
 #undef NUM
+#undef SIZ
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
@@ -122,6 +126,7 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 */
 
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
+#define SIZ DM_REPORT_FIELD_TYPE_SIZE
 
 #define TYPE_RESERVED_VALUE(type, id, desc, value, ...) {type, &_reserved_ ## id, _reserved_ ## id ## _names, desc},
 
@@ -133,10 +138,11 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 
 static const struct dm_report_reserved_value _report_reserved_values[] = {
 	#include "values.h"
-	{0, NULL, NULL}
+	{0, NULL, NULL, NULL}
 };
 
 #undef NUM
+#undef SIZ
 #undef TYPE_RESERVED_VALUE
 #undef FIELD_RESERVED_VALUE
 #undef FIELD_RESERVED_BINARY_VALUE
@@ -659,7 +665,7 @@ static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_
 {
 	const uint32_t size = *(const uint32_t *) data;
 	const char *disp, *repstr;
-	uint64_t *sortval;
+	double *sortval;
 
 	if (!*(disp = display_size_units(private, (uint64_t) size)))
 		return_0;
@@ -674,7 +680,7 @@ static int _size32_disp(struct dm_report *rh __attribute__((unused)), struct dm_
 		return 0;
 	}
 
-	*sortval = (uint64_t) size;
+	*sortval = (double) size;
 
 	return _field_set_value(field, repstr, sortval);
 }
@@ -686,7 +692,7 @@ static int _size64_disp(struct dm_report *rh __attribute__((unused)),
 {
 	const uint64_t size = *(const uint64_t *) data;
 	const char *disp, *repstr;
-	uint64_t *sortval;
+	double *sortval;
 
 	if (!*(disp = display_size_units(private, size)))
 		return_0;
@@ -696,12 +702,12 @@ static int _size64_disp(struct dm_report *rh __attribute__((unused)),
 		return 0;
 	}
 
-	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
+	if (!(sortval = dm_pool_alloc(mem, sizeof(double)))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
-	*sortval = size;
+	*sortval = (double) size;
 
 	return _field_set_value(field, repstr, sortval);
 }
diff --git a/lib/report/values.h b/lib/report/values.h
index bc42563..dd20caf 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -83,7 +83,7 @@ FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
-FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &GET_TYPE_RESERVED_VALUE(num_undef_64), "auto")
+FIELD_RESERVED_VALUE(lv_read_ahead, lv_read_ahead_auto, "", &_siz_max, "auto")
 FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_error, "", "error", "error", "error when full", "error if no space")
 FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_queue, "", "queue", "queue", "queue when full", "queue if no space")
 FIELD_RESERVED_VALUE(lv_when_full, lv_when_full_undef, "", "", "", "undefined")
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9f50ff3..2fe9300 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1262,43 +1262,59 @@ static int _close_enough(double d1, double d2)
 	return fabs(d1 - d2) < DBL_EPSILON;
 }
 
+static int _do_check_value_is_reserved(unsigned type, const void *reserved_value,
+				       const void *value1, const void *value2)
+{
+	switch (type) {
+		case DM_REPORT_FIELD_TYPE_NUMBER:
+			if ((*(uint64_t *)value1 == *(uint64_t *) reserved_value) ||
+			    (value2 && (*(uint64_t *)value2 == *(uint64_t *) reserved_value)))
+				return 1;
+				break;
+		case DM_REPORT_FIELD_TYPE_STRING:
+			if ((!strcmp((const char *)value1, (const char *) reserved_value)) ||
+			    (value2 && (!strcmp((const char *)value2, (const char *) reserved_value))))
+				return 1;
+			break;
+		case DM_REPORT_FIELD_TYPE_SIZE:
+			if ((_close_enough(*(double *)value1, *(double *) reserved_value)) ||
+			    (value2 && (_close_enough(*(double *)value2, *(double *) reserved_value))))
+				return 1;
+			break;
+		case DM_REPORT_FIELD_TYPE_STRING_LIST:
+			/* FIXME Add comparison for string list */
+			break;
+	}
+
+	return 0;
+}
+
 /*
  * Used to check whether a value of certain type used in selection is reserved.
  */
-static int _check_value_is_reserved(struct dm_report *rh, unsigned type, const void *value)
+static int _check_value_is_reserved(struct dm_report *rh, uint32_t field_num, unsigned type,
+				    const void *value1, const void *value2)
 {
 	const struct dm_report_reserved_value *iter = rh->reserved_values;
+	const struct dm_report_field_reserved_value *frv;
 
 	if (!iter)
 		return 0;
 
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
-					/* FIXME Add comparison for string list */
-					break;
-			}
-		}
+	while (iter->value) {
+		if (iter->type == DM_REPORT_FIELD_TYPE_NONE) {
+			frv = (const struct dm_report_field_reserved_value *) iter->value;
+			if (frv->field_num == field_num && _do_check_value_is_reserved(type, frv->value, value1, value2))
+				return 1;
+		} else if (iter->type & type && _do_check_value_is_reserved(type, iter->value, value1, value2))
+			return 1;
 		iter++;
 	}
 
 	return 0;
 }
 
-static int _cmp_field_int(struct dm_report *rh, const char *field_id,
+static int _cmp_field_int(struct dm_report *rh, uint32_t field_num, const char *field_id,
 			  uint64_t a, uint64_t b, uint32_t flags)
 {
 	switch(flags & FLD_CMP_MASK) {
@@ -1307,13 +1323,13 @@ static int _cmp_field_int(struct dm_report *rh, const char *field_id,
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
 			return a != b;
 		case FLD_CMP_NUMBER|FLD_CMP_GT:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a > b;
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a > b;
 		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a >= b;
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a >= b;
 		case FLD_CMP_NUMBER|FLD_CMP_LT:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a < b;
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a < b;
 		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &a) ? 0 : a <= b;
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &a, &b) ? 0 : a <= b;
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_int: unsupported number "
 				  "comparison type for field %s", field_id);
@@ -1322,7 +1338,7 @@ static int _cmp_field_int(struct dm_report *rh, const char *field_id,
 	return 0;
 }
 
-static int _cmp_field_double(struct dm_report *rh, const char *field_id,
+static int _cmp_field_double(struct dm_report *rh, uint32_t field_num, const char *field_id,
 			     double a, double b, uint32_t flags)
 {
 	switch(flags & FLD_CMP_MASK) {
@@ -1331,13 +1347,13 @@ static int _cmp_field_double(struct dm_report *rh, const char *field_id,
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
 			return !_close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_GT:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : (a > b) && !_close_enough(a, b);
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : (a > b) && !_close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : (a > b) || _close_enough(a, b);
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : (a > b) || _close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_LT:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : (a < b) && !_close_enough(a, b);
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : (a < b) && !_close_enough(a, b);
 		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
-			return _check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &a) ? 0 : a < b || _close_enough(a, b);
+			return _check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &a, &b) ? 0 : a < b || _close_enough(a, b);
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_double: unsupported number "
 				  "comparison type for selection field %s", field_id);
@@ -1346,7 +1362,8 @@ static int _cmp_field_double(struct dm_report *rh, const char *field_id,
 	return 0;
 }
 
-static int _cmp_field_string(struct dm_report *rh __attribute__((unused)), const char *field_id,
+static int _cmp_field_string(struct dm_report *rh __attribute__((unused)),
+			     uint32_t field_num, const char *field_id,
 			     const char *a, const char *b, uint32_t flags)
 {
 	switch (flags & FLD_CMP_MASK) {
@@ -1440,7 +1457,7 @@ static int _cmp_field_string_list_any(const struct str_list_sort_value *val,
 }
 
 static int _cmp_field_string_list(struct dm_report *rh __attribute__((unused)),
-				  const char *field_id,
+				  uint32_t field_num, const char *field_id,
 				  const struct str_list_sort_value *value,
 				  const struct selection_str_list *selection, uint32_t flags)
 {
@@ -1510,16 +1527,16 @@ static int _compare_selection_field(struct dm_report *rh,
 					return 0;
 				/* fall through */
 			case DM_REPORT_FIELD_TYPE_NUMBER:
-				r = _cmp_field_int(rh, field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
+				r = _cmp_field_int(rh, f->props->field_num, field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				r = _cmp_field_double(rh, field_id, *(const uint64_t *) f->sort_value, fs->v.d, fs->flags);
+				r = _cmp_field_double(rh, f->props->field_num, field_id, *(double *) f->sort_value, fs->v.d, fs->flags);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING:
-				r = _cmp_field_string(rh, field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
+				r = _cmp_field_string(rh, f->props->field_num, field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
-				r = _cmp_field_string_list(rh, field_id, (const struct str_list_sort_value *) f->sort_value,
+				r = _cmp_field_string_list(rh, f->props->field_num, field_id, (const struct str_list_sort_value *) f->sort_value,
 							   fs->v.l, fs->flags);
 				break;
 			default:
@@ -2500,7 +2517,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					dm_pool_free(rh->selection->mem, s);
 				} else {
 					fs->v.s = s;
-					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_STRING, fs->v.s)) {
+					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, fs->v.s, NULL)) {
 						log_error("String value %s found in selection is reserved.", fs->v.s);
 						goto error;
 					}
@@ -2515,7 +2532,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						log_error(_out_of_range_msg, s, field_id);
 						goto error;
 					}
-					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_NUMBER, &fs->v.i)) {
+					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_NUMBER, &fs->v.i, NULL)) {
 						log_error("Numeric value %" PRIu64 " found in selection is reserved.", fs->v.i);
 						goto error;
 					}
@@ -2524,7 +2541,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
 				if (reserved)
-					fs->v.d = (double) * (uint64_t *) _get_reserved_value(reserved);
+					fs->v.d = *(double *) _get_reserved_value(reserved);
 				else {
 					fs->v.d = strtod(s, NULL);
 					if (errno == ERANGE) {
@@ -2534,7 +2551,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (custom && (factor = *((uint64_t *)custom)))
 						fs->v.d *= factor;
 					fs->v.d /= 512; /* store size in sectors! */
-					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_SIZE, &fs->v.d)) {
+					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &fs->v.d, NULL)) {
 						log_error("Size value %f found in selection is reserved.", fs->v.d);
 						goto error;
 					}
@@ -2553,7 +2570,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 
 					fs->v.i = (dm_percent_t) (DM_PERCENT_1 * fs->v.d);
 
-					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_PERCENT, &fs->v.i)) {
+					if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_PERCENT, &fs->v.i, NULL)) {
 						log_error("Percent value %s found in selection is reserved.", s);
 						goto error;
 					}
@@ -2561,7 +2578,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING_LIST:
 				fs->v.l = *(struct selection_str_list **)custom;
-				if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->v.l)) {
+				if (_check_value_is_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING_LIST, fs->v.l, NULL)) {
 					log_error("String list value found in selection is reserved.");
 					goto error;
 				}


