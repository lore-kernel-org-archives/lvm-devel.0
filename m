From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:28 +0000 (UTC)
Subject: master - report: select: add help for creating selections
Message-ID: <20140617143428.C1D5460C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d667adeeab7eb7b88a596ebd998fa0a32a4f61c
Commit:        6d667adeeab7eb7b88a596ebd998fa0a32a4f61c
Parent:        03a3f6078de3790a6fca3db8deb4bd204df611f1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:42:14 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: add help for creating selections

The "<lvm command> -S/--select help" shows help (including list of fields to match against):

  ...field list here including the field type name...

  Selection operands
  ------------------
    field               - Reporting field.
    number              - Non-negative integer value.
    size                - Floating point value with units specified.
    string              - Characters quoted by ' or " or unquoted.
    string list         - Strings enclosed by [ ] and elements delimited by either
                          "all items must match" or "at least one item must match" operator.
    regular expression  - Characters quoted by ' or " or unquoted.

  Selection operators
  -------------------
    Comparison operators:
        =~  - Matching regular expression.
        !~  - Not matching regular expression.
         =  - Equal to.
        !=  - Not equal to.
        >=  - Greater than or equal to.
         >  - Greater than
        <=  - Less than or equal to.
         <  - Less than.

    Logical and grouping operators:
        &&  - All fields must match
         ,  - All fields must match
        ||  - At least one field must match
         #  - At least one field must match
         !  - Logical negation
         (  - Left parenthesis
         )  - Right parenthesis
         [  - List start
         ]  - List end
---
 libdm/libdm-report.c |   56 ++++++++++++++++++++++++++++++++++++++++++++-----
 tools/reporter.c     |    5 +++-
 2 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 380c4dc..df29b6b 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -475,7 +475,7 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 /*
  * show help message
  */
-static void _display_fields(struct dm_report *rh)
+static void _display_fields(struct dm_report *rh, int display_all_fields_item)
 {
 	uint32_t f;
 	const struct dm_report_object_type *type;
@@ -503,9 +503,11 @@ static void _display_fields(struct dm_report *rh)
 			log_warn("%*.*s", (int) strlen(desc) + 7,
 				 (int) strlen(desc) + 7,
 				 "-------------------------------------------------------------------------------");
-			log_warn("  %sall%-*s - %s", type->prefix,
-				 (int) (id_len - 3 - strlen(type->prefix)), "",
-				 "All fields in this section.");
+			if (display_all_fields_item) {
+				log_warn("  %sall%-*s - %s", type->prefix,
+					 (int) (id_len - 3 - strlen(type->prefix)), "",
+					 "All fields in this section.");
+			}
 		}
 
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */
@@ -768,7 +770,7 @@ static int _parse_fields(struct dm_report *rh, const char *format,
 			we++;
 
 		if (!_field_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			_display_fields(rh);
+			_display_fields(rh, 1);
 			log_warn(" ");
 			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
 			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
@@ -798,7 +800,7 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			_display_fields(rh);
+			_display_fields(rh, 1);
 			log_warn(" ");
 			if (strcasecmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP) &&
 			    strcmp(ws, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))
@@ -1835,6 +1837,34 @@ static struct selection_node *_alloc_selection_node(struct dm_pool *mem, uint32_
 	return sn;
 }
 
+static void _display_selection_help(struct dm_report *rh)
+{
+	struct op_def *t;
+
+	log_warn("Selection operands");
+	log_warn("------------------");
+	log_warn("  field               - Reporting field.");
+	log_warn("  number              - Non-negative integer value.");
+	log_warn("  size                - Floating point value with units, 'm' unit used by default if not specified.");
+	log_warn("  string              - Characters quoted by \' or \" or unquoted.");
+	log_warn("  string list         - Strings enclosed by [ ] and elements delimited by either");
+	log_warn("                        \"all items must match\" or \"at least one item must match\" operator.");
+	log_warn("  regular expression  - Characters quoted by \' or \" or unquoted.");
+	log_warn(" ");
+	log_warn("Selection operators");
+	log_warn("-------------------");
+	log_warn("  Comparison operators:");
+	t = _op_cmp;
+	for (; t->string; t++)
+		log_warn("    %4s  - %s", t->string, t->desc);
+	log_warn(" ");
+	log_warn("  Logical and grouping operators:");
+	t = _op_log;
+	for (; t->string; t++)
+		log_warn("    %4s  - %s", t->string, t->desc);
+	log_warn(" ");
+}
+
 static char _sel_syntax_error_at_msg[] = "Selection syntax error at '%s'.";
 
 /*
@@ -1884,6 +1914,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		c = we[0];
 		tmp = (char *) we;
 		tmp[0] = '\0';
+		_display_fields(rh, 0);
+		log_warn(" ");
 		log_error("Unrecognised selection field: %s", ws);
 		tmp[0] = c;
 		goto bad;
@@ -1893,10 +1925,12 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 
 	/* comparison operator */
 	if (!(flags = _tok_op_cmp(we, &last))) {
+		_display_selection_help(rh);
 		log_error("Unrecognised comparison operator: %s", we);
 		goto bad;
 	}
 	if (!last) {
+		_display_selection_help(rh);
 		log_error("Missing value after operator");
 		goto bad;
 	}
@@ -1905,6 +1939,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	if ((flags & FLD_CMP_NUMBER) &&
 	    (ft->flags != DM_REPORT_FIELD_TYPE_NUMBER) &&
 	    (ft->flags != DM_REPORT_FIELD_TYPE_SIZE)) {
+		_display_selection_help(rh);
 		log_error("Operator can be used only with numeric or size fields: %s", ws);
 		goto bad;
 	}
@@ -2084,6 +2119,15 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return rh;
 	}
 
+	if (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
+	    !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) {
+		_display_fields(rh, 0);
+		log_warn(" ");
+		_display_selection_help(rh);
+		dm_report_free(rh);
+		return NULL;
+	}
+
 	if (!(root = _alloc_selection_node(rh->mem, SEL_OR)))
 		return_0;
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 56980cf..1e91f8f 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -358,7 +358,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		if ( (!strcasecmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
 		      !strcmp(options, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) ||
 		     (!strcasecmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
-		      !strcmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) )
+		      !strcmp(keys, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) ||
+		     (selection &&
+		      (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
+		       !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT))) )
 			return r;
 		return_ECMD_FAILED;
 	}


