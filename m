From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Feb 2017 22:12:50 +0000 (UTC)
Subject: master - Revert "lvconvert: enable previous syntax to swap metadata"
Message-ID: <20170214221250.1209261122@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7417c8acfa0e9274fbfcf3220630ac3b66e88fb4
Commit:        7417c8acfa0e9274fbfcf3220630ac3b66e88fb4
Parent:        d2c5bb5c7066142930c88275d2fb6c8552559c9a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 14 16:02:54 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 14 16:02:54 2017 -0600

Revert "lvconvert: enable previous syntax to swap metadata"

This reverts commit 717363bb9427c02addeb22ef77396132cb30c782.

These alternate forms for swapping metadata cannot be
distinguished from the command for creating a pool.
If we were to add these alternate forms for swapping
metadata, we would need to overload the pool creation
command defs, making those definitions ambiguous.
---
 tools/command-lines.in |   14 --------------
 tools/lvconvert.c      |    2 ++
 tools/lvmcmdline.c     |    2 --
 tools/tools.h          |    1 -
 4 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index b6aa1d1..377e536 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -508,20 +508,6 @@ OO: --chunksize SizeKB, OO_LVCONVERT
 ID: lvconvert_swap_pool_metadata
 DESC: Swap metadata LV in a thin pool or cache pool (for repair only).
 
-lvconvert --poolmetadata LV --thinpool LV_thinpool
-OO: --chunksize SizeKB, OO_LVCONVERT
-ID: lvconvert_swap_thinpool_metadata
-DESC: Swap metadata LV in a thin pool (for repair only).
-DESC: (variant, use --swapmetadata).
-FLAGS: SECONDARY_SYNTAX
-
-lvconvert --poolmetadata LV --cachepool LV_cachepool
-OO: --chunksize SizeKB, OO_LVCONVERT
-ID: lvconvert_swap_cachepool_metadata
-DESC: Swap metadata LV in a cache pool (for repair only).
-DESC: (variant, use --swapmetadata).
-FLAGS: SECONDARY_SYNTAX
-
 ---
 
 # lvconvert --merge is an extremely ambiguous command.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3897602..502d614 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4040,6 +4040,7 @@ int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **a
 			       NULL, NULL, &_lvconvert_swap_pool_metadata_single);
 }
 
+#if 0
 int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct command *new_command;
@@ -4071,6 +4072,7 @@ int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, ch
 
 	return lvconvert_swap_pool_metadata_cmd(cmd, argc, argv);
 }
+#endif
 
 static int _lvconvert_merge_thin_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 65f80c8..02aaff2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -141,8 +141,6 @@ struct command_function command_functions[CMD_COUNT] = {
 	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
 	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_cmd },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
-	{ lvconvert_swap_thinpool_metadata_CMD,		lvconvert_swap_pool_metadata_noarg_cmd },
-	{ lvconvert_swap_cachepool_metadata_CMD,	lvconvert_swap_pool_metadata_noarg_cmd },
 	{ lvconvert_merge_thin_CMD,			lvconvert_merge_thin_cmd },
 	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index 2f2a0fd..b3858a0 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -278,7 +278,6 @@ int lvconvert_to_pool_noarg_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
-int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
 


