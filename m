From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 00:02:29 -0400
Subject: [PATCH 6/8] Add lvm_pv_get_property() generic function to obtain value of any pv property.
In-Reply-To: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
References: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287460951-338-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_pv.c  |   20 ++++++++++++++++++++
 2 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 32a138b..066f2ca 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1244,6 +1244,52 @@ uint64_t lvm_pv_get_size(const pv_t pv);
 uint64_t lvm_pv_get_free(const pv_t pv);
 
 /**
+ * Get the value of a PV property
+ *
+ * \memberof pv_t
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \param   name
+ * Name of property to query.  See pvs man page for full list of properties
+ * that may be queried.
+ *
+ * \param   value
+ * Pointer to an lvm_property_value structure that will contain the current
+ * value of the property.  The pointer may be NULL if just checking the
+ * name of the property.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value value;
+ *      char *prop_name = "pv_mda_count";
+ *
+ *      if (lvm_pv_get_property(pv, prop_name, NULL)) {
+ *           // handle error
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s'.\n", prop_name);
+ *           return;
+ *      }
+ *
+ *      if (lvm_pv_get_property(pv, prop_name, &value) < 0) {
+ *              // handle error
+ *      }
+ *      if (value.is_string)
+ *           printf(", value = %s\n", value.value.string);
+ *	else
+ *           printf(", value = %"PRIu64"\n", value.value.integer);
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
index 0b6b6b1..5f0dd7d 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -16,6 +16,7 @@
 #include "lvm2app.h"
 #include "metadata.h"
 #include "lvm-string.h"
+#include "properties.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
@@ -48,6 +49,25 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 	return (uint64_t) SECTOR_SIZE * pv_free(pv);
 }
 
+int lvm_pv_get_property(const pv_t pv, const char *name,
+			struct lvm_property_value *value)
+{
+	struct lvm_property_type prop;
+
+	prop.id = name;
+	if (!pv_get_property(pv, &prop))
+		return -1;
+	if (!value)
+		return 0;
+	value->is_settable = prop.is_settable;
+	value->is_string = prop.is_string;
+	if (value->is_string)
+		value->value.string = prop.value.string;
+	else
+		value->value.integer = prop.value.integer;
+	return 0;
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
-- 
1.7.2.2


