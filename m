From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Wed, 09 Aug 2023 15:30:27 +0000
Subject: [Git][lvmteam/lvm2][main] lvconvert swapmetadata: fix lvmlockd locking
Message-ID: <64d3b113ce0ea_28a6d74299d3@gitlab-sidekiq-low-urgency-cpu-bound-v2-79db7d77db-vkj5f.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
2928891b by David Teigland at 2023-08-08T16:57:22-05:00
lvconvert swapmetadata: fix lvmlockd locking

The lockd lock needs to be freed for the LV that is becoming
the new metadata LV, and a new lockd lock needs to be created
for the old metadata LV that is becoming an independent LV.
Fixes b3e45219c2f4

- - - - -


1 changed file:

- tools/lvconvert.c


Changes:

=====================================
tools/lvconvert.c
=====================================
@@ -2818,6 +2818,9 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	struct lv_type *lvtype;
 	char meta_name[NAME_LEN];
 	const char *swap_name;
+	char *lockd_meta_args = NULL;
+	char *lockd_meta_name = NULL;
+	struct id lockd_meta_id;
 	uint32_t chunk_size;
 	int is_thinpool;
 	int is_cachepool;
@@ -2872,6 +2875,12 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		return 0;
 
+	/* If new metadata LV is inactive here, ensure it's not active elsewhere */
+	if (!lockd_lv(cmd, metadata_lv, "ex", 0)) {
+		log_error("New pool metadata LV %s cannot be locked.", display_lvname(metadata_lv));
+		return 0;
+	}
+
 	if (!deactivate_lv(cmd, metadata_lv)) {
 		log_error("Aborting. Failed to deactivate %s.",
 			  display_lvname(metadata_lv));
@@ -2883,8 +2892,22 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 		return 0;
 	}
 
-        metadata_lv->lock_args = NULL;
-
+	/*
+	 * metadata_lv is currently an independent LV with its own lockd lock allocated.
+	 * A pool metadata LV does not have its own lockd lock (only the pool LV does.)
+	 * So, when metadata_lv is added to the thin pool, it's lock needs to be freed.
+	 * Save info about the metadata_lv here that will be used to free the lock.
+	 * The current pool metadata LV does not currently have its own lockd lock
+	 * allocated, and once it becomes an independent LV it will need its own lock.
+	 * (see setting prev_metadata_lv->lock_args below.)
+	 */
+	if (vg_is_shared(vg) && metadata_lv->lock_args) {
+		lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
+		lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
+		memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
+		/* Without lock_args, a lock will no longer be acquired for this LV. */
+		metadata_lv->lock_args = NULL;
+	}
 
 	seg = first_seg(lv);
 
@@ -2950,9 +2973,27 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	if (!attach_pool_metadata_lv(seg, metadata_lv))
 		return_0;
 
+	/*
+	 * The previous metadata LV will now be an independent LV so it now
+	 * requires a lockd lock.  We could call lockd_init_lv_args() directly
+	 * here, but reuse the existing code in vg_write() to be consistent
+	 * with the way lvcreate allocates locks.
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		if (!strcmp(vg->lock_type, "sanlock"))
+			prev_metadata_lv->lock_args = "pending";
+		else if (!strcmp(vg->lock_type, "dlm"))
+			prev_metadata_lv->lock_args = "dlm";
+		else if (!strcmp(vg->lock_type, "idm"))
+			prev_metadata_lv->lock_args = "idm";
+	}
+
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
+	if (lockd_meta_name)
+		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
+
 	return 1;
 }
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/2928891bd00bce8d880f8c3a6aec430a57c49377

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/2928891bd00bce8d880f8c3a6aec430a57c49377
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230809/e84854ea/attachment-0001.htm>
