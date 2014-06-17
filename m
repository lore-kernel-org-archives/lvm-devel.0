From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:11 +0000 (UTC)
Subject: master - report: select: add --select arg to dmsetup
Message-ID: <20140617143411.8DCDD60C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a1c7e5d785a75016f5326ed6464da3b5e2d6a8a
Commit:        3a1c7e5d785a75016f5326ed6464da3b5e2d6a8a
Parent:        bc6458de878af27667612ff7873243454bb63566
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:38:49 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:20 2014 +0200

report: select: add --select arg to dmsetup

---
 tools/dmsetup.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index fd87d42..1a5e068 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -120,6 +120,7 @@ enum {
 	ADD_NODE_ON_RESUME_ARG,
 	CHECKS_ARG,
 	COLS_ARG,
+	SELECT_ARG,
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
@@ -2846,6 +2847,7 @@ static int _report_init(const struct command *cmd)
 	char *options = (char *) default_report_options;
 	const char *keys = "";
 	const char *separator = " ";
+	const char *selection = NULL;
 	int aligned = 1, headings = 1, buffered = 1, field_prefixes = 0;
 	int quoted = 1, columns_as_rows = 0;
 	uint32_t flags = 0;
@@ -2909,6 +2911,9 @@ static int _report_init(const struct command *cmd)
 		aligned = 0;
 	}
 
+	if (_switches[SELECT_ARG] && _string_args[SELECT_ARG])
+		selection = _string_args[SELECT_ARG];
+
 	if (aligned)
 		flags |= DM_REPORT_OUTPUT_ALIGNED;
 
@@ -2927,9 +2932,9 @@ static int _report_init(const struct command *cmd)
 	if (columns_as_rows)
 		flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
 
-	if (!(_report = dm_report_init(&_report_type,
-				       _report_types, _report_fields,
-				       options, separator, flags, keys, NULL)))
+	if (!(_report = dm_report_init_with_selection(&_report_type, _report_types,
+				_report_fields, options, separator, flags, keys,
+				selection, NULL)))
 		goto out;
 
 	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {
@@ -3111,7 +3116,8 @@ static void _usage(FILE *out)
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
-		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
+		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
+		"        [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _commands[i].name, _commands[i].help);
 	fprintf(out, "\n<device> may be device name or -u <uuid> or "
@@ -3518,6 +3524,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"readonly", 0, &ind, READ_ONLY},
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"columns", 0, &ind, COLS_ARG},
+		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
@@ -3615,7 +3622,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:ru:U:vy",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;
@@ -3649,6 +3656,10 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			_switches[SORT_ARG]++;
 			_string_args[SORT_ARG] = optarg;
 		}
+		if (c == 'S' || ind == SELECT_ARG) {
+			_switches[SELECT_ARG]++;
+			_string_args[SELECT_ARG] = optarg;
+		}
 		if (c == 'v' || ind == VERBOSE_ARG)
 			_switches[VERBOSE_ARG]++;
 		if (c == 'u' || ind == UUID_ARG) {


