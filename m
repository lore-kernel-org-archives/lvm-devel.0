From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:52:01 -0400
Subject: [PATCH 10/11] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a generic VG property function to lvm2app.  Call the internal library
vg_get_property() function.  If the property is a string strdup from the
vg mempool.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   42 ++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_vg.c  |   19 +++++++++++++++++++
 2 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 47d3417..cc839a6 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -168,6 +168,22 @@ typedef struct lvm_str_list {
 	const char *str;
 } lvm_str_list_t;
 
+/**
+ * Property Value
+ *
+ * This structure defines a single LVM property value for an LVM object.
+ * The structures are returned by functions such as
+ * lvm_vg_get_property() and lvm_vg_set_property().
+ */
+typedef struct lvm_property_value {
+	unsigned is_writeable;
+	unsigned is_string;
+	union {
+		char *s_val;
+		uint64_t n_val;
+	} v;
+} lvm_property_value_t;
+
 /*************************** generic lvm handling ***************************/
 /**
  * Create a LVM handle.
@@ -848,6 +864,32 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
  */
 struct dm_list *lvm_vg_get_tags(const vg_t vg);
 
+/**
+ * Get the value of a VG property
+ *
+ * \memberof vg_t
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value value;
+ *
+ *      if (lvm_vg_get_property(vg, "vg_mda_count", &value) < 0) {
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
+int lvm_vg_get_property(vg_t vg, const char *name,
+			struct lvm_property_value *value);
+
 /************************** logical volume handling *************************/
 
 /**
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a75652d..7b8be78 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -20,6 +20,7 @@
 #include "locking.h"
 #include "lvmcache.h"
 #include "lvm_misc.h"
+#include "properties.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
@@ -341,6 +342,24 @@ const char *lvm_vg_get_name(const vg_t vg)
 	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
 }
 
+
+int lvm_vg_get_property(vg_t vg, const char *name,
+			struct lvm_property_value *value)
+{
+	struct lvm_property_type prop;
+
+	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
+	if (!vg_get_property(vg, &prop))
+		return -1;
+	value->is_writeable = prop.is_writeable;
+	value->is_string = prop.is_string;
+	if (value->is_string)
+		value->v.s_val = dm_pool_strdup(vg->vgmem, prop.v.s_val);
+	else
+		value->v.n_val = prop.v.n_val;
+	return 0;
+}
+
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);
-- 
1.7.2.1


