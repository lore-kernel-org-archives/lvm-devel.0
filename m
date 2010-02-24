From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:16:18 -0000
Subject: LVM2/liblvm .exported_symbols lvm2app.h lvm_vg.c
Message-ID: <20100224181618.16015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:16:18

Modified files:
	liblvm         : .exported_symbols lvm2app.h lvm_vg.c 

Log message:
	Add lvm_vg_get_tags(), lvm_vg_add_tag(), and lvm_vg_remove_tag().
	
	Add lvm2app functions to manage VG tags.
	For lvm_vg_get_tags(), we return a list of tags, similar to other
	functions that return lists.  An empty list is returned if there
	are no VG tags.  NULL is returned if there is a problem obtaining
	the list of tags.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/liblvm/.exported_symbols	2010/02/14 03:21:38	1.23
+++ LVM2/liblvm/.exported_symbols	2010/02/24 18:16:18	1.24
@@ -18,6 +18,7 @@
 lvm_vg_get_extent_count
 lvm_vg_get_free_extent_count
 lvm_vg_get_pv_count
+lvm_vg_get_tags
 lvm_lv_activate
 lvm_lv_deactivate
 lvm_lv_get_uuid
@@ -33,6 +34,8 @@
 lvm_vg_open
 lvm_vg_close
 lvm_vg_remove
+lvm_vg_add_tag
+lvm_vg_remove_tag
 lvm_scan
 lvm_errno
 lvm_errmsg
--- LVM2/liblvm/lvm2app.h	2010/02/15 19:55:49	1.11
+++ LVM2/liblvm/lvm2app.h	2010/02/24 18:16:18	1.12
@@ -159,10 +159,10 @@
  * Lists of these structures are returned by lvm_list_vg_names and
  * lvm_list_vg_uuids.
  */
-struct lvm_str_list {
+typedef struct lvm_str_list {
 	struct dm_list list;
 	const char *str;
-};
+} lvm_str_list_t;
 
 /*************************** generic lvm handling ***************************/
 /**
@@ -458,6 +458,26 @@
 int lvm_vg_reduce(vg_t vg, const char *device);
 
 /**
+ * Add/remove a tag to/from a VG.
+ *
+ * These functions require calling lvm_vg_write to commit the change to disk.
+ * After successfully adding/removing a tag, use lvm_vg_write to commit the
+ * new VG to disk.  Upon failure, retry the operation or release the VG handle
+ * with lvm_vg_close.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   tag
+ * Tag to add/remove to/from VG.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_add_tag(vg_t vg, const char *tag);
+int lvm_vg_remove_tag(vg_t vg, const char *tag);
+
+/**
  * Set the extent size of a VG.
  *
  * This function requires calling lvm_vg_write to commit the change to disk.
@@ -644,6 +664,33 @@
  */
 uint64_t lvm_vg_get_max_lv(const vg_t vg);
 
+/**
+ * Return the list of volume group tags.
+ *
+ * The memory allocated for the list is tied to the vg_t handle and will be
+ * released when lvm_vg_close is called.
+ *
+ * To process the list, use the dm_list iterator functions.  For example:
+ *      vg_t vg;
+ *      struct dm_list *tags;
+ *      struct lvm_str_list *strl;
+ *
+ *      tags = lvm_vg_get_tags(vg);
+ *	dm_list_iterate_items(strl, tags) {
+ *		tag = strl->str;
+ *              // do something with tag
+ *      }
+ *
+ *
+ * \return
+ * A list with entries of type struct lvm_str_list, containing the
+ * tag strings attached to volume group.
+ * If no tags are attached to the given VG, an empty list is returned
+ * (check with dm_list_empty()).
+ * If there is a problem obtaining the list of tags, NULL is returned.
+ */
+struct dm_list *lvm_vg_get_tags(const vg_t vg);
+
 /************************** logical volume handling *************************/
 
 /**
--- LVM2/liblvm/lvm_vg.c	2010/02/16 00:27:02	1.36
+++ LVM2/liblvm/lvm_vg.c	2010/02/24 18:16:18	1.37
@@ -21,10 +21,39 @@
 #include "lvm-string.h"
 #include "lvmcache.h"
 #include "metadata.h"
+#include "lvm_misc.h"
 
 #include <errno.h>
 #include <string.h>
 
+int lvm_vg_add_tag(vg_t vg, const char *tag)
+{
+	if (vg_read_error(vg))
+		return -1;
+
+	if (!vg_check_write_mode(vg))
+		return -1;
+
+	if (!vg_change_tag(vg, tag, 1))
+		return -1;
+	return 0;
+}
+
+
+int lvm_vg_remove_tag(vg_t vg, const char *tag)
+{
+	if (vg_read_error(vg))
+		return -1;
+
+	if (!vg_check_write_mode(vg))
+		return -1;
+
+	if (!vg_change_tag(vg, tag, 0))
+		return -1;
+	return 0;
+}
+
+
 vg_t lvm_vg_create(lvm_t libh, const char *vg_name)
 {
 	struct volume_group *vg;
@@ -233,6 +262,11 @@
 	return list;
 }
 
+struct dm_list *lvm_vg_get_tags(const vg_t vg)
+{
+	return tag_list_copy(vg->vgmem, &vg->tags);
+}
+
 uint64_t lvm_vg_get_seqno(const vg_t vg)
 {
 	return vg_seqno(vg);


