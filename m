From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Mar 2016 13:03:16 +0000 (UTC)
Subject: master - cleanup: indent and dots
Message-ID: <20160301130316.95C2460DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=872d5922e17692332df3ee3bebeb1dac0855887d
Commit:        872d5922e17692332df3ee3bebeb1dac0855887d
Parent:        36d0dcef38ec3ce89f3c13be272efc69f981b207
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 1 11:41:09 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 1 14:02:43 2016 +0100

cleanup: indent and dots

---
 tools/toollib.c |  107 ++++++++++++++++++++++++++-----------------------------
 1 files changed, 51 insertions(+), 56 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index dbb6d40..05d765d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3689,7 +3689,6 @@ static struct pvcreate_device *_pvcreate_list_find_name(struct dm_list *devices,
  * foreign/shared/clustered VG, that VG will not be processed by this function,
  * and the arg will be reported as not found.
  */
-
 static int _pvcreate_check_single(struct cmd_context *cmd,
 				  struct volume_group *vg,
 				  struct physical_volume *pv,
@@ -3732,7 +3731,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	 * Check if the uuid specified for the new PV is used by another PV.
 	 */
 	if (!found && pv->dev && pp->uuid_str && id_equal(&pv->id, &pp->pva.id)) {
-		log_error("uuid %s already in use on \"%s\"", pp->uuid_str, pv_dev_name(pv));
+		log_error("UUID %s already in use on \"%s\".", pp->uuid_str, pv_dev_name(pv));
 		pp->check_failed = 1;
 		return 0;
 	}
@@ -3740,7 +3739,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	if (!found)
 		return 1;
 
-	log_debug("Checking device %s for pvcreate %.32s",
+	log_debug("Checking device %s for pvcreate %.32s.",
 		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
 
 	/*
@@ -3758,21 +3757,19 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	 * What kind of device is this: an orphan PV, an uninitialized/unused
 	 * device, a PV used in a VG.
 	 */
-
 	if (vg && !is_orphan_vg(vg->name)) {
 		/* Device is a PV used in a VG. */
-		log_debug("Found pvcreate arg %s: pv is used in %s", pd->name, vg->name);
+		log_debug("Found pvcreate arg %s: pv is used in %s.", pd->name, vg->name);
 		pd->is_vg_pv = 1;
 		pd->vg_name = dm_pool_strdup(cmd->mem, vg->name);
-
 	} else if (vg && is_orphan_vg(vg->name)) {
 		if (is_used_pv(pv)) {
 			/* Device is used in an unknown VG. */
-			log_debug("Found pvcreate arg %s: pv is used in unknown VG", pd->name);
+			log_debug("Found pvcreate arg %s: PV is used in unknown VG.", pd->name);
 			pd->is_used_unknown_pv = 1;
 		} else {
 			/* Device is an orphan PV. */
-			log_debug("Found pvcreate arg %s: pv is orphan in %s", pd->name, vg->name);
+			log_debug("Found pvcreate arg %s: PV is orphan in %s.", pd->name, vg->name);
 			pd->is_orphan_pv = 1;
 		}
 
@@ -3781,7 +3778,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 		else
 			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	} else {
-		log_debug("Found pvcreate arg %s: device is not a pv", pd->name);
+		log_debug("Found pvcreate arg %s: device is not a PV.", pd->name);
 		/* Device is not a PV. */
 		pd->is_not_pv = 1;
 	}
@@ -3800,15 +3797,15 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	 * pvcreate is being run on this device, but the device is already
 	 * a PV in a VG.  A prompt or force option is required to use it.
 	 */
-
 	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
-		log_error("prompt alloc failed");
+		log_error("prompt alloc failed.");
 		pp->check_failed = 1;
 		return 0;
 	}
 	prompt->dev = pd->dev;
 	prompt->type = PROMPT_PVCREATE_PV_IN_VG;
 	prompt->pv_name = dm_pool_strdup(cmd->mem, pd->name);
+
 	if (pd->is_used_unknown_pv)
 		prompt->vg_name_unknown = 1;
 	else
@@ -3817,6 +3814,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 
 	pd->dev = pv->dev;
 	dm_list_move(&pp->arg_process, &pd->list);
+
 	return 1;
 }
 
@@ -3864,7 +3862,6 @@ static int _pv_confirm_single(struct cmd_context *cmd,
 	 * What kind of device is this: an orphan PV, an uninitialized/unused
 	 * device, a PV used in a VG.
 	 */
-
 	if (vg && !is_orphan_vg(vg->name)) {
 		/* Device is a PV used in a VG. */
 
@@ -3877,7 +3874,6 @@ static int _pv_confirm_single(struct cmd_context *cmd,
 			/* In check_single it was in a different VG. */
 			goto fail;
 		}
-
 	} else if (is_orphan(pv)) {
 		/* Device is an orphan PV. */
 
@@ -3895,10 +3891,8 @@ static int _pv_confirm_single(struct cmd_context *cmd,
 			/* In check_single it was different. */
 			goto fail;
 		}
-
 	} else {
 		/* Device is not a PV. */
-
 		if (pd->is_orphan_pv || pd->is_used_unknown_pv) {
 			/* In check_single it was an orphan PV. */
 			goto fail;
@@ -3912,11 +3906,13 @@ static int _pv_confirm_single(struct cmd_context *cmd,
 
 	/* Device is unchanged from check_single. */
 	dm_list_move(&pp->arg_process, &pd->list);
+
 	return 1;
 
 fail:
 	log_error("Cannot use device %s: it changed during prompt.", pd->name);
 	dm_list_move(&pp->arg_fail, &pd->list);
+
 	return 1;
 }
 
@@ -3954,7 +3950,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	if (!found)
 		return 1;
 
-	log_debug("Checking device %s for pvremove %.32s",
+	log_debug("Checking device %s for pvremove %.32s.",
 		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
 
 	/*
@@ -3962,7 +3958,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 */
 	if (!dev_test_excl(pv->dev)) {
 		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
+		log_error("Can't open %s exclusively.  Mounted filesystem?.",
 			  pv_dev_name(pv));
 		dm_list_move(&pp->arg_fail, &pd->list);
 		return 1;
@@ -3990,18 +3986,18 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 
 	if (vg && !is_orphan_vg(vg->name)) {
 		/* Device is a PV used in a VG. */
-		log_debug("Found pvremove arg %s: pv is used in %s", pd->name, vg->name);
+		log_debug("Found pvremove arg %s: pv is used in %s.", pd->name, vg->name);
 		pd->is_vg_pv = 1;
 		pd->vg_name = dm_pool_strdup(cmd->mem, vg->name);
 
 	} else if (vg && is_orphan_vg(vg->name)) {
 		if (is_used_pv(pv)) {
 			/* Device is used in an unknown VG. */
-			log_debug("Found pvremove arg %s: pv is used in unknown VG", pd->name);
+			log_debug("Found pvremove arg %s: pv is used in unknown VG.", pd->name);
 			pd->is_used_unknown_pv = 1;
 		} else {
 			/* Device is an orphan PV. */
-			log_debug("Found pvremove arg %s: pv is orphan in %s", pd->name, vg->name);
+			log_debug("Found pvremove arg %s: pv is orphan in %s.", pd->name, vg->name);
 			pd->is_orphan_pv = 1;
 		}
 
@@ -4010,14 +4006,14 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 		else
 			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	} else {
-		log_debug("Found pvremove arg %s: device is not a pv", pd->name);
+		log_debug("Found pvremove arg %s: device is not a PV.", pd->name);
 		/* Device is not a PV. */
 		pd->is_not_pv = 1;
 	}
 
 	if (pd->is_not_pv) {
 		pd->dev = pv->dev;
-		log_error("No PV found on device %s", pd->name);
+		log_error("No PV found on device %s.", pd->name);
 		dm_list_move(&pp->arg_fail, &pd->list);
 		return 1;
 	}
@@ -4038,7 +4034,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	 */
 
 	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
-		log_error("prompt alloc failed");
+		log_error("prompt alloc failed.");
 		pp->check_failed = 1;
 		return 0;
 	}
@@ -4086,6 +4082,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct pvcreate_prompt *prompt, *prompt2;
 	struct physical_volume *pv;
 	struct volume_group *orphan_vg;
+	struct lvmcache_info *info;
 	struct dm_list arg_sort;
 	struct pv_list *pvl;
 	struct pv_list *vgpvl;
@@ -4108,12 +4105,12 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		pv_name = pp->pv_names[i];
 
 		if (!(pd = dm_pool_zalloc(cmd->mem, sizeof(*pd)))) {
-			log_error("alloc failed");
+			log_error("alloc failed.");
 			return 0;
 		}
 
 		if (!(pd->name = dm_pool_strdup(cmd->mem, pv_name))) {
-			log_error("strdup failed");
+			log_error("strdup failed.");
 			return 0;
 		}
 
@@ -4143,7 +4140,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * vgcreate/vgextend use the PVs created here to add to a VG.
 	 */
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error("Can't get lock for orphan PVs.");
 		return 0;
 	}
 
@@ -4273,11 +4270,10 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * Clear the cache here before locking orphans, since it won't be
 	 * done by process_each_pv with orphans already locked.
 	 */
-
 	lvmcache_destroy(cmd, 1, 0);
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
+		log_error("Can't get lock for orphan PVs.");
 		goto_out;
 	}
 
@@ -4293,7 +4289,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * arg_fail if it cannot be used.  After the second loop, any devices
 	 * remaining on arg_confirm were not found and are not used.
 	 */
-
 	dm_list_splice(&pp->arg_confirm, &pp->arg_process);
 
 	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pv_confirm_single);
@@ -4334,7 +4329,7 @@ do_command:
 	 * Wipe signatures on devices being created.
 	 */
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
-		log_verbose("Wiping signatures on new PV %s", pd->name);
+		log_verbose("Wiping signatures on new PV %s.", pd->name);
 
 		if (!wipe_known_signatures(cmd, pd->dev, pd->name, TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
 					    0, pp->yes, pp->force, &pd->wiped)) {
@@ -4354,10 +4349,10 @@ do_command:
 	 * and not recreate a new PV on top of an existing PV.
 	 */
 	if (pp->preserve_existing && pp->orphan_vg_name) {
-		log_debug("Using existing orphan PVs in %s", pp->orphan_vg_name);
+		log_debug("Using existing orphan PVs in %s.", pp->orphan_vg_name);
 
 		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, &consistent))) {
-			log_error("Cannot read orphans VG %s", pp->orphan_vg_name);
+			log_error("Cannot read orphans VG %s.", pp->orphan_vg_name);
 			goto_bad;
 		}
 
@@ -4366,7 +4361,7 @@ do_command:
 				continue;
 
 			if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
-				log_error("alloc pvl failed");
+				log_error("alloc pvl failed.");
 				dm_list_move(&pp->arg_fail, &pd->list);
 				continue;
 			}
@@ -4380,7 +4375,7 @@ do_command:
 			}
 
 			if (found) {
-				log_debug("Using existing orphan PV %s", pv_dev_name(vgpvl->pv));
+				log_debug("Using existing orphan PV %s.", pv_dev_name(vgpvl->pv));
 				pvl->pv = vgpvl->pv;
 				dm_list_add(&pp->pvs, &pvl->list);
 			} else {
@@ -4404,59 +4399,60 @@ do_command:
 			break;
 
 		if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
-			log_error("alloc pvl failed");
+			log_error("alloc pvl failed.");
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
 		}
 
 		pv_name = pd->name;
 
-		log_debug("Creating a new PV on %s", pv_name);
+		log_debug("Creating a new PV on %s.", pv_name);
 
 		if (!(pv = pv_create(cmd, pd->dev, &pp->pva))) {
-			log_error("Failed to setup physical volume \"%s\"", pv_name);
+			log_error("Failed to setup physical volume \"%s\".", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
 		}
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-			    " available sectors", pv_name, pv_size(pv));
+			    " available sectors.", pv_name, pv_size(pv));
 
 		if (!label_remove(pv->dev)) {
-			log_error("Failed to wipe existing label on %s", pv_name);
+			log_error("Failed to wipe existing label on %s.", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
 		}
 
 		if (pp->zero) {
-			log_verbose("Zeroing start of device %s", pv_name);
+			log_verbose("Zeroing start of device %s.", pv_name);
 
 			if (!dev_open_quiet(pv->dev)) {
-				log_error("%s not opened: device not zeroed", pv_name);
+				log_error("%s not opened: device not zeroed.", pv_name);
 				dm_list_move(&pp->arg_fail, &pd->list);
 				continue;
 			}
 
 			if (!dev_set(pv->dev, UINT64_C(0), (size_t) 2048, 0)) {
-                        	log_error("%s not wiped: aborting", pv_name);
-                        	if (!dev_close(pv->dev))
-                                	stack;
+				log_error("%s not wiped: aborting.", pv_name);
+				if (!dev_close(pv->dev))
+					stack;
 				dm_list_move(&pp->arg_fail, &pd->list);
 				continue;
-                	}
-                	if (!dev_close(pv->dev))
-                        	stack;
+			}
+			if (!dev_close(pv->dev))
+				stack;
 		}
 
-		log_verbose("Writing physical volume data to disk \"%s\"", pv_name);
+		log_verbose("Writing physical volume data to disk \"%s\".", pv_name);
 
 		if (!pv_write(cmd, pv, 0)) {
-			log_error("Failed to write physical volume \"%s\"", pv_name);
+			log_error("Failed to write physical volume \"%s\".", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
 		}
 
-		log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);
+		log_print_unless_silent("Physical volume \"%s\" successfully created.",
+					pv_name);
 
 		pvl->pv = pv;
 		dm_list_add(&pp->pvs, &pvl->list);
@@ -4466,10 +4462,8 @@ do_command:
 	 * Remove PVs from devices for pvremove.
 	 */
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_remove) {
-		struct lvmcache_info *info;
-
 		if (!label_remove(pd->dev)) {
-			log_error("Failed to wipe existing label(s) on %s", pd->name);
+			log_error("Failed to wipe existing label(s) on %s.", pd->name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
 		}
@@ -4479,17 +4473,18 @@ do_command:
 			lvmcache_del(info);
 
 		if (!lvmetad_pv_gone_by_dev(pd->dev, NULL)) {
-			log_error("Failed to remove PV %s from lvmetad", pd->name);
+			log_error("Failed to remove PV %s from lvmetad.", pd->name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
 		}
 
-		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
+		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
 					pd->name);
 	}
 
 	dm_list_iterate_items(pd, &pp->arg_fail)
-		log_debug("pv command failed for %s", pd->name);
+		log_debug("%s: command failed for %s.",
+			  cmd->command->name, pd->name);
 
 	if (!dm_list_empty(&pp->arg_fail))
 		goto_bad;


