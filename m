From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 15:54:02 -0500
Subject: master - man/help: use order of required options from cmd def
Message-ID: <201703082054.v28Ks2Tt001688@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d0172ff15c8af6e5df22afca1c8dc9725c3684f
Commit:        4d0172ff15c8af6e5df22afca1c8dc9725c3684f
Parent:        3d5182c81946bb7e7e0a704ce3e4585968055dc8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 8 14:51:08 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 14:51:08 2017 -0600

man/help: use order of required options from cmd def

Follow the same as written in command-lines.in
---
 tools/command-lines.in |    3 ++-
 tools/command.c        |   32 +++-----------------------------
 2 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 4f2ab44..150f572 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -350,7 +350,8 @@ lvconvert --type raid LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
-DESC: Convert LV to raid or change raid layout.
+DESC: Convert LV to raid or change raid layout
+DESC: (a specific raid level must be used, e.g. raid1).
 RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --mirrors SNumber LV
diff --git a/tools/command.c b/tools/command.c
index 0d56e51..d001f94 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1698,8 +1698,6 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	if (cmd->ro_count) {
 		first = 1;
 
-		/* print options with short opts */
-
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
@@ -1717,35 +1715,11 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 				first = 0;
 			}
 
-			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
-			if (cmd->required_opt_args[ro].def.val_bits) {
-				printf(" ");
-				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
-			}
-		}
-
-		/* print options without short opts */
-
-		for (ro = 0; ro < cmd->ro_count; ro++) {
-			opt_enum = cmd->required_opt_args[ro].opt;
-
 			if (opt_names[opt_enum].short_opt)
-				continue;
-
-			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
-				include_extents = 1;
-
-			if (onereq) {
-				if (first)
-					printf("\n\t(");
-				else {
-					printf(",\n\t ");
-					printf("   "); /* align for no short opt */
-				}
-				first = 0;
-			}
+				printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+			else
+				printf(" %s", opt_names[opt_enum].long_opt);
 
-			printf(" %s", opt_names[opt_enum].long_opt);
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
 				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);


