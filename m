From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:54 +0200
Subject: [PATCH 20/22] Replicator: lvchange implementation
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <3c1973a45becb43f7b432002b243cb0b5333215a.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/commands.h |    6 ++
 tools/lvchange.c |  195 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 196 insertions(+), 5 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 7966cff..9e27ad9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -80,6 +80,10 @@ xx(lvchange,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[--replicator ReplicatorName]\n"
+   "\t[--site SiteName [--sitemode {sync|warn|stall|drop|fail}]\n"
+   "\t  [{--fallbehinddata Size[bBsSkKmMgG]|\n"
+   "\t    --fallbehindios IOCount|--fallbehindtimeout Secs}]]]\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -91,6 +95,8 @@ xx(lvchange,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
    poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
+   fallbehinddata_ARG, fallbehindios_ARG, fallbehindtimeout_ARG,
+   replicator_ARG, replicatorlogtype_ARG, remotevg_ARG, site_ARG, sitemode_ARG,
    sysinit_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 126e61a..4d43db4 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -15,6 +15,11 @@
 
 #include "tools.h"
 
+/* Internal data storage used for process_each_lv callbacks */
+struct lvchange_data {
+	struct dm_list activate_names;
+};
+
 static int lvchange_permission(struct cmd_context *cmd,
 			       struct logical_volume *lv)
 {
@@ -514,12 +519,156 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 }
 
+static int lvchange_site(struct cmd_context *cmd, struct logical_volume *lv,
+			 int *skip_available)
+{
+	struct lvinfo info;
+	struct replicator_site nrsite;
+	struct logical_volume *replicator;
+	struct replicator_site *rsite;
+	const char *replicator_name, *trname;
+	int active;
+	int changed = 0;
+
+	replicator = (lv_is_replicator(lv)) ? lv : first_seg(lv)->replicator;
+	rsite = find_local_site_in_replicator(replicator);
+
+	if (arg_count(cmd, replicator_ARG)) {
+		if (lv == replicator) {
+			log_error("Replicator specified twice.");
+			return 0;
+		}
+		replicator_name = arg_str_value(cmd, replicator_ARG, "");
+		/* Strip the volume group from the replicator */
+		if ((trname = strrchr(replicator_name, (int)'/')))
+			replicator_name = trname + 1;
+		/* Skip different replicator */
+		if (strcmp(replicator->name, replicator_name)) {
+			log_debug("Replicator %s/%s name does not match %s.",
+				  replicator->name, lv->name, replicator_name);
+			return 2;
+		}
+	}
+
+	if (arg_count(cmd, site_ARG)) {
+		nrsite.name = arg_str_value(cmd, site_ARG,
+					    DEFAULT_REPLICATOR_LOCAL_SITE_NAME);
+
+		/* Skip different replicator */
+		if (!(rsite = find_site_in_replicator(replicator, nrsite.name))) {
+			log_debug("Replicator %s/%s does not have site %s.",
+				  replicator->name, lv->name, nrsite.name);
+			return 2;
+		}
+	}
+
+	if (arg_count(cmd, remotevg_ARG)) {
+		log_error("Cannot change remotevg.");
+		return 0;
+	}
+
+	if (arg_count(cmd, replicatorlogtype_ARG)) {
+		log_error("Cannot change replicator log type.");
+		return 0;
+	}
+
+	memset(&nrsite, 0, sizeof(nrsite));
+	nrsite.state = NUM_REPLICATOR_STATE; /* invalid state */
+	if (arg_count(cmd, available_ARG)) {
+		if (rsite->site_index != 0) {
+			log_error("Cannot change state of remote site %s/%s.",
+				  replicator->name, rsite->name);
+			return 0;
+		}
+		switch (arg_uint_value(cmd, available_ARG, 0)) {
+		case CHANGE_ALY:
+		case CHANGE_AE:
+		case CHANGE_AY:
+			nrsite.state = REPLICATOR_STATE_ACTIVE;
+			break;
+		default:
+			nrsite.state = REPLICATOR_STATE_PASSIVE;
+		}
+
+		if (rsite->state != nrsite.state) {
+			rsite->state = nrsite.state;
+			changed++;
+		}
+	}
+
+	if (!get_replicator_site_params(cmd, rsite, &changed))
+		return_0;
+
+	if (!changed)
+		return 2;
+
+	/* Replicator heads needs to be updated */
+	if (lv == replicator)
+		lv = first_replicator_dev(replicator);
+
+	active = (lv_info(cmd, lv, &info, 0, 0) && info.exists);
+
+	if (active && !arg_count(cmd, force_ARG) &&
+	    yes_no_prompt("Replicator LVs %s will be deactivated. "
+			  "Continue? [y/n]: ",
+			  replicator->name) == 'n') {
+		log_error("%s site not changed.", rsite->name);
+		return 0;
+	}
+
+	if (active) {
+		/* FIXME: some cases may require synchronization of data from log */
+		if (arg_count(cmd, available_ARG) &&
+		    (nrsite.state == REPLICATOR_STATE_PASSIVE)) {
+			if (!lvchange_availability(cmd, lv))
+				return_0;
+			*skip_available = 1; /* skip later change of available */
+		} else if (!deactivate_lv(cmd, lv)) {
+			log_error("Unable to deactivate replicator %s.",
+				  replicator->name);
+			return 0;
+		}
+	}
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	backup(lv->vg);
+
+	if (active && !arg_count(cmd, available_ARG) &&
+	    !activate_lv(cmd, lv)) {
+		log_debug("Retry to activate replicator %s.",
+			  replicator->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   void *handle __attribute((unused)))
+			   void *handle)
 {
 	int doit = 0, docmds = 0;
 	int dmeventd_mode, archived = 0;
 	struct logical_volume *origin;
+	struct lvchange_data *lvc_data = handle;
+	int skip_available = 0;
+
+	struct str_list *sl;
+	dm_list_iterate_items(sl, &lvc_data->activate_names)
+		log_error("LIST %s  %p", sl->str, sl->str);
+
+	if (str_list_match_item(&lvc_data->activate_names, lv->name)) {
+		if (lv_is_replicator(lv))
+			lv = first_replicator_dev(lv);
+
+		if (!activate_lv(cmd, lv)) {
+			log_error("Reactivation of replicator %s failed.",
+				  lv->rdevice->rsite->replicator->name);
+			return ECMD_FAILED;
+		}
+		return ECMD_PROCESSED;
+	}
 
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
@@ -569,7 +718,8 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    lv_is_virtual_origin(origin = origin_from_cow(lv)))
 		lv = origin;
 
-	if (!(lv_is_visible(lv)) && !lv_is_virtual_origin(lv)) {
+	if (!lv_is_visible(lv) && !lv_is_virtual_origin(lv) &&
+	    !lv_is_replicator(lv)) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
@@ -663,6 +813,21 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+        /* Update replicator paramaters */
+	if ((lv_is_replicator(lv) || lv_is_replicator_dev(lv)) &&
+	    (arg_count(cmd, site_ARG) || arg_count(cmd, replicator_ARG))) {
+		if (!archived && !archive(lv->vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+		archived = 1;
+		switch (lvchange_site(cmd, lv, &skip_available)) {
+		case 0: docmds++; break;
+		case 1: docmds++; doit++; break;
+		default: /* 2 = ok, but nothing changed */;
+		}
+	}
+
 	if (doit)
 		log_print("Logical volume \"%s\" changed", lv->name);
 
@@ -673,7 +838,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 
 	/* availability change */
-	if (arg_count(cmd, available_ARG)) {
+	if (!skip_available && arg_count(cmd, available_ARG)) {
 		if (!lvchange_availability(cmd, lv)) {
 			stack;
 			return ECMD_FAILED;
@@ -705,7 +870,18 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (doit != docmds) {
-		stack;
+		if (lv->vg->cmd_missing_vgs) {
+			if (!str_list_add(lv->vg->cmd->mem,
+					  &lvc_data->activate_names,
+					  lv->name)) {
+				log_error("Allocation of lv name failed.");
+				lv->vg->cmd_missing_vgs = 0;
+			}
+		} else
+			stack;
+		/* Note: using cmd mempool to live across vg lifetime */
+		/* return ECMD_FAILED for reprocessing */
+
 		return ECMD_FAILED;
 	}
 
@@ -718,8 +894,16 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
+		arg_count(cmd, replicator_ARG) || arg_count(cmd, site_ARG) ||
+		arg_count(cmd, remotevg_ARG) || arg_count(cmd, replicatorlogtype_ARG) ||
+		arg_count(cmd, fallbehinddata_ARG) || arg_count(cmd, fallbehindios_ARG) ||
+		arg_count(cmd, fallbehindtimeout_ARG) || arg_count(cmd, sitemode_ARG) ||
 		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG);
 
+	struct lvchange_data lvc_data;
+
+	dm_list_init(&lvc_data.activate_names);
+
 	if (!update &&
             !arg_count(cmd, available_ARG) && !arg_count(cmd, refresh_ARG) &&
             !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG) &&
@@ -767,7 +951,8 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	log_error("LVCHANGE DATA  %d ", argc);
 	return process_each_lv(cmd, argc, argv,
-			       update ? READ_FOR_UPDATE : 0, NULL,
+			       update ? READ_FOR_UPDATE : 0, &lvc_data,
 			       &lvchange_single);
 }
-- 
1.7.1.1


