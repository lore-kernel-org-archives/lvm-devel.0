From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 22 Oct 2010 07:51:09 -0400
Subject: [PATCH 4/5] Add lvm_lv_get_property() generic function to obtain value of any lv propert
In-Reply-To: <1287748270-26875-1-git-send-email-dwysocha@redhat.com>
References: <1287748270-26875-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287748270-26875-5-git-send-email-dwysocha@redhat.com>
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
 liblvm/lvm2app.h |   38 ++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_lv.c  |    5 +++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 13ece31..59825fb 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1032,6 +1032,44 @@ const char *lvm_lv_get_name(const lv_t lv);
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
+ *      if (!v.is_valid) {
+ *           printf("Invalid property name or unable to query"
+ *                  "'%s', errno = %d.\n", prop_name, lvm_errno(libh));
+ *           return;
+ *      }
+ *      if (v.is_string)
+ *           printf(", value = %s\n", v.value.string);
+ *	if (v.is_integer)
+ *           printf(", value = %"PRIu64"\n", v.value.integer);
+ *
+ * \return
+ * lvm_property_value structure that will contain the current
+ * value of the property.  Caller should check 'is_valid' flag before using
+ * the value.  If 'is_valid' is not set, caller should check lvm_errno()
+ * for specific error.
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


