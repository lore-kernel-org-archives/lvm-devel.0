From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:20 +0000 (UTC)
Subject: master - cache: add cache_set_params function
Message-ID: <20160505220120.D708860C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=def65507e6beab7d1830622492772cc89abe4ccb
Commit:        def65507e6beab7d1830622492772cc89abe4ccb
Parent:        ae805eea50b1033115a18b8a0c9931c2c917b8b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 21:30:15 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:30:49 2016 +0200

cache: add cache_set_params function

Wrapping function to handle setup of various cache related params.
Reusable with lvcreate & lvconvert.
---
 lib/metadata/cache_manip.c       |   34 ++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    5 +++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5ecfbe2..27a716a 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -632,6 +632,40 @@ out:
 }
 
 /*
+ * Universal 'wrapper' function  do-it-all
+ * to update all commonly specified cache parameters
+ */
+int cache_set_params(struct lv_segment *seg,
+		     const char *cache_mode,
+		     const char *policy_name,
+		     const struct dm_config_tree *policy_settings,
+		     uint32_t chunk_size)
+{
+	struct lv_segment *pool_seg;
+
+	if (!cache_set_mode(seg, cache_mode))
+		return_0;
+
+	if (!cache_set_policy(seg, policy_name, policy_settings))
+		return_0;
+
+	pool_seg = seg_is_cache(seg) ? first_seg(seg->pool_lv) : seg;
+
+	if (chunk_size) {
+		if (!validate_lv_cache_chunk_size(pool_seg->lv, chunk_size))
+			return_0;
+		pool_seg->chunk_size = chunk_size;
+	} else {
+		/* TODO: some calc_policy solution for cache ? */
+		if (!recalculate_pool_chunk_size_with_dev_hints(pool_seg->lv, 0,
+								THIN_CHUNK_SIZE_CALC_METHOD_GENERIC))
+			return_0;
+	}
+
+	return 1;
+}
+
+/*
  * Wipe cache pool metadata area before use.
  *
  * Activates metadata volume as 'cache-pool' so regular wiping
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 54c2668..b3f450a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1216,6 +1216,11 @@ int cache_mode_is_set(const struct lv_segment *seg);
 int cache_set_mode(struct lv_segment *cache_seg, const char *str);
 int cache_set_policy(struct lv_segment *cache_seg, const char *name,
 		     const struct dm_config_tree *settings);
+int cache_set_params(struct lv_segment *seg,
+		     const char *cache_mode,
+		     const char *policy_name,
+		     const struct dm_config_tree *policy_settings,
+		     uint32_t chunk_size);
 void cache_check_for_warns(const struct lv_segment *seg);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,


