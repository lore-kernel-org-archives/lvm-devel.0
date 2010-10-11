From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:37 -0400
Subject: [PATCH 13/14] Add lvm_lv_get_property() generic function to obtain value of any lv property.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-14-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    6 ++++++
 lib/report/properties.h |    2 ++
 liblvm/lvm2app.h        |   26 ++++++++++++++++++++++++++
 liblvm/lvm_lv.c         |   18 ++++++++++++++++++
 4 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 250c7c9..56372da 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -267,6 +267,12 @@ static int _get_property(const void *obj, struct lvm_property_type *prop,
 	return 1;
 }
 
+int lv_get_property(const struct logical_volume *lv,
+		    struct lvm_property_type *prop)
+{
+	return _get_property(lv, prop, LVS);
+}
+
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop)
 {
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 7398f2f..5956604 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -34,6 +34,8 @@ struct lvm_property_type {
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
+int lv_get_property(const struct logical_volume *lv,
+		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop);
 int pv_get_property(const struct physical_volume *pv,
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index b6cc729..126700a 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1012,6 +1012,32 @@ const char *lvm_lv_get_name(const lv_t lv);
 uint64_t lvm_lv_get_size(const lv_t lv);
 
 /**
+ * Get the value of a LV property
+ *
+ * \memberof pv_t
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value value;
+ *
+ *      if (lvm_lv_get_property(pv, "seg_count", &value) < 0) {
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
+int lvm_lv_get_property(const lv_t lv, const char *name,
+			struct lvm_property_value *value);
+
+/**
  * Get the current activation state of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 7bdafe0..76e8691 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -21,6 +21,7 @@
 #include "locking.h"
 #include "activate.h"
 #include "lvm_misc.h"
+#include "properties.h"
 
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
@@ -48,6 +49,23 @@ const char *lvm_lv_get_name(const lv_t lv)
 			       NAME_LEN+1);
 }
 
+int lvm_lv_get_property(const lv_t lv, const char *name,
+			struct lvm_property_value *value)
+{
+	struct lvm_property_type prop;
+
+	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
+	if (!lv_get_property(lv, &prop))
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
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
-- 
1.7.2.2


