From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 28 Sep 2015 19:32:47 +0000 (UTC)
Subject: master - libdm: Move status fns from deptree to targets.
Message-ID: <20150928193247.656B4602F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0173c260d8270465f1895044b34609008962cc00
Commit:        0173c260d8270465f1895044b34609008962cc00
Parent:        9d815e5f5a17963a09b103177770e9af80c90e0f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 28 20:28:31 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 28 20:28:31 2015 +0100

libdm: Move status fns from deptree to targets.

libdm-deptree is only for functions working with dm tree nodes.
---
 WHATS_NEW_DM          |    1 +
 libdm/Makefile.in     |    9 +-
 libdm/libdm-common.h  |    2 +
 libdm/libdm-deptree.c |  344 +-----------------------------------------------
 libdm/libdm-targets.c |  357 +++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 366 insertions(+), 347 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b665bbc..c1c48ea 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Move target status functions out of libdm-deptree.
   Correct use of max_write_behind parameter when generating raid target line.
   Fix dm-event systemd service to make sure it is executed before mounting.
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 1b924ce..6b7cc48 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -21,13 +21,14 @@ SOURCES =\
 	datastruct/hash.c \
 	datastruct/list.c \
 	libdm-common.c \
-	libdm-file.c \
+	libdm-config.c \
 	libdm-deptree.c \
-	libdm-string.c \
+	libdm-file.c \
 	libdm-report.c \
-	libdm-timestamp.c \
 	libdm-stats.c \
-	libdm-config.c \
+	libdm-string.c \
+	libdm-targets.c \
+	libdm-timestamp.c \
 	mm/dbg_malloc.c \
 	mm/pool.c \
 	regex/matcher.c \
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index 4705a77..0083015 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -51,4 +51,6 @@ void selinux_release(void);
 void inc_suspended(void);
 void dec_suspended(void);
 
+int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s);
+
 #endif
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index b5067f5..ef283e9 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1427,48 +1427,6 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 	return r;
 }
 
-static int _thin_pool_parse_status(const char *params,
-				   struct dm_status_thin_pool *s)
-{
-	int pos;
-
-	if (!params) {
-		log_error("Failed to parse invalid thin params.");
-		return 0;
-	}
-
-	/* FIXME: add support for held metadata root */
-	if (sscanf(params, FMTu64 " " FMTu64 "/" FMTu64 " " FMTu64 "/" FMTu64 "%n",
-		   &s->transaction_id,
-		   &s->used_metadata_blocks,
-		   &s->total_metadata_blocks,
-		   &s->used_data_blocks,
-		   &s->total_data_blocks, &pos) < 5) {
-		log_error("Failed to parse thin pool params: %s.", params);
-		return 0;
-	}
-
-	/* New status flags */
-	if (strstr(params + pos, "no_discard_passdown"))
-		s->discards = DM_THIN_DISCARDS_NO_PASSDOWN;
-	else if (strstr(params + pos, "ignore_discard"))
-		s->discards = DM_THIN_DISCARDS_IGNORE;
-	else /* default discard_passdown */
-		s->discards = DM_THIN_DISCARDS_PASSDOWN;
-
-	if (strstr(params + pos, "ro "))
-		s->read_only = 1;
-	else if (strstr(params + pos, "fail"))
-		s->fail = 1;
-	else if (strstr(params + pos, "out_of_data_space"))
-		s->out_of_data_space = 1;
-
-	if (strstr(params + pos, "error_if_no_space"))
-		s->error_if_no_space = 1;
-
-	return 1;
-}
-
 static int _thin_pool_get_status(struct dm_tree_node *dnode,
 				 struct dm_status_thin_pool *s)
 {
@@ -1501,7 +1459,7 @@ static int _thin_pool_get_status(struct dm_tree_node *dnode,
 		goto out;
 	}
 
-	if (!_thin_pool_parse_status(params, s))
+	if (!parse_thin_pool_status(params, s))
 		goto_out;
 
 	log_debug_activation("Found transaction id %" PRIu64 " for thin pool %s "
@@ -3103,45 +3061,6 @@ int dm_tree_node_add_snapshot_merge_target(struct dm_tree_node *node,
 				    merge_uuid, 1, chunk_size);
 }
 
-int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
-			   struct dm_status_snapshot **status)
-{
-	struct dm_status_snapshot *s;
-	int r;
-
-	if (!params) {
-		log_error("Failed to parse invalid snapshot params.");
-		return 0;
-	}
-
-	if (!(s = dm_pool_zalloc(mem, sizeof(*s)))) {
-		log_error("Failed to allocate snapshot status structure.");
-		return 0;
-	}
-
-	r = sscanf(params, FMTu64 "/" FMTu64 " " FMTu64,
-		   &s->used_sectors, &s->total_sectors,
-		   &s->metadata_sectors);
-
-	if (r == 3 || r == 2)
-		s->has_metadata_sectors = (r == 3);
-	else if (!strcmp(params, "Invalid"))
-		s->invalid = 1;
-	else if (!strcmp(params, "Merge failed"))
-		s->merge_failed = 1;
-	else if (!strcmp(params, "Overflow"))
-		s->overflow = 1;
-	else {
-		dm_pool_free(mem, s);
-		log_error("Failed to parse snapshot params: %s.", params);
-		return 0;
-	}
-
-	*status = s;
-
-	return 1;
-}
-
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
 				  uint64_t size)
 {
@@ -3313,84 +3232,6 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 	return dm_tree_node_add_raid_target_with_params(node, size, &params);
 }
 
-/*
- * Various RAID status versions include:
- * Versions < 1.5.0 (4 fields):
- *   <raid_type> <#devs> <health_str> <sync_ratio>
- * Versions 1.5.0+  (6 fields):
- *   <raid_type> <#devs> <health_str> <sync_ratio> <sync_action> <mismatch_cnt>
- */
-int dm_get_status_raid(struct dm_pool *mem, const char *params,
-		       struct dm_status_raid **status)
-{
-	int i;
-	const char *pp, *p;
-	struct dm_status_raid *s;
-
-	if (!params || !(p = strchr(params, ' '))) {
-		log_error("Failed to parse invalid raid params.");
-		return 0;
-	}
-	p++;
-
-	/* second field holds the device count */
-	if (sscanf(p, "%d", &i) != 1)
-		return_0;
-
-	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_raid))))
-		return_0;
-
-	if (!(s->raid_type = dm_pool_zalloc(mem, p - params)))
-		goto_bad; /* memory is freed went pool is destroyed */
-
-	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
-		goto_bad;
-
-	if (sscanf(params, "%s %u %s %" PRIu64 "/%" PRIu64,
-		   s->raid_type,
-		   &s->dev_count,
-		   s->dev_health,
-		   &s->insync_regions,
-		   &s->total_regions) != 5) {
-		log_error("Failed to parse raid params: %s", params);
-		goto bad;
-	}
-
-	*status = s;
-
-	/*
-	 * All pre-1.5.0 version parameters are read.  Now we check
-	 * for additional 1.5.0+ parameters.
-	 *
-	 * Note that 'sync_action' will be NULL (and mismatch_count
-	 * will be 0) if the kernel returns a pre-1.5.0 status.
-	 */
-	for (p = params, i = 0; i < 4; i++, p++)
-		if (!(p = strchr(p, ' ')))
-			return 1;  /* return pre-1.5.0 status */
-
-	pp = p;
-	if (!(p = strchr(p, ' '))) {
-		log_error(INTERNAL_ERROR "Bad RAID status received.");
-		goto bad;
-	}
-	p++;
-
-	if (!(s->sync_action = dm_pool_zalloc(mem, p - pp)))
-		goto_bad;
-
-	if (sscanf(pp, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2) {
-		log_error("Failed to parse raid params: %s", params);
-		goto bad;
-	}
-
-	return 1;
-bad:
-	dm_pool_free(mem, s);
-
-	return 0;
-}
-
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
 				  uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
@@ -3482,143 +3323,6 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	return 1;
 }
 
-static const char *advance_to_next_word(const char *str, int count)
-{
-	int i;
-	const char *p;
-
-	for (p = str, i = 0; i < count; i++, p++)
-		if (!(p = strchr(p, ' ')))
-			return NULL;
-
-	return p;
-}
-
-/*
- * <metadata block size> <#used metadata blocks>/<#total metadata blocks>
- * <cache block size> <#used cache blocks>/<#total cache blocks>
- * <#read hits> <#read misses> <#write hits> <#write misses>
- * <#demotions> <#promotions> <#dirty> <#features> <features>*
- * <#core args> <core args>* <policy name> <#policy args> <policy args>*
- *
- * metadata block size      : Fixed block size for each metadata block in
- *                            sectors
- * #used metadata blocks    : Number of metadata blocks used
- * #total metadata blocks   : Total number of metadata blocks
- * cache block size         : Configurable block size for the cache device
- *                            in sectors
- * #used cache blocks       : Number of blocks resident in the cache
- * #total cache blocks      : Total number of cache blocks
- * #read hits               : Number of times a READ bio has been mapped
- *                            to the cache
- * #read misses             : Number of times a READ bio has been mapped
- *                            to the origin
- * #write hits              : Number of times a WRITE bio has been mapped
- *                            to the cache
- * #write misses            : Number of times a WRITE bio has been
- *                            mapped to the origin
- * #demotions               : Number of times a block has been removed
- *                            from the cache
- * #promotions              : Number of times a block has been moved to
- *                            the cache
- * #dirty                   : Number of blocks in the cache that differ
- *                            from the origin
- * #feature args            : Number of feature args to follow
- * feature args             : 'writethrough' (optional)
- * #core args               : Number of core arguments (must be even)
- * core args                : Key/value pairs for tuning the core
- *                            e.g. migration_threshold
- *			     *policy name              : Name of the policy
- * #policy args             : Number of policy arguments to follow (must be even)
- * policy args              : Key/value pairs
- *                            e.g. sequential_threshold
- */
-int dm_get_status_cache(struct dm_pool *mem, const char *params,
-			struct dm_status_cache **status)
-{
-	int i, feature_argc;
-	char *str;
-	const char *p, *pp;
-	struct dm_status_cache *s;
-
-	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_cache))))
-		return_0;
-
-	/* Read in args that have definitive placement */
-	if (sscanf(params,
-		   " %" PRIu32
-		   " %" PRIu64 "/%" PRIu64
-		   " %" PRIu32
-		   " %" PRIu64 "/%" PRIu64
-		   " %" PRIu64 " %" PRIu64
-		   " %" PRIu64 " %" PRIu64
-		   " %" PRIu64 " %" PRIu64
-		   " %" PRIu64
-		   " %d",
-		   &s->metadata_block_size,
-		   &s->metadata_used_blocks, &s->metadata_total_blocks,
-		   &s->block_size, /* AKA, chunk_size */
-		   &s->used_blocks, &s->total_blocks,
-		   &s->read_hits, &s->read_misses,
-		   &s->write_hits, &s->write_misses,
-		   &s->demotions, &s->promotions,
-		   &s->dirty_blocks,
-		   &feature_argc) != 14)
-		goto bad;
-
-	/* Now jump to "features" section */
-	if (!(p = advance_to_next_word(params, 12)))
-		goto bad;
-
-	/* Read in features */
-	for (i = 0; i < feature_argc; i++) {
-		if (!strncmp(p, "writethrough ", 13))
-			s->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
-		else if (!strncmp(p, "writeback ", 10))
-			s->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
-		else
-			log_error("Unknown feature in status: %s", params);
-
-		if (!(p = advance_to_next_word(p, 1)))
-			goto bad;
-	}
-
-	/* Read in core_args. */
-	if (sscanf(p, "%d ", &s->core_argc) != 1)
-		goto bad;
-	if (s->core_argc &&
-	    (!(s->core_argv = dm_pool_zalloc(mem, sizeof(char *) * s->core_argc)) ||
-	     !(p = advance_to_next_word(p, 1)) ||
-	     !(str = dm_pool_strdup(mem, p)) ||
-	     !(p = advance_to_next_word(p, s->core_argc)) ||
-	     (dm_split_words(str, s->core_argc, 0, s->core_argv) != s->core_argc)))
-		goto bad;
-
-	/* Read in policy args */
-	pp = p;
-	if (!(p = advance_to_next_word(p, 1)) ||
-	    !(s->policy_name = dm_pool_zalloc(mem, (p - pp))))
-		goto bad;
-	if (sscanf(pp, "%s %d", s->policy_name, &s->policy_argc) != 2)
-		goto bad;
-	if (s->policy_argc &&
-	    (!(s->policy_argv = dm_pool_zalloc(mem, sizeof(char *) * s->policy_argc)) ||
-	     !(p = advance_to_next_word(p, 1)) ||
-	     !(str = dm_pool_strdup(mem, p)) ||
-	     (dm_split_words(str, s->policy_argc, 0, s->policy_argv) != s->policy_argc)))
-		goto bad;
-
-	*status = s;
-	return 1;
-
-bad:
-	log_error("Failed to parse cache params: %s", params);
-	dm_pool_free(mem, s);
-	*status = NULL;
-
-	return 0;
-}
-
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
@@ -4045,52 +3749,6 @@ int dm_tree_node_set_thin_external_origin(struct dm_tree_node *node,
 	return 1;
 }
 
-int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
-			    struct dm_status_thin_pool **status)
-{
-	struct dm_status_thin_pool *s;
-
-	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
-		log_error("Failed to allocate thin_pool status structure.");
-		return 0;
-	}
-
-	if (!_thin_pool_parse_status(params, s)) {
-		dm_pool_free(mem, s);
-		return_0;
-	}
-
-	*status = s;
-
-	return 1;
-}
-
-int dm_get_status_thin(struct dm_pool *mem, const char *params,
-		       struct dm_status_thin **status)
-{
-	struct dm_status_thin *s;
-
-	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin)))) {
-		log_error("Failed to allocate thin status structure.");
-		return 0;
-	}
-
-	if (strchr(params, '-')) {
-		s->mapped_sectors = 0;
-		s->highest_mapped_sector = 0;
-	} else if (sscanf(params, FMTu64 " " FMTu64,
-		   &s->mapped_sectors,
-		   &s->highest_mapped_sector) != 2) {
-		dm_pool_free(mem, s);
-		log_error("Failed to parse thin params: %s.", params);
-		return 0;
-	}
-
-	*status = s;
-
-	return 1;
-}
-
 static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct dm_tree_node *dev_node, uint64_t offset)
 {
 	struct seg_area *area;
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
new file mode 100644
index 0000000..f22ad9c
--- /dev/null
+++ b/libdm/libdm-targets.c
@@ -0,0 +1,357 @@
+/*
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "dmlib.h"
+#include "libdm-common.h"
+
+int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
+			   struct dm_status_snapshot **status)
+{
+	struct dm_status_snapshot *s;
+	int r;
+
+	if (!params) {
+		log_error("Failed to parse invalid snapshot params.");
+		return 0;
+	}
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(*s)))) {
+		log_error("Failed to allocate snapshot status structure.");
+		return 0;
+	}
+
+	r = sscanf(params, FMTu64 "/" FMTu64 " " FMTu64,
+		   &s->used_sectors, &s->total_sectors,
+		   &s->metadata_sectors);
+
+	if (r == 3 || r == 2)
+		s->has_metadata_sectors = (r == 3);
+	else if (!strcmp(params, "Invalid"))
+		s->invalid = 1;
+	else if (!strcmp(params, "Merge failed"))
+		s->merge_failed = 1;
+	else if (!strcmp(params, "Overflow"))
+		s->overflow = 1;
+	else {
+		dm_pool_free(mem, s);
+		log_error("Failed to parse snapshot params: %s.", params);
+		return 0;
+	}
+
+	*status = s;
+
+	return 1;
+}
+
+/*
+ * Various RAID status versions include:
+ * Versions < 1.5.0 (4 fields):
+ *   <raid_type> <#devs> <health_str> <sync_ratio>
+ * Versions 1.5.0+  (6 fields):
+ *   <raid_type> <#devs> <health_str> <sync_ratio> <sync_action> <mismatch_cnt>
+ */
+int dm_get_status_raid(struct dm_pool *mem, const char *params,
+		       struct dm_status_raid **status)
+{
+	int i;
+	const char *pp, *p;
+	struct dm_status_raid *s;
+
+	if (!params || !(p = strchr(params, ' '))) {
+		log_error("Failed to parse invalid raid params.");
+		return 0;
+	}
+	p++;
+
+	/* second field holds the device count */
+	if (sscanf(p, "%d", &i) != 1)
+		return_0;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_raid))))
+		return_0;
+
+	if (!(s->raid_type = dm_pool_zalloc(mem, p - params)))
+		goto_bad; /* memory is freed went pool is destroyed */
+
+	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
+		goto_bad;
+
+	if (sscanf(params, "%s %u %s %" PRIu64 "/%" PRIu64,
+		   s->raid_type,
+		   &s->dev_count,
+		   s->dev_health,
+		   &s->insync_regions,
+		   &s->total_regions) != 5) {
+		log_error("Failed to parse raid params: %s", params);
+		goto bad;
+	}
+
+	*status = s;
+
+	/*
+	 * All pre-1.5.0 version parameters are read.  Now we check
+	 * for additional 1.5.0+ parameters.
+	 *
+	 * Note that 'sync_action' will be NULL (and mismatch_count
+	 * will be 0) if the kernel returns a pre-1.5.0 status.
+	 */
+	for (p = params, i = 0; i < 4; i++, p++)
+		if (!(p = strchr(p, ' ')))
+			return 1;  /* return pre-1.5.0 status */
+
+	pp = p;
+	if (!(p = strchr(p, ' '))) {
+		log_error(INTERNAL_ERROR "Bad RAID status received.");
+		goto bad;
+	}
+	p++;
+
+	if (!(s->sync_action = dm_pool_zalloc(mem, p - pp)))
+		goto_bad;
+
+	if (sscanf(pp, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2) {
+		log_error("Failed to parse raid params: %s", params);
+		goto bad;
+	}
+
+	return 1;
+bad:
+	dm_pool_free(mem, s);
+
+	return 0;
+}
+
+static const char *_advance_to_next_word(const char *str, int count)
+{
+	int i;
+	const char *p;
+
+	for (p = str, i = 0; i < count; i++, p++)
+		if (!(p = strchr(p, ' ')))
+			return NULL;
+
+	return p;
+}
+
+/*
+ * <metadata block size> <#used metadata blocks>/<#total metadata blocks>
+ * <cache block size> <#used cache blocks>/<#total cache blocks>
+ * <#read hits> <#read misses> <#write hits> <#write misses>
+ * <#demotions> <#promotions> <#dirty> <#features> <features>*
+ * <#core args> <core args>* <policy name> <#policy args> <policy args>*
+ *
+ * metadata block size      : Fixed block size for each metadata block in
+ *                            sectors
+ * #used metadata blocks    : Number of metadata blocks used
+ * #total metadata blocks   : Total number of metadata blocks
+ * cache block size         : Configurable block size for the cache device
+ *                            in sectors
+ * #used cache blocks       : Number of blocks resident in the cache
+ * #total cache blocks      : Total number of cache blocks
+ * #read hits               : Number of times a READ bio has been mapped
+ *                            to the cache
+ * #read misses             : Number of times a READ bio has been mapped
+ *                            to the origin
+ * #write hits              : Number of times a WRITE bio has been mapped
+ *                            to the cache
+ * #write misses            : Number of times a WRITE bio has been
+ *                            mapped to the origin
+ * #demotions               : Number of times a block has been removed
+ *                            from the cache
+ * #promotions              : Number of times a block has been moved to
+ *                            the cache
+ * #dirty                   : Number of blocks in the cache that differ
+ *                            from the origin
+ * #feature args            : Number of feature args to follow
+ * feature args             : 'writethrough' (optional)
+ * #core args               : Number of core arguments (must be even)
+ * core args                : Key/value pairs for tuning the core
+ *                            e.g. migration_threshold
+ *			     *policy name              : Name of the policy
+ * #policy args             : Number of policy arguments to follow (must be even)
+ * policy args              : Key/value pairs
+ *                            e.g. sequential_threshold
+ */
+int dm_get_status_cache(struct dm_pool *mem, const char *params,
+			struct dm_status_cache **status)
+{
+	int i, feature_argc;
+	char *str;
+	const char *p, *pp;
+	struct dm_status_cache *s;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_cache))))
+		return_0;
+
+	/* Read in args that have definitive placement */
+	if (sscanf(params,
+		   " %" PRIu32
+		   " %" PRIu64 "/%" PRIu64
+		   " %" PRIu32
+		   " %" PRIu64 "/%" PRIu64
+		   " %" PRIu64 " %" PRIu64
+		   " %" PRIu64 " %" PRIu64
+		   " %" PRIu64 " %" PRIu64
+		   " %" PRIu64
+		   " %d",
+		   &s->metadata_block_size,
+		   &s->metadata_used_blocks, &s->metadata_total_blocks,
+		   &s->block_size, /* AKA, chunk_size */
+		   &s->used_blocks, &s->total_blocks,
+		   &s->read_hits, &s->read_misses,
+		   &s->write_hits, &s->write_misses,
+		   &s->demotions, &s->promotions,
+		   &s->dirty_blocks,
+		   &feature_argc) != 14)
+		goto bad;
+
+	/* Now jump to "features" section */
+	if (!(p = _advance_to_next_word(params, 12)))
+		goto bad;
+
+	/* Read in features */
+	for (i = 0; i < feature_argc; i++) {
+		if (!strncmp(p, "writethrough ", 13))
+			s->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+		else if (!strncmp(p, "writeback ", 10))
+			s->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+		else
+			log_error("Unknown feature in status: %s", params);
+
+		if (!(p = _advance_to_next_word(p, 1)))
+			goto bad;
+	}
+
+	/* Read in core_args. */
+	if (sscanf(p, "%d ", &s->core_argc) != 1)
+		goto bad;
+	if (s->core_argc &&
+	    (!(s->core_argv = dm_pool_zalloc(mem, sizeof(char *) * s->core_argc)) ||
+	     !(p = _advance_to_next_word(p, 1)) ||
+	     !(str = dm_pool_strdup(mem, p)) ||
+	     !(p = _advance_to_next_word(p, s->core_argc)) ||
+	     (dm_split_words(str, s->core_argc, 0, s->core_argv) != s->core_argc)))
+		goto bad;
+
+	/* Read in policy args */
+	pp = p;
+	if (!(p = _advance_to_next_word(p, 1)) ||
+	    !(s->policy_name = dm_pool_zalloc(mem, (p - pp))))
+		goto bad;
+	if (sscanf(pp, "%s %d", s->policy_name, &s->policy_argc) != 2)
+		goto bad;
+	if (s->policy_argc &&
+	    (!(s->policy_argv = dm_pool_zalloc(mem, sizeof(char *) * s->policy_argc)) ||
+	     !(p = _advance_to_next_word(p, 1)) ||
+	     !(str = dm_pool_strdup(mem, p)) ||
+	     (dm_split_words(str, s->policy_argc, 0, s->policy_argv) != s->policy_argc)))
+		goto bad;
+
+	*status = s;
+	return 1;
+
+bad:
+	log_error("Failed to parse cache params: %s", params);
+	dm_pool_free(mem, s);
+	*status = NULL;
+
+	return 0;
+}
+
+int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s)
+{
+	int pos;
+
+	if (!params) {
+		log_error("Failed to parse invalid thin params.");
+		return 0;
+	}
+
+	/* FIXME: add support for held metadata root */
+	if (sscanf(params, FMTu64 " " FMTu64 "/" FMTu64 " " FMTu64 "/" FMTu64 "%n",
+		   &s->transaction_id,
+		   &s->used_metadata_blocks,
+		   &s->total_metadata_blocks,
+		   &s->used_data_blocks,
+		   &s->total_data_blocks, &pos) < 5) {
+		log_error("Failed to parse thin pool params: %s.", params);
+		return 0;
+	}
+
+	/* New status flags */
+	if (strstr(params + pos, "no_discard_passdown"))
+		s->discards = DM_THIN_DISCARDS_NO_PASSDOWN;
+	else if (strstr(params + pos, "ignore_discard"))
+		s->discards = DM_THIN_DISCARDS_IGNORE;
+	else /* default discard_passdown */
+		s->discards = DM_THIN_DISCARDS_PASSDOWN;
+
+	if (strstr(params + pos, "ro "))
+		s->read_only = 1;
+	else if (strstr(params + pos, "fail"))
+		s->fail = 1;
+	else if (strstr(params + pos, "out_of_data_space"))
+		s->out_of_data_space = 1;
+
+	if (strstr(params + pos, "error_if_no_space"))
+		s->error_if_no_space = 1;
+
+	return 1;
+}
+
+int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
+			    struct dm_status_thin_pool **status)
+{
+	struct dm_status_thin_pool *s;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
+		log_error("Failed to allocate thin_pool status structure.");
+		return 0;
+	}
+
+	if (!parse_thin_pool_status(params, s)) {
+		dm_pool_free(mem, s);
+		return_0;
+	}
+
+	*status = s;
+
+	return 1;
+}
+
+int dm_get_status_thin(struct dm_pool *mem, const char *params,
+		       struct dm_status_thin **status)
+{
+	struct dm_status_thin *s;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin)))) {
+		log_error("Failed to allocate thin status structure.");
+		return 0;
+	}
+
+	if (strchr(params, '-')) {
+		s->mapped_sectors = 0;
+		s->highest_mapped_sector = 0;
+	} else if (sscanf(params, FMTu64 " " FMTu64,
+		   &s->mapped_sectors,
+		   &s->highest_mapped_sector) != 2) {
+		dm_pool_free(mem, s);
+		log_error("Failed to parse thin params: %s.", params);
+		return 0;
+	}
+
+	*status = s;
+
+	return 1;
+}


