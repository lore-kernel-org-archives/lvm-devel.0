From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 26 Jul 2009 15:13:04 -0400
Subject: [PATCH 2/4] Add lvm_lv_is_active and lvm_lv_is_suspended.
In-Reply-To: <1248635586-8139-2-git-send-email-dwysocha@redhat.com>
References: <1248635586-8139-1-git-send-email-dwysocha@redhat.com>
	<1248635586-8139-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1248635586-8139-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Return whether an LV is active in the kernel (live table) or suspended
(table suspend).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    2 ++
 liblvm/lvm.h             |   18 ++++++++++++++++++
 liblvm/lvm_lv.c          |   19 +++++++++++++++++++
 3 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 6708154..9911423 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -17,6 +17,8 @@ lvm_lv_deactivate
 lvm_lv_get_uuid
 lvm_lv_get_name
 lvm_lv_get_size
+lvm_lv_is_active
+lvm_lv_is_suspended
 lvm_vg_create
 lvm_vg_extend
 lvm_vg_set_extent_size
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index c5c4486..2e8d5c6 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -514,6 +514,24 @@ char *lvm_lv_get_name(const lv_t *lv);
  */
 uint64_t lvm_lv_get_size(const lv_t *lv);
 
+/**
+ * Get the current activation state of a logical volume.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  1 if the LV is active in the kernel, 0 if not
+ */
+uint64_t lvm_lv_is_active(const lv_t *lv);
+
+/**
+ * Get the current suspended state of a logical volume.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  1 if the LV is suspended in the kernel, 0 if not
+ */
+uint64_t lvm_lv_is_suspended(const lv_t *lv);
+
 /************************** physical volume handling ************************/
 
 /**
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 4a12030..7d0ec01 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -19,6 +19,7 @@
 #include "defaults.h"
 #include "segtype.h"
 #include "locking.h"
+#include "activate.h"
 
 #include <string.h>
 
@@ -49,6 +50,24 @@ char *lvm_lv_get_name(const lv_t *lv)
 	return name;
 }
 
+uint64_t lvm_lv_is_active(const lv_t *lv)
+{
+	struct lvinfo info;
+	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
+	    info.exists && info.live_table)
+		return 1;
+	return 0;
+}
+
+uint64_t lvm_lv_is_suspended(const lv_t *lv)
+{
+	struct lvinfo info;
+	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
+	    info.exists && info.suspended)
+		return 1;
+	return 0;
+}
+
 /* Set defaults for non-segment specific LV parameters */
 static void _lv_set_default_params(struct lvcreate_params *lp,
 				   vg_t *vg, const char *lvname,
-- 
1.6.0.6


