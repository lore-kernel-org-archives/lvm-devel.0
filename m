From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:18 +0000 (UTC)
Subject: master - cache: add validate_lv_cache_chunk_size
Message-ID: <20160505220118.BAC7060C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae805eea50b1033115a18b8a0c9931c2c917b8b2
Commit:        ae805eea50b1033115a18b8a0c9931c2c917b8b2
Parent:        00dfca034c7478b88874d43bc36633e3176d1866
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 3 21:50:04 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:30:49 2016 +0200

cache: add validate_lv_cache_chunk_size

---
 lib/metadata/cache_manip.c       |   19 +++++++++++++++++++
 lib/metadata/metadata-exported.h |    1 +
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a514828..5ecfbe2 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -184,6 +184,25 @@ int update_cache_pool_params(const struct segment_type *segtype,
 }
 
 /*
+ * Validate if existing cache-pool can be used with given chunk size
+ * i.e. cache-pool metadata size fits all info.
+ */
+int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size)
+{
+	uint64_t min_size = _cache_min_metadata_size(pool_lv->size, chunk_size);
+
+	if (min_size > first_seg(pool_lv)->metadata_lv->size) {
+		log_error("Cannot use chunk size %s with cache pool %s. "
+			  "Minimal required size for metadata is %s.",
+			  display_size(pool_lv->vg->cmd, chunk_size),
+			  display_lvname(pool_lv),
+			  display_size(pool_lv->vg->cmd, min_size));
+		return 0;
+	}
+
+	return 1;
+}
+/*
  * Validate arguments for converting origin into cached volume with given cache pool.
  *
  * Always validates origin_lv, and when it is known also cache pool_lv
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8c4dfc3..54c2668 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1222,6 +1222,7 @@ int update_cache_pool_params(const struct segment_type *segtype,
 			     int passed_args, uint32_t pool_data_extents,
 			     uint32_t *pool_metadata_extents,
 			     int *chunk_size_calc_method, uint32_t *chunk_size);
+int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size);
 int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
 int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
 struct logical_volume *lv_cache_create(struct logical_volume *pool,


