From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 00:02:28 -0400
Subject: [PATCH 5/8] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
References: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287460951-338-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a generic VG property function to lvm2app.  Call the internal library
vg_get_property() function.  Strings are dup'd internally.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_vg.c  |   21 +++++++++++++++++
 2 files changed, 86 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 47d3417..32a138b 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -139,7 +139,7 @@ typedef struct physical_volume *pv_t;
 /**
  * Logical Volume object list.
  *
- * Lists of these structures are returned by lvm_vg_list_pvs().
+ * Lists of these structures are returned by lvm_vg_list_lvs().
  */
 typedef struct lvm_lv_list {
 	struct dm_list list;
@@ -168,6 +168,25 @@ typedef struct lvm_str_list {
 	const char *str;
 } lvm_str_list_t;
 
+/**
+ * Property Value
+ *
+ * This structure defines a single LVM property value for an LVM object.
+ * The structures are returned by functions such as
+ * lvm_vg_get_property() and lvm_vg_set_property().
+ *
+ * is_settable: indicates whether a 'set' function exists for this property
+ * is_string: indicates whether this property is a string (1) or integer (0)
+ */
+typedef struct lvm_property_value {
+	unsigned is_settable:1;
+	unsigned is_string:1;
+	union {
+		const char *string;
+		uint64_t integer;
+	} value;
+} lvm_property_value_t;
+
 /*************************** generic lvm handling ***************************/
 /**
  * Create a LVM handle.
@@ -848,6 +867,51 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
  */
 struct dm_list *lvm_vg_get_tags(const vg_t vg);
 
+/**
+ * Get the value of a VG property
+ *
+ * \memberof vg_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   name
+ * Name of property to query.  See vgs man page for full list of properties
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
+ *      char *prop_name = "vg_mda_count";
+ *
+ *      if (lvm_vg_get_property(vg, prop_name, NULL)) {
+ *           // handle error
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s'.\n", prop_name);
+ *           return;
+ *      }
+ *      if (lvm_vg_get_property(vg, prop_name, &value) < 0) {
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
+int lvm_vg_get_property(const vg_t vg, const char *name,
+			struct lvm_property_value *value);
+
 /************************** logical volume handling *************************/
 
 /**
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a09208a..94b3723 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -20,6 +20,7 @@
 #include "locking.h"
 #include "lvmcache.h"
 #include "lvm_misc.h"
+#include "properties.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
@@ -335,6 +336,26 @@ const char *lvm_vg_get_name(const vg_t vg)
 	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
 }
 
+
+int lvm_vg_get_property(const vg_t vg, const char *name,
+			struct lvm_property_value *value)
+{
+	struct lvm_property_type prop;
+
+	prop.id = name;
+	if (!vg_get_property(vg, &prop))
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
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);
-- 
1.7.2.2


