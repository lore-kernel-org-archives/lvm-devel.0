From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:48 -0500
Subject: [PATCH 6/7] Add lvm_lv_get_tags(), lvm_lv_add_tag(), and lvm_lv_remove_tag().
In-Reply-To: <1266349189-23166-6-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-4-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-5-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1266349189-23166-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add lvm2app functions to manage VG tags.
For lvm_lv_get_tags(), we return a list of tags, similar to other
functions that return lists.  NULL is returned if there are no
tags.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    3 ++
 liblvm/lvm2app.h         |   46 ++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c          |   58 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 107 insertions(+), 0 deletions(-)

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
index b21d0e9..46a9e74 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -833,6 +833,52 @@ uint64_t lvm_lv_is_active(const lv_t lv);
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
+ * If no tags are attached to the given VG, NULL is returned.
+ */
+struct dm_list *lvm_lv_get_tags(const lv_t lv);
+
+
+/**
  * Resize logical volume to new_size bytes.
  *
  * NOTE: This function is currently not implemented.
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 7a37d2c..0ac7f79 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -23,6 +23,15 @@
 
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
@@ -68,6 +77,55 @@ uint64_t lvm_lv_is_suspended(const lv_t lv)
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
+	struct dm_list *list;
+	lvm_str_list_t *lsl;
+	struct str_list *sl;
+
+	if (_lv_check_handle(lv, 0))
+		return NULL;
+	if (dm_list_empty(&lv->tags))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(lv->vg->vgmem, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(sl, &lv->tags) {
+		if (!(lsl = dm_pool_zalloc(lv->vg->vgmem, sizeof(*lsl)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lv_list.");
+			return NULL;
+		}
+		lsl->str = dm_pool_strdup(lv->vg->vgmem, sl->str);
+		dm_list_add(list, &lsl->list);
+	}
+	return list;
+}
+
 /* Set defaults for non-segment specific LV parameters */
 static void _lv_set_default_params(struct lvcreate_params *lp,
 				   vg_t vg, const char *lvname,
-- 
1.6.0.6


