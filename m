From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:22:03 -0400
Subject: master - Remove VG lock ordering check
Message-ID: <201806071522.w57FM3xK013197@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7aa51c70f17af10df906a7e123a497c1cf3c1ba
Commit:        e7aa51c70f17af10df906a7e123a497c1cf3c1ba
Parent:        18259d5559307f2708e12b9923988319e46572df
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 5 15:16:58 2018 -0500
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 7 16:17:04 2018 +0100

Remove VG lock ordering check

Four commands lock two VGs at a time:

- vgsplit and vgmerge already have their own logic to
  acquire the locks in the correct order.

- vgimportclone and vgrename disable this ordering check.
---
 lib/cache/lvmcache.c  |   66 -------------------------------------------------
 lib/cache/lvmcache.h  |    1 -
 lib/locking/locking.c |    6 ----
 tools/toollib.c       |    8 ------
 tools/vgimportclone.c |    4 ---
 tools/vgrename.c      |    5 ---
 6 files changed, 0 insertions(+), 90 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b9aa8a0..774d687 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -77,7 +77,6 @@ static int _has_scanned = 0;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
-static int _suppress_lock_ordering = 0;
 
 int lvmcache_init(struct cmd_context *cmd)
 {
@@ -158,71 +157,6 @@ static void _update_cache_lock_state(const char *vgname, int locked)
 	_update_cache_vginfo_lock_state(vginfo, locked);
 }
 
-/*
- * Ensure vgname2 comes after vgname1 alphabetically.
- * Orphan locks come last.
- * VG_GLOBAL comes first.
- */
-static int _vgname_order_correct(const char *vgname1, const char *vgname2)
-{
-	if (is_global_vg(vgname1))
-		return 1;
-
-	if (is_global_vg(vgname2))
-		return 0;
-
-	if (is_orphan_vg(vgname1))
-		return 0;
-
-	if (is_orphan_vg(vgname2))
-		return 1;
-
-	if (strcmp(vgname1, vgname2) < 0)
-		return 1;
-
-	return 0;
-}
-
-void lvmcache_lock_ordering(int enable)
-{
-	_suppress_lock_ordering = !enable;
-}
-
-/*
- * Ensure VG locks are acquired in alphabetical order.
- */
-int lvmcache_verify_lock_order(const char *vgname)
-{
-	struct dm_hash_node *n;
-	const char *vgname2;
-
-	if (_suppress_lock_ordering)
-		return 1;
-
-	if (!_lock_hash)
-		return 1;
-
-	dm_hash_iterate(n, _lock_hash) {
-		if (!dm_hash_get_data(_lock_hash, n))
-			return_0;
-
-		if (!(vgname2 = dm_hash_get_key(_lock_hash, n))) {
-			log_error(INTERNAL_ERROR "VG lock %s hits NULL.",
-				 vgname);
-			return 0;
-		}
-
-		if (!_vgname_order_correct(vgname2, vgname)) {
-			log_errno(EDEADLK, INTERNAL_ERROR "VG lock %s must "
-				  "be requested before %s, not after.",
-				  vgname, vgname2);
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
 	if (dm_hash_lookup(_lock_hash, vgname))
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 5891757..4808a0d 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -87,7 +87,6 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
-int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
 const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd, const char *vgname, const char *vgid, unsigned revalidate_labels);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index a4fcaf7..5e28452 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -234,12 +234,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		/* Global VG_ORPHANS lock covers all orphan formats. */
 		if (is_orphan_vg(vol))
 			vol = VG_ORPHANS;
-		/* VG locks alphabetical, ORPHAN lock last */
-		if ((lck_type != LCK_UNLOCK) &&
-		    !(flags & LCK_CACHE) &&
-		    !lvmcache_verify_lock_order(vol))
-			return_0;
-
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */
diff --git a/tools/toollib.c b/tools/toollib.c
index 236e2b1..a4dddd3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5414,14 +5414,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	}
 
 	/*
-	 * This function holds the orphans lock while reading VGs to look for
-	 * devices.  This means the orphans lock is held while VG locks are
-	 * acquired, which is against lvmcache lock ordering rules, so disable
-	 * the lvmcache lock ordering checks.
-	 */
-	lvmcache_lock_ordering(0);
-
-	/*
 	 * Clear the cache before acquiring the orphan lock.  (Clearing the
 	 * cache with locks held is an error.)  We want the orphan lock
 	 * acquired before process_each_pv.  If the orphan lock is not held
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 7421912..e37b897 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -342,9 +342,6 @@ retry_name:
 
 	log_debug("Changing VG %s to %s.", vp.old_vgname, vp.new_vgname);
 
-	/* We don't care if the new name comes before the old in lock order. */
-	lvmcache_lock_ordering(0);
-
 	if (!lock_vol(cmd, vp.new_vgname, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for new VG name %s", vp.new_vgname);
 		goto out;
@@ -363,7 +360,6 @@ out:
 	unlock_vg(cmd, NULL, VG_GLOBAL);
 	internal_filter_clear();
 	init_internal_filtering(0);
-	lvmcache_lock_ordering(1);
 	destroy_processing_handle(cmd, handle);
 
 	/* Enable lvmetad again if no duplicates are left. */
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 4f2a08b..bbc3087 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -99,13 +99,8 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	 *   this uuid-for-name case.
 	 */
 	if (vp->lock_vg_old_first || vp->old_name_is_uuid) {
-		if (vp->old_name_is_uuid)
-			lvmcache_lock_ordering(0);
-
 		if (!_lock_new_vg_for_rename(cmd, vp->vg_name_new))
 			return ECMD_FAILED;
-
-		lvmcache_lock_ordering(1);
 	}
 
 	dev_dir = cmd->dev_dir;


