From: David Teigland <teigland@sourceware.org>
Date: Fri, 25 Oct 2019 15:15:42 -0400
Subject: master - lvmlockd: fix cachevol locking
Message-ID: <201910251915.x9PJFgJZ022044@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a8bd0c50979d5975b74055ca9d1535737bdaadf
Commit:        6a8bd0c50979d5975b74055ca9d1535737bdaadf
Parent:        221edf40305de4cab7441d88adf6a15b73c556c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 17:09:00 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 25 14:08:59 2019 -0500

lvmlockd: fix cachevol locking

When a cachevol LV is attached, have the LV keep it's lock
allocated.  The lock on the cachevol won't be used while
it's attached.  When the cachevol is split a new lock does
not need to be allocated.  (Applies to cachevol usage by
both dm-cache and dm-writecache.)
---
 lib/locking/lvmlockd.c  |    8 +++++++
 lib/metadata/metadata.c |    4 ++-
 tools/lvconvert.c       |   52 ++++++++++++++++++++++------------------------
 3 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index bdd567d..f396478 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2368,6 +2368,14 @@ int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 		return 1;
 
 	/*
+	 * A cachevol LV is one exception, where the LV keeps lock_args (so
+	 * they do not need to be reallocated on split) but the lvmlockd lock
+	 * is not used.
+	 */
+	if (lv_is_cache_vol(lv))
+		return 1;
+
+	/*
 	 * LV type cannot be active concurrently on multiple hosts,
 	 * so shared mode activation is not allowed.
 	 */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 45a83bd..c4f7247 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2670,7 +2670,9 @@ int vg_validate(struct volume_group *vg)
 
 				}
 			} else {
-				if (lvl->lv->lock_args) {
+				if (lv_is_cache_vol(lvl->lv)) {
+					log_debug("lock_args will be ignored on cache vol");
+				} else if (lvl->lv->lock_args) {
 					log_error(INTERNAL_ERROR "LV %s/%s shouldn't have lock_args",
 						  vg->name, lvl->lv->name);
 					r = 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c312956..d0d277b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3475,6 +3475,18 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 		goto_out;
 
 	/*
+	 * lv/cache_lv keeps the same lockd lock it had before, the lock for
+	 * lv_fast is kept but is not used while it's attached, and
+	 * lv_corig has no lock.  (When the cachevol is split a new lvmlockd
+	 * lock does not need to be created for it again.)
+	 */
+	if (vg_is_shared(vg) && lv_fast->lock_args) {
+		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
+		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
+		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
+	}
+
+	/*
 	 * The lvm tradition is to rename an LV with a special role-specific
 	 * suffix when it becomes hidden.  Here the _cvol suffix is added to
 	 * the fast LV name.  When the cache is detached, it's renamed back.
@@ -3518,18 +3530,6 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 	}
 
 	/*
-	 * lv/cache_lv keeps the same lockd lock it had before, the lock for
-	 * lv_fast is freed, and lv_corig has no lock.
-	 */
-
-	if (vg_is_shared(vg) && lv_fast->lock_args) {
-		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
-		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
-		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
-		lv_fast->lock_args = NULL;
-	}
-
-	/*
 	 * vg_write(), suspend_lv(), vg_commit(), resume_lv(),
 	 * where the old LV is suspended and the new LV is resumed.
 	 */
@@ -3538,10 +3538,9 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 		goto_out;
 
 	if (lockd_fast_name) {
-		/* unlock and free lockd lock for lv_fast */
+		/* lockd unlock for lv_fast */
 		if (!lockd_lv_name(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args, "un", LDLV_PERSISTENT))
 			log_error("Failed to unlock fast LV %s/%s", vg->name, lockd_fast_name);
-		lockd_free_lv(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args);
 	}
 
 	r = 1;
@@ -5608,6 +5607,17 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto_bad;
 
 	/*
+	 * lv keeps the same lockd lock it had before, the lock for
+	 * lv_fast is kept but is not used while it's attached, and
+	 * lv_wcorig gets no lock.
+	 */
+	if (vg_is_shared(vg) && lv_fast->lock_args) {
+		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
+		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
+		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
+	}
+
+	/*
 	 * TODO: use libblkid to get the sector size of lv.  If it doesn't
 	 * match the block_size we are using for the writecache, then warn that
 	 * an existing file system on lv may become unmountable with the
@@ -5651,17 +5661,6 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto_bad;
 
 	/*
-	 * lv keeps the same lockd lock it had before, the lock for
-	 * lv_fast is freed, and lv_wcorig gets no lock.
-	 */
-	if (vg_is_shared(vg) && lv_fast->lock_args) {
-		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
-		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
-		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
-		lv_fast->lock_args = NULL;
-	}
-
-	/*
 	 * vg_write(), suspend_lv(), vg_commit(), resume_lv(),
 	 * where the old LV is suspended and the new LV is resumed.
 	 */
@@ -5672,10 +5671,9 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	lockd_lv(cmd, lv, "un", 0);
 
 	if (lockd_fast_name) {
-		/* unlock and free lockd lock for lv_fast */
+		/* lockd unlock for lv_fast */
 		if (!lockd_lv_name(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args, "un", 0))
 			log_error("Failed to unlock fast LV %s/%s", vg->name, lockd_fast_name);
-		lockd_free_lv(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args);
 	}
 
 	log_print_unless_silent("Logical volume %s now has write cache.",


