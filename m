From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:07 +0000 (GMT)
Subject: main - toolcontext: reuse destroy_config_context
Message-ID: <20211220151407.378943858422@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26e6580dfb00912823282f7028ab542501c449ef
Commit:        26e6580dfb00912823282f7028ab542501c449ef
Parent:        09a4b56895b959f46a9b7e7af11732d8e1bbf945
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 10 20:51:46 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

toolcontext: reuse destroy_config_context

Call existing destroy_config_context() to destroy
some parts of cmd_context.
---
 lib/commands/toolcontext.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a0c78ddd6..c772dc6b1 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2041,8 +2041,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
 	_destroy_filters(cmd);
-	if (cmd->mem)
-		dm_pool_destroy(cmd->mem);
 	devices_file_exit(cmd);
 	dev_cache_exit();
 	_destroy_dev_types(cmd);
@@ -2050,16 +2048,10 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	if ((cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING)))
 		config_destroy(cft_cmdline);
-	_destroy_config(cmd);
 
 	if (cmd->cft_def_hash)
 		dm_hash_destroy(cmd->cft_def_hash);
 
-	if (cmd->libmem)
-		dm_pool_destroy(cmd->libmem);
-
-	if (cmd->pending_delete_mem)
-		dm_pool_destroy(cmd->pending_delete_mem);
 #ifndef VALGRIND_POOL
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
@@ -2084,7 +2076,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 		free(cmd->linebuffer);
 	}
 #endif
-	free(cmd);
+	destroy_config_context(cmd);
 
 	lvmpolld_disconnect();
 


