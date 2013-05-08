From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  8 May 2013 17:45:28 -0500
Subject: [PATCH 06/19] lvm2app: Implement lv resize (v2)
In-Reply-To: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
Message-ID: <1368053141-13836-7-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Simplified version of lv resize.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |  1 +
 liblvm/lvm2app.h                 |  2 --
 liblvm/lvm_lv.c                  | 19 ++++++++++++++++---
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c8621ab..21ea86d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -26,6 +26,7 @@
 #include "vg.h"
 #include "lv.h"
 #include "lvm-percent.h"
+#include "errors.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 633b026..25778d1 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1374,8 +1374,6 @@ int lvm_lv_rename(lv_t lv, const char *new_name);
  *
  * \memberof lv_t
  *
- * NOTE: This function is currently not implemented.
- *
  * \param   lv
  * Logical volume handle.
  *
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 4fbd06b..49306e6 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -318,9 +318,22 @@ int lvm_lv_rename(lv_t lv, const char *new_name)
 
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
-	/* FIXME: add lv resize code here */
-	log_error("NOT IMPLEMENTED YET");
-	return -1;
+	struct lvresize_params lp = { 0 };
+
+	lp.vg_name = lv->vg->name;
+	lp.lv_name = lv->name;
+	lp.sign = SIGN_NONE;
+	lp.percent = PERCENT_NONE;
+	lp.resize = LV_ANY;
+	lp.size = new_size >> SECTOR_SHIFT;
+	lp.ac_force = 1;	/* Assume the user has a good backup? */
+
+	if (ECMD_PROCESSED != lv_resize(lv->vg->cmd, lv->vg, &lp, &lv->vg->pvs)) {
+		log_verbose("LV Re-size failed.");
+		return -1;
+	}
+
+	return 0;
 }
 
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size)
-- 
1.8.1.4


