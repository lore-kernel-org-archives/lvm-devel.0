From: David Teigland <teigland@sourceware.org>
Date: Fri, 27 May 2022 17:40:29 +0000 (GMT)
Subject: main - devices file: move clean up after command is run
Message-ID: <20220527174029.E9AF038418A8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9dfa6f38793f6b5f7de2a4148ab2f7790e3c39da
Commit:        9dfa6f38793f6b5f7de2a4148ab2f7790e3c39da
Parent:        a30013ff4f5981afd7778597172e0e834ca99cd4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 27 12:38:43 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 27 12:38:43 2022 -0500

devices file: move clean up after command is run

devices_file_exit wasn't being called between lvm_shell
commands, so the file lock wouldn't be released.
---
 lib/commands/toolcontext.c | 2 --
 tools/lvmcmdline.c         | 1 +
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4cb81bf94..2666d7b42 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1905,7 +1905,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
 
-	devices_file_exit(cmd);
 	if (!dev_cache_exit())
 		stack;
 	_destroy_dev_types(cmd);
@@ -2034,7 +2033,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
 	_destroy_filters(cmd);
-	devices_file_exit(cmd);
 	dev_cache_exit();
 	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1e3547ed7..b052d698f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3305,6 +3305,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	hints_exit(cmd);
 	lvmcache_destroy(cmd, 1, 1);
 	label_scan_destroy(cmd);
+	devices_file_exit(cmd);
 
 	if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
 		dm_config_destroy(config_string_cft);

