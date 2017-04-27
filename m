From: David Teigland <teigland@sourceware.org>
Date: Thu, 27 Apr 2017 14:26:00 -0400
Subject: master - pvcreate: add prompt when setting dev size
Message-ID: <201704271826.v3RIQ0pw007561@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4f9ff14508084789c731e99d8921c052da694319
Commit:        4f9ff14508084789c731e99d8921c052da694319
Parent:        5cf51fb2f74ad43a2555bc391cf069caa1d99775
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 27 12:13:09 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 27 13:25:41 2017 -0500

pvcreate: add prompt when setting dev size

If the device size does not match the size requested
by --setphysicalvolumesize, then prompt the user.

Make the pvcreate checking/prompting code handle
multiple prompts for the same device, since the
new prompt can be in addition to the existing
prompt when the PV is in a VG.
---
 test/shell/pv-check-dev-size.sh |    4 +-
 test/shell/snapshot-usage.sh    |    2 +-
 tools/args.h                    |    2 +-
 tools/pvcreate.c                |    4 +-
 tools/pvresize.c                |    4 +-
 tools/toollib.c                 |  133 +++++++++++++++++++++++++++++++--------
 6 files changed, 115 insertions(+), 34 deletions(-)

diff --git a/test/shell/pv-check-dev-size.sh b/test/shell/pv-check-dev-size.sh
index d3d1b53..76618ad 100644
--- a/test/shell/pv-check-dev-size.sh
+++ b/test/shell/pv-check-dev-size.sh
@@ -27,7 +27,7 @@ not grep "$CHECK_MSG" err
 vgremove -ff $vg
 
 # set PV size to 2x dev size
-pvcreate --setphysicalvolumesize 16m $dev1
+pvcreate --yes --setphysicalvolumesize 16m $dev1
 vgcreate $vg $dev1 2>err
 grep "$CHECK_MSG" err
 pvs 2>err
@@ -36,7 +36,7 @@ vgremove -ff $vg
 
 # should be quiet if requested
 aux lvmconf 'metadata/check_pv_device_sizes = 0'
-pvcreate --setphysicalvolumesize 16m $dev1
+pvcreate --yes --setphysicalvolumesize 16m $dev1
 vgcreate $vg $dev1 2>err
 not grep "$CHECK_MSG" err
 pvs 2>err
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index a780664..a751f1a 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -78,7 +78,7 @@ aux lvmconf "activation/snapshot_autoextend_percent = 20" \
             "activation/snapshot_autoextend_threshold = 50"
 
 # Check usability with smallest (1k) extent size ($lv has 15P)
-pvcreate --setphysicalvolumesize 4T "$DM_DEV_DIR/$vg/$lv"
+pvcreate --yes --setphysicalvolumesize 4T "$DM_DEV_DIR/$vg/$lv"
 trap 'cleanup_tail' EXIT
 vgcreate -s 1K $vg1 "$DM_DEV_DIR/$vg/$lv"
 
diff --git a/tools/args.h b/tools/args.h
index be1711b..87b33e7 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -402,7 +402,7 @@ arg(originname_ARG, '\0', "originname", lv_VAL, 0, 0,
     "to a thin LV. The LV being converted becomes a read-only external origin\n"
     "with this name.\n")
 
-arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0,
+arg(setphysicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0,
     "Overrides the automatically detected size of the PV.\n"
     "Use with care, or prior to reducing the physical size of the device.\n")
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index e69eed4..0fe5ad5 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -52,11 +52,11 @@ static int pvcreate_restore_params_from_args(struct cmd_context *cmd, int argc,
 		pp->pva.idp = &pp->pva.id;
 	}
 
-	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, setphysicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
 		return 0;
 	}
-	pp->pva.size = arg_uint64_value(cmd, physicalvolumesize_ARG, UINT64_C(0));
+	pp->pva.size = arg_uint64_value(cmd, setphysicalvolumesize_ARG, UINT64_C(0));
 
 	if (arg_is_set(cmd, restorefile_ARG) || arg_is_set(cmd, uuidstr_ARG))
 		pp->zero = 0;
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 1de1709..8a65952 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -72,13 +72,13 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
+	if (arg_sign_value(cmd, setphysicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
 		ret = EINVALID_CMD_LINE;
 		goto out;
 	}
 
-	params.new_size = arg_uint64_value(cmd, physicalvolumesize_ARG,
+	params.new_size = arg_uint64_value(cmd, setphysicalvolumesize_ARG,
 					   UINT64_C(0));
 
 	params.done = 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index 838765b..f3cf4ca 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4751,6 +4751,7 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 enum {
 	PROMPT_PVCREATE_PV_IN_VG = 1,
 	PROMPT_PVREMOVE_PV_IN_VG = 2,
+	PROMPT_PVCREATE_DEV_SIZE = 4,
 };
 
 enum {
@@ -4767,6 +4768,8 @@ enum {
 struct pvcreate_prompt {
 	struct dm_list list;
 	uint32_t type;
+	uint64_t size;
+	uint64_t new_size;
 	const char *pv_name;
 	const char *vg_name;
 	struct device *dev;
@@ -4808,12 +4811,14 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 {
 	const char *vgname = prompt->vg_name ? prompt->vg_name : "<unknown>";
 	const char *pvname = prompt->pv_name;
+	int answer_yes = 0;
+	int answer_no = 0;
 
 	/* The VG name can be unknown when the PV is used but metadata is not available */
 
-	if (prompt->type == PROMPT_PVCREATE_PV_IN_VG) {
+	if (prompt->type & PROMPT_PVCREATE_PV_IN_VG) {
 		if (pp->force != DONT_PROMPT_OVERRIDE) {
-			prompt->answer = PROMPT_ANSWER_NO;
+			answer_no = 1;
 
 			if (prompt->vg_name_unknown) {
 				log_error("PV %s is used by a VG but its metadata is missing.", pvname);
@@ -4825,20 +4830,39 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 				log_error("Unable to add physical volume '%s' to volume group '%s'", pvname, vgname);
 			}
 		} else if (pp->yes) {
-			prompt->answer = PROMPT_ANSWER_YES;
+			answer_yes = 1;
 		} else if (ask) {
 			if (yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n') {
-				prompt->answer = PROMPT_ANSWER_NO;
-				log_error("%s: physical volume not initialized", pvname);
+				answer_no = 1;
 			} else {
-				prompt->answer = PROMPT_ANSWER_YES;
+				answer_yes = 1;
 				log_warn("WARNING: Forcing physical volume creation on %s of volume group \"%s\"", pvname, vgname);
 			}
 		}
 
-	} else if (prompt->type == PROMPT_PVREMOVE_PV_IN_VG) {
+	}
+
+	if (prompt->type & PROMPT_PVCREATE_DEV_SIZE) {
+		if (pp->yes) {
+			log_warn("WARNING: Faking size of PV %s. Don't write outside real device.", pvname);
+			answer_yes = 1;
+		} else if (ask) {
+			if (prompt->new_size != prompt->size) {
+				if (yes_no_prompt("WARNING: %s: device size %s does not match requested size %s. Proceed? [y/n]: ", pvname,
+						  display_size(cmd, (uint64_t)prompt->size),
+						  display_size(cmd, (uint64_t)prompt->new_size)) == 'n') {
+					answer_no = 1;
+				} else {
+					answer_yes = 1;
+					log_warn("WARNING: Faking size of PV %s. Don't write outside real device.", pvname);
+				}
+			}
+		}
+	}
+	
+	if (prompt->type & PROMPT_PVREMOVE_PV_IN_VG) {
 		if (pp->force != DONT_PROMPT_OVERRIDE) {
-			prompt->answer = PROMPT_ANSWER_NO;
+			answer_no = 1;
 
 			if (prompt->vg_name_unknown)
 				log_error("PV %s is used by a VG but its metadata is missing.", pvname);
@@ -4847,20 +4871,51 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 			log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
 		} else if (pp->yes) {
 			log_warn("WARNING: PV %s is used by VG %s", pvname, vgname);
-			prompt->answer = PROMPT_ANSWER_YES;
+			answer_yes = 1;
 		} else if (ask) {
 			log_warn("WARNING: PV %s is used by VG %s", pvname, vgname);
-			if (yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n') {
-				prompt->answer = PROMPT_ANSWER_NO;
-				log_error("%s: physical volume label not removed", pvname);
-			} else {
-				prompt->answer = PROMPT_ANSWER_YES;
-			}
+			if (yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n')
+				answer_no = 1;
+			else
+				answer_yes = 1;
 		}
+	}
 
-		if ((prompt->answer == PROMPT_ANSWER_YES) && (pp->force == DONT_PROMPT_OVERRIDE))
-			log_warn("WARNING: Wiping physical volume label from %s of volume group \"%s\"", pvname, vgname);
+	if (answer_yes && answer_no) {
+		log_warn("WARNING: prompt answer yes is overriden by prompt answer no.");
+		answer_yes = 0;
 	}
+
+	/*
+	 * no answer is valid when not asking the user.
+	 * the caller uses this to check if all the prompts
+	 * can be answered automatically without prompts.
+	 */
+	if (!ask && !answer_yes && !answer_no)
+		return;
+
+	if (answer_no)
+		prompt->answer = PROMPT_ANSWER_NO;
+	else if (answer_yes)
+		prompt->answer = PROMPT_ANSWER_YES;
+
+	/*
+	 * Mostly historical messages.  Other messages above could be moved
+	 * here to separate the answer logic from the messages.
+	 */
+
+	if ((prompt->type & (PROMPT_PVCREATE_DEV_SIZE | PROMPT_PVCREATE_PV_IN_VG)) &&
+	    (prompt->answer == PROMPT_ANSWER_NO))
+		log_error("%s: physical volume not initialized.", pvname);
+
+	if ((prompt->type & PROMPT_PVREMOVE_PV_IN_VG) &&
+	    (prompt->answer == PROMPT_ANSWER_NO))
+		log_error("%s: physical volume label not removed.", pvname);
+
+	if ((prompt->type & PROMPT_PVREMOVE_PV_IN_VG) &&
+	    (prompt->answer == PROMPT_ANSWER_YES) &&
+	    (pp->force == DONT_PROMPT_OVERRIDE))
+		log_warn("WARNING: Wiping physical volume label from %s of volume group \"%s\".", pvname, vgname);
 }
 
 static struct pvcreate_device *_pvcreate_list_find_dev(struct dm_list *devices, struct device *dev)
@@ -4912,6 +4967,10 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
+	uint64_t size = 0;
+	uint64_t new_size = 0;
+	int need_size_prompt = 0;
+	int need_vg_prompt = 0;
 	int found = 0;
 
 	if (!pv->dev)
@@ -4996,35 +5055,57 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 		pd->is_not_pv = 1;
 	}
 
+	if (arg_is_set(cmd, setphysicalvolumesize_ARG)) {
+		new_size = arg_uint64_value(cmd, setphysicalvolumesize_ARG, UINT64_C(0));
+
+		if (!dev_get_size(pv->dev, &size)) {
+			log_error("Can't get device size of %s.", pv_dev_name(pv));
+			dm_list_move(&pp->arg_fail, &pd->list);
+			return 1;
+		} else if (new_size != size)
+			need_size_prompt = 1;
+	}
+
 	/*
 	 * pvcreate is being run on this device, and it's not a PV,
 	 * or is an orphan PV.  Neither case requires a prompt.
+	 * Or, pvcreate is being run on this device, but the device
+	 * is already a PV in a VG.  A prompt or force option is required
+	 * to use it.
 	 */
-	if (pd->is_orphan_pv || pd->is_not_pv) {
+	if (pd->is_orphan_pv || pd->is_not_pv)
+		need_vg_prompt = 0;
+	else
+		need_vg_prompt = 1;
+
+	if (!need_size_prompt && !need_vg_prompt) {
 		pd->dev = pv->dev;
 		dm_list_move(&pp->arg_process, &pd->list);
 		return 1;
 	}
 
-	/*
-	 * pvcreate is being run on this device, but the device is already
-	 * a PV in a VG.  A prompt or force option is required to use it.
-	 */
 	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
 		log_error("prompt alloc failed.");
 		pp->check_failed = 1;
 		return 0;
 	}
 	prompt->dev = pd->dev;
-	prompt->type = PROMPT_PVCREATE_PV_IN_VG;
 	prompt->pv_name = dm_pool_strdup(cmd->mem, pd->name);
+	prompt->size = size;
+	prompt->new_size = new_size;
 
 	if (pd->is_used_unknown_pv)
 		prompt->vg_name_unknown = 1;
-	else
+	else if (need_vg_prompt)
 		prompt->vg_name = dm_pool_strdup(cmd->mem, vg->name);
-	dm_list_add(&pp->prompts, &prompt->list);
 
+	if (need_size_prompt)
+		prompt->type |= PROMPT_PVCREATE_DEV_SIZE;
+
+	if (need_vg_prompt)
+		prompt->type |= PROMPT_PVCREATE_PV_IN_VG;
+
+	dm_list_add(&pp->prompts, &prompt->list);
 	pd->dev = pv->dev;
 	dm_list_move(&pp->arg_process, &pd->list);
 
@@ -5254,7 +5335,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 		prompt->vg_name_unknown = 1;
 	else
 		prompt->vg_name = dm_pool_strdup(cmd->mem, vg->name);
-	prompt->type = PROMPT_PVREMOVE_PV_IN_VG;
+	prompt->type |= PROMPT_PVREMOVE_PV_IN_VG;
 	dm_list_add(&pp->prompts, &prompt->list);
 
 	pd->dev = pv->dev;


