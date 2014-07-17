From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:13 +0000 (UTC)
Subject: master - cache: use get_cache_mode for validation
Message-ID: <20140717142913.4256561171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5d6c4b0f3527b42ff3e7ef7a68010c3540d6f41
Commit:        f5d6c4b0f3527b42ff3e7ef7a68010c3540d6f41
Parent:        8f9f18013948f696bffaddb612d55a94f6279c9c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 15:12:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:16:45 2014 +0200

cache: use get_cache_mode for validation

Use a single function to validate cache mode arg
and set DM_ feature flags.
---
 lib/cache_segtype/cache.c        |    6 +-----
 lib/metadata/cache_manip.c       |   14 ++++++++++++++
 lib/metadata/metadata-exported.h |    1 +
 tools/lvconvert.c                |   13 +++----------
 tools/lvcreate.c                 |   14 +++-----------
 5 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 0e49530..ddaf3cf 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -74,11 +74,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	if (dm_config_has_node(sn, "cache_mode")) {
 		if (!(str = dm_config_find_str(sn, "cache_mode", NULL)))
 			return SEG_LOG_ERROR("cache_mode must be a string in");
-		if (!strcmp(str, "writethrough"))
-			seg->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-		else if (!strcmp(str, "writeback"))
-			seg->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
-		else
+		if (!get_cache_mode(str, &seg->feature_flags))
 			return SEG_LOG_ERROR("Unknown cache_mode in");
 	}
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index e220dd9..8a5e5e3 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -299,3 +299,17 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 	return 1;
 }
+
+int get_cache_mode(const char *str, uint32_t *flags)
+{
+	if (!strcmp(str, "writethrough"))
+		*flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+	else if (!strcmp(str, "writeback"))
+		*flags |= DM_CACHE_FEATURE_WRITEBACK;
+	else {
+		log_error("Cache pool cachemode \"%s\" is unknown.", str);
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f2521db..2b06718 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1050,6 +1050,7 @@ int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 struct logical_volume *lv_cache_create(struct logical_volume *pool,
 				       struct logical_volume *origin);
 int lv_cache_remove(struct logical_volume *cache_lv);
+int get_cache_mode(const char *str, uint32_t *flags);
 /* --  metadata/cache_manip.c */
 
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e128b81..eef408a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -289,16 +289,9 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 	}
 
 	if (cachepool) {
-		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL))) {
-			if (!strcmp(tmp_str, "writeback"))
-				lp->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
-			else if (!strcmp(tmp_str, "writethrough"))
-				lp->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-			else {
-				log_error("Unknown cachemode argument");
-				return 0;
-			}
-		}
+		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL)) &&
+		    !get_cache_mode(tmp_str, &lp->feature_flags))
+			return_0;
 	} else {
 		if (!arg_is_any_set(cmd, "is valid only with cache pools",
 				    cachemode_ARG, -1))
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8e45cc1..e9a170c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -713,17 +713,9 @@ static int _read_cache_pool_params(struct lvcreate_params *lp,
 	lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
 					DEFAULT_CACHE_POOL_CHUNK_SIZE * 2);
 
-	str_arg = arg_str_value(cmd, cachemode_ARG, NULL);
-	if (str_arg) {
-		if (!strcmp(str_arg, "writeback"))
-			lp->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
-		else if (!strcmp(str_arg, "writethrough"))
-			lp->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-		else {
-			log_error("Unknown cachemode argument");
-			return 0;
-		}
-	}
+	if ((str_arg = arg_str_value(cmd, cachemode_ARG, NULL)) &&
+	    !get_cache_mode(str_arg, &lp->feature_flags))
+		return_0;
 
 	return 1;
 }


