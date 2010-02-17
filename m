From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Feb 2010 12:29:03 -0500
Subject: [PATCH 7/8] Add lvm_lv_get_tags(), lvm_lv_add_tag(), and lvm_lv_remove_tag().
In-Reply-To: <1266427744-30327-7-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-3-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-4-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-5-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-6-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1266427744-30327-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add lvm2app functions to manage LV tags.
For lvm_lv_get_tags(), we return a list of tags, similar to other
functions that return lists.  An empty list is returned if there
are no tags.  NULL is returned if there is a problem obtaining
the list of tags.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    3 ++
 liblvm/lvm2app.h         |   48 ++++++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c          |   35 +++++++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 7431248..9b61d45 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -26,6 +26,9 @@ lvm_lv_get_name
 lvm_lv_get_size
 lvm_lv_is_active
 lvm_lv_is_suspended
+lvm_lv_add_tag
+lvm_lv_remove_tag
+lvm_lv_get_tags
 lvm_vg_create
 lvm_vg_extend
 lvm_vg_reduce
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 41ce18c..e052301 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -835,6 +835,54 @@ uint64_t lvm_lv_is_active(const lv_t lv);
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
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 7a37d2c..86175ae 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
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
@@ -68,6 +78,31 @@ uint64_t lvm_lv_is_suspended(const lv_t lv)
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
-- 
1.6.0.6


