From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 26 Jul 2009 15:13:03 -0400
Subject: [PATCH 1/4] Implement lvm_lv_activate and lvm_lv_deactivate liblvm calls.
In-Reply-To: <1248635586-8139-1-git-send-email-dwysocha@redhat.com>
References: <1248635586-8139-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248635586-8139-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Limited implementation but other types of activation should probably have
separate calls.  We also currently do not handle pvmoves or lvconverts.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/.exported_symbols |    2 ++
 liblvm/lvm.h             |   25 +++++++++++++++++++++++++
 liblvm/lvm_lv.c          |   44 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index d0e87df..6708154 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -12,6 +12,8 @@ lvm_vg_get_extent_size
 lvm_vg_get_extent_count
 lvm_vg_get_free_extent_count
 lvm_vg_get_pv_count
+lvm_lv_activate
+lvm_lv_deactivate
 lvm_lv_get_uuid
 lvm_lv_get_name
 lvm_lv_get_size
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index ac64ca2..c5c4486 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -441,6 +441,31 @@ struct dm_list *lvm_vg_list_lvs(vg_t *vg);
 lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
 
 /**
+ * Activate a logical volume.
+ *
+ * This API is the equivalent of the lvm command "lvchange -ay".
+ *
+ * NOTE: This API cannot currently handle LVs with an in-progress pvmove or
+ * lvconvert.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_lv_activate(lv_t *lv);
+
+/**
+ * Deactivate a logical volume.
+ *
+ * This API is the equivalent of the lvm command "lvchange -an".
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_lv_deactivate(lv_t *lv);
+
+/**
  * Remove a logical volume from a volume group.
  *
  * This function commits the change to disk and does _not_ require calling
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 556d457..4a12030 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -18,6 +18,8 @@
 #include "lvm-string.h"
 #include "defaults.h"
 #include "segtype.h"
+#include "locking.h"
+
 #include <string.h>
 
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
@@ -102,3 +104,45 @@ int lvm_vg_remove_lv(lv_t *lv)
 		return 0;
 	return lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT);
 }
+
+int lvm_lv_activate(lv_t *lv)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
+		return 0;
+
+	/* FIXME: handle pvmove stuff later */
+	if (lv->status & LOCKED) {
+		log_error("Unable to activate locked LV\n");
+		return 0;
+	}
+
+	/* FIXME: handle lvconvert stuff later */
+	if (lv->status & CONVERTING) {
+		log_error("Unable to activate LV with in-progress lvconvert\n");
+		return 0;
+	}
+
+	if (lv_is_origin(lv)) {
+		log_verbose("Activating logical volume \"%s\" "
+			    "exclusively", lv->name);
+		if (!activate_lv_excl(lv->vg->cmd, lv))
+			return_0;
+	} else {
+		log_verbose("Activating logical volume \"%s\"",
+			    lv->name);
+		if (!activate_lv(lv->vg->cmd, lv))
+			return_0;
+	}
+	return 1;
+}
+
+int lvm_lv_deactivate(lv_t *lv)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
+		return 0;
+
+	log_verbose("Deactivating logical volume \"%s\"", lv->name);
+	if (!deactivate_lv(lv->vg->cmd, lv))
+		return_0;
+	return 1;
+}
-- 
1.6.0.6


