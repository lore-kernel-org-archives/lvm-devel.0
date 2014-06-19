From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Jun 2014 14:17:53 +0000 (UTC)
Subject: master - report: make "help" and "?" field implicit
Message-ID: <20140619141753.C39F960911@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd7325f18d6869452447b7e1d08d8ada7703e0de
Commit:        cd7325f18d6869452447b7e1d08d8ada7703e0de
Parent:        012dab7aa3373201e59a77fa1e11823bd95c771c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 19 15:33:16 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 19 16:09:31 2014 +0200

report: make "help" and "?" field implicit

Making "help" and "?" implicit also simplifies code since the
dm_report_init caller (lvm/dmsetup) doesn't need to check on
dm_report_init return whether "help" or "?" was hit while parsing
fields/sort keys in libdevmapper.

The libdevmapper now sets internal "RH_ALREADY_REPORTED" flag
after it reports the "help" or "?" implicit field. Then libdevmapper
itself checks for this flag in dm_report_object and if found,
the actual reporting is skipped (because the "help" implicit field
was reported instead of the actual report).
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |   84 +++++++++++++++++++++++++++++++++----------------
 tools/reporter.c     |   11 +------
 3 files changed, 58 insertions(+), 38 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9e6f92e..3d1eee1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 =================================
+  Make "help" and "?" reporting fields implicit.
   Recognize implicit "selected" field if using dm_report_init_with_selection.
   Add support for implicit reporting fields which are predefined in libdm.
   Add DM_REPORT_FIELD_TYPE_PERCENT: separate number and percent fields.
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 00b99c8..8e46f78 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -24,6 +24,7 @@
  */
 #define RH_SORT_REQUIRED	0x00000100
 #define RH_HEADINGS_PRINTED	0x00000200
+#define RH_ALREADY_REPORTED	0x00000400
 
 struct dm_report {
 	struct dm_pool *mem;
@@ -191,29 +192,24 @@ struct row {
 /*
  * Implicit report types and fields.
  */
-static const struct dm_report_object_type _implicit_void_report_types[] = {
-	{ 0, "", "", NULL }
-};
-
-static const struct dm_report_field_type _implicit_void_report_fields[] = {
-	{ 0, 0, 0, 0, "", "", 0, 0}
-};
-
-static const struct dm_report_object_type *_implicit_report_types = _implicit_void_report_types;
-static const struct dm_report_field_type *_implicit_report_fields = _implicit_void_report_fields;
-
 #define COMMON_REPORT_TYPE 0x80000000
 #define COMMON_FIELD_SELECTED_ID "selected"
+#define COMMON_FIELD_HELP_ID DM_REPORT_FIELD_RESERVED_NAME_HELP
+#define COMMON_FIELD_HELP_ALT_ID DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT
 
-static void *_null_returning_fn(void *obj)
+static void *_null_returning_fn(void *obj __attribute__((unused)))
 {
 	return NULL;
 }
 
-static const struct dm_report_object_type _implicit_common_report_types[] = {
-	{ COMMON_REPORT_TYPE, "Common", "common_", _null_returning_fn },
-	{ 0, "", "", NULL }
-};
+static int _no_report_fn(struct dm_report *rh __attribute__((unused)),
+			 struct dm_pool *mem __attribute__((unused)),
+			 struct dm_report_field *field __attribute__((unused)),
+			 const void *data __attribute__((unused)),
+			 void *private __attribute__((unused)))
+{
+	return 1;
+}
 
 static int _selected_disp(struct dm_report *rh,
 			  struct dm_pool *mem __attribute__((unused)),
@@ -225,11 +221,27 @@ static int _selected_disp(struct dm_report *rh,
 	return dm_report_field_int(rh, field, &row->selected);
 }
 
+static const struct dm_report_object_type _implicit_common_report_types[] = {
+	{ COMMON_REPORT_TYPE, "Common", "common_", _null_returning_fn },
+	{ 0, "", "", NULL }
+};
+
 static const struct dm_report_field_type _implicit_common_report_fields[] = {
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
+	{ 0, 0, 0, 0, "", "", 0, 0}
+};
+
+static const struct dm_report_field_type _implicit_common_report_fields_with_selection[] = {
 	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_SELECTED_ID, "Selected", _selected_disp, "Item passes selection criteria." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ID, "Help", _no_report_fn, "Show help." },
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_HELP_ALT_ID, "Help", _no_report_fn, "Show help." },
 	{ 0, 0, 0, 0, "", "", 0, 0}
 };
 
+static const struct dm_report_object_type *_implicit_report_types = _implicit_common_report_types;
+static const struct dm_report_field_type *_implicit_report_fields = _implicit_common_report_fields;
+
 static const struct dm_report_object_type *_find_type(struct dm_report *rh,
 						      uint32_t report_type)
 {
@@ -940,10 +952,7 @@ static int _parse_fields(struct dm_report *rh, const char *format,
 		if (!_field_match(rh, ws, (size_t) (we - ws), report_type_only)) {
 			_display_fields(rh, 1, 0);
 			log_warn(" ");
-			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
-			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
-				log_error("Unrecognised field: %.*s",
-					  (int) (we - ws), ws);
+			log_error("Unrecognised field: %.*s", (int) (we - ws), ws);
 			return 0;
 		}
 	}
@@ -970,10 +979,7 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
 			_display_fields(rh, 1, 0);
 			log_warn(" ");
-			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
-			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
-				log_error("dm_report: Unrecognised field: %.*s",
-					  (int) (we - ws), ws);
+			log_error("dm_report: Unrecognised field: %.*s", (int) (we - ws), ws);
 			return 0;
 		}
 	}
@@ -1015,6 +1021,20 @@ static void _dm_report_init_update_types(struct dm_report *rh, uint32_t *report_
 		*report_types &= ~type->id;
 }
 
+static int _help_requested(struct dm_report *rh)
+{
+	struct field_properties *fp;
+
+	dm_list_iterate_items(fp, &rh->field_props) {
+		if (fp->implicit &&
+		    (!strcmp(_implicit_report_fields[fp->field_num].id, COMMON_FIELD_HELP_ID) ||
+		     !strcmp(_implicit_report_fields[fp->field_num].id, COMMON_FIELD_HELP_ALT_ID)))
+			return 1;
+	}
+
+	return 0;
+}
+
 struct dm_report *dm_report_init(uint32_t *report_types,
 				 const struct dm_report_object_type *types,
 				 const struct dm_report_field_type *fields,
@@ -1098,6 +1118,12 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 	 */
 	_dm_report_init_update_types(rh, report_types);
 
+	if (_help_requested(rh)) {
+		_display_fields(rh, 1, 0);
+		log_warn(" ");
+		rh->flags |= RH_ALREADY_REPORTED;
+	}
+
 	return rh;
 }
 
@@ -1406,6 +1432,9 @@ int dm_report_object(struct dm_report *rh, void *object)
 		goto out;
 	}
 
+	if (rh->flags & RH_ALREADY_REPORTED)
+		return 1;
+
 	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
 		log_error("dm_report_object: struct row allocation failed");
 		goto out;
@@ -2615,8 +2644,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	struct selection_node *root = NULL;
 	const char *fin, *next;
 
-	_implicit_report_types = _implicit_common_report_types;
-	_implicit_report_fields = _implicit_common_report_fields;
+	_implicit_report_fields = _implicit_common_report_fields_with_selection;
 
 	if (!(rh = dm_report_init(report_types, types, fields, output_fields,
 			output_separator, output_flags, sort_keys, private_data)))
@@ -2640,8 +2668,8 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		_display_fields(rh, 0, 1);
 		log_warn(" ");
 		_display_selection_help(rh);
-		dm_report_free(rh);
-		return NULL;
+		rh->flags |= RH_ALREADY_REPORTED;
+		return rh;
 	}
 
 	if (!(root = _alloc_selection_node(rh->mem, SEL_OR)))
diff --git a/tools/reporter.c b/tools/reporter.c
index 1e91f8f..b08d97b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -354,17 +354,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
 					  headings, field_prefixes, quoted,
-					  columns_as_rows, selection))) {
-		if ( (!strcasecmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
-		      !strcmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) ||
-		     (!strcasecmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
-		      !strcmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) ||
-		     (selection &&
-		      (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
-		       !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))) )
-			return r;
+					  columns_as_rows, selection)))
 		return_ECMD_FAILED;
-	}
 
 	/* Ensure options selected are compatible */
 	if (report_type & SEGS)


