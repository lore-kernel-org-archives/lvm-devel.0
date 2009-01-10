From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2009 03:01:36 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20090110030136.16081.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-10 03:01:36

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Add an "all" field which expands to all fields of the report type.
	
	For example in LVM2, "pv_all" gives all PV fields.
	"seg_all" gives all LV segment fields.
	
	"all" gives all fields of the final report type.  I think this is more
	useful than just adding the current prefix.
	
	So "lvs -o seg_all" gives all the LV segment fields, whilst
	"lvs --segments -o all" adds in LV and VG fields too.
	
	"lvs -o all -O vg_name" has report type LVS+VGS so includes all LV and all
	VG fields.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.259&r2=1.260
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW_DM	2009/01/07 12:17:40	1.259
+++ LVM2/WHATS_NEW_DM	2009/01/10 03:01:35	1.260
@@ -1,5 +1,6 @@
 Version 1.02.30 -
 ====================================
+  Add "all" field to reports expanding to all fields of report type.
   Add checks for device names in dmsetup and show proper error messages.
   Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines
 
--- LVM2/libdm/libdm-report.c	2008/11/03 22:14:29	1.26
+++ LVM2/libdm/libdm-report.c	2009/01/10 03:01:35	1.27
@@ -300,8 +300,6 @@
 {
 	struct field_properties *fp;
 
-	rh->report_types |= rh->fields[field_num].type;
-
 	if (!(fp = dm_pool_zalloc(rh->mem, sizeof(struct field_properties)))) {
 		log_error("dm_report: struct field_properties allocation "
 			  "failed");
@@ -352,23 +350,73 @@
 	return 0;
 }
 
-static int _field_match(struct dm_report *rh, const char *field, size_t flen)
+/*
+ * Check for a report type prefix + "all" match.
+ */
+static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
+{
+	size_t prefix_len;
+	const struct dm_report_object_type *t;
+
+	if (!strncasecmp(field, "all", 3) && flen == 3)
+		return rh->report_types;
+
+	for (t = rh->types; t->data_fn; t++) {
+		prefix_len = strlen(t->prefix);
+		if (!strncasecmp(t->prefix, field, prefix_len) &&
+		    !strncasecmp(field + prefix_len, "all", 3) &&
+		    flen == prefix_len + 3)
+			return t->id;
+	}
+
+	return 0;
+}
+
+/*
+ * Add all fields with a matching type.
+ */
+static int _add_all_fields(struct dm_report *rh, uint32_t type)
 {
 	uint32_t f;
 
+	for (f = 0; rh->fields[f].report_fn; f++)
+		if ((rh->fields[f].type & type) && !_add_field(rh, f, 0))
+			return 0;
+
+	return 1;
+}
+
+static int _field_match(struct dm_report *rh, const char *field, size_t flen,
+			unsigned report_type_only)
+{
+	uint32_t f, type;
+
 	if (!flen)
 		return 0;
 
 	for (f = 0; rh->fields[f].report_fn; f++)
 		if (_is_same_field(rh->fields[f].id, field, flen,
-				   rh->field_prefix))
-			return _add_field(rh, f, 0) ? 1 : 0;
+				   rh->field_prefix)) {
+			if (report_type_only) {
+				rh->report_types |= rh->fields[f].type;
+				return 1;
+			} else
+				return _add_field(rh, f, 0) ? 1 : 0;
+		}
+
+	if ((type = _all_match(rh, field, flen))) {
+		if (report_type_only) {
+			rh->report_types |= type;
+			return 1;
+		} else
+			return  _add_all_fields(rh, type);
+	}
 
 	return 0;
 }
 
 static int _add_sort_key(struct dm_report *rh, uint32_t field_num,
-			 uint32_t flags)
+			 uint32_t flags, unsigned report_type_only)
 {
 	struct field_properties *fp, *found = NULL;
 
@@ -379,8 +427,15 @@
 		}
 	}
 
-	if (!found && !(found = _add_field(rh, field_num, FLD_HIDDEN)))
-		return_0;
+	if (!found) {
+		if (report_type_only)
+			rh->report_types |= rh->fields[field_num].type;
+		else if (!(found = _add_field(rh, field_num, FLD_HIDDEN)))
+			return_0;
+	}
+
+	if (report_type_only)
+		return 1;
 
 	if (found->flags & FLD_SORT_KEY) {
 		log_error("dm_report: Ignoring duplicate sort field: %s",
@@ -395,7 +450,8 @@
 	return 1;
 }
 
-static int _key_match(struct dm_report *rh, const char *key, size_t len)
+static int _key_match(struct dm_report *rh, const char *key, size_t len,
+		      unsigned report_type_only)
 {
 	uint32_t f;
 	uint32_t flags;
@@ -422,12 +478,13 @@
 	for (f = 0; rh->fields[f].report_fn; f++)
 		if (_is_same_field(rh->fields[f].id, key, len,
 				   rh->field_prefix))
-			return _add_sort_key(rh, f, flags);
+			return _add_sort_key(rh, f, flags, report_type_only);
 
 	return 0;
 }
 
-static int _parse_options(struct dm_report *rh, const char *format)
+static int _parse_options(struct dm_report *rh, const char *format,
+			  unsigned report_type_only)
 {
 	const char *ws;		/* Word start */
 	const char *we = format;	/* Word end */
@@ -442,7 +499,7 @@
 		while (*we && *we != ',')
 			we++;
 
-		if (!_field_match(rh, ws, (size_t) (we - ws))) {
+		if (!_field_match(rh, ws, (size_t) (we - ws), report_type_only)) {
 			_display_fields(rh);
 			log_warn(" ");
 			if (strcasecmp(ws, "help") && strcmp(ws, "?"))
@@ -455,7 +512,8 @@
 	return 1;
 }
 
-static int _parse_keys(struct dm_report *rh, const char *keys)
+static int _parse_keys(struct dm_report *rh, const char *keys,
+		       unsigned report_type_only)
 {
 	const char *ws;		/* Word start */
 	const char *we = keys;	/* Word end */
@@ -467,7 +525,7 @@
 		ws = we;
 		while (*we && *we != ',')
 			we++;
-		if (!_key_match(rh, ws, (size_t) (we - ws))) {
+		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
 			log_error("dm_report: Unrecognised field: %.*s",
 				  (int) (we - ws), ws);
 			return 0;
@@ -535,13 +593,20 @@
 		return NULL;
 	}
 
-	/* Generate list of fields for output based on format string & flags */
-	if (!_parse_options(rh, output_fields)) {
+	/*
+	 * To keep the code needed to add the "all" field to a minimum, we parse
+	 * the field lists twice.  The first time we only update the report type.
+	 * FIXME Use one pass instead and expand the "all" field afterwards.
+	 */
+	if (!_parse_options(rh, output_fields, 1) ||
+	    !_parse_keys(rh, sort_keys, 1)) {
 		dm_report_free(rh);
 		return NULL;
 	}
 
-	if (!_parse_keys(rh, sort_keys)) {
+	/* Generate list of fields for output based on format string & flags */
+	if (!_parse_options(rh, output_fields, 0) ||
+	    !_parse_keys(rh, sort_keys, 0)) {
 		dm_report_free(rh);
 		return NULL;
 	}


