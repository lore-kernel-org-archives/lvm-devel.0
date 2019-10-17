From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:04:47 -0400
Subject: master - cachevol: use CVOL UUID for cdata and cmeta layered devices
Message-ID: <201910171104.x9HB4lOA023568@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a08d6d1d4945024be5e686de0df02fc66ad8d8d
Commit:        2a08d6d1d4945024be5e686de0df02fc66ad8d8d
Parent:        55bf692bff777e3beefed5b89a28c1fb1ebe1d32
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 16:05:51 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:49 2019 +0200

cachevol: use CVOL UUID for cdata and cmeta layered devices

Since code is using -cdata and -cmeta UUID suffixes, it does not need
any new 'extra' ID to be generated and stored in metadata.

Since introduce of new 'segtype' cache+CACHE_USES_CACHEVOL we can
safely assume 'new' cache with cachevol will now be created
without extra metadata_id and data_id in metadata.

For backward compatibility, code still reads them in case older
version of metadata have them - so it still should be able
to activate such volumes.

Bonus is lowered size of lv structure used to store info about LV
(noticable with big volume groups).
---
 WHATS_NEW                        |    1 +
 lib/activate/dev_manager.c       |   10 ++++---
 lib/cache_segtype/cache.c        |   48 +++++++++++++++++++++++--------------
 lib/metadata/cache_manip.c       |   14 +++++-----
 lib/metadata/metadata-exported.h |    4 +-
 5 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e4106c1..d6e4c9a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  No longer store extra UUID for cmeta and cdata cachevol layer.
   Enhance activation of cache devices with cachevols.
   Add _cvol in list of protected suffixes and start use it with DM UUID.
   Rename LV converted to cachevol to use _cvol suffix.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 38a397b..9e4dba4 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2374,9 +2374,11 @@ static int _add_cvol_subdev_to_dtree(struct dev_manager *dm, struct dm_tree *dtr
 	char *name ,*dlid;
 	union lvid lvid = { 0 };
 
-	/* TODO: Convert to use just  CVOL UUID with suffix */
 	memcpy(&lvid.id[0], &lv->vg->id, sizeof(struct id));
-	memcpy(&lvid.id[1], (meta_or_data) ? &lvseg->metadata_id : &lvseg->data_id, sizeof(struct id));
+	/* When ID is provided in form of metadata_id or data_id, otherwise use CVOL ID */
+	memcpy(&lvid.id[1],
+	       (meta_or_data && lvseg->metadata_id) ? lvseg->metadata_id :
+	       (lvseg->data_id) ? lvseg->data_id : &pool_lv->lvid.id[1], sizeof(struct id));
 
 	if (!(dlid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&lvid.s, layer)))
 		return_0;
@@ -3159,9 +3161,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		memset(&lvid_meta, 0, sizeof(lvid_meta));
 		memset(&lvid_data, 0, sizeof(lvid_meta));
 		memcpy(&lvid_meta.id[0], &vg->id, sizeof(struct id));
-		memcpy(&lvid_meta.id[1], &lvseg->metadata_id, sizeof(struct id));
+		memcpy(&lvid_meta.id[1], lvseg->metadata_id ? : &pool_lv->lvid.id[1], sizeof(struct id));
 		memcpy(&lvid_data.id[0], &vg->id, sizeof(struct id));
-		memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
+		memcpy(&lvid_data.id[1], lvseg->data_id ? : &pool_lv->lvid.id[1], sizeof(struct id));
 
 		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, "cmeta")))
 			return_0;
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 798b157..4699070 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -528,17 +528,25 @@ static int _cache_text_import(struct lv_segment *seg,
 		if (!dm_config_get_uint64(sn, "data_len", &seg->data_len))
 			return SEG_LOG_ERROR("Couldn't read data_len in");
 
-		if (!dm_config_get_str(sn, "metadata_id", &uuid))
-			return SEG_LOG_ERROR("Couldn't read metadata_id in");
-
-		if (!id_read_format(&seg->metadata_id, uuid))
-			return SEG_LOG_ERROR("Couldn't format metadata_id in");
-
-		if (!dm_config_get_str(sn, "data_id", &uuid))
-			return SEG_LOG_ERROR("Couldn't read data_id in");
+		/* Will use CVOL ID, when metadata_id is not provided */
+		if (dm_config_has_node(sn, "metadata_id")) {
+			if (!(seg->metadata_id = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*seg->metadata_id))))
+				return SEG_LOG_ERROR("Couldn't allocate metadata_id in");
+			if (!dm_config_get_str(sn, "metadata_id", &uuid))
+				return SEG_LOG_ERROR("Couldn't read metadata_id in");
+			if (!id_read_format(seg->metadata_id, uuid))
+				return SEG_LOG_ERROR("Couldn't format metadata_id in");
+		}
 
-		if (!id_read_format(&seg->data_id, uuid))
-			return SEG_LOG_ERROR("Couldn't format data_id in");
+		/* Will use CVOL ID, when data_id is not provided */
+		if (dm_config_has_node(sn, "data_id")) {
+			if (!(seg->data_id = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*seg->data_id))))
+				return SEG_LOG_ERROR("Couldn't allocate data_id in");
+			if (!dm_config_get_str(sn, "data_id", &uuid))
+				return SEG_LOG_ERROR("Couldn't read data_id in");
+			if (!id_read_format(seg->data_id, uuid))
+				return SEG_LOG_ERROR("Couldn't format data_id in");
+		}
 	} else {
 		/* Do not call this when LV is cache_vol. */
 		/* load order is unknown, could be cache origin or pool LV, so check for both */
@@ -581,13 +589,17 @@ static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
 		outf(f, "data_start = " FMTu64, seg->data_start);
 		outf(f, "data_len = " FMTu64, seg->data_len);
 
-		if (!id_write_format(&seg->metadata_id, buffer, sizeof(buffer)))
-			return_0;
-		outf(f, "metadata_id = \"%s\"", buffer);
+		if (seg->metadata_id) {
+			if (!id_write_format(seg->metadata_id, buffer, sizeof(buffer)))
+				return_0;
+			outf(f, "metadata_id = \"%s\"", buffer);
+		}
 
-		if (!id_write_format(&seg->data_id, buffer, sizeof(buffer)))
-			return_0;
-		outf(f, "data_id = \"%s\"", buffer);
+		if (seg->data_id) {
+			if (!id_write_format(seg->data_id, buffer, sizeof(buffer)))
+				return_0;
+			outf(f, "data_id = \"%s\"", buffer);
+		}
 	}
 
 	return 1;
@@ -695,9 +707,9 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		memset(&metadata_lvid, 0, sizeof(metadata_lvid));
 		memset(&data_lvid, 0, sizeof(data_lvid));
 		memcpy(&metadata_lvid.id[0], &seg->lv->vg->id, sizeof(struct id));
-		memcpy(&metadata_lvid.id[1], &seg->metadata_id, sizeof(struct id));
+		memcpy(&metadata_lvid.id[1], (seg->metadata_id) ? : &seg->pool_lv->lvid.id[1], sizeof(struct id));
 		memcpy(&data_lvid.id[0], &seg->lv->vg->id, sizeof(struct id));
-		memcpy(&data_lvid.id[1], &seg->data_id, sizeof(struct id));
+		memcpy(&data_lvid.id[1], (seg->data_id) ? : &seg->pool_lv->lvid.id[1], sizeof(struct id));
 
 		if (!(metadata_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&metadata_lvid.s, "cmeta")))
 			return_0;
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 53600d9..3b51ea0 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -578,7 +578,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct logical_volume *corigin_lv;
 	struct logical_volume *cache_pool_lv;
-	const struct id *data_id, *metadata_id;
+	struct id *data_id, *metadata_id;
 	uint64_t data_len, metadata_len;
 	cache_mode_t cache_mode;
 	int is_clear;
@@ -668,9 +668,9 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 	/* Preserve currently imortant data from original cache segment.
 	 * TODO: can it be done without this ? */
-	data_id = &cache_seg->data_id;
+	data_id = cache_seg->data_id;
 	data_len = cache_seg->data_len;
-	metadata_id = &cache_seg->metadata_id;
+	metadata_id = cache_seg->metadata_id;
 	metadata_len = cache_seg->metadata_len;
 
 	/* Replace 'error' with 'cache' segtype */
@@ -691,8 +691,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	/* Restore preserved data into a new cache segment that is going to be removed. */
 	if ((cache_seg->data_len = data_len)) {
 		cache_seg->metadata_len = metadata_len;
-		memcpy(&cache_seg->data_id, data_id, sizeof(struct id));
-		memcpy(&cache_seg->metadata_id, metadata_id, sizeof(struct id));
+		cache_seg->data_id = data_id;
+		cache_seg->metadata_id = metadata_id;
 		cache_pool_lv->status |= LV_CACHE_VOL;
 		/* Unused settings set only for passing metadata validation. */
 		cache_seg->cache_mode = CACHE_MODE_WRITETHROUGH;
@@ -1215,8 +1215,8 @@ int cache_vol_set_params(struct cmd_context *cmd,
 	cache_seg->cache_metadata_format = format;
 	cache_seg->policy_name = policy_name;
 	cache_seg->policy_settings = policy_settings;
-	id_create(&cache_seg->metadata_id);
-	id_create(&cache_seg->data_id);
+	/* Since we add -cdata  and -cmeta to UUID we use CacheVol LV UUID */
+	cache_seg->data_id = cache_seg->metadata_id = NULL;
 
 	return 1;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 66d8579..f340093 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -506,8 +506,8 @@ struct lv_segment {
 	uint64_t metadata_len;			/* For cache */
 	uint64_t data_start;			/* For cache */
 	uint64_t data_len;			/* For cache */
-	struct id metadata_id;			/* For cache */
-	struct id data_id;			/* For cache */
+	struct id *metadata_id;			/* For cache, when NULL uses CVOL id */
+	struct id *data_id;			/* For cache, when NULL uses CVOL id */
 
 	cache_metadata_format_t cache_metadata_format;/* For cache_pool */
 	cache_mode_t cache_mode;		/* For cache_pool */


