From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:50 +0000 (UTC)
Subject: master - pvremove: use common toollib processing code
Message-ID: <20160225151550.55DB861057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04d34da706a596b7c1d7c5376fb42aa99374fc51
Commit:        04d34da706a596b7c1d7c5376fb42aa99374fc51
Parent:        30c69b3f8ac6c2a4c8b1a47b1482ac4b6a7b8d2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 15:00:50 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

pvremove: use common toollib processing code

Use the new pvcreate_each_device() function from
toollib.
---
 lib/metadata/metadata-exported.h |    2 +
 tools/commands.h                 |    2 +-
 tools/pvremove.c                 |   48 +++++--
 tools/toollib.c                  |  282 ++++++++++++++++++++++++++++++++------
 4 files changed, 276 insertions(+), 58 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 008aef2..9c6abd7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -591,9 +591,11 @@ struct pvcreate_each_params {
 	struct dm_list arg_process;     /* pvcreate_device, used for processing */
 	struct dm_list arg_confirm;     /* pvcreate_device, used for processing */
 	struct dm_list arg_create;      /* pvcreate_device, used for pvcreate */
+	struct dm_list arg_remove;      /* pvcreate_device, used for pvremove */
 	struct dm_list arg_fail;        /* pvcreate_device, failed to create */
 	struct dm_list pvs;             /* pv_list, created and usable for vgcreate/vgextend */
 	const char *orphan_vg_name;
+	unsigned is_remove : 1;         /* is removing PVs, not creating */
 	unsigned preserve_existing : 1;
 	unsigned check_failed : 1;
 };
diff --git a/tools/commands.h b/tools/commands.h
index fcd2c24..25784bf 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -911,7 +911,7 @@ xx(lvpoll,
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
-   0,
+   ENABLE_ALL_DEVS,
    "pvremove\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 1d42c6e..1628ecc 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -17,33 +17,51 @@
 
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
-	int i;
-	unsigned force_count;
-	unsigned prompt;
-	struct dm_list pv_names;
+	struct processing_handle *handle;
+	struct pvcreate_each_params pp;
+	int ret;
 
 	if (!argc) {
 		log_error("Please enter a physical volume path");
 		return EINVALID_CMD_LINE;
 	}
 
-	force_count = arg_count(cmd, force_ARG);
-	prompt = arg_count(cmd, yes_ARG);
+	pvcreate_each_params_set_defaults(&pp);
 
-	dm_list_init(&pv_names);
+	pp.is_remove = 1;
+	pp.force = arg_count(cmd, force_ARG);
+	pp.yes = arg_count(cmd, yes_ARG);
+	pp.pv_count = argc;
+	pp.pv_names = argv;
 
-	/* Needed to change the set of orphan PVs. */
+	/*
+	 * Needed to change the set of orphan PVs.
+	 * (disable afterward to prevent process_each_pv from doing
+	 * a shared global lock since it's already acquired it ex.)
+	 */
 	if (!lockd_gl(cmd, "ex", 0))
 		return_ECMD_FAILED;
+	cmd->lockd_gl_disable = 1;
 
-	for (i = 0; i < argc; i++) {
-		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		if (!str_list_add(cmd->mem, &pv_names, argv[i]))
-			return_ECMD_FAILED;
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
 	}
 
-	if (!pvremove_many(cmd, &pv_names, force_count, prompt))
-		return_ECMD_FAILED;
+	/*
+	 * pvremove uses the same toollib function as pvcreate,
+	 * but sets "is_remove" which changes the check function,
+	 * and the actual create vs remove step.
+	 */
+
+	if (!pvcreate_each_device(cmd, handle, &pp))
+		ret = ECMD_FAILED;
+	else {
+		/* pvcreate_each_device returns with orphans locked */
+		unlock_vg(cmd, VG_ORPHANS);
+		ret = ECMD_PROCESSED;
+	}
 
-	return ECMD_PROCESSED;
+	destroy_processing_handle(cmd, handle);
+	return ret;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index ec0335d..dc025e4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3452,6 +3452,7 @@ void pvcreate_each_params_set_defaults(struct pvcreate_each_params *pp)
 	dm_list_init(&pp->arg_process);
 	dm_list_init(&pp->arg_confirm);
 	dm_list_init(&pp->arg_create);
+	dm_list_init(&pp->arg_remove);
 	dm_list_init(&pp->arg_fail);
 	dm_list_init(&pp->pvs);
 }
@@ -3566,6 +3567,7 @@ int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each
 
 enum {
 	PROMPT_PVCREATE_PV_IN_VG = 1,
+	PROMPT_PVREMOVE_PV_IN_VG = 2,
 };
 
 enum {
@@ -3603,45 +3605,78 @@ struct pvcreate_device {
 	unsigned is_used_unknown_pv : 1; /* device is a PV used in an unknown VG */
 };
 
+/*
+ * If a PV is in a VG, and pvcreate or pvremove is run on it:
+ *
+ * pvcreate|pvremove -f      : fails
+ * pvcreate|pvremove -y      : fails
+ * pvcreate|pvremove -f -y   : fails
+ * pvcreate|pvremove -ff     : get y/n prompt
+ * pvcreate|pvremove -ff -y  : succeeds
+ *
+ * FIXME: there are a lot of various phrasings used depending on the
+ * command and specific case.  Find some similar way to phrase these.
+ */
+
 static void _check_pvcreate_prompt(struct cmd_context *cmd,
 				   struct pvcreate_each_params *pp,
 				   struct pvcreate_prompt *prompt,
 				   int ask)
 {
+	const char *vgname = prompt->vg_name ? prompt->vg_name : "<unknown>";
+	const char *pvname = prompt->pv_name;
+
+	/* The VG name can be unknown when the PV is used but metadata is not available */
+
 	if (prompt->type == PROMPT_PVCREATE_PV_IN_VG) {
 		if (pp->force != DONT_PROMPT_OVERRIDE) {
 			prompt->answer = PROMPT_ANSWER_NO;
 
-			/* FIXME: use similar error messages for these cases */
-
 			if (prompt->vg_name_unknown) {
-				log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.",
-					  prompt->pv_name);
-				log_error("Can't initialize PV '%s' without -ff.", prompt->pv_name);
+				log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.", pvname);
+				log_error("Can't initialize PV '%s' without -ff.", pvname);
 			} else if (!strcmp(command_name(cmd), "pvcreate")) {
-				log_error("Can't initialize physical volume \"%s\" of volume group \"%s\" without -ff",
-					  prompt->pv_name, prompt->vg_name);
+				log_error("Can't initialize physical volume \"%s\" of volume group \"%s\" without -ff", pvname, vgname);
 			} else {
-				log_error("Physical volume '%s' is already in volume group '%s'",
-					  prompt->pv_name, prompt->vg_name);
-				log_error("Unable to add physical volume '%s' to volume group '%s'",
-					  prompt->pv_name, prompt->vg_name);
+				log_error("Physical volume '%s' is already in volume group '%s'", pvname, vgname);
+				log_error("Unable to add physical volume '%s' to volume group '%s'", pvname, vgname);
 			}
 		} else if (pp->yes) {
 			prompt->answer = PROMPT_ANSWER_YES;
 		} else if (ask) {
-			const char *vgname = prompt->vg_name ? prompt->vg_name : "<unknown>";
+			if (yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n') {
+				prompt->answer = PROMPT_ANSWER_NO;
+				log_error("%s: physical volume not initialized", pvname);
+			} else {
+				prompt->answer = PROMPT_ANSWER_YES;
+				log_warn("WARNING: Forcing physical volume creation on %s of volume group \"%s\"", pvname, vgname);
+			}
+		}
 
-			if (yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ",
-					  prompt->pv_name, vgname) == 'n') {
+	} else if (prompt->type == PROMPT_PVREMOVE_PV_IN_VG) {
+		if (pp->force != DONT_PROMPT_OVERRIDE) {
+			prompt->answer = PROMPT_ANSWER_NO;
+
+			if (prompt->vg_name_unknown)
+				log_error("PV %s belongs to a VG but its metadata is missing.", pvname);
+			else
+				log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", pvname, vgname);
+			log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
+		} else if (pp->yes) {
+			log_warn("WARNING: PV %s belongs to Volume Group %s", pvname, vgname);
+			prompt->answer = PROMPT_ANSWER_YES;
+		} else if (ask) {
+			log_warn("WARNING: PV %s belongs to Volume Group %s", pvname, vgname);
+			if (yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n') {
 				prompt->answer = PROMPT_ANSWER_NO;
-				log_error("%s: physical volume not initialized", prompt->pv_name);
+				log_error("%s: physical volume label not removed", pvname);
 			} else {
 				prompt->answer = PROMPT_ANSWER_YES;
-				log_warn("WARNING: Forcing physical volume creation on %s of volume group \"%s\"",
-					 prompt->pv_name, vgname);
 			}
 		}
+
+		if ((prompt->answer == PROMPT_ANSWER_YES) && (pp->force == DONT_PROMPT_OVERRIDE))
+			log_warn("WARNING: Wiping physical volume label from %s of volume group \"%s\"", pvname, vgname);
 	}
 }
 
@@ -3687,10 +3722,10 @@ static struct pvcreate_device *_pvcreate_list_find_name(struct dm_list *devices,
  * and the arg will be reported as not found.
  */
 
-static int _pvcreate_check1_single(struct cmd_context *cmd,
-				   struct volume_group *vg,
-				   struct physical_volume *pv,
-				   struct processing_handle *handle)
+static int _pvcreate_check_single(struct cmd_context *cmd,
+				  struct volume_group *vg,
+				  struct physical_volume *pv,
+				  struct processing_handle *handle)
 {
 	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
@@ -3830,10 +3865,10 @@ static int _pvcreate_check1_single(struct cmd_context *cmd,
  * prompts, then it will not be found during this check.
  */
 
-static int _pvcreate_check2_single(struct cmd_context *cmd,
-				   struct volume_group *vg,
-				   struct physical_volume *pv,
-				   struct processing_handle *handle)
+static int _pv_confirm_single(struct cmd_context *cmd,
+			      struct volume_group *vg,
+			      struct physical_volume *pv,
+			      struct processing_handle *handle)
 {
 	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
@@ -3849,7 +3884,7 @@ static int _pvcreate_check2_single(struct cmd_context *cmd,
 	if (!found)
 		return 1;
 
-	/* Repeat the same from check1. */
+	/* Repeat the same from check_single. */
 	if (!dev_test_excl(pv->dev)) {
 		/* FIXME Detect whether device-mapper itself is still using it */
 		log_error("Can't open %s exclusively.  Mounted filesystem?",
@@ -3866,12 +3901,12 @@ static int _pvcreate_check2_single(struct cmd_context *cmd,
 		/* Device is a PV used in a VG. */
 
 		if (pd->is_orphan_pv || pd->is_not_pv || pd->is_used_unknown_pv) {
-			/* In check1 it was an orphan or unused. */
+			/* In check_single it was an orphan or unused. */
 			goto fail;
 		}
 
 		if (pd->is_vg_pv && pd->vg_name && strcmp(pd->vg_name, vg->name)) {
-			/* In check1 it was in a different VG. */
+			/* In check_single it was in a different VG. */
 			goto fail;
 		}
 
@@ -3879,17 +3914,17 @@ static int _pvcreate_check2_single(struct cmd_context *cmd,
 		/* Device is an orphan PV. */
 
 		if (pd->is_not_pv) {
-			/* In check1 it was not a PV. */
+			/* In check_single it was not a PV. */
 			goto fail;
 		}
 
 		if (pd->is_vg_pv) {
-			/* In check1 it was in a VG. */
+			/* In check_single it was in a VG. */
 			goto fail;
 		}
 
 		if (is_used_pv(pv) != pd->is_used_unknown_pv) {
-			/* In check1 it was different. */
+			/* In check_single it was different. */
 			goto fail;
 		}
 
@@ -3897,26 +3932,162 @@ static int _pvcreate_check2_single(struct cmd_context *cmd,
 		/* Device is not a PV. */
 
 		if (pd->is_orphan_pv || pd->is_used_unknown_pv) {
-			/* In check1 it was an orphan PV. */
+			/* In check_single it was an orphan PV. */
 			goto fail;
 		}
 
 		if (pd->is_vg_pv) {
-			/* In check1 it was in a VG. */
+			/* In check_single it was in a VG. */
 			goto fail;
 		}
 	}
 
-	/* Device is unchanged from check1. */
+	/* Device is unchanged from check_single. */
 	dm_list_move(&pp->arg_process, &pd->list);
 	return 1;
 
 fail:
-	log_error("Cannot use device %s: it changed during create.", pd->name);
+	log_error("Cannot use device %s: it changed during prompt.", pd->name);
 	dm_list_move(&pp->arg_fail, &pd->list);
 	return 1;
 }
 
+static int _pvremove_check_single(struct cmd_context *cmd,
+				  struct volume_group *vg,
+				  struct physical_volume *pv,
+				  struct processing_handle *handle)
+{
+	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
+	struct pvcreate_device *pd;
+	struct pvcreate_prompt *prompt;
+	struct label *label;
+	struct device *dev;
+	int found = 0;
+
+	if (!pv->dev)
+		return 1;
+
+	/*
+	 * Check if one of the command args in arg_devices
+	 * matches this device.
+	 */
+	dm_list_iterate_items(pd, &pp->arg_devices) {
+		dev = dev_cache_get(pd->name, cmd->full_filter);
+		if (dev != pv->dev)
+			continue;
+
+		pd->dev = pv->dev;
+		if (pv->dev->pvid[0])
+			strncpy(pd->pvid, pv->dev->pvid, ID_LEN);
+		found = 1;
+		break;
+	}
+
+	if (!found)
+		return 1;
+
+	log_debug("Checking device %s for pvremove %.32s",
+		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
+
+	/*
+	 * This test will fail if the device belongs to an MD array.
+	 */
+	if (!dev_test_excl(pv->dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
+			  pv_dev_name(pv));
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return 1;
+	}
+
+	/*
+	 * Is there a pv here already?
+	 * If not, this is an error unless you used -f.
+	 */
+	if (!label_read(pd->dev, &label, 0)) {
+		if (pp->force) {
+			dm_list_move(&pp->arg_process, &pd->list);
+			return 1;
+		} else {
+			log_error("No PV label found on %s.", pd->name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			return 1;
+		}
+	}
+
+	/*
+	 * What kind of device is this: an orphan PV, an uninitialized/unused
+	 * device, a PV used in a VG.
+	 */
+
+	if (vg && !is_orphan_vg(vg->name)) {
+		/* Device is a PV used in a VG. */
+		log_debug("Found pvremove arg %s: pv is used in %s", pd->name, vg->name);
+		pd->is_vg_pv = 1;
+		pd->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+
+	} else if (vg && is_orphan_vg(vg->name)) {
+		if (is_used_pv(pv)) {
+			/* Device is used in an unknown VG. */
+			log_debug("Found pvremove arg %s: pv is used in unknown VG", pd->name);
+			pd->is_used_unknown_pv = 1;
+		} else {
+			/* Device is an orphan PV. */
+			log_debug("Found pvremove arg %s: pv is orphan in %s", pd->name, vg->name);
+			pd->is_orphan_pv = 1;
+		}
+
+		if (!strcmp(vg->name, FMT_LVM1_ORPHAN_VG_NAME))
+			pp->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
+		else
+			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
+	} else {
+		log_debug("Found pvremove arg %s: device is not a pv", pd->name);
+		/* Device is not a PV. */
+		pd->is_not_pv = 1;
+	}
+
+	if (pd->is_not_pv) {
+		pd->dev = pv->dev;
+		log_error("No PV found on device %s", pd->name);
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return 1;
+	}
+
+	/*
+	 * pvremove is being run on this device, and it's not a PV,
+	 * or is an orphan PV.  Neither case requires a prompt.
+	 */
+	if (pd->is_orphan_pv) {
+		pd->dev = pv->dev;
+		dm_list_move(&pp->arg_process, &pd->list);
+		return 1;
+	}
+
+	/*
+	 * pvremove is being run on this device, but the device is in a VG.
+	 * A prompt or force option is required to use it.
+	 */
+
+	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
+		log_error("prompt alloc failed");
+		pp->check_failed = 1;
+		return 0;
+	}
+	prompt->dev = pd->dev;
+	prompt->pv_name = dm_pool_strdup(cmd->mem, pd->name);
+	if (pd->is_used_unknown_pv)
+		prompt->vg_name_unknown = 1;
+	else
+		prompt->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+	prompt->type = PROMPT_PVREMOVE_PV_IN_VG;
+	dm_list_add(&pp->prompts, &prompt->list);
+
+	pd->dev = pv->dev;
+	dm_list_move(&pp->arg_process, &pd->list);
+	return 1;
+}
+
 /*
  * This can be used by pvcreate, vgcreate and vgextend to create PVs.  The
  * callers need to set up the pvcreate_each_params structure based on command
@@ -4026,7 +4197,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * If it's added to arg_process but needs a prompt or force option, then
 	 * a corresponding prompt entry is added to pp->prompts.
 	 */
-	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pvcreate_check1_single);
+	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle,
+			pp->is_remove ? _pvremove_check_single : _pvcreate_check_single);
 
 	/*
 	 * A fatal error was found while checking.
@@ -4056,7 +4228,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * The command cannot continue if there are no devices to create.
 	 */
 	if (dm_list_empty(&pp->arg_process)) {
-		log_error("No devices found.");
+		log_debug("No devices to process.");
 		goto_bad;
 	}
 
@@ -4157,7 +4329,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	dm_list_splice(&pp->arg_confirm, &pp->arg_process);
 
-	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pvcreate_check2_single);
+	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pv_confirm_single);
 
 	dm_list_iterate_items(pd, &pp->arg_confirm)
 		log_error("Device %s not found (or ignored by filtering).", pd->name);
@@ -4171,7 +4343,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		goto_bad;
 
 	if (dm_list_empty(&pp->arg_process)) {
-		log_error("No devices found.");
+		log_debug("No devices to process.");
 		goto_bad;
 	}
 
@@ -4186,7 +4358,10 @@ do_command:
 			dm_list_move(&pp->arg_process, &pd->list);
 	}
 
-	dm_list_splice(&pp->arg_create, &pp->arg_process);
+	if (pp->is_remove)
+		dm_list_splice(&pp->arg_remove, &pp->arg_process);
+	else
+		dm_list_splice(&pp->arg_create, &pp->arg_process);
 
 	/*
 	 * Wipe signatures on devices being created.
@@ -4334,8 +4509,31 @@ do_command:
 		dm_list_add(&pp->pvs, &pvl->list);
 	}
 
-	dm_list_iterate_items(pvl, &pp->pvs)
-		log_debug("pv command succeeded for %s", pv_dev_name(pvl->pv));
+	/*
+	 * Remove PVs from devices for pvremove.
+	 */
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_remove) {
+		struct lvmcache_info *info;
+
+		if (!label_remove(pd->dev)) {
+			log_error("Failed to wipe existing label(s) on %s", pd->name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		info = lvmcache_info_from_pvid(pd->pvid, 0);
+		if (info)
+			lvmcache_del(info);
+
+		if (!lvmetad_pv_gone_by_dev(pd->dev, NULL)) {
+			log_error("Failed to remove PV %s from lvmetad", pd->name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
+					pd->name);
+	}
 
 	dm_list_iterate_items(pd, &pp->arg_fail)
 		log_debug("pv command failed for %s", pd->name);


