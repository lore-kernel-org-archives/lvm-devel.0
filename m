From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Oct 2010 14:08:44 -0000
Subject: LVM2/liblvm lvm2app.h lvm_misc.c lvm_misc.h lv ...
Message-ID: <20101025140844.20317.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-25 14:08:44

Modified files:
	liblvm         : lvm2app.h lvm_misc.c lvm_misc.h lvm_vg.c 

Log message:
	Add lvm_vg_get_property() generic vg property function.
	
	Add a generic VG property function to lvm2app.  Call the internal library
	vg_get_property() function.  Strings are dup'd internally.
	Rework lvm_vg_get_property to return lvm_property_value and require caller
	to check 'is_valid' flag.  If !is_valid, the caller can check lvm_errno()
	for the specific error.
	
	Create a 'get_property' function, local to lvm2app, that factors out
	most of the common code that copies the components of lvm_property_type
	into lvm_property_value.  This allows for a 1-line function for each
	of the generic property functions exported by lvm2app.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/liblvm/lvm2app.h	2010/08/02 12:23:06	1.20
+++ LVM2/liblvm/lvm2app.h	2010/10/25 14:08:43	1.21
@@ -139,7 +139,7 @@
 /**
  * Logical Volume object list.
  *
- * Lists of these structures are returned by lvm_vg_list_pvs().
+ * Lists of these structures are returned by lvm_vg_list_lvs().
  */
 typedef struct lvm_lv_list {
 	struct dm_list list;
@@ -168,6 +168,30 @@
 	const char *str;
 } lvm_str_list_t;
 
+/**
+ * Property Value
+ *
+ * This structure defines a single LVM property value for an LVM object.
+ * The structures are returned by functions such as
+ * lvm_vg_get_property().
+ *
+ * is_settable: indicates whether a 'set' function exists for this property
+ * is_string: indicates whether this property is a string (1) or not (0)
+ * is_integer: indicates whether this property is an integer (1) or not (0)
+ * is_valid: indicates whether 'value' is valid (1) or not (0)
+ */
+typedef struct lvm_property_value {
+	uint32_t is_settable:1;
+	uint32_t is_string:1;
+	uint32_t is_integer:1;
+	uint32_t is_valid:1;
+	uint32_t padding:28;
+	union {
+		const char *string;
+		uint64_t integer;
+	} value;
+} lvm_property_value_t;
+
 /*************************** generic lvm handling ***************************/
 /**
  * Create a LVM handle.
@@ -848,6 +872,45 @@
  */
 struct dm_list *lvm_vg_get_tags(const vg_t vg);
 
+/**
+ * Get the value of a VG property
+ *
+ * \memberof vg_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   name
+ * Name of property to query.  See vgs man page for full list of properties
+ * that may be queried.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "vg_mda_count";
+ *
+ *      v = lvm_vg_get_property(vg, prop_name);
+ *      if (!v.is_valid) {
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s', errno = %d.\n", prop_name, lvm_errno(libh));
+ *           return;
+ *      }
+ *      if (v.is_string)
+ *           printf(", value = %s\n", v.value.string);
+ *	if (v.is_integer)
+ *           printf(", value = %"PRIu64"\n", v.value.integer);
+ *
+ *
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check 'is_valid' flag before using
+ * the value.  If 'is_valid' is not set, caller should check lvm_errno()
+ * for specific error.
+ */
+struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name);
+
 /************************** logical volume handling *************************/
 
 /**
--- LVM2/liblvm/lvm_misc.c	2010/07/09 16:57:34	1.2
+++ LVM2/liblvm/lvm_misc.c	2010/10/25 14:08:43	1.3
@@ -15,6 +15,7 @@
 #include "lvm2app.h"
 #include "lvm_misc.h"
 #include "lib.h"
+#include "properties.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
@@ -43,3 +44,37 @@
 	}
 	return list;
 }
+
+struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
+				       const lv_t lv, const char *name)
+{
+	struct lvm_property_type prop;
+	struct lvm_property_value v;
+
+	prop.id = name;
+	if (pv) {
+		if (!pv_get_property(pv, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
+	} else if (vg) {
+		if (!vg_get_property(vg, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
+	} else if (lv) {
+		if (!lv_get_property(lv, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
+	}
+	v.is_settable = prop.is_settable;
+	v.is_string = prop.is_string;
+	v.is_integer = prop.is_integer;
+	if (v.is_string)
+		v.value.string = prop.value.string;
+	if (v.is_integer)
+		v.value.integer = prop.value.integer;
+	v.is_valid = 1;
+	return v;
+}
--- LVM2/liblvm/lvm_misc.h	2010/07/09 16:57:34	1.2
+++ LVM2/liblvm/lvm_misc.h	2010/10/25 14:08:43	1.3
@@ -17,5 +17,7 @@
 #include "libdevmapper.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
+struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
+				       const lv_t lv, const char *name);
 
 #endif
--- LVM2/liblvm/lvm_vg.c	2010/09/30 14:07:48	1.44
+++ LVM2/liblvm/lvm_vg.c	2010/10/25 14:08:43	1.45
@@ -335,6 +335,12 @@
 	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
 }
 
+
+struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
+{
+	return get_property(NULL, vg, NULL, name);
+}
+
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);


