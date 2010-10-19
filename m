From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 07:32:53 -0400
Subject: [PATCH 6/8] Add lvm_pv_get_property() generic function to obtain value of any pv property.
In-Reply-To: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287487975-26572-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a generic PV property function to lvm2app, similar to VG function.
Return lvm_property_value and require caller to check 'is_valid' flag
and lvm_errno() for API error.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   38 ++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_pv.c  |    6 ++++++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 8b244fc..ed22ed9 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1240,6 +1240,44 @@ uint64_t lvm_pv_get_size(const pv_t pv);
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
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      lvm_property_value value;
+ *      char *prop_name = "pv_mda_count";
+ *
+ *      v = lvm_pv_get_property(pv, prop_name);
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
+struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 0b6b6b1..efdccb5 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -16,6 +16,7 @@
 #include "lvm2app.h"
 #include "metadata.h"
 #include "lvm-string.h"
+#include "lvm_misc.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
@@ -48,6 +49,11 @@ uint64_t lvm_pv_get_free(const pv_t pv)
 	return (uint64_t) SECTOR_SIZE * pv_free(pv);
 }
 
+struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name)
+{
+	return get_property(pv, NULL, NULL, name);
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
-- 
1.7.2.2


