From: David Teigland <teigland@sourceware.org>
Date: Mon, 29 Apr 2019 15:31:53 -0400
Subject: master - remove retry for missed PVs in process_each_pv
Message-ID: <201904291931.x3TJVrGa011006@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a519be8d4b9818f6715eb43a4e9427a4b1dd61ab
Commit:        a519be8d4b9818f6715eb43a4e9427a4b1dd61ab
Parent:        8c87dda195ffadcce1e428d3481e8d01080e2b22
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 23 14:47:56 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 29 13:01:15 2019 -0500

remove retry for missed PVs in process_each_pv

This is no longer needed with the change to orphan
and global locks.
---
 tools/toollib.c |  105 -------------------------------------------------------
 1 files changed, 0 insertions(+), 105 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 5882675..b8be826 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3992,59 +3992,6 @@ static struct device_id_list *_device_list_find_dev(struct dm_list *devices, str
 	return NULL;
 }
 
-static int _device_list_copy(struct cmd_context *cmd, struct dm_list *src, struct dm_list *dst)
-{
-	struct device_id_list *dil;
-	struct device_id_list *dil_new;
-
-	dm_list_iterate_items(dil, src) {
-		if (!(dil_new = dm_pool_alloc(cmd->mem, sizeof(*dil_new)))) {
-			log_error("device_id_list alloc failed.");
-			return ECMD_FAILED;
-		}
-
-		dil_new->dev = dil->dev;
-		strncpy(dil_new->pvid, dil->pvid, ID_LEN);
-		dm_list_add(dst, &dil_new->list);
-	}
-
-	return ECMD_PROCESSED;
-}
-
-/*
- * For each device in arg_devices or all_devices that has a pvid, add a copy of
- * that device to arg_missed.  All PVs (devices with a pvid) should have been
- * found while processing all VGs (including orphan VGs).  But, some may have
- * been missed if VGs were changing at the same time.  This function creates a
- * list of PVs that still remain in the given list, i.e. were missed the first
- * time.  A second iteration through VGs can look for these explicitly.
- * (arg_devices is used if specific PVs are being processed; all_devices is
- * used if all devs are being processed)
- */
-static int _get_missed_pvs(struct cmd_context *cmd,
-			   struct dm_list *devices,
-			   struct dm_list *arg_missed)
-{
-	struct device_id_list *dil;
-	struct device_id_list *dil_missed;
-
-	dm_list_iterate_items(dil, devices) {
-		if (!dil->pvid[0])
-			continue;
-
-		if (!(dil_missed = dm_pool_alloc(cmd->mem, sizeof(*dil_missed)))) {
-			log_error("device_id_list alloc failed.");
-			return ECMD_FAILED;
-		}
-
-		dil_missed->dev = dil->dev;
-		strncpy(dil_missed->pvid, dil->pvid, ID_LEN);
-		dm_list_add(arg_missed, &dil_missed->list);
-	}
-
-	return ECMD_PROCESSED;
-}
-
 static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
 				struct processing_handle *handle,
 				process_single_pv_fn_t process_single_pv)
@@ -4436,7 +4383,6 @@ int process_each_pv(struct cmd_context *cmd,
 	struct dm_list arg_tags;	/* str_list */
 	struct dm_list arg_pvnames;	/* str_list */
 	struct dm_list arg_devices;	/* device_id_list */
-	struct dm_list arg_missed;	/* device_id_list */
 	struct dm_list all_vgnameids;	/* vgnameid_list */
 	struct dm_list all_devices;	/* device_id_list */
 	struct device_id_list *dil;
@@ -4467,7 +4413,6 @@ int process_each_pv(struct cmd_context *cmd,
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_pvnames);
 	dm_list_init(&arg_devices);
-	dm_list_init(&arg_missed);
 	dm_list_init(&all_vgnameids);
 	dm_list_init(&all_devices);
 
@@ -4570,56 +4515,6 @@ int process_each_pv(struct cmd_context *cmd,
 	if (ret > ret_max)
 		ret_max = ret;
 
-	/*
-	 * If the orphans lock was held, there shouldn't be missed devices.
-	 *
-	 * FIXME: this case can now be removed with the global lock
-	 * replacing the orphans lock.
-	 */
-	goto skip_missed;
-
-	/*
-	 * Some PVs may have been missed by the first search if another command
-	 * moved them at the same time.  Repeat the search for only the
-	 * specific PVs missed.  lvmcache needs clearing for a fresh search.
-	 *
-	 * If missed PVs are found in this repeated search, they are removed
-	 * from the arg_missed list, but they also need to be removed from the
-	 * arg_devices list, otherwise the check at the end will produce an
-	 * error, thinking they weren't found.  This is the reason for saving
-	 * and comparing the original arg_missed list.
-	 */
-	if (!process_all_pvs)
-		_get_missed_pvs(cmd, &arg_devices, &arg_missed);
-	else
-		_get_missed_pvs(cmd, &all_devices, &arg_missed);
-
-	if (!dm_list_empty(&arg_missed)) {
-		struct dm_list arg_missed_orig;
-
-		dm_list_init(&arg_missed_orig);
-		_device_list_copy(cmd, &arg_missed, &arg_missed_orig);
-
-		log_verbose("Some PVs were not found in first search, retrying.");
-
-		lvmcache_label_scan(cmd);
-
-		ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
-					  &arg_missed, &arg_tags, 0, 0,
-					  handle, process_single_pv);
-		if (ret != ECMD_PROCESSED)
-			stack;
-		if (ret > ret_max)
-			ret_max = ret;
-
-		/* Devices removed from arg_missed are removed from arg_devices. */
-		dm_list_iterate_items(dil, &arg_missed_orig) {
-			if (!_device_list_find_dev(&arg_missed, dil->dev))
-				_device_list_remove(&arg_devices, dil->dev);
-		}
-	}
-
-skip_missed:
 	dm_list_iterate_items(dil, &arg_devices) {
 		log_error("Failed to find physical volume \"%s\".", dev_name(dil->dev));
 		ret_max = ECMD_FAILED;


