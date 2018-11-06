From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:42:45 -0500
Subject: master - cache: factor getting cache mode
Message-ID: <201811062142.wA6LgjXk004728@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e26dacf30a656276afdc36516cb7b330da4ff705
Commit:        e26dacf30a656276afdc36516cb7b330da4ff705
Parent:        f3f3d6066b82523867a7e7cdaa3d64ae73a44b2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 15:46:07 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: factor getting cache mode

so part can be called separately
---
 lib/metadata/cache_manip.c |   67 ++++++++++++++++++++++++++++---------------
 1 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 0cf94ae..b4d269d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -95,32 +95,14 @@ int set_cache_mode(cache_mode_t *mode, const char *cache_mode)
 	return 1;
 }
 
-int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
+static cache_mode_t _get_cache_mode_from_config(struct cmd_context *cmd,
+						struct profile *profile,
+						struct logical_volume *lv)
 {
-	struct cmd_context *cmd = seg->lv->vg->cmd;
-	struct profile *profile = seg->lv->profile;
+	cache_mode_t mode;
 	const char *str;
 	int id;
 
-	if (seg_is_cache(seg))
-		seg = first_seg(seg->pool_lv);
-	else if (seg_is_cache_pool(seg)) {
-		if (mode == CACHE_MODE_UNSELECTED)
-			return 1;	/* Defaults only for cache */
-	} else {
-		log_error(INTERNAL_ERROR "Cannot set cache mode for non cache volume %s.",
-			  display_lvname(seg->lv));
-		return 0;
-	}
-
-	if (mode != CACHE_MODE_UNSELECTED) {
-		seg->cache_mode = mode;
-		return 1;
-	}
-
-	if (seg->cache_mode != CACHE_MODE_UNSELECTED)
-		return 1;               /* Default already set in cache pool */
-
 	/* Figure default settings from config/profiles */
 	id = allocation_cache_mode_CFG;
 
@@ -131,11 +113,48 @@ int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 
 	if (!(str = find_config_tree_str(cmd, id, profile))) {
 		log_error(INTERNAL_ERROR "Cache mode is not determined.");
+		return CACHE_MODE_WRITETHROUGH;
+	}
+
+	if (!(set_cache_mode(&mode, str)))
+		return CACHE_MODE_WRITETHROUGH;
+
+	return mode;
+}
+
+int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
+{
+	struct cmd_context *cmd = seg->lv->vg->cmd;
+	struct lv_segment *setting_seg;
+
+	/*
+	 * Don't set a cache mode on an unused cache pool, the
+	 * cache mode will be set when it's attached.
+	 */
+	if (seg_is_cache_pool(seg) && (mode == CACHE_MODE_UNSELECTED))
+		return 1;
+
+	if (seg_is_cache_pool(seg))
+		setting_seg = seg;
+
+	else if (seg_is_cache(seg))
+		setting_seg = first_seg(seg->pool_lv);
+
+	else {
+		log_error(INTERNAL_ERROR "Cannot set cache mode for non cache volume %s.",
+			  display_lvname(seg->lv));
 		return 0;
 	}
 
-	if (!(set_cache_mode(&seg->cache_mode, str)))
-		return_0;
+	if (mode != CACHE_MODE_UNSELECTED) {
+		setting_seg->cache_mode = mode;
+		return 1;
+	}
+
+	if (setting_seg->cache_mode != CACHE_MODE_UNSELECTED)
+		return 1;
+
+	setting_seg->cache_mode = _get_cache_mode_from_config(cmd, seg->lv->profile, seg->lv);
 
 	return 1;
 }


