From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:15 +0000 (UTC)
Subject: master - libdm: report: add dm_report_set_selection
Message-ID: <20160620094115.955546100A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2078b842fb50d73f886fb93ff9e06c08977bf8a3
Commit:        2078b842fb50d73f886fb93ff9e06c08977bf8a3
Parent:        f2facdc1d01b0353b05623634d34924317c44a9c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 12 15:04:37 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

libdm: report: add dm_report_set_selection

Since we can do repeated dm_report_output calls now, we also like
to be able to set selection for each of these outputs.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_128 |    1 +
 libdm/libdevmapper.h                |    2 +
 libdm/libdm-report.c                |  124 ++++++++++++++++++++++++++---------
 4 files changed, 97 insertions(+), 31 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6842771..1772e18 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.128 -
 =================================
+  Add dm_report_set_selection to set selection for multiple output of report.
   Add DM_REPORT_OUTPUT_MULTIPLE_TIMES flag for multiple output of same report.
   Move field width handling/sort init from dm_report_object to dm_report_output.
   Add _LOG_BYPASS_REPORT flag for bypassing any log report currently set.
diff --git a/libdm/.exported_symbols.DM_1_02_128 b/libdm/.exported_symbols.DM_1_02_128
index 6e365d5..c323973 100644
--- a/libdm/.exported_symbols.DM_1_02_128
+++ b/libdm/.exported_symbols.DM_1_02_128
@@ -2,3 +2,4 @@ dm_report_group_create
 dm_report_group_push
 dm_report_group_pop
 dm_report_group_destroy
+dm_report_set_selection
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 61ab279..7fd765c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2675,6 +2675,8 @@ void dm_report_free(struct dm_report *rh);
 int dm_report_set_output_field_name_prefix(struct dm_report *rh,
 					   const char *report_prefix);
 
+int dm_report_set_selection(struct dm_report *rh, const char *selection);
+
 /*
  * Report functions are provided for simple data types.
  * They take care of allocating copies of the data.
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 95b6ded..cae9c66 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -30,6 +30,7 @@
 struct selection {
 	struct dm_pool *mem;
 	struct selection_node *selection_root;
+	int add_new_fields;
 };
 
 struct report_group_item;
@@ -1900,7 +1901,7 @@ static int _check_selection(struct dm_report *rh, struct selection_node *sn,
 
 static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
 {
-	if (!rh->selection)
+	if (!rh->selection || !rh->selection->selection_root)
 		return 1;
 
 	return _check_selection(rh, rh->selection->selection_root, fields);
@@ -3422,9 +3423,17 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 
 	/* The field is neither used in display options nor sort keys. */
 	if (!found) {
-		if (!(found = _add_field(rh, field_num, implicit, FLD_HIDDEN)))
+		if (rh->selection->add_new_fields) {
+			if (!(found = _add_field(rh, field_num, implicit, FLD_HIDDEN)))
+				return NULL;
+			rh->report_types |= fields[field_num].type;
+		} else {
+			log_error("Unable to create selection with field \'%s\' "
+				  "which is not included in current report.",
+				  implicit ? _implicit_report_fields[field_num].id
+					   : rh->fields[field_num].id);
 			return NULL;
-		rh->report_types |= fields[field_num].type;
+		}
 	}
 
 	field_id = fields[found->field_num].id;
@@ -3962,6 +3971,86 @@ error:
 	return NULL;
 }
 
+static int _alloc_rh_selection(struct dm_report *rh)
+{
+	if (!(rh->selection = dm_pool_zalloc(rh->mem, sizeof(struct selection))) ||
+	    !(rh->selection->mem = dm_pool_create("report selection", 10 * 1024))) {
+		log_error("Failed to allocate report selection structure.");
+		if (rh->selection)
+			dm_pool_free(rh->mem, rh->selection);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _report_set_selection(struct dm_report *rh, const char *selection, int add_new_fields)
+{
+	struct selection_node *root = NULL;
+	const char *fin, *next;
+
+	if (rh->selection) {
+		if (rh->selection->selection_root)
+			/* Trash any previous selection. */
+			dm_pool_free(rh->selection->mem, rh->selection->selection_root);
+		rh->selection->selection_root = NULL;
+	} else {
+		if (!_alloc_rh_selection(rh))
+			goto_bad;
+	}
+
+	if (!selection)
+		return 1;
+
+	rh->selection->add_new_fields = add_new_fields;
+
+	if (!(root = _alloc_selection_node(rh->selection->mem, SEL_OR)))
+		return 0;
+
+	if (!_parse_or_ex(rh, selection, &fin, root))
+		goto_bad;
+
+	next = _skip_space(fin);
+	if (*next) {
+		log_error("Expecting logical operator");
+		log_error(_sel_syntax_error_at_msg, next);
+		log_error(_sel_help_ref_msg);
+		goto bad;
+	}
+
+	rh->selection->selection_root = root;
+	return 1;
+bad:
+	dm_pool_free(rh->selection->mem, root);
+	return 0;
+}
+
+static void _reset_field_props(struct dm_report *rh)
+{
+	struct field_properties *fp;
+	dm_list_iterate_items(fp, &rh->field_props)
+		fp->width = fp->initial_width;
+}
+
+int dm_report_set_selection(struct dm_report *rh, const char *selection)
+{
+	struct row *row;
+
+	if (!_report_set_selection(rh, selection, 0))
+		return_0;
+
+	_reset_field_props(rh);
+
+	dm_list_iterate_items(row, &rh->rows) {
+		row->selected = _check_report_selection(rh, &row->fields);
+		if (row->field_sel_status)
+			_implicit_report_fields[row->field_sel_status->props->field_num].report_fn(rh,
+							rh->mem, row->field_sel_status, row, rh->private);
+	}
+
+	return 1;
+}
+
 struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						const struct dm_report_object_type *types,
 						const struct dm_report_field_type *fields,
@@ -3974,8 +4063,6 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						void *private_data)
 {
 	struct dm_report *rh;
-	struct selection_node *root = NULL;
-	const char *fin, *next;
 
 	_implicit_report_fields = _implicit_special_report_fields_with_selection;
 
@@ -4005,29 +4092,11 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return rh;
 	}
 
-	if (!(rh->selection = dm_pool_zalloc(rh->mem, sizeof(struct selection))) ||
-	    !(rh->selection->mem = dm_pool_create("report selection", 10 * 1024))) {
-		log_error("Failed to allocate report selection structure.");
-		goto bad;
-	}
-
-	if (!(root = _alloc_selection_node(rh->selection->mem, SEL_OR)))
-		goto_bad;
-
-	if (!_parse_or_ex(rh, selection, &fin, root))
+	if (!_report_set_selection(rh, selection, 1))
 		goto_bad;
 
-	next = _skip_space(fin);
-	if (*next) {
-		log_error("Expecting logical operator");
-		log_error(_sel_syntax_error_at_msg, next);
-		log_error(_sel_help_ref_msg);
-		goto bad;
-	}
-
 	_dm_report_init_update_types(rh, report_types);
 
-	rh->selection->selection_root = root;
 	return rh;
 bad:
 	dm_report_free(rh);
@@ -4351,13 +4420,6 @@ bad:
 	return 0;
 }
 
-static void _reset_field_props(struct dm_report *rh)
-{
-	struct field_properties *fp;
-	dm_list_iterate_items(fp, &rh->field_props)
-		fp->width = fp->initial_width;
-}
-
 static void _destroy_rows(struct dm_report *rh)
 {
 	/*


