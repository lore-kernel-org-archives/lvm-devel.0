From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:57:00 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: add --select arg to dmsetup
Message-ID: <20140509065700.8CDF060DED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e444773af0eed95026fd0b5f5f5850c9ee3e5a9
Commit:        5e444773af0eed95026fd0b5f5f5850c9ee3e5a9
Parent:        4966d6bf9681f94779edc333b05bfcdee58c2770
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 11:58:31 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: add --select arg to dmsetup

---
 tools/dmsetup.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9131e67..4a33c7a 100644
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
@@ -2932,6 +2933,13 @@ static int _report_init(const struct command *cmd)
 	if (field_prefixes)
 		dm_report_set_output_field_name_prefix(_report, "dm_");
 
+	if (_switches[SELECT_ARG] &&
+	    !dm_report_set_output_selection(_report, &_report_type,
+					    _string_args[SELECT_ARG])) {
+		err("Failed to set report output selection.");
+		goto out;
+	}
+
 	r = 1;
 
 out:
@@ -3103,7 +3111,8 @@ static void _usage(FILE *out)
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
-		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
+		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
+		"        [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _commands[i].name, _commands[i].help);
 	fprintf(out, "\n<device> may be device name or -u <uuid> or "
@@ -3510,6 +3519,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"readonly", 0, &ind, READ_ONLY},
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"columns", 0, &ind, COLS_ARG},
+		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
@@ -3607,7 +3617,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:ru:U:vy",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;
@@ -3641,6 +3651,10 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
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


