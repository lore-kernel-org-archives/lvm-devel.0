From: Tony Asleson <tasleson@redhat.com>
Date: Mon,  1 Apr 2013 16:34:59 -0500
Subject: [PATCH 5/7] lvm2app: Implement lv resize (v2)
In-Reply-To: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
References: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
Message-ID: <1364852101-14961-5-git-send-email-tasleson@redhat.com>
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
index c88e68a..b9b925b 100644
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
index 935c53b..98585c0 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1365,8 +1365,6 @@ int lvm_lv_rename(lv_t lv, const char *new_name);
  *
  * \memberof lv_t
  *
- * NOTE: This function is currently not implemented.
- *
  * \param   lv
  * Logical volume handle.
  *
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 91948a6..8167fc3 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -309,9 +309,22 @@ int lvm_lv_rename(lv_t lv, const char *new_name)
 
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


