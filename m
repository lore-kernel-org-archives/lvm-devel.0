From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 14:05:11 +0000 (UTC)
Subject: master - cleanup: preserve constness of some pointers
Message-ID: <20150818140511.6041260DD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e1feb0f736f4ebd819f25eb53f7f7ab74bb0678
Commit:        6e1feb0f736f4ebd819f25eb53f7f7ab74bb0678
Parent:        ef7264807ff44c029360e697dd391ab870bb4481
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 15:39:04 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 16:05:04 2015 +0200

cleanup: preserve constness of some pointers

---
 libdm/libdm-report.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 84b1294..b948073 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -257,7 +257,7 @@ static int _selected_disp(struct dm_report *rh,
 			  const void *data,
 			  void *private __attribute__((unused)))
 {
-	struct row *row = (struct row *)data;
+	const struct row *row = (const struct row *)data;
 	return dm_report_field_int(rh, field, &row->selected);
 }
 
@@ -1387,11 +1387,11 @@ static int _dbl_less_or_equal(double d1, double d2)
 	return _dbl_less(d1, d2) || _dbl_equal(d1, d2);
 }
 
-#define _uint64 *(uint64_t *)
-#define _uint64arr(var,index) ((uint64_t *)var)[index]
+#define _uint64 *(const uint64_t *)
+#define _uint64arr(var,index) ((const uint64_t *)var)[index]
 #define _str (const char *)
-#define _dbl *(double *)
-#define _dblarr(var,index) ((double *)var)[index]
+#define _dbl *(const double *)
+#define _dblarr(var,index) ((const double *)var)[index]
 
 static int _do_check_value_is_strictly_reserved(unsigned type, const void *res_val, int res_range,
 						const void *val, struct field_selection *fs)
@@ -1790,7 +1790,7 @@ static int _compare_selection_field(struct dm_report *rh,
 				r = _cmp_field_int(rh, f->props->field_num, field_id, *(const uint64_t *) f->sort_value, fs);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
-				r = _cmp_field_double(rh, f->props->field_num, field_id, *(double *) f->sort_value, fs);
+				r = _cmp_field_double(rh, f->props->field_num, field_id, *(const double *) f->sort_value, fs);
 				break;
 			case DM_REPORT_FIELD_TYPE_STRING:
 				r = _cmp_field_string(rh, f->props->field_num, field_id, (const char *) f->sort_value, fs);
@@ -2446,8 +2446,8 @@ static const char *_tok_value_regex(struct dm_report *rh,
 
 static int _str_list_item_cmp(const void *a, const void *b)
 {
-	const struct dm_str_list **item_a = (const struct dm_str_list **) a;
-	const struct dm_str_list **item_b = (const struct dm_str_list **) b;
+	const struct dm_str_list * const *item_a = (const struct dm_str_list * const *) a;
+	const struct dm_str_list * const *item_b = (const struct dm_str_list * const *) b;
 
 	return strcmp((*item_a)->str, (*item_b)->str);
 }
@@ -3357,7 +3357,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		memcpy(s, v, len);
 		s[len] = '\0';
 
-		fs->value->v.r = dm_regex_create(rh->selection->mem, (const char **) &s, 1);
+		fs->value->v.r = dm_regex_create(rh->selection->mem, (const char * const *) &s, 1);
 		dm_free(s);
 		if (!fs->value->v.r) {
 			log_error("dm_report: failed to create regex "
@@ -3377,7 +3377,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				if (rvw->value) {
 					fs->value->v.s = (const char *) rvw->value;
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.s = (((const char **) rvw->value)[1]);
+						fs->value->next->v.s = (((const char * const *) rvw->value)[1]);
 					dm_pool_free(rh->selection->mem, s);
 				} else {
 					fs->value->v.s = s;
@@ -3389,9 +3389,9 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_NUMBER:
 				if (rvw->value) {
-					fs->value->v.i = *(uint64_t *) rvw->value;
+					fs->value->v.i = *(const uint64_t *) rvw->value;
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.i = (((uint64_t *) rvw->value)[1]);
+						fs->value->next->v.i = (((const uint64_t *) rvw->value)[1]);
 				} else {
 					if (((fs->value->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
 						 (errno == ERANGE)) {
@@ -3407,16 +3407,16 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
 				if (rvw->value) {
-					fs->value->v.d = *(double *) rvw->value;
+					fs->value->v.d = *(const double *) rvw->value;
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.d = (((double *) rvw->value)[1]);
+						fs->value->next->v.d = (((const double *) rvw->value)[1]);
 				} else {
 					fs->value->v.d = strtod(s, NULL);
 					if (errno == ERANGE) {
 						log_error(_out_of_range_msg, s, field_id);
 						goto error;
 					}
-					if (custom && (factor = *((uint64_t *)custom)))
+					if (custom && (factor = *((const uint64_t *)custom)))
 						fs->value->v.d *= factor;
 					fs->value->v.d /= 512; /* store size in sectors! */
 					if (_check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_SIZE, &fs->value->v.d, NULL)) {
@@ -3428,9 +3428,9 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_PERCENT:
 				if (rvw->value) {
-					fs->value->v.i = *(uint64_t *) rvw->value;
+					fs->value->v.i = *(const uint64_t *) rvw->value;
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.i = (((uint64_t *) rvw->value)[1]);
+						fs->value->next->v.i = (((const uint64_t *) rvw->value)[1]);
 				} else {
 					fs->value->v.d = strtod(s, NULL);
 					if ((errno == ERANGE) || (fs->value->v.d < 0) || (fs->value->v.d > 100)) {
@@ -3455,9 +3455,9 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_TIME:
 				if (rvw->value) {
-					fs->value->v.t = *(time_t *) rvw->value;
+					fs->value->v.t = *(const time_t *) rvw->value;
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
-						fs->value->next->v.t = (((time_t *) rvw->value)[1]);
+						fs->value->next->v.t = (((const time_t *) rvw->value)[1]);
 				} else {
 					tval = (struct time_value *) custom;
 					fs->value->v.t = tval->t1;


