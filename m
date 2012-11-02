From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  2 Nov 2012 15:33:08 -0500
Subject: [PATCH 1/3] liblvm: Breakout required operations for re-size into vg_commit
In-Reply-To: <1351888390-12619-1-git-send-email-tasleson@redhat.com>
References: <1351888390-12619-1-git-send-email-tasleson@redhat.com>
Message-ID: <1351888390-12619-2-git-send-email-tasleson@redhat.com>
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
 lib/format_text/flags.c          |    1 +
 lib/metadata/metadata-exported.h |    3 +-
 lib/metadata/metadata.c          |   87 +++++++++++++++++++++++++++++++++++++-
 tools/lvresize.c                 |   84 ++++++++++--------------------------
 4 files changed, 113 insertions(+), 62 deletions(-)

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
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1ba6550..b1cc985 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -62,8 +62,9 @@
 #define MIRROR_LOG		UINT64_C(0x00020000)	/* LV */
 #define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
 
-#define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
+#define LV_NOTSYNCED	UINT64_C(0x00080000)	/* LV */
 #define LV_REBUILD		UINT64_C(0x00100000)	/* LV */
+#define LV_RESIZE		UINT64_C(0x00200000)	/* LV - internal use only */
 //#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define CONVERTING		UINT64_C(0x00400000)	/* LV */
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 549a356..78db45f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2696,6 +2696,80 @@ static int _vg_commit_mdas(struct volume_group *vg)
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
+				return 0;
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
+					stack;
+					return 0;
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
@@ -2707,9 +2781,15 @@ int vg_commit(struct volume_group *vg)
 		return cache_updated;
 	}
 
-	if (!lvmetad_vg_update(vg))
+	if (!_pre_lv_resize(vg))
 		return 0;
 
+	if (!lvmetad_vg_update(vg)) {
+		cache_updated = 0;
+		goto out;
+	}
+
+
 	cache_updated = _vg_commit_mdas(vg);
 
 	if (cache_updated) {
@@ -2728,6 +2808,11 @@ int vg_commit(struct volume_group *vg)
 		log_error("Attempt to drop cached metadata failed "
 			  "after commit for VG %s.", vg->name);
 
+out:
+	if (!_post_lv_resize(vg, cache_updated)) {
+		cache_updated = 0;
+	}
+
 	/* If at least one mda commit succeeded, it was committed */
 	return cache_updated;
 }
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 4c9580d..a32751d 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -374,7 +374,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t size_rest;
 	uint32_t pv_extent_count;
 	alloc_policy_t alloc;
-	struct logical_volume *lock_lv;
 	struct lv_list *lvl;
 	struct lv_segment *seg, *uninitialized_var(mirr_seg);
 	uint32_t seg_extents;
@@ -824,62 +823,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
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
@@ -901,10 +846,29 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!(r = _lvresize(cmd, vg, &lp)))
-		stack;
+	r = _lvresize(cmd, vg, &lp);
 
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
+	if (ECMD_PROCESSED == r) {
+		if (!vg_write(vg)) {
+			stack;
+			r = ECMD_FAILED;
+			goto out;
+		}
+
+		if (!vg_commit(vg)) {
+			r = ECMD_FAILED;
+			goto out;
+		}
+
+		log_print_unless_silent("Logical volume %s successfully resized", lp.lv_name);
 
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
1.7.1


