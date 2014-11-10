From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:34 +0000 (UTC)
Subject: master - cache: option
Message-ID: <20141110210634.2964660FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6effcb16fcc912bdca250b45442b783ebe75c481
Commit:        6effcb16fcc912bdca250b45442b783ebe75c481
Parent:        c5c2665a213332904836ad90e2f90dd72b6db4c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 10:07:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cache: option

---
 lib/metadata/cache_manip.c |   30 ++++++++++++++++++++++++++----
 1 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index cce2911..b94b867 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -268,8 +268,27 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
-	/* Localy active volume is needed (writeback only?) */
+	/* Localy active volume is needed for writeback */
 	if (!lv_is_active_locally(cache_lv)) {
+		/* Give up any remote locks */
+		if (!deactivate_lv(cache_lv->vg->cmd, cache_lv)) {
+			log_error("Cannot deactivate remotely active cache lv.");
+			return 0;
+		}
+		/* For inactive writethrough just drop cache layer */
+		if (first_seg(cache_seg->pool_lv)->feature_flags &
+		    DM_CACHE_FEATURE_WRITETHROUGH) {
+			corigin_lv = seg_lv(cache_seg, 0);
+			if (!detach_pool_lv(cache_seg))
+				return_0;
+			if (!remove_layer_from_lv(cache_lv, corigin_lv))
+				return_0;
+			if (!lv_remove(corigin_lv))
+				return_0;
+			return 1;
+		}
+
+		/* Otherwise localy active volume is need to sync dirty blocks */
 		cache_lv->status |= LV_TEMPORARY;
 		if (!activate_lv_excl_local(cache_lv->vg->cmd, cache_lv) ||
 		    !lv_is_active_locally(cache_lv)) {
@@ -297,10 +316,13 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 */
 	if (!lv_cache_status(cache_lv, &status))
 		return_0;
+	dirty_blocks = status->cache->dirty_blocks;
+	if (!(status->cache->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH))
+		dirty_blocks++; /* Not writethrough - always dirty */
 	is_cleaner = !strcmp(status->cache->policy_name, "cleaner");
 	dm_pool_destroy(status->mem);
 
-	if (!is_cleaner) {
+	if (dirty_blocks && !is_cleaner) {
 		/* Switch to cleaner policy to flush the cache */
 		log_print_unless_silent("Flushing cache for %s.", cache_lv->name);
 		cache_seg->cleaner_policy = 1;
@@ -310,7 +332,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	}
 
 	//FIXME: use polling to do this...
-	do {
+	while (dirty_blocks) {
 		if (!lv_cache_status(cache_lv, &status))
 			return_0;
 		dirty_blocks = status->cache->dirty_blocks;
@@ -320,7 +342,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 						dirty_blocks);
 			sleep(1);
 		}
-	} while (dirty_blocks);
+	}
 
 	cache_pool_lv = cache_seg->pool_lv;
 	if (!detach_pool_lv(cache_seg))


