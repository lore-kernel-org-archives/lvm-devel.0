From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 17:58:50 -0500
Subject: master - help: show extents option for lvcreate
Message-ID: <201703022258.v22Mwo0N015132@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d39927f2251edbb60db5af55ddf06ef50331e49
Commit:        5d39927f2251edbb60db5af55ddf06ef50331e49
Parent:        9b23d9bfe40428b4f0b744eea1a346f6234bfd83
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 16:33:14 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 16:58:19 2017 -0600

help: show extents option for lvcreate

A special case is needed to display
--extents for lvcreate since the cmd defs
treat --extents as an automatic alternative
to --size (to avoid duplicating every cmd def).
---
 tools/command.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index e82fdea..2e8299b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1635,6 +1635,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 {
 	struct command_name *cname = find_command_name(cmd->name);
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
+	int include_extents = 0;
 	int ro, rp, oo, op, opt_enum, first;
 
 	/*
@@ -1654,6 +1655,10 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
+			/* special case */
+			if (!strcmp(cmd->name, "lvcreate") && (opt_enum == size_ARG))
+				include_extents = 1;
+
 			if (onereq) {
 				if (first)
 					printf("\n\t(");
@@ -1690,6 +1695,9 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		goto op_count;
 
 	if (cmd->oo_count) {
+		if (include_extents)
+			printf("\n\t[ --extents Number[PERCENT] ]");
+
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			opt_enum = cmd->optional_opt_args[oo].opt;
 
@@ -1822,8 +1830,9 @@ void print_usage_notes(struct command_name *cname, struct command *cmd)
 
 	if (!strcmp(cname->name, "lvcreate")) {
 		printf("  Special options for command:\n");
-		printf("        [ --extents NumberExtents ]\n"
-		       "        The --extents option can be used in place of --size in each case.\n");
+		printf("        [ --extents Number[PERCENT] ]\n"
+		       "        The --extents option can be used in place of --size in each case.\n"
+		       "        The number allows an optional percent suffix (see man lvcreate).\n");
 		printf("\n");
 		printf("        [ --name String ]\n"
 		       "        The --name option is not required but is typically used.\n"


