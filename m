From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Feb 2014 10:39:01 +0000 (UTC)
Subject: master - cache: using unsigned argc
Message-ID: <20140215103901.4C25360E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c651c614ec758702cc63a8ac96aac1ddfd45a067
Commit:        c651c614ec758702cc63a8ac96aac1ddfd45a067
Parent:        da268eb4cc297d42d123821df3ce441fa4bec293
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 14 22:33:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 15 11:36:53 2014 +0100

cache: using unsigned argc

Convert using unsigned for _argc.
---
 lib/cache_segtype/cache.c        |   22 ++++++++++------------
 lib/metadata/metadata-exported.h |    4 ++--
 libdm/libdevmapper.h             |    4 ++--
 libdm/libdm-deptree.c            |   17 +++++++++--------
 4 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 78a23d7..90ed40e 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -96,8 +96,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 		if (!dm_config_has_node(sn, "core_argv"))
 			return SEG_LOG_ERROR("not all core arguments defined in");
 
-		if (!dm_config_get_uint32(sn, "core_argc",
-					  (uint32_t *)&seg->core_argc))
+		if (!dm_config_get_uint32(sn, "core_argc", &seg->core_argc))
 			return SEG_LOG_ERROR("Unable to read core_argc in");
 
 		str = dm_config_find_str(sn, "core_argv", NULL);
@@ -110,8 +109,8 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return_0;
 		if (str &&
 		    (!(argv_str = dm_pool_strdup(mem, str)) ||
-		     (seg->core_argc != dm_split_words(argv_str, seg->core_argc,
-						       0, seg->core_argv))))
+		     ((int)seg->core_argc != dm_split_words(argv_str, seg->core_argc,
+							    0, seg->core_argv))))
 			return SEG_LOG_ERROR("core_argc and core_argv do"
 					     " not match in");
 	}
@@ -135,8 +134,7 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("policy_name must be a string in");
 		seg->policy_name = dm_pool_strdup(mem, str);
 
-		if (!dm_config_get_uint32(sn, "policy_argc",
-					  (uint32_t *)&seg->policy_argc))
+		if (!dm_config_get_uint32(sn, "policy_argc", &seg->policy_argc))
 			return SEG_LOG_ERROR("Unable to read policy_argc in");
 
 		str = dm_config_find_str(sn, "policy_argv", NULL);
@@ -149,9 +147,9 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return_0;
 		if (str &&
 		    (!(argv_str = dm_pool_strdup(mem, str)) ||
-		     (seg->policy_argc != dm_split_words(argv_str,
-							 seg->policy_argc,
-							 0, seg->policy_argv))))
+		     ((int)seg->policy_argc != dm_split_words(argv_str,
+							      seg->policy_argc,
+							      0, seg->policy_argv))))
 			return SEG_LOG_ERROR("policy_argc and policy_argv do"
 					     " not match in");
 	}
@@ -176,7 +174,7 @@ static int _cache_pool_text_import_area_count(const struct dm_config_node *sn,
 static int _cache_pool_text_export(const struct lv_segment *seg,
 				   struct formatter *f)
 {
-	int i;
+	unsigned i;
 	char buf[256]; //FIXME: IS THERE AN 'outf' THAT DOESN'T DO NEWLINE?!?
 	uint32_t feature_flags = seg->feature_flags;
 
@@ -199,7 +197,7 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	}
 
 	if (seg->core_argc) {
-		outf(f, "core_argc = %d", seg->core_argc);
+		outf(f, "core_argc = %u", seg->core_argc);
 		outf(f, "core_argv = \"");
 		for (i = 0; i < seg->core_argc; i++)
 			outf(f, "%s%s", i ? " " : "", seg->core_argv[i]);
@@ -208,7 +206,7 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 
 	if (seg->policy_name) {
 		outf(f, "policy_name = \"%s\"", seg->policy_name);
-		outf(f, "policy_argc = %d", seg->policy_argc);
+		outf(f, "policy_argc = %u", seg->policy_argc);
 		buf[0] = '\0';
 		for (i = 0; i < seg->policy_argc; i++)
 			sprintf(buf, "%s%s", i ? " " : "", seg->policy_argv[i]);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6ca4309..438f5b2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -397,10 +397,10 @@ struct lv_segment {
 	uint32_t device_id;			/* For thin, 24bit */
 
 	uint32_t feature_flags;			/* For cache */
-	int core_argc;				/* For cache */
+	unsigned core_argc;			/* For cache */
 	char **core_argv;			/* For cache */
 	char *policy_name;			/* For cache */
-	int policy_argc;			/* For cache */
+	unsigned policy_argc;			/* For cache */
 	char **policy_argv;			/* For cache */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 112ec27..cbd86d4 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -772,10 +772,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *origin_uuid,
 				  uint32_t chunk_size,
 				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
-				  int core_argc,
+				  unsigned core_argc,
 				  char **core_argv,
 				  char *policy_name,
-				  int   policy_argc,
+				  unsigned policy_argc,
 				  char **policy_argv);
 
 /*
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d2a54eb..0834f38 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -172,10 +172,10 @@ struct load_segment {
 	uint32_t flags;			/* Mirror + raid + Cache */
 	char *uuid;			/* Clustered mirror log */
 
-	int   core_argc;		/* Cache */
+	unsigned core_argc;		/* Cache */
 	char **core_argv;		/* Cache */
 	char *policy_name;		/* Cache */
-	int   policy_argc;		/* Cache */
+	unsigned policy_argc;		/* Cache */
 	char **policy_argv;		/* Cache */
 
 	const char *cipher;		/* Crypt */
@@ -2274,7 +2274,8 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 				    struct load_segment *seg,
 				    char *params, size_t paramsize)
 {
-	int i, pos = 0;
+	int pos = 0;
+	unsigned i = 0;
 	unsigned feature_count;
 	struct seg_area *area;
 	char data[DM_FORMAT_DEV_BUFSIZE];
@@ -2302,7 +2303,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 
 	/* Features */
 	feature_count = hweight32(seg->flags);
-	EMIT_PARAMS(pos, " %d", feature_count);
+	EMIT_PARAMS(pos, " %u", feature_count);
 	if (seg->flags & DM_CACHE_FEATURE_WRITETHROUGH)
 		EMIT_PARAMS(pos, " writethrough");
 	else if (seg->flags & DM_CACHE_FEATURE_WRITEBACK)
@@ -2310,7 +2311,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 
 	/* Core Arguments (like 'migration_threshold') */
 	if (seg->core_argc) {
-		EMIT_PARAMS(pos, " %d", seg->core_argc);
+		EMIT_PARAMS(pos, " %u", seg->core_argc);
 		for (i = 0; i < seg->core_argc; i++)
 			EMIT_PARAMS(pos, " %s", seg->core_argv[i]);
 	}
@@ -2319,7 +2320,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	if (!seg->policy_name)
 		EMIT_PARAMS(pos, " default 0");
 	else {
-		EMIT_PARAMS(pos, " %s %d", seg->policy_name, seg->policy_argc);
+		EMIT_PARAMS(pos, " %s %u", seg->policy_name, seg->policy_argc);
 		if (seg->policy_argc % 2) {
 			log_error(INTERNAL_ERROR
 				  "Cache policy arguments must be in "
@@ -3206,10 +3207,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *origin_uuid,
 				  uint32_t chunk_size,
 				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
-				  int core_argc,
+				  unsigned core_argc,
 				  char **core_argv,
 				  char *policy_name,
-				  int   policy_argc,
+				  unsigned policy_argc,
 				  char **policy_argv)
 {
 	int i;


