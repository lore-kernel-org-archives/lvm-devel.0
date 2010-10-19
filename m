From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 07:32:54 -0400
Subject: [PATCH 7/8] Add lvm_lv_get_property() generic function to obtain value of any lv property.
In-Reply-To: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287487975-26572-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a generic LV property function to lvm2app, similar to VG function.
Return lvm_property_value and require caller to check 'is_valid' flag
and lvm_errno() for API error.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    6 ++++++
 lib/report/properties.h |    2 ++
 liblvm/lvm2app.h        |   38 ++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c         |    5 +++++
 4 files changed, 51 insertions(+), 0 deletions(-)

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
index ed22ed9..e90adf8 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1030,6 +1030,44 @@ const char *lvm_lv_get_name(const lv_t lv);
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
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value v;
+ *      char *prop_name = "seg_count";
+ *
+ *      v = lvm_lv_get_property(lv, prop_name);
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
+struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name);
+
+/**
  * Get the current activation state of a logical volume.
  *
  * \memberof lv_t
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 7bdafe0..cef87f5 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -48,6 +48,11 @@ const char *lvm_lv_get_name(const lv_t lv)
 			       NAME_LEN+1);
 }
 
+struct lvm_property_value lvm_lv_get_property(const lv_t lv, const char *name)
+{
+	return get_property(NULL, NULL, lv, name);
+}
+
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
-- 
1.7.2.2


