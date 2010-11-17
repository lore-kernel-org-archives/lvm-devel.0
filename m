From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 19:16:06 -0000
Subject: LVM2/liblvm lvm2app.h lvm_misc.c lvm_misc.h lv ...
Message-ID: <20101117191606.26685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 19:16:05

Modified files:
	liblvm         : lvm2app.h lvm_misc.c lvm_misc.h lvm_vg.c 

Log message:
	Implement lvm_vg_set_property() by calling internal 'set' property function.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/liblvm/lvm2app.h	2010/10/25 14:09:08	1.23
+++ LVM2/liblvm/lvm2app.h	2010/11/17 19:16:05	1.24
@@ -911,6 +911,36 @@
  */
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name);
 
+/**
+ * Set the value of a VG property.  Note that the property must be
+ * a 'settable' property, as evidenced by the 'is_settable' flag
+ * when querying the property.
+ *
+ * \memberof vg_t
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example (integer):
+ *      lvm_property_value copies;
+ *
+ *      if (lvm_vg_get_property(vg, "vg_mda_copies", &copies) < 0) {
+ *              // Error - unable to query property
+ *      }
+ *      if (!copies.is_settable) {
+ *              // Error - property not settable
+ *      }
+ *      copies.value.integer = 2;
+ *      if (lvm_vg_set_property(vg, "vg_mda_copies", &copies) < 0) {
+ *              // handle error
+ *      }
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_set_property(const vg_t vg, const char *name,
+			struct lvm_property_value *value);
+
 /************************** logical volume handling *************************/
 
 /**
--- LVM2/liblvm/lvm_misc.c	2010/10/25 14:08:43	1.3
+++ LVM2/liblvm/lvm_misc.c	2010/11/17 19:16:05	1.4
@@ -78,3 +78,33 @@
 	v.is_valid = 1;
 	return v;
 }
+
+
+int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
+		 const char *name, struct lvm_property_value *v)
+{
+	struct lvm_property_type prop;
+
+	prop.id = name;
+	if (v->is_string)
+		prop.value.string = v->value.string;
+	else
+		prop.value.integer = v->value.integer;
+	if (pv) {
+		if (!pv_set_property(pv, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	} else if (vg) {
+		if (!vg_set_property(vg, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	} else if (lv) {
+		if (!lv_set_property(lv, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	}
+	return 0;
+}
--- LVM2/liblvm/lvm_misc.h	2010/10/25 14:08:43	1.3
+++ LVM2/liblvm/lvm_misc.h	2010/11/17 19:16:05	1.4
@@ -19,5 +19,7 @@
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const char *name);
+int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
+		 const char *name, struct lvm_property_value *value);
 
 #endif
--- LVM2/liblvm/lvm_vg.c	2010/10/25 14:08:43	1.45
+++ LVM2/liblvm/lvm_vg.c	2010/11/17 19:16:05	1.46
@@ -341,6 +341,12 @@
 	return get_property(NULL, vg, NULL, name);
 }
 
+int lvm_vg_set_property(const vg_t vg, const char *name,
+			struct lvm_property_value *value)
+{
+	return set_property(NULL, vg, NULL, name, value);
+}
+
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);


