From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 20:42:32 +0000 (UTC)
Subject: master - lvconvert: enable previous syntax to swap metadata
Message-ID: <20170213204232.321EF6105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=717363bb9427c02addeb22ef77396132cb30c782
Commit:        717363bb9427c02addeb22ef77396132cb30c782
Parent:        b2fd5b31d3cbe1267ab01c4d6af4785f800938f4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 13 14:40:53 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 14:41:54 2017 -0600

lvconvert: enable previous syntax to swap metadata

---
 tools/command-lines.in |   14 ++++++++++++++
 tools/lvconvert.c      |    2 --
 tools/lvmcmdline.c     |    2 ++
 tools/tools.h          |    1 +
 4 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1a9a796..2eddd41 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -508,6 +508,20 @@ OO: --chunksize SizeKB, OO_LVCONVERT
 ID: lvconvert_swap_pool_metadata
 DESC: Swap metadata LV in a thin pool or cache pool (for repair only).
 
+lvconvert --poolmetadata LV --thinpool LV_thinpool
+OO: --chunksize SizeKB, OO_LVCONVERT
+ID: lvconvert_swap_thinpool_metadata
+DESC: Swap metadata LV in a thin pool (for repair only).
+DESC: (variant, use --swapmetadata).
+FLAGS: SECONDARY_SYNTAX
+
+lvconvert --poolmetadata LV --cachepool LV_cachepool
+OO: --chunksize SizeKB, OO_LVCONVERT
+ID: lvconvert_swap_cachepool_metadata
+DESC: Swap metadata LV in a cache pool (for repair only).
+DESC: (variant, use --swapmetadata).
+FLAGS: SECONDARY_SYNTAX
+
 ---
 
 # lvconvert --merge is an extremely ambiguous command.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 502d614..3897602 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4040,7 +4040,6 @@ int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **a
 			       NULL, NULL, &_lvconvert_swap_pool_metadata_single);
 }
 
-#if 0
 int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct command *new_command;
@@ -4072,7 +4071,6 @@ int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, ch
 
 	return lvconvert_swap_pool_metadata_cmd(cmd, argc, argv);
 }
-#endif
 
 static int _lvconvert_merge_thin_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 44efc85..40e1cf4 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -141,6 +141,8 @@ struct command_function command_functions[CMD_COUNT] = {
 	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
 	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_cmd },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
+	{ lvconvert_swap_thinpool_metadata_CMD,		lvconvert_swap_pool_metadata_noarg_cmd },
+	{ lvconvert_swap_cachepool_metadata_CMD,	lvconvert_swap_pool_metadata_noarg_cmd },
 	{ lvconvert_merge_thin_CMD,			lvconvert_merge_thin_cmd },
 	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index b3858a0..2f2a0fd 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -278,6 +278,7 @@ int lvconvert_to_pool_noarg_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_swap_pool_metadata_noarg_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
 


