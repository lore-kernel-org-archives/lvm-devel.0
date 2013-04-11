From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 11 Apr 2013 15:58:50 -0500
Subject: [PATCH 1/2] lvm2app: Add function to retrieve the origin.
Message-ID: <1365713931-12666-1-git-send-email-tasleson@redhat.com>
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
index 15827ac..369c300 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1223,6 +1223,22 @@ const char *lvm_lv_get_name(const lv_t lv);
 const char *lvm_lv_get_attr(const lv_t lv);
 
 /**
+ * Get the origin of a snapshot.
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
+ * Null if the logical volume is not a snapshot, else origin name.
+ */
+const char *lvm_lv_get_origin(const lv_t lv);
+
+/**
  * Get the current size in bytes of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 9d3ae79..f244a60 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -53,6 +53,11 @@ const char *lvm_lv_get_attr(const lv_t lv)
 	return lv_attr_dup(lv->vg->vgmem, lv);
 }
 
+const char *lvm_lv_get_origin(const lv_t lv)
+{
+	return lv_origin_dup(lv->vg->vgmem, lv);
+}
+
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
 	return get_property(NULL, NULL, lv, NULL, NULL, name);
-- 
1.8.1.4


