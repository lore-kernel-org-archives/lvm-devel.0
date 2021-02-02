From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Feb 2021 21:15:12 +0000 (GMT)
Subject: main - hints: clean up comment and init settings
Message-ID: <20210202211512.E2B12398E410@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=834cba000a68675909844865f56e77ab62c1943b
Commit:        834cba000a68675909844865f56e77ab62c1943b
Parent:        cb54d0801d776205788f8f46b31dd9e487833343
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 2 15:14:05 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 2 15:14:05 2021 -0600

hints: clean up comment and init settings

no behavior change
---
 tools/lvmcmdline.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b84a9a014..5e0edcade 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2427,13 +2427,15 @@ static int _get_current_settings(struct cmd_context *cmd)
 
 	/*
 	 * enable_hints is set to 1 if any commands are using hints.
-	 * use_hints is set to 1 if this command doesn't use the hints.
+	 * use_hints is set to 1 if this command should use the hints.
 	 * enable_hints=1 and use_hints=0 means that this command won't
 	 * use the hints, but it may invalidate the hints that are used
 	 * by other commands.
 	 *
 	 * enable_hints=0 means no commands are using hints, so this
 	 * command would not need to invalidate hints for other cmds.
+	 *
+	 * Code should check !enable_hints before checking use_hints.
 	 */
 	cmd->enable_hints = 1;
 
@@ -2444,8 +2446,10 @@ static int _get_current_settings(struct cmd_context *cmd)
 		cmd->use_hints = 0;
 
 	if ((hint_mode = find_config_tree_str(cmd, devices_hints_CFG, NULL))) {
-		if (!strcmp(hint_mode, "none"))
+		if (!strcmp(hint_mode, "none")) {
 			cmd->enable_hints = 0;
+			cmd->use_hints = 0;
+		}
 	}
 
 	cmd->partial_activation = 0;


