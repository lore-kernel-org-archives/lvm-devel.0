From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  8 May 2013 17:45:37 -0500
Subject: [PATCH 15/19] lvm2app: Add method to retrieve attr from lv.
In-Reply-To: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
Message-ID: <1368053141-13836-16-git-send-email-tasleson@redhat.com>
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
index a397297..17f7382 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1216,6 +1216,22 @@ const char *lvm_lv_get_uuid(const lv_t lv);
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
index 49306e6..38813ea 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -57,6 +57,11 @@ const char *lvm_lv_get_name(const lv_t lv)
 			       NAME_LEN+1);
 }
 
+const char *lvm_lv_get_attr(const lv_t lv)
+{
+	return lv_attr_dup(lv->vg->vgmem, lv);
+}
+
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
 	return get_property(NULL, NULL, lv, NULL, NULL, NULL, name);
-- 
1.8.1.4


