From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Oct 2010 14:08:55 -0000
Subject: LVM2/liblvm lvm2app.h lvm_pv.c
Message-ID: <20101025140855.20481.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-25 14:08:55

Modified files:
	liblvm         : lvm2app.h lvm_pv.c 

Log message:
	Add lvm_pv_get_property() generic function to obtain value of any pv property.
	
	Add a generic PV property function to lvm2app, similar to VG function.
	Return lvm_property_value and require caller to check 'is_valid' flag
	before using the value.  If 'is_valid' is not set, then lvm_errno()
	should be used to obtain the specific error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/liblvm/lvm2app.h	2010/10/25 14:08:43	1.21
+++ LVM2/liblvm/lvm2app.h	2010/10/25 14:08:55	1.22
@@ -1243,6 +1243,44 @@
 uint64_t lvm_pv_get_free(const pv_t pv);
 
 /**
+ * Get the value of a PV property
+ *
+ * \memberof pv_t
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \param   name
+ * Name of property to query.  See pvs man page for full list of properties
+ * that may be queried.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value value;
+ *      char *prop_name = "pv_mda_count";
+ *
+ *      v = lvm_pv_get_property(pv, prop_name);
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
+struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
--- LVM2/liblvm/lvm_pv.c	2010/09/30 14:07:48	1.13
+++ LVM2/liblvm/lvm_pv.c	2010/10/25 14:08:55	1.14
@@ -16,6 +16,7 @@
 #include "lvm2app.h"
 #include "metadata.h"
 #include "lvm-string.h"
+#include "lvm_misc.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
@@ -48,6 +49,11 @@
 	return (uint64_t) SECTOR_SIZE * pv_free(pv);
 }
 
+struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
+{
+	return get_property(pv, NULL, NULL, name);
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */


