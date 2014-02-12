From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 12 Feb 2014 15:55:39 +0000 (UTC)
Subject: master - cache: Ability to convert an existing LV into a cached LV
Message-ID: <20140212155539.3992860E99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0912cf67aae21446a10b3a22067aee1e8f792856
Commit:        0912cf67aae21446a10b3a22067aee1e8f792856
Parent:        c8b6c4aee9a298a4c415d45c9e144d641bc7c6c6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 12 09:55:35 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 12 09:55:35 2014 -0600

cache: Ability to convert an existing LV into a cached LV

Users now have the ability to convert their existing logical volumes
into cached logical volumes.  A cache pool LV must be specified using
the '--cachepool' argument.  The cachepool is the small, fast LV used
to cache the large, slow LV that is being converted.
---
 lib/metadata/cache_manip.c |    7 +++++
 tools/args.h               |    1 +
 tools/commands.h           |    9 +++++-
 tools/lvconvert.c          |   54 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 67 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index f7518b0..673d90e 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -104,6 +104,13 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 		return NULL;
 	}
 
+	if (!dm_list_empty(&pool->segs_using_this_lv)) {
+		seg = get_only_segment_using_this_lv(pool);
+		log_error("%s is already in use by %s",
+			  pool->name, seg ? seg->lv->name : "another LV");
+		return NULL;
+	}
+
 	if (lv_is_cache_type(origin)) {
 		/*
 		 * FIXME: We can layer caches, insert_layer_for_lv() would
diff --git a/tools/args.h b/tools/args.h
index 5f26511..f1a4ef4 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -63,6 +63,7 @@ arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(cache_ARG, '\0', "cache", NULL, 0)
 arg(cachemode_ARG, '\0', "cachemode", string_arg, 0)
+arg(cachepool_ARG, '\0', "cachepool", string_arg, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index a078b16..b0d608b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -221,9 +221,14 @@ xx(lvconvert,
    "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
    "\t [--poolmetadataspare {y|n}]]\n"
-   "\tCacheDataLogicalVolume[Path]\n\n",
+   "\tCacheDataLogicalVolume[Path]\n\n"
 
-   alloc_ARG, background_ARG, cachemode_ARG, chunksize_ARG,
+   "lvconvert "
+   "--type cache\n"
+   "\t--cachepool CachePoolLogicalVolume[Path]\n"
+   "\tLogicalVolume[Path]\n\n",
+
+   alloc_ARG, background_ARG, cachemode_ARG, cachepool_ARG, chunksize_ARG,
    corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
    mirrors_ARG, name_ARG, noudevsync_ARG, originname_ARG, poolmetadata_ARG,
    poolmetadatasize_ARG, poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5774e11..d53b83a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -28,6 +28,7 @@ struct lvconvert_params {
 	int zero;
 
 	const char *origin;
+	const char *cachepool;
 	const char *lv_name;
 	const char *lv_split_name;
 	const char *lv_name_full;
@@ -201,7 +202,7 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	/* FIXME: Check thin-pool and thin more thoroughly! */
 	if (!strcmp(type_str, "snapshot") ||
 	    !strncmp(type_str, "raid", 4) ||
-	    !strcmp(type_str, "cache_pool") ||
+	    !strcmp(type_str, "cache_pool") || !strcmp(type_str, "cache") ||
 	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
 		return 1;
 
@@ -288,7 +289,14 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, thin_ARG))
 		lp->thin = 1;
 
-	if (arg_count(cmd, thinpool_ARG) || cache_pool) {
+	if (arg_count(cmd, cachepool_ARG)) {
+		if (strcmp(type_str, "cache")) {
+			log_error("--cachepool argument is only valid with "
+				  " the \"cache\" segment type");
+			return 0;
+		}
+		lp->cachepool = arg_str_value(cmd, cachepool_ARG, NULL);
+	} else if (arg_count(cmd, thinpool_ARG) || cache_pool) {
 		if (arg_count(cmd, merge_ARG)) {
 			log_error("--%spool and --merge are mutually exlusive.",
 				  cache_pool ? "type cache_" : "thin");
@@ -2926,6 +2934,41 @@ out:
 	return r;
 }
 
+static int _lvconvert_cache(struct logical_volume *origin,
+			    struct lvconvert_params *lp)
+{
+	struct cmd_context *cmd = origin->vg->cmd;
+	struct logical_volume *cache_lv;
+	struct logical_volume *cachepool;
+
+	if (!lp->cachepool) {
+		log_error("--cachepool argument is required.");
+		return 0;
+	}
+
+	if (!(cachepool = find_lv(origin->vg, lp->cachepool))) {
+		log_error("Unable to find cache pool LV, %s", lp->cachepool);
+		return 0;
+	}
+
+	if (!(cache_lv = lv_cache_create(cachepool, origin)))
+		return_0;
+
+	if (!vg_write(cache_lv->vg))
+		return_0;
+	if (!suspend_lv(cmd, cache_lv))
+		return_0;
+	if (!vg_commit(cache_lv->vg))
+		return_0;
+	if (!resume_lv(cmd, cache_lv))
+		return_0;
+
+	log_print_unless_silent("%s/%s is now cached.",
+				cache_lv->vg->name, cache_lv->name);
+
+	return 1;
+}
+
 static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
@@ -2996,6 +3039,13 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 
+	} else if (segtype_is_cache(lp->segtype)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
+		if (!_lvconvert_cache(lv, lp))
+			return_ECMD_FAILED;
+
 	} else if (segtype_is_cache_pool(lp->segtype)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;


