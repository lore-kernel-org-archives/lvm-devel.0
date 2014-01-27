From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 27 Jan 2014 22:21:45 +0000 (UTC)
Subject: master - cache: Add DM interface for retrieving a cache's status
Message-ID: <20140127222145.BC4A161171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df181cc51e32fb54dac6652574e303e93b51b8bd
Commit:        df181cc51e32fb54dac6652574e303e93b51b8bd
Parent:        1ff7e214e0cf0e7ef0280b71ab128e029172a1d9
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jan 27 05:30:10 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jan 27 05:30:42 2014 -0600

cache:  Add DM interface for retrieving a cache's status

This patch defines a structure for holding all of the device-mapper
cache target's status information.  The associated function provides
an easy way for higher levels (LVM) to consume the information.

This patch finishes the device-mapper interface for the cache and
cachepool segment types (i.e. the cache target).
---
 libdm/libdevmapper.h  |   35 ++++++++++++-
 libdm/libdm-deptree.c |  137 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 171 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ae9a91a..670c5e09 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -294,6 +294,39 @@ struct dm_status_raid {
 int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status);
 
+struct dm_status_cache {
+	uint64_t version;  /* zero for now */
+
+	uint32_t metadata_block_size;   /* in 512B sectors */
+	uint32_t block_size;            /* AKA 'chunk_size' */
+
+	uint64_t metadata_used_blocks;
+	uint64_t metadata_total_blocks;
+
+	uint64_t used_blocks;
+	uint64_t dirty_blocks;
+	uint64_t total_blocks;
+
+	uint64_t read_hits;
+	uint64_t read_misses;
+	uint64_t write_hits;
+	uint64_t write_misses;
+
+	uint64_t demotions;
+	uint64_t promotions;
+
+	uint32_t feature_flags;
+
+	int core_argc;
+	char **core_argv;
+
+	char *policy_name;
+	int   policy_argc;
+	char **policy_argv;
+};
+
+int dm_get_status_cache(struct dm_pool *mem, const char *params,
+			struct dm_status_cache **status);
 
 /*
  * Snapshot target's format:
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d3f6640..32d53be 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3249,6 +3249,143 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	return 1;
 }
 
+static const char *advance_to_next_word(const char *str, int count)
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
+	if (!(p = advance_to_next_word(params, 12)))
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
+		if (!(p = advance_to_next_word(p, 1)))
+			goto bad;
+	}
+
+	/* Read in core_args. */
+	if (sscanf(p, "%d ", &s->core_argc) != 1)
+		goto bad;
+	if (s->core_argc &&
+	    (!(s->core_argv = dm_pool_zalloc(mem, sizeof(char *) * s->core_argc)) ||
+	     !(p = advance_to_next_word(p, 1)) ||
+	     !(str = dm_pool_strdup(mem, p)) ||
+	     !(p = advance_to_next_word(p, s->core_argc)) ||
+	     (dm_split_words(str, s->core_argc, 0, s->core_argv) != s->core_argc)))
+		goto bad;
+
+	/* Read in policy args */
+	pp = p;
+	if (!(p = advance_to_next_word(p, 1)) ||
+	    !(s->policy_name = dm_pool_zalloc(mem, (p - pp))))
+		goto bad;
+	if (sscanf(pp, "%s %d", s->policy_name, &s->policy_argc) != 2)
+		goto bad;
+	if (s->policy_argc &&
+	    (!(s->policy_argv = dm_pool_zalloc(mem, sizeof(char *) * s->policy_argc)) ||
+	     !(p = advance_to_next_word(p, 1)) ||
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
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,


