From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:55:54 -0400
Subject: master - lvconvert: enable --uncache with dm-cache cachevol
Message-ID: <201909242055.x8OKtsRw015818@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f27625f005f5a96a7ed44d2dbc9f71cfcc981c54
Commit:        f27625f005f5a96a7ed44d2dbc9f71cfcc981c54
Parent:        44640043628425e09122aa3775fd40a5b13c0fd0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 11:57:44 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 15:50:58 2019 -0500

lvconvert: enable --uncache with dm-cache cachevol

splitcache followed by an automatic lvremove of
the cachevol LV
---
 tools/lvconvert.c |   35 +++++++++++++++++++++--------------
 1 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 352a588..e4f605e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1884,8 +1884,18 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 
 	backup(lv->vg);
 
-	log_print_unless_silent("Logical volume %s is not cached and %s is unused.",
-				display_lvname(lv), display_lvname(lv_fast));
+	return 1;
+}
+
+static int _lvconvert_split_and_remove_cachevol(struct cmd_context *cmd,
+				   struct logical_volume *lv,
+				   struct logical_volume *lv_fast)
+{
+	if (!_lvconvert_split_and_keep_cachevol(cmd, lv, lv_fast))
+		return_0;
+
+	if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED)
+		return_0;
 
 	return 1;
 }
@@ -1918,15 +1928,6 @@ static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _lvconvert_split_and_remove_cachevol(struct cmd_context *cmd,
-				   struct logical_volume *lv,
-				   struct logical_volume *lv_fast)
-{
-	log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
-	log_error("The cache %s may then be removed with lvremove.", display_lvname(lv_fast));
-	return 0;
-}
-
 static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *cachepool_lv)
@@ -4726,13 +4727,19 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 		ret = _lvconvert_detach_writecache(cmd, lv_main, lv_fast);
 
 	} else if (lv_is_cache(lv_main) && lv_is_cache_vol(lv_fast)) {
-		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD)
+		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
 			ret = _lvconvert_split_and_remove_cachevol(cmd, lv_main, lv_fast);
 
-		else if (cmd->command->command_enum == lvconvert_split_and_keep_cache_CMD)
+			log_print_unless_silent("Logical volume %s is not cached and %s is removed.",
+						display_lvname(lv), display_lvname(lv_fast));
+
+		} else if (cmd->command->command_enum == lvconvert_split_and_keep_cache_CMD) {
 			ret = _lvconvert_split_and_keep_cachevol(cmd, lv_main, lv_fast);
 
-		else  {
+			log_print_unless_silent("Logical volume %s is not cached and %s is unused.",
+						display_lvname(lv), display_lvname(lv_fast));
+
+		} else  {
 			log_error(INTERNAL_ERROR "Unknown cache split command.");
 			ret = 0;
 		}


