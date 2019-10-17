From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:17 -0400
Subject: master - cache: single code for removal of cached volume
Message-ID: <201910171105.x9HB5HW8023649@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5938cde11bb7298104871acf47d60b0fd5835b71
Commit:        5938cde11bb7298104871acf47d60b0fd5835b71
Parent:        9969361b51d0b69fa04a6a7cd87ca74208b2437a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 12:53:54 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

cache: single code for removal of cached volume

Use same routine for dropping cached LV for cachevol and cachepool.
---
 lib/metadata/lv_manip.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b3a749d..b5b9a4a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6275,19 +6275,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lockd_lv(cmd, lock_lv, "ex", LDLV_PERSISTENT))
 		return_0;
 
-	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
-		struct logical_volume *cachevol_lv = first_seg(lv)->pool_lv;
-
-		if (!lv_cache_remove(lv)) {
-			log_error("Failed to detach cache from %s", display_lvname(lv));
-			return 0;
-		}
-		if (!lv_remove_single(cmd, cachevol_lv, force, suppress_remove_message)) {
-			log_error("Failed to remove cachevol %s.", display_lvname(cachevol_lv));
-			return 0;
-		}
-	}
-
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
@@ -6339,7 +6326,22 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (lv_is_cache(lv) && !lv_is_pending_delete(lv)) {
-		if (!lv_remove_single(cmd, first_seg(lv)->pool_lv, force,
+		/* Handles both cachepool & cachevol based cached LVs.
+		 * It's placed before deactivation, so it can try to uncache
+		 * 'active' LV if possible
+		 */
+		struct logical_volume *cachevol_lv = first_seg(lv)->pool_lv;
+
+		if (lv_is_cache_pool(cachevol_lv))
+			is_last_pool = 1;
+
+		if (!archive(vg))
+			return_0;
+
+		if (!lv_cache_remove(lv))
+			return_0;
+
+		if (!lv_remove_single(cmd, cachevol_lv, force,
 				      suppress_remove_message)) {
 			if (force < DONT_PROMPT_OVERRIDE) {
 				log_error("Failed to uncache %s.", display_lvname(lv));
@@ -6349,7 +6351,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			log_print_unless_silent("Ignoring uncache failure of %s.",
 						display_lvname(lv));
 		}
-		is_last_pool = 1;
 	}
 
 	/* Used cache pool, COW or historical LV cannot be activated */


