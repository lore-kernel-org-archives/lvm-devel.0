From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:09:46 -0000
Subject: LVM2/lib/report properties.c properties.h
Message-ID: <20100930140946.18705.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:09:46

Modified files:
	lib/report     : properties.c properties.h 

Log message:
	Add pv_get_property and create generic internal _get_property function.
	
	We need to use a similar function for pv and lv properties, so just make
	a generic _get_property() function that contains most of the required
	functionality.  Also, add a check to ensure the field name matches the
	object passed in by re-using report_type_t enum.  For pv properties,
	the report_type might be either PVS or LABEL.
	
	In addition, add 'const' to 'get' functions object parameter, but not
	'set' functions.  Add _not_implemented_set() and _not_implemented_get()
	functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/report/properties.c	2010/09/30 14:09:33	1.7
+++ LVM2/lib/report/properties.c	2010/09/30 14:09:45	1.8
@@ -21,9 +21,9 @@
 #include "metadata.h"
 
 #define GET_NUM_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
-static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
+static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
-	struct TYPE *VAR = (struct TYPE *)obj; \
+	const struct TYPE *VAR = (const struct TYPE *)obj; \
 \
 	prop->v.n_val = VALUE; \
 	return 1; \
@@ -36,9 +36,9 @@
 	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
-static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
+static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
-	struct TYPE *VAR = (struct TYPE *)obj; \
+	const struct TYPE *VAR = (const struct TYPE *)obj; \
 \
 	prop->v.s_val = (char *)VALUE;	\
 	return 1; \
@@ -50,7 +50,13 @@
 #define GET_LV_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 
-static int _not_implemented(void *obj, struct lvm_property_type *prop)
+static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
+{
+	log_errno(ENOSYS, "Function not implemented");
+	return 0;
+}
+
+static int _not_implemented_set(void *obj, struct lvm_property_type *prop)
 {
 	log_errno(ENOSYS, "Function not implemented");
 	return 0;
@@ -58,174 +64,174 @@
 
 /* PV */
 GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
-#define _pv_fmt_set _not_implemented
+#define _pv_fmt_set _not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_uuid, pv_uuid_dup(pv))
-#define _pv_uuid_set _not_implemented
+#define _pv_uuid_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(dev_size, SECTOR_SIZE * pv_dev_size(pv))
-#define _dev_size_set _not_implemented
+#define _dev_size_set _not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_name, pv_name_dup(pv))
-#define _pv_name_set _not_implemented
+#define _pv_name_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_free, SECTOR_SIZE * pv_mda_free(pv))
-#define _pv_mda_free_set _not_implemented
+#define _pv_mda_free_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_size, SECTOR_SIZE * pv_mda_size(pv))
-#define _pv_mda_size_set _not_implemented
+#define _pv_mda_size_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pe_start, SECTOR_SIZE * pv->pe_start)
-#define _pe_start_set _not_implemented
+#define _pe_start_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_size, SECTOR_SIZE * pv_size_field(pv))
-#define _pv_size_set _not_implemented
+#define _pv_size_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_free, SECTOR_SIZE * pv_free(pv))
-#define _pv_free_set _not_implemented
+#define _pv_free_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_used, SECTOR_SIZE * pv_used(pv))
-#define _pv_used_set _not_implemented
+#define _pv_used_set _not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_attr, pv_attr_dup(pv->vg->vgmem, pv))
-#define _pv_attr_set _not_implemented
+#define _pv_attr_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_pe_count, pv->pe_count)
-#define _pv_pe_count_set _not_implemented
+#define _pv_pe_count_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_pe_alloc_count, pv->pe_alloc_count)
-#define _pv_pe_alloc_count_set _not_implemented
+#define _pv_pe_alloc_count_set _not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_tags, pv_tags_dup(pv))
-#define _pv_tags_set _not_implemented
+#define _pv_tags_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
-#define _pv_mda_count_set _not_implemented
+#define _pv_mda_count_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
-#define _pv_mda_used_count_set _not_implemented
+#define _pv_mda_used_count_set _not_implemented_set
 
 /* LV */
-#define _lv_uuid_get _not_implemented
-#define _lv_uuid_set _not_implemented
-#define _lv_name_get _not_implemented
-#define _lv_name_set _not_implemented
-#define _lv_path_get _not_implemented
-#define _lv_path_set _not_implemented
-#define _lv_attr_get _not_implemented
-#define _lv_attr_set _not_implemented
-#define _lv_major_get _not_implemented
-#define _lv_major_set _not_implemented
-#define _lv_minor_get _not_implemented
-#define _lv_minor_set _not_implemented
-#define _lv_read_ahead_get _not_implemented
-#define _lv_read_ahead_set _not_implemented
-#define _lv_kernel_major_get _not_implemented
-#define _lv_kernel_major_set _not_implemented
-#define _lv_kernel_minor_get _not_implemented
-#define _lv_kernel_minor_set _not_implemented
-#define _lv_kernel_read_ahead_get _not_implemented
-#define _lv_kernel_read_ahead_set _not_implemented
-#define _lv_size_get _not_implemented
-#define _lv_size_set _not_implemented
-#define _seg_count_get _not_implemented
-#define _seg_count_set _not_implemented
-#define _origin_get _not_implemented
-#define _origin_set _not_implemented
-#define _origin_size_get _not_implemented
-#define _origin_size_set _not_implemented
-#define _snap_percent_get _not_implemented
-#define _snap_percent_set _not_implemented
-#define _copy_percent_get _not_implemented
-#define _copy_percent_set _not_implemented
-#define _move_pv_get _not_implemented
-#define _move_pv_set _not_implemented
-#define _convert_lv_get _not_implemented
-#define _convert_lv_set _not_implemented
-#define _lv_tags_get _not_implemented
-#define _lv_tags_set _not_implemented
-#define _mirror_log_get _not_implemented
-#define _mirror_log_set _not_implemented
-#define _modules_get _not_implemented
-#define _modules_set _not_implemented
+#define _lv_uuid_get _not_implemented_get
+#define _lv_uuid_set _not_implemented_set
+#define _lv_name_get _not_implemented_get
+#define _lv_name_set _not_implemented_set
+#define _lv_path_get _not_implemented_get
+#define _lv_path_set _not_implemented_set
+#define _lv_attr_get _not_implemented_get
+#define _lv_attr_set _not_implemented_set
+#define _lv_major_get _not_implemented_get
+#define _lv_major_set _not_implemented_set
+#define _lv_minor_get _not_implemented_get
+#define _lv_minor_set _not_implemented_set
+#define _lv_read_ahead_get _not_implemented_get
+#define _lv_read_ahead_set _not_implemented_set
+#define _lv_kernel_major_get _not_implemented_get
+#define _lv_kernel_major_set _not_implemented_set
+#define _lv_kernel_minor_get _not_implemented_get
+#define _lv_kernel_minor_set _not_implemented_set
+#define _lv_kernel_read_ahead_get _not_implemented_get
+#define _lv_kernel_read_ahead_set _not_implemented_set
+#define _lv_size_get _not_implemented_get
+#define _lv_size_set _not_implemented_set
+#define _seg_count_get _not_implemented_get
+#define _seg_count_set _not_implemented_set
+#define _origin_get _not_implemented_get
+#define _origin_set _not_implemented_set
+#define _origin_size_get _not_implemented_get
+#define _origin_size_set _not_implemented_set
+#define _snap_percent_get _not_implemented_get
+#define _snap_percent_set _not_implemented_set
+#define _copy_percent_get _not_implemented_get
+#define _copy_percent_set _not_implemented_set
+#define _move_pv_get _not_implemented_get
+#define _move_pv_set _not_implemented_set
+#define _convert_lv_get _not_implemented_get
+#define _convert_lv_set _not_implemented_set
+#define _lv_tags_get _not_implemented_get
+#define _lv_tags_set _not_implemented_set
+#define _mirror_log_get _not_implemented_get
+#define _mirror_log_set _not_implemented_set
+#define _modules_get _not_implemented_get
+#define _modules_set _not_implemented_set
 
 /* VG */
 GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
-#define _vg_fmt_set _not_implemented
+#define _vg_fmt_set _not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_uuid, vg_uuid_dup(vg))
-#define _vg_uuid_set _not_implemented
+#define _vg_uuid_set _not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_name, vg_name_dup(vg))
-#define _vg_name_set _not_implemented
+#define _vg_name_set _not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_attr, vg_attr_dup(vg->vgmem, vg))
-#define _vg_attr_set _not_implemented
+#define _vg_attr_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
-#define _vg_size_set _not_implemented
+#define _vg_size_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
-#define _vg_free_set _not_implemented
+#define _vg_free_set _not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
-#define _vg_sysid_set _not_implemented
+#define _vg_sysid_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
-#define _vg_extent_size_set _not_implemented
+#define _vg_extent_size_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
-#define _vg_extent_count_set _not_implemented
+#define _vg_extent_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_free_count, vg->free_count)
-#define _vg_free_count_set _not_implemented
+#define _vg_free_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(max_lv, vg->max_lv)
-#define _max_lv_set _not_implemented
+#define _max_lv_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(max_pv, vg->max_pv)
-#define _max_pv_set _not_implemented
+#define _max_pv_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(pv_count, vg->pv_count)
-#define _pv_count_set _not_implemented
+#define _pv_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(lv_count, (vg_visible_lvs(vg)))
-#define _lv_count_set _not_implemented
+#define _lv_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(snap_count, (snapshot_count(vg)))
-#define _snap_count_set _not_implemented
+#define _snap_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
-#define _vg_seqno_set _not_implemented
+#define _vg_seqno_set _not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_tags, vg_tags_dup(vg))
-#define _vg_tags_set _not_implemented
+#define _vg_tags_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
-#define _vg_mda_count_set _not_implemented
+#define _vg_mda_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
-#define _vg_mda_used_count_set _not_implemented
+#define _vg_mda_used_count_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
-#define _vg_mda_free_set _not_implemented
+#define _vg_mda_free_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
-#define _vg_mda_size_set _not_implemented
+#define _vg_mda_size_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
-#define _vg_mda_copies_set _not_implemented
+#define _vg_mda_copies_set _not_implemented_set
 
 /* LVSEG */
-#define _segtype_get _not_implemented
-#define _segtype_set _not_implemented
-#define _stripes_get _not_implemented
-#define _stripes_set _not_implemented
-#define _stripesize_get _not_implemented
-#define _stripesize_set _not_implemented
-#define _stripe_size_get _not_implemented
-#define _stripe_size_set _not_implemented
-#define _regionsize_get _not_implemented
-#define _regionsize_set _not_implemented
-#define _region_size_get _not_implemented
-#define _region_size_set _not_implemented
-#define _chunksize_get _not_implemented
-#define _chunksize_set _not_implemented
-#define _chunk_size_get _not_implemented
-#define _chunk_size_set _not_implemented
-#define _seg_start_get _not_implemented
-#define _seg_start_set _not_implemented
-#define _seg_start_pe_get _not_implemented
-#define _seg_start_pe_set _not_implemented
-#define _seg_size_get _not_implemented
-#define _seg_size_set _not_implemented
-#define _seg_tags_get _not_implemented
-#define _seg_tags_set _not_implemented
-#define _seg_pe_ranges_get _not_implemented
-#define _seg_pe_ranges_set _not_implemented
-#define _devices_get _not_implemented
-#define _devices_set _not_implemented
+#define _segtype_get _not_implemented_get
+#define _segtype_set _not_implemented_set
+#define _stripes_get _not_implemented_get
+#define _stripes_set _not_implemented_set
+#define _stripesize_get _not_implemented_get
+#define _stripesize_set _not_implemented_set
+#define _stripe_size_get _not_implemented_get
+#define _stripe_size_set _not_implemented_set
+#define _regionsize_get _not_implemented_get
+#define _regionsize_set _not_implemented_set
+#define _region_size_get _not_implemented_get
+#define _region_size_set _not_implemented_set
+#define _chunksize_get _not_implemented_get
+#define _chunksize_set _not_implemented_set
+#define _chunk_size_get _not_implemented_get
+#define _chunk_size_set _not_implemented_set
+#define _seg_start_get _not_implemented_get
+#define _seg_start_set _not_implemented_set
+#define _seg_start_pe_get _not_implemented_get
+#define _seg_start_pe_set _not_implemented_set
+#define _seg_size_get _not_implemented_get
+#define _seg_size_set _not_implemented_set
+#define _seg_tags_get _not_implemented_get
+#define _seg_tags_set _not_implemented_set
+#define _seg_pe_ranges_get _not_implemented_get
+#define _seg_pe_ranges_set _not_implemented_set
+#define _devices_get _not_implemented_get
+#define _devices_set _not_implemented_set
 
 
 /* PVSEG */
-#define _pvseg_start_get _not_implemented
-#define _pvseg_start_set _not_implemented
-#define _pvseg_size_get _not_implemented
-#define _pvseg_size_set _not_implemented
+#define _pvseg_start_get _not_implemented_get
+#define _pvseg_start_set _not_implemented_set
+#define _pvseg_size_get _not_implemented_get
+#define _pvseg_size_set _not_implemented_set
 
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, writeable) \
-	{ #id, writeable, sorttype == STR, { .n_val = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, writeable, sorttype == STR, { .n_val = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ "", 0, 0, { .n_val = 0 }, _not_implemented, _not_implemented },
+	{ 0, "", 0, 0, { .n_val = 0 }, _not_implemented_get, _not_implemented_set },
 };
 
 #undef STR
@@ -233,7 +239,8 @@
 #undef FIELD
 
 
-int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
+static int _get_property(const void *obj, struct lvm_property_type *prop,
+			 report_type_t type)
 {
 	struct lvm_property_type *p;
 
@@ -247,10 +254,27 @@
 		log_errno(EINVAL, "Invalid property name %s", prop->id);
 		return 0;
 	}
+	if (!(p->type & type)) {
+		log_errno(EINVAL, "Property name %s does not match type %d",
+			  prop->id, p->type);
+		return 0;
+	}
 
 	*prop = *p;
-	if (!p->get((void *)vg, prop)) {
+	if (!p->get(obj, prop)) {
 		return 0;
 	}
 	return 1;
 }
+
+int vg_get_property(const struct volume_group *vg,
+		    struct lvm_property_type *prop)
+{
+	return _get_property(vg, prop, VGS);
+}
+
+int pv_get_property(const struct physical_volume *pv,
+		    struct lvm_property_type *prop)
+{
+	return _get_property(pv, prop, PVS | LABEL);
+}
--- LVM2/lib/report/properties.h	2010/08/20 12:44:58	1.1
+++ LVM2/lib/report/properties.h	2010/09/30 14:09:45	1.2
@@ -17,10 +17,12 @@
 #include "libdevmapper.h"
 #include "lvm-types.h"
 #include "metadata.h"
+#include "report.h"
 
 #define LVM_PROPERTY_NAME_LEN DM_REPORT_FIELD_TYPE_ID_LEN
 
 struct lvm_property_type {
+	report_type_t type;
 	char id[LVM_PROPERTY_NAME_LEN];
 	unsigned is_writeable;
 	unsigned is_string;
@@ -28,10 +30,13 @@
 		char *s_val;
 		uint64_t n_val;
 	} v;
-	int (*get) (void *obj, struct lvm_property_type *prop);
+	int (*get) (const void *obj, struct lvm_property_type *prop);
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
-int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
+int vg_get_property(const struct volume_group *vg,
+		    struct lvm_property_type *prop);
+int pv_get_property(const struct physical_volume *pv,
+		    struct lvm_property_type *prop);
 
 #endif


