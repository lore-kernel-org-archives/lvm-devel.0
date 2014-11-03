From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:38 +0000 (UTC)
Subject: master - cache: add wipe_cache_pool
Message-ID: <20141103132338.85E24602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2e9802ba7eb48af8d78cee2420897201d57c406
Commit:        d2e9802ba7eb48af8d78cee2420897201d57c406
Parent:        0b7335f84717743bf9c3f9ea9cafff279dff8672
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 18:36:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: add wipe_cache_pool

Add function for wiping cache pool volume.
Only unused cache-pool could be wiped.
---
 lib/metadata/cache_manip.c       |   41 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e59a32f..bff64a3 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -369,3 +369,44 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 	seg = get_only_segment_using_this_lv(lv);
 	return seg && lv_is_cache(seg->lv) && (seg_lv(seg, 0) == lv);
 }
+
+/*
+ * Wipe cache pool metadata area before use.
+ *
+ * Activates metadata volume as 'cache-pool' so regular wiping
+ * of existing visible volume may proceed.
+ */
+int wipe_cache_pool(struct logical_volume *cache_pool_lv)
+{
+	int r;
+
+	/* Only unused cache-pool could be activated and wiped */
+	if (!lv_is_cache_pool(cache_pool_lv) ||
+	    !dm_list_empty(&cache_pool_lv->segs_using_this_lv)) {
+		log_error(INTERNAL_ERROR "Failed to wipe cache pool for volume %s.",
+			  display_lvname(cache_pool_lv));
+		return 0;
+	}
+
+	cache_pool_lv->status |= LV_TEMPORARY;
+	if (!activate_lv_local(cache_pool_lv->vg->cmd, cache_pool_lv)) {
+		log_error("Aborting. Failed to activate cache pool %s.",
+			  display_lvname(cache_pool_lv));
+		return 0;
+	}
+	cache_pool_lv->status &= ~LV_TEMPORARY;
+	if (!(r = wipe_lv(cache_pool_lv, (struct wipe_params) { .do_zero = 1 }))) {
+		log_error("Aborting. Failed to wipe cache pool %s.",
+			  display_lvname(cache_pool_lv));
+		/* Delay return of error after deactivation */
+	}
+
+	/* Deactivate cleared cache-pool metadata */
+	if (!deactivate_lv(cache_pool_lv->vg->cmd, cache_pool_lv)) {
+		log_error("Aborting. Could not deactivate cache pool %s.",
+			  display_lvname(cache_pool_lv));
+		r = 0;
+	}
+
+	return r;
+}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 013da16..723a9c1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1099,6 +1099,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
 int get_cache_mode(const char *str, uint32_t *flags);
+int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,


