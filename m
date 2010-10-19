From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 00:02:30 -0400
Subject: [PATCH 7/8] Add lvm_lv_get_property() generic function to obtain value of any lv property.
In-Reply-To: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
References: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287460951-338-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    6 ++++++
 lib/report/properties.h |    2 ++
 liblvm/lvm2app.h        |   44 ++++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c         |   20 ++++++++++++++++++++
 4 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8f9272c..c08ddfd 100644
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
index db4ae51..18e5ab9 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -32,6 +32,8 @@ struct lvm_property_type {
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
+int lv_get_property(const struct logical_volume *lv,
+		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop);
 int pv_get_property(const struct physical_volume *pv,
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 066f2ca..fbaf173 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1034,6 +1034,50 @@ const char *lvm_lv_get_name(const lv_t lv);
 uint64_t lvm_lv_get_size(const lv_t lv);
 
 /**
+ * Get the value of a LV property
+ *
+ * \memberof lv_t
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \param   name
+ * Name of property to query.  See lvs man page for full list of properties
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
+ *      char *prop_name = "seg_count";
+ *
+ *      if (lvm_lv_get_property(lv, prop_name, NULL)) {
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s'.\n", prop_name);
+ *           return;
+ *      }
+ *      if (lvm_lv_get_property(lv, prop_name, &value) < 0) {
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
+int lvm_lv_get_property(const lv_t lv, const char *name,
+			struct lvm_property_value *value);
+
+/**
  * Get the current activation state of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 7bdafe0..8dd4b0a 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -21,6 +21,7 @@
 #include "locking.h"
 #include "activate.h"
 #include "lvm_misc.h"
+#include "properties.h"
 
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
@@ -48,6 +49,25 @@ const char *lvm_lv_get_name(const lv_t lv)
 			       NAME_LEN+1);
 }
 
+int lvm_lv_get_property(const lv_t lv, const char *name,
+			struct lvm_property_value *value)
+{
+	struct lvm_property_type prop;
+
+	prop.id = name;
+	if (!lv_get_property(lv, &prop))
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
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
-- 
1.7.2.2


