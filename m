From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:30 +0000 (UTC)
Subject: master - report: select: show field type in field list if in context of selection
Message-ID: <20140617143430.DAB7860C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a075ec15c4a8e704fbb9519326d0c97371ead2f3
Commit:        a075ec15c4a8e704fbb9519326d0c97371ead2f3
Parent:        6d667adeeab7eb7b88a596ebd998fa0a32a4f61c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 16 14:06:04 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: show field type in field list if in context of selection

When the field list is displayed as help for constructing selection
criteria, show also the field value type. This is useful for users
to know what set of operators are allowed for the type - the subsequent
"Selection operands" section in the help output summarize all known
types that can be used in selection.
---
 libdm/libdm-report.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index df29b6b..1c35166 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -472,10 +472,22 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 		log_warn(INTERNAL_ERROR "Using string as sort value for numerical field.");
 }
 
+static const char *_get_field_type_name(unsigned field_type)
+{
+	switch (field_type) {
+		case DM_REPORT_FIELD_TYPE_STRING: return "string";
+		case DM_REPORT_FIELD_TYPE_NUMBER: return "number";
+		case DM_REPORT_FIELD_TYPE_SIZE: return "size";
+		case DM_REPORT_FIELD_TYPE_STRING_LIST: return "string list";
+		default: return "unknown";
+	}
+}
+
 /*
  * show help message
  */
-static void _display_fields(struct dm_report *rh, int display_all_fields_item)
+static void _display_fields(struct dm_report *rh, int display_all_fields_item
+			    int display_field_types)
 {
 	uint32_t f;
 	const struct dm_report_object_type *type;
@@ -511,7 +523,10 @@ static void _display_fields(struct dm_report *rh, int display_all_fields_item)
 		}
 
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */
-		log_warn("  %-*s - %s", (int) id_len, rh->fields[f].id, rh->fields[f].desc);
+		log_warn("  %-*s - %s%s%s%s", (int) id_len, rh->fields[f].id, rh->fields[f].desc,
+					      display_field_types ? " [" : "",
+					      display_field_types ? _get_field_type_name(rh->fields[f].flags & DM_REPORT_FIELD_TYPE_MASK) : "",
+					      display_field_types ? "]" : "");
 		last_desc = desc;
 	}
 }
@@ -770,7 +785,7 @@ static int _parse_fields(struct dm_report *rh, const char *format,
 			we++;
 
 		if (!_field_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			_display_fields(rh, 1);
+			_display_fields(rh, 1, 0);
 			log_warn(" ");
 			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
 			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
@@ -800,7 +815,7 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			_display_fields(rh, 1);
+			_display_fields(rh, 1, 0);
 			log_warn(" ");
 			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
 			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
@@ -1914,7 +1929,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		c = we[0];
 		tmp = (char *) we;
 		tmp[0] = '\0';
-		_display_fields(rh, 0);
+		_display_fields(rh, 0, 1);
 		log_warn(" ");
 		log_error("Unrecognised selection field: %s", ws);
 		tmp[0] = c;
@@ -2121,7 +2136,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 
 	if (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
 	    !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) {
-		_display_fields(rh, 0);
+		_display_fields(rh, 0, 1);
 		log_warn(" ");
 		_display_selection_help(rh);
 		dm_report_free(rh);


