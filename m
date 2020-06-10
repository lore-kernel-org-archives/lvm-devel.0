From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:38 +0000 (GMT)
Subject: master - writecache: remove from an active lv
Message-ID: <20200610173138.2CFD73858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=240062a18365a7f6725ebcf1b035a6e0a3b12803
Commit:        240062a18365a7f6725ebcf1b035a6e0a3b12803
Parent:        8806f2d5ed4792042b246b930fb44f24b9ee45c2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 24 13:52:12 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:13:31 2020 -0500

writecache: remove from an active lv

---
 lib/metadata/lv_manip.c          |  17 ++-
 lib/metadata/metadata-exported.h |   3 +-
 lib/metadata/writecache_manip.c  | 288 +++++++++++++++++++++++++++++++++------
 test/shell/writecache-split.sh   |  35 +++--
 tools/lvconvert.c                |  42 ++----
 5 files changed, 294 insertions(+), 91 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1311f70bd..c1c86aa4c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6568,7 +6568,20 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	if (lv_is_used_cache_pool(lv) || lv_is_cache_vol(lv)) {
+	if (lv_is_cache_vol(lv)) {
+		if ((cache_seg = get_only_segment_using_this_lv(lv))) {
+			/* When used with cache, lvremove on cachevol also removes the cache! */
+		       	if (seg_is_cache(cache_seg)) {
+				if (!lv_cache_remove(cache_seg->lv))
+					return_0;
+			} else if (seg_is_writecache(cache_seg)) {
+				log_error("Detach cachevol before removing.");
+				return 0;
+			}
+		}
+	}
+
+	if (lv_is_used_cache_pool(lv)) {
 		/* Cache pool removal drops cache layer
 		 * If the cache pool is not linked, we can simply remove it. */
 		if (!(cache_seg = get_only_segment_using_this_lv(lv)))
@@ -6832,7 +6845,7 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 	}
 
 	if (!(origin_only ? suspend_lv_origin(vg->cmd, lock_lv) : suspend_lv(vg->cmd, lock_lv))) {
-		log_error("Failed to lock logical volume %s.",
+		log_error("Failed to suspend logical volume %s.",
 			  display_lvname(lock_lv));
 		vg_revert(vg);
 	} else if (!(r = vg_commit(vg)))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 083f74a28..9de088437 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -89,8 +89,7 @@
 #define PARTIAL_LV		UINT64_C(0x0000000001000000)	/* LV - derived flag, not
 							   written out in metadata*/
 
-//#define POSTORDER_FLAG	UINT64_C(0x0000000002000000) /* Not real flags, reserved for
-//#define POSTORDER_OPEN_FLAG	UINT64_C(0x0000000004000000)    temporary use inside vg_read_internal. */
+#define WRITECACHE_ORIGIN	UINT64_C(0x0000000002000000)
 #define INTEGRITY_METADATA	UINT64_C(0x0000000004000000)    /* LV - Internal use only */
 #define VIRTUAL_ORIGIN		UINT64_C(0x0000000008000000)	/* LV - internal use only */
 
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 31d069edb..4f09e69cf 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -19,6 +19,7 @@
 #include "lib/commands/toolcontext.h"
 #include "lib/display/display.h"
 #include "lib/metadata/segtype.h"
+#include "lib/metadata/lv_alloc.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
 
@@ -26,6 +27,15 @@ int lv_is_writecache_origin(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 
+	/*
+	 * This flag is needed when removing writecache from an origin
+	 * in which case the lv connections have been destroyed and
+	 * identifying a writecache origin by these connections doesn't
+	 * work.
+	 */
+	if (lv->status & WRITECACHE_ORIGIN)
+		return 1;
+
 	/* Make sure there's exactly one segment in segs_using_this_lv! */
 	if (dm_list_empty(&lv->segs_using_this_lv) ||
 	    (dm_list_size(&lv->segs_using_this_lv) > 1))
@@ -48,46 +58,6 @@ int lv_is_writecache_cachevol(const struct logical_volume *lv)
 	return 0;
 }
 
-static int _lv_writecache_detach(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct logical_volume *lv_fast)
-{
-	struct lv_segment *seg = first_seg(lv);
-	struct logical_volume *origin;
-
-	if (!seg_is_writecache(seg)) {
-		log_error("LV %s segment is not writecache.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!seg->writecache) {
-		log_error("LV %s writecache segment has no writecache.", display_lvname(lv));
-		return 0;
-	}
-
-	if (!(origin = seg_lv(seg, 0))) {
-		log_error("LV %s writecache segment has no origin", display_lvname(lv));
-		return 0;
-	}
-
-	if (!remove_seg_from_segs_using_this_lv(seg->writecache, seg))
-		return_0;
-
-	lv_set_visible(seg->writecache);
-
-	lv->status &= ~WRITECACHE;
-	seg->writecache = NULL;
-
-	lv_fast->status &= ~LV_CACHE_VOL;
-
-	if (!remove_layer_from_lv(lv, origin))
-		return_0;
-
-	if (!lv_remove(origin))
-		return_0;
-
-	return 1;
-}
-
 static int _get_writecache_kernel_error(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					uint32_t *kernel_error)
@@ -131,13 +101,64 @@ fail:
 	return 0;
 }
 
-int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
+static void _rename_detached_cvol(struct cmd_context *cmd, struct logical_volume *lv_fast)
+{
+	struct volume_group *vg = lv_fast->vg;
+	char cvol_name[NAME_LEN];
+	char *suffix, *cvol_name_dup;
+
+	/*
+	 * Rename lv_fast back to its original name, without the _cvol
+	 * suffix that was added when lv_fast was attached for caching.
+	 * If the name is in use, generate new lvol%d.
+	 * Failing to rename is not really a problem, so we intentionally
+	 * do not consider some things here as errors.
+	 */
+	if (!dm_strncpy(cvol_name, lv_fast->name, sizeof(cvol_name)) ||
+	    !(suffix  = strstr(cvol_name, "_cvol"))) {
+		log_debug("LV %s has no suffix for cachevol (skipping rename).",
+			display_lvname(lv_fast));
+		return;
+	}
+
+	*suffix = 0;
+	if (lv_name_is_used_in_vg(vg, cvol_name, NULL) &&
+	    !generate_lv_name(vg, "lvol%d", cvol_name, sizeof(cvol_name))) {
+		log_warn("Failed to generate new unique name for unused LV %s", lv_fast->name);
+		return;
+	}
+
+	if (!(cvol_name_dup = dm_pool_strdup(vg->vgmem, cvol_name))) {
+		stack;
+		return;
+	}
+
+	lv_fast->name = cvol_name_dup;
+}
+
+static int _lv_detach_writecache_cachevol_inactive(struct logical_volume *lv, int noflush)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
+	struct volume_group *vg = lv->vg;
 	struct logical_volume *lv_fast;
+	struct logical_volume *lv_wcorig;
+	struct lv_segment *seg = first_seg(lv);
 	uint32_t kernel_error = 0;
 
-	lv_fast = first_seg(lv)->writecache;
+	if (!seg_is_writecache(seg)) {
+		log_error("LV %s segment is not writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!(lv_fast = seg->writecache)) {
+		log_error("LV %s writecache segment has no writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!(lv_wcorig = seg_lv(seg, 0))) {
+		log_error("LV %s writecache segment has no origin", display_lvname(lv));
+		return 0;
+	}
 
 	if (noflush)
 		goto detach;
@@ -157,6 +178,8 @@ int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
 
 	if (!sync_local_dev_names(cmd)) {
 		log_error("Failed to sync local devices before detaching writecache.");
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -176,7 +199,8 @@ int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
 
 	if (kernel_error) {
 		log_error("Failed to flush writecache (error %u) for %s.", kernel_error, display_lvname(lv));
-		deactivate_lv(cmd, lv);
+		if (!deactivate_lv(cmd, lv))
+			log_error("Failed to deactivate %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -188,11 +212,185 @@ int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
 	lv->status &= ~LV_TEMPORARY;
 
  detach:
-	if (!_lv_writecache_detach(cmd, lv, lv_fast)) {
-		log_error("Failed to detach writecache from %s", display_lvname(lv));
+	if (!remove_seg_from_segs_using_this_lv(lv_fast, seg))
+		return_0;
+
+	lv->status &= ~WRITECACHE;
+	seg->writecache = NULL;
+
+	if (!remove_layer_from_lv(lv, lv_wcorig))
+		return_0;
+
+	if (!lv_remove(lv_wcorig))
+		return_0;
+
+	lv_set_visible(lv_fast);
+	lv_fast->status &= ~LV_CACHE_VOL;
+
+	_rename_detached_cvol(cmd, lv_fast);
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	return 1;
+}
+
+static int _lv_detach_writecache_cachevol_active(struct logical_volume *lv, int noflush)
+{
+	struct cmd_context *cmd = lv->vg->cmd;
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *lv_fast;
+	struct logical_volume *lv_wcorig;
+	struct logical_volume *lv_old;
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t kernel_error = 0;
+
+	if (!seg_is_writecache(seg)) {
+		log_error("LV %s segment is not writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!(lv_fast = seg->writecache)) {
+		log_error("LV %s writecache segment has no writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!(lv_wcorig = seg_lv(seg, 0))) {
+		log_error("LV %s writecache segment has no origin", display_lvname(lv));
+		return 0;
+	}
+
+	if (noflush)
+		goto detach;
+
+	if (!lv_writecache_message(lv, "flush_on_suspend")) {
+		log_error("Failed to set flush_on_suspend in writecache detach %s.", display_lvname(lv));
+		return 0;
+	}
+
+ detach:
+	if (!remove_seg_from_segs_using_this_lv(lv_fast, seg)) {
+		log_error("Failed to remove seg in writecache detach.");
+		return 0;
+	}
+
+	lv->status &= ~WRITECACHE;
+	seg->writecache = NULL;
+
+	if (!remove_layer_from_lv(lv, lv_wcorig)) {
+		log_error("Failed to remove lv layer in writecache detach.");
+		return 0;
+	}
+
+	/*
+	 * vg_write(), suspend_lv(), vg_commit(), resume_lv().
+	 * usually done by lv_update_and_reload for an active lv,
+	 * but in this case we need to check for writecache errors
+	 * after suspend.
+	 */
+
+	if (!vg_write(vg)) {
+		log_error("Failed to write VG in writecache detach.");
+		return 0;
+	}
+
+	/*
+	 * The version of LV before removal of writecache.  When need to
+	 * check for kernel errors based on the old version of LV which
+	 * is still present in the kernel.
+	 */
+	if (!(lv_old = (struct logical_volume *)lv_committed(lv))) {
+		log_error("Failed to get lv_committed in writecache detach.");
+		return 0;
+	}
+
+	/*
+	 * suspend does not use 'lv' as we know it here, but grabs the
+	 * old (precommitted) version of 'lv' using lv_committed(),
+	 * which is from vg->vg_comitted.
+	 */
+	log_debug("Suspending writecache to detach %s", display_lvname(lv));
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to suspend LV in writecache detach.");
+		vg_revert(vg);
+		return 0;
+	}
+
+	log_debug("Checking writecache errors to detach.");
+
+	if (!_get_writecache_kernel_error(cmd, lv_old, &kernel_error)) {
+		log_error("Failed to get writecache error status for %s.", display_lvname(lv_old));
+		return 0;
+	}
+
+	if (kernel_error) {
+		log_error("Failed to flush writecache (error %u) for %s.", kernel_error, display_lvname(lv));
+		return 0;
+	}
+
+	if (!vg_commit(vg)) {
+		log_error("Failed to commit VG in writecache detach.");
+		return 0;
+	}
+
+	/*
+	 * Since vg_commit has happened, vg->vg_committed is now the
+	 * newest copy of lv, so resume uses the 'lv' that we know
+	 * here.
+	 */
+	log_debug("Resuming after writecache detached %s", display_lvname(lv));
+
+	if (!resume_lv(cmd, lv)) {
+		log_error("Failed to resume LV in writecache detach.");
+		return 0;
+	}
+
+	log_debug("Deactivating previous cachevol %s", display_lvname(lv_fast));
+
+	if (!deactivate_lv(cmd, lv_fast))
+		log_error("Failed to deactivate previous cachevol in writecache detach.");
+
+	/*
+	 * Needed for lv_is_writecache_origin to know lv_wcorig was
+	 * a writecache origin, which is needed so that the -real
+	 * dm uuid suffix is applied, which is needed for deactivate to
+	 * work. This is a hacky roundabout way of setting the -real
+	 * uuid suffix (it would be nice to have a deactivate command
+	 * that accepts a dm uuid.)
+	 */
+	lv_wcorig->status |= WRITECACHE_ORIGIN;
+
+	log_debug("Deactivating previous wcorig %s", display_lvname(lv_wcorig));
+
+	if (!lv_deactivate(cmd, NULL, lv_wcorig))
+		log_error("Failed to deactivate previous wcorig LV in writecache detach.");
+
+	log_debug("Removing previous wcorig %s", display_lvname(lv_wcorig));
+
+	if (!lv_remove(lv_wcorig)) {
+		log_error("Failed to remove previous wcorig LV in writecache detach.");
+		return 0;
+	}
+
+	lv_set_visible(lv_fast);
+	lv_fast->status &= ~LV_CACHE_VOL;
+
+	_rename_detached_cvol(cmd, lv_fast);
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Failed to write and commit VG in writecache detach.");
 		return 0;
 	}
 
 	return 1;
 }
 
+int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
+{
+	if (lv_is_active(lv))
+		return _lv_detach_writecache_cachevol_active(lv, noflush);
+	else
+		return _lv_detach_writecache_cachevol_inactive(lv, noflush);
+}
+
diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index 0f2dc4729..9553ade0c 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -20,29 +20,21 @@ mkfs_mount_umount()
 {
         lvt=$1
 
-        lvchange -ay $vg/$lvt
-
         mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lvt"
         mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
         cp pattern1 "$mount_dir/pattern1"
         dd if=/dev/zero of="$mount_dir/zeros2M" bs=1M count=32 conv=fdatasync
         umount "$mount_dir"
-
-        lvchange -an $vg/$lvt
 }
 
 mount_umount()
 {
         lvt=$1
 
-        lvchange -ay $vg/$lvt
-
         mount "$DM_DEV_DIR/$vg/$lvt" "$mount_dir"
         diff pattern1 "$mount_dir/pattern1"
         dd if="$mount_dir/zeros2M" of=/dev/null bs=1M count=32
         umount "$mount_dir"
-
-        lvchange -an $vg/$lvt
 }
 
 aux have_writecache 1 0 0 || skip
@@ -62,18 +54,39 @@ lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"
 
 #
-# split when no devs are missing
+# split while inactive
+#
+
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+
+lvchange -ay $vg/$lv1
+mkfs_mount_umount $lv1
+lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+lvs -o segtype $vg/$lv1 | grep linear
+lvs -o segtype $vg/$lv2 | grep linear
+
+lvchange -ay $vg/$lv1
+mount_umount $lv1
+lvchange -an $vg/$lv1
+
+#
+# split while active
 #
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
 
+lvchange -ay $vg/$lv1
 mkfs_mount_umount $lv1
 
 lvconvert --splitcache $vg/$lv1
 lvs -o segtype $vg/$lv1 | grep linear
 lvs -o segtype $vg/$lv2 | grep linear
 
+lvchange -ay $vg/$lv1
 mount_umount $lv1
+lvchange -an $vg/$lv1
 
 #
 # split while cachevol is missing
@@ -81,7 +94,9 @@ mount_umount $lv1
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
 
+lvchange -ay $vg/$lv1
 mkfs_mount_umount $lv1
+lvchange -an $vg/$lv1
 
 aux disable_dev "$dev2"
 
@@ -108,7 +123,9 @@ lvcreate -n $lv2 -l 14 -an $vg "$dev2" "$dev3"
 
 lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
 
+lvchange -ay $vg/$lv1
 mkfs_mount_umount $lv1
+lvchange -an $vg/$lv1
 
 aux disable_dev "$dev3"
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76e00f0a2..7935eb74e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5311,19 +5311,8 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast)
 {
-	char cvol_name[NAME_LEN];
-	char *c;
 	int noflush = 0;
 
-	/*
-	 * LV must be inactive externally before detaching cache.
-	 */
-
-	if (lv_info(cmd, lv, 1, NULL, 0, 0)) {
-		log_error("LV %s must be inactive to detach writecache.", display_lvname(lv));
-		return 0;
-	}
-
 	if (!archive(lv->vg))
 		return_0;
 
@@ -5347,31 +5336,18 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 		noflush = 1;
 	}
 
-	if (!lv_detach_writecache_cachevol(lv, noflush))
-		return_0;
-
 	/*
-	 * Rename lv_fast back to its original name, without the _cvol
-	 * suffix that was added when lv_fast was attached for caching.
+	 * TODO: send a message to writecache in the kernel to start writing
+	 * back cache data to the origin.  Then release the vg lock and monitor
+	 * the progress of that writeback.  When it's complete we can reacquire
+	 * the vg lock, rescan the vg (ensure it hasn't changed), and do the
+	 * detach which should be quick since the writeback is complete.  If
+	 * this command is canceled while monitoring writeback, it should just
+	 * be rerun.  The LV will continue to have the writecache until this
+	 * command is run to completion.
 	 */
-	if (!dm_strncpy(cvol_name, lv_fast->name, sizeof(cvol_name)) ||
-	    !(c = strstr(cvol_name, "_cvol"))) {
-		log_debug("LV %s has no suffix for cachevol (skipping rename).",
-			display_lvname(lv_fast));
-	} else {
-		*c = 0;
-		/* If the name is in use, generate new lvol%d */
-		if (lv_name_is_used_in_vg(lv->vg, cvol_name, NULL) &&
-		    !generate_lv_name(lv->vg, "lvol%d", cvol_name, sizeof(cvol_name))) {
-			log_error("Failed to generate unique name for unused logical volume.");
-			return 0;
-		}
 
-		if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
-			return_0;
-	}
-
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+	if (!lv_detach_writecache_cachevol(lv, noflush))
 		return_0;
 
 	backup(lv->vg);


