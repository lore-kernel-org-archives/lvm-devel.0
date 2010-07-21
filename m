From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Jul 2010 09:56:14 -0400
Subject: [PATCH 3/4] Add lvm_vg_get_attr_value() generic vg attibute function.
In-Reply-To: <1279720575-27485-3-git-send-email-dwysocha@redhat.com>
References: <1279720575-27485-1-git-send-email-dwysocha@redhat.com>
	<1279720575-27485-2-git-send-email-dwysocha@redhat.com>
	<1279720575-27485-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1279720575-27485-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Call into lvm internal report_value() function to return a single
field value.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   26 ++++++++++++++++++++++++++
 liblvm/lvm_vg.c  |    8 ++++++++
 2 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 5bd78ee..39d1822 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -848,6 +848,32 @@ uint64_t lvm_vg_get_max_lv(const vg_t vg);
  */
 struct dm_list *lvm_vg_get_tags(const vg_t vg);
 
+/**
+ * Get the value of the VG attribute 'attr_name'.
+ *
+ * \memberof vg_t
+ *
+ * The memory allocated for a string attribute value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example:
+ *      dm_report_field_value_type value;
+ *
+ *      if (lvm_vg_get_attr_value(vg, "vg_mda_count", &value) < 0) {
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
+int lvm_vg_get_attr_value(vg_t vg, const char *attr_name,
+			  struct dm_report_field_value_type *value);
+
 /************************** logical volume handling *************************/
 
 /**
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a75652d..c08490d 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -20,6 +20,7 @@
 #include "locking.h"
 #include "lvmcache.h"
 #include "lvm_misc.h"
+#include "report.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
@@ -341,6 +342,13 @@ const char *lvm_vg_get_name(const vg_t vg)
 	return dm_pool_strndup(vg->vgmem, (const char *)vg->name, NAME_LEN+1);
 }
 
+int lvm_vg_get_attr_value(vg_t vg, const char *attr_name,
+			  struct dm_report_field_value_type *value)
+{
+	return !report_value(vg, NULL, NULL, NULL, NULL,
+			     attr_name, value);
+}
+
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);
-- 
1.6.0.6


