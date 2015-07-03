From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  3 Jul 2015 09:32:37 +0000 (UTC)
Subject: master - report: call appropriate handler to evaluate fuzzy reserved names and dynamic reserved values
Message-ID: <20150703093237.2879F60976@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b1422c45c6c782f5134e74439ccdd6766085d4c
Commit:        3b1422c45c6c782f5134e74439ccdd6766085d4c
Parent:        335707b0e2e657a40ae87fb47dbf744cb53d74fb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 20 18:47:54 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 3 10:47:38 2015 +0200

report: call appropriate handler to evaluate fuzzy reserved names and dynamic reserved values

Wire the dm_report_reserved_handler instance call in reporting/selection
infrastructure to handle reserved value actions (currently only
DM_REPORT_RESERVED_PARSE_FUZZY_NAME and DM_REPORT_RESERVED_GET_DYNAMIC_VALUE
actions).
---
 lib/report/report.c  |    8 +++++
 libdm/libdm-report.c |   71 +++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 73 insertions(+), 6 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 2e9a5d3..4d1b8eb 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -96,6 +96,8 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
  * 		- 'reserved_value_id_n' (for 0)
  */
 #define NUM uint64_t
+#define NUM_HND dm_report_reserved_handler
+#define HND (dm_report_reserved_handler)
 #define NOFLAG 0
 #define NAMED DM_REPORT_FIELD_RESERVED_VALUE_NAMED
 #define RANGE DM_REPORT_FIELD_RESERVED_VALUE_RANGE
@@ -117,6 +119,8 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 #include "values.h"
 
 #undef NUM
+#undef NUM_HND
+#undef HND
 #undef NOFLAG
 #undef NAMED
 #undef RANGE
@@ -134,6 +138,8 @@ static const int32_t _reserved_num_undef_32 = INT32_C(-1);
 */
 
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
+#define NUM_HND DM_REPORT_FIELD_TYPE_NUMBER
+#define HND 0
 #define NOFLAG 0
 #define NAMED DM_REPORT_FIELD_RESERVED_VALUE_NAMED
 #define RANGE DM_REPORT_FIELD_RESERVED_VALUE_RANGE
@@ -154,6 +160,8 @@ static const struct dm_report_reserved_value _report_reserved_values[] = {
 };
 
 #undef NUM
+#undef NUM_HND
+#undef HND
 #undef NOFLAG
 #undef NAMED
 #undef RANGE
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 559d463..2ec98d6 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2123,14 +2123,48 @@ static const char *_tok_value_string(const char *s,
 	return s;
 }
 
-static const char *_reserved_name(const char **names, const char *s, size_t len)
+static const char *_reserved_name(struct dm_report *rh,
+				  const struct dm_report_reserved_value *reserved,
+				  const struct dm_report_field_reserved_value *frv,
+				  uint32_t field_num, const char *s, size_t len)
 {
-	const char **name = names;
+	dm_report_reserved_handler handler;
+	const char *canonical_name;
+	const char **name;
+	char *tmp_s;
+	char c;
+	int r;
+
+	name = reserved->names;
 	while (*name) {
 		if ((strlen(*name) == len) && !strncmp(*name, s, len))
 			return *name;
 		name++;
 	}
+
+	if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES) {
+		handler = (dm_report_reserved_handler) frv ? frv->value : reserved->value;
+		c = s[len];
+		tmp_s = (char *) s;
+		tmp_s[len] = '\0';
+		if ((r = handler(rh, rh->selection->mem, field_num,
+				 DM_REPORT_RESERVED_PARSE_FUZZY_NAME,
+				 tmp_s, (const void **) &canonical_name)) <= 0) {
+			if (r == -1)
+				log_error(INTERNAL_ERROR "%s reserved value handler for field %s has missing "
+					  "implementation of DM_REPORT_RESERVED_PARSE_FUZZY_NAME action",
+					  (reserved->type & DM_REPORT_FIELD_TYPE_MASK) ? "type-specific" : "field-specific",
+					   rh->fields[field_num].id);
+			else
+				log_error("Error occured while processing %s reserved value handler for field %s",
+					  (reserved->type & DM_REPORT_FIELD_TYPE_MASK) ? "type-specific" : "field-specific",
+					   rh->fields[field_num].id);
+		}
+		tmp_s[len] = c;
+		if (r && canonical_name)
+			return canonical_name;
+	}
+
 	return NULL;
 }
 
@@ -2144,6 +2178,7 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 				 struct reserved_value_wrapper *rvw)
 {
 	const struct dm_report_reserved_value *iter = implicit ? NULL : rh->reserved_values;
+	const struct dm_report_field_reserved_value *frv;
 	const char *tmp_begin, *tmp_end, *tmp_s = s;
 	const char *name = NULL;
 	char c;
@@ -2160,12 +2195,14 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 	while (iter->value) {
 		if (!(iter->type & DM_REPORT_FIELD_TYPE_MASK)) {
 			/* DM_REPORT_FIELD_TYPE_NONE - per-field reserved value */
-			if (((((const struct dm_report_field_reserved_value *) iter->value)->field_num) == field_num) &&
-			    (name = _reserved_name(iter->names, tmp_begin, tmp_end - tmp_begin)))
+			frv = (const struct dm_report_field_reserved_value *) iter->value;
+			if ((frv->field_num == field_num) && (name = _reserved_name(rh, iter, frv, field_num,
+										    tmp_begin, tmp_end - tmp_begin)))
 				break;
 		} else if (iter->type & type) {
 			/* DM_REPORT_FIELD_TYPE_* - per-type reserved value */
-			if ((name = _reserved_name(iter->names, tmp_begin, tmp_end - tmp_begin)))
+			if ((name = _reserved_name(rh, iter, NULL, field_num,
+						   tmp_begin, tmp_end - tmp_begin)))
 				break;
 		}
 		iter++;
@@ -3115,6 +3152,8 @@ static int _get_reserved_value(struct dm_report *rh, uint32_t field_num,
 			       struct reserved_value_wrapper *rvw)
 {
 	const void *tmp_value;
+	dm_report_reserved_handler handler;
+	int r;
 
 	if (!rvw->reserved) {
 		rvw->value = NULL;
@@ -3122,10 +3161,30 @@ static int _get_reserved_value(struct dm_report *rh, uint32_t field_num,
 	}
 
 	if (rvw->reserved->type & DM_REPORT_FIELD_TYPE_MASK)
+		/* type reserved value */
 		tmp_value = rvw->reserved->value;
 	else
+		/* per-field reserved value */
 		tmp_value = ((const struct dm_report_field_reserved_value *) rvw->reserved->value)->value;
 
+	if (rvw->reserved->type & (DM_REPORT_FIELD_RESERVED_VALUE_DYNAMIC_VALUE | DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES)) {
+		handler = (dm_report_reserved_handler) tmp_value;
+		if ((r = handler(rh, rh->selection->mem, field_num,
+				 DM_REPORT_RESERVED_GET_DYNAMIC_VALUE,
+				 rvw->matched_name, &tmp_value) <= 0)) {
+			if (r == -1)
+				log_error(INTERNAL_ERROR "%s reserved value handler for field %s has missing"
+					  "implementation of DM_REPORT_RESERVED_GET_DYNAMIC_VALUE action",
+					  (rvw->reserved->type) & DM_REPORT_FIELD_TYPE_MASK ? "type-specific" : "field-specific",
+					  rh->fields[field_num].id);
+			else
+				log_error("Error occured while processing %s reserved value handler for field %s",
+					  (rvw->reserved->type) & DM_REPORT_FIELD_TYPE_MASK ? "type-specific" : "field-specific",
+					  rh->fields[field_num].id);
+			return 0;
+		}
+	}
+
 	rvw->value = tmp_value;
 	return 1;
 }


