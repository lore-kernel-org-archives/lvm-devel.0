From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:04:04 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add help for creating selections
Message-ID: <20140606120404.C953860CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82675bdffcba91900d5d6c1be3fe7c892b778b1e
Commit:        82675bdffcba91900d5d6c1be3fe7c892b778b1e
Parent:        7c6cc37a2a630c1d573b5fb5c01c4c448d1eac6c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:42:14 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:40:36 2014 +0200

report: select: add help for creating selections

The "<lvm command> -S/--select help" shows help (including list of fields to match against):

  Selection operands
  ------------------
    fields              - reporting fields
    numbers             - integer or floating point, non-negative
    strings             - characters quoted by ' or " or unquoted
    string lists        - strings enclosed by [ ] and elements delimitedby logical
                          conjunction (meaning "all items must match") or logical
                          disjunction operator (meaning "at least one item must match")
    regular expression  - characters quoted by ' or " or unquoted

  Selection operators
  -------------------
    Comparison operators:
        =~  - Matching regular expression
        !~  - Not matching regular expression
         =  - Equal to
        !=  - Not equal
        >=  - Greater than or equal to
         >  - Greater than
        <=  - Lesser than or equal to
         <  - Lesser than

    Logical and grouping operators:
        &&  - Logical conjunction
         ,  - Logical conjunction (alternative)
        ||  - Logical disjunction
         /  - Logical disjunction (alternative)
         !  - Logical negation
         (  - Left parenthesis
         )  - Right parenthesis
         [  - List start
         ]  - List end
---
 libdm/libdm-report.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 tools/reporter.c     |    5 ++++-
 2 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 001c7bc..6b2b975 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1817,6 +1817,34 @@ static struct selection_node *_alloc_selection_node(struct dm_pool *mem, uint32_
 	return sn;
 }
 
+static void _display_selection_help(struct dm_report *rh)
+{
+	struct op_def *t;
+
+	log_warn("Selection operands");
+	log_warn("------------------");
+	log_warn("  fields              - reporting fields");
+	log_warn("  numbers	        - integer or floating point, non-negative");
+	log_warn("  strings	        - characters quoted by \' or \" or unquoted");
+	log_warn("  string lists	- strings enclosed by [ ] and elements delimited by logical");
+	log_warn("                        conjunction (meaning \"all items must match\") or logical");
+	log_warn("                        disjunction operator (meaning \"at least one item must match\")");
+	log_warn("  regular expression  - characters quoted by \' or \" or unquoted");
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
@@ -1866,6 +1894,8 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		c = we[0];
 		tmp = (char *) we;
 		tmp[0] = '\0';
+		_display_fields(rh);
+		log_warn(" ");
 		log_error("Unrecognised selection field: %s", ws);
 		tmp[0] = c;
 		goto bad;
@@ -1875,10 +1905,12 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 
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
@@ -1887,6 +1919,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	if ((flags & FLD_CMP_NUMBER) &&
 	    (ft->flags != DM_REPORT_FIELD_TYPE_NUMBER) &&
 	    (ft->flags != DM_REPORT_FIELD_TYPE_SIZE)) {
+		_display_selection_help(rh);
 		log_error("Operator can be used only with numeric or size fields: %s", ws);
 		goto bad;
 	}
@@ -2066,6 +2099,15 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return rh;
 	}
 
+	if (!strcasecmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP) ||
+	    !strcmp(selection, DM_REPORT_FIELD_RESERVED_NAME_HELP_ALT)) {
+		_display_fields(rh);
+		log_warn(" ");
+		_display_selection_help(rh);
+		dm_report_free(rh);
+		return NULL;
+	}
+
 	if (!(root = _alloc_selection_node(rh->mem, SEL_OR)))
 		return_0;
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 9ff6e72..7935672 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -376,7 +376,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
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


