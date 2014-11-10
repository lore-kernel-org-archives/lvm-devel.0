From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:29 +0000 (UTC)
Subject: master - cache: new API for libdm
Message-ID: <20141110210629.DB16660799@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e230a8ad80c0c2f48c04979405fe2897f7ef769
Commit:        3e230a8ad80c0c2f48c04979405fe2897f7ef769
Parent:        824019531cbba02c722cb0bf0957ac84eccef3b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 9 20:18:00 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cache: new API for libdm

---
 lib/cache_segtype/cache.c        |  130 +++++++++++--------------------------
 lib/metadata/cache_manip.c       |   14 +---
 lib/metadata/metadata-exported.h |   13 ++---
 tools/lvconvert.c                |    2 +-
 4 files changed, 48 insertions(+), 111 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ea480de..6dcbf42 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -38,8 +38,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	uint32_t chunk_size;
 	struct logical_volume *data_lv, *meta_lv;
 	const char *str = NULL;
-	char *argv_str;
-	struct dm_pool *mem = seg->lv->vg->vgmem; //FIXME: what mempool should be used?
+	struct dm_pool *mem = seg->lv->vg->vgmem;
 
 	if (!dm_config_has_node(sn, "data"))
 		return SEG_LOG_ERROR("Cache data not specified in");
@@ -62,7 +61,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 
 	/*
 	 * Read in features:
-	 *   cache_mode = {writethrough|writeback}
+	 *   cache_mode = {passthrough|writethrough|writeback}
 	 *
 	 *   'cache_mode' does not have to be present.
 	 */
@@ -74,76 +73,30 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	}
 
 	/*
-	 * Read in core arguments (these are key/value pairs)
-	 *   core_argc = <# args>
-	 *   core_argv = "[<key> <value>]..."
+	 * Read in policy args:
+	 *   mq {
+	 *	migration_threshold=2048
+	 *	sequention_threashold=100
+	 *	random_threashold=200
+	 *	read_promote_adjustment=10
+	 *	write_promote_adjustment=20
+	 *	discard_promote_adjustment=40
 	 *
-	 *   'core_argc' does not have to be present.  If it is not present,
-	 *   any other core_* fields are ignored.  If it is present, then
-	 *   'core_argv' must be present - even if they are
-	 *   'core_argc = 0' and 'core_argv = ""'.
-	 */
-	if (dm_config_has_node(sn, "core_argc")) {
-		if (!dm_config_has_node(sn, "core_argv"))
-			return SEG_LOG_ERROR("not all core arguments defined in");
-
-		if (!dm_config_get_uint32(sn, "core_argc", &seg->core_argc))
-			return SEG_LOG_ERROR("Unable to read core_argc in");
-
-		str = dm_config_find_str(sn, "core_argv", NULL);
-		if ((str && !seg->core_argc) || (!str && seg->core_argc))
-			return SEG_LOG_ERROR("core_argc and core_argv do"
-					     " not match in");
-
-		if (!(seg->core_argv =
-		      dm_pool_alloc(mem, sizeof(char *) * seg->core_argc)))
-			return_0;
-		if (str &&
-		    (!(argv_str = dm_pool_strdup(mem, str)) ||
-		     ((int)seg->core_argc != dm_split_words(argv_str, seg->core_argc,
-							    0, (char **) seg->core_argv))))
-			return SEG_LOG_ERROR("core_argc and core_argv do"
-					     " not match in");
-	}
-
-	/*
-	 * Read in policy:
-	 *   policy_name = "<policy_name>"
-	 *   policy_argc = <# args>
-	 *   policy_argv = "[<key> <value>]..."
+	 *	<key> = <value>
+	 *	<key> = <value>
+	 *	...
+	 *   }
 	 *
-	 *   'policy_name' does not have to be present.  If it is not present,
-	 *   any other policy_* fields are ignored.  If it is present, then
-	 *   the other policy_* fields must be present - even if they are
-	 *   'policy_argc = 0' and 'policy_argv = ""'.
+	 *   If the policy is not present, default policy is used.
 	 */
-	if (dm_config_has_node(sn, "policy_name")) {
-		if (!dm_config_has_node(sn, "policy_argc") ||
-		    !dm_config_has_node(sn, "policy_argv"))
-			return SEG_LOG_ERROR("not all policy arguments defined in");
-		if (!(str = dm_config_find_str(sn, "policy_name", NULL)))
-			return SEG_LOG_ERROR("policy_name must be a string in");
-		seg->policy_name = dm_pool_strdup(mem, str);
-
-		if (!dm_config_get_uint32(sn, "policy_argc", &seg->policy_argc))
-			return SEG_LOG_ERROR("Unable to read policy_argc in");
-
-		str = dm_config_find_str(sn, "policy_argv", NULL);
-		if ((str && !seg->policy_argc) || (!str && seg->policy_argc))
-			return SEG_LOG_ERROR("policy_argc and policy_argv do"
-					     " not match in");
-
-		if (!(seg->policy_argv =
-		      dm_pool_alloc(mem, sizeof(char *) * seg->policy_argc)))
-			return_0;
-		if (str &&
-		    (!(argv_str = dm_pool_strdup(mem, str)) ||
-		     ((int)seg->policy_argc != dm_split_words(argv_str,
-							      seg->policy_argc,
-							      0, (char **) seg->policy_argv))))
-			return SEG_LOG_ERROR("policy_argc and policy_argv do"
-					     " not match in");
-	}
+	for (; sn; sn = sn->sib)
+		if (!sn->v) {
+			if (seg->policy_args)
+				return SEG_LOG_ERROR("only a singly policy is supported for");
+
+			if (!(seg->policy_args = dm_config_clone_node_with_mem(mem, sn, 0)))
+				return_0;
+		}
 
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
@@ -165,8 +118,6 @@ static int _cache_pool_text_import_area_count(const struct dm_config_node *sn,
 static int _cache_pool_text_export(const struct lv_segment *seg,
 				   struct formatter *f)
 {
-	unsigned i;
-	char buf[256]; //FIXME: IS THERE AN 'outf' THAT DOESN'T DO NEWLINE?!?
 	const char *cache_mode;
 
 	if (!(cache_mode = get_cache_pool_cachemode_name(seg)))
@@ -177,22 +128,8 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
 	outf(f, "cache_mode = \"%s\"", cache_mode);
 
-	if (seg->core_argc) {
-		outf(f, "core_argc = %u", seg->core_argc);
-		outf(f, "core_argv = \"");
-		for (i = 0; i < seg->core_argc; i++)
-			outf(f, "%s%s", i ? " " : "", seg->core_argv[i]);
-		outf(f, "\"");
-	}
-
-	if (seg->policy_name) {
-		outf(f, "policy_name = \"%s\"", seg->policy_name);
-		outf(f, "policy_argc = %u", seg->policy_argc);
-		buf[0] = '\0';
-		for (i = 0; i < seg->policy_argc; i++)
-			sprintf(buf, "%s%s", i ? " " : "", seg->policy_argv[i]);
-		outf(f, "policy_argv = \"%s\"", buf);
-	}
+	if (seg->policy_args)
+		out_config_node(f, seg->policy_args);
 
 	return 1;
 }
@@ -284,6 +221,12 @@ static int _cache_text_import(struct lv_segment *seg,
 
 	if (!set_lv_segment_area_lv(seg, 0, origin_lv, 0, 0))
 		return_0;
+
+	seg->cleaner_policy = 0;
+	if (dm_config_has_node(sn, "cleaner") &&
+	    !dm_config_get_uint32(sn, "cleaner", &seg->cleaner_policy))
+		return SEG_LOG_ERROR("Could not read cache cleaner in");
+
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
 		return_0;
 
@@ -306,6 +249,9 @@ static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
 	outf(f, "cache_pool = \"%s\"", seg->pool_lv->name);
 	outf(f, "origin = \"%s\"", seg_lv(seg, 0)->name);
 
+	if (seg->cleaner_policy)
+		outf(f, "cleaner = 1");
+
 	return 1;
 }
 
@@ -321,6 +267,8 @@ static int _cache_add_target_line(struct dev_manager *dm,
 {
 	struct lv_segment *cache_pool_seg = first_seg(seg->pool_lv);
 	char *metadata_uuid, *data_uuid, *origin_uuid;
+	const char *policy_name = seg->cleaner_policy ? "cleaner" :
+		cache_pool_seg->policy_args ? cache_pool_seg->policy_args->key : NULL;
 
 	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
 		return_0;
@@ -336,12 +284,12 @@ static int _cache_add_target_line(struct dev_manager *dm,
 					   metadata_uuid,
 					   data_uuid,
 					   origin_uuid,
-					   NULL,
-					   cache_pool_seg->policy_name,
+					   seg->cleaner_policy ? NULL : cache_pool_seg->policy_args,
+					   policy_name,
 					   cache_pool_seg->chunk_size))
 		return_0;
 
-	return add_areas_line(dm, seg, node, 0u, seg->area_count);
+	return 1;
 }
 #endif /* DEVMAPPER_SUPPORT */
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 69a51ef..cce2911 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -301,19 +301,11 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	dm_pool_destroy(status->mem);
 
 	if (!is_cleaner) {
-		/* We must swap in the cleaner to flush the cache */
+		/* Switch to cleaner policy to flush the cache */
 		log_print_unless_silent("Flushing cache for %s.", cache_lv->name);
-
-		/*
-		 * Is there are clean way to free the memory for the name
-		 * and argv when changing the policy?
-		 */
-		cache_seg->policy_name = "cleaner";
-		cache_seg->policy_argc = 0;
-		cache_seg->policy_argv = NULL;
-
+		cache_seg->cleaner_policy = 1;
 		/* update the kernel to put the cleaner policy in place */
-		if (!lv_update_and_reload(cache_lv))
+		if (!lv_update_and_reload_origin(cache_lv))
 			return_0;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4c15fee..5acc511 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -425,15 +425,12 @@ struct lv_segment {
 	thin_discards_t discards;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *external_lv;	/* For thin */
-	struct logical_volume *pool_lv;		/* For thin */
+	struct logical_volume *pool_lv;		/* For thin, cache */
 	uint32_t device_id;			/* For thin, 24bit */
 
-	uint32_t feature_flags;			/* For cache */
-	unsigned core_argc;			/* For cache */
-	const char **core_argv;			/* For cache */
-	const char *policy_name;		/* For cache */
-	unsigned policy_argc;			/* For cache */
-	const char **policy_argv;		/* For cache */
+	uint64_t feature_flags;			/* For cache_pool */
+	struct dm_config_node *policy_args;	/* For cache_pool  (-> policy_name) */
+	unsigned cleaner_policy;		/* For cache */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
@@ -851,7 +848,7 @@ struct lvcreate_params {
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */
 
-	uint32_t feature_flags; /* cache */
+	uint64_t feature_flags; /* cache */
 
 	const struct segment_type *segtype; /* all */
 	unsigned target_attr; /* all */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8b09ee6..d4f3db1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -48,7 +48,7 @@ struct lvconvert_params {
 	uint32_t stripes;
 	uint32_t stripe_size;
 	uint32_t read_ahead;
-	uint32_t feature_flags; /* cache_pool */
+	uint64_t feature_flags; /* cache_pool */
 
 	const struct segment_type *segtype;
 	unsigned target_attr;


