From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:16 +0000 (UTC)
Subject: master - libdm: report: implement DM_REPORT_GROUP_JSON for JSON report output
Message-ID: <20160620094016.E66AB60FCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=094fce37765964a9c3b32d1473e75c7d121eace1
Commit:        094fce37765964a9c3b32d1473e75c7d121eace1
Parent:        230b7ff0f6c844bde2185baa9db63961baefb3d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 2 14:21:40 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 10:42:26 2016 +0200

libdm: report: implement DM_REPORT_GROUP_JSON for JSON report output

This patch introduces DM_REPORT_GROUP_JSON report group type. When using
this group type and when pushing a report to such a group, these flags
are automatically unset:

   DM_REPORT_OUTPUT_ALIGNED
   DM_REPORT_OUTPUT_HEADINGS
   DM_REPORT_OUTPUT_COLUMNS_AS_ROWS

...and this flag is set:

   DM_REPORT_OUTPUT_BUFFERED

The whole group is encapsulated in { } for the outermost JSON object
and then each report is reported on output as array of objects where
each object is the row from report:

  {
     "report_name1": [
         {field1="value", field2="value",...},
         {field1="value", field2="value",...}
         ...
     ],
     "report_name2": [
         {field1="value", field2="value",...},
         {field1="value", field2="value",...}
         ...
     ]
     ...
  }
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    3 +-
 libdm/libdm-report.c |  241 +++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 233 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9e1985a..da36f49 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Introduce DM_REPORT_GROUP_JSON for report group with JSON output format.
   Introduce DM_REPORT_GROUP_BASIC for report group with basic report output.
   Introduce DM_REPORT_GROUP_SINGLE for report group having single report only.
   Add dm_report_group_{create,push,pop,destroy} to support report grouping.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fbe4322..cad79dd 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2710,7 +2710,8 @@ struct dm_report_group;
 
 typedef enum {
 	DM_REPORT_GROUP_SINGLE,
-	DM_REPORT_GROUP_BASIC
+	DM_REPORT_GROUP_BASIC,
+	DM_REPORT_GROUP_JSON
 } dm_report_group_type_t;
 
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index d73598f..485bbdf 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4203,6 +4203,16 @@ static int _sort_rows(struct dm_report *rh)
 #define STANDARD_QUOTE		"\'"
 #define STANDARD_PAIR		"="
 
+#define JSON_INDENT_UNIT       4
+#define JSON_SPACE             " "
+#define JSON_QUOTE             "\""
+#define JSON_PAIR              ":"
+#define JSON_SEPARATOR         ","
+#define JSON_OBJECT_START      "{"
+#define JSON_OBJECT_END        "}"
+#define JSON_ARRAY_START       "["
+#define JSON_ARRAY_END         "]"
+
 #define UNABLE_TO_EXTEND_OUTPUT_LINE_MSG "dm_report: Unable to extend output line"
 
 static int _is_basic_report(struct dm_report *rh)
@@ -4211,6 +4221,12 @@ static int _is_basic_report(struct dm_report *rh)
 	       (rh->group_item->group->type == DM_REPORT_GROUP_BASIC);
 }
 
+static int _is_json_report(struct dm_report *rh)
+{
+	return rh->group_item &&
+	       (rh->group_item->group->type == DM_REPORT_GROUP_JSON);
+}
+
 /*
  * Produce report output
  */
@@ -4225,7 +4241,16 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	char *buf = NULL;
 	size_t buf_size = 0;
 
-	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
+	if (_is_json_report(rh)) {
+		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
+		    !dm_pool_grow_object(rh->mem, fields[field->props->field_num].id, 0) ||
+		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1) ||
+		    !dm_pool_grow_object(rh->mem, JSON_PAIR, 1) ||
+		    !dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
+			log_error("dm_report: Unable to extend output line");
+			return 0;
+		}
+	} else if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
 		if (!(field_id = dm_strdup(fields[field->props->field_num].id))) {
 			log_error("dm_report: Failed to copy field name");
 			return 0;
@@ -4300,12 +4325,19 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 		}
 	}
 
-	if ((rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) &&
-	    !(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED))
-		if (!dm_pool_grow_object(rh->mem, STANDARD_QUOTE, 1)) {
+	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
+		if (!(rh->flags & DM_REPORT_OUTPUT_FIELD_UNQUOTED)) {
+			if (!dm_pool_grow_object(rh->mem, STANDARD_QUOTE, 1)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
+		}
+	} else if (_is_json_report(rh)) {
+		if (!dm_pool_grow_object(rh->mem, JSON_QUOTE, 1)) {
 			log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
 			goto bad;
 		}
+	}
 
 	dm_free(buf);
 	return 1;
@@ -4407,39 +4439,78 @@ static int _output_as_columns(struct dm_report *rh)
 	struct dm_list *fh, *rowh, *ftmp, *rtmp;
 	struct row *row = NULL;
 	struct dm_report_field *field;
+	struct dm_list *last_row;
+	int do_field_delim;
+	char *line;
 
 	/* If headings not printed yet, calculate field widths and print them */
 	if (!(rh->flags & RH_HEADINGS_PRINTED))
 		_report_headings(rh);
 
 	/* Print and clear buffer */
+	last_row = dm_list_last(&rh->rows);
 	dm_list_iterate_safe(rowh, rtmp, &rh->rows) {
 		if (!dm_pool_begin_object(rh->mem, 512)) {
 			log_error("dm_report: Unable to allocate output line");
 			return 0;
 		}
+
+		if (_is_json_report(rh)) {
+			if (!dm_pool_grow_object(rh->mem, JSON_OBJECT_START, 0)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
+		}
+
 		row = dm_list_item(rowh, struct row);
+		do_field_delim = 0;
+
 		dm_list_iterate_safe(fh, ftmp, &row->fields) {
 			field = dm_list_item(fh, struct dm_report_field);
 			if (field->props->flags & FLD_HIDDEN)
 				continue;
 
+			if (do_field_delim) {
+				if (_is_json_report(rh)) {
+					if (!dm_pool_grow_object(rh->mem, JSON_SEPARATOR, 0) ||
+					    !dm_pool_grow_object(rh->mem, JSON_SPACE, 0)) {
+						log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+						goto bad;
+					}
+				} else {
+					if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
+						log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+						goto bad;
+					}
+				}
+			} else
+				do_field_delim = 1;
+
 			if (!_output_field(rh, field))
 				goto bad;
 
-			if (!dm_list_end(&row->fields, fh))
-				if (!dm_pool_grow_object(rh->mem, rh->separator, 0)) {
-					log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
-					goto bad;
-				}
-
 			dm_list_del(&field->list);
 		}
+
+		if (_is_json_report(rh)) {
+			if (!dm_pool_grow_object(rh->mem, JSON_OBJECT_END, 0)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
+			if (rowh != last_row &&
+			    !dm_pool_grow_object(rh->mem, JSON_SEPARATOR, 0)) {
+				log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+				goto bad;
+			}
+		}
+
 		if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
 			log_error("dm_report: Unable to terminate output line");
 			goto bad;
 		}
-		log_print("%s", (char *) dm_pool_end_object(rh->mem));
+
+		line = (char *) dm_pool_end_object(rh->mem);
+		log_print("%*s", rh->group_item ? rh->group_item->group->indent + (int) strlen(line) : 0, line);
 		dm_list_del(&row->list);
 	}
 
@@ -4469,6 +4540,70 @@ static struct report_group_item *_get_topmost_report_group_item(struct dm_report
 	return item;
 }
 
+static int _json_output_array_start(struct dm_pool *mem, struct report_group_item *item)
+{
+	const char *name = (const char *) item->data;
+	char *output;
+
+	if (!dm_pool_begin_object(mem, 32)) {
+		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+		return 0;
+	}
+
+	if (!dm_pool_grow_object(mem, JSON_QUOTE, 1) ||
+	    !dm_pool_grow_object(mem, name, 0) ||
+	    !dm_pool_grow_object(mem, JSON_QUOTE JSON_PAIR JSON_SPACE JSON_ARRAY_START, 0) ||
+	    !dm_pool_grow_object(mem, "\0", 1) ||
+	    !(output = dm_pool_end_object(mem))) {
+		log_error(UNABLE_TO_EXTEND_OUTPUT_LINE_MSG);
+		goto bad;
+	}
+
+	if (item->parent->store.finished_count > 0)
+		log_print("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
+
+	if (item->parent->parent && item->parent->data) {
+		log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
+		item->group->indent += JSON_INDENT_UNIT;
+	}
+
+	log_print("%*s", item->group->indent + (int) strlen(output), output);
+	item->group->indent += JSON_INDENT_UNIT;
+
+	dm_pool_free(mem, output);
+	return 1;
+bad:
+	dm_pool_abandon_object(mem);
+	return 0;
+}
+
+static int _prepare_json_report_output(struct dm_report *rh)
+{
+	if (rh->group_item->output_done && dm_list_empty(&rh->rows))
+		return 1;
+
+	/*
+	 * If this report is in JSON group, it must be at the
+	 * top of the stack of reports so the output from
+	 * different reports do not interleave with each other.
+	 */
+	if (_get_topmost_report_group_item(rh->group_item->group) != rh->group_item) {
+		log_error("dm_report: dm_report_output: interleaved reports detected for JSON output");
+		return 0;
+	}
+
+	if (rh->group_item->needs_closing) {
+		log_error("dm_report: dm_report_output: unfinished JSON output detected");
+		return 0;
+	}
+
+	if (!_json_output_array_start(rh->mem, rh->group_item))
+		return_0;
+
+	rh->group_item->needs_closing = 1;
+	return 1;
+}
+
 static int _print_basic_report_header(struct dm_report *rh)
 {
 	const char *report_name = (const char *) rh->group_item->data;
@@ -4493,6 +4628,10 @@ int dm_report_output(struct dm_report *rh)
 {
 	int r = 0;
 
+	if (_is_json_report(rh) &&
+	    !_prepare_json_report_output(rh))
+		return_0;
+
 	if (dm_list_empty(&rh->rows)) {
 		r = 1;
 		goto out;
@@ -4524,6 +4663,13 @@ static int _report_group_create_basic(struct dm_report_group *group)
 	return 1;
 }
 
+static int _report_group_create_json(struct dm_report_group *group)
+{
+	log_print(JSON_OBJECT_START);
+	group->indent += JSON_INDENT_UNIT;
+	return 1;
+}
+
 struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void *data)
 {
 	struct dm_report_group *group;
@@ -4560,6 +4706,10 @@ struct dm_report_group *dm_report_group_create(dm_report_group_type_t type, void
 			if (!_report_group_create_basic(group))
 				goto_bad;
 			break;
+		case DM_REPORT_GROUP_JSON:
+			if (!_report_group_create_json(group))
+				goto_bad;
+			break;
 		default:
 			goto_bad;
 	}
@@ -4597,6 +4747,40 @@ static int _report_group_push_basic(struct report_group_item *item, const char *
 	return 1;
 }
 
+static int _report_group_push_json(struct report_group_item *item, const char *name)
+{
+	if (name && !(item->data = dm_pool_strdup(item->group->mem, name))) {
+		log_error("dm_report: failed to duplicate json item name");
+		return 0;
+	}
+
+	if (item->report) {
+		item->report->flags &= ~(DM_REPORT_OUTPUT_ALIGNED |
+					 DM_REPORT_OUTPUT_HEADINGS |
+					 DM_REPORT_OUTPUT_COLUMNS_AS_ROWS);
+		item->report->flags |= DM_REPORT_OUTPUT_BUFFERED;
+	} else {
+		if (name) {
+			if (!_json_output_array_start(item->group->mem, item))
+				return_0;
+		} else {
+			if (!item->parent->parent) {
+				log_error("dm_report: can't use unnamed object at top level of JSON output");
+				return 0;
+			}
+			if (item->parent->store.finished_count > 0)
+				log_print("%*s", item->group->indent + (int) sizeof(JSON_SEPARATOR) - 1, JSON_SEPARATOR);
+			log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_START) - 1, JSON_OBJECT_START);
+			item->group->indent += JSON_INDENT_UNIT;
+		}
+
+		item->output_done = 1;
+		item->needs_closing = 1;
+	}
+
+	return 1;
+}
+
 int dm_report_group_push(struct dm_report_group *group, struct dm_report *report, void *data)
 {
 	struct report_group_item *item, *tmp_item;
@@ -4634,6 +4818,10 @@ int dm_report_group_push(struct dm_report_group *group, struct dm_report *report
 			if (!_report_group_push_basic(item, data))
 				goto_bad;
 			break;
+		case DM_REPORT_GROUP_JSON:
+			if (!_report_group_push_json(item, data))
+				goto_bad;
+			break;
 		default:
 			goto_bad;
 	}
@@ -4655,6 +4843,23 @@ static int _report_group_pop_basic(struct report_group_item *item)
 	return 1;
 }
 
+static int _report_group_pop_json(struct report_group_item *item)
+{
+	if (item->output_done && item->needs_closing) {
+		if (item->data) {
+			item->group->indent -= JSON_INDENT_UNIT;
+			log_print("%*s", item->group->indent + (int) sizeof(JSON_ARRAY_END) - 1, JSON_ARRAY_END);
+		}
+		if (item->parent->data && item->parent->parent) {
+			item->group->indent -= JSON_INDENT_UNIT;
+			log_print("%*s", item->group->indent + (int) sizeof(JSON_OBJECT_END) - 1, JSON_OBJECT_END);
+		}
+		item->needs_closing = 0;
+	}
+
+	return 1;
+}
+
 int dm_report_group_pop(struct dm_report_group *group)
 {
 	struct report_group_item *item;
@@ -4676,6 +4881,10 @@ int dm_report_group_pop(struct dm_report_group *group)
 			if (!_report_group_pop_basic(item))
 				return_0;
 			break;
+		case DM_REPORT_GROUP_JSON:
+			if (!_report_group_pop_json(item))
+				return_0;
+			break;
 		default:
 			return 0;
         }
@@ -4704,6 +4913,12 @@ static int _report_group_destroy_basic(void)
 	return 1;
 }
 
+static int _report_group_destroy_json(void)
+{
+	log_print(JSON_OBJECT_END);
+	return 1;
+}
+
 int dm_report_group_destroy(struct dm_report_group *group)
 {
 	struct report_group_item *item, *tmp_item;
@@ -4728,6 +4943,10 @@ int dm_report_group_destroy(struct dm_report_group *group)
 			if (!_report_group_destroy_basic())
 				goto_out;
 			break;
+		case DM_REPORT_GROUP_JSON:
+			if (!_report_group_destroy_json())
+				goto_out;
+			break;
 		default:
 			goto_out;
         }


