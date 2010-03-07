From: Milan Broz <mbroz@redhat.com>
Date: Sun,  7 Mar 2010 11:32:44 +0100
Subject: [PATCH 2/2] Add --help dmsetup option as the synonym for help command.
In-Reply-To: <1267957964-2436-1-git-send-email-mbroz@redhat.com>
References: <1267957964-2436-1-git-send-email-mbroz@redhat.com>
Message-ID: <1267957964-2436-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Many people (including myself) are repeatedly confused
that dmsetup doesn't understand usual --help option...
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |    4 ++++
 tools/dmsetup.c  |   14 ++++++++++++--
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 425ab88..1dc4904 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,7 @@
 Version 1.02.45 -
 ====================================
   Add --showkeys parameter description into dmsetup man page.
+  Add --help option as the synonym for help command.
 
 Version 1.02.44 - 15th February 2010
 ====================================
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 8a5eca8..9d2dcf2 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -112,6 +112,10 @@ Invoking the command as \fBdevmap_name\fP is equivalent to
 .IP \fB-c|-C|--columns
 .br
 Display output in columns rather than as Field: Value lines.
+.IP \fB-h|--help
+.br
+Outputs a summary of the commands available, optionally including
+the list of report fields (synonym with \fBhelp\fP command).
 .IP \fB--inactive
 .br
 When returning any table information from the kernel report on the 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 74af6f1..69fa128 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -124,6 +124,7 @@ enum {
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
+	HELP_ARG,
 	INACTIVE_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
@@ -2720,7 +2721,8 @@ static void _usage(FILE *out)
 	int i;
 
 	fprintf(out, "Usage:\n\n");
-	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
+	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
+		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie] [--noudevrules] [--noudevsync] [-y|--yes]\n"
 		"        [--readahead [+]<sectors>|auto|none]\n"
@@ -3083,6 +3085,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
+		{"help", 0, &ind, HELP_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
@@ -3167,10 +3170,12 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:j:m:M:no:O:ru:U:vy",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:ru:U:vy",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;
+		if (c == 'h' || ind == HELP_ARG)
+			_switches[HELP_ARG]++;
 		if (c == 'c' || c == 'C' || ind == COLS_ARG)
 			_switches[COLS_ARG]++;
 		if (c == 'f' || ind == FORCE_ARG)
@@ -3329,6 +3334,11 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
+	if (_switches[HELP_ARG]) {
+		c = _find_command("help");
+		goto doit;
+	}
+
 	if (_switches[VERSION_ARG]) {
 		c = _find_command("version");
 		goto doit;
-- 
1.7.0


