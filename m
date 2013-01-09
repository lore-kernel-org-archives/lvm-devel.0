From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  8 Jan 2013 23:53:17 -0600
Subject: [PATCH 4/4] lvm2app: Implement lv resize
In-Reply-To: <1357710797-18574-1-git-send-email-tasleson@redhat.com>
References: <1357710797-18574-1-git-send-email-tasleson@redhat.com>
Message-ID: <1357710797-18574-5-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When re-sizing a LV with the command line, after the re-size
occurs the code used to do a vg_write and then a number of
operations before and after the commit.  As the API requires
the ability to have the re-size done independantly of the
write and commit a flag was added so that when we go through
vg_commit we will do the same required steps to commit the
lv size change regardless if it was done through the command
line or the API.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/format_text/flags.c          |  1 +
 lib/metadata/lv_manip.c          | 68 ++----------------------------
 lib/metadata/metadata-exported.h |  8 ++++
 lib/metadata/metadata.c          | 90 +++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm2app.h                 |  2 -
 liblvm/lvm_lv.c                  | 19 +++++++--
 tools/lvresize.c                 | 32 ++++++++++----
 7 files changed, 142 insertions(+), 78 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a3a3d0e..4edf7e1 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -77,6 +77,7 @@ static const struct flag _lv_flags[] = {
 	{THIN_POOL, NULL, 0},
 	{THIN_POOL_DATA, NULL, 0},
 	{THIN_POOL_METADATA, NULL, 0},
+	{LV_RESIZE, NULL, 0},
 	{0, NULL, 0}
 };
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 26a137d..dd5f0ce 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3047,10 +3047,6 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
  * Core lv resize code
  */
 
-#define SIZE_BUF 128
-
-
-
 static int _validate_stripesize(struct cmd_context *cmd,
 				const struct volume_group *vg,
 				struct lvresize_params *lp)
@@ -3123,8 +3119,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 
 	return 1;
 }
-
-enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
+#define SIZE_BUF 128
 #define FSADM_CMD "fsadm"
 #define FSADM_CMD_MAX_ARGS 6
 #define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
@@ -3133,7 +3128,7 @@ enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
  * FSADM_CMD --dry-run --verbose --force check lv_path
  * FSADM_CMD --dry-run --verbose --force resize lv_path size
  */
-static int _fsadm_cmd(struct cmd_context *cmd,
+int _fsadm_cmd(struct cmd_context *cmd,
 		      const struct volume_group *vg,
 		      const struct lvresize_params *lp,
 		      enum fsadm_cmd_e fcmd,
@@ -3277,7 +3272,6 @@ int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t size_rest;
 	uint32_t pv_extent_count;
 	alloc_policy_t alloc;
-	struct logical_volume *lock_lv;
 	struct lv_list *lvl;
 	struct lv_segment *seg, *uninitialized_var(mirr_seg);
 	uint32_t seg_extents;
@@ -3714,62 +3708,8 @@ int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	/* store vg on disk(s) */
-	if (!vg_write(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	/* If snapshot, must suspend all associated devices */
-	if (lv_is_cow(lv))
-		lock_lv = origin_from_cow(lv);
-	else
-		lock_lv = lv;
-
-	if (!suspend_lv(cmd, lock_lv)) {
-		log_error("Failed to suspend %s", lp->lv_name);
-		vg_revert(vg);
-		backup(vg);
-		return ECMD_FAILED;
-	}
-
-	if (!vg_commit(vg)) {
-		stack;
-		if (!resume_lv(cmd, lock_lv))
-			stack;
-		backup(vg);
-		return ECMD_FAILED;
-	}
-
-	if (!resume_lv(cmd, lock_lv)) {
-		log_error("Problem reactivating %s", lp->lv_name);
-		backup(vg);
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	/*
-	 * Update lvm pool metadata (drop messages) if the pool has been
-	 * resumed and do a pool active/deactivate in other case.
-	 *
-	 * Note: Active thin pool can be waiting for resize.
-	 *
-	 * FIXME: Activate only when thin volume is active
-	 */
-	if (lv_is_thin_pool(lv) &&
-	    !update_pool_lv(lv, !lv_is_active(lv))) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
-
-	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	/* Set the flag to tell commit that we have addl. work todo*/
+	lv->status |= LV_RESIZE;
 
 	return ECMD_PROCESSED;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 040b2e5..a04addd 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -26,6 +26,7 @@
 #include "vg.h"
 #include "lv.h"
 #include "lvm-percent.h"
+#include "errors.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -64,6 +65,7 @@
 
 #define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
 #define LV_REBUILD		UINT64_C(0x00100000)	/* LV */
+#define LV_RESIZE		UINT64_C(0x00200000)	/* LV - internal use only */
 //#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define CONVERTING		UINT64_C(0x00400000)	/* LV */
 
@@ -500,6 +502,12 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp, struct dm_list *pvh);
 
+enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
+int _fsadm_cmd(struct cmd_context *cmd,
+		      const struct volume_group *vg,
+		      const struct lvresize_params *lp,
+		      enum fsadm_cmd_e fcmd,
+		      int *status);
 /*
  * Return a handle to VG metadata.
  */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a472b18..30f1f0b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2703,6 +2703,79 @@ static int _vg_commit_mdas(struct volume_group *vg)
 	return cache_updated;
 }
 
+/* Check to see if we have a lv that was re-sized, if yes then suspend the lv */
+static int _pre_lv_resize(struct volume_group *vg)
+{
+	struct lv_list *lvl = NULL;
+	struct logical_volume *lock_lv = NULL;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->status & LV_RESIZE) {
+			if (lv_is_cow(lvl->lv))
+				lock_lv = origin_from_cow(lvl->lv);
+			else
+				lock_lv = lvl->lv;
+
+			if (!suspend_lv(vg->cmd, lock_lv)) {
+				log_error("Failed to suspend %s", lvl->lv->name);
+				vg_revert(vg);
+				backup(vg);
+				return 0;
+			}
+		}
+	}
+	return 1;
+}
+
+/* If we have lv resize then resume the suspended lv */
+static int _post_lv_resize(struct volume_group *vg, int ok)
+{
+	struct lv_list *lvl = NULL;
+	struct logical_volume *lock_lv = NULL;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->status & LV_RESIZE) {
+
+			/* Clear the flag */
+			lvl->lv->status &= ~LV_RESIZE;
+
+			if (lv_is_cow(lvl->lv))
+				lock_lv = origin_from_cow(lvl->lv);
+			else
+				lock_lv = lvl->lv;
+
+			if (!resume_lv(vg->cmd, lock_lv)) {
+				log_error("Problem reactivating %s", lvl->lv->name);
+				backup(vg);
+				return_0;
+			}
+
+			backup(vg);
+
+			/* We could have been called after an error has occurred, in that
+			   case we will not do the next step */
+			if (ok) {
+
+				/*
+				* Update lvm pool metadata (drop messages) if the pool has been
+				* resumed and do a pool active/deactivate in other case.
+				*
+				* Note: Active thin pool can be waiting for resize.
+				*
+				* FIXME: Activate only when thin volume is active
+				*/
+				if (lv_is_thin_pool(lvl->lv) &&
+					!update_pool_lv(lvl->lv, !lv_is_active(lvl->lv))) {
+					return_0;
+				}
+			}
+		}
+	}
+
+	return 1;
+}
+
+
 /* Commit pending changes */
 int vg_commit(struct volume_group *vg)
 {
@@ -2714,9 +2787,15 @@ int vg_commit(struct volume_group *vg)
 		return cache_updated;
 	}
 
+	if (!_pre_lv_resize(vg))
+		return_0;
+
 	/* Skip if we already did this in vg_write */
 	if ((vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
-		return_0;
+	{
+		cache_updated = 0;
+		goto_out;
+	}
 
 	cache_updated = _vg_commit_mdas(vg);
 
@@ -2736,6 +2815,15 @@ int vg_commit(struct volume_group *vg)
 		log_error("Attempt to drop cached metadata failed "
 			  "after commit for VG %s.", vg->name);
 
+out:
+	if (!_post_lv_resize(vg, cache_updated)) {
+		cache_updated = 0;
+	}
+
+	if (!cache_updated) {
+		stack;
+	}
+
 	/* If at least one mda commit succeeded, it was committed */
 	return cache_updated;
 }
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 00f92ab..7515973 100644
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
index 91948a6..7e8b469 100644
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
+	if (ECMD_PROCESSED != _lvresize(lv->vg->cmd, lv->vg, &lp, &lv->vg->pvs)) {
+		log_verbose("LV Re-size failed.");
+		return -1;
+	}
+
+	return 0;
 }
 
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size)
diff --git a/tools/lvresize.c b/tools/lvresize.c
index bb576e0..3a8c464 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -14,8 +14,7 @@
  */
 
 #include "tools.h"
-
-
+#include "metadata.h"
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			    struct lvresize_params *lp)
@@ -161,7 +160,6 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
 
-
 	log_verbose("Finding volume group %s", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
@@ -173,14 +171,32 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	/* How does this list get cleaned up? */
 	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
 						     lp.argv, 1) : &vg->pvs)) {
-		stack;
-		return ECMD_FAILED;
+		r = ECMD_FAILED;
+		goto_out;
 	}
 
-	if (!(r = _lvresize(cmd, vg, &lp, pvh)))
-		stack;
+	r = _lvresize(cmd, vg, &lp, pvh);
 
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
+	if (ECMD_PROCESSED == r) {
+		if (!vg_write(vg)) {
+			r = ECMD_FAILED;
+			goto_out;
+		}
 
+		if (!vg_commit(vg)) {
+			r = ECMD_FAILED;
+			goto_out;
+		}
+
+		log_print_unless_silent("Logical volume %s successfully resized", lp.lv_name);
+
+		if (lp.resizefs && (lp.resize == LV_EXTEND) &&
+			!_fsadm_cmd(cmd, vg, &lp, FSADM_CMD_RESIZE, NULL)) {
+			r = ECMD_FAILED;
+		}
+	}
+
+out:
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
-- 
1.7.11.7


