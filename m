From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Thu, 31 Jan 2013 19:55:51 +0530
Subject: [PATCH V2 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <1359642352-9688-1-git-send-email-mohan@in.ibm.com>
References: <1359642352-9688-1-git-send-email-mohan@in.ibm.com>
Message-ID: <1359642352-9688-2-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Add thin and thin pool lv creation support to lvm library

Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
---
 lib/metadata/lv_manip.c          |   2 +-
 lib/metadata/metadata-exported.h |   1 +
 liblvm/lvm2app.h                 |  53 +++++++++++++++++++
 liblvm/lvm_lv.c                  | 107 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 162 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c1437eb..4dd5ebf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4518,7 +4518,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->discards = lp->discards;
 		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
-		first_seg(lv)->low_water_mark = 0;
+		first_seg(lv)->low_water_mark = lp->low_water_mark;
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ffec129..40519f5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -617,6 +617,7 @@ struct lvcreate_params {
 	uint64_t voriginsize; /* snapshot */
 	uint32_t poolmetadataextents; /* thin pool */
 	uint64_t poolmetadatasize; /* thin pool */
+	uint64_t low_water_mark;  /* thin_pool */
 	struct dm_list *pvh; /* all */
 
 	uint32_t permission; /* all */
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 93a78c3..1b621a8 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1400,6 +1400,59 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
  */
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
 
+
+/**
+ * Create a thinpool in a given VG
+ *
+ * \param   vg
+ * Volume Group handle.
+ *
+ * \param   pool_name
+ * Name of the pool.
+ *
+ * \param   size
+ * size of the pool
+ *
+ * \param   chunk_size
+ * data block size of the pool
+ * DM_THIN_MIN_DATA_BLOCK_SIZE < chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE
+ *
+ * \param  low_water_mark_blocks
+ * When number of free blocks in the pool reaches below than this thresold a dm
+ * event is sent.
+ *
+ * \return
+ * Valid lv pointer on success, else NULL on error.
+ *
+ */
+lv_t lvm_lv_thinpool(const vg_t vg, const char *pool_name, uint64_t size,
+		     uint32_t chunk_size, uint64_t low_water_mark_blocks);
+
+/**
+ * Create a thin LV in a given VG & thin pool
+ *
+ * \param   vg
+ * Volume Group handle.
+ *
+ * \param   pool_name
+ * Name of the pool.
+ *
+ * \param lvname
+ * Name of the LV to create
+ *
+ * \param   size
+ * Size of logical volume
+ *
+ * \return
+ * Valid lv pointer on success, else NULL on error.
+ *
+ */
+
+lv_t lvm_lv_thin(const vg_t vg, const char *pool_name, const char *lvname,
+		uint64_t size);
+
+
+
 /************************** physical volume handling ************************/
 
 /**
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 91948a6..6091b3d 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -350,3 +350,110 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
 		return NULL;
 	return (lv_t) lvl->lv;
 }
+
+/* Set defaults for thin pool specific LV parameters */
+static void _lv_set_pool_params(struct lvcreate_params *lp,
+				vg_t vg, const char *pool,
+				   uint64_t extents)
+{
+	_lv_set_default_params(lp, vg, NULL, extents);
+
+	lp->pool = pool;
+
+	lp->create_thin_pool = 1;
+	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
+	lp->stripes = 1;
+	lp->poolmetadatasize = extents * vg->extent_size / lp->chunk_size *
+		(SECTOR_SIZE / UINT64_C(64));
+	lp->poolmetadataextents = extents_from_size(vg->cmd, lp->poolmetadatasize,
+						   vg->extent_size);
+}
+
+lv_t lvm_lv_thinpool(const vg_t vg, const char *pool, uint64_t size,
+		     uint32_t chunk_size, uint64_t low_water_mark_blocks)
+{
+	struct lvcreate_params lp = { 0 };
+	uint64_t extents = 0;
+	struct lv_list *lvl = NULL;
+
+	if (vg_read_error(vg))
+		return NULL;
+	if (!vg_check_write_mode(vg))
+		return NULL;
+
+	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
+					  vg->extent_size))) {
+		log_error("Unable to create LV thin pool without size.");
+		return NULL;
+	}
+
+	if (chunk_size)
+		lp.chunk_size = chunk_size;
+	else
+		lp.chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
+
+	if (lp.chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
+	    lp.chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
+		log_error("Invalid chunk_size");
+		return NULL;
+	}
+
+	_lv_set_pool_params(&lp, vg, pool, extents);
+
+	lp.low_water_mark = low_water_mark_blocks;
+	if (!lp.segtype)
+		return_NULL;
+	if (!lv_create_single(vg, &lp))
+		return_NULL;
+	if (!(lvl = find_lv_in_vg(vg, pool)))
+		return NULL;
+	return (lv_t) lvl->lv;
+}
+
+/* Set defaults for thin LV specific parameters */
+static void _lv_set_thin_params(struct lvcreate_params *lp,
+				vg_t vg, const char *pool,
+				const char *lvname,
+				uint64_t extents)
+{
+	_lv_set_default_params(lp, vg, lvname, extents);
+
+	lp->thin = 1;
+	lp->pool = pool;
+	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
+
+	lp->voriginsize = extents * vg->extent_size;
+	lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
+						   vg->extent_size);
+
+	lp->stripes = 1;
+}
+
+lv_t lvm_lv_thin(const vg_t vg, const char *pool,
+		 const char *lvname, uint64_t size)
+{
+	struct lvcreate_params lp = { 0 };
+	uint64_t extents = 0;
+	struct lv_list *lvl = NULL;
+
+	if (vg_read_error(vg))
+		return NULL;
+	if (!vg_check_write_mode(vg))
+		return NULL;
+
+	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
+					  vg->extent_size))) {
+		log_error("Unable to create thin LV without size.");
+		return NULL;
+	}
+
+	_lv_set_thin_params(&lp, vg, pool, lvname, extents);
+
+	if (!lp.segtype)
+		return_NULL;
+	if (!lv_create_single(vg, &lp))
+		return_NULL;
+	if (!(lvl = find_lv_in_vg(vg, pool)))
+		return NULL;
+	return (lv_t) lvl->lv;
+}
-- 
1.7.11.7


