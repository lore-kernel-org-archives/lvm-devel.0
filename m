From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 10 Apr 2013 13:41:23 -0500
Subject: [PATCH 1/2] lvm2app: Add method to retrieve attr from lv.
Message-ID: <1365619284-4238-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 liblvm/lvm2app.h | 16 ++++++++++++++++
 liblvm/lvm_lv.c  |  5 +++++
 2 files changed, 21 insertions(+)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index f889f2f..15827ac 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1207,6 +1207,22 @@ const char *lvm_lv_get_uuid(const lv_t lv);
 const char *lvm_lv_get_name(const lv_t lv);
 
 /**
+ * Get the attributes of a logical volume.
+ *
+ * \memberof lv_t
+ *
+ * The memory allocated for the name is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * Copy of the attributes for the logical volume
+ */
+const char *lvm_lv_get_attr(const lv_t lv);
+
+/**
  * Get the current size in bytes of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 8167fc3..9d3ae79 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -48,6 +48,11 @@ const char *lvm_lv_get_name(const lv_t lv)
 			       NAME_LEN+1);
 }
 
+const char *lvm_lv_get_attr(const lv_t lv)
+{
+	return lv_attr_dup(lv->vg->vgmem, lv);
+}
+
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
 	return get_property(NULL, NULL, lv, NULL, NULL, name);
-- 
1.8.1.4


