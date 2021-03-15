From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:06 +0000 (GMT)
Subject: main - cleanup: simplify
Message-ID: <20210315101406.E896C3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b563c926ba348be14988889a581c81ca09ca66e0
Commit:        b563c926ba348be14988889a581c81ca09ca66e0
Parent:        664d3b0f226ffbbf064157885d7d4f8c0aed49cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 12 13:25:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

cleanup: simplify

---
 tools/lvconvert.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4c159b01e..b50074294 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4958,7 +4958,7 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 	struct logical_volume *lv_main = NULL;
 	struct logical_volume *lv_fast = NULL;
 	struct lv_segment *seg;
-	int ret;
+	int ret = 0;
 
 	if (lv_is_writecache(lv)) {
 		lv_main = lv;
@@ -5031,10 +5031,8 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 			log_print_unless_silent("Logical volume %s is not cached and %s is unused.",
 						display_lvname(lv), display_lvname(lv_fast));
 
-		} else  {
+		} else
 			log_error(INTERNAL_ERROR "Unknown cache split command.");
-			ret = 0;
-		}
 
 	} else if (lv_is_cache(lv_main) && lv_is_cache_pool(lv_fast)) {
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD)
@@ -5043,14 +5041,10 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 		else if (cmd->command->command_enum == lvconvert_split_and_keep_cache_CMD)
 			ret = _lvconvert_split_and_keep_cachepool(cmd, lv_main, lv_fast);
 
-		else  {
+		else
 			log_error(INTERNAL_ERROR "Unknown cache split command.");
-			ret = 0;
-		}
-	} else {
+	} else
 		log_error(INTERNAL_ERROR "Unknown cache split command.");
-		ret = 0;
-	}
 
 	if (!ret)
 		return ECMD_FAILED;


