From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:28 +0000 (UTC)
Subject: master - report: make report options defined by "-o" groupable
Message-ID: <20151030145228.20E5D609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df190dcfa58ee3c7cc9959da6af3ae22e9618992
Commit:        df190dcfa58ee3c7cc9959da6af3ae22e9618992
Parent:        e149fe7fdfd22b496bbd870d19412b0e9f090149
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 21 14:57:49 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

report: make report options defined by "-o" groupable

Also, besides making "-o" groupable, use string lists to store
lists of options temporarily while processing all instances of
the "-o" group.
---
 tools/args.h     |    2 +-
 tools/reporter.c |   61 ++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index c887774..210545e 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -185,7 +185,7 @@ arg(name_ARG, 'n', "name", string_arg, 0)
 arg(nofsck_ARG, 'n', "nofsck", NULL, 0)
 arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0)
 arg(oldpath_ARG, 'n', "oldpath", NULL, 0)
-arg(options_ARG, 'o', "options", string_arg, 0)
+arg(options_ARG, 'o', "options", string_arg, ARG_GROUPABLE)
 arg(sort_ARG, 'O', "sort", string_arg, 0)
 arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0)
 arg(permission_ARG, 'p', "permission", permission_arg, 0)
diff --git a/tools/reporter.c b/tools/reporter.c
index 4cf099b..f053b08 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -606,26 +606,57 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 
 static int _get_report_options(struct cmd_context *cmd, const char **options)
 {
+	struct arg_value_group_list *current_group;
+	struct dm_list *final_opts_list;
+	struct dm_list *opts_list = NULL;
 	const char *opts;
-	char *str;
+	int r = ECMD_PROCESSED;
 
-	opts = arg_str_value(cmd, options_ARG, "");
-	if (!opts || !*opts) {
-		log_error("Invalid options string: %s", opts);
-		return EINVALID_CMD_LINE;
+	if (!(final_opts_list = str_to_str_list(NULL, *options, ",", 1))) {
+		r = ECMD_FAILED;
+		goto_out;
 	}
-	if (*opts == '+') {
-		if (!(str = dm_pool_alloc(cmd->mem,
-				 strlen(*options) + strlen(opts) + 1))) {
-			log_error("options string allocation failed");
-			return ECMD_FAILED;
+
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, options_ARG))
+			continue;
+
+		opts = grouped_arg_str_value(current_group->arg_values, options_ARG, NULL);
+		if (!opts || !*opts) {
+			log_error("Invalid options string: %s", opts);
+			r = EINVALID_CMD_LINE;
+			goto out;
 		}
-		(void) sprintf(str, "%s,%s", *options, opts + 1);
-		*options = str;
-	} else
-		*options = opts;
 
-	return ECMD_PROCESSED;
+		switch (*opts) {
+			case '+':
+				if (!(opts_list = str_to_str_list(NULL, opts + 1, ",", 1))) {
+					r = ECMD_FAILED;
+					goto_out;
+				}
+				dm_list_splice(final_opts_list, opts_list);
+				str_list_destroy(opts_list, 1);
+				opts_list = NULL;
+				break;
+			default:
+				str_list_destroy(final_opts_list, 1);
+				if (!(final_opts_list = str_to_str_list(NULL, opts, ",", 1))) {
+					r = ECMD_FAILED;
+					goto out;
+				}
+		}
+	}
+
+	if (!(*options = str_list_to_str(cmd->mem, final_opts_list, ","))) {
+		r = ECMD_FAILED;
+		goto out;
+	}
+out:
+	if (opts_list)
+		str_list_destroy(final_opts_list, 1);
+	if (final_opts_list)
+		str_list_destroy(final_opts_list, 1);
+	return r;
 }
 
 static int _report(struct cmd_context *cmd, int argc, char **argv,


