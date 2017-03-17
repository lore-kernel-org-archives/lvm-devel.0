From: David Teigland <teigland@sourceware.org>
Date: Fri, 17 Mar 2017 12:25:34 -0400
Subject: master - help: align option list in pv/lv/vgchange cases
Message-ID: <201703171625.v2HGPYEo005651@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d7be8f5df2787354bb6cf40b6436047b82cfb58
Commit:        8d7be8f5df2787354bb6cf40b6436047b82cfb58
Parent:        fec2ea76cf30f6333ff4dc6afb8a40b84d7abf7b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 17 11:20:51 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 17 11:23:38 2017 -0500

help: align option list in pv/lv/vgchange cases

Align one-required options like is done for
optional options.
---
 tools/command.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index e14291d..a344e55 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1708,22 +1708,69 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 	printf("  %s", cmd->name);
 
-	if (cmd->ro_count) {
+	if (onereq && cmd->ro_count) {
+		/* one required option in a set */
 		first = 1;
 
+		/* options with short and long */
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if (!opt_names[opt_enum].short_opt)
+				continue;
+
+			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
+				include_extents = 1;
+
+			if (first)
+				printf("\n\t(");
+			else
+				printf(",\n\t ");
+			first = 0;
+
+			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
+			}
+		}
+
+		/* options with only long */
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
+			if (opt_names[opt_enum].short_opt)
+				continue;
+
 			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
 				include_extents = 1;
 
-			if (onereq) {
-				if (first)
-					printf("\n\t(");
-				else
-					printf(",\n\t ");
-				first = 0;
+			if (first)
+				printf("\n\t(");
+			else
+				printf(",\n\t ");
+			first = 0;
+
+			printf("    %s", opt_names[opt_enum].long_opt);
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
+		}
+
+		printf(" )\n");
+	}
+
+	if (!onereq && cmd->ro_count) {
+		first = 1;
+
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
+				include_extents = 1;
 
 			if (opt_names[opt_enum].short_opt)
 				printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
@@ -1735,9 +1782,6 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
 		}
-
-		if (onereq)
-			printf(" )\n");
 	}
 
 	if (cmd->rp_count) {


