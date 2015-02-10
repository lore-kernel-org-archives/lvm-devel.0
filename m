From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:42 +0000 (UTC)
Subject: master - libdm: report: add dm_report_object_is_selected
Message-ID: <20150210151242.19DD06108C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=123a3383a021df737852892ff400f047b5ff609e
Commit:        123a3383a021df737852892ff400f047b5ff609e
Parent:        2ee3bcb877b081dd6281644d4c9c366dd08ad1c1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Nov 24 11:07:39 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:04:38 2015 +0100

libdm: report: add dm_report_object_is_selected

The new dm_report_object_is_selected fn makes it possible to opt whether the
object reported should be displayed on output or not. Also, in addition to
that, it makes it possible to save the result of selection (either 0 or 1).

So dm_report_object_is_selected is simply  more general form of object
reporting fn - combinations now allow for:

  dm_report_object_is_selected(rh, object, 1, NULL):
  This is exactly the original dm_report_object fn and it's fully equal
  to it.

  dm_report_object_is_selected(rh, object, 0, selected):
  Do not display the result on output, but save info whether the object
  is selected or not in 'selected' variable.

  dm_report_object_is_selected(rh, object, 1, selected):
  Display the result on output (if it passes selection criteria) and save
  whether the object is selected or not in 'selected' variable.

  dm_report_object(rh, object, 0, NULL):
  This combination is not allowed - it will end up with internal error.
  We're either interested in selection status or we want to display the
  result on output or both, but never nothing of the two.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |   10 +++++++++
 libdm/libdm-report.c |   53 +++++++++++++++++++++++++++++++++----------------
 3 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3fb69cb..183ef15 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.94 - 
 ===================================
+  Add dm_report_object_is_selected for generalized interface for report/select.
 
 Version 1.02.93 - 21st January 2015
 ===================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b164b51..309e63f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1761,7 +1761,17 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						const char *selection,
 						const struct dm_report_reserved_value reserved_values[],
 						void *private_data);
+/*
+ * Report an object, pass it through the selection criteria if they
+ * are present and display the result on output if it passes the criteria.
+ */
 int dm_report_object(struct dm_report *rh, void *object);
+/*
+ * The same as dm_report_object, but display the result on output only if
+ * 'do_output' arg is set. Also, save the result of selection in 'selected'
+ * arg if it's not NULL (either 1 if the object passes, otherwise 0).
+ */
+int dm_report_object_is_selected(struct dm_report *rh, void *object, int do_output, int *selected);
 
 /*
  * Compact report output so that if field value is empty for all rows in
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2612f74..6f528f1 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1575,7 +1575,7 @@ static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
 	return _check_selection(rh, rh->selection->selection_root, fields);
 }
 
-int dm_report_object(struct dm_report *rh, void *object)
+static int _do_report_object(struct dm_report *rh, void *object, int do_output, int *selected)
 {
 	const struct dm_report_field_type *fields;
 	struct field_properties *fp;
@@ -1586,7 +1586,13 @@ int dm_report_object(struct dm_report *rh, void *object)
 	int r = 0;
 
 	if (!rh) {
-		log_error(INTERNAL_ERROR "dm_report handler is NULL.");
+		log_error(INTERNAL_ERROR "_do_report_object: dm_report handler is NULL.");
+		return 0;
+	}
+
+	if (!do_output && !selected) {
+		log_error(INTERNAL_ERROR "_do_report_object: output not requested and "
+					 "selected output variable is NULL too.");
 		return 0;
 	}
 
@@ -1594,7 +1600,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 		return 1;
 
 	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
-		log_error("dm_report_object: struct row allocation failed");
+		log_error("_do_report_object: struct row allocation failed");
 		return 0;
 	}
 
@@ -1604,7 +1610,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	    !(row->sort_fields =
 		dm_pool_zalloc(rh->mem, sizeof(struct dm_report_field *) *
 			       rh->keys_count))) {
-		log_error("dm_report_object: "
+		log_error("_do_report_object: "
 			  "row sort value structure allocation failed");
 		goto out;
 	}
@@ -1615,7 +1621,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	/* For each field to be displayed, call its report_fn */
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (!(field = dm_pool_zalloc(rh->mem, sizeof(*field)))) {
-			log_error("dm_report_object: "
+			log_error("_do_report_object: "
 				  "struct dm_report_field allocation failed");
 			goto out;
 		}
@@ -1632,7 +1638,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 		data = fp->implicit ? _report_get_implicit_field_data(rh, fp, row)
 				    : _report_get_field_data(rh, fp, object);
 		if (!data) {
-			log_error("dm_report_object: "
+			log_error("_do_report_object: "
 				  "no data assigned to field %s",
 				  fields[fp->field_num].id);
 			goto out;
@@ -1641,7 +1647,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 		if (!fields[fp->field_num].report_fn(rh, rh->mem,
 							 field, data,
 							 rh->private)) {
-			log_error("dm_report_object: "
+			log_error("_do_report_object: "
 				  "report function failed for field %s",
 				  fields[fp->field_num].id);
 			goto out;
@@ -1650,11 +1656,14 @@ int dm_report_object(struct dm_report *rh, void *object)
 		dm_list_add(&row->fields, &field->list);
 	}
 
+	r = 1;
+
 	if (!_check_report_selection(rh, &row->fields)) {
-		if (!field_sel_status) {
-			r = 1;
+		row->selected = 0;
+
+		if (!field_sel_status)
 			goto out;
-		}
+
 		/*
 		 * If field with id "selected" is reported,
 		 * report the row although it does not pass
@@ -1662,7 +1671,6 @@ int dm_report_object(struct dm_report *rh, void *object)
 		 * The "selected" field reports the result
 		 * of the selection.
 		 */
-		row->selected = 0;
 		_implicit_report_fields[field_sel_status->props->field_num].report_fn(rh,
 						rh->mem, field_sel_status, row, rh->private);
 		/*
@@ -1670,12 +1678,13 @@ int dm_report_object(struct dm_report *rh, void *object)
 		 * because it is part of the sort field list,
 		 * skip the display of the row as usual.
 		 */
-		if (field_sel_status->props->flags & FLD_HIDDEN) {
-			r = 1;
+		if (field_sel_status->props->flags & FLD_HIDDEN)
 			goto out;
-		}
 	}
 
+	if (!do_output)
+		goto out;
+
 	dm_list_add(&rh->rows, &row->list);
 
 	dm_list_iterate_items(field, &row->fields) {
@@ -1691,10 +1700,10 @@ int dm_report_object(struct dm_report *rh, void *object)
 
 	if (!(rh->flags & DM_REPORT_OUTPUT_BUFFERED))
 		return dm_report_output(rh);
-
-	r = 1;
 out:
-	if (!r)
+	if (selected)
+		*selected = row->selected;
+	if (!do_output || !r)
 		dm_pool_free(rh->mem, row);
 	return r;
 }
@@ -1751,6 +1760,16 @@ int dm_report_compact_fields(struct dm_report *rh)
 	return 1;
 }
 
+int dm_report_object(struct dm_report *rh, void *object)
+{
+	return _do_report_object(rh, object, 1, NULL);
+}
+
+int dm_report_object_is_selected(struct dm_report *rh, void *object, int do_output, int *selected)
+{
+	return _do_report_object(rh, object, do_output, selected);
+}
+
 /*
  * Selection parsing
  */


