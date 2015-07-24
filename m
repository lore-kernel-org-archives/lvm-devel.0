From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 24 Jul 2015 18:49:20 +0000 (UTC)
Subject: master - tools: Streamline long option hyphen removal.
Message-ID: <20150724184920.538AC60B92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=705caa8c32782a9b42cdd05138cf61536e0a99f9
Commit:        705caa8c32782a9b42cdd05138cf61536e0a99f9
Parent:        c1f5ac3eca1ebccc08fdc3f9304e3d85fa115146
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 24 19:45:49 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 24 19:45:49 2015 +0100

tools: Streamline long option hyphen removal.

---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   48 ++++++++++++++++++++++++++----------------------
 2 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 03e76c7..8f74625 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix long option hyphen removal. (2.02.122)
   Fix clvmd freeze if client disappears without first releasing its locks.
   Fix lvconvert segfaults while performing snapshots merge.
   Ignore errors during detection if use_blkid_wiping=1 and --force is used.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 403948a..9e0d029 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1463,8 +1463,6 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_ARG_LEN 64
-
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft;
@@ -1472,10 +1470,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int ret = 0;
 	int locking_type;
 	int monitoring;
-	char arg_new[MAX_ARG_LEN];
-	char *arg;
-	int quit_arg_hyphen_removal;
-	int i, j, j_new;
+	char *arg_new, *arg;
+	int i;
+	int skip_hyphens;
 
 	init_error_message_produced(0);
 
@@ -1484,28 +1481,35 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	/* eliminate '-' from all options starting with -- */
 	for (i = 1; i < argc; i++) {
-		quit_arg_hyphen_removal = 0;
+
 		arg = argv[i];
 
-		if (arg[0] == '-' && arg[1] == '-' && strlen(arg) == 2)
+		if (*arg++ != '-' || *arg++ != '-')
+			continue;
+
+		/* If we reach "--" then stop. */
+		if (!*arg)
 			break;
 
-		if (arg[0] == '-' && arg[1] == '-' && strlen(arg) < MAX_ARG_LEN) {
-			memset(arg_new, 0, sizeof(arg_new));
-			arg_new[0] = '-';
-			arg_new[1] = '-';
-
-			for (j = 2, j_new = 2; j < strlen(arg) + 1; j++) {
-				if (arg[j] == '=')
-					quit_arg_hyphen_removal = 1;
-				if (!quit_arg_hyphen_removal && arg[j] == '-')
-					continue;
-				arg_new[j_new] = arg[j];
-				j_new++;
+		arg_new = arg;
+		skip_hyphens = 1;
+		while (*arg) {
+			/* If we encounter '=', stop any further hyphen removal. */
+			if (*arg == '=')
+				skip_hyphens = 0;
+
+			/* Do we need to keep the next character? */
+			if (*arg != '-' || !skip_hyphens) {
+				if (arg_new != arg)
+					*arg_new = *arg;
+				++arg_new;
 			}
-
-			memcpy(argv[i], arg_new, strlen(arg_new) + 1);
+			arg++;
 		}
+
+		/* Terminate a shortened arg */
+		if (arg_new != arg)
+			*arg_new = '\0';
 	}
 
 	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))


