From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Jun 2015 07:53:22 +0000 (UTC)
Subject: master - lvm: move hyphen mangling code
Message-ID: <20150619075322.4B70860D03@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3173442984dd8d31e43cb50db385f31c75cc9839
Commit:        3173442984dd8d31e43cb50db385f31c75cc9839
Parent:        438a65dfdb13abd10b3311e96786770d70868de1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 19 09:44:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 19 09:51:48 2015 +0200

lvm: move hyphen mangling code

Relocate hyphen code from lvm main into lvm_run_command()
so all command and library user will have it.

Update WHATS_NEW with missing changes.
---
 WHATS_NEW          |    2 ++
 tools/lvm.c        |   25 -------------------------
 tools/lvmcmdline.c |   23 +++++++++++++++++++++++
 3 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3ef783f..8ea02cd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -5,6 +5,8 @@ Version 2.02.122 -
   Allow to extend reduced thin volumes with external origins.
   Consider snapshot and origin LV as unusable if its component is suspended.
   Fix lvmconfig segfault on settings with undefined default value (2.02.120).
+  Add explicit 's' (shared) activation mode.
+  Ignore hyphens in long options names (i.e. --long-option == --longoption).
 
 Version 2.02.121 - 12th June 2015
 =================================
diff --git a/tools/lvm.c b/tools/lvm.c
index 00cd16f..f9ab438 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -16,33 +16,8 @@
 #include "tools.h"
 #include "lvm2cmdline.h"
 
-#define MAX_ARG_LEN 64
-
 int main(int argc, char **argv)
 {
-	char arg_new[MAX_ARG_LEN];
-	char *arg;
-	int i, j, j_new;
-
-	for (i = 1; i < argc; i++) {
-		arg = argv[i];
-
-		if (arg[0] == '-' && arg[1] == '-' && strlen(arg) < MAX_ARG_LEN) {
-			memset(arg_new, 0, sizeof(arg_new));
-			arg_new[0] = '-';
-			arg_new[1] = '-';
-
-			for (j = 2, j_new = 2; j < strlen(arg) + 1; j++) {
-				if (arg[j] == '-')
-					continue;
-				arg_new[j_new] = arg[j];
-				j_new++;
-			}
-
-			memcpy(argv[i], arg_new, strlen(arg_new) + 1);
-		}
-	}
-
 	return lvm2_main(argc, argv);
 }
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 792dc41..023a3d6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1414,12 +1414,35 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int ret = 0;
 	int locking_type;
 	int monitoring;
+	char *arg_new, *arg;
+	int i;
 
 	init_error_message_produced(0);
 
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
+	/* eliminate '-' from all options starting with -- */
+	for (i = 1; i < argc; ++i) {
+
+		if (argv[i][0] != '-' || argv[i][1] != '-')
+			continue;
+
+		arg_new = arg = argv[i] + 2;
+
+		while (*arg) {
+			if (*arg != '-') {
+				if (arg_new != arg)
+					*arg_new = *arg;
+				++arg_new;
+			}
+			++arg;
+		}
+
+		if (arg_new != arg)
+			*arg_new = 0;
+	}
+
 	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))
 		return_ECMD_FAILED;
 


