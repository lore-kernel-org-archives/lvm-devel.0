From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:24 +0000 (UTC)
Subject: master - report: adapt selection code to recognize per-field reserved values
Message-ID: <20140704140024.F0E9F60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0956fd230fea550707acb2889223438996102de4
Commit:        0956fd230fea550707acb2889223438996102de4
Parent:        da545ce3b471e76b3ebcfcb5528118d8dd9264df
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 4 11:21:38 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:50:50 2014 +0200

report: adapt selection code to recognize per-field reserved values

In contrast to per-type reserved values that are applied for all fields
of that type, per-field reserved values are only applied for concrete
field only.

Also add 'struct dm_report_field_reserved_value' to libdm for per-field
reserved value definition. This is defined by field number (an index
in the 'fields' array which is given for the dm_report_init_with_selection
function during report initialization) and the value to use for any
of the specified reserved names.
---
 libdm/libdevmapper.h |   27 ++++++++++++
 libdm/libdm-report.c |  112 +++++++++++++++++++++++++++++++++-----------------
 2 files changed, 101 insertions(+), 38 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ad504da..dc3da78 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1633,6 +1633,7 @@ struct dm_report_field;
 #define DM_REPORT_FIELD_ALIGN_LEFT		0x00000001
 #define DM_REPORT_FIELD_ALIGN_RIGHT		0x00000002
 #define DM_REPORT_FIELD_TYPE_MASK		0x00000FF0
+#define DM_REPORT_FIELD_TYPE_NONE		0x00000000
 #define DM_REPORT_FIELD_TYPE_STRING		0x00000010
 #define DM_REPORT_FIELD_TYPE_NUMBER		0x00000020
 #define DM_REPORT_FIELD_TYPE_SIZE		0x00000040
@@ -1658,9 +1659,35 @@ struct dm_report_field_type {
 	const char *desc;	/* description of the field */
 };
 
+/*
+ * Per-field reserved value.
+ */
+struct dm_report_field_reserved_value {
+	/* field_num is the position of the field in 'fields'
+	   array passed to dm_report_init_with_selection */
+	uint32_t field_num;
+	/* the value is of the same type as the field
+	   identified by field_num */
+	const void *value;
+};
+
+/*
+ * Reserved value is a 'value' that is used directly if any of the 'names' is hit.
+ *
+ * If type is any of DM_REPORT_FIELD_TYPE_*, the reserved value is recognized
+ * for all fields of that type.
+ *
+ * If type is DM_REPORT_FIELD_TYPE_NONE, the reserved value is recognized
+ * for the exact field specified - hence the type of the value is automatically
+ * the same as the type of the field itself.
+ *
+ * The array of reserved values is used to initialize reporting with
+ * selection enabled (see also dm_report_init_with_selection function).
+ */
 struct dm_report_reserved_value {
 	const unsigned type;		/* DM_REPORT_FIELD_TYPE_* */
 	const void *value;		/* reserved value:
+						struct dm_report_field_reserved_value for DM_REPORT_FIELD_TYPE_NONE
 						uint64_t for DM_REPORT_FIELD_TYPE_NUMBER
 						uint64_t for DM_REPORT_FIELD_TYPE_SIZE (number of 512-byte sectors)
 						uint64_t for DM_REPORT_FIELD_TYPE_PERCENT
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 00c3d3f..ad89cf2 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1599,6 +1599,18 @@ static int _tok_op_cmp(const char *s, const char **end)
 	return _tok_op(_op_cmp, s, end, 0);
 }
 
+static char _get_and_skip_quote_char(char const **s)
+{
+	char c = 0;
+
+	if (**s == '"' || **s == '\'') {
+		c = **s;
+		(*s)++;
+	}
+
+	return c;
+}
+
  /*
   *
   * Input:
@@ -1689,38 +1701,62 @@ static const char *_tok_value_string(const char *s,
 	return s;
 }
 
+static const char *_reserved_name(const char **names, const char *s, size_t len)
+{
+	const char **name = names;
+	while (*name) {
+		if ((strlen(*name) == len) && !strncmp(*name, s, len))
+			return *name;
+		name++;
+	}
+	return NULL;
+}
+
 /*
  * Used to replace a string representation of the reserved value
  * found in selection with the exact reserved value of certain type.
  */
-static const char *_get_reserved_value(struct dm_report *rh, unsigned type,
-				       const char *s, const char **begin, const char **end,
-				       const struct dm_report_reserved_value **reserved)
-{
-	const struct dm_report_reserved_value *iter = rh->reserved_values;
-	const char **name;
+static const char *_get_reserved(struct dm_report *rh, unsigned type,
+				 uint32_t field_num, int implicit,
+				 const char *s, const char **begin, const char **end,
+				 const struct dm_report_reserved_value **reserved)
+{
+	const struct dm_report_reserved_value *iter = implicit ? NULL : rh->reserved_values;
+	const char *tmp_begin, *tmp_end, *tmp_s = s;
+	const char *name = NULL;
+	char c;
 
 	*reserved = NULL;
 
 	if (!iter)
 		return s;
 
-	while (iter->type) {
-		if (iter->type & type) {
-			name = iter->names;
-			while (*name) {
-				if (!strcmp(*name, s)) {
-					*begin = s;
-					*end = s += strlen(*name);
-					*reserved = iter;
-					return s;
-				}
-				name++;
-			}
+	c = _get_and_skip_quote_char(&tmp_s);
+	if (!(tmp_s = _tok_value_string(tmp_s, &tmp_begin, &tmp_end, c, SEL_AND | SEL_OR | SEL_PRECEDENCE_PE, NULL)))
+		return s;
+
+	while (iter->value) {
+		if (!iter->type) {
+			/* DM_REPORT_FIELD_TYPE_NONE - per-field reserved value */
+			if (((((const struct dm_report_field_reserved_value *) iter->value)->field_num) == field_num) &&
+			    (name = _reserved_name(iter->names, tmp_begin, tmp_end - tmp_begin)))
+				break;
+		} else if (iter->type & type) {
+			/* DM_REPORT_FIELD_TYPE_* - per-type reserved value */
+			if ((name = _reserved_name(iter->names, tmp_begin, tmp_end - tmp_begin)))
+				break;
 		}
 		iter++;
 	}
 
+	if (name) {
+		/* found! */
+		*begin = tmp_begin;
+		*end = tmp_end;
+		s = tmp_s;
+		*reserved = iter;
+	}
+
 	return s;
 }
 
@@ -1880,18 +1916,6 @@ static int _add_item_to_string_list(struct dm_pool *mem, const char *begin,
 	return 1;
 }
 
-static char _get_and_skip_quote_char(char const **s)
-{
-	char c = 0;
-
-	if (**s == '"' || **s == '\'') {
-		c = **s;
-		(*s)++;
-	}
-
-	return c;
-}
-
 /*
  * Input:
  *   ft              - field type for which the value is parsed
@@ -2033,8 +2057,10 @@ bad:
  */
 static const char *_tok_value(struct dm_report *rh,
 			      const struct dm_report_field_type *ft,
-			      const char *s, const char **begin,
-			      const char **end, uint32_t *flags,
+			      uint32_t field_num, int implicit,
+			      const char *s,
+			      const char **begin, const char **end,
+			      uint32_t *flags,
 			      const struct dm_report_reserved_value **reserved,
 			      struct dm_pool *mem, void *custom)
 {
@@ -2046,7 +2072,7 @@ static const char *_tok_value(struct dm_report *rh,
 
 	s = _skip_space(s);
 
-	s = _get_reserved_value(rh, expected_type, s, begin, end, reserved);
+	s = _get_reserved(rh, expected_type, field_num, implicit, s, begin, end, reserved);
 	if (*reserved) {
 		*flags |= expected_type;
 		return s;
@@ -2149,6 +2175,14 @@ static const char *_tok_field_name(const char *s,
 	return s;
 }
 
+static const void *_get_reserved_value(const struct dm_report_reserved_value *reserved)
+{
+	if (reserved->type)
+		return reserved->value;
+	else
+		return ((const struct dm_report_field_reserved_value *) reserved->value)->value;
+}
+
 static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       uint32_t field_num,
 						       int implicit,
@@ -2229,7 +2263,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		switch (flags & DM_REPORT_FIELD_TYPE_MASK) {
 			case DM_REPORT_FIELD_TYPE_STRING:
 				if (reserved) {
-					fs->v.s = (const char *) reserved->value;
+					fs->v.s = (const char *) _get_reserved_value(reserved);
 					dm_pool_free(rh->mem, s);
 				} else {
 					fs->v.s = s;
@@ -2241,7 +2275,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_NUMBER:
 				if (reserved)
-					fs->v.i = *(uint64_t *) reserved->value;
+					fs->v.i = *(uint64_t *) _get_reserved_value(reserved);
 				else {
 					if (((fs->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
 						 (errno == ERANGE)) {
@@ -2257,7 +2291,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
 				if (reserved)
-					fs->v.d = (double) * (uint64_t *) reserved->value;
+					fs->v.d = (double) * (uint64_t *) _get_reserved_value(reserved);
 				else {
 					fs->v.d = strtod(s, NULL);
 					if (errno == ERANGE) {
@@ -2276,7 +2310,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 				break;
 			case DM_REPORT_FIELD_TYPE_PERCENT:
 				if (reserved)
-					fs->v.i = *(uint64_t *) reserved->value;
+					fs->v.i = *(uint64_t *) _get_reserved_value(reserved);
 				else {
 					fs->v.d = strtod(s, NULL);
 					if ((errno == ERANGE) || (fs->v.d < 0) || (fs->v.d > 100)) {
@@ -2508,7 +2542,9 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 			custom = &str_list;
 		else
 			custom = NULL;
-		if (!(last = _tok_value(rh, ft, last, &vs, &ve, &flags, &reserved, rh->mem, custom)))
+		if (!(last = _tok_value(rh, ft, field_num, implicit,
+					last, &vs, &ve, &flags,
+					&reserved, rh->mem, custom)))
 			goto_bad;
 	}
 


