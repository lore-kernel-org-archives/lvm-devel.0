From: David Teigland <teigland@sourceware.org>
Date: Fri, 14 Jun 2019 10:28:10 -0400
Subject: master - fix man page generation
Message-ID: <201906141428.x5EESA3p022103@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f5e46965bd3e967de8c3b6741f2b7f178192a53
Commit:        9f5e46965bd3e967de8c3b6741f2b7f178192a53
Parent:        a4dbbefaff74b6507c82dc1b938b0312c2dda576
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 14 09:26:08 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 14 09:26:08 2019 -0500

fix man page generation

The man page generation for pvchange/lvchange/vgchange was
incorrect (leaving out some option listings) as a result of
commit e225bf5 "fix command definition for pvchange -a"
---
 tools/command.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 246d181..bdd18d6 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1292,7 +1292,7 @@ void factor_common_options(void)
 				if (strcmp(cmd->name, command_names[cn].name))
 					continue;
 
-				if (cmd->ro_count)
+				if (cmd->ro_count || cmd->any_ro_count)
 					command_names[cn].variant_has_ro = 1;
 				if (cmd->rp_count)
 					command_names[cn].variant_has_rp = 1;
@@ -1301,7 +1301,7 @@ void factor_common_options(void)
 				if (cmd->op_count)
 					command_names[cn].variant_has_op = 1;
 
-				for (ro = 0; ro < cmd->ro_count; ro++) {
+				for (ro = 0; ro < cmd->ro_count + cmd->any_ro_count; ro++) {
 					command_names[cn].all_options[cmd->required_opt_args[ro].opt] = 1;
 
 					if ((cmd->required_opt_args[ro].opt == size_ARG) && !strncmp(cmd->name, "lv", 2))


