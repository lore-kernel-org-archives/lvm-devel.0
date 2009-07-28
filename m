From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 13:16:41 -0000
Subject: LVM2/liblvm lvm.h lvm_base.c lvm_lv.c
Message-ID: <20090728131641.1228.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 13:16:40

Modified files:
	liblvm         : lvm.h lvm_base.c lvm_lv.c 

Log message:
	Update lvm.h - remove remaining FIXMEs, note limitations of a few functions.
	
	Almost done...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/liblvm/lvm.h	2009/07/28 12:19:58	1.38
+++ LVM2/liblvm/lvm.h	2009/07/28 13:16:40	1.39
@@ -20,13 +20,36 @@
 #include <stdint.h>
 
 
-/******************************** WARNING ********************************/
-/*
+/******************************** WARNING ***********************************
+ *
  * NOTE: This API is under development and subject to change at any time.
  *
  * Please send feedback to lvm-devel at redhat.com
+ *
+ *********************************** WARNING ********************************/
+
+/*************************** Design Overview ********************************/
+
+/*
+ * The API is designed around the following basic LVM objects:
+ * 1) Physical Volume (PV) 2) Volume Group (VG) 3) Logical Volume (LV).
+ *
+ * The library provides functions to list the objects in a system,
+ * get and set object properties (such as names, UUIDs, and sizes), as well
+ * as create/remove objects and perform more complex operations and
+ * transformations. Each object instance is represented by a handle, and
+ * handles are passed to and from the functions to perform the operations.
+ *
+ * A central object in the library is the Volume Group, represented by the
+ * VG handle, vg_t. Performing an operation on a PV or LV object first
+ * requires obtaining a VG handle. Once the vg_t has been obtained, it can
+ * be used to enumerate the pv_t's and lv_t's within that vg_t. Attributes
+ * of these objects can then be queried.
+ *
+ * A volume group handle may be obtained with read or write permission.
+ * Any attempt to change a property of a pv_t, vg_t, or lv_t without
+ * obtaining write permission on the vg_t will fail with EPERM.
  */
-/******************************** WARNING ********************************/
 
 /**
  * Retrieve the library version.
@@ -180,9 +203,8 @@
  * Override the LVM configuration with a configuration string.
  *
  * This function is equivalent to the --config option on lvm commands.
- * FIXME: submit a patch to document the --config option
  * Once this API has been used to over-ride the configuration,
- * you should use lvm_config_reload to apply the new settings.
+ * use lvm_config_reload to apply the new settings.
  *
  * \param   libh
  * Handle obtained from lvm_init.
@@ -559,9 +581,8 @@
  * Create a linear logical volume.
  * This function commits the change to disk and does _not_ require calling
  * lvm_vg_write.
- * FIXME: This function should probably not commit to disk but require calling
- * lvm_vg_write.  However, this appears to be non-trivial change until
- * lv_create_single is refactored by segtype.
+ * NOTE: The commit behavior of this function is subject to change
+ * as the API is developed.
  *
  * \param   vg
  * VG handle obtained from lvm_vg_create or lvm_vg_open.
@@ -612,11 +633,10 @@
  *
  * This function commits the change to disk and does _not_ require calling
  * lvm_vg_write.
+ * NOTE: The commit behavior of this function is subject to change
+ * as the API is developed.
  * Currently only removing linear LVs are possible.
  *
- * FIXME: This function should probably not commit to disk but require calling
- * lvm_vg_write.
- *
  * \param   lv
  * Logical volume handle.
  *
@@ -689,6 +709,8 @@
 /**
  * Resize logical volume to new_size bytes.
  *
+ * NOTE: This function is currently not implemented.
+ *
  * \param   lv
  * Logical volume handle.
  *
@@ -763,6 +785,8 @@
 /**
  * Resize physical volume to new_size bytes.
  *
+ * NOTE: This function is currently not implemented.
+ *
  * \param   pv
  * Physical volume handle.
  *
--- LVM2/liblvm/lvm_base.c	2009/07/28 11:03:28	1.10
+++ LVM2/liblvm/lvm_base.c	2009/07/28 13:16:40	1.11
@@ -77,6 +77,9 @@
 	return 0;
 }
 
+/*
+ * FIXME: submit a patch to document the --config option
+ */
 int lvm_config_override(lvm_t libh, const char *config_settings)
 {
 	struct cmd_context *cmd = (struct cmd_context *)libh;
--- LVM2/liblvm/lvm_lv.c	2009/07/28 09:56:48	1.10
+++ LVM2/liblvm/lvm_lv.c	2009/07/28 13:16:40	1.11
@@ -96,6 +96,11 @@
 	lp->stripe_size = DEFAULT_STRIPESIZE * 2;
 }
 
+/*
+ * FIXME: This function should probably not commit to disk but require calling
+ * lvm_vg_write.  However, this appears to be non-trivial change until
+ * lv_create_single is refactored by segtype.
+ */
 lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size)
 {
 	struct lvcreate_params lp;
@@ -117,6 +122,10 @@
 	return lvl->lv;
 }
 
+/*
+ * FIXME: This function should probably not commit to disk but require calling
+ * lvm_vg_write.
+ */
 int lvm_vg_remove_lv(lv_t *lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))


