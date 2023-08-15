From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Tue, 15 Aug 2023 18:17:19 +0000
Subject: [Git][lvmteam/lvm2][main] lvconvert swapmetadata: update lvmlockd locking for uuid exchange
Message-ID: <64dbc12fc58d5_28a8c78784b4@gitlab-sidekiq-low-urgency-cpu-bound-v2-bbc6f7c5-lmkxp.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
e548afd1 by David Teigland at 2023-08-15T13:13:06-05:00
lvconvert swapmetadata: update lvmlockd locking for uuid exchange

lvmlockd locking for swapmetadata adjusted for commit
ac36153e9943 lvconvert: preserve UUID for swapped metadata

Now that the LV uuid is swapped between LVs, the lvmlockd lock can
simply be moved between them, and the same lock can continue to be
used for the LV outside of the pool.

- - - - -


1 changed file:

- tools/lvconvert.c


Changes:

=====================================
tools/lvconvert.c
=====================================
@@ -2835,9 +2835,7 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	struct lv_type *lvtype;
 	char meta_name[NAME_LEN];
 	const char *swap_name;
-	char *lockd_meta_args = NULL;
-	char *lockd_meta_name = NULL;
-	struct id lockd_meta_id;
+	const char *swap_lock_args;
 	uint32_t chunk_size;
 	int is_thinpool;
 	int is_cachepool;
@@ -2904,25 +2902,15 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lockd_lv(cmd, metadata_lv, "un", 0)) {
-		log_error("Failed to unlock LV %s.", display_lvname(metadata_lv));
-		return 0;
-	}
-
 	/*
 	 * metadata_lv is currently an independent LV with its own lockd lock allocated.
 	 * A pool metadata LV does not have its own lockd lock (only the pool LV does.)
-	 * So, when metadata_lv is added to the thin pool, it's lock needs to be freed.
-	 * Save info about the metadata_lv here that will be used to free the lock.
-	 * The current pool metadata LV does not currently have its own lockd lock
-	 * allocated, and once it becomes an independent LV it will need its own lock.
-	 * (see setting prev_metadata_lv->lock_args below.)
+	 * Since the LV name and uuid are exchanged between the old and new metadata LVs,
+	 * the lvmlockd lock can just be moved between the two LVs, so the new indepdent
+	 * LV (former metadata LV) gets the lock that was used for old independent LV.
 	 */
 	if (vg_is_shared(vg) && metadata_lv->lock_args) {
-		lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
-		lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
-		memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
-		/* Without lock_args, a lock will no longer be acquired for this LV. */
+		swap_lock_args = metadata_lv->lock_args;
 		metadata_lv->lock_args = NULL;
 	}
 
@@ -2980,25 +2968,15 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 
 	/*
 	 * The previous metadata LV will now be an independent LV so it now
-	 * requires a lockd lock.  We could call lockd_init_lv_args() directly
-	 * here, but reuse the existing code in vg_write() to be consistent
-	 * with the way lvcreate allocates locks.
+	 * requires a lockd lock, and gets the lock from the LV that's becoming
+	 * the new metadata LV.
 	 */
-	if (is_lockd_type(vg->lock_type)) {
-		if (!strcmp(vg->lock_type, "sanlock"))
-			prev_metadata_lv->lock_args = "pending";
-		else if (!strcmp(vg->lock_type, "dlm"))
-			prev_metadata_lv->lock_args = "dlm";
-		else if (!strcmp(vg->lock_type, "idm"))
-			prev_metadata_lv->lock_args = "idm";
-	}
+	if (is_lockd_type(vg->lock_type))
+		prev_metadata_lv->lock_args = swap_lock_args;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	if (lockd_meta_name)
-		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
-
 	return 1;
 }
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/e548afd1756418933678d2014a8d3f7e5f6b3741

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/e548afd1756418933678d2014a8d3f7e5f6b3741
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230815/cb9b064a/attachment-0001.htm>
