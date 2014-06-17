From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:41 +0000 (UTC)
Subject: master - report: add support for implicit fields, add implicit "selected" field
Message-ID: <20140617143441.61FA060C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f88130fd8543c3fd5829afb1bc4e4bd30a255d0c
Commit:        f88130fd8543c3fd5829afb1bc4e4bd30a255d0c
Parent:        0d8e94ce2e6f48c47194c4844d4f59ccd7806959
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 12 13:57:22 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: add support for implicit fields, add implicit "selected" field

Implicit fields are fields that are registered with the report
and reported internally by libdevmapper itself (compared to explicit
fields that are registered by the layer above libdevmapper - e.g. LVM,
dmsetup...).

The "selected" field is the implicit field (for now the only one)
that reports the result of the selection. Since the selection itself
is the property of the libdevmapper, the upper layer using dm_report_init
can't register this field itself and it must be done directly at
libdevmapper layer.

The "selected" field is internally registered as part of the "common"
report type with id 0x80000000 (the last bit in uin32_t) which is then
reserved (the explicit report types are then checked if they do not
contain this id and if yes, we error out).

This way, the "selected" field is recognized by all libdevmapper users
that initialize the reporting with "dm_report_init_with_selection".
If reporting is initialized with the classical "dm_report_init",
there's no functional change (so the "selected" field is not defined
and it's not recognized).
---
 libdm/libdm-report.c |  349 ++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 282 insertions(+), 67 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0461bdf..79b3687 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -71,6 +71,7 @@ struct field_properties {
 	int32_t width;
 	const struct dm_report_object_type *type;
 	uint32_t flags;
+	int implicit;
 };
 
 /*
@@ -184,6 +185,49 @@ struct row {
 	struct dm_report *rh;
 	struct dm_list fields;			  /* Fields in display order */
 	struct dm_report_field *(*sort_fields)[]; /* Fields in sort order */
+	int selected;
+};
+
+/*
+ * Implicit report types and fields.
+ */
+static const struct dm_report_object_type _implicit_void_report_types[] = {
+	{ 0, "", "", NULL }
+};
+
+static const struct dm_report_field_type _implicit_void_report_fields[] = {
+	{ 0, 0, 0, 0, "", "", 0, 0}
+};
+
+static const struct dm_report_object_type *_implicit_report_types = _implicit_void_report_types;
+static const struct dm_report_field_type *_implicit_report_fields = _implicit_void_report_fields;
+
+#define COMMON_REPORT_TYPE 0x80000000
+#define COMMON_FIELD_SELECTED_ID "selected"
+
+static void *_null_returning_fn(void *obj)
+{
+	return NULL;
+}
+
+static const struct dm_report_object_type _implicit_common_report_types[] = {
+	{ COMMON_REPORT_TYPE, "Common", "common_", _null_returning_fn },
+	{ 0, "", "", NULL }
+};
+
+static int _selected_disp(struct dm_report *rh,
+			  struct dm_pool *mem __attribute__((unused)),
+			  struct dm_report_field *field,
+			  const void *data,
+			  void *private __attribute__((unused)))
+{
+	struct row *row = (struct row *)data;
+	return dm_report_field_int(rh, field, &row->selected);
+}
+
+static const struct dm_report_field_type _implicit_common_report_fields[] = {
+	{ COMMON_REPORT_TYPE, DM_REPORT_FIELD_TYPE_NUMBER, 0, 8, COMMON_FIELD_SELECTED_ID, "Selected", _selected_disp, "Item passes selection criteria." },
+	{ 0, 0, 0, 0, "", "", 0, 0}
 };
 
 static const struct dm_report_object_type *_find_type(struct dm_report *rh,
@@ -191,6 +235,10 @@ static const struct dm_report_object_type *_find_type(struct dm_report *rh,
 {
 	const struct dm_report_object_type *t;
 
+	for (t = _implicit_report_types; t->data_fn; t++)
+		if (t->id == report_type)
+			return t;
+
 	for (t = rh->types; t->data_fn; t++)
 		if (t->id == report_type)
 			return t;
@@ -524,25 +572,37 @@ static const char *_get_field_type_name(unsigned field_type)
 /*
  * show help message
  */
-static void _display_fields(struct dm_report *rh, int display_all_fields_item
-			    int display_field_types)
+static size_t _get_longest_field_id_len(const struct dm_report_field_type *fields)
 {
 	uint32_t f;
-	const struct dm_report_object_type *type;
-	const char *desc, *last_desc = "";
 	size_t id_len = 0;
 
-	for (f = 0; rh->fields[f].report_fn; f++)
-		if (strlen(rh->fields[f].id) > id_len)
-			id_len = strlen(rh->fields[f].id);
+	for (f = 0; fields[f].report_fn; f++)
+		if (strlen(fields[f].id) > id_len)
+			id_len = strlen(fields[f].id);
+
+	return id_len;
+}
+
+static void _display_fields_more(struct dm_report *rh,
+				 const struct dm_report_field_type *fields,
+				 size_t id_len, int display_all_fields_item,
+				 int display_field_types)
+{
+	uint32_t f;
+	const struct dm_report_object_type *type;
+	const char *desc, *last_desc = "";
 
+	for (f = 0; fields[f].report_fn; f++)
+		if (strlen(fields[f].id) > id_len)
+			id_len = strlen(fields[f].id);
 
 	for (type = rh->types; type->data_fn; type++)
 		if (strlen(type->prefix) + 3 > id_len)
 			id_len = strlen(type->prefix) + 3;
 
-	for (f = 0; rh->fields[f].report_fn; f++) {
-		if ((type = _find_type(rh, rh->fields[f].type)) && type->desc)
+	for (f = 0; fields[f].report_fn; f++) {
+		if ((type = _find_type(rh, fields[f].type)) && type->desc)
 			desc = type->desc;
 		else
 			desc = " ";
@@ -559,31 +619,54 @@ static void _display_fields(struct dm_report *rh, int display_all_fields_item
 					 "All fields in this section.");
 			}
 		}
-
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */
-		log_warn("  %-*s - %s%s%s%s", (int) id_len, rh->fields[f].id, rh->fields[f].desc,
+		log_warn("  %-*s - %s%s%s%s", (int) id_len, fields[f].id, fields[f].desc,
 					      display_field_types ? " [" : "",
-					      display_field_types ? _get_field_type_name(rh->fields[f].flags & DM_REPORT_FIELD_TYPE_MASK) : "",
+					      display_field_types ? _get_field_type_name(fields[f].flags & DM_REPORT_FIELD_TYPE_MASK) : "",
 					      display_field_types ? "]" : "");
 		last_desc = desc;
 	}
 }
 
 /*
+ * show help message
+ */
+static void _display_fields(struct dm_report *rh, int display_all_fields_item,
+			    int display_field_types)
+{
+	size_t tmp, id_len = 0;
+
+	if ((tmp = _get_longest_field_id_len(_implicit_report_fields)) > id_len)
+		id_len = tmp;
+	if ((tmp = _get_longest_field_id_len(rh->fields)) > id_len)
+		id_len = tmp;
+
+	_display_fields_more(rh, _implicit_report_fields, id_len,
+			     display_all_fields_item, display_field_types);
+	log_warn(" ");
+	_display_fields_more(rh, rh->fields, id_len, display_all_fields_item,
+			     display_field_types);
+}
+
+/*
  * Initialise report handle
  */
 static int _copy_field(struct dm_report *rh, struct field_properties *dest,
-		       uint32_t field_num)
+		       uint32_t field_num, int implicit)
 {
+	const struct dm_report_field_type *fields = implicit ? _implicit_report_fields
+							     : rh->fields;
+
 	dest->field_num = field_num;
-	dest->width = rh->fields[field_num].width;
-	dest->flags = rh->fields[field_num].flags & DM_REPORT_FIELD_MASK;
+	dest->width = fields[field_num].width;
+	dest->flags = fields[field_num].flags & DM_REPORT_FIELD_MASK;
+	dest->implicit = implicit;
 
 	/* set object type method */
-	dest->type = _find_type(rh, rh->fields[field_num].type);
+	dest->type = _find_type(rh, fields[field_num].type);
 	if (!dest->type) {
 		log_error("dm_report: field not match: %s",
-			  rh->fields[field_num].id);
+			  fields[field_num].id);
 		return 0;
 	}
 
@@ -591,7 +674,8 @@ static int _copy_field(struct dm_report *rh, struct field_properties *dest,
 }
 
 static struct field_properties * _add_field(struct dm_report *rh,
-					    uint32_t field_num, uint32_t flags)
+					    uint32_t field_num, int implicit,
+					    uint32_t flags)
 {
 	struct field_properties *fp;
 
@@ -601,7 +685,7 @@ static struct field_properties * _add_field(struct dm_report *rh,
 		return NULL;
 	}
 
-	if (!_copy_field(rh, fp, field_num)) {
+	if (!_copy_field(rh, fp, field_num, implicit)) {
 		stack;
 		dm_pool_free(rh->mem, fp);
 		return NULL;
@@ -648,10 +732,27 @@ static int _is_same_field(const char *name1, const char *name2,
 /*
  * Check for a report type prefix + "all" match.
  */
-static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
+static void _all_match_combine(const struct dm_report_object_type *types,
+			       unsigned unprefixed_all_matched,
+			       const char *field, size_t flen,
+			       uint32_t *report_types)
 {
-	size_t prefix_len;
 	const struct dm_report_object_type *t;
+	size_t prefix_len;
+
+	for (t = types; t->data_fn; t++) {
+		prefix_len = strlen(t->prefix);
+
+		if (!strncasecmp(t->prefix, field, prefix_len) &&
+		    ((unprefixed_all_matched && (flen == prefix_len)) ||
+		     (!strncasecmp(field + prefix_len, "all", 3) &&
+		      (flen == prefix_len + 3))))
+			*report_types |= t->id;
+	}
+}
+
+static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
+{
 	uint32_t report_types = 0;
 	unsigned unprefixed_all_matched = 0;
 
@@ -667,15 +768,8 @@ static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
 	}
 
 	/* Combine all report types that have a matching prefix. */
-	for (t = rh->types; t->data_fn; t++) {
-		prefix_len = strlen(t->prefix);
-
-		if (!strncasecmp(t->prefix, field, prefix_len) &&
-		    ((unprefixed_all_matched && (flen == prefix_len)) ||
-		     (!strncasecmp(field + prefix_len, "all", 3) &&
-		      (flen == prefix_len + 3))))
-			report_types |= t->id;
-	}
+	_all_match_combine(_implicit_report_types, unprefixed_all_matched, field, flen, &report_types);
+	_all_match_combine(rh->types, unprefixed_all_matched, field, flen, &report_types);
 
 	return report_types;
 }
@@ -687,23 +781,37 @@ static int _add_all_fields(struct dm_report *rh, uint32_t type)
 {
 	uint32_t f;
 
+	for (f = 0; _implicit_report_fields[f].report_fn; f++)
+		if ((_implicit_report_fields[f].type & type) && !_add_field(rh, f, 1, 0))
+			return 0;
+
 	for (f = 0; rh->fields[f].report_fn; f++)
-		if ((rh->fields[f].type & type) && !_add_field(rh, f, 0))
+		if ((rh->fields[f].type & type) && !_add_field(rh, f, 0, 0))
 			return 0;
 
 	return 1;
 }
 
-static int _get_field(struct dm_report *rh, const char *field, size_t flen, uint32_t *f_ret)
+static int _get_field(struct dm_report *rh, const char *field, size_t flen,
+		      uint32_t *f_ret, int *implicit)
 {
 	uint32_t f;
 
 	if (!flen)
 		return 0;
 
+	for (f = 0; _implicit_report_fields[f].report_fn; f++) {
+		if (_is_same_field(_implicit_report_fields[f].id, field, flen, rh->field_prefix)) {
+			*f_ret = f;
+			*implicit = 1;
+			return 1;
+		}
+	}
+
 	for (f = 0; rh->fields[f].report_fn; f++) {
 		if (_is_same_field(rh->fields[f].id, field, flen, rh->field_prefix)) {
 			*f_ret = f;
+			*implicit = 0;
 			return 1;
 		}
 	}
@@ -715,16 +823,18 @@ static int _field_match(struct dm_report *rh, const char *field, size_t flen,
 			unsigned report_type_only)
 {
 	uint32_t f, type;
+	int implicit;
 
 	if (!flen)
 		return 0;
 
-	if ((_get_field(rh, field, flen, &f))) {
+	if ((_get_field(rh, field, flen, &f, &implicit))) {
 		if (report_type_only) {
-			rh->report_types |= rh->fields[f].type;
+			rh->report_types |= implicit ? _implicit_report_fields[f].type
+						     : rh->fields[f].type;
 			return 1;
 		} else
-			return _add_field(rh, f, 0) ? 1 : 0;
+			return _add_field(rh, f, implicit, 0) ? 1 : 0;
 	}
 
 	if ((type = _all_match(rh, field, flen))) {
@@ -738,13 +848,15 @@ static int _field_match(struct dm_report *rh, const char *field, size_t flen,
 	return 0;
 }
 
-static int _add_sort_key(struct dm_report *rh, uint32_t field_num,
+static int _add_sort_key(struct dm_report *rh, uint32_t field_num, int implicit,
 			 uint32_t flags, unsigned report_type_only)
 {
 	struct field_properties *fp, *found = NULL;
+	const struct dm_report_field_type *fields = implicit ? _implicit_report_fields
+							     : rh->fields;
 
 	dm_list_iterate_items(fp, &rh->field_props) {
-		if (fp->field_num == field_num) {
+		if ((fp->implicit == implicit) && (fp->field_num == field_num)) {
 			found = fp;
 			break;
 		}
@@ -752,8 +864,8 @@ static int _add_sort_key(struct dm_report *rh, uint32_t field_num,
 
 	if (!found) {
 		if (report_type_only)
-			rh->report_types |= rh->fields[field_num].type;
-		else if (!(found = _add_field(rh, field_num, FLD_HIDDEN)))
+			rh->report_types |= fields[field_num].type;
+		else if (!(found = _add_field(rh, field_num, implicit, FLD_HIDDEN)))
 			return_0;
 	}
 
@@ -762,7 +874,7 @@ static int _add_sort_key(struct dm_report *rh, uint32_t field_num,
 
 	if (found->flags & FLD_SORT_KEY) {
 		log_warn("dm_report: Ignoring duplicate sort field: %s.",
-			 rh->fields[field_num].id);
+			 fields[field_num].id);
 		return 1;
 	}
 
@@ -798,10 +910,13 @@ static int _key_match(struct dm_report *rh, const char *key, size_t len,
 		return 0;
 	}
 
+	for (f = 0; _implicit_report_fields[f].report_fn; f++)
+		if (_is_same_field(_implicit_report_fields[f].id, key, len, rh->field_prefix))
+			return _add_sort_key(rh, f, 1, flags, report_type_only);
+
 	for (f = 0; rh->fields[f].report_fn; f++)
-		if (_is_same_field(rh->fields[f].id, key, len,
-				   rh->field_prefix))
-			return _add_sort_key(rh, f, flags, report_type_only);
+		if (_is_same_field(rh->fields[f].id, key, len, rh->field_prefix))
+			return _add_sort_key(rh, f, 0, flags, report_type_only);
 
 	return 0;
 }
@@ -866,6 +981,40 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 	return 1;
 }
 
+static int _contains_reserved_report_type(const struct dm_report_object_type *types)
+{
+	const struct dm_report_object_type *type, *implicit_type;
+
+	for (implicit_type = _implicit_report_types; implicit_type->data_fn; implicit_type++) {
+		for (type = types; type->data_fn; type++) {
+			if (implicit_type->id & type->id) {
+				log_error(INTERNAL_ERROR "dm_report_init: definition of report "
+					  "types given contains reserved identifier");
+				return 1;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void _dm_report_init_update_types(struct dm_report *rh, uint32_t *report_types)
+{
+	const struct dm_report_object_type *type;
+
+	if (!report_types)
+		return;
+
+	*report_types = rh->report_types;
+	/*
+	 * Do not include implicit types as these are not understood by
+	 * dm_report_init caller - the caller doesn't know how to check
+	 * these types anyway.
+	 */
+	for (type = _implicit_report_types; type->data_fn; type++)
+		*report_types &= ~type->id;
+}
+
 struct dm_report *dm_report_init(uint32_t *report_types,
 				 const struct dm_report_object_type *types,
 				 const struct dm_report_field_type *fields,
@@ -883,6 +1032,9 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 		return 0;
 	}
 
+	if (_contains_reserved_report_type(types))
+		return_0;
+
 	/*
 	 * rh->report_types is updated in _parse_fields() and _parse_keys()
 	 * to contain all types corresponding to the fields specified by
@@ -941,9 +1093,10 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 		return NULL;
 	}
 
-	/* Return updated types value for further compatility check by caller */
-	if (report_types)
-		*report_types = rh->report_types;
+	/*
+	 * Return updated types value for further compatility check by caller.
+	 */
+	_dm_report_init_update_types(rh, report_types);
 
 	return rh;
 }
@@ -985,12 +1138,24 @@ int dm_report_set_output_field_name_prefix(struct dm_report *rh, const char *out
 static void *_report_get_field_data(struct dm_report *rh,
 				    struct field_properties *fp, void *object)
 {
+	const struct dm_report_field_type *fields = fp->implicit ? _implicit_report_fields
+								 : rh->fields;
+
 	char *ret = fp->type->data_fn(object);
 
 	if (!ret)
 		return NULL;
 
-	return (void *)(ret + rh->fields[fp->field_num].offset);
+	return (void *)(ret + fields[fp->field_num].offset);
+}
+
+static void *_report_get_implicit_field_data(struct dm_report *rh __attribute__((unused)),
+					     struct field_properties *fp, struct row *row)
+{
+	if (!strcmp(_implicit_report_fields[fp->field_num].id, COMMON_FIELD_SELECTED_ID))
+		return row;
+
+	return NULL;
 }
 
 static int _cmp_field_int(const char *field_id, uint64_t a, uint64_t b, uint32_t flags)
@@ -1138,7 +1303,9 @@ static int _compare_selection_field(struct dm_report *rh,
 				    struct dm_report_field *f,
 				    struct field_selection *fs)
 {
-	const char *field_id = rh->fields[f->props->field_num].id;
+	const struct dm_report_field_type *fields = f->props->implicit ? _implicit_report_fields
+								       : rh->fields;
+	const char *field_id = fields[f->props->field_num].id;
 	int r = 0;
 
 	if (!f->sort_value) {
@@ -1226,9 +1393,10 @@ static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
 
 int dm_report_object(struct dm_report *rh, void *object)
 {
+	const struct dm_report_field_type *fields;
 	struct field_properties *fp;
 	struct row *row = NULL;
-	struct dm_report_field *field;
+	struct dm_report_field *field, *field_sel_status = NULL;
 	void *data = NULL;
 	int len;
 	int r = 0;
@@ -1255,6 +1423,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	}
 
 	dm_list_init(&row->fields);
+	row->selected = 1;
 
 	/* For each field to be displayed, call its report_fn */
 	dm_list_iterate_items(fp, &rh->field_props) {
@@ -1263,21 +1432,31 @@ int dm_report_object(struct dm_report *rh, void *object)
 				  "struct dm_report_field allocation failed");
 			goto out;
 		}
+
+		if (fp->implicit) {
+			fields = _implicit_report_fields;
+			if (!strcmp(fields[fp->field_num].id, COMMON_FIELD_SELECTED_ID))
+				field_sel_status = field;
+		} else
+			fields = rh->fields;
+
 		field->props = fp;
 
-		if (!(data = _report_get_field_data(rh, fp, object))) {
+		data = fp->implicit ? _report_get_implicit_field_data(rh, fp, row)
+				    : _report_get_field_data(rh, fp, object);
+		if (!data) {
 			log_error("dm_report_object: "
 				  "no data assigned to field %s",
-				  rh->fields[fp->field_num].id);
+				  fields[fp->field_num].id);
 			goto out;
 		}
 
-		if (!rh->fields[fp->field_num].report_fn(rh, rh->mem,
+		if (!fields[fp->field_num].report_fn(rh, rh->mem,
 							 field, data,
 							 rh->private)) {
 			log_error("dm_report_object: "
 				  "report function failed for field %s",
-				  rh->fields[fp->field_num].id);
+				  fields[fp->field_num].id);
 			goto out;
 		}
 
@@ -1285,8 +1464,29 @@ int dm_report_object(struct dm_report *rh, void *object)
 	}
 
 	if (!_check_report_selection(rh, &row->fields)) {
-		r = 1;
-		goto out;
+		if (!field_sel_status) {
+			r = 1;
+			goto out;
+		}
+		/*
+		 * If field with id "selected" is reported,
+		 * report the row although it does not pass
+		 * the selection criteria.
+		 * The "selected" field reports the result
+		 * of the selection.
+		 */
+		row->selected = 0;
+		_implicit_report_fields[field_sel_status->props->field_num].report_fn(rh,
+						rh->mem, field_sel_status, row, rh->private);
+		/*
+		 * If the "selected" field is not displayed, e.g.
+		 * because it is part of the sort field list,
+		 * skip the display of the row as usual.
+		 */
+		if (field_sel_status->props->flags & FLD_HIDDEN) {
+			r = 1;
+			goto out;
+		}
 	}
 
 	dm_list_add(&rh->rows, &row->list);
@@ -1916,6 +2116,7 @@ static const char *_tok_field_name(const char *s,
 
 static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       uint32_t field_num,
+						       int implicit,
 						       const char *v,
 						       size_t len,
 						       uint32_t flags,
@@ -1923,6 +2124,8 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						       void *custom)
 {
 	static const char *_out_of_range_msg = "Field selection value %s out of supported range for field %s.";
+	const struct dm_report_field_type *fields = implicit ? _implicit_report_fields
+							     : rh->fields;
 	struct field_properties *fp, *found = NULL;
 	struct field_selection *fs;
 	const char *field_id;
@@ -1930,7 +2133,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	char *s;
 
 	dm_list_iterate_items(fp, &rh->field_props) {
-		if (fp->field_num == field_num) {
+		if ((fp->implicit == implicit) && (fp->field_num == field_num)) {
 			found = fp;
 			break;
 		}
@@ -1938,12 +2141,12 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 
 	/* The field is neither used in display options nor sort keys. */
 	if (!found) {
-		if (!(found = _add_field(rh, field_num, FLD_HIDDEN)))
+		if (!(found = _add_field(rh, field_num, implicit, FLD_HIDDEN)))
 			return NULL;
-		rh->report_types |= rh->fields[field_num].type;
+		rh->report_types |= fields[field_num].type;
 	}
 
-	field_id = rh->fields[found->field_num].id;
+	field_id = fields[found->field_num].id;
 
 	if (!(found->flags & flags & DM_REPORT_FIELD_TYPE_MASK)) {
 		log_error("dm_report: incompatible comparison "
@@ -2192,6 +2395,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	const char *vs, *ve; /* value */
 	const char *last;
 	uint32_t flags, field_num;
+	int implicit;
 	const struct dm_report_field_type *ft;
 	struct selection_str_list *str_list;
 	const struct dm_report_reserved_value *reserved;
@@ -2207,7 +2411,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	}
 
 	/* check if the field with given name exists */
-	if (!_get_field(rh, ws, (size_t) (we - ws), &field_num)) {
+	if (!_get_field(rh, ws, (size_t) (we - ws), &field_num, &implicit)) {
 		c = we[0];
 		tmp = (char *) we;
 		tmp[0] = '\0';
@@ -2218,7 +2422,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		goto bad;
 	}
 
-	ft = &rh->fields[field_num];
+	ft = implicit ? &_implicit_report_fields[field_num]
+		      : &rh->fields[field_num];
 
 	/* comparison operator */
 	if (!(flags = _tok_op_cmp(we, &last))) {
@@ -2262,7 +2467,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	*next = _skip_space(last);
 
 	/* create selection */
-	if (!(fs = _create_field_selection(rh, field_num, vs, (size_t) (ve - vs), flags, reserved, custom)))
+	if (!(fs = _create_field_selection(rh, field_num, implicit, vs, (size_t) (ve - vs), flags, reserved, custom)))
 		return_NULL;
 
 	/* create selection node */
@@ -2410,6 +2615,9 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 	struct selection_node *root = NULL;
 	const char *fin, *next;
 
+	_implicit_report_types = _implicit_common_report_types;
+	_implicit_report_fields = _implicit_common_report_fields;
+
 	if (!(rh = dm_report_init(report_types, types, fields, output_fields,
 			output_separator, output_flags, sort_keys, private_data)))
 		return NULL;
@@ -2449,8 +2657,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		goto error;
 	}
 
-	if (report_types)
-		*report_types = rh->report_types;
+	_dm_report_init_update_types(rh, report_types);
 
 	rh->selection_root = root;
 	return rh;
@@ -2464,6 +2671,7 @@ error:
  */
 static int _report_headings(struct dm_report *rh)
 {
+	const struct dm_report_field_type *fields;
 	struct field_properties *fp;
 	const char *heading;
 	char *buf = NULL;
@@ -2500,7 +2708,9 @@ static int _report_headings(struct dm_report *rh)
 		if (fp->flags & FLD_HIDDEN)
 			continue;
 
-		heading = rh->fields[fp->field_num].heading;
+		fields = fp->implicit ? _implicit_report_fields : rh->fields;
+
+		heading = fields[fp->field_num].heading;
 		if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
 			if (dm_snprintf(buf, buf_size, "%-*.*s",
 					 fp->width, fp->width, heading) < 0) {
@@ -2616,6 +2826,8 @@ static int _sort_rows(struct dm_report *rh)
  */
 static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 {
+	const struct dm_report_field_type *fields = field->props->implicit ? _implicit_report_fields
+									   : rh->fields;
 	char *field_id;
 	int32_t width;
 	uint32_t align;
@@ -2624,7 +2836,7 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
 	size_t buf_size = 0;
 
 	if (rh->flags & DM_REPORT_OUTPUT_FIELD_NAME_PREFIX) {
-		if (!(field_id = dm_strdup(rh->fields[field->props->field_num].id))) {
+		if (!(field_id = dm_strdup(fields[field->props->field_num].id))) {
 			log_error("dm_report: Failed to copy field name");
 			return 0;
 		}
@@ -2715,6 +2927,7 @@ bad:
 
 static int _output_as_rows(struct dm_report *rh)
 {
+	const struct dm_report_field_type *fields;
 	struct field_properties *fp;
 	struct dm_report_field *field;
 	struct row *row;
@@ -2728,13 +2941,15 @@ static int _output_as_rows(struct dm_report *rh)
 			continue;
 		}
 
+		fields = fp->implicit ? _implicit_report_fields : rh->fields;
+
 		if (!dm_pool_begin_object(rh->mem, 512)) {
 			log_error("dm_report: Unable to allocate output line");
 			return 0;
 		}
 
 		if ((rh->flags & DM_REPORT_OUTPUT_HEADINGS)) {
-			if (!dm_pool_grow_object(rh->mem, rh->fields[fp->field_num].heading, 0)) {
+			if (!dm_pool_grow_object(rh->mem, fields[fp->field_num].heading, 0)) {
 				log_error("dm_report: Failed to extend row for field name");
 				goto bad;
 			}


