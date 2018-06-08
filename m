From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 15:02:31 -0400
Subject: master - Remove unused cluster-related locking flags
Message-ID: <201806081902.w58J2V43003647@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c59140f5fbd48139ac008c8c1ab1aefc4288698
Commit:        1c59140f5fbd48139ac008c8c1ab1aefc4288698
Parent:        a8759dc7a6669b9ecfbc749d68beed2e0029903b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 12:38:43 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 14:01:00 2018 -0500

Remove unused cluster-related locking flags

---
 lib/locking/file_locking.c |    4 ---
 lib/locking/locking.c      |   19 ++++---------
 lib/locking/locking.h      |   60 --------------------------------------------
 3 files changed, 6 insertions(+), 77 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 6b295e9..a0a4f02 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -47,10 +47,6 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		/* LCK_CACHE does not require a real lock */
-		if (flags & LCK_CACHE)
-			break;
-
 		if (is_orphan_vg(resource) || is_global_vg(resource)) {
 			if (dm_snprintf(lockfile, sizeof(lockfile),
 					"%s/P_%s", _lock_dir, resource + 1) < 0) {
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index b6bd8d8..c9298af 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -70,7 +70,6 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
 {
 	/* Ignore locks not associated with updating VG metadata */
 	if ((flags & LCK_SCOPE_MASK) != LCK_VG ||
-	    (flags & LCK_CACHE) ||
 	    !strcmp(resource, VG_GLOBAL))
 		return;
 
@@ -207,7 +206,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		if (lck_type != LCK_WRITE)
 			goto out_hold;
 
-		if (cmd->is_activating && (lck_scope == LCK_VG) && !(flags & LCK_CACHE) && strcmp(vol, VG_GLOBAL))
+		if (cmd->is_activating && (lck_scope == LCK_VG) && strcmp(vol, VG_GLOBAL))
 			goto out_hold;
 
 		goto out_fail;
@@ -230,7 +229,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	 * refuse write lock requests.
 	 */
 	if (cmd->metadata_read_only) {
-		if ((lck_type == LCK_WRITE) && (lck_scope == LCK_VG) && !(flags & LCK_CACHE) && strcmp(vol, VG_GLOBAL)) {
+		if ((lck_type == LCK_WRITE) && (lck_scope == LCK_VG) && strcmp(vol, VG_GLOBAL)) {
 			log_error("Operation prohibited while global/metadata_read_only is set.");
 			goto out_fail;
 		}
@@ -243,12 +242,11 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 
 	/*
 	 * FIXME: I don't think we need this any more.
-	 * If a real lock was acquired (i.e. not LCK_CACHE),
+	 * If a real lock was acquired
 	 * perform an immediate unlock unless LCK_HOLD was requested.
 	 */
 
-	if ((lck_type == LCK_NULL) || (lck_type == LCK_UNLOCK) ||
-	    (flags & (LCK_CACHE | LCK_HOLD)))
+	if ((lck_type == LCK_UNLOCK) || (flags & LCK_HOLD))
 		goto out_hold;
 
 	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
@@ -262,9 +260,9 @@ out_hold:
 	 * locked by looking in lvmcache.  They shouldn't need to
 	 * do that, and we should be able to remove this.
 	 */
-	if ((lck_scope == LCK_VG) && !(flags & LCK_CACHE) && (lck_type != LCK_UNLOCK))
+	if ((lck_scope == LCK_VG) && (lck_type != LCK_UNLOCK))
 		lvmcache_lock_vgname(resource, lck_type == LCK_READ);
-	else if ((lck_scope == LCK_VG) && !(flags & LCK_CACHE) && (lck_type == LCK_UNLOCK))
+	else if ((lck_scope == LCK_VG) && (lck_type == LCK_UNLOCK))
 		lvmcache_unlock_vgname(resource);
 
 	/* FIXME: we shouldn't need to keep track of this either. */
@@ -304,11 +302,6 @@ int vg_write_lock_held(void)
 	return _vg_write_lock_held;
 }
 
-int locking_is_clustered(void)
-{
-	return 0;
-}
-
 int sync_local_dev_names(struct cmd_context* cmd)
 {
 	memlock_unlock(cmd);
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 23636fc..bbd7dfe 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -25,15 +25,6 @@ int init_locking(struct cmd_context *cmd, int file_locking_sysinit, int file_loc
 void fin_locking(void);
 void reset_locking(void);
 int vg_write_lock_held(void);
-int locking_is_clustered(void);
-int locking_supports_remote_queries(void);
-
-#ifndef NODE_ALL
-#  define NODE_ALL     "*"
-#  define NODE_LOCAL   "."
-#  define NODE_REMOTE  "^"
-#endif
-int cluster_lock_held(const char *vol, const char *node, int *exclusive);
 
 /*
  * LCK_VG:
@@ -41,8 +32,6 @@ int cluster_lock_held(const char *vol, const char *node, int *exclusive);
  *   Use VG_ORPHANS to lock all orphan PVs.
  *   Use VG_GLOBAL as a global lock and to wipe the internal cache.
  *   char *vol holds volume group name.
- *   Set LCK_CACHE flag when manipulating 'vol' metadata in the internal cache.
- *   (Like commit, revert or invalidate metadata.)
  *   If more than one lock needs to be held simultaneously, they must be
  *   acquired in alphabetical order of 'vol' (to avoid deadlocks), with
  *   VG_ORPHANS last.
@@ -59,37 +48,18 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 /*
  * Internal locking representation.
  *   LCK_VG: Uses prefix V_ unless the vol begins with # (i.e. #global or #orphans)
- *           or the LCK_CACHE flag is set when it uses the prefix P_.
- * If LCK_CACHE is set, we do not take out a real lock.
- * NB In clustered situations, LCK_CACHE is not propagated directly to remote nodes.
- * (It can be deduced from lock name.)
- */
-
-/*
- * Does the LVM1 driver have this VG active?
  */
-int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 
 /*
  * Lock type - these numbers are the same as VMS and the IBM DLM
  */
 #define LCK_TYPE_MASK	0x00000007U
 
-#define LCK_NULL	0x00000000U	/* LCK$_NLMODE (Deactivate) */
 #define LCK_READ	0x00000001U	/* LCK$_CRMODE (Activate) */
-					/* LCK$_CWMODE */
-#define LCK_PREAD       0x00000003U	/* LCK$_PRMODE */
 #define LCK_WRITE	0x00000004U	/* LCK$_PWMODE (Suspend) */
-#define LCK_EXCL	0x00000005U	/* LCK$_EXMODE (Exclusive) */
 #define LCK_UNLOCK      0x00000006U	/* This is ours (Resume) */
 
 /*
- * Lock flags - these numbers are the same as DLM
- */
-#define LCKF_NOQUEUE	0x00000001U	/* LKF$_NOQUEUE */
-#define LCKF_CONVERT	0x00000004U	/* LKF$_CONVERT */
-
-/*
  * Lock scope
  */
 #define LCK_SCOPE_MASK	0x00001008U
@@ -101,28 +71,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
  */
 #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
 #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
-#define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
-
-#define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
-#define LCK_REMOTE	0x00000800U	/* Propagate to remote nodes only */
-#define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
-#define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
-#define LCK_REVERT	0x00000400U	/* Revert any incomplete change */
-
-/*
- * Additional lock bits for cluster communication via args[1]
- */
-#define LCK_PARTIAL_MODE        	0x01	/* Partial activation? */
-#define LCK_MIRROR_NOSYNC_MODE		0x02	/* Mirrors don't require sync */
-#define LCK_DMEVENTD_MONITOR_MODE	0x04	/* Register with dmeventd */
-
-/* Not yet used. */
-#define LCK_CONVERT_MODE		0x08	/* Convert existing lock */
-
-#define LCK_TEST_MODE			0x10    /* Test mode: No activation */
-#define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
-#define LCK_DMEVENTD_MONITOR_IGNORE     0x40	/* Whether to ignore dmeventd */
-#define LCK_REVERT_MODE			0x80	/* Remove inactive tables */
 
 /*
  * Special cases of VG locks.
@@ -133,18 +81,10 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 /*
  * Common combinations
  */
-#define LCK_NONE		(LCK_VG | LCK_NULL)
-
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
 
-/* FIXME: LCK_HOLD abused here */
-#define LCK_VG_COMMIT		(LCK_VG | LCK_WRITE | LCK_CACHE | LCK_HOLD)
-#define LCK_VG_REVERT		(LCK_VG | LCK_READ  | LCK_CACHE | LCK_HOLD)
-
-#define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
-
 #define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
 
 #define unlock_vg(cmd, vg, vol)	\


