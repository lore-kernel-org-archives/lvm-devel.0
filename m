From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:43 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select add _check_selection fn to support checking fields against given selections
Message-ID: <20140606120343.C9E9760180@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c3a72eb7ec90a8bc945ec04477208d8c1d2f528
Commit:        5c3a72eb7ec90a8bc945ec04477208d8c1d2f528
Parent:        710d2c246255c7e2d292f952d20d1bbaf5cc63b9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:38:22 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:11:20 2014 +0200

report: select add _check_selection fn to support checking fields against given selections

This is rebased and edited versions of the original design and
patch proposed by Jun'ichi Nomura:
  http://www.redhat.com/archives/dm-devel/2007-April/msg00025.html

The _check_selection implements the actual field checking against the
selection tree.
---
 libdm/libdm-report.c |  157 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 156 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f85ccad..5c33ef5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -16,6 +16,8 @@
 #include "dmlib.h"
 
 #include <ctype.h>
+#include <math.h>  /* fabs() */
+#include <float.h> /* DBL_EPSILON */
 
 /*
  * Internal flags
@@ -791,6 +793,158 @@ static void *_report_get_field_data(struct dm_report *rh,
 	return (void *)(ret + rh->fields[fp->field_num].offset);
 }
 
+static inline int _cmp_field_int(const char *field_id, uint64_t a, uint64_t b, uint32_t flags)
+{
+	switch(flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return a == b;
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return a != b;
+		case FLD_CMP_NUMBER|FLD_CMP_GT:
+			return a > b;
+		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
+			return a >= b;
+		case FLD_CMP_NUMBER|FLD_CMP_LT:
+			return a < b;
+		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
+			return a <= b;
+		default:
+			log_error(INTERNAL_ERROR "_cmp_field_int: unsupported number "
+				  "comparison type for field %s", field_id);
+	}
+
+	return 0;
+}
+
+static int _close_enough(double d1, double d2)
+{
+	return fabs(d1 - d2) < DBL_EPSILON;
+}
+
+static inline int _cmp_field_double(const char *field_id, double a, double b, uint32_t flags)
+{
+	switch(flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return _close_enough(a, b);
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return !_close_enough(a, b);
+		case FLD_CMP_NUMBER|FLD_CMP_GT:
+			return (a > b) && !_close_enough(a, b);
+		case FLD_CMP_NUMBER|FLD_CMP_GT|FLD_CMP_EQUAL:
+			return (a > b) || _close_enough(a, b);
+		case FLD_CMP_NUMBER|FLD_CMP_LT:
+			return (a < b) && !_close_enough(a, b);
+		case FLD_CMP_NUMBER|FLD_CMP_LT|FLD_CMP_EQUAL:
+			return a < b || _close_enough(a, b);
+		default:
+			log_error(INTERNAL_ERROR "_cmp_field_double: unsupported number "
+				  "comparison type for selection field %s", field_id);
+	}
+
+	return 0;
+}
+
+static inline int _cmp_field_string(const char *field_id, const char *a, const char *b, uint32_t flags)
+{
+	switch (flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return !strcmp(a, b);
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return strcmp(a, b);
+		default:
+			log_error(INTERNAL_ERROR "_cmp_field_string: unsupported string "
+				  "comparison type for selection field %s", field_id);
+	}
+
+	return 0;
+}
+
+static inline int _cmp_field_regex(const char *s, struct dm_regex *r, uint32_t flags)
+{
+	return (dm_regex_match(r, s) >= 0) ^ (flags & FLD_CMP_NOT);
+}
+
+static int _compare_selection_field(struct dm_report *rh,
+				    struct dm_report_field *f,
+				    struct field_selection *fs)
+{
+	const char *field_id = rh->fields[f->props->field_num].id;
+	int r = 0;
+
+	if (!f->sort_value) {
+		log_error("_compare_selection_field: field without value :%d",
+			  f->props->field_num);
+		return 0;
+	}
+
+	if (fs->flags & FLD_CMP_REGEX)
+		r = _cmp_field_regex((const char *) f->sort_value, fs->v.r, fs->flags);
+	else {
+		switch(f->props->flags & DM_REPORT_FIELD_TYPE_MASK) {
+			case DM_REPORT_FIELD_TYPE_NUMBER:
+				r = _cmp_field_int(field_id, *(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
+				break;
+			case DM_REPORT_FIELD_TYPE_SIZE:
+				r = _cmp_field_double(field_id, *(const uint64_t *) f->sort_value, fs->v.d, fs->flags);
+				break;
+			case DM_REPORT_FIELD_TYPE_STRING:
+				r = _cmp_field_string(field_id, (const char *) f->sort_value, fs->v.s, fs->flags);
+				break;
+			default:
+				log_error(INTERNAL_ERROR "_compare_selection_field: unknown field type for field %s", field_id);
+		}
+	}
+
+	log_verbose("%s field %s with value '%s'.", r ? "Selecting" : "Not selecting", field_id, f->report_string);
+
+	return r;
+}
+
+static int _check_selection(struct dm_report *rh, struct selection_node *sn,
+			    struct dm_list *fields)
+{
+	int r;
+	struct selection_node *iter_n;
+	struct dm_report_field *f;
+
+	switch (sn->type & SEL_MASK) {
+		case SEL_ITEM:
+			r = 1;
+			dm_list_iterate_items(f, fields) {
+				if (sn->selection.item->fp != f->props)
+					continue;
+				if (!_compare_selection_field(rh, f, sn->selection.item))
+					r = 0;
+			}
+			break;
+		case SEL_OR:
+			r = 0;
+			dm_list_iterate_items(iter_n, &sn->selection.set)
+				if ((r |= _check_selection(rh, iter_n, fields)))
+					break;
+			break;
+		case SEL_AND:
+			r = 1;
+			dm_list_iterate_items(iter_n, &sn->selection.set)
+				if (!(r &= _check_selection(rh, iter_n, fields)))
+					break;
+			break;
+		default:
+			log_error("Unsupported selection type");
+			return 0;
+	}
+
+	return (sn->type & SEL_MODIFIER_NOT) ? !r : r;
+}
+
+static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
+{
+	if (!rh->selection_root)
+		return 1;
+
+	return _check_selection(rh, rh->selection_root, fields);
+}
+
 int dm_report_object(struct dm_report *rh, void *object)
 {
 	struct field_properties *fp;
@@ -1339,7 +1493,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		if (!(last = _tok_value_regex(ft, last, &vs, &ve, &flags)))
 			goto_bad;
 	} else {
-		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE)
+		if (ft->flags == DM_REPORT_FIELD_TYPE_SIZE ||
+		    ft->flags == DM_REPORT_FIELD_TYPE_NUMBER)
 			custom = &factor;
 		else
 			custom = NULL;


