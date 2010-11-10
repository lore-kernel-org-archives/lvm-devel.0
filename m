From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:11:56 -0500
Subject: [PATCH 3/7] Add lvm_lvseg_get_property() function.
In-Reply-To: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
References: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289405520-19964-4-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dave Wysochanski <dwysocha@redhat.com>

Add lvm2app function to query lvseg properties.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h  |   39 +++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c   |    8 +++++++-
 liblvm/lvm_misc.c |    8 +++++++-
 liblvm/lvm_misc.h |    3 ++-
 liblvm/lvm_pv.c   |    2 +-
 liblvm/lvm_vg.c   |    2 +-
 6 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 82ed383..744d343 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1102,6 +1102,45 @@ uint64_t lvm_lv_get_size(const lv_t lv);
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name);
 
 /**
+ * Get the value of a LV segment property
+ *
+ * \memberof lv_t
+ *
+ * \param   lvseg
+ * Logical volume segment handle.
+ *
+ * \param   name
+ * Name of property to query.  See lvs man page for full list of properties
+ * that may be queried.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "seg_start_pe";
+ *
+ *      v = lvm_lvseg_get_property(lvseg, prop_name);
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
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check lvm_errno() as well
+ * as 'is_valid' flag before using the value.
+ */
+struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
+						 const char *name);
+
+/**
  * Get the current activation state of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 42982f9..5d6f110 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -50,7 +50,13 @@ const char *lvm_lv_get_name(const lv_t lv)
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, name);
+	return get_property(NULL, NULL, lv, NULL, name);
+}
+
+struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
+						 const char *name)
+{
+	return get_property(NULL, NULL, NULL, lvseg, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index adec2bc..f19efb2 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -46,7 +46,8 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 }
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
-				       const lv_t lv, const char *name)
+				       const lv_t lv, const lvseg_t lvseg,
+				       const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v;
@@ -67,6 +68,11 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 			v.is_valid = 0;
 			return v;
 		}
+	} else if (lvseg) {
+		if (!lvseg_get_property(lvseg, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
 	}
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index b4e675e..918482e 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -18,6 +18,7 @@
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
-				       const lv_t lv, const char *name);
+				       const lv_t lv, const lvseg_t lvseg,
+				       const char *name);
 
 #endif
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index efdccb5..6705dd8 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -51,7 +51,7 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, name);
 }
 
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 6970910..bc92ca2 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -338,7 +338,7 @@ const char *lvm_vg_get_name(const vg_t vg)
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, name);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
-- 
1.7.2.2


