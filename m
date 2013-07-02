From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:08 +0000 (UTC)
Subject: master - lvm2app: Implement lv resize (v3)
Message-ID: <20130702192608.DB4C660F45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49d7596581be013ec71a1da7897f861b721eaa19
Commit:        49d7596581be013ec71a1da7897f861b721eaa19
Parent:        c43ce46ba796d92382b386bbeee933fc7479a9cd
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 13 18:07:16 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:33 2013 -0500

lvm2app: Implement lv resize (v3)

Simplified version of lv resize.

v3: Rebase changes to make work.  Needed to set sizeargs = 1
to indicate to resize that we are asking for a size based
resize.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 liblvm/lvm2app.h                 |    2 --
 liblvm/lvm_lv.c                  |   20 +++++++++++++++++---
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f07e360..ee8f0c1 100644
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
index 2039126..d0f89f1 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -318,9 +318,23 @@ int lvm_lv_rename(lv_t lv, const char *new_name)
 
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
+	lp.sizeargs = 1;
+
+	if (ECMD_PROCESSED != lv_resize(lv->vg->cmd, lv->vg, &lp, &lv->vg->pvs)) {
+		log_verbose("LV Re-size failed.");
+		return -1;
+	}
+
+	return 0;
 }
 
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size)


