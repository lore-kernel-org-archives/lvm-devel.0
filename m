From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:57 +0000 (UTC)
Subject: master - cleanup: correcting tracing
Message-ID: <20141103132357.5866B60243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6c5445bea45de548bb16378030cd4f381bf4c04
Commit:        d6c5445bea45de548bb16378030cd4f381bf4c04
Parent:        d574072dd8eb11f54c2f9835e49da5b193cdfca7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 3 12:52:24 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: correcting tracing

Use log_error for real error.
---
 lib/activate/dev_manager.c |    6 +++---
 lib/metadata/cache_manip.c |    5 +++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9272742..7b43e09 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -558,7 +558,7 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
 	}
 
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
-		goto out;
+		goto_out;
 
 	if (!(dinfo = dm_tree_node_get_info(dnode))) {
 		log_error("Failed to get info from tree node for %s.", lv->name);
@@ -1099,7 +1099,7 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
 	if (!type || strcmp(type, "raid")) {
-		log_debug("Expected raid segment type but got %s instead",
+		log_error("Expected raid segment type but got %s instead",
 			  type ? type : "NULL");
 		goto out;
 	}
@@ -1193,7 +1193,7 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
 	if (!type || strcmp(type, "cache")) {
-		log_debug("Expected cache segment type but got %s instead",
+		log_error("Expected cache segment type but got %s instead",
 			  type ? type : "NULL");
 		goto out;
 	}
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a9f21ad..ec7f444 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -241,7 +241,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	struct lv_status_cache *status;
 
 	if (!lv_is_cache(cache_lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not cached.", cache_lv->name);
+		log_error(INTERNAL_ERROR "LV %s is not cache volume.",
+			  display_lvname(cache_lv));
 		return 0;
 	}
 
@@ -291,7 +292,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 		/* update the kernel to put the cleaner policy in place */
 		if (!lv_update_and_reload(cache_lv))
-                        return_0;
+			return_0;
 	}
 
 	//FIXME: use polling to do this...


