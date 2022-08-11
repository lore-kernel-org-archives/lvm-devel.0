From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:07 +0000 (GMT)
Subject: main - libdm: report: separate basic and JSON+JSON_STD format in _output_field
Message-ID: <20220811110607.82213385828A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbee18f6e5c0e70c9b6cb75b67d0e15c99604135
Commit:        fbee18f6e5c0e70c9b6cb75b67d0e15c99604135
Parent:        31cd8346ae92fcc32ce4f2f60f7962e620a7b12f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 29 21:59:12 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

libdm: report: separate basic and JSON+JSON_STD format in _output_field

Use separate functions to handle basic and JSON+JSON_STD format.
It's clearer this way than interleaving both in the same function.
---
 device_mapper/libdm-report.c | 165 ++++++++++++++++++++++++-------------------
 libdm/libdm-report.c         | 165 ++++++++++++++++++++++++-------------------
 2 files changed, 188 insertions(+), 142 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index aab7bdd63..c7d4e18b9 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -4462,38 +4462,24 @@ static int _is_pure_numeric_field(struct dm_report_field *field)
 	return field->props->flags & (DM_REPORT_FIELD_TYPE_NUMBER | DM_REPORT_FIELD_TYPE_PERCENT);
 }
 
-/*
- * Produce report output
- */
-static int _output_field(struct dm_report *rh, struct dm_report_field *field)
+static const char *_get_field_id(struct dm_report *rh, struct dm_report_field *field)
 {
 	const struct dm_report_field_type *fields = field->props->implicit ? _implicit_report_fields
 									   : rh->fields;
+
+	return fields[field->props->field_num].id;
+}
+
+static int _output_field_basic_fmt(struct dm_report *rh, struct dm_report_field *field)
+{
 	char *field_id;
 	int32_t width;
 	uint32_t align;
-	const char *repstr;
-	const char *p1_repstr, *p2_repstr;
 	char *buf = NULL;
 	size_t buf_size = 0;
 
-	if (_is_json_report(rh)) {
-		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
-		    !dm_pool_grow_object(rh->mem, fields[field->props->field_num].id, 0) ||
-		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
-		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1)) {
-			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			goto bad;
-		}
-
-		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
-			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				goto bad;
-			}
-		}
-	} else if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
-		if (!(field_id = strdup(fields[field->props->field_num].id))) {
+	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
+		if (!(field_id = strdup(_get_field_id(rh, field)))) {
 			log_error("dm_report: Failed to copy field name");
 			return 0;
 		}
@@ -4524,48 +4510,14 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	}
 
-	if (_is_json_std_report(rh) && _is_pure_numeric_field(field) && !*field->report_string)
-		repstr = JSON_NULL;
-	else
-		repstr = field->report_string;
-
-	width = field->props->width;
-
-	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
-		if (_is_json_report(rh)) {
-			/* Escape any JSON_QUOTE that may appear in reported string. */
-			p1_repstr = repstr;
-			while ((p2_repstr = strstr(p1_repstr, JSON_QUOTE))) {
-				if (p2_repstr > p1_repstr) {
-					if (!dm_pool_grow_object(rh->mem, p1_repstr, p2_repstr - p1_repstr)) {
-						log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-						return 0;
-					}
-				}
-				if (!dm_pool_grow_object(rh->mem, JSON_ESCAPE_CHAR, 1) ||
-				    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-					return 0;
-				}
-				p1_repstr = p2_repstr + 1;
-			}
-
-			if (!dm_pool_grow_object(rh->mem, p1_repstr, 0)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				return 0;
-			}
-		} else {
-			if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				return 0;
-			}
-		}
-	} else {
+	if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
 		if (!(align = field->props->flags & DM_REPORT_FIELD_ALIGN_MASK))
 			align = ((field->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ||
-				 (field->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) ? 
+				 (field->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) ?
 				DM_REPORT_FIELD_ALIGN_RIGHT : DM_REPORT_FIELD_ALIGN_LEFT;
 
+		width = field->props->width;
+
 		/* Including trailing '\0'! */
 		buf_size = width + 1;
 		if (!(buf = malloc(buf_size))) {
@@ -4575,7 +4527,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 
 		if (align & DM_REPORT_FIELD_ALIGN_LEFT) {
 			if (dm_snprintf(buf, buf_size, "%-*.*s",
-					 width, width, repstr) < 0) {
+					 width, width, field->report_string) < 0) {
 				log_error("dm_report: left-aligned snprintf() failed");
 				goto bad;
 			}
@@ -4585,7 +4537,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 			}
 		} else if (align & DM_REPORT_FIELD_ALIGN_RIGHT) {
 			if (dm_snprintf(buf, buf_size, "%*.*s",
-					 width, width, repstr) < 0) {
+					 width, width, field->report_string) < 0) {
 				log_error("dm_report: right-aligned snprintf() failed");
 				goto bad;
 			}
@@ -4594,6 +4546,11 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 				goto bad;
 			}
 		}
+	} else {
+		if (!dm_pool_grow_object(rh->mem, field->report_string, 0)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
 	}
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
@@ -4603,23 +4560,89 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 				goto bad;
 			}
 		}
-	} else if (_is_json_report(rh)) {
-		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
-			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				goto bad;
-			}
-		}
 	}
 
 	free(buf);
 	return 1;
-
 bad:
 	free(buf);
 	return 0;
 }
 
+static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
+{
+	const char *p_repstr;
+
+	/* Escape any JSON_QUOTE that may appear in reported string. */
+	while ((p_repstr = strstr(repstr, JSON_QUOTE))) {
+		if (p_repstr > repstr) {
+			if (!dm_pool_grow_object(rh->mem, repstr, p_repstr - repstr)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+		}
+		if (!dm_pool_grow_object(rh->mem, JSON_ESCAPE_CHAR, 1) ||
+		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+		repstr = p_repstr + 1;
+	}
+
+	if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
+		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *field)
+{
+	const char *repstr;
+
+	if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
+	    !dm_pool_grow_object(rh->mem, _get_field_id(rh, field),  0) ||
+	    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
+	    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1)) {
+		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+		return 0;
+	}
+
+	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+	}
+
+	if (_is_json_std_report(rh) && _is_pure_numeric_field(field) && !*field->report_string)
+		repstr = JSON_NULL;
+	else
+		repstr = field->report_string;
+
+	if (!_safe_repstr_output(rh, repstr))
+		return_0;
+
+	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Produce report output
+ */
+static int _output_field(struct dm_report *rh, struct dm_report_field *field)
+{
+	return _is_json_report(rh) ? _output_field_json_fmt(rh, field)
+				   : _output_field_basic_fmt(rh, field);
+}
+
 static void _destroy_rows(struct dm_report *rh)
 {
 	/*
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9fac341a4..848961ced 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4461,38 +4461,24 @@ static int _is_pure_numeric_field(struct dm_report_field *field)
 	return field->props->flags & (DM_REPORT_FIELD_TYPE_NUMBER | DM_REPORT_FIELD_TYPE_PERCENT);
 }
 
-/*
- * Produce report output
- */
-static int _output_field(struct dm_report *rh, struct dm_report_field *field)
+static const char *_get_field_id(struct dm_report *rh, struct dm_report_field *field)
 {
 	const struct dm_report_field_type *fields = field->props->implicit ? _implicit_report_fields
 									   : rh->fields;
+
+	return fields[field->props->field_num].id;
+}
+
+static int _output_field_basic_fmt(struct dm_report *rh, struct dm_report_field *field)
+{
 	char *field_id;
 	int32_t width;
 	uint32_t align;
-	const char *repstr;
-	const char *p1_repstr, *p2_repstr;
 	char *buf = NULL;
 	size_t buf_size = 0;
 
-	if (_is_json_report(rh)) {
-		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
-		    !dm_pool_grow_object(rh->mem, fields[field->props->field_num].id, 0) ||
-		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
-		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1)) {
-			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-			goto bad;
-		}
-
-		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
-			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				goto bad;
-			}
-		}
-	} else if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
-		if (!(field_id = dm_strdup(fields[field->props->field_num].id))) {
+	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
+		if (!(field_id = strdup(_get_field_id(rh, field)))) {
 			log_error("dm_report: Failed to copy field name");
 			return 0;
 		}
@@ -4523,48 +4509,14 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	}
 
-	if (_is_json_std_report(rh) && _is_pure_numeric_field(field) && !*field->report_string)
-		repstr = JSON_NULL;
-	else
-		repstr = field->report_string;
-
-	width = field->props->width;
-
-	if (!(rh->flags & DM_REPORT_OUTPUT_ALIGNED)) {
-		if (_is_json_report(rh)) {
-			/* Escape any JSON_QUOTE that may appear in reported string. */
-			p1_repstr = repstr;
-			while ((p2_repstr = strstr(p1_repstr, JSON_QUOTE))) {
-				if (p2_repstr > p1_repstr) {
-					if (!dm_pool_grow_object(rh->mem, p1_repstr, p2_repstr - p1_repstr)) {
-						log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-						return 0;
-					}
-				}
-				if (!dm_pool_grow_object(rh->mem, JSON_ESCAPE_CHAR, 1) ||
-				    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-					return 0;
-				}
-				p1_repstr = p2_repstr + 1;
-			}
-
-			if (!dm_pool_grow_object(rh->mem, p1_repstr, 0)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				return 0;
-			}
-		} else {
-			if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				return 0;
-			}
-		}
-	} else {
+	if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
 		if (!(align = field->props->flags & DM_REPORT_FIELD_ALIGN_MASK))
 			align = ((field->props->flags & DM_REPORT_FIELD_TYPE_NUMBER) ||
-				 (field->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) ? 
+				 (field->props->flags & DM_REPORT_FIELD_TYPE_SIZE)) ?
 				DM_REPORT_FIELD_ALIGN_RIGHT : DM_REPORT_FIELD_ALIGN_LEFT;
 
+		width = field->props->width;
+
 		/* Including trailing '\0'! */
 		buf_size = width + 1;
 		if (!(buf = dm_malloc(buf_size))) {
@@ -4574,7 +4526,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 
 		if (align & DM_REPORT_FIELD_ALIGN_LEFT) {
 			if (dm_snprintf(buf, buf_size, "%-*.*s",
-					 width, width, repstr) < 0) {
+					 width, width, field->report_string) < 0) {
 				log_error("dm_report: left-aligned snprintf() failed");
 				goto bad;
 			}
@@ -4584,7 +4536,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 			}
 		} else if (align & DM_REPORT_FIELD_ALIGN_RIGHT) {
 			if (dm_snprintf(buf, buf_size, "%*.*s",
-					 width, width, repstr) < 0) {
+					 width, width, field->report_string) < 0) {
 				log_error("dm_report: right-aligned snprintf() failed");
 				goto bad;
 			}
@@ -4593,6 +4545,11 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 				goto bad;
 			}
 		}
+	} else {
+		if (!dm_pool_grow_object(rh->mem, field->report_string, 0)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
 	}
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
@@ -4602,23 +4559,89 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 				goto bad;
 			}
 		}
-	} else if (_is_json_report(rh)) {
-		if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
-			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
-				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-				goto bad;
-			}
-		}
 	}
 
 	dm_free(buf);
 	return 1;
-
 bad:
 	dm_free(buf);
 	return 0;
 }
 
+static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
+{
+	const char *p_repstr;
+
+	/* Escape any JSON_QUOTE that may appear in reported string. */
+	while ((p_repstr = strstr(repstr, JSON_QUOTE))) {
+		if (p_repstr > repstr) {
+			if (!dm_pool_grow_object(rh->mem, repstr, p_repstr - repstr)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+		}
+		if (!dm_pool_grow_object(rh->mem, JSON_ESCAPE_CHAR, 1) ||
+		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+		repstr = p_repstr + 1;
+	}
+
+	if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
+		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *field)
+{
+	const char *repstr;
+
+	if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
+	    !dm_pool_grow_object(rh->mem, _get_field_id(rh, field),  0) ||
+	    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
+	    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1)) {
+		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+		return 0;
+	}
+
+	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+	}
+
+	if (_is_json_std_report(rh) && _is_pure_numeric_field(field) && !*field->report_string)
+		repstr = JSON_NULL;
+	else
+		repstr = field->report_string;
+
+	if (!_safe_repstr_output(rh, repstr))
+		return_0;
+
+	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
+		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * Produce report output
+ */
+static int _output_field(struct dm_report *rh, struct dm_report_field *field)
+{
+	return _is_json_report(rh) ? _output_field_json_fmt(rh, field)
+				   : _output_field_basic_fmt(rh, field);
+}
+
 static void _destroy_rows(struct dm_report *rh)
 {
 	/*

