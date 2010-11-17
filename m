From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:09:43 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_misc.c lvm_ ...
Message-ID: <20101117200943.7917.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:09:42

Modified files:
	liblvm         : lvm2app.h lvm_lv.c lvm_misc.c lvm_misc.h 
	                 lvm_pv.c lvm_vg.c 

Log message:
	Add lvm2app function to query lvseg properties.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/liblvm/lvm2app.h	2010/11/17 20:07:01	1.25
+++ LVM2/liblvm/lvm2app.h	2010/11/17 20:09:42	1.26
@@ -1132,6 +1132,45 @@
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name);
 
 /**
+ * Get the value of a LV segment property
+ *
+ * \memberof lv_t
+ *
+ * \param   lvseg
+ * Logical volume segment handle.
+ *
+ * \param   name
+ * Name of property to query.  See lvs man page for full list of properties
+ * that may be queried.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "seg_start_pe";
+ *
+ *      v = lvm_lvseg_get_property(lvseg, prop_name);
+ *      if (lvm_errno(libh) || !v.is_valid) {
+ *           // handle error
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s'.\n", prop_name);
+ *           return;
+ *      }
+ *      if (v.is_string)
+ *           printf(", value = %s\n", v.value.string);
+ *	else
+ *           printf(", value = %"PRIu64"\n", v.value.integer);
+ *
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check lvm_errno() as well
+ * as 'is_valid' flag before using the value.
+ */
+struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
+						 const char *name);
+
+/**
  * Get the current activation state of a logical volume.
  *
  * \memberof lv_t
--- LVM2/liblvm/lvm_lv.c	2010/11/17 20:07:01	1.29
+++ LVM2/liblvm/lvm_lv.c	2010/11/17 20:09:42	1.30
@@ -50,7 +50,13 @@
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, name);
+	return get_property(NULL, NULL, lv, NULL, name);
+}
+
+struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
+						 const char *name)
+{
+	return get_property(NULL, NULL, NULL, lvseg, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
--- LVM2/liblvm/lvm_misc.c	2010/11/17 19:16:05	1.4
+++ LVM2/liblvm/lvm_misc.c	2010/11/17 20:09:42	1.5
@@ -46,7 +46,8 @@
 }
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
-				       const lv_t lv, const char *name)
+				       const lv_t lv, const lvseg_t lvseg,
+				       const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v;
@@ -67,6 +68,11 @@
 			v.is_valid = 0;
 			return v;
 		}
+	} else if (lvseg) {
+		if (!lvseg_get_property(lvseg, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
 	}
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
--- LVM2/liblvm/lvm_misc.h	2010/11/17 19:16:05	1.4
+++ LVM2/liblvm/lvm_misc.h	2010/11/17 20:09:42	1.5
@@ -18,7 +18,8 @@
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
-				       const lv_t lv, const char *name);
+				       const lv_t lv, const lvseg_t lvseg,
+                                       const char *name);
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 		 const char *name, struct lvm_property_value *value);
 
--- LVM2/liblvm/lvm_pv.c	2010/10/25 14:08:55	1.14
+++ LVM2/liblvm/lvm_pv.c	2010/11/17 20:09:42	1.15
@@ -51,7 +51,7 @@
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, name);
 }
 
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
--- LVM2/liblvm/lvm_vg.c	2010/11/17 19:16:05	1.46
+++ LVM2/liblvm/lvm_vg.c	2010/11/17 20:09:42	1.47
@@ -338,7 +338,7 @@
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, name);
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,


