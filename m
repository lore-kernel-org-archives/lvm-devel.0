From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:09 +0000 (UTC)
Subject: master - cache: Add lv_cache_setpolicy to cache_manip.c.
Message-ID: <20141120155309.4D85560DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d22ffd8c289f570b3406f684212b6e7821179710
Commit:        d22ffd8c289f570b3406f684212b6e7821179710
Parent:        0050480c0eced1da98ffc76d5010cef605c776eb
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 18:38:30 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

cache: Add lv_cache_setpolicy to cache_manip.c.

---
 lib/metadata/cache_manip.c       |   18 ++++++++++++++++++
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index fb5346d..f7b1b99 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -395,6 +395,24 @@ int lv_is_cache_origin(const struct logical_volume *lv)
 	return seg && lv_is_cache(seg->lv) && !lv_is_pending_delete(seg->lv) && (seg_lv(seg, 0) == lv);
 }
 
+int lv_cache_setpolicy(struct logical_volume *lv, struct dm_config_tree *policy)
+{
+	struct lv_segment *seg = first_seg(lv);
+	const char *name;
+
+	if (lv_is_cache(lv))
+		seg = first_seg(seg->pool_lv);
+
+	if (!(seg->policy_settings = dm_config_clone_node_with_mem(lv->vg->vgmem, policy->root, 0)))
+		return_0;
+
+	if ((name = dm_config_find_str(policy->root, "policy", NULL)) &&
+	    !(seg->policy_name = dm_pool_strdup(lv->vg->vgmem, name)))
+		return_0;
+
+	return 1;
+}
+
 /*
  * Wipe cache pool metadata area before use.
  *
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c472f41..d960e1f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1109,6 +1109,7 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
+int lv_cache_setpolicy(struct logical_volume *cache_lv, struct dm_config_tree *pol);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 


