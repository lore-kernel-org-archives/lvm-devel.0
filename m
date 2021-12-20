From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:16 +0000 (GMT)
Subject: main - label: cache dm device list
Message-ID: <20211220151416.46C033857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04fbffb116eaf5fb1b10785df92966d0083b270f
Commit:        04fbffb116eaf5fb1b10785df92966d0083b270f
Parent:        0d67bc96fd15b9f3110bdc824749805c8392b04a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 15 11:45:22 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

label: cache dm device list

Since we check for present DM devices - cache result for
futher use of checking presence of such device.

lvm2 uses cache result for label scan, but also when
it tries to activate or deactivate LV - however only simple
target 'striped' is reasonably supported.

Use disable_dm_devs to be able to control when lv_info()
get cache or uncached results.

TODO: support more type, however this is getting very complicated.
---
 WHATS_NEW                  |  1 +
 lib/activate/activate.c    |  6 ++++++
 lib/activate/dev_manager.c | 29 +++++++++++++++++++++++++++++
 lib/commands/toolcontext.c |  1 +
 lib/commands/toolcontext.h |  3 +++
 lib/label/label.c          | 35 +++++++++++++++++++++++++++++++++++
 lib/label/label.h          |  1 +
 lib/locking/locking.c      |  1 +
 tools/toollib.c            |  3 +--
 9 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b206f067..e2f6e166b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.15 - 
 ===================================
+  Use cache or active DM device when available with new kernels.
   Introduce function to utilize UUIDs from DM_DEVICE_LIST.
   Increase some hash table size to better support large device sets.
 
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ffb7f4b29..db5f08b11 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2391,6 +2391,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 	static const struct lv_activate_opts laopts = { .skip_in_use = 1 };
 	struct dm_list *snh;
 	int r = 0;
+	unsigned tmp_state;
 
 	if (!activation())
 		return 1;
@@ -2463,12 +2464,17 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 	}
 	critical_section_dec(cmd, "deactivated");
 
+	tmp_state = cmd->disable_dm_devs;
+	cmd->disable_dm_devs = 1;
+
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists) {
 		/* Turn into log_error, but we do not log error */
 		log_debug_activation("Deactivated volume is still %s present.",
 				     display_lvname(lv));
 		r = 0;
 	}
+
+	cmd->disable_dm_devs = tmp_state;
 out:
 
 	return r;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 16c66a341..6cf4c718c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -964,6 +964,16 @@ int dev_manager_info(struct cmd_context *cmd,
 	if (!(dlid = build_dm_uuid(cmd->mem, lv, layer)))
 		goto_out;
 
+	if (!cmd->disable_dm_devs &&
+	    cmd->cache_dm_devs &&
+	    !dm_device_list_find_by_uuid(cmd->cache_dm_devs, dlid, NULL)) {
+		log_debug("Cached as inactive %s.", name);
+		if (dminfo)
+			memset(dminfo, 0, sizeof(*dminfo));
+		r = 1;
+		goto out;
+	}
+
 	if (!(r = _info(cmd, name, dlid,
 			with_open_count, with_read_ahead, with_name_check,
 			dminfo, read_ahead, seg_status)))
@@ -2245,6 +2255,13 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(dlid = build_dm_uuid(dm->track_pending_delete ? dm->cmd->pending_delete_mem : dm->mem, lv, layer)))
 		return_0;
 
+	if (!dm->cmd->disable_dm_devs &&
+	    dm->cmd->cache_dm_devs &&
+	    !dm_device_list_find_by_uuid(dm->cmd->cache_dm_devs, dlid, NULL)) {
+		log_debug("Cached as not present %s.", name);
+		return 1;
+	}
+
 	if (!_info(dm->cmd, name, dlid, 1, 0, 0, &info, NULL, NULL))
 		return_0;
 
@@ -2390,6 +2407,9 @@ static int _pool_callback(struct dm_tree_node *node,
 			return 0;
 		}
 	}
+
+	dm_device_list_destroy(&cmd->cache_dm_devs); /* Cache no longer valid */
+
 	log_debug("Running check command on %s", mpath);
 
 	if (data->skip_zero) {
@@ -3777,6 +3797,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	struct dm_tree_node *root;
 	char *dlid;
 	int r = 0;
+	unsigned tmp_state;
 
 	if (action < DM_ARRAY_SIZE(_action_names))
 		log_debug_activation("Creating %s%s tree for %s.",
@@ -3796,9 +3817,17 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 	dm->suspend = (action == SUSPEND_WITH_LOCKFS) || (action == SUSPEND);
 	dm->track_external_lv_deps = 1;
 
+	/* ATM do not use caching for anything else then striped target.
+	 * And also skip for CLEAN action */
+	tmp_state = dm->cmd->disable_dm_devs;
+	if (!seg_is_striped_target(first_seg(lv)) || (action == CLEAN))
+		dm->cmd->disable_dm_devs = 1;
+
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
+	dm->cmd->disable_dm_devs = tmp_state;
+
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
 		log_error("Lost dependency tree root node.");
 		goto out_no_root;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c772dc6b1..301596482 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2052,6 +2052,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->cft_def_hash)
 		dm_hash_destroy(cmd->cft_def_hash);
 
+	dm_device_list_destroy(&cmd->cache_dm_devs);
 #ifndef VALGRIND_POOL
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4d7d4630d..f16322d4e 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -203,6 +203,7 @@ struct cmd_context {
 	unsigned event_activation:1;		/* whether event_activation is set */
 	unsigned udevoutput:1;
 	unsigned online_vg_file_removed:1;
+	unsigned disable_dm_devs:1;		/* temporarily disable use of dm devs cache */
 
 	/*
 	 * Devices and filtering.
@@ -214,6 +215,8 @@ struct cmd_context {
 	const char *devicesfile;                /* from --devicesfile option */
 	struct dm_list deviceslist;             /* from --devices option, struct dm_str_list */
 
+	struct dm_list *cache_dm_devs;		/* cache with UUIDs from DM_DEVICE_LIST (when available) */
+
 	/*
 	 * Configuration.
 	 */
diff --git a/lib/label/label.c b/lib/label/label.c
index 5c77a6923..8676b9e4a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1719,6 +1719,41 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 	}
 }
 
+void label_scan_invalidate_lvs(struct cmd_context *cmd, struct dm_list *lvs)
+{
+	struct dm_list *devs;
+	struct dm_active_device *dm_dev;
+	unsigned devs_features = 0;
+	struct device *dev;
+	struct lv_list *lvl;
+	dev_t devt;
+
+	if (get_device_list(NULL, &devs, &devs_features)) {
+		if (devs_features & DM_DEVICE_LIST_HAS_UUID) {
+			dm_list_iterate_items(dm_dev, devs)
+				if (dm_dev->uuid &&
+				    strncmp(dm_dev->uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1) == 0) {
+					devt = MKDEV(dm_dev->major, dm_dev->minor);
+					if ((dev = dev_cache_get_by_devt(cmd, devt, NULL, NULL)))
+						label_scan_invalidate(dev);
+				}
+			/* ATM no further caching for any lvconvert command
+			 * TODO: any other command to be skipped ??
+			 */
+			if (strcmp(cmd->name, "lvconvert")) {
+				dm_device_list_destroy(&cmd->cache_dm_devs);
+				cmd->cache_dm_devs = devs; /* cache to avoid unneeded checks */
+				devs = NULL;
+			}
+		}
+		dm_device_list_destroy(&devs);
+	}
+
+	if (!(devs_features & DM_DEVICE_LIST_HAS_UUID))
+		dm_list_iterate_items(lvl, lvs)
+			label_scan_invalidate_lv(cmd, lvl->lv);
+}
+
 /*
  * Empty the bcache of all blocks and close all open fds,
  * but keep the bcache set up.
diff --git a/lib/label/label.h b/lib/label/label.h
index 3cda1818c..26784c3e8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -110,6 +110,7 @@ int label_scan_devs_excl(struct cmd_context *cmd, struct dev_filter *f, struct d
 int label_scan_dev(struct cmd_context *cmd, struct device *dev);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
+void label_scan_invalidate_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 void label_scan_drop(struct cmd_context *cmd);
 void label_scan_destroy(struct cmd_context *cmd);
 int label_scan_setup_bcache(void);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c69f08c09..a8153a693 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -330,6 +330,7 @@ int vg_write_lock_held(void)
 
 int sync_local_dev_names(struct cmd_context* cmd)
 {
+	dm_device_list_destroy(&cmd->cache_dm_devs);
 	memlock_unlock(cmd);
 	fs_unlock();
 	return 1;
diff --git a/tools/toollib.c b/tools/toollib.c
index 3b3a20689..f95c98f51 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3122,8 +3122,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 * in bcache, and needs to be closed so the open fd doesn't
 	 * interfere with processing the LV.
 	 */
-	dm_list_iterate_items(lvl, &final_lvs)
-		label_scan_invalidate_lv(cmd, lvl->lv);
+	label_scan_invalidate_lvs(cmd, &final_lvs);
 
 	dm_list_iterate_items(lvl, &final_lvs) {
 		lv_uuid[0] = '\0';


