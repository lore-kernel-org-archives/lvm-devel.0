From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 24 Jul 2015 15:30:36 +0000 (UTC)
Subject: master - Fix dehyphenation cases
Message-ID: <20150724153036.3AE7A6016D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcb875dcb19323ab62f2f3b409c4bda4ce8267d1
Commit:        bcb875dcb19323ab62f2f3b409c4bda4ce8267d1
Parent:        be662439331abf6ccb16dd996bfe15eb613b4e53
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 24 10:25:13 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 24 10:25:13 2015 -0500

Fix dehyphenation cases

Stop removing hyphens when = is seen.  With an option
like --profile=thin-performance, the hyphen removal
will stop at = and will not remove - after thin.

Stop removing hyphens altogether when a stand alone arg
of -- appears.
---
 tools/lvmcmdline.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6dbc189..403948a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1463,6 +1463,8 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	return 1;
 }
 
+#define MAX_ARG_LEN 64
+
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft;
@@ -1470,8 +1472,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int ret = 0;
 	int locking_type;
 	int monitoring;
-	char *arg_new, *arg;
-	int i;
+	char arg_new[MAX_ARG_LEN];
+	char *arg;
+	int quit_arg_hyphen_removal;
+	int i, j, j_new;
 
 	init_error_message_produced(0);
 
@@ -1479,24 +1483,29 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	sigint_clear();
 
 	/* eliminate '-' from all options starting with -- */
-	for (i = 1; i < argc; ++i) {
-
-		if (argv[i][0] != '-' || argv[i][1] != '-')
-			continue;
+	for (i = 1; i < argc; i++) {
+		quit_arg_hyphen_removal = 0;
+		arg = argv[i];
 
-		arg_new = arg = argv[i] + 2;
+		if (arg[0] == '-' && arg[1] == '-' && strlen(arg) == 2)
+			break;
 
-		while (*arg) {
-			if (*arg != '-') {
-				if (arg_new != arg)
-					*arg_new = *arg;
-				++arg_new;
+		if (arg[0] == '-' && arg[1] == '-' && strlen(arg) < MAX_ARG_LEN) {
+			memset(arg_new, 0, sizeof(arg_new));
+			arg_new[0] = '-';
+			arg_new[1] = '-';
+
+			for (j = 2, j_new = 2; j < strlen(arg) + 1; j++) {
+				if (arg[j] == '=')
+					quit_arg_hyphen_removal = 1;
+				if (!quit_arg_hyphen_removal && arg[j] == '-')
+					continue;
+				arg_new[j_new] = arg[j];
+				j_new++;
 			}
-			++arg;
-		}
 
-		if (arg_new != arg)
-			*arg_new = 0;
+			memcpy(argv[i], arg_new, strlen(arg_new) + 1);
+		}
 	}
 
 	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))


