From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:16:27 -0000
Subject: LVM2/liblvm .exported_symbols lvm2app.h lvm_lv.c
Message-ID: <20100224181627.16235.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:16:26

Modified files:
	liblvm         : .exported_symbols lvm2app.h lvm_lv.c 

Log message:
	Add lvm_lv_get_tags(), lvm_lv_add_tag(), and lvm_lv_remove_tag().
	
	Add lvm2app functions to manage LV tags.
	For lvm_lv_get_tags(), we return a list of tags, similar to other
	functions that return lists.  An empty list is returned if there
	are no tags.  NULL is returned if there is a problem obtaining
	the list of tags.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/liblvm/.exported_symbols	2010/02/24 18:16:18	1.24
+++ LVM2/liblvm/.exported_symbols	2010/02/24 18:16:26	1.25
@@ -26,6 +26,9 @@
 lvm_lv_get_size
 lvm_lv_is_active
 lvm_lv_is_suspended
+lvm_lv_add_tag
+lvm_lv_remove_tag
+lvm_lv_get_tags
 lvm_vg_create
 lvm_vg_extend
 lvm_vg_reduce
--- LVM2/liblvm/lvm2app.h	2010/02/24 18:16:18	1.12
+++ LVM2/liblvm/lvm2app.h	2010/02/24 18:16:26	1.13
@@ -835,6 +835,54 @@
 uint64_t lvm_lv_is_suspended(const lv_t lv);
 
 /**
+ * Add/remove a tag to/from a LV.
+ *
+ * These functions require calling lvm_vg_write to commit the change to disk.
+ * After successfully adding/removing a tag, use lvm_vg_write to commit the
+ * new VG to disk.  Upon failure, retry the operation or release the VG handle
+ * with lvm_vg_close.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \param   tag
+ * Tag to add/remove to/from LV.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_lv_add_tag(lv_t lv, const char *tag);
+int lvm_lv_remove_tag(lv_t lv, const char *tag);
+
+/**
+ * Return the list of logical volume tags.
+ *
+ * The memory allocated for the list is tied to the vg_t handle and will be
+ * released when lvm_vg_close is called.
+ *
+ * To process the list, use the dm_list iterator functions.  For example:
+ *      lv_t lv;
+ *      struct dm_list *tags;
+ *      struct lvm_str_list *strl;
+ *
+ *      tags = lvm_lv_get_tags(lv);
+ *	dm_list_iterate_items(strl, tags) {
+ *		tag = strl->str;
+ *              // do something with tag
+ *      }
+ *
+ *
+ * \return
+ * A list with entries of type struct lvm_str_list, containing the
+ * tag strings attached to volume group.
+ * If no tags are attached to the LV, an empty list is returned
+ * (check with dm_list_empty()).
+ * If there is a problem obtaining the list of tags, NULL is returned.
+ */
+struct dm_list *lvm_lv_get_tags(const lv_t lv);
+
+
+/**
  * Resize logical volume to new_size bytes.
  *
  * NOTE: This function is currently not implemented.
--- LVM2/liblvm/lvm_lv.c	2010/02/16 00:27:02	1.18
+++ LVM2/liblvm/lvm_lv.c	2010/02/24 18:16:26	1.19
@@ -20,9 +20,19 @@
 #include "segtype.h"
 #include "locking.h"
 #include "activate.h"
+#include "lvm_misc.h"
 
 #include <string.h>
 
+static int _lv_check_handle(const lv_t lv, const int vg_writeable)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg))
+		return -1;
+	if (vg_writeable && !vg_check_write_mode(lv->vg))
+		return -1;
+	return 0;
+}
+
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
 uint64_t lvm_lv_get_size(const lv_t lv)
 {
@@ -68,6 +78,31 @@
 	return 0;
 }
 
+int lvm_lv_add_tag(lv_t lv, const char *tag)
+{
+	if (_lv_check_handle(lv, 1))
+		return -1;
+	if (!lv_change_tag(lv, tag, 1))
+		return -1;
+	return 0;
+}
+
+
+int lvm_lv_remove_tag(lv_t lv, const char *tag)
+{
+	if (_lv_check_handle(lv, 1))
+		return -1;
+	if (!lv_change_tag(lv, tag, 0))
+		return -1;
+	return 0;
+}
+
+
+struct dm_list *lvm_lv_get_tags(const lv_t lv)
+{
+	return tag_list_copy(lv->vg->vgmem, &lv->tags);
+}
+
 /* Set defaults for non-segment specific LV parameters */
 static void _lv_set_default_params(struct lvcreate_params *lp,
 				   vg_t vg, const char *lvname,


