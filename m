From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 12 Jul 2013 21:52:49 +0000 (UTC)
Subject: master - lib/properties: Common code for handling properties.
Message-ID: <20130712215249.83A4B6155A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9775a19af1f2a93d5550f4ff5843e3ac8e556eb1
Commit:        9775a19af1f2a93d5550f4ff5843e3ac8e556eb1
Parent:        bdd2246ce91d8b8c050ad7a2b52e32489262c4b3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jul 12 13:09:44 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jul 12 16:52:16 2013 -0500

lib/properties: Common code for handling properties.

The common bits from lib/report/properties.[c|h] have
been moved to lib/properties/prop_common.[c|h] to allow
re-use of property handling functionality without
polluting the report handling functionality.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 include/.symlinks.in         |    1 +
 lib/Makefile.in              |    3 +-
 lib/properties/prop_common.c |   92 ++++++++++++
 lib/properties/prop_common.h |  121 +++++++++++++++
 lib/report/columns.h         |   43 +------
 lib/report/properties.c      |  331 ++++++++++++++----------------------------
 lib/report/properties.h      |   17 +--
 7 files changed, 329 insertions(+), 279 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 7fdc045..0fdcdb0 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -58,6 +58,7 @@
 @top_srcdir@/lib/misc/lvm-wrappers.h
 @top_srcdir@/lib/misc/lvm-percent.h
 @top_srcdir@/lib/misc/sharedlib.h
+ at top_srcdir@/lib/properties/prop_common.h
 @top_srcdir@/lib/report/properties.h
 @top_srcdir@/lib/report/report.h
 @top_srcdir@/lib/uuid/uuid.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index d789839..a58605c 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -104,6 +104,7 @@ SOURCES =\
 	misc/lvm-wrappers.c \
 	misc/lvm-percent.c \
 	mm/memlock.c \
+	properties/prop_common.c \
 	report/properties.c \
 	report/report.c \
 	striped/striped.c \
diff --git a/lib/properties/prop_common.c b/lib/properties/prop_common.c
new file mode 100644
index 0000000..25888f9
--- /dev/null
+++ b/lib/properties/prop_common.c
@@ -0,0 +1,92 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+#include "lib.h"
+#include "prop_common.h"
+
+int prop_not_implemented_get(const void *obj, struct lvm_property_type *prop)
+{
+	log_errno(ENOSYS, "Function not implemented");
+
+	return 0;
+}
+
+int prop_not_implemented_set(void *obj, struct lvm_property_type *prop)
+{
+	log_errno(ENOSYS, "Function not implemented");
+
+	return 0;
+}
+
+int prop_get_property(struct lvm_property_type *p, const void *obj,
+		struct lvm_property_type *prop,
+		unsigned type)
+{
+	while (p->id[0]) {
+		if (!strcmp(p->id, prop->id))
+			break;
+		p++;
+	}
+	if (!p->id[0]) {
+		log_errno(EINVAL, "Invalid property name %s", prop->id);
+		return 0;
+	}
+	if (!(p->type & type)) {
+		log_errno(EINVAL, "Property name %s does not match type %d",
+			  prop->id, p->type);
+		return 0;
+	}
+
+	*prop = *p;
+	if (!p->get(obj, prop)) {
+		return 0;
+	}
+
+	return 1;
+}
+
+int prop_set_property(struct lvm_property_type *p, void *obj,
+		struct lvm_property_type *prop,
+		unsigned type)
+{
+	while (p->id[0]) {
+		if (!strcmp(p->id, prop->id))
+			break;
+		p++;
+	}
+	if (!p->id[0]) {
+		log_errno(EINVAL, "Invalid property name %s", prop->id);
+		return 0;
+	}
+	if (!p->is_settable) {
+		log_errno(EINVAL, "Unable to set read-only property %s",
+			  prop->id);
+		return 0;
+	}
+	if (!(p->type & type)) {
+		log_errno(EINVAL, "Property name %s does not match type %d",
+			  prop->id, p->type);
+		return 0;
+	}
+
+	if (p->is_string)
+		p->value.string = prop->value.string;
+	else
+		p->value.integer = prop->value.integer;
+	if (!p->set(obj, p)) {
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/lib/properties/prop_common.h b/lib/properties/prop_common.h
new file mode 100644
index 0000000..a39f2f1
--- /dev/null
+++ b/lib/properties/prop_common.h
@@ -0,0 +1,121 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+#ifndef _LVM_PROP_COMMON_H
+#define _LVM_PROP_COMMON_H
+
+#include <stdint.h>
+
+/*
+ * Common code for getting and setting properties.
+ */
+
+struct lvm_property_type {
+	unsigned type;
+	const char *id;
+	unsigned is_settable:1;
+	unsigned is_string:1;
+	unsigned is_integer:1;
+	union {
+		const char *string;
+		uint64_t integer;
+	} value;
+	int (*get) (const void *obj, struct lvm_property_type *prop);
+	int (*set) (void *obj, struct lvm_property_type *prop);
+};
+
+int prop_not_implemented_get(const void *obj, struct lvm_property_type *prop);
+int prop_not_implemented_set(void *obj, struct lvm_property_type *prop);
+
+int prop_get_property(struct lvm_property_type *p, const void *obj,
+		struct lvm_property_type *prop,
+		unsigned type);
+int prop_set_property(struct lvm_property_type *p, void *obj,
+		struct lvm_property_type *prop,
+		unsigned type);
+
+#define GET_NUM_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
+static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
+{ \
+	const struct TYPE *VAR = (const struct TYPE *)obj; \
+\
+	prop->value.integer = VALUE; \
+	return 1; \
+}
+
+#define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
+static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct TYPE *VAR = (struct TYPE *)obj; \
+\
+	SETFN(VAR, prop->value.integer);		\
+	return 1; \
+}
+
+#define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
+static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
+{ \
+	const struct TYPE *VAR = (const struct TYPE *)obj; \
+\
+	prop->value.string = (char *)VALUE;	\
+	return 1; \
+}
+
+/*
+ * The 'FIELD' macro arguments are defined as follows:
+ * 1. report_type.  An enum value that selects a specific
+ * struct dm_report_object_type in the _report_types array.  The value is
+ * used to select the containing base object address (see *obj_get*
+ * functions) for any data values of any field in the report.
+ * 2. Containing struct.  The structure that either contains the field data
+ * as a member or should be used to obtain the field data.  The containing
+ * struct should match the base object of the report_type.
+ * 3. Field type.  This must be either 'STR' or 'NUM'.
+ * 4. Report heading.  This is the field heading that is displayed by the
+ * reporting commands.
+ * 5. Data value pointer.  This argument is always a member of the
+ * containing struct.  It may point directly to the data value (for example,
+ * lv_uuid - see _uuid_disp()) or may be used to derive the data value (for
+ * example, seg_count - see _lvsegcount_disp()).  In the FIELD macro
+ * definition, it is used in an offset calculation to derive the offset to
+ * the data value from the containing struct base address.  Note that in some
+ * cases, the argument is the first member of the struct, in which case the
+ * data value pointer points to the start of the struct itself (for example,
+ * 'lvid' field of struct 'lv').
+ * 6. Minimum display width.  This is the minimum width used to display
+ * the field value, typically matching the width of the column heading.
+ * 7. Display function identifier.  Used to derive the full name of the
+ * function that displays this field.  Derivation is done by appending '_'
+ * then prepending this argument to '_disp'.  For example, if this argument
+ * is 'uuid', the display function is _uuid_disp().  Adding a new field may
+ * require defining a new display function (for example _myfieldname_disp()),
+ * or re-use of an existing one (for example, _uint32_disp()).
+ * 8. Unique format identifier / field id.  This name must be unique and is
+ * used to select fields via '-o' in the reporting commands (pvs/vgs/lvs).
+ * The string used to specify the field - the 'id' member of
+ * struct dm_report_field_type.
+ * 9. Description of field.  This is a brief (ideally <= 52 chars) description
+ * of the field used in the reporting commands.
+ * 10. Flags.
+ *     FIELD_MODIFIABLE.  A '_set' function exists to change the field's value.
+ *     The function name is derived in a similar way to item 7 above.
+ */
+
+#define STR 1
+#define NUM 2
+
+#define FIELD_MODIFIABLE 0x00000001
+#define FIELD(type, strct, field_type, head, field, width, fn, id, desc, settable) \
+	{ type, #id, settable, field_type == STR, field_type == NUM, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+
+#endif
diff --git a/lib/report/columns.h b/lib/report/columns.h
index d13d19a..4c0bca2 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,47 +17,6 @@
  * This file defines the fields (columns) for the reporting commands
  * (pvs/vgs/lvs).
  */
-/*
- * The 'FIELD' macro arguments are defined as follows:
- * 1. report_type.  An enum value that selects a specific
- * struct dm_report_object_type in the _report_types array.  The value is
- * used to select the containing base object address (see *obj_get*
- * functions) for any data values of any field in the report.
- * 2. Containing struct.  The structure that either contains the field data
- * as a member or should be used to obtain the field data.  The containing
- * struct should match the base object of the report_type.
- * 3. Field type.  This must be either 'STR' or 'NUM'.
- * 4. Report heading.  This is the field heading that is displayed by the
- * reporting commands.
- * 5. Data value pointer.  This argument is always a member of the
- * containing struct.  It may point directly to the data value (for example,
- * lv_uuid - see _uuid_disp()) or may be used to derive the data value (for
- * example, seg_count - see _lvsegcount_disp()).  In the FIELD macro
- * definition, it is used in an offset calculation to derive the offset to
- * the data value from the containing struct base address.  Note that in some
- * cases, the argument is the first member of the struct, in which case the
- * data value pointer points to the start of the struct itself (for example,
- * 'lvid' field of struct 'lv').
- * 6. Minimum display width.  This is the minimum width used to display
- * the field value, typically matching the width of the column heading.
- * 7. Display function identifier.  Used to derive the full name of the
- * function that displays this field.  Derivation is done by appending '_'
- * then prepending this argument to '_disp'.  For example, if this argument
- * is 'uuid', the display function is _uuid_disp().  Adding a new field may
- * require defining a new display function (for example _myfieldname_disp()),
- * or re-use of an existing one (for example, _uint32_disp()).
- * 8. Unique format identifier / field id.  This name must be unique and is
- * used to select fields via '-o' in the reporting commands (pvs/vgs/lvs).
- * The string used to specify the field - the 'id' member of
- * struct dm_report_field_type.
- * 9. Description of field.  This is a brief (ideally <= 52 chars) description
- * of the field used in the reporting commands.
- * 10. Flags.
- *     FIELD_MODIFIABLE.  A '_set' function exists to change the field's value.
- *     The function name is derived in a similar way to item 7 above.
- */
-
-#define FIELD_MODIFIABLE 0x00000001
 
 /* *INDENT-OFF* */
 FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, lv_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c7194c5..a4832af 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -12,23 +12,13 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include <errno.h>
-
-#include "libdevmapper.h"
+#include "lib.h"
 #include "properties.h"
 #include "activate.h"
-#include "lvm-logging.h"
 #include "lvm-types.h"
 #include "metadata.h"
 
-#define GET_NUM_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
-static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
-{ \
-	const struct TYPE *VAR = (const struct TYPE *)obj; \
-\
-	prop->value.integer = VALUE; \
-	return 1; \
-}
+
 #define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, volume_group, vg)
 #define GET_PV_NUM_PROPERTY_FN(NAME, VALUE) \
@@ -40,14 +30,6 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define GET_PVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
-#define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
-static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
-{ \
-	struct TYPE *VAR = (struct TYPE *)obj; \
-\
-	SETFN(VAR, prop->value.integer);		\
-	return 1; \
-}
 #define SET_VG_NUM_PROPERTY_FN(NAME, SETFN) \
 	SET_NUM_PROPERTY_FN(NAME, SETFN, volume_group, vg)
 #define SET_PV_NUM_PROPERTY_FN(NAME, SETFN) \
@@ -55,14 +37,6 @@ static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
 #define SET_LV_NUM_PROPERTY_FN(NAME, SETFN) \
 	SET_NUM_PROPERTY_FN(NAME, SETFN, logical_volume, lv)
 
-#define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
-static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
-{ \
-	const struct TYPE *VAR = (const struct TYPE *)obj; \
-\
-	prop->value.string = (char *)VALUE;	\
-	return 1; \
-}
 #define GET_VG_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, volume_group, vg)
 #define GET_PV_STR_PROPERTY_FN(NAME, VALUE) \
@@ -74,20 +48,6 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define GET_PVSEG_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
-static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
-{
-	log_errno(ENOSYS, "Function not implemented");
-
-	return 0;
-}
-
-static int _not_implemented_set(void *obj, struct lvm_property_type *prop)
-{
-	log_errno(ENOSYS, "Function not implemented");
-
-	return 0;
-}
-
 static percent_t _copy_percent(const struct logical_volume *lv)
 {
 	percent_t percent;
@@ -164,338 +124,267 @@ static percent_t _metadata_percent(const struct logical_volume *lv)
 
 /* PV */
 GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
-#define _pv_fmt_set _not_implemented_set
+#define _pv_fmt_set prop_not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_uuid, pv_uuid_dup(pv))
-#define _pv_uuid_set _not_implemented_set
+#define _pv_uuid_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(dev_size, SECTOR_SIZE * pv_dev_size(pv))
-#define _dev_size_set _not_implemented_set
+#define _dev_size_set prop_not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_name, pv_name_dup(pv))
-#define _pv_name_set _not_implemented_set
+#define _pv_name_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_free, SECTOR_SIZE * pv_mda_free(pv))
-#define _pv_mda_free_set _not_implemented_set
+#define _pv_mda_free_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_size, SECTOR_SIZE * pv_mda_size(pv))
-#define _pv_mda_size_set _not_implemented_set
+#define _pv_mda_size_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pe_start, SECTOR_SIZE * pv->pe_start)
-#define _pe_start_set _not_implemented_set
+#define _pe_start_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_size, SECTOR_SIZE * pv_size_field(pv))
-#define _pv_size_set _not_implemented_set
+#define _pv_size_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_free, SECTOR_SIZE * pv_free(pv))
-#define _pv_free_set _not_implemented_set
+#define _pv_free_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_used, SECTOR_SIZE * pv_used(pv))
-#define _pv_used_set _not_implemented_set
+#define _pv_used_set prop_not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_attr, pv_attr_dup(pv->vg->vgmem, pv))
-#define _pv_attr_set _not_implemented_set
+#define _pv_attr_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_pe_count, pv->pe_count)
-#define _pv_pe_count_set _not_implemented_set
+#define _pv_pe_count_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_pe_alloc_count, pv->pe_alloc_count)
-#define _pv_pe_alloc_count_set _not_implemented_set
+#define _pv_pe_alloc_count_set prop_not_implemented_set
 GET_PV_STR_PROPERTY_FN(pv_tags, pv_tags_dup(pv))
-#define _pv_tags_set _not_implemented_set
+#define _pv_tags_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
-#define _pv_mda_count_set _not_implemented_set
+#define _pv_mda_count_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
-#define _pv_mda_used_count_set _not_implemented_set
+#define _pv_mda_used_count_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(ba_start, SECTOR_SIZE * pv->ba_start)
-#define _ba_start_set _not_implemented_set
+#define _ba_start_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(ba_size, SECTOR_SIZE * pv->ba_size)
-#define _ba_size_set _not_implemented_set
+#define _ba_size_set prop_not_implemented_set
 
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
-#define _lv_uuid_set _not_implemented_set
+#define _lv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_name, lv_name_dup(lv->vg->vgmem, lv))
-#define _lv_name_set _not_implemented_set
+#define _lv_name_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
-#define _lv_path_set _not_implemented_set
+#define _lv_path_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
-#define _lv_attr_set _not_implemented_set
+#define _lv_attr_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
-#define _lv_major_set _not_implemented_set
+#define _lv_major_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
-#define _lv_minor_set _not_implemented_set
+#define _lv_minor_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_read_ahead, lv->read_ahead * SECTOR_SIZE)
-#define _lv_read_ahead_set _not_implemented_set
+#define _lv_read_ahead_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_major, lv_kernel_major(lv))
-#define _lv_kernel_major_set _not_implemented_set
+#define _lv_kernel_major_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_minor, lv_kernel_minor(lv))
-#define _lv_kernel_minor_set _not_implemented_set
+#define _lv_kernel_minor_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_read_ahead, lv_kernel_read_ahead(lv) * SECTOR_SIZE)
-#define _lv_kernel_read_ahead_set _not_implemented_set
+#define _lv_kernel_read_ahead_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
-#define _lv_size_set _not_implemented_set
+#define _lv_size_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
-#define _seg_count_set _not_implemented_set
+#define _seg_count_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
-#define _origin_set _not_implemented_set
+#define _origin_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
-#define _origin_size_set _not_implemented_set
+#define _origin_size_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
-#define _snap_percent_set _not_implemented_set
+#define _snap_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
-#define _copy_percent_set _not_implemented_set
+#define _copy_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(sync_percent, _copy_percent(lv))
-#define _sync_percent_set _not_implemented_set
+#define _sync_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(mismatches, _mismatches(lv))
-#define _mismatches_set _not_implemented_set
+#define _mismatches_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(writebehind, _writebehind(lv))
-#define _writebehind_set _not_implemented_set
+#define _writebehind_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(minrecoveryrate, _minrecoveryrate(lv))
-#define _minrecoveryrate_set _not_implemented_set
+#define _minrecoveryrate_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(maxrecoveryrate, _maxrecoveryrate(lv))
-#define _maxrecoveryrate_set _not_implemented_set
+#define _maxrecoveryrate_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(syncaction, _sync_action(lv))
-#define _syncaction_set _not_implemented_set
+#define _syncaction_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
-#define _move_pv_set _not_implemented_set
+#define _move_pv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
-#define _convert_lv_set _not_implemented_set
+#define _convert_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
-#define _lv_tags_set _not_implemented_set
+#define _lv_tags_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
-#define _mirror_log_set _not_implemented_set
+#define _mirror_log_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(modules, lv_modules_dup(lv->vg->vgmem, lv))
-#define _modules_set _not_implemented_set
+#define _modules_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(data_lv, lv_data_lv_dup(lv->vg->vgmem, lv))
-#define _data_lv_set _not_implemented_set
+#define _data_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(metadata_lv, lv_metadata_lv_dup(lv->vg->vgmem, lv))
-#define _metadata_lv_set _not_implemented_set
+#define _metadata_lv_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(pool_lv, lv_pool_lv_dup(lv->vg->vgmem, lv))
-#define _pool_lv_set _not_implemented_set
+#define _pool_lv_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(data_percent, _data_percent(lv))
-#define _data_percent_set _not_implemented_set
+#define _data_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(metadata_percent, _metadata_percent(lv))
-#define _metadata_percent_set _not_implemented_set
+#define _metadata_percent_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_metadata_size, lv_metadata_size(lv) * SECTOR_SIZE)
-#define _lv_metadata_size_set _not_implemented_set
+#define _lv_metadata_size_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_time, lv_time_dup(lv->vg->vgmem, lv))
-#define _lv_time_set _not_implemented_set
+#define _lv_time_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_host, lv_host_dup(lv->vg->vgmem, lv))
-#define _lv_host_set _not_implemented_set
+#define _lv_host_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_active, lv_active_dup(lv->vg->vgmem, lv))
-#define _lv_active_set _not_implemented_set
+#define _lv_active_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_profile, lv_profile_dup(lv->vg->vgmem, lv))
-#define _lv_profile_set _not_implemented_set
+#define _lv_profile_set prop_not_implemented_set
 
 /* VG */
 GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
-#define _vg_fmt_set _not_implemented_set
+#define _vg_fmt_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_uuid, vg_uuid_dup(vg))
-#define _vg_uuid_set _not_implemented_set
+#define _vg_uuid_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_name, vg_name_dup(vg))
-#define _vg_name_set _not_implemented_set
+#define _vg_name_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_attr, vg_attr_dup(vg->vgmem, vg))
-#define _vg_attr_set _not_implemented_set
+#define _vg_attr_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
-#define _vg_size_set _not_implemented_set
+#define _vg_size_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
-#define _vg_free_set _not_implemented_set
+#define _vg_free_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
-#define _vg_sysid_set _not_implemented_set
+#define _vg_sysid_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_size, (SECTOR_SIZE * vg->extent_size))
-#define _vg_extent_size_set _not_implemented_set
+#define _vg_extent_size_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
-#define _vg_extent_count_set _not_implemented_set
+#define _vg_extent_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_free_count, vg->free_count)
-#define _vg_free_count_set _not_implemented_set
+#define _vg_free_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(max_lv, vg->max_lv)
-#define _max_lv_set _not_implemented_set
+#define _max_lv_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(max_pv, vg->max_pv)
-#define _max_pv_set _not_implemented_set
+#define _max_pv_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(pv_count, vg->pv_count)
-#define _pv_count_set _not_implemented_set
+#define _pv_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(lv_count, (vg_visible_lvs(vg)))
-#define _lv_count_set _not_implemented_set
+#define _lv_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(snap_count, (snapshot_count(vg)))
-#define _snap_count_set _not_implemented_set
+#define _snap_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
-#define _vg_seqno_set _not_implemented_set
+#define _vg_seqno_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_tags, vg_tags_dup(vg))
-#define _vg_tags_set _not_implemented_set
+#define _vg_tags_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
-#define _vg_mda_count_set _not_implemented_set
+#define _vg_mda_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
-#define _vg_mda_used_count_set _not_implemented_set
+#define _vg_mda_used_count_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
-#define _vg_mda_free_set _not_implemented_set
+#define _vg_mda_free_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
-#define _vg_mda_size_set _not_implemented_set
+#define _vg_mda_size_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 SET_VG_NUM_PROPERTY_FN(vg_mda_copies, vg_set_mda_copies)
 GET_VG_STR_PROPERTY_FN(vg_profile, vg_profile_dup(vg))
-#define _vg_profile_set _not_implemented_set
+#define _vg_profile_set prop_not_implemented_set
 
 /* LVSEG */
 GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg->lv->vg->vgmem, lvseg))
-#define _segtype_set _not_implemented_set
+#define _segtype_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripes, lvseg->area_count)
-#define _stripes_set _not_implemented_set
+#define _stripes_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripesize, (SECTOR_SIZE * lvseg->stripe_size))
-#define _stripesize_set _not_implemented_set
+#define _stripesize_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripe_size, (SECTOR_SIZE * lvseg->stripe_size))
-#define _stripe_size_set _not_implemented_set
+#define _stripe_size_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(regionsize, (SECTOR_SIZE * lvseg->region_size))
-#define _regionsize_set _not_implemented_set
+#define _regionsize_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(region_size, (SECTOR_SIZE * lvseg->region_size))
-#define _region_size_set _not_implemented_set
+#define _region_size_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(chunksize, (SECTOR_SIZE * lvseg_chunksize(lvseg)))
-#define _chunksize_set _not_implemented_set
+#define _chunksize_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(chunk_size, (SECTOR_SIZE * lvseg_chunksize(lvseg)))
-#define _chunk_size_set _not_implemented_set
+#define _chunk_size_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(thin_count, dm_list_size(&lvseg->lv->segs_using_this_lv))
-#define _thin_count_set _not_implemented_set
+#define _thin_count_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
-#define _zero_set _not_implemented_set
+#define _zero_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
-#define _transaction_id_set _not_implemented_set
+#define _transaction_id_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(discards, lvseg_discards_dup(lvseg->lv->vg->vgmem, lvseg))
-#define _discards_set _not_implemented_set
+#define _discards_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, (SECTOR_SIZE * lvseg_start(lvseg)))
-#define _seg_start_set _not_implemented_set
+#define _seg_start_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
-#define _seg_start_pe_set _not_implemented_set
+#define _seg_start_pe_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_size, (SECTOR_SIZE * lvseg_size(lvseg)))
-#define _seg_size_set _not_implemented_set
+#define _seg_size_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
-#define _seg_tags_set _not_implemented_set
+#define _seg_tags_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
 			  lvseg_seg_pe_ranges(lvseg->lv->vg->vgmem, lvseg))
-#define _seg_pe_ranges_set _not_implemented_set
+#define _seg_pe_ranges_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
-#define _devices_set _not_implemented_set
+#define _devices_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, lvseg))
-#define _monitor_set _not_implemented_set
+#define _monitor_set prop_not_implemented_set
 
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
-#define _pvseg_start_set _not_implemented_set
+#define _pvseg_start_set prop_not_implemented_set
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
-#define _pvseg_size_set _not_implemented_set
-
+#define _pvseg_size_set prop_not_implemented_set
 
-#define STR DM_REPORT_FIELD_TYPE_STRING
-#define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, sorttype == STR, sorttype == NUM, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ 0, "", 0, 0, 0, { .integer = 0 }, _not_implemented_get, _not_implemented_set },
+	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get, prop_not_implemented_set },
 };
 
 #undef STR
 #undef NUM
 #undef FIELD
 
-static int _get_property(const void *obj, struct lvm_property_type *prop,
-			 unsigned type)
-{
-	struct lvm_property_type *p;
-
-	p = _properties;
-	while (p->id[0]) {
-		if (!strcmp(p->id, prop->id))
-			break;
-		p++;
-	}
-	if (!p->id[0]) {
-		log_errno(EINVAL, "Invalid property name %s", prop->id);
-		return 0;
-	}
-	if (!(p->type & type)) {
-		log_errno(EINVAL, "Property name %s does not match type %d",
-			  prop->id, p->type);
-		return 0;
-	}
-
-	*prop = *p;
-	if (!p->get(obj, prop)) {
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _set_property(void *obj, struct lvm_property_type *prop,
-			 unsigned type)
-{
-	struct lvm_property_type *p;
-
-	p = _properties;
-	while (p->id[0]) {
-		if (!strcmp(p->id, prop->id))
-			break;
-		p++;
-	}
-	if (!p->id[0]) {
-		log_errno(EINVAL, "Invalid property name %s", prop->id);
-		return 0;
-	}
-	if (!p->is_settable) {
-		log_errno(EINVAL, "Unable to set read-only property %s",
-			  prop->id);
-		return 0;
-	}
-	if (!(p->type & type)) {
-		log_errno(EINVAL, "Property name %s does not match type %d",
-			  prop->id, p->type);
-		return 0;
-	}
-
-	if (p->is_string)
-		p->value.string = prop->value.string;
-	else
-		p->value.integer = prop->value.integer;
-	if (!p->set(obj, p)) {
-		return 0;
-	}
-
-	return 1;
-}
-
 int lvseg_get_property(const struct lv_segment *lvseg,
 		       struct lvm_property_type *prop)
 {
-	return _get_property(lvseg, prop, SEGS);
+	return prop_get_property(_properties, lvseg, prop, SEGS);
 }
 
 int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop)
 {
-	return _get_property(lv, prop, LVS);
+	return prop_get_property(_properties, lv, prop, LVS);
 }
 
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop)
 {
-	return _get_property(vg, prop, VGS);
+	return prop_get_property(_properties, vg, prop, VGS);
 }
 
 int pvseg_get_property(const struct pv_segment *pvseg,
 		       struct lvm_property_type *prop)
 {
-	return _get_property(pvseg, prop, PVSEGS);
+	return prop_get_property(_properties, pvseg, prop, PVSEGS);
 }
 
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop)
 {
-	return _get_property(pv, prop, PVS | LABEL);
+	return prop_get_property(_properties, pv, prop, PVS | LABEL);
 }
 
 int lv_set_property(struct logical_volume *lv,
 		    struct lvm_property_type *prop)
 {
-	return _set_property(lv, prop, LVS);
+	return prop_set_property(_properties, lv, prop, LVS);
 }
 
 int vg_set_property(struct volume_group *vg,
 		    struct lvm_property_type *prop)
 {
-	return _set_property(vg, prop, VGS);
+	return prop_set_property(_properties, vg, prop, VGS);
 }
 
 int pv_set_property(struct physical_volume *pv,
 		    struct lvm_property_type *prop)
 {
-	return _set_property(pv, prop, PVS | LABEL);
+	return prop_set_property(_properties, pv, prop, PVS | LABEL);
 }
diff --git a/lib/report/properties.h b/lib/report/properties.h
index aefd3f5..4e8bf86 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,20 +18,7 @@
 #include "lvm-types.h"
 #include "metadata.h"
 #include "report.h"
-
-struct lvm_property_type {
-	unsigned type;
-	const char *id;
-	unsigned is_settable:1;
-	unsigned is_string:1;
-	unsigned is_integer:1;
-	union {
-		const char *string;
-		uint64_t integer;
-	} value;
-	int (*get) (const void *obj, struct lvm_property_type *prop);
-	int (*set) (void *obj, struct lvm_property_type *prop);
-};
+#include "prop_common.h"
 
 int lvseg_get_property(const struct lv_segment *lvseg,
 		       struct lvm_property_type *prop);


