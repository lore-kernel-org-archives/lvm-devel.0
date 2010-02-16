From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:47 -0500
Subject: [PATCH 5/7] Add lvm_vg_get_tags(), lvm_vg_add_tag(), and lvm_vg_remove_tag().
In-Reply-To: <1266349189-23166-5-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-4-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1266349189-23166-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add lvm2app functions to manage VG tags.
For lvm_vg_get_tags(), we return a list of tags, similar to other
functions that return lists.  NULL is returned if there is no
tags.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    3 ++
 liblvm/lvm2app.h         |   49 +++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_vg.c          |   55 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+), 2 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index c184a88..7431248 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -18,6 +18,7 @@ lvm_vg_get_extent_size
 lvm_vg_get_extent_count
 lvm_vg_get_free_extent_count
 lvm_vg_get_pv_count
+lvm_vg_get_tags
 lvm_lv_activate
 lvm_lv_deactivate
 lvm_lv_get_uuid
@@ -33,6 +34,8 @@ lvm_vg_write
 lvm_vg_open
 lvm_vg_close
 lvm_vg_remove
+lvm_vg_add_tag
+lvm_vg_remove_tag
 lvm_scan
 lvm_errno
 lvm_errmsg
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 39bfff8..b21d0e9 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -159,10 +159,10 @@ typedef struct lvm_pv_list {
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
@@ -458,6 +458,26 @@ int lvm_vg_extend(vg_t vg, const char *device);
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
@@ -644,6 +664,31 @@ uint64_t lvm_vg_get_max_pv(const vg_t vg);
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
+ * If no tags are attached to the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_get_tags(const vg_t vg);
+
 /************************** logical volume handling *************************/
 
 /**
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 0c166d5..7486154 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -25,6 +25,34 @@
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
@@ -233,6 +261,33 @@ struct dm_list *lvm_vg_list_lvs(vg_t vg)
 	return list;
 }
 
+struct dm_list *lvm_vg_get_tags(const vg_t vg)
+{
+	struct dm_list *list;
+	lvm_str_list_t *lsl;
+	struct str_list *sl;
+
+	if (dm_list_empty(&vg->tags))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(sl, &vg->tags) {
+		if (!(lsl = dm_pool_zalloc(vg->vgmem, sizeof(*lsl)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lv_list.");
+			return NULL;
+		}
+		lsl->str = dm_pool_strdup(vg->vgmem, sl->str);
+		dm_list_add(list, &lsl->list);
+	}
+	return list;
+}
+
 uint64_t lvm_vg_get_seqno(const vg_t vg)
 {
 	return vg_seqno(vg);
-- 
1.6.0.6


