From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:56 +0000 (UTC)
Subject: master - cache: add log_error on error path
Message-ID: <20160527134756.23F6C607A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04003cf1ff1c4d00c0d155de6387cdd83478f812
Commit:        04003cf1ff1c4d00c0d155de6387cdd83478f812
Parent:        ecfb90de7405e55d79239d70838a31c66f2e926a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 25 16:27:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

cache: add log_error on error path

Validate and report error when lv_cache_status is called
for inactive LV, or pending delete or unused cache_pool.
---
 lib/activate/activate.c |   22 ++++++++++++++++------
 tools/lvchange.c        |    3 ++-
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2b22eec..1260b10 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1131,19 +1131,29 @@ int lv_cache_status(const struct logical_volume *cache_lv,
 	struct dev_manager *dm;
 	struct lv_segment *cache_seg;
 
-	if (lv_is_cache_pool(cache_lv) && !dm_list_empty(&cache_lv->segs_using_this_lv)) {
-		if (!(cache_seg = get_only_segment_using_this_lv(cache_lv)))
-			return_0;
+	if (lv_is_cache_pool(cache_lv)) {
+		if (dm_list_empty(&cache_lv->segs_using_this_lv) ||
+		    !(cache_seg = get_only_segment_using_this_lv(cache_lv))) {
+			log_error(INTERNAL_ERROR "Cannot check status for unused cache pool %s.",
+				  display_lvname(cache_lv));
+			return 0;
+		}
 		cache_lv = cache_seg->lv;
 	}
 
-	if (lv_is_pending_delete(cache_lv))
+	if (lv_is_pending_delete(cache_lv)) {
+		log_error("Cannot check status for deleted cache volume %s.",
+			  display_lvname(cache_lv));
 		return 0;
+	}
 
-	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
+	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0)) {
+		log_error("Cannot check status for locally inactive cache volume %s.",
+			  display_lvname(cache_lv));
 		return 0;
+	}
 
-	log_debug_activation("Checking cache status for LV %s.",
+	log_debug_activation("Checking status for cache volume %s.",
 			     display_lvname(cache_lv));
 
 	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
diff --git a/tools/lvchange.c b/tools/lvchange.c
index ad27786..16ede56 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -702,7 +702,8 @@ static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 		goto_out;
 
 	if ((mode != CACHE_MODE_UNDEFINED) &&
-	    (mode != pool_seg->cache_mode)) {
+	    (mode != pool_seg->cache_mode) &&
+	    lv_is_cache(lv)) {
 		if (!lv_cache_wait_for_clean(lv, &is_clean))
 			return_0;
 		if (!is_clean) {


