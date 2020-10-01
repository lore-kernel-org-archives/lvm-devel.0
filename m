From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Oct 2020 15:10:08 +0000 (GMT)
Subject: master - pvcreate/pvremove: reimplement device checks
Message-ID: <20201001151008.B37AB398542E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1b7438c9fb7ab9b0940ce433c0ece2fa17a6f03
Commit:        d1b7438c9fb7ab9b0940ce433c0ece2fa17a6f03
Parent:        46e5908759a803173c2d8964d8ca832195993f3b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 23 13:19:11 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 10:09:09 2020 -0500

pvcreate/pvremove: reimplement device checks

Reorganize checking the device args for pvcreate/pvremove
to prepare for future changes.  There should be no change
in behavior.  Stop the inverted use of process_each_pv,
which pulled in a lot of unnecessary processing, and call
the check functions on each device directly.
---
 tools/toollib.c | 542 ++++++++++++++++++++++++--------------------------------
 1 file changed, 231 insertions(+), 311 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0016648e3..1814399b9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4869,113 +4869,84 @@ static struct pvcreate_device *_pvcreate_list_find_name(struct dm_list *devices,
 	return NULL;
 }
 
-/*
- * If this function decides that a arg_devices entry cannot be used, but the
- * command might be able to continue without it, then it moves that entry from
- * arg_devices to arg_fail.
- *
- * If this function decides that an arg_devices entry could be used (possibly
- * requiring a prompt), then it moves the entry from arg_devices to arg_process.
- *
- * Any arg_devices entries that are not moved to arg_fail or arg_process were
- * not found.  The caller will decide if the command can continue if any
- * arg_devices entries were not found, or if any were moved to arg_fail.
- *
- * This check does not need to look at PVs in foreign, shared or clustered VGs.
- * If pvcreate/vgcreate/vgextend specifies a device in a
- * foreign/shared/clustered VG, that VG will not be processed by this function,
- * and the arg will be reported as not found.
- */
-static int _pvcreate_check_single(struct cmd_context *cmd,
-				  struct volume_group *vg,
-				  struct physical_volume *pv,
-				  struct processing_handle *handle)
+static int _pvcreate_check_used(struct cmd_context *cmd,
+				struct pvcreate_params *pp,
+				struct pvcreate_device *pd)
 {
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
-	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
 	uint64_t size = 0;
 	uint64_t new_size = 0;
 	int need_size_prompt = 0;
 	int need_vg_prompt = 0;
-	int found = 0;
+	struct lvmcache_info *info;
+	const char *vgname;
 
-	if (!pv->dev)
-		return 1;
+	log_debug("Checking %s for pvcreate %.32s.",
+		  dev_name(pd->dev), pd->dev->pvid[0] ? pd->dev->pvid : "");
 
 	/*
-	 * Check if one of the command args in arg_devices
-	 * matches this device.
+	 * Since the device is likely not a PV yet, it was probably not
+	 * scanned by label_scan at the start of the command, so that
+	 * needs to be done first to find if there's a PV label or metadata
+	 * on it.  If there's a PV label, it sets dev->pvid.
+	 * If a VG is using the dev, it adds basic VG info for it to
+	 * lvmcache.
 	 */
-	dm_list_iterate_items(pd, &pp->arg_devices) {
-		if (pd->dev != pv->dev)
-			continue;
+	label_read(pd->dev);
 
-		if (pv->dev->pvid[0])
-			strncpy(pd->pvid, pv->dev->pvid, ID_LEN);
-		found = 1;
-		break;
+	if (!pd->dev->pvid[0]) {
+		log_debug("Check pvcreate arg %s no PVID found", dev_name(pd->dev));
+		pd->is_not_pv = 1;
+		return 1;
 	}
 
 	/*
-	 * Check if the uuid specified for the new PV is used by another PV.
+	 * Don't allow using a device with duplicates.
 	 */
-	if (!found && pv->dev && pp->uuid_str && id_equal(&pv->id, &pp->pva.id)) {
-		log_error("UUID %s already in use on \"%s\".", pp->uuid_str, pv_dev_name(pv));
-		pp->check_failed = 1;
+	if (lvmcache_pvid_in_unused_duplicates(pd->dev->pvid)) {
+		log_error("Cannot use device %s with duplicates.", dev_name(pd->dev));
+		dm_list_move(&pp->arg_fail, &pd->list);
 		return 0;
 	}
 
-	if (!found)
-		return 1;
-
-	log_debug("Checking pvcreate arg %s which has existing PVID: %.32s.",
-		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "<none>");
-
-
-	/*
-	 * Don't allow using a device with duplicates.
-	 */
-	if (lvmcache_pvid_in_unused_duplicates(pd->dev->pvid)) {
-		log_error("Cannot use device %s with duplicates.", pd->name);
+	if (!(info = lvmcache_info_from_pvid(pd->dev->pvid, pd->dev, 0))) {
+		log_error("Failed to read lvm info for %s PVID %s.", dev_name(pd->dev), pd->dev->pvid);
 		dm_list_move(&pp->arg_fail, &pd->list);
-		return 1;
+		return 0;
 	}
 
+	vgname = lvmcache_vgname_from_info(info);
+
 	/*
 	 * What kind of device is this: an orphan PV, an uninitialized/unused
 	 * device, a PV used in a VG.
 	 */
-	if (vg && !is_orphan_vg(vg->name)) {
+	if (vgname && !is_orphan_vg(vgname)) {
 		/* Device is a PV used in a VG. */
-		log_debug("Found pvcreate arg %s: pv is used in %s.", pd->name, vg->name);
+		log_debug("Check pvcreate arg %s found vg %s.", dev_name(pd->dev), vgname);
 		pd->is_vg_pv = 1;
-		pd->vg_name = dm_pool_strdup(cmd->mem, vg->name);
-	} else if (vg && is_orphan_vg(vg->name)) {
-		if (is_used_pv(pv)) {
+		pd->vg_name = dm_pool_strdup(cmd->mem, vgname);
+	} else if (!vgname || (vgname && is_orphan_vg(vgname))) {
+		uint32_t ext_flags = lvmcache_ext_flags(info);
+		if (ext_flags & PV_EXT_USED) {
 			/* Device is used in an unknown VG. */
-			log_debug("Found pvcreate arg %s: PV is used in unknown VG.", pd->name);
+			log_debug("Check pvcreate arg %s found EXT_USED flag.", dev_name(pd->dev));
 			pd->is_used_unknown_pv = 1;
 		} else {
 			/* Device is an orphan PV. */
-			log_debug("Found pvcreate arg %s: PV is orphan in %s.", pd->name, vg->name);
+			log_debug("Check pvcreate arg %s is orphan.", dev_name(pd->dev));
 			pd->is_orphan_pv = 1;
 		}
-
 		pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
-	} else {
-		log_debug("Found pvcreate arg %s: device is not a PV.", pd->name);
-		/* Device is not a PV. */
-		pd->is_not_pv = 1;
 	}
 
 	if (arg_is_set(cmd, setphysicalvolumesize_ARG)) {
 		new_size = arg_uint64_value(cmd, setphysicalvolumesize_ARG, UINT64_C(0));
 
-		if (!dev_get_size(pv->dev, &size)) {
-			log_error("Can't get device size of %s.", pv_dev_name(pv));
+		if (!dev_get_size(pd->dev, &size)) {
+			log_error("Can't get device size of %s.", dev_name(pd->dev));
 			dm_list_move(&pp->arg_fail, &pd->list);
-			return 1;
+			return 0;
 		}
 
 		if (new_size != size)
@@ -4994,26 +4965,22 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	else
 		need_vg_prompt = 1;
 
-	if (!need_size_prompt && !need_vg_prompt) {
-		pd->dev = pv->dev;
-		dm_list_move(&pp->arg_process, &pd->list);
+	if (!need_size_prompt && !need_vg_prompt)
 		return 1;
-	}
 
 	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
-		log_error("prompt alloc failed.");
-		pp->check_failed = 1;
-		return 0;
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return_0;
 	}
 	prompt->dev = pd->dev;
-	prompt->pv_name = dm_pool_strdup(cmd->mem, pd->name);
+	prompt->pv_name = dm_pool_strdup(cmd->mem, dev_name(pd->dev));
 	prompt->size = size;
 	prompt->new_size = new_size;
 
 	if (pd->is_used_unknown_pv)
 		prompt->vg_name_unknown = 1;
 	else if (need_vg_prompt)
-		prompt->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+		prompt->vg_name = dm_pool_strdup(cmd->mem, vgname);
 
 	if (need_size_prompt)
 		prompt->type |= PROMPT_PVCREATE_DEV_SIZE;
@@ -5022,149 +4989,44 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 		prompt->type |= PROMPT_PVCREATE_PV_IN_VG;
 
 	dm_list_add(&pp->prompts, &prompt->list);
-	pd->dev = pv->dev;
-	dm_list_move(&pp->arg_process, &pd->list);
 
 	return 1;
 }
 
-/*
- * This repeats the first check -- devices should be found, and should not have
- * changed since the first check.  If they were changed/used while the orphans
- * lock was not held (during prompting), then they can't be used any more and
- * are moved to arg_fail.  If they are not found by this loop, that also
- * disqualifies them from being used.  Each arg_confirm entry that's found and
- * is ok, is moved to arg_process.  Those not found will remain in arg_confirm.
- *
- * This check does not need to look in foreign/shared/clustered VGs.  If a
- * device from arg_confirm was used in a foreign/shared/clustered VG during the
- * prompts, then it will not be found during this check.
- */
-
-static int _pv_confirm_single(struct cmd_context *cmd,
-			      struct volume_group *vg,
-			      struct physical_volume *pv,
-			      struct processing_handle *handle)
+static int _pvremove_check_used(struct cmd_context *cmd,
+				struct pvcreate_params *pp,
+				struct pvcreate_device *pd)
 {
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
-	struct pvcreate_device *pd;
-	int found = 0;
-
-	dm_list_iterate_items(pd, &pp->arg_confirm) {
-		if (pd->dev != pv->dev)
-			continue;
-		found = 1;
-		break;
-	}
-
-	if (!found)
-		return 1;
-
-	/*
-	 * What kind of device is this: an orphan PV, an uninitialized/unused
-	 * device, a PV used in a VG.
-	 */
-	if (vg && !is_orphan_vg(vg->name)) {
-		/* Device is a PV used in a VG. */
-
-		if (pd->is_orphan_pv || pd->is_not_pv || pd->is_used_unknown_pv) {
-			/* In check_single it was an orphan or unused. */
-			goto fail;
-		}
-
-		if (pd->is_vg_pv && pd->vg_name && strcmp(pd->vg_name, vg->name)) {
-			/* In check_single it was in a different VG. */
-			goto fail;
-		}
-	} else if (is_orphan(pv)) {
-		/* Device is an orphan PV. */
-
-		if (pd->is_not_pv) {
-			/* In check_single it was not a PV. */
-			goto fail;
-		}
-
-		if (pd->is_vg_pv) {
-			/* In check_single it was in a VG. */
-			goto fail;
-		}
-
-		if (is_used_pv(pv) != pd->is_used_unknown_pv) {
-			/* In check_single it was different. */
-			goto fail;
-		}
-	} else {
-		/* Device is not a PV. */
-		if (pd->is_orphan_pv || pd->is_used_unknown_pv) {
-			/* In check_single it was an orphan PV. */
-			goto fail;
-		}
-
-		if (pd->is_vg_pv) {
-			/* In check_single it was in a VG. */
-			goto fail;
-		}
-	}
-
-	/* Device is unchanged from check_single. */
-	dm_list_move(&pp->arg_process, &pd->list);
-
-	return 1;
-
-fail:
-	log_error("Cannot use device %s: it changed during prompt.", pd->name);
-	dm_list_move(&pp->arg_fail, &pd->list);
-
-	return 1;
-}
-
-static int _pvremove_check_single(struct cmd_context *cmd,
-				  struct volume_group *vg,
-				  struct physical_volume *pv,
-				  struct processing_handle *handle)
-{
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
-	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
-	int found = 0;
+	struct lvmcache_info *info;
+	const char *vgname = NULL;
 
-	if (!pv->dev)
-		return 1;
+	log_debug("Checking %s for pvremove %.32s.",
+		  dev_name(pd->dev), pd->dev->pvid[0] ? pd->dev->pvid : "");
 
 	/*
-	 * Check if one of the command args in arg_devices
-	 * matches this device.
+	 * Is there a pv here already?
+	 * If not, this is an error unless you used -f.
 	 */
-	dm_list_iterate_items(pd, &pp->arg_devices) {
-		if (pd->dev != pv->dev)
-			continue;
 
-		if (pv->dev->pvid[0])
-			strncpy(pd->pvid, pv->dev->pvid, ID_LEN);
-		found = 1;
-		break;
+	if (!pd->dev->pvid[0]) {
+		log_debug("Check pvremove arg %s no PVID found", dev_name(pd->dev));
+		if (pp->force)
+			return 1;
+		pd->is_not_pv = 1;
 	}
 
-	if (!found)
-		return 1;
-
-	log_debug("Checking device %s for pvremove %.32s.",
-		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
-
-
-	/*
-	 * Is there a pv here already?
-	 * If not, this is an error unless you used -f.
-	 */
-	if (!lvmcache_has_dev_info(pv->dev)) {
-		if (pp->force) {
-			dm_list_move(&pp->arg_process, &pd->list);
+	if (!(info = lvmcache_info_from_pvid(pd->dev->pvid, pd->dev, 0))) {
+		if (pp->force)
 			return 1;
-		} else {
-			pd->is_not_pv = 1;
-		}
+		log_error("Failed to read lvm info for %s PVID %s.", dev_name(pd->dev), pd->dev->pvid);
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return 0;
 	}
 
+	if (info)
+		vgname = lvmcache_vgname_from_info(info);
+
 	/*
 	 * What kind of device is this: an orphan PV, an uninitialized/unused
 	 * device, a PV used in a VG.
@@ -5172,49 +5034,40 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 
 	if (pd->is_not_pv) {
 		/* Device is not a PV. */
-		log_debug("Found pvremove arg %s: device is not a PV.", pd->name);
+		log_debug("Check pvremove arg %s device is not a PV.", dev_name(pd->dev));
 
-	} else if (vg && !is_orphan_vg(vg->name)) {
+	} else if (vgname && !is_orphan_vg(vgname)) {
 		/* Device is a PV used in a VG. */
-		log_debug("Found pvremove arg %s: pv is used in %s.", pd->name, vg->name);
+		log_debug("Check pvremove arg %s found vg %s.", dev_name(pd->dev), vgname);
 		pd->is_vg_pv = 1;
-		pd->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+		pd->vg_name = dm_pool_strdup(cmd->mem, vgname);
 
-	} else if (vg && is_orphan_vg(vg->name)) {
-		if (is_used_pv(pv)) {
+	} else if (info && (!vgname || (vgname && is_orphan_vg(vgname)))) {
+		uint32_t ext_flags = lvmcache_ext_flags(info);
+		if (ext_flags & PV_EXT_USED) {
 			/* Device is used in an unknown VG. */
-			log_debug("Found pvremove arg %s: pv is used in unknown VG.", pd->name);
+			log_debug("Check pvremove arg %s found EXT_USED flag.", dev_name(pd->dev));
 			pd->is_used_unknown_pv = 1;
 		} else {
 			/* Device is an orphan PV. */
-			log_debug("Found pvremove arg %s: pv is orphan in %s.", pd->name, vg->name);
+			log_debug("Check pvremove arg %s is orphan.", dev_name(pd->dev));
 			pd->is_orphan_pv = 1;
 		}
-
 		pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
-	} else {
-		/* FIXME: is it possible to reach here? */
-		log_debug("Found pvremove arg %s: device is not a PV.", pd->name);
-		/* Device is not a PV. */
-		pd->is_not_pv = 1;
 	}
 
 	if (pd->is_not_pv) {
-		pd->dev = pv->dev;
-		log_error("No PV found on device %s.", pd->name);
+		log_error("No PV found on device %s.", dev_name(pd->dev));
 		dm_list_move(&pp->arg_fail, &pd->list);
-		return 1;
+		return 0;
 	}
 
 	/*
 	 * pvremove is being run on this device, and it's not a PV,
 	 * or is an orphan PV.  Neither case requires a prompt.
 	 */
-	if (pd->is_orphan_pv) {
-		pd->dev = pv->dev;
-		dm_list_move(&pp->arg_process, &pd->list);
+	if (pd->is_orphan_pv)
 		return 1;
-	}
 
 	/*
 	 * pvremove is being run on this device, but the device is in a VG.
@@ -5222,22 +5075,104 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 */
 
 	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
-		log_error("prompt alloc failed.");
-		pp->check_failed = 1;
-		return 0;
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return_0;
 	}
 	prompt->dev = pd->dev;
-	prompt->pv_name = dm_pool_strdup(cmd->mem, pd->name);
+	prompt->pv_name = dm_pool_strdup(cmd->mem, dev_name(pd->dev));
 	if (pd->is_used_unknown_pv)
 		prompt->vg_name_unknown = 1;
 	else
-		prompt->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+		prompt->vg_name = dm_pool_strdup(cmd->mem, vgname);
 	prompt->type |= PROMPT_PVREMOVE_PV_IN_VG;
 	dm_list_add(&pp->prompts, &prompt->list);
 
-	pd->dev = pv->dev;
-	dm_list_move(&pp->arg_process, &pd->list);
+	return 1;
+}
+
+static int _confirm_check_used(struct cmd_context *cmd,
+				struct pvcreate_params *pp,
+				struct pvcreate_device *pd)
+{
+	struct lvmcache_info *info = NULL;
+	const char *vgname = NULL;
+	int is_not_pv = 0;
+
+	log_debug("Checking %s to confirm %.32s.",
+		  dev_name(pd->dev), pd->dev->pvid[0] ? pd->dev->pvid : "");
+
+	if (!pd->dev->pvid[0]) {
+		log_debug("Check confirm arg %s no PVID found", dev_name(pd->dev));
+		is_not_pv = 1;
+	}
+
+	if (!(info = lvmcache_info_from_pvid(pd->dev->pvid, pd->dev, 0))) {
+		log_debug("Check confirm arg %s no info.", dev_name(pd->dev));
+		is_not_pv = 1;
+	}
+
+	if (info)
+		vgname = lvmcache_vgname_from_info(info);
+
+
+	/*
+	 * What kind of device is this: an orphan PV, an uninitialized/unused
+	 * device, a PV used in a VG.
+	 */
+	if (vgname && !is_orphan_vg(vgname)) {
+		/* Device is a PV used in a VG. */
+
+		if (pd->is_orphan_pv || pd->is_not_pv || pd->is_used_unknown_pv) {
+			/* In first check it was an orphan or unused. */
+			goto fail;
+		}
+
+		if (pd->is_vg_pv && pd->vg_name && strcmp(pd->vg_name, vgname)) {
+			/* In first check it was in a different VG. */
+			goto fail;
+		}
+	} else if (info && (!vgname || is_orphan_vg(vgname))) {
+		uint32_t ext_flags = lvmcache_ext_flags(info);
+
+		/* Device is an orphan PV. */
+
+		if (pd->is_not_pv) {
+			/* In first check it was not a PV. */
+			goto fail;
+		}
+
+		if (pd->is_vg_pv) {
+			/* In first check it was in a VG. */
+			goto fail;
+		}
+
+		if ((ext_flags & PV_EXT_USED) && !pd->is_used_unknown_pv) {
+			/* In first check it was different. */
+			goto fail;
+		}
+
+		if (!(ext_flags & PV_EXT_USED) && pd->is_used_unknown_pv) {
+			/* In first check it was different. */
+			goto fail;
+		}
+	} else if (is_not_pv) {
+		/* Device is not a PV. */
+		if (pd->is_orphan_pv || pd->is_used_unknown_pv) {
+			/* In first check it was an orphan PV. */
+			goto fail;
+		}
+
+		if (pd->is_vg_pv) {
+			/* In first check it was in a VG. */
+			goto fail;
+		}
+	}
+
+	return 1;
 
+fail:
+	log_error("Cannot use device %s: it changed during prompt.", dev_name(pd->dev));
+	dm_list_move(&pp->arg_fail, &pd->list);
 	return 1;
 }
 
@@ -5247,10 +5182,6 @@ static int _pvremove_check_single(struct cmd_context *cmd,
  * line args.  This includes the pv_names field which specifies the devices to
  * create PVs on.
  *
- * This uses process_each_pv() and should be called from a high level in the
- * command -- the same level at which other instances of process_each are
- * called.
- *
  * This function returns 0 (failed) if the caller requires all specified
  * devices to be created, and any of those devices are not found, or any of
  * them cannot be created.
@@ -5278,6 +5209,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	unsigned int physical_block_size, logical_block_size;
 	unsigned int prev_pbs = 0, prev_lbs = 0;
 	int must_use_all = (cmd->cname->flags & MUST_USE_ALL_ARGS);
+	int unlocked_for_prompts = 0;
 	int found;
 	unsigned i;
 
@@ -5313,17 +5245,28 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	/*
 	 * Translate arg names into struct device's.
 	 */
-	dm_list_iterate_items(pd, &pp->arg_devices)
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
 		pd->dev = dev_cache_get(cmd, pd->name, cmd->filter);
+		if (!pd->dev) {
+			log_error("Device %s not found.", pd->name);
+			dm_list_del(&pd->list);
+			dm_list_add(&pp->arg_fail, &pd->list);
+		}
+	}
+
+	/*
+	 * Can the command continue if some specified devices were not found?
+	 */
+	if (must_use_all && !dm_list_empty(&pp->arg_fail)) {
+		log_error("Command requires all devices to be found.");
+		return_0;
+	}
 
 	/*
 	 * Check for consistent block sizes.
 	 */
 	if (pp->check_consistent_block_size) {
 		dm_list_iterate_items(pd, &pp->arg_devices) {
-			if (!pd->dev)
-				continue;
-
 			logical_block_size = 0;
 			physical_block_size = 0;
 
@@ -5361,58 +5304,48 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * Use process_each_pv to search all existing PVs and devices.
-	 *
-	 * This is a slightly different way to use process_each_pv, because the
-	 * command args (arg_devices) are not being processed directly by
-	 * process_each_pv (argc and argv are not passed).  Instead,
-	 * process_each_pv is processing all existing PVs and devices, and the
-	 * single function is matching each of those against the command args
-	 * (arg_devices).
-	 *
-	 * If an arg_devices entry is found during process_each_pv, it's moved
-	 * to arg_process if it can be used, or arg_fail if it cannot be used.
-	 * If it's added to arg_process but needs a prompt or force option, then
-	 * a corresponding prompt entry is added to pp->prompts.
-	 */
-	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN,
-			handle, pp->is_remove ? _pvremove_check_single : _pvcreate_check_single);
+	/* check_used moves pd entries into the arg_fail list if pvcreate/pvremove is disallowed */
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
+		if (pp->is_remove)
+			_pvremove_check_used(cmd, pp, pd);
+		else
+			_pvcreate_check_used(cmd, pp, pd);
+	}
 
 	/*
-	 * A fatal error was found while checking.
+	 * If the user specified a uuid for the new PV, check
+	 * if a PV on another dev is already using that uuid.
 	 */
-	if (pp->check_failed)
-		goto_bad;
+	if (!pp->is_remove && pp->uuid_str) {
+		struct device *dev;
+		if ((dev = lvmcache_device_from_pvid(cmd, &pp->pva.id, NULL))) {
+			dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
+				if (pd->dev != dev) {
+					log_error("UUID %s already in use on \"%s\".", pp->uuid_str, dev_name(dev));
+					dm_list_move(&pp->arg_fail, &pd->list);
+				}
+			}
+		}
+	}
 
 	/*
 	 * Special case: pvremove -ff is allowed to clear a duplicate device in
-	 * the unchosen duplicates list.  PVs in the unchosen duplicates list
-	 * won't be found by normal process_each searches -- they are not in
-	 * lvmcache and can't be processed normally.  We save them here and
-	 * erase them below without going through the normal processing code.
+	 * the unchosen duplicates list.  We save them here and erase them below.
 	 */
 	if (pp->is_remove && (pp->force == DONT_PROMPT_OVERRIDE) &&
 	   !dm_list_empty(&pp->arg_devices) && lvmcache_has_duplicate_devs()) {
 		dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
 			if (lvmcache_dev_is_unused_duplicate(pd->dev)) {
-				log_debug("Found pvremove arg %s: device is a duplicate.", pd->name);
+				log_debug("Check pvremove arg %s device is a duplicate.", dev_name(pd->dev));
 				dm_list_move(&remove_duplicates, &pd->list);
 			}
 		}
 	}
 
 	/*
-	 * Check if all arg_devices were found by process_each_pv.
+	 * Any devices not moved to arg_fail can be processed.
 	 */
-	dm_list_iterate_items(pd, &pp->arg_devices)
-		log_error("Device %s %s.", pd->name, dev_cache_filtered_reason(pd->name));
-
-	/*
-	 * Can the command continue if some specified devices were not found?
-	 */
-	if (!dm_list_empty(&pp->arg_devices) && must_use_all)
-		goto_bad;
+	dm_list_splice(&pp->arg_process, &pp->arg_devices);
 
 	/*
 	 * Can the command continue if some specified devices cannot be used?
@@ -5468,8 +5401,10 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	lockf_global(cmd, "un");
 
+	unlocked_for_prompts = 1;
+
 	/*
-	 * Process prompts that require asking the user.  The orphans lock is
+	 * Process prompts that require asking the user.  The global lock is
 	 * not held, so there's no harm in waiting for a user to respond.
 	 */
 	dm_list_iterate_items_safe(prompt, prompt2, &pp->prompts) {
@@ -5500,7 +5435,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	/*
 	 * Reacquire the lock that was released above before waiting, then
-	 * check again that the devices can still be used.  If the second loop
+	 * check again that the devices can still be used.  If the second check
 	 * finds them changed, or can't find them any more, then they aren't
 	 * used.  Use a non-blocking request when reacquiring to avoid
 	 * potential deadlock since this is not the normal locking sequence.
@@ -5511,41 +5446,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	lvmcache_label_scan(cmd);
-
-	/*
-	 * The device args began on the arg_devices list, then the first check
-	 * loop moved those entries to arg_process as they were found.  Devices
-	 * not found during the first loop are not being used, and remain on
-	 * arg_devices.
-	 * 
-	 * Now, the arg_process entries are moved to arg_confirm, and the second
-	 * check loop moves them back to arg_process as they are found and are
-	 * unchanged.  Like the first loop, the second loop moves an entry to
-	 * arg_fail if it cannot be used.  After the second loop, any devices
-	 * remaining on arg_confirm were not found and are not used.
-	 */
-	dm_list_splice(&pp->arg_confirm, &pp->arg_process);
-
-	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN,
-			handle, _pv_confirm_single);
-
-	dm_list_iterate_items(pd, &pp->arg_confirm)
-		log_error("Device %s %s.", pd->name, dev_cache_filtered_reason(pd->name));
-
-	/* Some devices were not found during the second check. */
-	if (!dm_list_empty(&pp->arg_confirm) && must_use_all)
-		goto_bad;
-
-	/* Some devices changed during the second check. */
-	if (!dm_list_empty(&pp->arg_fail) && must_use_all)
-		goto_bad;
-
-	if (dm_list_empty(&pp->arg_process)) {
-		log_debug("No devices to process.");
-		goto bad;
-	}
-
 do_command:
 
 	dm_list_iterate_items(pd, &pp->arg_process) {
@@ -5561,6 +5461,25 @@ do_command:
 		goto bad;
 	}
 
+	/*
+	 * If the global lock was unlocked to wait for prompts, then
+	 * devs could have changed while unlocked, so confirm that
+	 * the devs are unchanged since check_used.
+	 * Changed pd entries are moved to arg_fail.
+	 */
+	if (unlocked_for_prompts) {
+		dm_list_iterate_items_safe(pd, pd2, &pp->arg_process)
+			_confirm_check_used(cmd, pp, pd);
+
+		if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+			goto_bad;
+	}
+
+	if (dm_list_empty(&pp->arg_process)) {
+		log_debug("No devices to process.");
+		goto bad;
+	}
+
 	/*
 	 * Reorder arg_process entries to match the original order of args.
 	 */
@@ -5579,6 +5498,7 @@ do_command:
 	 * Wipe signatures on devices being created.
 	 */
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
+		/* FIXME: won't all already be open excl from label_scan_devs_excl above? */
 		label_scan_open_excl(pd->dev);
 
 		log_verbose("Wiping signatures on new PV %s.", pd->name);
@@ -5658,6 +5578,7 @@ do_command:
 
 		pv_name = pd->name;
 
+		/* FIXME: won't all already be open excl from label_scan_devs_excl above? */
 		label_scan_open_excl(pd->dev);
 
 		log_debug("Creating a new PV on %s.", pv_name);
@@ -5671,7 +5592,6 @@ do_command:
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 			    " available sectors.", pv_name, pv_size(pv));
 
-
 		if (!label_remove(pv->dev)) {
 			log_error("Failed to wipe existing label on %s.", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);


