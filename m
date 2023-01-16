From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:14 +0000 (GMT)
Subject: main - vdo: read live vdo size configuration
Message-ID: <20230116113914.199633858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bed2cafe83096cf01cfff5cd2cd64ecb32b7d78
Commit:        1bed2cafe83096cf01cfff5cd2cd64ecb32b7d78
Parent:        773b88e028ab2965a8c185f5f2147334f8f2bbfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 15 21:24:28 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

vdo: read live vdo size configuration

Introduce struct vdo_pool_size_config usable to calculate necessary
memory size for active VDO volume.

Function lv_vdo_pool_size_config() is able to read out this
configuration out of runtime DM table line.
---
 lib/activate/activate.c          | 31 +++++++++++++++++++
 lib/activate/activate.h          |  2 ++
 lib/activate/dev_manager.c       | 65 ++++++++++++++++++++++++++++++++++++++++
 lib/activate/dev_manager.h       |  3 ++
 lib/metadata/metadata-exported.h |  6 ++++
 5 files changed, 107 insertions(+)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2f3c231cc..d6c1eca2f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -322,6 +322,11 @@ int lv_vdo_pool_percent(const struct logical_volume *lv, dm_percent_t *percent)
 {
 	return 0;
 }
+int lv_vdo_pool_size_config(const struct logical_volume *lv,
+			    struct vdo_pool_size_config *cfg)
+{
+	return 0;
+}
 int lvs_in_vg_activated(const struct volume_group *vg)
 {
 	return 0;
@@ -1363,6 +1368,32 @@ int lv_vdo_pool_percent(const struct logical_volume *lv, dm_percent_t *percent)
 	return 1;
 }
 
+/*
+ * lv_vdo_pool_size_config obtains size configuration from active VDO table line
+ *
+ * If the 'params' string has been already retrieved, use it.
+ * If the mempool already exists, use it.
+ *
+ */
+int lv_vdo_pool_size_config(const struct logical_volume *lv,
+			    struct vdo_pool_size_config *cfg)
+{
+	struct dev_manager *dm;
+	int r;
+
+	if (!lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
+		return 1;  /* Inactive VDO pool -> no runtime config */
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, !lv_is_pvmove(lv))))
+		return_0;
+
+	r = dev_manager_vdo_pool_size_config(dm, lv, cfg);
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index a276b48a7..e550ec5b0 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -204,6 +204,8 @@ int lv_thin_pool_status(const struct logical_volume *lv, int flush,
 int lv_vdo_pool_status(const struct logical_volume *lv, int flush,
 		       struct lv_status_vdo **status);
 int lv_vdo_pool_percent(const struct logical_volume *lv, dm_percent_t *percent);
+int lv_vdo_pool_size_config(const struct logical_volume *lv,
+			    struct vdo_pool_size_config *cfg);
 
 /*
  * Return number of LVs in the VG that are active.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cafb94ad5..689305f7b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1957,6 +1957,71 @@ out:
 	return r;
 }
 
+int dev_manager_vdo_pool_size_config(struct dev_manager *dm,
+				     const struct logical_volume *lv,
+				     struct vdo_pool_size_config *cfg)
+{
+	const char *dlid;
+	struct dm_info info;
+	uint64_t start, length;
+	struct dm_task *dmt = NULL;
+	char *type = NULL;
+	char *params = NULL;
+	int r = 0;
+	unsigned version = 0;
+
+	memset(cfg, 0, sizeof(*cfg));
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
+		return_0;
+
+	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, &info, NULL, dlid, 0, 0, 0, 0, 0, 0)))
+		return_0;
+
+	if (!info.exists)
+		goto inactive; /* VDO device is not active, should not happen here... */
+
+	log_debug_activation("Checking VDO pool table line for LV %s.",
+			     display_lvname(lv));
+
+	if (dm_get_next_target(dmt, NULL, &start, &length, &type, &params)) {
+		log_error("More then one table line found for %s.",
+			  display_lvname(lv));
+		goto out;
+	}
+
+	if (!type || strcmp(type, TARGET_NAME_VDO)) {
+		log_error("Expected %s segment type but got %s instead.",
+			  TARGET_NAME_VDO, type ? type : "NULL");
+		goto out;
+	}
+
+	if (sscanf(params, "V%u %*s " FMTu64 " %*u " FMTu32,
+		   &version, &cfg->physical_size, &cfg->block_map_cache_size_mb) != 3) {
+		log_error("Failed to parse VDO parameters %s for LV %s.",
+			  params, display_lvname(lv));
+		goto out;
+	}
+
+	switch (version) {
+	case 2: break;
+	case 4: break;
+	default: log_warn("WARNING: Unknown VDO table line version %u.", version);
+	}
+
+	cfg->virtual_size = length;
+	cfg->physical_size *= 8; // From 4K unit to 512B
+	cfg->block_map_cache_size_mb /= 256; // From 4K unit to MiB
+	cfg->index_memory_size_mb = first_seg(lv)->vdo_params.index_memory_size_mb; // Preserved
+
+inactive:
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 
 /*************************/
 /*  NEW CODE STARTS HERE */
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index b494e3eaf..59f45b6f1 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -83,6 +83,9 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 int dev_manager_vdo_pool_status(struct dev_manager *dm,
 				const struct logical_volume *lv, int flush,
 				struct lv_status_vdo **status, int *exists);
+int dev_manager_vdo_pool_size_config(struct dev_manager *dm,
+				     const struct logical_volume *lv,
+				     struct vdo_pool_size_config *cfg);
 int dev_manager_suspend(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, const struct logical_volume *lv,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c7eaa5233..7c481905a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1376,6 +1376,12 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 			   struct dm_vdo_target_params *vtp,
 			   uint64_t *vdo_pool_header_size,
 			   struct profile *profile);
+struct vdo_pool_size_config {
+	uint64_t physical_size;
+	uint64_t virtual_size;
+	uint32_t block_map_cache_size_mb;
+	uint32_t index_memory_size_mb;
+};
 int check_vdo_constrains(struct cmd_context *cmd, uint64_t physical_size,
 			 uint64_t virtual_size, struct dm_vdo_target_params *vtp);
 /* --  metadata/vdo_manip.c */

