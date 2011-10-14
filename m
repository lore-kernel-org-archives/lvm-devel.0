From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Oct 2011 16:59:31 +0200
Subject: [PATCH 4/6][devname mangling] Add --manglename arg to dmsetup
Message-ID: <4E984E53.9090403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add --manglename arg to dmsetup to select the name mangling method used
on devname parameter used throughout all dmsetup commands.

By default, it's the value set during configure ("auto" by default).

Peter
---
 tools/dmsetup.c |   30 +++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f35c8a5..b693143 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -126,6 +126,7 @@ enum {
 	GID_ARG,
 	HELP_ARG,
 	INACTIVE_ARG,
+	MANGLENAME_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
 	MODE_ARG,
@@ -1335,6 +1336,7 @@ static int _process_all(const struct command *cmd, int argc, char **argv, int si
 	int r = 1;
 	struct dm_names *names;
 	unsigned next = 0;
+	dm_string_mangle_t nm;
 
 	struct dm_task *dmt;
 
@@ -1360,6 +1362,14 @@ static int _process_all(const struct command *cmd, int argc, char **argv, int si
 		goto out;
 	}
 
+	/*
+	 * We're iterating over the list of device names acquired
+	 * directly from kernel. These names are already mangled
+	 * so disable name mangling termporarily here!
+	 */
+	nm = dm_get_default_name_mangle();
+	dm_set_default_name_mangle(DM_STRING_MANGLE_NONE);
+
 	do {
 		names = (struct dm_names *)((char *) names + next);
 		if (!fn(cmd, argc, argv, names, 1))
@@ -1367,6 +1377,8 @@ static int _process_all(const struct command *cmd, int argc, char **argv, int si
 		next = names->next;
 	} while (next);
 
+	dm_set_default_name_mangle(nm);
+
       out:
 	dm_task_destroy(dmt);
 	return r;
@@ -2806,7 +2818,7 @@ static void _usage(FILE *out)
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
+		"        [--checks] [--manglename <mangle_type>] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
@@ -2816,6 +2828,7 @@ static void _usage(FILE *out)
 		fprintf(out, "\t%s %s\n", _commands[i].name, _commands[i].help);
 	fprintf(out, "\n<device> may be device name or -u <uuid> or "
 		     "-j <major> -m <minor>\n");
+	fprintf(out, "<mangle_type> is one of 'none', 'auto' and 'hex'.\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
 	fprintf(out, "Table_file contents may be supplied on stdin.\n");
 	fprintf(out, "Tree options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
@@ -3168,6 +3181,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"gid", 1, &ind, GID_ARG},
 		{"help", 0, &ind, HELP_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
+		{"manglename", 1, &ind, MANGLENAME_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
@@ -3337,6 +3351,20 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		}
 		if ((ind == INACTIVE_ARG))
 			_switches[INACTIVE_ARG]++;
+		if ((ind == MANGLENAME_ARG)) {
+			_switches[MANGLENAME_ARG]++;
+			if (!strcasecmp(optarg, "none"))
+				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLE_NONE;
+			else if (!strcasecmp(optarg, "auto"))
+				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLE_AUTO;
+			else if (!strcasecmp(optarg, "hex"))
+				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLE_HEX;
+			else {
+				log_error("Unknown name mangle type");
+				return 0;
+			}
+			dm_set_default_name_mangle(_int_args[MANGLENAME_ARG]);
+		}
 		if ((ind == NAMEPREFIXES_ARG))
 			_switches[NAMEPREFIXES_ARG]++;
 		if ((ind == NOFLUSH_ARG))


