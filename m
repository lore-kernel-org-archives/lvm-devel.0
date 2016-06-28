From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:20 +0000 (UTC)
Subject: master - libdm: report: fix field width calculation when using dm_report_column_headings
Message-ID: <20160628013320.1D28D60237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3985b12a2d11d3f4fd3d98090caa8664be594f5c
Commit:        3985b12a2d11d3f4fd3d98090caa8664be594f5c
Parent:        1b11f09d2a3bd3f6421776a004e62215054fa835
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 27 14:27:43 2016 +0200
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:28:40 2016 +0100

libdm: report: fix field width calculation when using dm_report_column_headings

This fixes commit 0ba5f4b8e977a6f2f45f95777da508b42d84c01a which moved
field recalculation (field width and sort position) from
dm_report_object to dm_report_output but it didn't handle the case when
dm_report_column_headings was used separately to report headings (before
dm_report_outpout call) and hence we ended up with intial widths for
fields in the headings.

If we're using dm_report_column_headings, we need to recalculate
fields if we haven't done so yet, the same way as we do in
dm_report_output.
---
 libdm/libdm-report.c |   65 +++++++++++++++++++++++++++++++------------------
 1 files changed, 41 insertions(+), 24 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index ad03c6e..8993201 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -25,7 +25,8 @@
  */
 #define RH_SORT_REQUIRED	0x00000100
 #define RH_HEADINGS_PRINTED	0x00000200
-#define RH_ALREADY_REPORTED	0x00000400
+#define RH_FIELD_CALC_NEEDED	0x00000400
+#define RH_ALREADY_REPORTED	0x00000800
 
 struct selection {
 	struct dm_pool *mem;
@@ -1282,6 +1283,8 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 	if (output_flags & DM_REPORT_OUTPUT_BUFFERED)
 		rh->flags |= RH_SORT_REQUIRED;
 
+	rh->flags |= RH_FIELD_CALC_NEEDED;
+
 	dm_list_init(&rh->field_props);
 	dm_list_init(&rh->rows);
 
@@ -4032,6 +4035,7 @@ static void _reset_field_props(struct dm_report *rh)
 	struct field_properties *fp;
 	dm_list_iterate_items(fp, &rh->field_props)
 		fp->width = fp->initial_width;
+	rh->flags |= RH_FIELD_CALC_NEEDED;
 }
 
 int dm_report_set_selection(struct dm_report *rh, const char *selection)
@@ -4188,11 +4192,45 @@ static int _report_headings(struct dm_report *rh)
 	return 0;
 }
 
+static int _should_display_row(struct row *row)
+{
+	return row->field_sel_status || row->selected;
+}
+
+static void _recalculate_fields(struct dm_report *rh)
+{
+	struct row *row;
+	struct dm_report_field *field;
+	size_t len;
+
+	dm_list_iterate_items(row, &rh->rows) {
+		dm_list_iterate_items(field, &row->fields) {
+			if ((rh->flags & RH_SORT_REQUIRED) &&
+			    (field->props->flags & FLD_SORT_KEY)) {
+				(*row->sort_fields)[field->props->sort_posn] = field;
+			}
+
+			if (_should_display_row(row)) {
+				len = (int) strlen(field->report_string);
+				if ((len > field->props->width))
+					field->props->width = len;
+
+			}
+		}
+	}
+
+	rh->flags &= ~RH_FIELD_CALC_NEEDED;
+}
+
 int dm_report_column_headings(struct dm_report *rh)
 {
 	/* Columns-as-rows does not use _report_headings. */
 	if (rh->flags & DM_REPORT_OUTPUT_COLUMNS_AS_ROWS)
 		return 1;
+
+	if (rh->flags & RH_FIELD_CALC_NEEDED)
+		_recalculate_fields(rh);
+
 	return _report_headings(rh);
 }
 
@@ -4246,11 +4284,6 @@ static int _row_compare(const void *a, const void *b)
 	return 0;		/* Identical */
 }
 
-static int _should_display_row(struct row *row)
-{
-	return row->field_sel_status || row->selected;
-}
-
 static int _sort_rows(struct dm_report *rh)
 {
 	struct row *(*rows)[];
@@ -4701,9 +4734,6 @@ static int _print_basic_report_header(struct dm_report *rh)
 
 int dm_report_output(struct dm_report *rh)
 {
-	struct row *row;
-	struct dm_report_field *field;
-	size_t len;
 	int r = 0;
 
 	if (_is_json_report(rh) &&
@@ -4715,21 +4745,8 @@ int dm_report_output(struct dm_report *rh)
 		goto out;
 	}
 
-	dm_list_iterate_items(row, &rh->rows) {
-		dm_list_iterate_items(field, &row->fields) {
-			if ((rh->flags & RH_SORT_REQUIRED) &&
-			    (field->props->flags & FLD_SORT_KEY)) {
-				(*row->sort_fields)[field->props->sort_posn] = field;
-			}
-
-			if (_should_display_row(row)) {
-				len = (int) strlen(field->report_string);
-				if ((len > field->props->width))
-					field->props->width = len;
-
-			}
-		}
-	}
+	if (rh->flags & RH_FIELD_CALC_NEEDED)
+		_recalculate_fields(rh);
 
 	if ((rh->flags & RH_SORT_REQUIRED))
 		_sort_rows(rh);


