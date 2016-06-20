From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:13 +0000 (UTC)
Subject: master - libdm: report: add DM_REPORT_OUTPUT_MULTIPLE_TIMES report flag to keep report data even after output is done
Message-ID: <20160620094113.8177360EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2facdc1d01b0353b05623634d34924317c44a9c
Commit:        f2facdc1d01b0353b05623634d34924317c44a9c
Parent:        0ba5f4b8e977a6f2f45f95777da508b42d84c01a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 12 14:34:04 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

libdm: report: add DM_REPORT_OUTPUT_MULTIPLE_TIMES report flag to keep report data even after output is done

The DM_REPORT_OUTPUT_MULTIPLE_TIMES instructs reporting code to
keep rows even after dm_report_output call - the rows are not
destroyed in this case which makes it possible to call dm_report_output
multiple times.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    1 +
 libdm/libdm-report.c |   83 ++++++++++++++++++++++++++++++++++---------------
 3 files changed, 59 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7e98e1f..6842771 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Add DM_REPORT_OUTPUT_MULTIPLE_TIMES flag for multiple output of same report.
   Move field width handling/sort init from dm_report_object to dm_report_output.
   Add _LOG_BYPASS_REPORT flag for bypassing any log report currently set.
   Introduce DM_REPORT_GROUP_JSON for report group with JSON output format.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index cad79dd..61ab279 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2606,6 +2606,7 @@ const void *dm_report_value_cache_get(struct dm_report *rh, const char *name);
 #define DM_REPORT_OUTPUT_FIELD_NAME_PREFIX	0x00000008
 #define DM_REPORT_OUTPUT_FIELD_UNQUOTED		0x00000010
 #define DM_REPORT_OUTPUT_COLUMNS_AS_ROWS	0x00000020
+#define DM_REPORT_OUTPUT_MULTIPLE_TIMES		0x00000040
 
 struct dm_report *dm_report_init(uint32_t *report_types,
 				 const struct dm_report_object_type *types,
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7a5d6e5..95b6ded 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1994,25 +1994,35 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 	if (!_check_report_selection(rh, &row->fields)) {
 		row->selected = 0;
 
-		if (!row->field_sel_status)
-			goto out;
-
-		/*
-		 * If field with id "selected" is reported,
-		 * report the row although it does not pass
-		 * the selection criteria.
-		 * The "selected" field reports the result
-		 * of the selection.
-		 */
-		_implicit_report_fields[row->field_sel_status->props->field_num].report_fn(rh,
-						rh->mem, row->field_sel_status, row, rh->private);
 		/*
-		 * If the "selected" field is not displayed, e.g.
-		 * because it is part of the sort field list,
-		 * skip the display of the row as usual.
+		 * If the row is not selected, we still keep it for output if either:
+		 *   - we're displaying special "selected" field in the row,
+		 *   - or the report is supposed to be on output multiple times
+		 *     where each output can have a new selection defined.
 		 */
-		if (row->field_sel_status->props->flags & FLD_HIDDEN)
+		if (!row->field_sel_status && !(rh->flags & DM_REPORT_OUTPUT_MULTIPLE_TIMES))
 			goto out;
+
+		if (row->field_sel_status) {
+			/*
+			 * If field with id "selected" is reported,
+			 * report the row although it does not pass
+			 * the selection criteria.
+			 * The "selected" field reports the result
+			 * of the selection.
+			 */
+			_implicit_report_fields[row->field_sel_status->props->field_num].report_fn(rh,
+							rh->mem, row->field_sel_status, row, rh->private);
+			/*
+			 * If the "selected" field is not displayed, e.g.
+			 * because it is part of the sort field list,
+			 * skip the display of the row as usual unless
+			 * we plan to do the output multiple times.
+			 */
+			if ((row->field_sel_status->props->flags & FLD_HIDDEN) &&
+			    !(rh->flags & DM_REPORT_OUTPUT_MULTIPLE_TIMES))
+				goto out;
+		}
 	}
 
 	if (!do_output)
@@ -4165,6 +4175,11 @@ static int _row_compare(const void *a, const void *b)
 	return 0;		/* Identical */
 }
 
+static int _should_display_row(struct row *row)
+{
+	return row->field_sel_status || row->selected;
+}
+
 static int _sort_rows(struct dm_report *rh)
 {
 	struct row *(*rows)[];
@@ -4439,6 +4454,11 @@ static int _output_as_columns(struct dm_report *rh)
 	/* Print and clear buffer */
 	last_row = dm_list_last(&rh->rows);
 	dm_list_iterate_safe(rowh, rtmp, &rh->rows) {
+		row = dm_list_item(rowh, struct row);
+
+		if (!_should_display_row(row))
+			continue;
+
 		if (!dm_pool_begin_object(rh->mem, 512)) {
 			log_error("dm_report: Unable to allocate output line");
 			return 0;
@@ -4451,7 +4471,6 @@ static int _output_as_columns(struct dm_report *rh)
 			}
 		}
 
-		row = dm_list_item(rowh, struct row);
 		do_field_delim = 0;
 
 		dm_list_iterate_safe(fh, ftmp, &row->fields) {
@@ -4478,7 +4497,8 @@ static int _output_as_columns(struct dm_report *rh)
 			if (!_output_field(rh, field))
 				goto bad;
 
-			dm_list_del(&field->list);
+			if (!(rh->flags & DM_REPORT_OUTPUT_MULTIPLE_TIMES))
+				dm_list_del(&field->list);
 		}
 
 		if (_is_json_report(rh)) {
@@ -4500,10 +4520,12 @@ static int _output_as_columns(struct dm_report *rh)
 
 		line = (char *) dm_pool_end_object(rh->mem);
 		log_print_bypass_report("%*s", rh->group_item ? rh->group_item->group->indent + (int) strlen(line) : 0, line);
-		dm_list_del(&row->list);
+		if (!(rh->flags & DM_REPORT_OUTPUT_MULTIPLE_TIMES))
+			dm_list_del(&row->list);
 	}
 
-	_destroy_rows(rh);
+	if (!(rh->flags & DM_REPORT_OUTPUT_MULTIPLE_TIMES))
+		_destroy_rows(rh);
 
 	return 1;
 
@@ -4631,14 +4653,17 @@ int dm_report_output(struct dm_report *rh)
 
 	dm_list_iterate_items(row, &rh->rows) {
 		dm_list_iterate_items(field, &row->fields) {
-			len = (int) strlen(field->report_string);
-			if ((len > field->props->width))
-				field->props->width = len;
-
 			if ((rh->flags & RH_SORT_REQUIRED) &&
 			    (field->props->flags & FLD_SORT_KEY)) {
 				(*row->sort_fields)[field->props->sort_posn] = field;
 			}
+
+			if (_should_display_row(row)) {
+				len = (int) strlen(field->report_string);
+				if ((len > field->props->width))
+					field->props->width = len;
+
+			}
 		}
 	}
 
@@ -4746,8 +4771,13 @@ static int _report_group_push_single(struct report_group_item *item, void *data)
 
 static int _report_group_push_basic(struct report_group_item *item, const char *name)
 {
-	if (!item->report && !name && item->parent->store.finished_count > 0)
-		log_print_bypass_report("%s", "");
+	if (item->report) {
+		if (!(item->report->flags & DM_REPORT_OUTPUT_BUFFERED))
+			item->report->flags &= ~(DM_REPORT_OUTPUT_MULTIPLE_TIMES);
+	} else {
+		if (!name && item->parent->store.finished_count > 0)
+			log_print_bypass_report("%s", "");
+	}
 
 	return 1;
 }
@@ -4802,6 +4832,7 @@ int dm_report_group_push(struct dm_report_group *group, struct dm_report *report
 		item->store.orig_report_flags = report->flags;
 		report->group_item = item;
 	}
+
 	item->group = group;
 	item->data = data;
 


