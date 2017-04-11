From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 13:19:17 -0400
Subject: master - lvconvert: prevent duplicate use of metadata lv
Message-ID: <201704111719.v3BHJHVR013355@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a96c8b46b62c316381eb029416b92197d9cfa4de
Commit:        a96c8b46b62c316381eb029416b92197d9cfa4de
Parent:        e0c169f8b7f214100ad11c68b1cab799e8adaaed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 12:07:14 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 12:11:00 2017 -0500

lvconvert: prevent duplicate use of metadata lv

The LV being processed cannot be used as the
pool metadata LV.
---
 tools/lvconvert.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ee7fb8b..c18b5a4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2658,10 +2658,15 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
  * Create a new pool LV, using the lv arg as the data sub LV.
  * The metadata sub LV is either a new LV created here, or an
  * existing LV specified by --poolmetadata.
+ *
+ * process_single_lv is the LV currently being processed by
+ * process_each_lv().  It will sometimes be the same as the
+ * lv arg, and sometimes not.
  */
 
 static int _lvconvert_to_pool(struct cmd_context *cmd,
 			      struct logical_volume *lv,
+			      struct logical_volume *process_single_lv,
 			      int to_thinpool,
 			      int to_cachepool,
 			      struct dm_list *use_pvh)
@@ -2773,6 +2778,12 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
+		if (metadata_lv == process_single_lv) {
+			log_error("Use a different LV for pool metadata %s.",
+				  display_lvname(metadata_lv));
+			return 0;
+		}
+
 		if (!lv_is_visible(metadata_lv)) {
 			log_error("Can't convert internal LV %s.",
 				  display_lvname(metadata_lv));
@@ -3765,7 +3776,7 @@ static int _lvconvert_to_pool_single(struct cmd_context *cmd,
 	} else
 		use_pvh = &lv->vg->pvs;
 
-	if (!_lvconvert_to_pool(cmd, lv, to_thinpool, to_cachepool, use_pvh))
+	if (!_lvconvert_to_pool(cmd, lv, lv, to_thinpool, to_cachepool, use_pvh))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -3815,7 +3826,7 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 			goto out;
 		}
 
-		if (!_lvconvert_to_pool(cmd, cachepool_lv, 0, 1, &vg->pvs)) {
+		if (!_lvconvert_to_pool(cmd, cachepool_lv, lv, 0, 1, &vg->pvs)) {
 			log_error("LV %s could not be converted to a cache pool.",
 				  display_lvname(cachepool_lv));
 			goto out;
@@ -3913,7 +3924,7 @@ static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
 			goto out;
 		}
 
-		if (!_lvconvert_to_pool(cmd, thinpool_lv, 1, 0, &vg->pvs)) {
+		if (!_lvconvert_to_pool(cmd, thinpool_lv, lv, 1, 0, &vg->pvs)) {
 			log_error("LV %s could not be converted to a thin pool.",
 				  display_lvname(thinpool_lv));
 			goto out;
@@ -4066,7 +4077,7 @@ static int _lvconvert_to_pool_or_swap_metadata_single(struct cmd_context *cmd,
 		return _lvconvert_swap_pool_metadata_single(cmd, lv, handle);
 	}
 
-	if (!_lvconvert_to_pool(cmd, lv, to_thinpool, to_cachepool, use_pvh))
+	if (!_lvconvert_to_pool(cmd, lv, lv, to_thinpool, to_cachepool, use_pvh))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;


