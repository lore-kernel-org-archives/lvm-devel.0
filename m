From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:14 +0000 (UTC)
Subject: master - cmd: add 'nohistory' option and wire it up in cmd_context
Message-ID: <20160303132014.9ADD2602C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a34de9cb9c1e8585f11bbb79bc447fdbdf7ea31
Commit:        9a34de9cb9c1e8585f11bbb79bc447fdbdf7ea31
Parent:        8f47119f6fb00b685d3a631ca9464ab940ee256a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:25:14 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

cmd: add 'nohistory' option and wire it up in cmd_context

The --nohistory switch will cause historical LVs to not be recorded
in metadata on demand.
---
 lib/commands/toolcontext.h |    1 +
 tools/args.h               |    1 +
 tools/lvmcmdline.c         |    2 ++
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index b5328e8..6a6267d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -129,6 +129,7 @@ struct cmd_context {
 	unsigned independent_metadata_areas:1;	/* active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
 	unsigned include_historical_lvs:1;	/* also process/report/display historical LVs */
+	unsigned record_historical_lvs:1;	/* record historical LVs */
 	unsigned include_foreign_vgs:1;		/* report/display cmds can reveal foreign VGs */
 	unsigned include_shared_vgs:1;		/* report/display cmds can reveal lockd VGs */
 	unsigned include_active_foreign_vgs:1;	/* cmd should process foreign VGs with active LVs */
diff --git a/tools/args.h b/tools/args.h
index 8dfe744..dc7b9e1 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -69,6 +69,7 @@ arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(noheadings_ARG, '\0', "noheadings", NULL, 0)
+arg(nohistory_ARG, '\0', "nohistory", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0)
 arg(nosuffix_ARG, '\0', "nosuffix", NULL, 0)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4a5cd23..ffe8447 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1102,6 +1102,8 @@ static int _get_settings(struct cmd_context *cmd)
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
 	cmd->include_shared_vgs = arg_is_set(cmd, shared_ARG) ? 1 : 0;
 	cmd->include_historical_lvs = arg_is_set(cmd, history_ARG) ? 1 : 0;
+	cmd->include_historical_lvs = arg_is_set(cmd, history_ARG) ? 1 : 0;
+	cmd->record_historical_lvs = arg_is_set(cmd, nohistory_ARG) ? 0 : 1;
 
 	/*
 	 * This is set to zero by process_each which wants to print errors


