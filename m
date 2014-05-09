From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:56 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: add _check_selection fn to support checking fields against given selections
Message-ID: <20140509065656.5EFD560F95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fda0e49393ec9e31a78ea5d9a41d74d82c2523dd
Commit:        fda0e49393ec9e31a78ea5d9a41d74d82c2523dd
Parent:        b73c961d5a9f7a74e4ebf17986868c2f0b1e71c4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 11:57:37 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: add _check_selection fn to support checking fields against given selections

---
 libdm/libdm-report.c |  153 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 153 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index b4c5d27..883f34f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -16,6 +16,8 @@
 #include "dmlib.h"
 
 #include <ctype.h>
+#include <math.h>  /* fabs() */
+#include <float.h> /* DBL_EPSILON */
 
 /*
  * Internal flags
@@ -784,6 +786,157 @@ static void *_report_get_field_data(struct dm_report *rh,
 	return (void *)(ret + rh->fields[fp->field_num].offset);
 }
 
+static inline int _cmp_field_int(uint64_t a, uint64_t b, uint32_t flags)
+{
+	switch(flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return a == b;
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return a != b;
+		case FLD_CMP_GT:
+			return a > b;
+		case FLD_CMP_GT|FLD_CMP_EQUAL:
+			return a >= b;
+		case FLD_CMP_LT:
+			return a < b;
+		case FLD_CMP_LT|FLD_CMP_EQUAL:
+			return a <= b;
+		default:
+			log_error("Unsupported comparison type for number");
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
+static inline int _cmp_field_double(double a, double b, uint32_t flags)
+{
+	switch(flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return _close_enough(a, b);
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return !_close_enough(a, b);
+		case FLD_CMP_GT:
+			return (a > b) && !_close_enough(a, b);
+		case FLD_CMP_GT|FLD_CMP_EQUAL:
+			return (a > b) || _close_enough(a, b);
+		case FLD_CMP_LT:
+			return (a < b) && !_close_enough(a, b);
+		case FLD_CMP_LT|FLD_CMP_EQUAL:
+			return a < b || _close_enough(a, b);
+		default:
+			log_error("Unsupported comparison type for number");
+	}
+
+	return 0;
+}
+
+static inline int _cmp_field_string(const char *a, const char *b, uint32_t flags)
+{
+	switch (flags & FLD_CMP_MASK) {
+		case FLD_CMP_EQUAL:
+			return !strcmp(a, b);
+		case FLD_CMP_NOT|FLD_CMP_EQUAL:
+			return strcmp(a, b);
+		default:
+			log_error("Unsupported comparison type for string");
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
+static int _compare_field(struct dm_report *rh,
+			  struct dm_report_field *f,
+			  struct field_selection *fs)
+{
+	int r = 0;
+
+	if (!f->sort_value) {
+		log_error("_compare_field: field without value :%d",
+			  f->props->field_num);
+		return 0;
+	}
+
+	if (fs->flags & FLD_CMP_REGEX)
+		r = _cmp_field_regex((const char *) f->sort_value, fs->v.r, fs->flags);
+	else {
+		switch(f->props->flags & DM_REPORT_FIELD_TYPE_MASK) {
+			case DM_REPORT_FIELD_TYPE_NUMBER:
+				r = _cmp_field_int(*(const uint64_t *) f->sort_value, fs->v.i, fs->flags);
+				break;
+			case DM_REPORT_FIELD_TYPE_SIZE:
+				r = _cmp_field_double(*(const uint64_t *) f->sort_value, fs->v.d, fs->flags);
+				break;
+			case DM_REPORT_FIELD_TYPE_STRING:
+				r = _cmp_field_string((const char *) f->sort_value, fs->v.s, fs->flags);
+				break;
+			default:
+				log_error(INTERNAL_ERROR "_compare_field: unknown field type");
+		}
+	}
+
+	log_verbose("%s field %s with value '%s'.",
+		    r ? "Selecting" : "Not selecting",
+		    rh->fields[f->props->field_num].id,
+		    f->report_string);
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
+				if (!_compare_field(rh, f, sn->selection.item))
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


