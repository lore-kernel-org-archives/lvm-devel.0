From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:36 -0400
Subject: [PATCH 12/14] Add lvm_pv_get_property() generic function to obtain value of any pv property.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   26 ++++++++++++++++++++++++++
 liblvm/lvm_pv.c  |   18 ++++++++++++++++++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index b5008c1..b6cc729 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1222,6 +1222,32 @@ uint64_t lvm_pv_get_size(const pv_t pv);
 uint64_t lvm_pv_get_free(const pv_t pv);
 
 /**
+ * Get the value of a PV property
+ *
+ * \memberof pv_t
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value value;
+ *
+ *      if (lvm_pv_get_property(pv, "pv_mda_count", &value) < 0) {
+ *              // handle error
+ *      }
+ *      if (value.is_string)
+ *           printf(", value = %s\n", value.u.s_val);
+ *	else
+ *           printf(", value = %"PRIu64"\n", value.u.n_val);
+ *
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_pv_get_property(const pv_t pv, const char *name,
+			struct lvm_property_value *value);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 0b6b6b1..2e3c3e9 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -16,6 +16,7 @@
 #include "lvm2app.h"
 #include "metadata.h"
 #include "lvm-string.h"
+#include "properties.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
@@ -48,6 +49,23 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 	return (uint64_t) SECTOR_SIZE * pv_free(pv);
 }
 
+int lvm_pv_get_property(const pv_t pv, const char *name,
+			struct lvm_property_value *value)
+{
+	struct lvm_property_type prop;
+
+	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
+	if (!pv_get_property(pv, &prop))
+		return -1;
+	value->is_writeable = prop.is_writeable;
+	value->is_string = prop.is_string;
+	if (value->is_string)
+		value->v.s_val = prop.v.s_val;
+	else
+		value->v.n_val = prop.v.n_val;
+	return 0;
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
-- 
1.7.2.2


