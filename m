From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:52 -0500
Subject: master - cleanup: use lv_is_used_cache_pool
Message-ID: <201802282022.w1SKMqWq009889@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16c209c613b35307105e7d022a95f58f897243aa
Commit:        16c209c613b35307105e7d022a95f58f897243aa
Parent:        e643de6e61e9329c84286941511242f0f0d2e71b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 17:38:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

cleanup: use lv_is_used_cache_pool

Use lv_is_used_cache_pool() to simplify the code.
Function was introduced later and this code missed to use it.
---
 lib/metadata/lv_manip.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 28f00ab..1e2cfc6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6084,7 +6084,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* Used cache pool, COW or historical LV cannot be activated */
-	if ((!lv_is_cache_pool(lv) || dm_list_empty(&lv->segs_using_this_lv)) &&
+	if (!lv_is_used_cache_pool(lv) &&
 	    !lv_is_cow(lv) && !lv_is_historical(lv) &&
 	    !deactivate_lv(cmd, lv)) {
 		/* FIXME Review and fix the snapshot error paths! */
@@ -6134,16 +6134,14 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (lv_is_cache_pool(lv)) {
+	if (lv_is_used_cache_pool(lv)) {
 		/* Cache pool removal drops cache layer
 		 * If the cache pool is not linked, we can simply remove it. */
-		if (!dm_list_empty(&lv->segs_using_this_lv)) {
-			if (!(cache_seg = get_only_segment_using_this_lv(lv)))
-				return_0;
-			/* TODO: polling */
-			if (!lv_cache_remove(cache_seg->lv))
-				return_0;
-		}
+		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+		/* TODO: polling */
+		if (!lv_cache_remove(cache_seg->lv))
+			return_0;
 	}
 
 	visible = lv_is_visible(lv);


