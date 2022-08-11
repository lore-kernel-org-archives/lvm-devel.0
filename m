From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:08 +0000 (GMT)
Subject: main - libdm: report: use proper JSON array for string list output in JSON_STD format
Message-ID: <20220811110608.A21F93858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73ec3c954b21522352b6f5cce9a700d6bf30ccf4
Commit:        73ec3c954b21522352b6f5cce9a700d6bf30ccf4
Parent:        fbee18f6e5c0e70c9b6cb75b67d0e15c99604135
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 4 16:14:44 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

libdm: report: use proper JSON array for string list output in JSON_STD format

In JSON format, we print string list this way:

  "key" = "item1,item2,...,itemN"

while in JSON_STD format, we print string list this way:

  "key" = ["item1","item2",...,"itemN"]
---
 device_mapper/libdm-report.c | 88 ++++++++++++++++++++++++++++++++++++++++++--
 libdm/libdm-report.c         | 88 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 168 insertions(+), 8 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index c7d4e18b9..d4cd06002 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -4569,12 +4569,21 @@ bad:
 	return 0;
 }
 
-static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
+static int _safe_repstr_output(struct dm_report *rh, const char *repstr, size_t len)
 {
 	const char *p_repstr;
+	const char *repstr_end = repstr + len;
 
 	/* Escape any JSON_QUOTE that may appear in reported string. */
-	while ((p_repstr = strstr(repstr, JSON_QUOTE))) {
+	while (1) {
+		if (len) {
+			if (!(p_repstr = memchr(repstr, JSON_QUOTE[0], repstr_end - repstr)))
+				break;
+		} else {
+			if (!(p_repstr = strstr(repstr, JSON_QUOTE)))
+				break;
+		}
+
 		if (p_repstr > repstr) {
 			if (!dm_pool_grow_object(rh->mem, repstr, p_repstr - repstr)) {
 				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
@@ -4589,7 +4598,7 @@ static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
 		repstr = p_repstr + 1;
 	}
 
-	if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
+	if (!dm_pool_grow_object(rh->mem, repstr, repstr_end - repstr)) {
 		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 		return 0;
 	}
@@ -4600,6 +4609,8 @@ static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
 static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *field)
 {
 	const char *repstr;
+	size_t list_size, i;
+	struct pos_len *pos_len;
 
 	if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
 	    !dm_pool_grow_object(rh->mem, _get_field_id(rh, field),  0) ||
@@ -4609,6 +4620,75 @@ static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *
 		return 0;
 	}
 
+	if (field->props->flags & DM_REPORT_FIELD_TYPE_STRING_LIST) {
+		if (!_is_json_std_report(rh)) {
+
+			/* string list in JSON - report whole list as simple string in quotes */
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+
+			if (!_safe_repstr_output(rh, field->report_string, 0))
+				return_0;
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+
+			return 1;
+		}
+
+		/* string list in JSON_STD - report list as proper JSON array */
+
+		if (!dm_pool_grow_object(rh->mem, JSON_ARRAY_START, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+
+		if (*field->report_string != 0) {
+			pos_len = (struct pos_len *) (field->report_string +
+				  ((struct str_list_sort_value *) field->sort_value)->items[0].len + 1);
+			list_size = pos_len->pos;
+		} else
+			list_size = 0;
+
+		for (i = 0; i < list_size; i++) {
+			pos_len++;
+
+			if (i != 0) {
+				if (!dm_pool_grow_object(rh->mem, JSON_SEPARATOR, 1)) {
+					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+					return 0;
+				}
+			}
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+
+			if (!_safe_repstr_output(rh, field->report_string + pos_len->pos, pos_len->len))
+				return_0;
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+		}
+
+		if (!dm_pool_grow_object(rh->mem, JSON_ARRAY_END, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+
+		return 1;
+	}
+
+	/* all other types than string list - handle both JSON and JSON_STD */
+
 	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
 		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
 			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
@@ -4621,7 +4701,7 @@ static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *
 	else
 		repstr = field->report_string;
 
-	if (!_safe_repstr_output(rh, repstr))
+	if (!_safe_repstr_output(rh, repstr, 0))
 		return_0;
 
 	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 848961ced..fc71ca5df 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4568,12 +4568,21 @@ bad:
 	return 0;
 }
 
-static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
+static int _safe_repstr_output(struct dm_report *rh, const char *repstr, size_t len)
 {
 	const char *p_repstr;
+	const char *repstr_end = repstr + len;
 
 	/* Escape any JSON_QUOTE that may appear in reported string. */
-	while ((p_repstr = strstr(repstr, JSON_QUOTE))) {
+	while (1) {
+		if (len) {
+			if (!(p_repstr = memchr(repstr, JSON_QUOTE[0], repstr_end - repstr)))
+				break;
+		} else {
+			if (!(p_repstr = strstr(repstr, JSON_QUOTE)))
+				break;
+		}
+
 		if (p_repstr > repstr) {
 			if (!dm_pool_grow_object(rh->mem, repstr, p_repstr - repstr)) {
 				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
@@ -4588,7 +4597,7 @@ static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
 		repstr = p_repstr + 1;
 	}
 
-	if (!dm_pool_grow_object(rh->mem, repstr, 0)) {
+	if (!dm_pool_grow_object(rh->mem, repstr, repstr_end - repstr)) {
 		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 		return 0;
 	}
@@ -4599,6 +4608,8 @@ static int _safe_repstr_output(struct dm_report *rh, const char *repstr)
 static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *field)
 {
 	const char *repstr;
+	size_t list_size, i;
+	struct pos_len *pos_len;
 
 	if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
 	    !dm_pool_grow_object(rh->mem, _get_field_id(rh, field),  0) ||
@@ -4608,6 +4619,75 @@ static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *
 		return 0;
 	}
 
+	if (field->props->flags & DM_REPORT_FIELD_TYPE_STRING_LIST) {
+		if (!_is_json_std_report(rh)) {
+
+			/* string list in JSON - report whole list as simple string in quotes */
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+
+			if (!_safe_repstr_output(rh, field->report_string, 0))
+				return_0;
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+
+			return 1;
+		}
+
+		/* string list in JSON_STD - report list as proper JSON array */
+
+		if (!dm_pool_grow_object(rh->mem, JSON_ARRAY_START, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+
+		if (*field->report_string != 0) {
+			pos_len = (struct pos_len *) (field->report_string +
+				  ((struct str_list_sort_value *) field->sort_value)->items[0].len + 1);
+			list_size = pos_len->pos;
+		} else
+			list_size = 0;
+
+		for (i = 0; i < list_size; i++) {
+			pos_len++;
+
+			if (i != 0) {
+				if (!dm_pool_grow_object(rh->mem, JSON_SEPARATOR, 1)) {
+					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+					return 0;
+				}
+			}
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+
+			if (!_safe_repstr_output(rh, field->report_string + pos_len->pos, pos_len->len))
+				return_0;
+
+			if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				return 0;
+			}
+		}
+
+		if (!dm_pool_grow_object(rh->mem, JSON_ARRAY_END, 1)) {
+			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+			return 0;
+		}
+
+		return 1;
+	}
+
+	/* all other types than string list - handle both JSON and JSON_STD */
+
 	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {
 		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
 			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
@@ -4620,7 +4700,7 @@ static int _output_field_json_fmt(struct dm_report *rh, struct dm_report_field *
 	else
 		repstr = field->report_string;
 
-	if (!_safe_repstr_output(rh, repstr))
+	if (!_safe_repstr_output(rh, repstr, 0))
 		return_0;
 
 	if (!(_is_json_std_report(rh) && _is_pure_numeric_field(field))) {

