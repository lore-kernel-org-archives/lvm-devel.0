From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Oct 2010 14:09:09 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c
Message-ID: <20101025140909.20625.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-25 14:09:08

Modified files:
	liblvm         : lvm2app.h lvm_lv.c 

Log message:
	Add lvm_lv_get_property() generic function to obtain value of any lv propert
	
	Add a generic LV property function to lvm2app, similar to VG function.
	Return lvm_property_value and require caller to check 'is_valid' flag
	and lvm_errno() for API error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/liblvm/lvm2app.h	2010/10/25 14:08:55	1.22
+++ LVM2/liblvm/lvm2app.h	2010/10/25 14:09:08	1.23
@@ -1033,6 +1033,44 @@
 uint64_t lvm_lv_get_size(const lv_t lv);
 
 /**
+ * Get the value of a LV property
+ *
+ * \memberof lv_t
+ *
+ * \param   lv
+ * Logical volume handle.
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
+ *      char *prop_name = "seg_count";
+ *
+ *      v = lvm_lv_get_property(lv, prop_name);
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
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check 'is_valid' flag before using
+ * the value.  If 'is_valid' is not set, caller should check lvm_errno()
+ * for specific error.
+ */
+struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name);
+
+/**
  * Get the current activation state of a logical volume.
  *
  * \memberof lv_t
--- LVM2/liblvm/lvm_lv.c	2010/09/30 14:07:48	1.26
+++ LVM2/liblvm/lvm_lv.c	2010/10/25 14:09:08	1.27
@@ -48,6 +48,11 @@
 			       NAME_LEN+1);
 }
 
+struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
+{
+	return get_property(NULL, NULL, lv, name);
+}
+
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;


