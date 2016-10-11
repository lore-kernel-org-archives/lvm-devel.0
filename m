From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:30 +0000 (UTC)
Subject: master - cleanup: use already set values
Message-ID: <20161011113930.3008B60D46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8b6c130158e1cc1a639afc21f5fd6306286fdb3
Commit:        c8b6c130158e1cc1a639afc21f5fd6306286fdb3
Parent:        f4ae43934a02c5cb90845758804fc278f5fb0edb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 11 13:19:44 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:37:43 2016 +0200

cleanup: use already set values

When we have already decoded arg_is_set into a local var
or already set  segment type - already use these
values instead of repeating calls and string checks.
---
 tools/lvconvert.c |   59 ++++++++++++++++++++++++----------------------------
 1 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 499ff1c..161062d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4110,11 +4110,11 @@ static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume
 static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
 				 struct lvconvert_params *lp)
 {
-	if (arg_is_set(cmd, splitsnapshot_ARG))
+	if (lp->splitsnapshot)
 		return _convert_cow_snapshot_splitsnapshot(cmd, lv, lp);
 
 	/* FIXME: add --merge-snapshot to make this distinct from --merge-mirror. */
-	if (arg_is_set(cmd, merge_ARG))
+	if (lp->merge)
 		return _convert_cow_snapshot_merge(cmd, lv, lp);
 
 	log_error("Operation not permitted on COW snapshot LV %s.", display_lvname(lv));
@@ -4128,7 +4128,7 @@ static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *
 				struct lvconvert_params *lp)
 {
 	/* FIXME: add --merge-snapshot to make this distinct from --merge-mirror. */
-	if (arg_is_set(cmd, merge_ARG))
+	if (lp->merge)
 		return _convert_thin_volume_merge(cmd, lv, lp);
 
 	log_error("Operation not permitted on thin LV %s.", display_lvname(lv));
@@ -4140,19 +4140,19 @@ static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *
 static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
-	if (arg_is_set(cmd, splitcache_ARG))
+	if (lp->splitcache)
 		return _convert_thin_pool_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, split_ARG))
+	if (lp->split)
 		return _convert_thin_pool_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, uncache_ARG))
+	if (lp->uncache)
 		return _convert_thin_pool_uncache(cmd, lv, lp);
 
 	if (lp->cache)
 		return _convert_thin_pool_cache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, repair_ARG))
+	if (lp->repair)
 		return _convert_thin_pool_repair(cmd, lv, lp);
 
 	/* FIXME: swapping the thin pool metadata LV needs a specific option like --swapmetadata */
@@ -4173,21 +4173,20 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume *lv,
 				 struct lvconvert_params *lp)
 {
-	if (arg_is_set(cmd, splitcache_ARG))
+	if (lp->splitcache)
 		return _convert_cache_volume_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, split_ARG))
+	if (lp->split)
 		return _convert_cache_volume_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, uncache_ARG))
+	if (lp->uncache)
 		return _convert_cache_volume_uncache(cmd, lv, lp);
 
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
 
-	/* Using --thinpool is ambiguous and not preferred. */
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
+	if (segtype_is_thin_pool(lp->segtype) ||
+	    arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4204,10 +4203,10 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
 			       struct lvconvert_params *lp)
 {
-	if (arg_is_set(cmd, splitcache_ARG))
+	if (lp->splitcache)
 		return _convert_cache_pool_splitcache(cmd, lv, lp);
 
-	if (arg_is_set(cmd, split_ARG))
+	if (lp->split)
 		return _convert_cache_pool_splitcache(cmd, lv, lp);
 
 	/* FIXME: swapping the cache pool metadata LV needs a specific option like --swapmetadata */
@@ -4234,7 +4233,7 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, mirrorlog_ARG) || arg_is_set(cmd, corelog_ARG))
 		return _convert_mirror_log(cmd, lv, lp);
 
-	if (arg_is_set(cmd, repair_ARG))
+	if (lp->repair)
 		return _convert_mirror_repair(cmd, lv, lp);
 
 	if (_linear_type_requested(lp->type_str))
@@ -4304,7 +4303,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, mirrors_ARG))
 		return _convert_raid_number(cmd, lv, lp);
 
-	if (arg_is_set(cmd, repair_ARG))
+	if (lp->repair)
 		return _convert_raid_repair(cmd, lv, lp);
 
 	if (arg_is_set(cmd, replace_ARG))
@@ -4332,7 +4331,7 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		if (arg_is_set(cmd, splitmirrors_ARG))
 			return _convert_raid_splitmirrors(cmd, lv, lp);
 
-		if (arg_is_set(cmd, merge_ARG))
+		if (lp->merge)
 			return _convert_raid_merge(cmd, lv, lp);
 
 		if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
@@ -4344,14 +4343,12 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		if (lp->cache)
 			return _convert_raid_cache(cmd, lv, lp);
 
-		/* Using --thinpool is ambiguous and not preferred. */
-
-		if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
+		if (segtype_is_thin_pool(lp->segtype) ||
+		    arg_is_set(cmd, thinpool_ARG))
 			return _convert_raid_thin_pool(cmd, lv, lp);
 
-		/* Using --cachepool is ambiguous and not preferred. */
-
-		if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
+		if (segtype_is_cache_pool(lp->segtype) ||
+		    arg_is_set(cmd, cachepool_ARG))
 			return _convert_raid_cache_pool(cmd, lv, lp);
 
 		/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
@@ -4369,10 +4366,10 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
 
 	/* FIXME: add --merge-mirror to make this distinct from --merge-snapshot. */
-	if (arg_is_set(cmd, merge_ARG))
+	if (lp->merge)
 		return _convert_striped_merge(cmd, lv, lp);
 
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) || arg_is_set(cmd, snapshot_ARG))
+	if (lp->snapshot || segtype_is_snapshot(lp->segtype))
 		return _convert_striped_snapshot(cmd, lv, lp);
 
 	if (lp->thin)
@@ -4381,14 +4378,12 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->cache)
 		return _convert_striped_cache(cmd, lv, lp);
 
-	/* Using --thinpool is ambiguous and not preferred. */
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_THIN_POOL) || arg_is_set(cmd, thinpool_ARG))
+	if (segtype_is_thin_pool(lp->segtype) ||
+	    arg_is_set(cmd, thinpool_ARG))
 		return _convert_striped_thin_pool(cmd, lv, lp);
 
-	/* Using --cachepool is ambiguous and not preferred. */
-
-	if (!strcmp(lp->type_str, SEG_TYPE_NAME_CACHE_POOL) || arg_is_set(cmd, cachepool_ARG))
+	if (segtype_is_cache_pool(lp->segtype) ||
+	    arg_is_set(cmd, cachepool_ARG))
 		return _convert_striped_cache_pool(cmd, lv, lp);
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR))


