From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:07 +0000 (UTC)
Subject: master - cleanup: cache use const char policy
Message-ID: <20140401185607.78D6B6092A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2ea3cd7ba998125e7d9e20981157c087c0d261b
Commit:        e2ea3cd7ba998125e7d9e20981157c087c0d261b
Parent:        d58cc2c0fc7cd8fd658b03d6fabdfbdf757562c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 14:41:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:54:09 2014 +0200

cleanup: cache use const char policy

Policy should be const char pointer.
---
 lib/activate/activate.c          |    6 +++---
 lib/activate/activate.h          |    4 ++--
 lib/cache_segtype/cache.c        |    4 ++--
 lib/metadata/cache_manip.c       |    4 ++--
 lib/metadata/metadata-exported.h |    6 +++---
 libdm/libdevmapper.h             |    6 +++---
 libdm/libdm-deptree.c            |   12 ++++++------
 7 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2fd1840..6667dfc 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -290,7 +290,7 @@ int lv_cache_block_info(const struct logical_volume *lv,
 }
 int lv_cache_policy_info(const struct logical_volume *lv,
 			 char **policy_name, int *policy_argc,
-			 char ***policy_argv)
+			 const char *const **policy_argv)
 {
 	return 0;
 }
@@ -1055,8 +1055,8 @@ int lv_cache_block_info(struct logical_volume *lv,
 }
 
 int lv_cache_policy_info(struct logical_volume *lv,
-			 char **policy_name, int *policy_argc,
-			 char ***policy_argv)
+			 const char **policy_name, int *policy_argc,
+			 const char ***policy_argv)
 {
 	int i;
 	struct lv_segment *cache_seg;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 5b17b8a..435cac5 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -124,8 +124,8 @@ int lv_cache_block_info(struct logical_volume *lv,
 			uint32_t *chunk_size, uint64_t *dirty_count,
 			uint64_t *used_count, uint64_t *total_count);
 int lv_cache_policy_info(struct logical_volume *lv,
-			 char **policy_name, int *policy_argc,
-			 char ***policy_argv);
+			 const char **policy_name, int *policy_argc,
+			 const char ***policy_argv);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index df521c4..3b1214b 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -110,7 +110,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		if (str &&
 		    (!(argv_str = dm_pool_strdup(mem, str)) ||
 		     ((int)seg->core_argc != dm_split_words(argv_str, seg->core_argc,
-							    0, seg->core_argv))))
+							    0, (char **) seg->core_argv))))
 			return SEG_LOG_ERROR("core_argc and core_argv do"
 					     " not match in");
 	}
@@ -149,7 +149,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		    (!(argv_str = dm_pool_strdup(mem, str)) ||
 		     ((int)seg->policy_argc != dm_split_words(argv_str,
 							      seg->policy_argc,
-							      0, seg->policy_argv))))
+							      0, (char **) seg->policy_argv))))
 			return SEG_LOG_ERROR("policy_argc and policy_argv do"
 					     " not match in");
 	}
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 4c41010..0988e48 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -179,7 +179,7 @@ static int _cleanup_orphan_lv(struct logical_volume *lv)
 int lv_cache_remove(struct logical_volume *cache_lv)
 {
 	struct cmd_context *cmd = cache_lv->vg->cmd;
-	char *policy_name;
+	const char *policy_name;
 	uint64_t dirty_blocks;
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
@@ -220,7 +220,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		 * Is there are clean way to free the memory for the name
 		 * and argv when changing the policy?
 		 */
-		cache_seg->policy_name = (char *)"cleaner";
+		cache_seg->policy_name = "cleaner";
 		cache_seg->policy_argc = 0;
 		cache_seg->policy_argv = NULL;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 347e080..6f97564 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -398,10 +398,10 @@ struct lv_segment {
 
 	uint32_t feature_flags;			/* For cache */
 	unsigned core_argc;			/* For cache */
-	char **core_argv;			/* For cache */
-	char *policy_name;			/* For cache */
+	const char **core_argv;			/* For cache */
+	const char *policy_name;		/* For cache */
 	unsigned policy_argc;			/* For cache */
-	char **policy_argv;			/* For cache */
+	const char **policy_argv;		/* For cache */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index dd57457..5f7b14c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -773,10 +773,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint32_t chunk_size,
 				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
 				  unsigned core_argc,
-				  char **core_argv,
-				  char *policy_name,
+				  const char *const *core_argv,
+				  const char *policy_name,
 				  unsigned policy_argc,
-				  char **policy_argv);
+				  const char *const *policy_argv);
 
 /*
  * Replicator operation mode
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e513885..03ec9cb 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -173,10 +173,10 @@ struct load_segment {
 	char *uuid;			/* Clustered mirror log */
 
 	unsigned core_argc;		/* Cache */
-	char **core_argv;		/* Cache */
-	char *policy_name;		/* Cache */
+	const char *const *core_argv;	/* Cache */
+	const char *policy_name;	/* Cache */
 	unsigned policy_argc;		/* Cache */
-	char **policy_argv;		/* Cache */
+	const char *const *policy_argv;	/* Cache */
 
 	const char *cipher;		/* Crypt */
 	const char *chainmode;		/* Crypt */
@@ -3227,10 +3227,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint32_t chunk_size,
 				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
 				  unsigned core_argc,
-				  char **core_argv,
-				  char *policy_name,
+				  const char *const *core_argv,
+				  const char *policy_name,
 				  unsigned policy_argc,
-				  char **policy_argv)
+				  const char *const *policy_argv)
 {
 	int i;
 	struct load_segment *seg = NULL;


