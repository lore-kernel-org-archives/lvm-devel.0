From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 12 Jul 2013 15:50:52 -0500
Subject: [PATCH 2/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <1373662252-10721-1-git-send-email-tasleson@redhat.com>
References: <1373662252-10721-1-git-send-email-tasleson@redhat.com>
Message-ID: <1373662252-10721-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add thin and thin pool lv creation support to lvm library

This is Mohan's thinp patch, re-worked to include suggestions
from Zdenek and Mohan.

Rework of commit 4d5de8322b3a6050def60542b167b46d97b2824d
which uses refactored properties handling.

Based on work done by M. Mohan Kumar <mohan@in.ibm.com>

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/properties/prop_common.h |   9 ++
 liblvm/Makefile.in           |   3 +-
 liblvm/lvm2app.h             | 153 +++++++++++++++++++++-
 liblvm/lvm_lv.c              | 293 ++++++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_misc.c            |  24 +++-
 liblvm/lvm_misc.h            |   8 +-
 liblvm/lvm_pv.c              |   4 +-
 liblvm/lvm_vg.c              |   6 +-
 8 files changed, 483 insertions(+), 17 deletions(-)

diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
index a39f2f1..6c89ad6 100644
--- a/lib/properties/prop_common.h
+++ b/lib/properties/prop_common.h
@@ -62,6 +62,15 @@ static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
 	return 1; \
 }
 
+#define SET_NUM_PROPERTY(NAME, VALUE, TYPE, VAR)			\
+static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct TYPE *VAR = (struct TYPE *)obj; \
+\
+	VALUE = prop->value.integer;		\
+	return 1; \
+}
+
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 8ae4661..d0f8d1b 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -18,6 +18,7 @@ top_builddir = @top_builddir@
 
 SOURCES =\
 	lvm_misc.c \
+	lvm_prop.c \
 	lvm_base.c \
 	lvm_lv.c \
 	lvm_pv.c \
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 2775de6..cb6766c 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2009,2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
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
@@ -1480,6 +1489,148 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
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
+lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
+		const char *pool_name, uint64_t size, uint32_t chunk_size,
+		uint64_t meta_size, lvm_thin_discards_t discard);
+
+#define lvm_lv_params_create_thin_pool_default(vg, pool_name, size) \
+			lvm_lv_params_create_thin_pool((vg), (pool_name), (size), 0, 0, \
+			LVM_THIN_DISCARDS_PASSDOWN)
+
+/**
+ * Creates the snapshot parameter passing object for the specified lv.
+ *
+ * \param	lv
+ * The logical volume to snapshot
+ *
+ * \param	snap_name
+ * Name of snapshot
+ *
+ * \param	max_snap_size
+ * Used for old snap shots max size, set to zero for thinp
+ *
+ * \return
+ * Valid lv_create_params pointer on success, else NULL on error.
+ * Note: Memory is associated with the vg, it will get reclaimed when vg is
+ * closed.
+ */
+lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
+													const char *snap_name,
+													uint64_t max_snap_size);
+/**
+ * Get the specific value of a lv create parameter by name
+ *
+ * \param	params		lv create parameters
+ *
+ * \param	name		name of parameter
+ *
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check 'is_valid' flag before using
+ * the value.  If 'is_valid' is not set, caller should check lvm_errno()
+ * for specific error.
+ */
+struct lvm_property_value lvm_lv_params_get_property(
+											const lv_create_params_t params,
+											const char *name);
+
+
+/**
+ * Set the specific value of a lv create parameter by name
+ *
+ * Note that the property must be a 'settable' property, as evidenced '
+ * by the 'is_settable' flag when querying the property.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle associated with the lv_create_params_t and will be released when
+ * lvm_vg_close() is called.
+ *
+ * \param	params		lv create parameters
+ *
+ * \param	name		name of parameter
+ *
+ * \param	prop		Property value to use for setting
+ *
+ * \return
+ * 0 on success, -1 on error.
+ */
+int lvm_lv_params_set_property(lv_create_params_t params,
+								const char *name,
+								struct lvm_property_value *prop);
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
index 0590bd6..c28d997 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,9 +21,19 @@
 #include "activate.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
+#include "lvm_prop.h"
 
 /* FIXME Improve all the log messages to include context. Which VG/LV as a minimum? */
 
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
@@ -62,13 +72,13 @@ const char *lvm_lv_get_origin(const lv_t lv)
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, NULL, NULL, name);
+	return get_property(NULL, NULL, lv, NULL, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, lvseg, NULL, name);
+	return get_property(NULL, NULL, NULL, lvseg, NULL, NULL, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
@@ -346,3 +356,280 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	return 0;
 }
 
+lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
+						uint64_t max_snap_size)
+{
+	struct lvm_lv_create_params *lvcp = NULL;
+
+	lvcp = lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
+	if (lvcp) {
+		return lvm_lv_create(lvcp);
+	}
+	return NULL;
+}
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
+lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
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
+lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
+													const char *snap_name,
+													uint64_t max_snap_size)
+{
+	uint64_t size = 0;
+	uint64_t extents = 0;
+	struct lvm_lv_create_params *lvcp = NULL;
+
+	if (vg_read_error(lv->vg)) {
+		return NULL;
+	}
+
+	if (!vg_check_write_mode(lv->vg))
+			return NULL;
+
+	if (snap_name == NULL || !strlen(snap_name)) {
+		log_error("snap_name invalid");
+		return NULL;
+	}
+
+	if (max_snap_size) {
+		size = max_snap_size >> SECTOR_SHIFT;
+		extents = extents_from_size(lv->vg->cmd, size, lv->vg->extent_size);
+	}
+
+	if (!size && !lv_is_thin_volume(lv) ) {
+		log_error("Origin is not thin, specify size of snapshot");
+					return NULL;
+	}
+
+	lvcp = dm_pool_zalloc(lv->vg->vgmem, sizeof (struct lvm_lv_create_params));
+	if (lvcp) {
+		lvcp->vg = lv->vg;
+		_lv_set_default_params(&lvcp->lvp, lv->vg, snap_name, extents);
+		lvcp->lvp.snapshot = 1;
+
+
+		if (size) {
+			lvcp->lvp.segtype = _get_segtype(lvcp->vg->cmd);
+			lvcp->lvp.chunk_size = 8;
+		} else {
+			lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "thin");
+
+			if (!lvcp->lvp.segtype) {
+				log_error(INTERNAL_ERROR "Segtype thin not found.");
+				return NULL;
+			}
+
+			lvcp->lvp.pool = first_seg(lv)->pool_lv->name;
+		}
+
+		lvcp->lvp.stripes = 1;
+		lvcp->lvp.origin = lv->name;
+
+		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
+	}
+
+	return lvcp;
+}
+
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
+struct lvm_property_value lvm_lv_params_get_property(
+						const lv_create_params_t params,
+						const char *name)
+{
+	struct lvm_property_value rc;
+
+	rc.is_valid = 0;
+
+	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, name);
+	} else {
+		log_error("Invalid lv_create_params parameter");
+	}
+	return rc;
+}
+
+int lvm_lv_params_set_property(lv_create_params_t params, const char *name,
+								struct lvm_property_value *prop)
+{
+	int rc = -1;
+
+	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
+		rc = set_property(NULL, NULL, NULL, &params->lvp, name, prop);
+	} else {
+		log_error("Invalid lv_create_params parameter");
+	}
+	return rc;
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
+
+		/*
+		 * In some case we are making a thin pool so lv_name is not valid, but
+		 * pool is.
+		 */
+		if (!(lvl = find_lv_in_vg(params->vg,
+				(params->lvp.lv_name) ? params->lvp.lv_name : params->lvp.pool)))
+			return_NULL;
+		return (lv_t) lvl->lv;
+	}
+	log_error("Invalid lv_create_params parameter");
+	return NULL;
+}
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 0a0ea12..c79af8f 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,6 +16,7 @@
 #include "properties.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
+#include "lvm_prop.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
@@ -46,8 +47,11 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 }
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
-				       const lv_t lv, const lvseg_t lvseg,
-				       const pvseg_t pvseg, const char *name)
+				       const lv_t lv,
+				       const lvseg_t lvseg,
+				       const pvseg_t pvseg,
+				       const struct lvcreate_params *lvcp,
+				       const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v = { 0 };
@@ -69,6 +73,9 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	} else if (pvseg) {
 		if (!pvseg_get_property(pvseg, &prop))
 			return v;
+	} else if (lvcp) {
+		if (!lv_create_param_get_property(lvcp, &prop))
+			return v;
 	} else {
 		log_errno(EINVAL, "Invalid NULL handle passed to library function.");
 		return v;
@@ -87,7 +94,9 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 
 
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
-		 const char *name, struct lvm_property_value *v)
+		struct lvcreate_params *lvcp,
+		const char *name,
+		struct lvm_property_value *v)
 {
 	struct lvm_property_type prop;
 
@@ -111,6 +120,13 @@ int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 			v->is_valid = 0;
 			return -1;
 		}
+	} else if (lvcp) {
+		if (!lv_create_param_set_property(lvcp, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	} else {
+		return -1;
 	}
 	return 0;
 }
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index a0324b8..a84125a 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -20,8 +20,10 @@
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const pvseg_t pvseg, const char *name);
+				       const pvseg_t pvseg, const struct lvcreate_params *lvcp,
+				       const char *name);
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
-		 const char *name, struct lvm_property_value *value);
+			struct lvcreate_params *lvcp, const char *name,
+			struct lvm_property_value *value);
 
 #endif
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index a2e7ef0..2bd0ac0 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -53,13 +53,13 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, NULL, pvseg, name);
+	return get_property(NULL, NULL, NULL, NULL, pvseg, NULL, name);
 }
 
 struct lvm_list_wrapper
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 35c7eea..c128ba7 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -340,7 +340,7 @@ const char *lvm_vg_get_name(const vg_t vg)
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, NULL, NULL, name);
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,
@@ -357,7 +357,7 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 				strlen(value->value.string) + 1);
 	}
 
-	return set_property(NULL, vg, NULL, name, value);
+	return set_property(NULL, vg, NULL, NULL, name, value);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
-- 
1.8.1.4


