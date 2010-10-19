From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 07:32:52 -0400
Subject: [PATCH 5/8] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287487975-26572-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a generic VG property function to lvm2app.  Call the internal library
vg_get_property() function.  Strings are dup'd internally.
Rework lvm_vg_get_property to return lvm_property_value and require caller
to check 'is_valid' flag and lvm_errno() for API error.
Create a 'get_property' function, local to lvm2app, that factors out
most of the common code that copies the components of lvm_property_type
into lvm_property_value.  This allows for a 1-line function for each
of the generic property functions exported by lvm2app.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h  |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_misc.c |   34 +++++++++++++++++++++++++++++
 liblvm/lvm_misc.h |    2 +
 liblvm/lvm_vg.c   |    6 +++++
 4 files changed, 103 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 47d3417..8b244fc 100644
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
@@ -168,6 +168,27 @@ typedef struct lvm_str_list {
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
+ * is_valid: indicates whether 'value' is valid (1) or not (0)
+ */
+typedef struct lvm_property_value {
+	unsigned is_settable:1;
+	unsigned is_string:1;
+	unsigned is_valid:1;
+	union {
+		const char *string;
+		uint64_t integer;
+	} value;
+} lvm_property_value_t;
+
 /*************************** generic lvm handling ***************************/
 /**
  * Create a LVM handle.
@@ -848,6 +869,45 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
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
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "vg_mda_count";
+ *
+ *      v = lvm_vg_get_property(vg, prop_name);
+ *      if (lvm_errno(libh) || !v.is_valid) {
+ *           // handle error
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s'.\n", prop_name);
+ *           return;
+ *      }
+ *      if (v.is_string)
+ *           printf(", value = %s\n", v.value.string);
+ *	else
+ *           printf(", value = %"PRIu64"\n", v.value.integer);
+ *
+ *
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check lvm_errno() as well
+ * as 'is_valid' flag before using the value.
+ */
+struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name);
+
 /************************** logical volume handling *************************/
 
 /**
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index e339faa..52f3636 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -15,6 +15,7 @@
 #include "lvm2app.h"
 #include "lvm_misc.h"
 #include "lib.h"
+#include "properties.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
@@ -43,3 +44,36 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 	}
 	return list;
 }
+
+struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
+				       const lv_t lv, const char *name)
+{
+	struct lvm_property_type prop;
+	struct lvm_property_value v;
+
+	prop.id = name;
+	if (pv) {
+		if (!pv_get_property(pv, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
+	} else if (vg) {
+		if (!vg_get_property(vg, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
+	} else if (lv) {
+		if (!lv_get_property(lv, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
+	}
+	v.is_settable = prop.is_settable;
+	v.is_string = prop.is_string;
+	if (v.is_string)
+		v.value.string = prop.value.string;
+	else
+		v.value.integer = prop.value.integer;
+	v.is_valid = 1;
+	return v;
+}
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index ced1f0f..b4e675e 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -17,5 +17,7 @@
 #include "libdevmapper.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
+struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
+				       const lv_t lv, const char *name);
 
 #endif
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a09208a..6970910 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -335,6 +335,12 @@ const char *lvm_vg_get_name(const vg_t vg)
 	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
 }
 
+
+struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
+{
+	return get_property(NULL, vg, NULL, name);
+}
+
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);
-- 
1.7.2.2


