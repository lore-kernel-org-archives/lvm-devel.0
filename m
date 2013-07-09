From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  9 Jul 2013 01:07:17 +0000 (UTC)
Subject: master - report: remove LV_CREATE_PARAMS report type
Message-ID: <20130709010717.DE4D061625@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd302daf646f680531bf76ab13a9dafd06f63220
Commit:        dd302daf646f680531bf76ab13a9dafd06f63220
Parent:        5ed7d0cf1de4ebea6be8cb67759da40cb61c3913
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 9 02:06:29 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 9 02:06:29 2013 +0100

report: remove LV_CREATE_PARAMS report type

Remove LV_CREATE_PARAMS from lib/report as it is not a type of metadata.
Added by 4d5de8322b3a6050def60542b167b46d97b2824d
---
 lib/report/columns.h    |    2 -
 lib/report/properties.c |   86 ++++++---------
 lib/report/properties.h |    6 -
 lib/report/report.c     |    1 -
 lib/report/report.h     |    3 +-
 liblvm/lvm2app.h        |  152 -------------------------
 liblvm/lvm_lv.c         |  289 +----------------------------------------------
 liblvm/lvm_misc.c       |   16 +---
 liblvm/lvm_misc.h       |    6 +-
 liblvm/lvm_pv.c         |    4 +-
 liblvm/lvm_vg.c         |    4 +-
 tools/reporter.c        |    4 -
 12 files changed, 45 insertions(+), 528 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 4a05167..d13d19a 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -164,6 +164,4 @@ FIELD(SEGS, seg, STR, "Monitor", list, 7, segmonitor, monitor, "Dmeventd monitor
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
-
-FIELD(LV_CREATE_PARAMS, lvcreate_params, NUM, "skip_zero", zero, 2, uint32, skip_zero, "Skip zeroing on lv creation", 1)
 /* *INDENT-ON* */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c20868b..c7194c5 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -39,9 +39,6 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
 #define GET_PVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
-#define GET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE)\
-	GET_NUM_PROPERTY_FN(NAME, VALUE, lvcreate_params, lvcp)
-
 
 #define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
 static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
@@ -51,15 +48,6 @@ static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
 	SETFN(VAR, prop->value.integer);		\
 	return 1; \
 }
-
-#define SET_NUM_PROPERTY(NAME, VALUE, TYPE, VAR)			\
-static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
-{ \
-	struct TYPE *VAR = (struct TYPE *)obj; \
-\
-	VALUE = prop->value.integer;		\
-	return 1; \
-}
 #define SET_VG_NUM_PROPERTY_FN(NAME, SETFN) \
 	SET_NUM_PROPERTY_FN(NAME, SETFN, volume_group, vg)
 #define SET_PV_NUM_PROPERTY_FN(NAME, SETFN) \
@@ -67,9 +55,6 @@ static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
 #define SET_LV_NUM_PROPERTY_FN(NAME, SETFN) \
 	SET_NUM_PROPERTY_FN(NAME, SETFN, logical_volume, lv)
 
-#define SET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE) \
-	SET_NUM_PROPERTY(NAME, VALUE, lvcreate_params, lvcp)
-
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
@@ -92,23 +77,29 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
 {
 	log_errno(ENOSYS, "Function not implemented");
+
 	return 0;
 }
 
 static int _not_implemented_set(void *obj, struct lvm_property_type *prop)
 {
 	log_errno(ENOSYS, "Function not implemented");
+
 	return 0;
 }
 
-static percent_t _copy_percent(const struct logical_volume *lv) {
-	percent_t perc;
-	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &perc, NULL))
-		perc = PERCENT_INVALID;
-	return perc;
+static percent_t _copy_percent(const struct logical_volume *lv)
+{
+	percent_t percent;
+
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))
+		percent = PERCENT_INVALID;
+
+	return percent;
 }
 
-static uint64_t _mismatches(const struct logical_volume *lv) {
+static uint64_t _mismatches(const struct logical_volume *lv)
+{
 	uint64_t cnt;
 
 	if (!lv_raid_mismatch_count(lv, &cnt))
@@ -116,53 +107,59 @@ static uint64_t _mismatches(const struct logical_volume *lv) {
 	return cnt;
 }
 
-static char *_sync_action(const struct logical_volume *lv) {
+static char *_sync_action(const struct logical_volume *lv)
+{
 	char *action;
 
 	if (!lv_raid_sync_action(lv, &action))
 		return 0;
+
 	return action;
 }
 
-static uint32_t _writebehind(const struct logical_volume *lv) {
+static uint32_t _writebehind(const struct logical_volume *lv)
+{
 	return first_seg(lv)->writebehind;
 }
 
-static uint32_t _minrecoveryrate(const struct logical_volume *lv) {
+static uint32_t _minrecoveryrate(const struct logical_volume *lv)
+{
 	return first_seg(lv)->min_recovery_rate;
 }
 
-static uint32_t _maxrecoveryrate(const struct logical_volume *lv) {
+static uint32_t _maxrecoveryrate(const struct logical_volume *lv)
+{
 	return first_seg(lv)->max_recovery_rate;
 }
 
-static percent_t _snap_percent(const struct logical_volume *lv) {
-	percent_t perc;
+static percent_t _snap_percent(const struct logical_volume *lv)
+{
+	percent_t percent;
 
-	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &perc))
-		perc = PERCENT_INVALID;
+	if (!lv_is_cow(lv) || !lv_snapshot_percent(lv, &percent))
+		percent = PERCENT_INVALID;
 
-	return perc;
+	return percent;
 }
 
 static percent_t _data_percent(const struct logical_volume *lv)
 {
-	percent_t perc;
+	percent_t percent;
 
 	if (lv_is_cow(lv))
 		return _snap_percent(lv);
 
 	if (lv_is_thin_volume(lv))
-		return lv_thin_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+		return lv_thin_percent(lv, 0, &percent) ? percent : PERCENT_INVALID;
 
-	return lv_thin_pool_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+	return lv_thin_pool_percent(lv, 0, &percent) ? percent : PERCENT_INVALID;
 }
 
 static percent_t _metadata_percent(const struct logical_volume *lv)
 {
-	percent_t perc;
+	percent_t percent;
 
-	return lv_thin_pool_percent(lv, 1, &perc) ? perc : PERCENT_INVALID;
+	return lv_thin_pool_percent(lv, 1, &percent) ? percent : PERCENT_INVALID;
 }
 
 /* PV */
@@ -368,16 +365,12 @@ GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 GET_LVSEG_STR_PROPERTY_FN(monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _monitor_set _not_implemented_set
 
-
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 #define _pvseg_start_set _not_implemented_set
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
 #define _pvseg_size_set _not_implemented_set
 
-/* lv create parameters */
-GET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
-SET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
@@ -393,7 +386,6 @@ struct lvm_property_type _properties[] = {
 #undef NUM
 #undef FIELD
 
-
 static int _get_property(const void *obj, struct lvm_property_type *prop,
 			 unsigned type)
 {
@@ -419,6 +411,7 @@ static int _get_property(const void *obj, struct lvm_property_type *prop,
 	if (!p->get(obj, prop)) {
 		return 0;
 	}
+
 	return 1;
 }
 
@@ -455,6 +448,7 @@ static int _set_property(void *obj, struct lvm_property_type *prop,
 	if (!p->set(obj, p)) {
 		return 0;
 	}
+
 	return 1;
 }
 
@@ -482,18 +476,6 @@ int pvseg_get_property(const struct pv_segment *pvseg,
 	return _get_property(pvseg, prop, PVSEGS);
 }
 
-int lv_create_param_get_property(const struct lvcreate_params *lvcp,
-		struct lvm_property_type *prop)
-{
-	return _get_property(lvcp, prop, LV_CREATE_PARAMS);
-}
-
-int lv_create_param_set_property(struct lvcreate_params *lvcp,
-		    struct lvm_property_type *prop)
-{
-	return _set_property(lvcp, prop, LV_CREATE_PARAMS);
-}
-
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop)
 {
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 1a08589..aefd3f5 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -50,10 +50,4 @@ int vg_set_property(struct volume_group *vg,
 int pv_set_property(struct physical_volume *pv,
 		    struct lvm_property_type *prop);
 
-int lv_create_param_get_property(const struct lvcreate_params *lvcp,
-		struct lvm_property_type *prop);
-
-int lv_create_param_set_property(struct lvcreate_params *lvcp,
-		    struct lvm_property_type *prop);
-
 #endif
diff --git a/lib/report/report.c b/lib/report/report.c
index 965859d..8b5455b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1295,7 +1295,6 @@ typedef struct logical_volume type_lv;
 typedef struct volume_group type_vg;
 typedef struct lv_segment type_seg;
 typedef struct pv_segment type_pvseg;
-typedef struct lvcreate_params type_lvcreate_params;
 
 static const struct dm_report_field_type _fields[] = {
 #include "columns.h"
diff --git a/lib/report/report.h b/lib/report/report.h
index d5bfb6a..26cc2f7 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -24,8 +24,7 @@ typedef enum {
 	VGS	= 4,
 	SEGS	= 8,
 	PVSEGS	= 16,
-	LABEL	= 32,
-	LV_CREATE_PARAMS = 64
+	LABEL	= 32
 } report_type_t;
 
 struct field;
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index f4475c0..2775de6 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -97,7 +97,6 @@ struct volume_group;
 struct logical_volume;
 struct lv_segment;
 struct pv_segment;
-struct lvm_lv_create_params;
 
 /**
  * \class lvm_t
@@ -154,14 +153,6 @@ typedef struct lv_segment *lvseg_t;
 typedef struct pv_segment *pvseg_t;
 
 /**
- * \class lv_create_params
- *
- * This lv_create_params represents the plethora of available options when
- * creating a logical volume
- */
-typedef struct lvm_lv_create_params *lv_create_params_t;
-
-/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -1489,149 +1480,6 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
  */
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
 
-/**
- * Thin provisioning discard policies
- */
-typedef enum {
-	LVM_THIN_DISCARDS_IGNORE,
-	LVM_THIN_DISCARDS_NO_PASSDOWN,
-	LVM_THIN_DISCARDS_PASSDOWN,
-} lvm_thin_discards_t;
-
-/**
- * Create a thinpool parameter passing object for the specified VG
- *
- * \param   vg
- * Volume Group handle.
- *
- * \param   pool_name
- * Name of the pool.
- *
- * \param   size
- * size of the pool
- *
- * \param   chunk_size
- * data block size of the pool
- * Default value is DEFAULT_THIN_POOL_CHUNK_SIZE * 2 when 0 passed as chunk_size
- * DM_THIN_MIN_DATA_BLOCK_SIZE < chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE
- *
- * \param meta_size
- * Size of thin pool's metadata logical volume. Allowed range is 2MB-16GB.
- * Default value (ie if 0) pool size / pool chunk size * 64
- *
- * \param discard
- * Thin discard policy
- * Note: THIN_DISCARDS_PASSDOWN is the default.
- *
- * \return
- * Valid lv_create_params pointer on success, else NULL on error.
- * Note: Memory is associated with the vg, it will get reclaimed when vg is
- * closed.
- *
- */
-lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
-		const char *pool_name, uint64_t size, uint32_t chunk_size,
-		uint64_t meta_size, lvm_thin_discards_t discard);
-
-#define lvm_lv_params_create_thin_pool_default(vg, pool_name, size) \
-			lvm_lv_params_create_thin_pool((vg), (pool_name), (size), 0, 0, \
-			LVM_THIN_DISCARDS_PASSDOWN)
-
-
-/**
- * Creates the snapshot parameter passing object for the specified lv.
- *
- * \param	lv
- * The logical volume to snapshot
- *
- * \param	snap_name
- * Name of snapshot
- *
- * \param	max_snap_size
- * Used for old snap shots max size, set to zero for thinp
- *
- * \return
- * Valid lv_create_params pointer on success, else NULL on error.
- * Note: Memory is associated with the vg, it will get reclaimed when vg is
- * closed.
- */
-lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
-													const char *snap_name,
-													uint64_t max_snap_size);
-/**
- * Get the specific value of a lv create parameter by name
- *
- * \param	params		lv create parameters
- *
- * \param	name		name of parameter
- *
- * \return
- * lvm_property_value structure that will contain the current
- * value of the property.  Caller should check 'is_valid' flag before using
- * the value.  If 'is_valid' is not set, caller should check lvm_errno()
- * for specific error.
- */
-struct lvm_property_value lvm_lv_params_get_property(
-											const lv_create_params_t params,
-											const char *name);
-
-
-/**
- * Set the specific value of a lv create parameter by name
- *
- * Note that the property must be a 'settable' property, as evidenced '
- * by the 'is_settable' flag when querying the property.
- *
- * The memory allocated for a string property value is tied to the vg_t
- * handle associated with the lv_create_params_t and will be released when
- * lvm_vg_close() is called.
- *
- * \param	params		lv create parameters
- *
- * \param	name		name of parameter
- *
- * \param	prop		Property value to use for setting
- *
- * \return
- * 0 on success, -1 on error.
- */
-int lvm_lv_params_set_property(lv_create_params_t params,
-								const char *name,
-								struct lvm_property_value *prop);
-
-/**
- * Create a thin LV creation parameters in a given VG & thin pool
- *
- * \param   vg
- * Volume Group handle.
- *
- * \param   pool_name
- * Name of the pool.
- *
- * \param lvname
- * Name of the LV to create
- *
- * \param   size
- * Size of logical volume
- *
- * \return
- * Valid lv_create_params pointer on success, else NULL on error.
- * Note: Memory is associated with the vg, it will get reclaimed when vg is
- * closed.
- *
- */
-lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
-									const char *lvname, uint64_t size);
-/**
- * Create the actual logical volume.
- *
- * \param	params		The parameters object for lv creation
- *
- * \return
- * Valid lv pointer on success, else NULL on error.
- */
-lv_t lvm_lv_create(lv_create_params_t params);
-
 /************************** physical volume handling ************************/
 
 /**
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 4171baa..0590bd6 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -24,15 +24,6 @@
 
 /* FIXME Improve all the log messages to include context. Which VG/LV as a minimum? */
 
-struct lvm_lv_create_params
-{
-	uint32_t magic;
-	vg_t vg;
-	struct lvcreate_params lvp;
-};
-
-#define LV_CREATE_PARAMS_MAGIC 0xFEED0001
-
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
@@ -71,13 +62,13 @@ const char *lvm_lv_get_origin(const lv_t lv)
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, NULL, NULL, NULL, name);
+	return get_property(NULL, NULL, lv, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, lvseg, NULL, NULL, name);
+	return get_property(NULL, NULL, NULL, lvseg, NULL, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
@@ -355,279 +346,3 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 	return 0;
 }
 
-lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name,
-						uint64_t max_snap_size)
-{
-	struct lvm_lv_create_params *lvcp = NULL;
-
-	lvcp = lvm_lv_params_create_snapshot(lv, snap_name, max_snap_size);
-	if (lvcp) {
-		return lvm_lv_create(lvcp);
-	}
-	return NULL;
-}
-
-/* Set defaults for thin pool specific LV parameters */
-static void _lv_set_pool_params(struct lvcreate_params *lp,
-				vg_t vg, const char *pool,
-				uint64_t extents, uint64_t meta_size)
-{
-	_lv_set_default_params(lp, vg, NULL, extents);
-
-	lp->pool = pool;
-
-	lp->create_thin_pool = 1;
-	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
-	lp->stripes = 1;
-
-	if (!meta_size) {
-		lp->poolmetadatasize = extents * vg->extent_size /
-			(lp->chunk_size * (SECTOR_SIZE / 64));
-		while ((lp->poolmetadatasize >
-			(2 * DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
-		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
-			lp->chunk_size <<= 1;
-			lp->poolmetadatasize >>= 1;
-	         }
-	} else
-		lp->poolmetadatasize = meta_size;
-
-	if (lp->poolmetadatasize % vg->extent_size)
-		lp->poolmetadatasize +=
-			vg->extent_size - lp->poolmetadatasize % vg->extent_size;
-
-	lp->poolmetadataextents =
-		extents_from_size(vg->cmd, lp->poolmetadatasize / SECTOR_SIZE,
-						   vg->extent_size);
-}
-
-lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
-		const char *pool_name, uint64_t size, uint32_t chunk_size,
-		uint64_t meta_size, lvm_thin_discards_t discard)
-{
-	uint64_t extents = 0;
-	struct lvm_lv_create_params *lvcp = NULL;
-
-	if (meta_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
-		log_error("Invalid metadata size");
-		return NULL;
-	}
-
-	if (meta_size &&
-		meta_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
-		log_error("Invalid metadata size");
-		return NULL;
-	}
-
-	if (vg_read_error(vg))
-		return NULL;
-
-	if (!vg_check_write_mode(vg))
-		return NULL;
-
-	if (pool_name == NULL || !strlen(pool_name)) {
-		log_error("pool_name invalid");
-		return NULL;
-	}
-
-	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
-					  vg->extent_size))) {
-		log_error("Unable to create LV thin pool without size.");
-		return NULL;
-	}
-
-	lvcp = dm_pool_zalloc(vg->vgmem, sizeof (struct lvm_lv_create_params));
-
-	if (lvcp) {
-		lvcp->vg = vg;
-		lvcp->lvp.discards = discard;
-
-		if (chunk_size)
-			lvcp->lvp.chunk_size = chunk_size;
-		else
-			lvcp->lvp.chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
-
-		if (lvcp->lvp.chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
-				lvcp->lvp.chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
-			log_error("Invalid chunk_size");
-			return NULL;
-		}
-
-		_lv_set_pool_params(&lvcp->lvp, vg, pool_name, extents, meta_size);
-
-		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
-	}
-	return lvcp;
-}
-
-/* Set defaults for thin LV specific parameters */
-static void _lv_set_thin_params(struct lvcreate_params *lp,
-				vg_t vg, const char *pool,
-				const char *lvname,
-				uint64_t extents)
-{
-	_lv_set_default_params(lp, vg, lvname, extents);
-
-	lp->thin = 1;
-	lp->pool = pool;
-	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
-
-	lp->voriginsize = extents * vg->extent_size;
-	lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
-						   vg->extent_size);
-
-	lp->stripes = 1;
-}
-
-lv_create_params_t lvm_lv_params_create_snapshot(const lv_t lv,
-													const char *snap_name,
-													uint64_t max_snap_size)
-{
-	uint64_t size = 0;
-	uint64_t extents = 0;
-	struct lvm_lv_create_params *lvcp = NULL;
-
-	if (vg_read_error(lv->vg)) {
-		return NULL;
-	}
-
-	if (!vg_check_write_mode(lv->vg))
-			return NULL;
-
-	if (snap_name == NULL || !strlen(snap_name)) {
-		log_error("snap_name invalid");
-		return NULL;
-	}
-
-	if (max_snap_size) {
-		size = max_snap_size >> SECTOR_SHIFT;
-		extents = extents_from_size(lv->vg->cmd, size, lv->vg->extent_size);
-	}
-
-	if (!size && !lv_is_thin_volume(lv) ) {
-		log_error("Origin is not thin, specify size of snapshot");
-					return NULL;
-	}
-
-	lvcp = dm_pool_zalloc(lv->vg->vgmem, sizeof (struct lvm_lv_create_params));
-	if (lvcp) {
-		lvcp->vg = lv->vg;
-		_lv_set_default_params(&lvcp->lvp, lv->vg, snap_name, extents);
-		lvcp->lvp.snapshot = 1;
-
-
-		if (size) {
-			lvcp->lvp.segtype = _get_segtype(lvcp->vg->cmd);
-			lvcp->lvp.chunk_size = 8;
-		} else {
-			lvcp->lvp.segtype = get_segtype_from_string(lv->vg->cmd, "thin");
-
-			if (!lvcp->lvp.segtype) {
-				log_error(INTERNAL_ERROR "Segtype thin not found.");
-				return NULL;
-			}
-
-			lvcp->lvp.pool = first_seg(lv)->pool_lv->name;
-		}
-
-		lvcp->lvp.stripes = 1;
-		lvcp->lvp.origin = lv->name;
-
-		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
-	}
-
-	return lvcp;
-}
-
-
-lv_create_params_t lvm_lv_params_create_thin(const vg_t vg, const char *pool_name,
-									const char *lvname, uint64_t size)
-{
-	struct lvm_lv_create_params *lvcp = NULL;
-	uint64_t extents = 0;
-
-	/* precondition checks */
-	if (vg_read_error(vg))
-		return NULL;
-
-	if (!vg_check_write_mode(vg))
-		return NULL;
-
-	if (pool_name == NULL || !strlen(pool_name)) {
-		log_error("pool_name invalid");
-		return NULL;
-	}
-
-	if (lvname == NULL || !strlen(lvname)) {
-		log_error("lvname invalid");
-		return NULL;
-	}
-
-	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
-			vg->extent_size))) {
-		log_error("Unable to create thin LV without size.");
-		return NULL;
-	}
-
-	lvcp = dm_pool_zalloc(vg->vgmem, sizeof (struct lvm_lv_create_params));
-	if (lvcp) {
-		lvcp->vg = vg;
-		_lv_set_thin_params(&lvcp->lvp, vg, pool_name, lvname, extents);
-		lvcp->magic = LV_CREATE_PARAMS_MAGIC;
-	}
-
-	return lvcp;
-}
-
-struct lvm_property_value lvm_lv_params_get_property(
-						const lv_create_params_t params,
-						const char *name)
-{
-	struct lvm_property_value rc;
-
-	rc.is_valid = 0;
-
-	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
-		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, name);
-	} else {
-		log_error("Invalid lv_create_params parameter");
-	}
-	return rc;
-}
-
-int lvm_lv_params_set_property(lv_create_params_t params, const char *name,
-								struct lvm_property_value *prop)
-{
-	int rc = -1;
-
-	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
-		rc = set_property(NULL, NULL, NULL, &params->lvp, name, prop);
-	} else {
-		log_error("Invalid lv_create_params parameter");
-	}
-	return rc;
-}
-
-lv_t lvm_lv_create(lv_create_params_t params)
-{
-	struct lv_list *lvl = NULL;
-
-	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
-		if (!params->lvp.segtype) {
-			log_error("segtype parameter is NULL");
-			return_NULL;
-		}
-		if (!lv_create_single(params->vg, &params->lvp))
-				return_NULL;
-
-		/* In some case we are making a thin pool so lv_name is not valid, but
-		 * pool is.
-		 */
-		if (!(lvl = find_lv_in_vg(params->vg,
-				(params->lvp.lv_name) ? params->lvp.lv_name : params->lvp.pool)))
-			return_NULL;
-		return (lv_t) lvl->lv;
-	}
-	log_error("Invalid lv_create_params parameter");
-	return NULL;
-}
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index de66417..0a0ea12 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -47,8 +47,7 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const pvseg_t pvseg, const struct lvcreate_params *lvcp,
-				       const char *name)
+				       const pvseg_t pvseg, const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v = { 0 };
@@ -70,9 +69,6 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	} else if (pvseg) {
 		if (!pvseg_get_property(pvseg, &prop))
 			return v;
-	} else if (lvcp) {
-		if (!lv_create_param_get_property(lvcp, &prop))
-					return v;
 	} else {
 		log_errno(EINVAL, "Invalid NULL handle passed to library function.");
 		return v;
@@ -91,8 +87,7 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 
 
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
-			struct lvcreate_params *lvcp, const char *name,
-			struct lvm_property_value *v)
+		 const char *name, struct lvm_property_value *v)
 {
 	struct lvm_property_type prop;
 
@@ -116,13 +111,6 @@ int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 			v->is_valid = 0;
 			return -1;
 		}
-	} else if (lvcp) {
-		if (!lv_create_param_set_property(lvcp, &prop)) {
-			v->is_valid = 0;
-			return -1;
-		}
-	} else {
-		return -1;
 	}
 	return 0;
 }
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index 76f4e0a..a0324b8 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -20,10 +20,8 @@
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const pvseg_t pvseg, const struct lvcreate_params *lvcp,
-				       const char *name);
+				       const pvseg_t pvseg, const char *name);
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
-			struct lvcreate_params *lvcp, const char *name,
-			struct lvm_property_value *value);
+		 const char *name, struct lvm_property_value *value);
 
 #endif
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 5d8a66b..e679b3a 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -53,13 +53,13 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, NULL, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, NULL, pvseg, NULL, name);
+	return get_property(NULL, NULL, NULL, NULL, pvseg, name);
 }
 
 struct lvm_list_wrapper
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 955afdb..4a5fdf5 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -339,7 +339,7 @@ const char *lvm_vg_get_name(const vg_t vg)
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, NULL, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, NULL, name);
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,
@@ -356,7 +356,7 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 				strlen(value->value.string) + 1);
 	}
 
-	return set_property(NULL, vg, NULL, NULL, name, value);
+	return set_property(NULL, vg, NULL, name, value);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
diff --git a/tools/reporter.c b/tools/reporter.c
index ced7d56..a6941e3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -271,7 +271,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		else
 			options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 		break;
-	case LV_CREATE_PARAMS:
 	default:
 		log_error(INTERNAL_ERROR "Unknown report type.");
 		return ECMD_FAILED;
@@ -383,9 +382,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);
 		break;
-
-	case LV_CREATE_PARAMS:
-			break;
 	}
 
 	dm_report_output(report_handle);


