From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  9 Jul 2014 22:34:35 +0000 (UTC)
Subject: master - report: Rename common fields to special fields.
Message-ID: <20140709223435.69A7060FE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a098cba0ebbd0682570cff2fc756a59533321f03
Commit:        a098cba0ebbd0682570cff2fc756a59533321f03
Parent:        46ea315f09306836cc10826b0e94da4685351d1c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 9 23:33:09 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 9 23:33:09 2014 +0100

report: Rename common fields to special fields.

Change the help heading from 'Common Fields' to 'Special Fields' for
the fields: selected, help, ?

Remove the code that does 'all' processing with these special fields as
each of them changes the behaviour of the command in an undesirable way.

'lvs -o all,selected' was of course just printing help.
(via internal expansion to 'lv_all,common_all')

and if we ignored the help fields, then '-o common_all' would still
pull in 'selected' and change the way rows were output.
---
 libdm/libdm-report.c |   52 ++++++++++++++++++++++---------------------------
 1 files changed, 23 insertions(+), 29 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index ad89cf2..9b4ea87 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -193,10 +193,10 @@ struct row {
 /*
  * Implicit report types and fields.
  */
-#define COMMON_REPORT_TYPE 0x80000000
-#define COMMON_FIELD_SELECTED_ID "selected"
-#define COMMON_FIELD_HELP_ID "help"
-#define COMMON_FIELD_HELP_ALT_ID "?"
+#define SPECIAL_REPORT_TYPE 0x80000000
+#define SPECIAL_FIELD_SELECTED_ID "selected"
+#define SPECIAL_FIELD_HELP_ID "help"
+#define SPECIAL_FIELD_HELP_ALT_ID "?"
 
 static void *_null_returning_fn(void *obj __attribute__((unused)))
 {
@@ -222,26 +222,26 @@ static int _selected_disp(struct dm_report *rh,
 	return dm_report_field_int(rh, field, &row->selected);
 }
 
-static const struct dm_report_object_type _implicit_common_report_types[] = {
-	{ COMMON_REPORT_TYPE, "Common", "common_", _null_returning_fn },
+static const struct dm_report_object_type _implicit_special_report_types[] = {
+	{ SPECIAL_REPORT_TYPE, "Special", "special_", _null_returning_fn },
 	{ 0, "", "", NULL }
 };
 
-static const struct dm_report_field_type _implicit_common_report_fields[] = {
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
+static const struct dm_report_field_type _implicit_special_report_fields[] = {
+	{ SPECIAL_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE , 0, 8, SPECIAL_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
+	{ SPECIAL_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE , 0, 8, SPECIAL_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
 	{ 0, 0, 0, 0, "", "", 0, 0}
 };
 
-static const struct dm_report_field_type _implicit_common_report_fields_with_selection[] = {
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_SELECTED_ID, "Selected", _selected_disp, "Item passes selection criteria." },
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
-	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
+static const struct dm_report_field_type _implicit_special_report_fields_with_selection[] = {
+	{ SPECIAL_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, SPECIAL_FIELD_SELECTED_ID, "Selected", _selected_disp, "Set if item passes selection criteria." },
+	{ SPECIAL_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE , 0, 8, SPECIAL_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
+	{ SPECIAL_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER | FLD_CMP_UNCOMPARABLE , 0, 8, SPECIAL_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
 	{ 0, 0, 0, 0, "", "", 0, 0}
 };
 
-static const struct dm_report_object_type *_implicit_report_types = _implicit_common_report_types;
-static const struct dm_report_field_type *_implicit_report_fields = _implicit_common_report_fields;
+static const struct dm_report_object_type *_implicit_report_types = _implicit_special_report_types;
+static const struct dm_report_field_type *_implicit_report_fields = _implicit_special_report_fields;
 
 static const struct dm_report_object_type *_find_type(struct dm_report *rh,
 						      uint32_t report_type)
@@ -626,11 +626,10 @@ static void _display_fields_more(struct dm_report *rh,
 			log_warn("%*.*s", (int) strlen(desc) + 7,
 				 (int) strlen(desc) + 7,
 				 "-------------------------------------------------------------------------------");
-			if (display_all_fields_item) {
+			if (display_all_fields_item && type->id != SPECIAL_REPORT_TYPE)
 				log_warn("  %sall%-*s - %s", type->prefix,
 					 (int) (id_len - 3 - strlen(type->prefix)), "",
 					 "All fields in this section.");
-			}
 		}
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */
 		log_warn("  %-*s - %s%s%s%s%s", (int) id_len, fields[f].id, fields[f].desc,
@@ -783,7 +782,6 @@ static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
 	}
 
 	/* Combine all report types that have a matching prefix. */
-	_all_match_combine(_implicit_report_types, unprefixed_all_matched, field, flen, &report_types);
 	_all_match_combine(rh->types, unprefixed_all_matched, field, flen, &report_types);
 
 	return report_types;
@@ -796,10 +794,6 @@ static int _add_all_fields(struct dm_report *rh, uint32_t type)
 {
 	uint32_t f;
 
-	for (f = 0; _implicit_report_fields[f].report_fn; f++)
-		if ((_implicit_report_fields[f].type & type) && !_add_field(rh, f, 1, 0))
-			return 0;
-
 	for (f = 0; rh->fields[f].report_fn; f++)
 		if ((rh->fields[f].type & type) && !_add_field(rh, f, 0, 0))
 			return 0;
@@ -1030,8 +1024,8 @@ static int _help_requested(struct dm_report *rh)
 
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->implicit &&
-		    (!strcmp(_implicit_report_fields[fp->field_num].id, COMMON_FIELD_HELP_ID) ||
-		     !strcmp(_implicit_report_fields[fp->field_num].id, COMMON_FIELD_HELP_ALT_ID)))
+		    (!strcmp(_implicit_report_fields[fp->field_num].id, SPECIAL_FIELD_HELP_ID) ||
+		     !strcmp(_implicit_report_fields[fp->field_num].id, SPECIAL_FIELD_HELP_ALT_ID)))
 			return 1;
 	}
 
@@ -1181,7 +1175,7 @@ static void *_report_get_field_data(struct dm_report *rh,
 static void *_report_get_implicit_field_data(struct dm_report *rh __attribute__((unused)),
 					     struct field_properties *fp, struct row *row)
 {
-	if (!strcmp(_implicit_report_fields[fp->field_num].id, COMMON_FIELD_SELECTED_ID))
+	if (!strcmp(_implicit_report_fields[fp->field_num].id, SPECIAL_FIELD_SELECTED_ID))
 		return row;
 
 	return NULL;
@@ -1468,7 +1462,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 
 		if (fp->implicit) {
 			fields = _implicit_report_fields;
-			if (!strcmp(fields[fp->field_num].id, COMMON_FIELD_SELECTED_ID))
+			if (!strcmp(fields[fp->field_num].id, SPECIAL_FIELD_SELECTED_ID))
 				field_sel_status = field;
 		} else
 			fields = rh->fields;
@@ -2700,7 +2694,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	struct selection_node *root = NULL;
 	const char *fin, *next;
 
-	_implicit_report_fields = _implicit_common_report_fields_with_selection;
+	_implicit_report_fields = _implicit_special_report_fields_with_selection;
 
 	if (!(rh = dm_report_init(report_types, types, fields, output_fields,
 			output_separator, output_flags, sort_keys, private_data)))
@@ -2719,8 +2713,8 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	}
 	rh->reserved_values = reserved_values;
 
-	if (!strcasecmp(selection, COMMON_FIELD_HELP_ID) ||
-	    !strcmp(selection, COMMON_FIELD_HELP_ALT_ID)) {
+	if (!strcasecmp(selection, SPECIAL_FIELD_HELP_ID) ||
+	    !strcmp(selection, SPECIAL_FIELD_HELP_ALT_ID)) {
 		_display_fields(rh, 0, 1);
 		log_warn(" ");
 		_display_selection_help(rh);


