From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Wed, 23 Jan 2013 12:55:07 +0530
Subject: [RFC/PATCH] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
References: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
Message-ID: <1358925908-32347-2-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Add thin and thin pool lv creation support to lvm library

Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
---
 liblvm/lvm2app.h | 44 ++++++++++++++++++++++++++
 liblvm/lvm_lv.c  | 94 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 138 insertions(+)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 93a78c3..92bdf71 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1400,6 +1400,50 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
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
+ * \return
+ * Valid lv pointer on success, else NULL on error.
+ *
+ */
+lv_t lvm_lv_thinpool(const vg_t vg, const char *pool_name, uint64_t size);
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
index 91948a6..42ee78f 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -350,3 +350,97 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
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
+	lp->chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
+	lp->create_thin_pool = 1;
+	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
+	lp->stripes = 1;
+	lp->poolmetadatasize = extents * vg->extent_size / lp->chunk_size *
+		(SECTOR_SIZE / UINT64_C(64));
+	lp->poolmetadataextents = extents_from_size(vg->cmd, lp->poolmetadatasize,
+						   vg->extent_size);
+}
+
+lv_t lvm_lv_thinpool(const vg_t vg, const char *pool, uint64_t size)
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
+	_lv_set_pool_params(&lp, vg, pool, extents);
+
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


