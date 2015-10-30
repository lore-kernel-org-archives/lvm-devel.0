From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:34 +0000 (UTC)
Subject: master - report: recognize known prefix when processing "-o -field_name1, field_name2, ..."
Message-ID: <20151030145234.71E77609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baf320455b06141eb472faa687e7fcdc838bdd8c
Commit:        baf320455b06141eb472faa687e7fcdc838bdd8c
Parent:        bb4d3fa7a70881b72ddf61cba02760b89cf07b53
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 22 14:30:11 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

report: recognize known prefix when processing "-o -field_name1,field_name2,..."

---
 tools/reporter.c |   35 +++++++++++++++++++++++++++++++----
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 591f4ed..f4f9b71 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -604,22 +604,48 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 	}
 }
 
-static void _del_option_from_list(struct dm_list *sll, const char *str)
+static void _del_option_from_list(struct dm_list *sll, const char *prefix,
+				  size_t prefix_len, const char *str)
 {
 	struct dm_list *slh;
 	struct dm_str_list *sl;
+	const char *a = str, *b;
 
+	prefix_len--;
 	dm_list_uniterate(slh, sll, sll) {
 		sl = dm_list_item(slh, struct dm_str_list);
+
+		/* exact match */
 		if (!strcmp(str, sl->str)) {
 			dm_list_del(slh);
 			return;
 		}
+
+		/* also try to match with known prefix */
+		b = sl->str;
+		if (!strncmp(prefix, a, prefix_len)) {
+			a += prefix_len;
+			if (*a == '_')
+				a++;
+		}
+		if (!strncmp(prefix, b, prefix_len)) {
+			b += prefix_len;
+			if (*b == '_')
+				b++;
+		}
+		if (!strcmp(a, b)) {
+			dm_list_del(slh);
+			return;
+		}
 	}
 }
 
-static int _get_report_options(struct cmd_context *cmd, const char **options)
+static int _get_report_options(struct cmd_context *cmd,
+			       report_type_t report_type,
+			       const char **options)
 {
+	const char *prefix = report_get_field_prefix(report_type);
+	size_t prefix_len = strlen(prefix);
 	struct arg_value_group_list *current_group;
 	struct dm_list *final_opts_list;
 	struct dm_list *opts_list = NULL;
@@ -655,7 +681,8 @@ static int _get_report_options(struct cmd_context *cmd, const char **options)
 					dm_list_splice(final_opts_list, opts_list);
 				} else if (*opts == '-') {
 					dm_list_iterate_items(sl, opts_list)
-						_del_option_from_list(final_opts_list, sl->str);
+						_del_option_from_list(final_opts_list, prefix,
+								      prefix_len, sl->str);
 				}
 				str_list_destroy(opts_list, 1);
 				opts_list = NULL;
@@ -765,7 +792,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	/* If -o supplied use it, else use default for report_type */
 	if (arg_count(cmd, options_ARG) &&
-	    ((r = _get_report_options(cmd, &options) != ECMD_PROCESSED)))
+	    ((r = _get_report_options(cmd, report_type, &options) != ECMD_PROCESSED)))
 		return r;
 
 	/* -O overrides default sort settings */


