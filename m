From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:25:58 +0000 (UTC)
Subject: master - lvm2app: Add thin and thin pool lv creation V5
Message-ID: <20130702192558.6DCFE60D30@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d5de8322b3a6050def60542b167b46d97b2824d
Commit:        4d5de8322b3a6050def60542b167b46d97b2824d
Parent:        fd94dd3b7e9e55029dd79274da18d8503fa12ebf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Apr 17 11:59:21 2013 +0530
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:33 2013 -0500

lvm2app: Add thin and thin pool lv creation V5

Add thin and thin pool lv creation support to lvm library

This is Mohan's thinp patch, re-worked to include suggestions
from Zdenek and Mohan.

V2: Remove const lvm_lv_params_create_thin
    Add const lvm_lv_params_skip_zero_get

V3: Changed get/set to use generic functions like current
    property

V4: Corrected macro in properties.c

V5: Fixed a bug in liblvm/lvm_lv.c function lvm_lv_create.
    incorrectly used pool instead of lv_name when doing the
    find_lv_in_vg call.

Based on work done by M. Mohan Kumar <mohan@in.ibm.com>

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/report/columns.h    |    2 +
 lib/report/properties.c |   30 +++++++
 lib/report/properties.h |    6 ++
 lib/report/report.c     |    1 +
 lib/report/report.h     |    3 +-
 liblvm/lvm2app.h        |  133 +++++++++++++++++++++++++++++
 liblvm/lvm_lv.c         |  212 ++++++++++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_misc.c       |   16 +++-
 liblvm/lvm_misc.h       |    6 +-
 liblvm/lvm_pv.c         |    4 +-
 liblvm/lvm_vg.c         |    4 +-
 tools/reporter.c        |    4 +
 12 files changed, 410 insertions(+), 11 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index d13d19a..4a05167 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -164,4 +164,6 @@ FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, monitor, "Dmeventd monitor
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
+
+FIELD(LV_CREATE_PARAMS, lvcreate_params, NUM, "skip_zero", zero, 2, uint32, skip_zero, "Skip zeroing on lv creation", 1)
 /* *INDENT-ON* */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ad23e7c..c20868b 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -39,6 +39,9 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
 #define GET_PVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
+#define GET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE)\
+	GET_NUM_PROPERTY_FN(NAME, VALUE, lvcreate_params, lvcp)
+
 
 #define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
 static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
@@ -48,6 +51,15 @@ static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
 	SETFN(VAR, prop->value.integer);		\
 	return 1; \
 }
+
+#define SET_NUM_PROPERTY(NAME, VALUE, TYPE, VAR)			\
+static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct TYPE *VAR = (struct TYPE *)obj; \
+\
+	VALUE = prop->value.integer;		\
+	return 1; \
+}
 #define SET_VG_NUM_PROPERTY_FN(NAME, SETFN) \
 	SET_NUM_PROPERTY_FN(NAME, SETFN, volume_group, vg)
 #define SET_PV_NUM_PROPERTY_FN(NAME, SETFN) \
@@ -55,6 +67,9 @@ static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
 #define SET_LV_NUM_PROPERTY_FN(NAME, SETFN) \
 	SET_NUM_PROPERTY_FN(NAME, SETFN, logical_volume, lv)
 
+#define SET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE) \
+	SET_NUM_PROPERTY(NAME, VALUE, lvcreate_params, lvcp)
+
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
@@ -360,6 +375,9 @@ GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
 #define _pvseg_size_set _not_implemented_set
 
+/* lv create parameters */
+GET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
+SET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
@@ -464,6 +482,18 @@ int pvseg_get_property(const struct pv_segment *pvseg,
 	return _get_property(pvseg, prop, PVSEGS);
 }
 
+int lv_create_param_get_property(const struct lvcreate_params *lvcp,
+		struct lvm_property_type *prop)
+{
+	return _get_property(lvcp, prop, LV_CREATE_PARAMS);
+}
+
+int lv_create_param_set_property(struct lvcreate_params *lvcp,
+		    struct lvm_property_type *prop)
+{
+	return _set_property(lvcp, prop, LV_CREATE_PARAMS);
+}
+
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop)
 {
diff --git a/lib/report/properties.h b/lib/report/properties.h
index aefd3f5..1a08589 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -50,4 +50,10 @@ int vg_set_property(struct volume_group *vg,
 int pv_set_property(struct physical_volume *pv,
 		    struct lvm_property_type *prop);
 
+int lv_create_param_get_property(const struct lvcreate_params *lvcp,
+		struct lvm_property_type *prop);
+
+int lv_create_param_set_property(struct lvcreate_params *lvcp,
+		    struct lvm_property_type *prop);
+
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 8b5455b..965859d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1295,6 +1295,7 @@ typedef struct logical_volume type_lv;
 typedef struct volume_group type_vg;
 typedef struct lv_segment type_seg;
 typedef struct pv_segment type_pvseg;
+typedef struct lvcreate_params type_lvcreate_params;
 
 static const struct dm_report_field_type _fields[] = {
 #include "columns.h"
diff --git a/lib/report/report.h b/lib/report/report.h
index 26cc2f7..d5bfb6a 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -24,7 +24,8 @@ typedef enum {
 	VGS	= 4,
 	SEGS	= 8,
 	PVSEGS	= 16,
-	LABEL	= 32
+	LABEL	= 32,
+	LV_CREATE_PARAMS = 64
 } report_type_t;
 
 struct field;
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 93a78c3..b1d6abd 100644
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
@@ -1400,6 +1409,130 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
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
+
+
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
index 91948a6..2039126 100644
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
@@ -50,13 +59,13 @@ const char *lvm_lv_get_name(const lv_t lv)
 
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
@@ -350,3 +359,202 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
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
+		if (!(lvl = find_lv_in_vg(params->vg, params->lvp.lv_name)))
+			return_NULL;
+		return (lv_t) lvl->lv;
+	}
+	log_error("Invalid lv_create_params parameter");
+	return NULL;
+}
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 0a0ea12..de66417 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -47,7 +47,8 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const pvseg_t pvseg, const char *name)
+				       const pvseg_t pvseg, const struct lvcreate_params *lvcp,
+				       const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v = { 0 };
@@ -69,6 +70,9 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	} else if (pvseg) {
 		if (!pvseg_get_property(pvseg, &prop))
 			return v;
+	} else if (lvcp) {
+		if (!lv_create_param_get_property(lvcp, &prop))
+					return v;
 	} else {
 		log_errno(EINVAL, "Invalid NULL handle passed to library function.");
 		return v;
@@ -87,7 +91,8 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 
 
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
-		 const char *name, struct lvm_property_value *v)
+			struct lvcreate_params *lvcp, const char *name,
+			struct lvm_property_value *v)
 {
 	struct lvm_property_type prop;
 
@@ -111,6 +116,13 @@ int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
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
index a0324b8..76f4e0a 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
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
index 90edaed..3924af4 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -51,13 +51,13 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 
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
 
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index b090b84..a707589 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -339,13 +339,13 @@ const char *lvm_vg_get_name(const vg_t vg)
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, NULL, NULL, name);
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,
 			struct lvm_property_value *value)
 {
-	return set_property(NULL, vg, NULL, name, value);
+	return set_property(NULL, vg, NULL, NULL, name, value);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
diff --git a/tools/reporter.c b/tools/reporter.c
index a6941e3..ced7d56 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -271,6 +271,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		else
 			options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 		break;
+	case LV_CREATE_PARAMS:
 	default:
 		log_error(INTERNAL_ERROR "Unknown report type.");
 		return ECMD_FAILED;
@@ -382,6 +383,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);
 		break;
+
+	case LV_CREATE_PARAMS:
+			break;
 	}
 
 	dm_report_output(report_handle);


