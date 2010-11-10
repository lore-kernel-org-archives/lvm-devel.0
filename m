From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:11:59 -0500
Subject: [PATCH 6/7] Add lvm_pvseg_get_property() function.
In-Reply-To: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
References: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289405520-19964-7-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add lvm2app function to query pvseg properties.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h  |   39 +++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c   |    4 ++--
 liblvm/lvm_misc.c |    7 ++++++-
 liblvm/lvm_misc.h |    2 +-
 liblvm/lvm_pv.c   |    8 +++++++-
 liblvm/lvm_vg.c   |    2 +-
 6 files changed, 56 insertions(+), 6 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index de6e8a3..90a89f5 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1407,6 +1407,45 @@ uint64_t lvm_pv_get_free(const pv_t pv);
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name);
 
 /**
+ * Get the value of a PV segment property
+ *
+ * \memberof pv_t
+ *
+ * \param   pvseg
+ * Physical volume segment handle.
+ *
+ * \param   name
+ * Name of property to query.  See pvs man page for full list of properties
+ * that may be queried.
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "pvseg_start";
+ *
+ *      v = lvm_pvseg_get_property(pvseg, prop_name);
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
+struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
+						 const char *name);
+
+/**
  * Return a list of pvseg handles for a given PV handle.
  *
  * \memberof pv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 5d6f110..ec5fec0 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -50,13 +50,13 @@ const char *lvm_lv_get_name(const lv_t lv)
 
 struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
 {
-	return get_property(NULL, NULL, lv, NULL, name);
+	return get_property(NULL, NULL, lv, NULL, NULL, name);
 }
 
 struct lvm_property_value lvm_lvseg_get_property(const lvseg_t lvseg,
 						 const char *name)
 {
-	return get_property(NULL, NULL, NULL, lvseg, name);
+	return get_property(NULL, NULL, NULL, lvseg, NULL, name);
 }
 
 uint64_t lvm_lv_is_active(const lv_t lv)
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index f19efb2..e3d9a5f 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -47,7 +47,7 @@ struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const char *name)
+				       const pvseg_t pvseg, const char *name)
 {
 	struct lvm_property_type prop;
 	struct lvm_property_value v;
@@ -73,6 +73,11 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 			v.is_valid = 0;
 			return v;
 		}
+	} else if (pvseg) {
+		if (!pvseg_get_property(pvseg, &prop)) {
+			v.is_valid = 0;
+			return v;
+		}
 	}
 	v.is_settable = prop.is_settable;
 	v.is_string = prop.is_string;
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index 918482e..55775b0 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -19,6 +19,6 @@
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const lvseg_t lvseg,
-				       const char *name);
+				       const pvseg_t pvseg, const char *name);
 
 #endif
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index aaaca92..9ca92d5 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -51,7 +51,13 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
 {
-	return get_property(pv, NULL, NULL, NULL, name);
+	return get_property(pv, NULL, NULL, NULL, NULL, name);
+}
+
+struct lvm_property_value lvm_pvseg_get_property(const pvseg_t pvseg,
+						 const char *name)
+{
+	return get_property(NULL, NULL, NULL, NULL, pvseg, name);
 }
 
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index bc92ca2..e9fb959 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -338,7 +338,7 @@ const char *lvm_vg_get_name(const vg_t vg)
 
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 {
-	return get_property(NULL, vg, NULL, NULL, name);
+	return get_property(NULL, vg, NULL, NULL, NULL, name);
 }
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
-- 
1.7.2.2


