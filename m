From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:56:14 -0400
Subject: master - lvconvert: enable --uncache with dm-writecache cachevol
Message-ID: <201909242056.x8OKuEi1015882@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a8e6ad014c7dd6785ad6859551d68a264bad1f8
Commit:        9a8e6ad014c7dd6785ad6859551d68a264bad1f8
Parent:        26596ce7faf1cd8b0aa4b199fa917fb14eace666
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 15:49:21 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 15:51:05 2019 -0500

lvconvert: enable --uncache with dm-writecache cachevol

splitcache followed by an automatic lvremove of
the cachevol LV
---
 tools/lvconvert.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 07b5d6a..60ab956 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4715,17 +4715,17 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 
 	/* If LV is inactive here, ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv_main, "ex", 0))
-		return_0;
+		return ECMD_FAILED;
 
 	if (lv_is_writecache(lv_main)) {
+		if (!_lvconvert_detach_writecache(cmd, lv_main, lv_fast))
+			return ECMD_FAILED;
+
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
-			log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
-			log_error("The writecache %s may then be removed with lvremove.", display_lvname(lv_fast));
-			return 0;
+			if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED)
+				return ECMD_FAILED;
 		}
 
-		ret = _lvconvert_detach_writecache(cmd, lv_main, lv_fast);
-
 	} else if (lv_is_cache(lv_main) && lv_is_cache_vol(lv_fast)) {
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
 			ret = _lvconvert_split_and_remove_cachevol(cmd, lv_main, lv_fast);


