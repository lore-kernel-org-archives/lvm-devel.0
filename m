From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:07 -0500
Subject: master - cache: LV supports cache segs with metadata format
Message-ID: <201703101837.v2AIb7bk019819@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=518b814cdb806f70f99aaa168fca45495b18a4cf
Commit:        518b814cdb806f70f99aaa168fca45495b18a4cf
Parent:        4a394f410d571d8c8ef7c9f87df781df0f7988bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 1 12:26:56 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: LV supports cache segs with metadata format

Cache pool read/writes metadata_format within its segment type..

For CachePoolLV unselected metadata format is NOT stored in metadata.

For CacheLV when metadata format is not present/selected in lvm2 metadata,
it's automatically assumed to be the version 1 (backward compatible).

To ensure older lvm2 will not 'miss-read' metadata with new version 2,
such LV is marked with METADATA_FORMAT status flag (segment is
specifying metadata format). So when cache uses metadata format 2,
it will become inaccesible on older system without such support.
(kernel dm cache < 1.10,  lvm2 < 2.02.169).
---
 WHATS_NEW                        |    1 +
 lib/cache_segtype/cache.c        |   35 +++++++++++++++++++++++++++++++++++
 lib/format_text/flags.c          |    1 +
 lib/metadata/metadata-exported.h |    5 ++++-
 4 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d1efed0..4a5b0f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support cache segment with configurable metadata format.
   Add allocation/cache_metadata_format profilable setttings.
   Use function cache_set_params() for both lvcreate and lvconvert.
   Skip rounding on cache chunk size boudary when create cache LV.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index c378eda..985af68 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -52,6 +52,12 @@ static void _fix_missing_defaults(struct lv_segment *cpool_seg)
 			    cpool_seg->policy_name);
 	}
 
+	if (cpool_seg->cache_metadata_format == CACHE_METADATA_FORMAT_UNSELECTED) {
+		cpool_seg->cache_metadata_format = CACHE_METADATA_FORMAT_1;
+		log_verbose("Cache pool %s uses implicit metadata format %u.",
+			    display_lvname(cpool_seg->lv), cpool_seg->cache_metadata_format);
+	}
+
 	if (cpool_seg->cache_mode == CACHE_MODE_UNSELECTED) {
 		cpool_seg->cache_mode = CACHE_MODE_WHEN_MISSING;
 		log_verbose("Cache pool %s is missing cache mode, using %s.",
@@ -107,6 +113,16 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Failed to duplicate policy in");
 	}
 
+	if (dm_config_has_node(sn, "metadata_format")) {
+		if (!dm_config_get_uint32(sn, "metadata_format", &seg->cache_metadata_format) ||
+		    ((seg->cache_metadata_format != CACHE_METADATA_FORMAT_1) &&
+		     (seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)))
+			return SEG_LOG_ERROR("Unknown cache metadata format %u number in",
+					     seg->cache_metadata_format);
+		if (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2)
+			seg->lv->status |= LV_METADATA_FORMAT;
+	}
+
 	/*
 	 * Read in policy args:
 	 *   policy_settings {
@@ -164,6 +180,25 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
 
+	switch (seg->cache_metadata_format) {
+	case CACHE_METADATA_FORMAT_UNSELECTED:
+		/* Unselected format is not printed */
+		break;
+	case CACHE_METADATA_FORMAT_1:
+		/* If format 1 was already specified with cache pool, store it,
+		 * otherwise format gets stored when LV is cached.
+		 * NB: format 1 could be lost anytime, it's a default format.
+		 * Older lvm2 tool can easily drop it.
+		 */
+	case CACHE_METADATA_FORMAT_2: /* more in future ? */
+		outf(f, "metadata_format = " FMTu32, seg->cache_metadata_format);
+		break;
+	default:
+		log_error(INTERNAL_ERROR "LV %s is using unknown cache metadada format %u.",
+			  display_lvname(seg->lv), seg->cache_metadata_format);
+		return 0;
+	}
+
 	/*
 	 * Cache pool used by a cache LV holds data. Not ideal,
 	 * but not worth to break backward compatibility, by shifting
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 716e632..a9f81f5 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -67,6 +67,7 @@ static const struct flag _lv_flags[] = {
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
+	{LV_METADATA_FORMAT, "METADATA_FORMAT", STATUS_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5c84bdf..c11899d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -141,7 +141,8 @@
 #define LV_RESHAPE_DELTA_DISKS_MINUS		UINT64_C(0x0200000000000000)    /* LV reshape flag delta disks minus image(s) */
 
 #define LV_REMOVE_AFTER_RESHAPE	UINT64_C(0x0400000000000000)	/* LV needs to be removed after a shrinking reshape */
-/* Next unused flag:		UINT64_C(0x0800000000000000)    */
+#define LV_METADATA_FORMAT	UINT64_C(0x0800000000000000)    /* LV has segments with metadata format */
+/* Next unused flag:		UINT64_C(0x1000000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -503,6 +504,7 @@ struct lv_segment {
 	struct logical_volume *pool_lv;		/* For thin, cache */
 	uint32_t device_id;			/* For thin, 24bit */
 
+	cache_metadata_format_t cache_metadata_format;/* For cache_pool */
 	cache_mode_t cache_mode;		/* For cache_pool */
 	const char *policy_name;		/* For cache_pool */
 	struct dm_config_node *policy_settings;	/* For cache_pool */
@@ -964,6 +966,7 @@ struct lvcreate_params {
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */
 
+	cache_metadata_format_t cache_metadata_format; /* cache */
 	cache_mode_t cache_mode; /* cache */
 	const char *policy_name; /* cache */
 	struct dm_config_tree *policy_settings; /* cache */


