From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:12:41 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_misc.c lvm_ ...
Message-ID: <20101117201241.8715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:12:40

Modified files:
	liblvm         : lvm2app.h lvm_lv.c lvm_misc.c lvm_misc.h 
	                 lvm_pv.c lvm_vg.c 

Log message:
	Add lvm2app function to query pvseg properties.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/liblvm/lvm2app.h	2010/11/17 20:10:42	1.27
+++ LVM2/liblvm/lvm2app.h	2010/11/17 20:12:39	1.28
@@ -1437,6 +1437,45 @@
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name);
 
 /**
+ * Get the value of a PV segment property
+ *
+ * \memberof pv_t
+ *
+ * \param   pvseg
+ * Physical volume segment handle.
+ *
+ * \param   name
+ * Name of property to query.  See pvs man page for full list of properties
+ * that may be queried.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "pvseg_start";
+ *
+ *      v = lvm_pvseg_get_property(pvseg, prop_name);
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
+struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
+						 const char *name);
+
+/**
  * Return a list of pvseg handles for a given PV handle.
  *
  * \memberof pv_t
--- LVM2/liblvm/lvm_lv.c	2010/11/17 20:09:42	1.30
+++ LVM2/liblvm/lvm_lv.c	2010/11/17 20:12:39	1.31
@@ -50,13 +50,13 @@
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, NULL, name);
+	return get_property(NULL, NULL, lv, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, lvseg, name);
+	return get_property(NULL, NULL, NULL, lvseg, NULL, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
--- LVM2/liblvm/lvm_misc.c	2010/11/17 20:09:42	1.5
+++ LVM2/liblvm/lvm_misc.c	2010/11/17 20:12:40	1.6
@@ -47,7 +47,7 @@
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const char *name)
+				       const pvseg_t pvseg, const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v;
@@ -73,6 +73,11 @@
 			v.is_valid = 0;
 			return v;
 		}
+	} else if (pvseg) {
+		if (!pvseg_get_property(pvseg, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
 	}
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
--- LVM2/liblvm/lvm_misc.h	2010/11/17 20:09:42	1.5
+++ LVM2/liblvm/lvm_misc.h	2010/11/17 20:12:40	1.6
@@ -19,7 +19,7 @@
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-                                       const char *name);
+				       const pvseg_t pvseg, const char *name);
 int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
 		 const char *name, struct lvm_property_value *value);
 
--- LVM2/liblvm/lvm_pv.c	2010/11/17 20:10:42	1.16
+++ LVM2/liblvm/lvm_pv.c	2010/11/17 20:12:40	1.17
@@ -51,7 +51,13 @@
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, NULL, name);
+}
+
+struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
+						 const char *name)
+{
+	return get_property(NULL, NULL, NULL, NULL, pvseg, name);
 }
 
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
--- LVM2/liblvm/lvm_vg.c	2010/11/17 20:09:42	1.47
+++ LVM2/liblvm/lvm_vg.c	2010/11/17 20:12:40	1.48
@@ -338,7 +338,7 @@
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, NULL, name);
 }
 
 int lvm_vg_set_property(const vg_t vg, const char *name,


