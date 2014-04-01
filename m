From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:09 +0000 (UTC)
Subject: master - cleanup: cache updates messages
Message-ID: <20140401185609.8FAB76092A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cb053339e5e001c57a2565f25b499ffb02d7f8a
Commit:        9cb053339e5e001c57a2565f25b499ffb02d7f8a
Parent:        e2ea3cd7ba998125e7d9e20981157c087c0d261b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 17:55:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:54:09 2014 +0200

cleanup: cache updates messages

Passing non cached device is an internal error.
Print messages at non-error level.
Shorten sleep delay for cache flush.
---
 lib/metadata/cache_manip.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 0988e48..b71e9e0 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -185,8 +185,10 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
 
-	if (!lv_is_cache(cache_lv))
-		return_0;
+	if (!lv_is_cache(cache_lv)) {
+		log_error(INTERNAL_ERROR "LV %s is not cached.", cache_lv->name);
+		return 0;
+	}
 
 	/* Active volume is needed (writeback only?) */
 	if (!activate_lv(cache_lv->vg->cmd, cache_lv)) {
@@ -214,7 +216,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 	if (strcmp(policy_name, "cleaner")) {
 		/* We must swap in the cleaner to flush the cache */
-		log_error("Flushing cache for %s", cache_lv->name);
+		log_print_unless_silent("Flushing cache for %s.", cache_lv->name);
 
 		/*
 		 * Is there are clean way to free the memory for the name
@@ -240,10 +242,10 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		if (!lv_cache_block_info(cache_lv, NULL,
 					 &dirty_blocks, NULL, NULL))
 			return_0;
-		log_error("%" PRIu64 " blocks must still be flushed.",
-			  dirty_blocks);
+		log_print_unless_silent("%" PRIu64 " blocks must still be flushed.",
+					dirty_blocks);
 		if (dirty_blocks)
-			sleep(5);
+			sleep(1);
 	} while (dirty_blocks);
 
 	cache_pool_lv = cache_seg->pool_lv;


