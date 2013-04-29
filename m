From: Tony Asleson <tasleson@redhat.com>
Date: Mon, 29 Apr 2013 14:20:43 -0500
Subject: [PATCH] RFC: lvm2app: Add thin and thin pool lv creation
Message-ID: <1367263243-17331-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Add thin and thin pool lv creation support to lvm library

This is Mohan's patch, re-worked to include suggestions
from Zdenek.

Is this closer to what we are looking for?

--Tony

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h | 116 +++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c  | 205 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 321 insertions(+)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 93a78c3..bbdc037 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -97,6 +97,7 @@ struct volume_group;
 struct logical_volume;
 struct lv_segment;
 struct pv_segment;
+struct lvm_lv_create_params;
 
 /**
  * \class lvm_t
@@ -153,6 +154,14 @@ typedef struct lv_segment *lvseg_t;
 typedef struct pv_segment *pvseg_t;
 
 /**
+ * \class lv_create_params
+ *
+ * This lv_create_params represents the plethora of available options when
+ * creating a logical volume
+ */
+typedef struct lvm_lv_create_params *lv_create_params_t;
+
+/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -1400,6 +1409,113 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
  */
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
 
+/**
+ * Thin provisioning discard policies
+ */
+typedef enum {
+	LVM_THIN_DISCARDS_IGNORE,
+	LVM_THIN_DISCARDS_NO_PASSDOWN,
+	LVM_THIN_DISCARDS_PASSDOWN,
+} lvm_thin_discards_t;
+
+/**
+ * Create a thinpool parameter passing object for the specified VG
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
+ * Default value is DEFAULT_THIN_POOL_CHUNK_SIZE * 2 when 0 passed as chunk_size
+ * DM_THIN_MIN_DATA_BLOCK_SIZE < chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE
+ *
+ * \param meta_size
+ * Size of thin pool's metadata logical volume. Allowed range is 2MB-16GB.
+ * Default value (ie if 0) pool size / pool chunk size * 64
+ *
+ * \param discard
+ * Thin discard policy
+ * Note: THIN_DISCARDS_PASSDOWN is the default.
+ *
+ * \return
+ * Valid lv_create_params pointer on success, else NULL on error.
+ * Note: Memory is associated with the vg, it will get reclaimed when vg is
+ * closed.
+ *
+ */
+lv_create_params_t lvm_lv_params_create_thin_pool(const vg_t vg,
+		const char *pool_name, uint64_t size, uint32_t chunk_size,
+		uint64_t meta_size, lvm_thin_discards_t discard);
+
+#define lvm_lv_params_create_thin_pool_default(vg, pool_name, size) \
+			lvm_lv_params_create_thin_pool((vg), (pool_name), (size), 0, 0, \
+			LVM_THIN_DISCARDS_PASSDOWN)
+
+
+/**
+ * Set the value of zero skip for the lv_create_params
+ *
+ * \param params
+ * lv_create_prams to change
+ *
+ * \param skip
+ * Value of skip zero to be set (0 == zero, 1 == skip zero)
+ *
+ * \return
+ * 0 on success, else -1
+ */
+int lvm_lv_params_skip_zero_set(lv_create_params_t params, int skip);
+
+/**
+ * Get the value of zero skip for the lv_create_params
+ *
+ * \param params
+ * lv_create_prams to query
+ *
+ * \return
+ * -1 on error, else 0 == zero, 1 == skip zero
+ */
+int lvm_lv_params_skip_zero_get(lv_create_params_t params);
+
+/**
+ * Create a thin LV creation parameters in a given VG & thin pool
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
+ * Valid lv_create_params pointer on success, else NULL on error.
+ * Note: Memory is associated with the vg, it will get reclaimed when vg is
+ * closed.
+ *
+ */
+lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
+									const char *lvname, uint64_t size);
+/**
+ * Create the actual logical volume.
+ *
+ * \param	params		The parameters object for lv creation
+ *
+ * \return
+ * Valid lv pointer on success, else NULL on error.
+ */
+lv_t lvm_lv_create(lv_create_params_t params);
+
 /************************** physical volume handling ************************/
 
 /**
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 91948a6..7e49cb3 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -22,6 +22,15 @@
 #include "lvm_misc.h"
 #include "lvm2app.h"
 
+struct lvm_lv_create_params
+{
+	uint32_t magic;
+	vg_t vg;
+	struct lvcreate_params lvp;
+};
+
+#define LV_CREATE_PARAMS_MAGIC 0xFEED0001
+
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
@@ -350,3 +359,199 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
 		return NULL;
 	return (lv_t) lvl->lv;
 }
+
+/* Set defaults for thin pool specific LV parameters */
+static void _lv_set_pool_params(struct lvcreate_params *lp,
+				vg_t vg, const char *pool,
+				uint64_t extents, uint64_t meta_size)
+{
+	_lv_set_default_params(lp, vg, NULL, extents);
+
+	lp->pool = pool;
+
+	lp->create_thin_pool = 1;
+	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
+	lp->stripes = 1;
+
+	if (!meta_size) {
+		lp->poolmetadatasize = extents * vg->extent_size /
+			(lp->chunk_size * (SECTOR_SIZE / 64));
+		while ((lp->poolmetadatasize >
+			(2 * DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
+		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
+			lp->chunk_size <<= 1;
+			lp->poolmetadatasize >>= 1;
+	         }
+	} else
+		lp->poolmetadatasize = meta_size;
+
+	if (lp->poolmetadatasize % vg->extent_size)
+		lp->poolmetadatasize +=
+			vg->extent_size - lp->poolmetadatasize % vg->extent_size;
+
+	lp->poolmetadataextents =
+		extents_from_size(vg->cmd, lp->poolmetadatasize / SECTOR_SIZE,
+						   vg->extent_size);
+}
+
+lv_create_params_t lvm_lv_params_create_thin_pool(const vg_t vg,
+		const char *pool_name, uint64_t size, uint32_t chunk_size,
+		uint64_t meta_size, lvm_thin_discards_t discard)
+{
+	uint64_t extents = 0;
+	struct lvm_lv_create_params *lvcp = NULL;
+
+	if (meta_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		log_error("Invalid metadata size");
+		return NULL;
+	}
+
+	if (meta_size &&
+		meta_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+		log_error("Invalid metadata size");
+		return NULL;
+	}
+
+	if (vg_read_error(vg))
+		return NULL;
+
+	if (!vg_check_write_mode(vg))
+		return NULL;
+
+	if (pool_name == NULL || !strlen(pool_name)) {
+		log_error("pool_name invalid");
+		return NULL;
+	}
+
+	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
+					  vg->extent_size))) {
+		log_error("Unable to create LV thin pool without size.");
+		return NULL;
+	}
+
+	lvcp = dm_pool_zalloc(vg->vgmem, sizeof (struct lvm_lv_create_params));
+
+	if (lvcp) {
+		lvcp->vg = vg;
+		lvcp->lvp.discards = discard;
+
+		if (chunk_size)
+			lvcp->lvp.chunk_size = chunk_size;
+		else
+			lvcp->lvp.chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
+
+		if (lvcp->lvp.chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
+				lvcp->lvp.chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
+			log_error("Invalid chunk_size");
+			return NULL;
+		}
+
+		_lv_set_pool_params(&lvcp->lvp, vg, pool_name, extents, meta_size);
+
+		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
+	}
+	return lvcp;
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
+lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
+									const char *lvname, uint64_t size)
+{
+	struct lvm_lv_create_params *lvcp = NULL;
+	uint64_t extents = 0;
+
+	/* precondition checks */
+	if (vg_read_error(vg))
+		return NULL;
+
+	if (!vg_check_write_mode(vg))
+		return NULL;
+
+	if (pool_name == NULL || !strlen(pool_name)) {
+		log_error("pool_name invalid");
+		return NULL;
+	}
+
+	if (lvname == NULL || !strlen(lvname)) {
+		log_error("lvname invalid");
+		return NULL;
+	}
+
+	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
+			vg->extent_size))) {
+		log_error("Unable to create thin LV without size.");
+		return NULL;
+	}
+
+	lvcp = dm_pool_zalloc(vg->vgmem, sizeof (struct lvm_lv_create_params));
+	if (lvcp) {
+		lvcp->vg = vg;
+		_lv_set_thin_params(&lvcp->lvp, vg, pool_name, lvname, extents);
+		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
+	}
+
+	return lvcp;
+}
+
+int lvm_lv_params_skip_zero_set(lv_create_params_t params, int skip)
+{
+	int rc = -1;
+
+	if (skip == 0 || skip == 1) {
+		if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+			params->lvp.zero = skip;
+			rc = 0;
+		} else {
+			log_error("Invalid lv_create_params parameter");
+		}
+	} else {
+		log_error("Invalid skip value");
+	}
+	return rc;
+}
+
+int lvm_lv_params_skip_zero_get(lv_create_params_t params)
+{
+	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+		return params->lvp.zero;
+	}
+	log_error("Invalid lv_create_params parameter");
+	return -1;
+}
+
+lv_t lvm_lv_create(lv_create_params_t params)
+{
+	struct lv_list *lvl = NULL;
+
+	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+		if (!params->lvp.segtype) {
+			log_error("segtype parameter is NULL");
+			return_NULL;
+		}
+		if (!lv_create_single(params->vg, &params->lvp))
+				return_NULL;
+		if (!(lvl = find_lv_in_vg(params->vg, params->lvp.pool)))
+			return_NULL;
+		return (lv_t) lvl->lv;
+	}
+	log_error("Invalid lv_create_params parameter");
+	return NULL;
+}
-- 
1.8.1.4


