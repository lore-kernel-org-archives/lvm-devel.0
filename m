From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 27 Sep 2013 14:10:26 -0500
Subject: [PATCH 06/12] lvm2app: Add ability to create PV with args
In-Reply-To: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
References: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
Message-ID: <1380309032-12736-7-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a PV create which takes a paramters object that
has get/set method to configure PV creation.

Current get/set operations include:
- size
- pvmetadatacopies
- pvmetadatasize
- data_alignment
- data_alignment_offset
- zero

Reference: https://bugzilla.redhat.com/show_bug.cgi?id=880395

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata.c  |  28 ++++++++++
 liblvm/lvm2app.h         |  64 ++++++++++++++++++++++
 liblvm/lvm_lv.c          |   8 +--
 liblvm/lvm_misc.c        |  10 ++++
 liblvm/lvm_misc.h        |   9 +++-
 liblvm/lvm_prop.c        |  31 +++++++++++
 liblvm/lvm_prop.h        |  14 +++++
 liblvm/lvm_prop_fields.h |   7 +++
 liblvm/lvm_pv.c          | 136 ++++++++++++++++++++++++++++++++++++++++++-----
 liblvm/lvm_vg.c          |   4 +-
 tools/toollib.c          |   6 ---
 11 files changed, 289 insertions(+), 28 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 942109d..1a212c3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1463,6 +1463,30 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_create *pvc)
 	return 1;
 }
 
+static int _verify_pv_create_params(struct pvcreate_params *pp)
+{
+	/*
+	 * FIXME: Some of these checks are duplicates in pvcreate_params_validate.
+	 */
+	if (pp->pvmetadatacopies > 2) {
+		log_error("Metadatacopies may only be 0, 1 or 2");
+		return 0;
+	}
+
+	if (pp->data_alignment > UINT32_MAX) {
+		log_error("Physical volume data alignment is too big.");
+		return 0;
+	}
+
+	if (pp->data_alignment_offset > UINT32_MAX) {
+		log_error("Physical volume data alignment offset is too big.");
+		return 0;
+	}
+
+	return 1;
+}
+
+
 /*
  * pvcreate_vol() - initialize a device with PV label and metadata area
  *
@@ -1487,6 +1511,10 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 	if (!pp)
 		pp = &default_pp;
 
+	if (!_verify_pv_create_params(pp)) {
+		goto bad;
+	}
+
 	if (pp->rp.idp) {
 		if ((dev = lvmcache_device_from_pvid(cmd, pp->rp.idp, NULL, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index cb6766c..afc6793 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -162,6 +162,14 @@ typedef struct pv_segment *pvseg_t;
 typedef struct lvm_lv_create_params *lv_create_params_t;
 
 /**
+ * \class pv_create_params
+ *
+ * This pv_create_params represents the plethora of available options when
+ * creating a physical volume
+ */
+typedef struct lvm_pv_create_params *pv_create_params_t;
+
+/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -582,6 +590,62 @@ int lvm_list_pvs_free(struct dm_list *pvlist);
 int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size);
 
 /**
+ * Create a physical volume parameter object for PV creation.
+ *
+ * \param	libh	Library handle
+ * \param	pv_name	Device name
+ *
+ * \return
+ * NULL on error, else valid parameter object to use.
+ */
+pv_create_params_t lvm_pv_params_create(lvm_t libh, const char *pv_name);
+
+/**
+ * Create a parameter object to use in function lvm_pv_create_adv
+ *
+ * 	\param 	params	The params object to get property value from
+ * 	\param	name	The name of the property to retrieve
+ *
+ * 	Available properties:
+ *
+ * 	size					zero indicates use detected size of device
+ * 							(recommended and default)
+ *	pvmetadatacopies		Number of metadata copies (0,1,2)
+ *	pvmetadatasize			The approx. size to be to be set aside for metadata
+ *	data_alignment			Align the start of the data to a multiple of
+ *							this number
+ *	data_alignment_offset	Shift the start of the data area by this addl.
+ *							offset
+ *	zero					Set to 1 to zero out first 2048 bytes of
+ *							device, 0 to not (default is 1)
+ *
+ * 	\return
+ * 	lvm_property_value
+ */
+struct lvm_property_value lvm_pv_params_get_property(
+						const pv_create_params_t params,
+						const char *name);
+
+/**
+ * Sets a property of a PV parameter create object.
+ *
+ * \param	params		The parameter object
+ * \param	name		The name of the property to set (see get prop list)
+ * \param	prop		The property to set the value on.
+ */
+int lvm_pv_params_set_property(pv_create_params_t params, const char *name,
+								struct lvm_property_value *prop);
+/**
+ * Creates a physical volume using the supplied params object.
+ *
+ * \param	params		The parameters to use for physical volume creation
+ *
+ * \return
+ * -1 on error, 0 on success.
+ */
+int lvm_pv_create_adv(pv_create_params_t params);
+
+/**
  *  Remove a physical volume.
  *  Note: You cannot remove a PV while iterating through the list of PVs as
  *  locks are held for the PV list.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 46399e4..938a16b 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -71,13 +71,13 @@ const char *lvm_lv_get_origin(const lv_t lv)
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, NULL, NULL, NULL, name);
+	return get_property(NULL, NULL, lv, NULL, NULL, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, lvseg, NULL, NULL, name);
+	return get_property(NULL, NULL, NULL, lvseg, NULL, NULL, NULL, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
@@ -598,7 +598,7 @@ struct lvm_property_value lvm_lv_params_get_property(
 	};
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
-		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, name);
+		rc = get_property(NULL, NULL, NULL, NULL, NULL, &params->lvp, NULL, name);
 	} else {
 		log_error("Invalid lv_create_params parameter");
 	}
@@ -612,7 +612,7 @@ int lvm_lv_params_set_property(lv_create_params_t params, const char *name,
 	int rc = -1;
 
 	if (params && params->magic == LV_CREATE_PARAMS_MAGIC) {
-		rc = set_property(NULL, NULL, NULL, &params->lvp, name, prop);
+		rc = set_property(NULL, NULL, NULL, &params->lvp, NULL, name, prop);
 	} else {
 		log_error("Invalid lv_create_params parameter");
 	}
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index c79af8f..ba77010 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -51,6 +51,7 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lvseg_t lvseg,
 				       const pvseg_t pvseg,
 				       const struct lvcreate_params *lvcp,
+				       const struct pvcreate_params *pvcp,
 				       const char *name)
 {
 	struct lvm_property_type prop;
@@ -76,6 +77,9 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	} else if (lvcp) {
 		if (!lv_create_param_get_property(lvcp, &prop))
 			return v;
+	} else if (pvcp) {
+		if (!pv_create_param_get_property(pvcp, &prop))
+			return v;
 	} else {
 		log_errno(EINVAL, "Invalid NULL handle passed to library function.");
 		return v;
@@ -95,6 +99,7 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 		struct lvcreate_params *lvcp,
+		struct pvcreate_params *pvcp,
 		const char *name,
 		struct lvm_property_value *v)
 {
@@ -125,6 +130,11 @@ int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 			v->is_valid = 0;
 			return -1;
 		}
+	} else if (pvcp) {
+		if (!pv_create_param_set_property(pvcp, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
 	} else {
 		return -1;
 	}
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index a84125a..b187021 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -16,14 +16,19 @@
 
 #include "libdevmapper.h"
 #include "lvm2app.h"
+#include "metadata-exported.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const pvseg_t pvseg, const struct lvcreate_params *lvcp,
+				       const pvseg_t pvseg,
+				       const struct lvcreate_params *lvcp,
+				       const struct pvcreate_params *pvcp,
 				       const char *name);
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
-			struct lvcreate_params *lvcp, const char *name,
+			struct lvcreate_params *lvcp,
+			struct pvcreate_params *pvcp,
+			const char *name,
 			struct lvm_property_value *value);
 
 #endif
diff --git a/liblvm/lvm_prop.c b/liblvm/lvm_prop.c
index e25f03b..cbbd6f5 100644
--- a/liblvm/lvm_prop.c
+++ b/liblvm/lvm_prop.c
@@ -21,6 +21,25 @@
 GET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
 SET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
 
+/* PV create parameters */
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(size, pvcp->size)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(size, pvcp->size)
+
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatacopies, pvcp->pvmetadatacopies)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatacopies, pvcp->pvmetadatacopies)
+
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatasize, pvcp->pvmetadatasize)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(pvmetadatasize, pvcp->pvmetadatasize)
+
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment, pvcp->data_alignment)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment, pvcp->data_alignment)
+
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment_offset, pvcp->data_alignment_offset)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(data_alignment_offset, pvcp->data_alignment_offset)
+
+GET_PVCREATEPARAMS_NUM_PROPERTY_FN(zero, pvcp->zero)
+SET_PVCREATEPARAMS_NUM_PROPERTY_FN(zero, pvcp->zero)
+
 struct lvm_property_type _lib_properties[] = {
 #include "lvm_prop_fields.h"
 	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get,
@@ -42,3 +61,15 @@ int lv_create_param_set_property(struct lvcreate_params *lvcp,
 {
 	return prop_set_property(_lib_properties, lvcp, prop, LV_CREATE_PARAMS);
 }
+
+int pv_create_param_get_property(const struct pvcreate_params *pvcp,
+		struct lvm_property_type *prop)
+{
+	return prop_get_property(_lib_properties, pvcp, prop, PV_CREATE_PARAMS);
+}
+
+int pv_create_param_set_property(struct pvcreate_params *pvcp,
+		    struct lvm_property_type *prop)
+{
+	return prop_set_property(_lib_properties, pvcp, prop, PV_CREATE_PARAMS);
+}
diff --git a/liblvm/lvm_prop.h b/liblvm/lvm_prop.h
index bedc078..db4cf8a 100644
--- a/liblvm/lvm_prop.h
+++ b/liblvm/lvm_prop.h
@@ -17,8 +17,10 @@
 #define _LIB_LVM_PROP_H
 
 typedef struct lvcreate_params type_lvcreate_params;
+typedef struct pvcreate_params type_pvcreate_params;
 
 #define LV_CREATE_PARAMS 1
+#define PV_CREATE_PARAMS 2
 
 #define GET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE)\
 	GET_NUM_PROPERTY_FN(NAME, VALUE, lvcreate_params, lvcp)
@@ -26,10 +28,22 @@ typedef struct lvcreate_params type_lvcreate_params;
 #define SET_LVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE) \
 	SET_NUM_PROPERTY(NAME, VALUE, lvcreate_params, lvcp)
 
+#define GET_PVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE)\
+	GET_NUM_PROPERTY_FN(NAME, VALUE, pvcreate_params, pvcp)
+
+#define SET_PVCREATEPARAMS_NUM_PROPERTY_FN(NAME, VALUE) \
+	SET_NUM_PROPERTY(NAME, VALUE, pvcreate_params, pvcp)
+
 int lv_create_param_get_property(const struct lvcreate_params *lvcp,
 		struct lvm_property_type *prop);
 
 int lv_create_param_set_property(struct lvcreate_params *lvcp,
 		    struct lvm_property_type *prop);
 
+int pv_create_param_get_property(const struct pvcreate_params *pvcp,
+		struct lvm_property_type *prop);
+
+int pv_create_param_set_property(struct pvcreate_params *pvcp,
+		    struct lvm_property_type *prop);
+
 #endif
diff --git a/liblvm/lvm_prop_fields.h b/liblvm/lvm_prop_fields.h
index 99c322d..ba7dd18 100644
--- a/liblvm/lvm_prop_fields.h
+++ b/liblvm/lvm_prop_fields.h
@@ -13,3 +13,10 @@
  */
 
 FIELD(LV_CREATE_PARAMS, lvcreate_params, NUM, "skip_zero", zero, 2, uint32, skip_zero, "Skip zeroing on lv creation", 1)
+
+FIELD(PV_CREATE_PARAMS, pvcreate_params, NUM, "size",      size, 2, uint64_t, size, "PV size", 1)
+FIELD(PV_CREATE_PARAMS, pvcreate_params, NUM, "pvmetadatacopies", pvmetadatacopies, 2, uint64_t, pvmetadatacopies, "PV Metadata copies", 1)
+FIELD(PV_CREATE_PARAMS, pvcreate_params, NUM, "pvmetadatasize", pvmetadatasize, 2, uint64_t, pvmetadatasize, "PV Metadata size", 1)
+FIELD(PV_CREATE_PARAMS, pvcreate_params, NUM, "data_alignment", data_alignment, 2, uint64_t, data_alignment, "Start data to a multiple of value", 1)
+FIELD(PV_CREATE_PARAMS, pvcreate_params, NUM, "data_alignment_offset", data_alignment_offset, 2, uint64_t, data_alignment_offset, "Shift the start of the data area", 1)
+FIELD(PV_CREATE_PARAMS, pvcreate_params, NUM, "zero", zero, 2, uint64_t, zero, "Zero first 2048 bytes of device", 1)
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index e67e1eb..d540a6c 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -21,6 +21,16 @@
 #include "locking.h"
 #include "toolcontext.h"
 
+struct lvm_pv_create_params
+{
+	uint32_t magic;
+	lvm_t libh;
+	const char *pv_name;
+	struct pvcreate_params pv_p;
+};
+
+#define PV_CREATE_PARAMS_MAGIC 0xFEED0002
+
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
 	return pv_uuid_dup(pv);
@@ -53,13 +63,13 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, NULL, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, NULL, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, NULL, pvseg, NULL, name);
+	return get_property(NULL, NULL, NULL, NULL, pvseg, NULL, NULL, name);
 }
 
 struct lvm_list_wrapper
@@ -80,6 +90,8 @@ int lvm_pv_remove(lvm_t libh, const char *pv_name)
 	return 0;
 }
 
+#define PV_LIST_MAGIC 0xF005BA11
+
 struct dm_list *lvm_list_pvs(lvm_t libh)
 {
 	struct lvm_list_wrapper *rc = NULL;
@@ -109,7 +121,7 @@ struct dm_list *lvm_list_pvs(lvm_t libh)
 		 * pointer in the free call.
 		 */
 		rc->cmd = cmd;
-		rc->magic = 0xF005BA11;
+		rc->magic = PV_LIST_MAGIC;
 	}
 
 	return &rc->pvslist;
@@ -123,7 +135,7 @@ int lvm_list_pvs_free(struct dm_list *pvlist)
 
 	if (pvlist) {
 		to_delete = dm_list_struct_base(pvlist, struct lvm_list_wrapper, pvslist);
-		if (to_delete->magic != 0xF005BA11) {
+		if (to_delete->magic != PV_LIST_MAGIC) {
 			log_errno(EINVAL, "Not a correct pvlist structure");
 			return -1;
 		}
@@ -224,26 +236,122 @@ int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 	return 0;
 }
 
-int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
+/*
+ * Common internal code to create a parameter passing object
+ */
+static struct lvm_pv_create_params *_lvm_pv_params_create(
+		lvm_t libh,
+		const char *pv_name,
+		struct lvm_pv_create_params *pvcp_in)
 {
-	struct pvcreate_params pp;
+	struct lvm_pv_create_params *pvcp = NULL;
+	const char *dev = NULL;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
-	uint64_t size_sectors = size;
 
-	pvcreate_params_set_defaults(&pp);
+	if (!pv_name || strlen(pv_name) == 0) {
+		log_error("Invalid pv_name");
+		return NULL;
+	}
+
+	if (!pvcp_in) {
+		pvcp = dm_pool_zalloc(cmd->libmem, sizeof(struct lvm_pv_create_params));
+	} else {
+		pvcp = pvcp_in;
+	}
+
+	if (!pvcp) {
+		return NULL;
+	}
+
+	dev = dm_pool_strdup(cmd->libmem, pv_name);
+	if (!dev) {
+		return NULL;
+	}
+
+	pvcreate_params_set_defaults(&pvcp->pv_p);
+	pvcp->pv_p.yes = 1;
+	pvcp->pv_p.force = DONT_PROMPT;
+	pvcp->pv_name = dev;
+	pvcp->libh = libh;
+	pvcp->magic = PV_CREATE_PARAMS_MAGIC;
+
+	return pvcp;
+}
+
+pv_create_params_t lvm_pv_params_create(lvm_t libh, const char *pv_name)
+{
+	return _lvm_pv_params_create(libh, pv_name, NULL);
+}
 
-	if (size_sectors != 0) {
-		if (size_sectors % SECTOR_SIZE) {
+struct lvm_property_value lvm_pv_params_get_property(
+						const pv_create_params_t params,
+						const char *name)
+{
+	struct lvm_property_value rc = {
+		.is_valid = 0
+	};
+
+	if (params && params->magic == PV_CREATE_PARAMS_MAGIC) {
+		rc = get_property(NULL, NULL, NULL, NULL, NULL, NULL, &params->pv_p,
+							name);
+	} else {
+		log_error("Invalid pv_create_params parameter");
+	}
+
+	return rc;
+}
+
+int lvm_pv_params_set_property(pv_create_params_t params, const char *name,
+								struct lvm_property_value *prop)
+{
+	int rc = -1;
+
+	if (params && params->magic == PV_CREATE_PARAMS_MAGIC) {
+		rc = set_property(NULL, NULL, NULL, NULL, &params->pv_p, name, prop);
+	} else {
+		log_error("Invalid pv_create_params parameter");
+	}
+	return rc;
+}
+
+static int _pv_create(pv_create_params_t params)
+{
+	struct cmd_context *cmd = (struct cmd_context *)params->libh;
+
+	if (params->pv_p.size) {
+		if (params->pv_p.size % SECTOR_SIZE) {
 			log_errno(EINVAL, "Size not a multiple of 512");
 			return -1;
 		}
-		size_sectors = size_sectors >> SECTOR_SHIFT;
+		params->pv_p.size = params->pv_p.size >> SECTOR_SHIFT;
 	}
 
-	pp.size = size_sectors;
+	if (!pvcreate_single(cmd, params->pv_name, &params->pv_p))
+		return -1;
+	return 0;
+}
+
+int lvm_pv_create(lvm_t libh, const char *pv_name, uint64_t size)
+{
+	struct lvm_pv_create_params pp;
 
-	if (!pvcreate_single(cmd, pv_name, &pp))
+	if (!_lvm_pv_params_create(libh, pv_name, &pp))
 		return -1;
 
-	return 0;
+	pp.pv_p.size = size;
+
+	return _pv_create(&pp);
+}
+
+int lvm_pv_create_adv(pv_create_params_t params)
+{
+	int rc = -1;
+
+	if (params && params->magic == PV_CREATE_PARAMS_MAGIC) {
+		rc = _pv_create(params);
+	} else {
+		log_error("Invalid pv_create_params parameter");
+	}
+
+	return rc;
 }
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 3f4968e..214f459 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -340,7 +340,7 @@ const char *lvm_vg_get_name(const vg_t vg)
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, NULL, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, NULL, NULL, NULL, name);
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,
@@ -357,7 +357,7 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 				strlen(value->value.string) + 1);
 	}
 
-	return set_property(NULL, vg, NULL, NULL, name, value);
+	return set_property(NULL, vg, NULL, NULL, NULL, name, value);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
diff --git a/tools/toollib.c b/tools/toollib.c
index 9b3e842..ae91df2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1523,12 +1523,6 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, pvmetadatacopies_ARG) &&
-	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
-		return 0;
-	}
-
 	if (arg_count(cmd, metadataignore_ARG))
 		pp->metadataignore = arg_int_value(cmd, metadataignore_ARG,
 						   DEFAULT_PVMETADATAIGNORE);
-- 
1.8.2.1


