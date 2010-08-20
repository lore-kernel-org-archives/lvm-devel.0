From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 12:44:59 -0000
Subject: LVM2/lib/report properties.c properties.h
Message-ID: <20100820124459.26519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 12:44:59

Added files:
	lib/report     : properties.c properties.h 

Log message:
	Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/lib/report/properties.c,v  -->  standard output
revision 1.1
--- LVM2/lib/report/properties.c
+++ -	2010-08-20 12:44:59.192173000 +0000
@@ -0,0 +1,226 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <errno.h>
+
+#include "libdevmapper.h"
+#include "properties.h"
+#include "lvm-logging.h"
+#include "lvm-types.h"
+#include "metadata.h"
+
+static int _not_implemented(void *obj, struct lvm_property_type *prop)
+{
+	log_errno(ENOSYS, "Function not implemented");
+	return 0;
+}
+
+/* PV */
+#define _pv_fmt_get _not_implemented
+#define _pv_fmt_set _not_implemented
+#define _pv_uuid_get _not_implemented
+#define _pv_uuid_set _not_implemented
+#define _dev_size_get _not_implemented
+#define _dev_size_set _not_implemented
+#define _pv_name_get _not_implemented
+#define _pv_name_set _not_implemented
+#define _pv_mda_free_get _not_implemented
+#define _pv_mda_free_set _not_implemented
+#define _pv_mda_size_get _not_implemented
+#define _pv_mda_size_set _not_implemented
+#define _pe_start_get _not_implemented
+#define _pe_start_set _not_implemented
+#define _pv_size_get _not_implemented
+#define _pv_size_set _not_implemented
+#define _pv_free_get _not_implemented
+#define _pv_free_set _not_implemented
+#define _pv_used_get _not_implemented
+#define _pv_used_set _not_implemented
+#define _pv_attr_get _not_implemented
+#define _pv_attr_set _not_implemented
+#define _pv_pe_count_get _not_implemented
+#define _pv_pe_count_set _not_implemented
+#define _pv_pe_alloc_count_get _not_implemented
+#define _pv_pe_alloc_count_set _not_implemented
+#define _pv_tags_get _not_implemented
+#define _pv_tags_set _not_implemented
+#define _pv_mda_count_get _not_implemented
+#define _pv_mda_count_set _not_implemented
+#define _pv_mda_used_count_get _not_implemented
+#define _pv_mda_used_count_set _not_implemented
+
+/* LV */
+#define _lv_uuid_get _not_implemented
+#define _lv_uuid_set _not_implemented
+#define _lv_name_get _not_implemented
+#define _lv_name_set _not_implemented
+#define _lv_path_get _not_implemented
+#define _lv_path_set _not_implemented
+#define _lv_attr_get _not_implemented
+#define _lv_attr_set _not_implemented
+#define _lv_major_get _not_implemented
+#define _lv_major_set _not_implemented
+#define _lv_minor_get _not_implemented
+#define _lv_minor_set _not_implemented
+#define _lv_read_ahead_get _not_implemented
+#define _lv_read_ahead_set _not_implemented
+#define _lv_kernel_major_get _not_implemented
+#define _lv_kernel_major_set _not_implemented
+#define _lv_kernel_minor_get _not_implemented
+#define _lv_kernel_minor_set _not_implemented
+#define _lv_kernel_read_ahead_get _not_implemented
+#define _lv_kernel_read_ahead_set _not_implemented
+#define _lv_size_get _not_implemented
+#define _lv_size_set _not_implemented
+#define _seg_count_get _not_implemented
+#define _seg_count_set _not_implemented
+#define _origin_get _not_implemented
+#define _origin_set _not_implemented
+#define _origin_size_get _not_implemented
+#define _origin_size_set _not_implemented
+#define _snap_percent_get _not_implemented
+#define _snap_percent_set _not_implemented
+#define _copy_percent_get _not_implemented
+#define _copy_percent_set _not_implemented
+#define _move_pv_get _not_implemented
+#define _move_pv_set _not_implemented
+#define _convert_lv_get _not_implemented
+#define _convert_lv_set _not_implemented
+#define _lv_tags_get _not_implemented
+#define _lv_tags_set _not_implemented
+#define _mirror_log_get _not_implemented
+#define _mirror_log_set _not_implemented
+#define _modules_get _not_implemented
+#define _modules_set _not_implemented
+
+/* VG */
+#define _vg_fmt_get _not_implemented
+#define _vg_fmt_set _not_implemented
+#define _vg_uuid_get _not_implemented
+#define _vg_uuid_set _not_implemented
+#define _vg_name_get _not_implemented
+#define _vg_name_set _not_implemented
+#define _vg_attr_get _not_implemented
+#define _vg_attr_set _not_implemented
+#define _vg_size_get _not_implemented
+#define _vg_size_set _not_implemented
+#define _vg_free_get _not_implemented
+#define _vg_free_set _not_implemented
+#define _vg_sysid_get _not_implemented
+#define _vg_sysid_set _not_implemented
+#define _vg_extent_size_get _not_implemented
+#define _vg_extent_size_set _not_implemented
+#define _vg_extent_count_get _not_implemented
+#define _vg_extent_count_set _not_implemented
+#define _vg_free_count_get _not_implemented
+#define _vg_free_count_set _not_implemented
+#define _max_lv_get _not_implemented
+#define _max_lv_set _not_implemented
+#define _max_pv_get _not_implemented
+#define _max_pv_set _not_implemented
+#define _pv_count_get _not_implemented
+#define _pv_count_set _not_implemented
+#define _lv_count_get _not_implemented
+#define _lv_count_set _not_implemented
+#define _snap_count_get _not_implemented
+#define _snap_count_set _not_implemented
+#define _vg_seqno_get _not_implemented
+#define _vg_seqno_set _not_implemented
+#define _vg_tags_get _not_implemented
+#define _vg_tags_set _not_implemented
+#define _vg_mda_count_get _not_implemented
+#define _vg_mda_count_set _not_implemented
+#define _vg_mda_used_count_get _not_implemented
+#define _vg_mda_used_count_set _not_implemented
+#define _vg_mda_free_get _not_implemented
+#define _vg_mda_free_set _not_implemented
+#define _vg_mda_size_get _not_implemented
+#define _vg_mda_size_set _not_implemented
+#define _vg_mda_copies_get _not_implemented
+#define _vg_mda_copies_set _not_implemented
+
+/* LVSEG */
+#define _segtype_get _not_implemented
+#define _segtype_set _not_implemented
+#define _stripes_get _not_implemented
+#define _stripes_set _not_implemented
+#define _stripesize_get _not_implemented
+#define _stripesize_set _not_implemented
+#define _stripe_size_get _not_implemented
+#define _stripe_size_set _not_implemented
+#define _regionsize_get _not_implemented
+#define _regionsize_set _not_implemented
+#define _region_size_get _not_implemented
+#define _region_size_set _not_implemented
+#define _chunksize_get _not_implemented
+#define _chunksize_set _not_implemented
+#define _chunk_size_get _not_implemented
+#define _chunk_size_set _not_implemented
+#define _seg_start_get _not_implemented
+#define _seg_start_set _not_implemented
+#define _seg_start_pe_get _not_implemented
+#define _seg_start_pe_set _not_implemented
+#define _seg_size_get _not_implemented
+#define _seg_size_set _not_implemented
+#define _seg_tags_get _not_implemented
+#define _seg_tags_set _not_implemented
+#define _seg_pe_ranges_get _not_implemented
+#define _seg_pe_ranges_set _not_implemented
+#define _devices_get _not_implemented
+#define _devices_set _not_implemented
+
+
+/* PVSEG */
+#define _pvseg_start_get _not_implemented
+#define _pvseg_start_set _not_implemented
+#define _pvseg_size_get _not_implemented
+#define _pvseg_size_set _not_implemented
+
+
+#define STR DM_REPORT_FIELD_TYPE_STRING
+#define NUM DM_REPORT_FIELD_TYPE_NUMBER
+#define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, writeable) \
+	{ #id, writeable, sorttype == STR, { .n_val = 0 }, _ ## id ## _get, _ ## id ## _set },
+
+struct lvm_property_type _properties[] = {
+#include "columns.h"
+	{ "", 0, 0, { .n_val = 0 }, _not_implemented, _not_implemented },
+};
+
+#undef STR
+#undef NUM
+#undef FIELD
+
+
+int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop)
+{
+	struct lvm_property_type *p;
+
+	p = _properties;
+	while (p->id[0]) {
+		if (!strcmp(p->id, prop->id))
+			break;
+		p++;
+	}
+	if (!p->id[0]) {
+		log_errno(EINVAL, "Invalid property name %s", prop->id);
+		return 0;
+	}
+
+	*prop = *p;
+	if (!p->get((void *)vg, prop)) {
+		return 0;
+	}
+	return 1;
+}
/cvs/lvm2/LVM2/lib/report/properties.h,v  -->  standard output
revision 1.1
--- LVM2/lib/report/properties.h
+++ -	2010-08-20 12:44:59.278643000 +0000
@@ -0,0 +1,37 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef _LVM_PROPERTIES_H
+#define _LVM_PROPERTIES_H
+
+#include "libdevmapper.h"
+#include "lvm-types.h"
+#include "metadata.h"
+
+#define LVM_PROPERTY_NAME_LEN DM_REPORT_FIELD_TYPE_ID_LEN
+
+struct lvm_property_type {
+	char id[LVM_PROPERTY_NAME_LEN];
+	unsigned is_writeable;
+	unsigned is_string;
+	union {
+		char *s_val;
+		uint64_t n_val;
+	} v;
+	int (*get) (void *obj, struct lvm_property_type *prop);
+	int (*set) (void *obj, struct lvm_property_type *prop);
+};
+
+int vg_get_property(struct volume_group *vg, struct lvm_property_type *prop);
+
+#endif


