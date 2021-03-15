From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:05 +0000 (GMT)
Subject: main - lvremove: drop flushing dm cache before remove
Message-ID: <20210315101405.C76603858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=664d3b0f226ffbbf064157885d7d4f8c0aed49cf
Commit:        664d3b0f226ffbbf064157885d7d4f8c0aed49cf
Parent:        5141a510bdfbf1ac8a64cc7ffd8c292c0c4b7a60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 13:29:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

lvremove: drop flushing dm cache before remove

Since cached LV is going to be removed together with its cache,
there is not much to gain if we try to flush cache first.
User may use 'vgcfgrestore' to get back origin + cache.
Assuming user is not using issue_discards.
When data are discarded after remove there is nothing to restore!

This change allows to futher reduce number of commits
during lvremove/vgremove.
---
 lib/metadata/lv_manip.c | 25 -------------------------
 1 file changed, 25 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2c77bacc2..9b1eefe60 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6663,31 +6663,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (lv_is_cache(lv) && !lv_is_pending_delete(lv)) {
-		/* Handles both cachepool & cachevol based cached LVs.
-		 * It's placed before deactivation, so it can try to uncache
-		 * 'active' LV if possible
-		 */
-		struct logical_volume *cachevol_lv = first_seg(lv)->pool_lv;
-
-		if (!archive(vg))
-			return_0;
-
-		if (!lv_cache_remove(lv))
-			return_0;
-
-		if (!lv_remove_single(cmd, cachevol_lv, force,
-				      suppress_remove_message)) {
-			if (force < DONT_PROMPT_OVERRIDE) {
-				log_error("Failed to uncache %s.", display_lvname(lv));
-				return 0;
-			}
-			/* Proceed with -ff */
-			log_print_unless_silent("Ignoring uncache failure of %s.",
-						display_lvname(lv));
-		}
-	}
-
 	/* Used cache pool, COW or historical LV cannot be activated */
 	if (!lv_is_used_cache_pool(lv) &&
 	    !lv_is_cache_vol(lv) &&


