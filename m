From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 28 Jan 2014 08:16:07 -0600
Subject: [LVM PATCH 1/3] cache: New fns for gathering info on cache devices
In-Reply-To: <1390918569-22041-1-git-send-email-jbrassow@redhat.com>
References: <1390918569-22041-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1390918569-22041-2-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Building on the new DM function that parses DM cache status, we
introduce the following LVM level functions to aquire information
about cache devices:
- lv_cache_block_info: retrieves information on the cache's block/chunk usage
- lv_cache_policy_info: retrieves information on the cache's policy

---
 lib/activate/activate.c          |  168 ++++++++++++++++++++++++++++++++++++++
 lib/activate/activate.h          |    6 ++
 lib/activate/dev_manager.c       |   51 +++++++++++-
 lib/activate/dev_manager.h       |    3 +
 lib/metadata/metadata-exported.h |   11 +++
 5 files changed, 238 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4c8c16d..4599064 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -285,6 +285,18 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
 }
+int lv_cache_block_info(const struct logical_volume *lv,
+			uint32_t *chunk_size, uint64_t *dirty_count,
+			uint64_t *used_count, uint64_t *total_count)
+{
+	return 0;
+}
+int lv_cache_policy_info(const struct logical_volume *lv,
+			 char **policy_name, int *policy_argc,
+			 char ***policy_argv)
+{
+	return 0;
+}
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent)
 {
@@ -969,6 +981,162 @@ out:
 	return r;
 }
 
+int lv_cache_block_info(struct logical_volume *lv,
+			uint32_t *chunk_size, uint64_t *dirty_count,
+			uint64_t *used_count, uint64_t *total_count)
+{
+	struct lv_segment *cache_seg;
+	struct logical_volume *cache_lv;
+	struct dev_manager *dm;
+	struct dm_status_cache *status;
+
+	/* The user is free to choose which args they are interested in */
+	if (chunk_size)
+		*chunk_size = 0;
+	if (dirty_count)
+		*dirty_count = 0;
+	if (used_count)
+		*used_count = 0;
+	if (total_count)
+		*total_count = 0;
+
+	if (lv_is_cache(lv))
+		cache_lv = lv;
+	else if (lv_is_cache_pool(lv)) {
+		if (dm_list_empty(&lv->segs_using_this_lv)) {
+			//FIXME: Ok to return value not sourced from kernel?
+			//       This could be valuable - esp for 'lvs' output
+			log_error(INTERNAL_ERROR "Unable to get block info"
+				  " of unlinked cache_pool, %s", lv->name);
+			//FIXME: ... because we could do this:
+			if (chunk_size)
+				*chunk_size = first_seg(lv)->chunk_size;
+			/* Unlinked cache_pools have 0 dirty & used blocks */
+			if (total_count) {
+				*total_count = lv->size; /* in sectors */
+				*total_count /= first_seg(lv)->chunk_size;
+			}
+
+			return 1;
+		}
+		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+		cache_lv = cache_seg->lv;
+	} else {
+		log_error(INTERNAL_ERROR
+			  "Unable to get block info of non-cache LV, %s",
+			  lv->name);
+		return 0;
+	}
+
+	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
+		return_0;
+
+	log_debug_activation("Checking cache block info for LV %s/%s",
+			     cache_lv->vg->name, cache_lv->name);
+
+	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_cache_status(dm, cache_lv, &status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+
+	if (chunk_size)
+		*chunk_size = status->block_size;
+	if (dirty_count)
+		*dirty_count = status->dirty_blocks;
+	if (used_count)
+		*used_count = status->used_blocks;
+	if (total_count)
+		*total_count = status->total_blocks;
+
+	dev_manager_destroy(dm);
+
+	return 1;
+}
+
+int lv_cache_policy_info(struct logical_volume *lv,
+			 char **policy_name, int *policy_argc,
+			 char ***policy_argv)
+{
+	int i;
+	struct lv_segment *cache_seg;
+	struct logical_volume *cache_lv;
+	struct dev_manager *dm;
+	struct dm_status_cache *status;
+	struct dm_pool *mem = lv->vg->vgmem;  //FIXME: best mempool to use?
+
+	/* The user is free to choose which args they are interested in */
+	if (policy_name)
+		*policy_name = NULL;
+	if (policy_argc)
+		*policy_argc = 0;
+	if (policy_argv)
+		*policy_argv = NULL;
+
+	if (lv_is_cache(lv))
+		cache_lv = lv;
+	else if (lv_is_cache_pool(lv)) {
+		if (dm_list_empty(&lv->segs_using_this_lv)) {
+			//FIXME: Ok to return value not sourced from kernel?
+			log_error(INTERNAL_ERROR "Unable to get policy info"
+				  " of unlinked cache_pool, %s", lv->name);
+			//FIXME: ... because we could do this:
+			if (policy_name)
+				*policy_name = first_seg(lv)->policy_name;
+			if (policy_argc)
+				*policy_argc = first_seg(lv)->policy_argc;
+			if (policy_argv)
+				*policy_argv = first_seg(lv)->policy_argv;
+
+			return 1;
+		}
+		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+		cache_lv = cache_seg->lv;
+	} else {
+		log_error(INTERNAL_ERROR
+			  "Unable to get policy info of non-cache LV, %s",
+			  lv->name);
+		return 0;
+	}
+
+	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
+		return_0;
+
+	log_debug_activation("Checking cache policy for LV %s/%s",
+			     cache_lv->vg->name, cache_lv->name);
+
+	if (!(dm = dev_manager_create(cache_lv->vg->cmd, cache_lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_cache_status(dm, cache_lv, &status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+
+	if (policy_name &&
+	    !(*policy_name = dm_pool_strdup(mem, status->policy_name)))
+		return_0;
+	if (policy_argc)
+		*policy_argc = status->policy_argc;
+	if (policy_argv) {
+		if (!(*policy_argv =
+		      dm_pool_zalloc(mem, sizeof(char *) * *policy_argc)))
+			return_0;
+		for (i = 0; i < *policy_argc; i++)
+			if (!((*policy_argv)[i] =
+			      dm_pool_strdup(mem, status->policy_argv[i])))
+				return_0;
+	}
+
+	dev_manager_destroy(dm);
+
+	return 1;
+}
+
 /*
  * Returns data or metadata percent usage, depends on metadata 0/1.
  * Returns 1 if percent set, else 0 on failure.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index f748a04..3da83ea 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -135,6 +135,12 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
+int lv_cache_block_info(struct logical_volume *lv,
+			uint32_t *chunk_size, uint64_t *dirty_count,
+			uint64_t *used_count, uint64_t *total_count);
+int lv_cache_policy_info(struct logical_volume *lv,
+			 char **policy_name, int *policy_argc,
+			 char ***policy_argv);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7b0b6e2..b48ca99 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1160,6 +1160,55 @@ out:
 	return r;
 }
 
+int dev_manager_cache_status(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     struct dm_status_cache **status)
+{
+	int r = 0;
+	const char *dlid;
+	struct dm_task *dmt;
+	struct dm_info info;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	const char *layer = lv_layer(lv);
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+		return_0;
+
+	log_debug_activation("Getting cache device status for %s.", lv->name);
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count.");
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
+
+	if (!type || strcmp(type, "cache")) {
+		log_debug("Expected cache segment type but got %s instead",
+			  type ? type : "NULL");
+		goto out;
+	}
+
+	if (!dm_get_status_cache(dm->mem, params, status))
+		goto_out;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+//FIXME: Can we get rid of this crap below?
 #if 0
 	log_very_verbose("%s %s", sus ? "Suspending" : "Resuming", name);
 
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 032766e..446b349 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -60,6 +60,9 @@ int dev_manager_raid_status(struct dev_manager *dm,
 int dev_manager_raid_message(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     const char *msg);
+int dev_manager_cache_status(struct dev_manager *dm,
+			     const struct logical_volume *lv,
+			     struct dm_status_cache **status);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index bdf5c9d..95feb1f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -110,6 +110,11 @@
 									this flag dropped during single
 									LVM command execution. */
 
+#define CACHE_POOL		UINT64_C(0x0000200000000000)    /* LV */
+#define CACHE_POOL_DATA		UINT64_C(0x0000400000000000)    /* LV */
+#define CACHE_POOL_METADATA	UINT64_C(0x0000800000000000)    /* LV */
+#define CACHE			UINT64_C(0x0001000000000000)    /* LV */
+
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
 #define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
@@ -169,6 +174,12 @@
 #define lv_is_raid(lv)		(((lv)->status & (RAID)) ? 1 : 0)
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
+#define lv_is_cache(lv)		(((lv)->status & (CACHE)) ? 1 : 0)
+#define lv_is_cache_pool(lv)	(((lv)->status & (CACHE_POOL)) ? 1 : 0)
+#define lv_is_cache_pool_data(lv)	(((lv)->status & (CACHE_POOL_DATA)) ? 1 : 0)
+#define lv_is_cache_pool_metadata(lv)	(((lv)->status & (CACHE_POOL_METADATA)) ? 1 : 0)
+#define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
+
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 
-- 
1.7.7.6


