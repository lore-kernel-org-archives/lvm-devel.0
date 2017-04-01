From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 31 Mar 2017 20:59:54 -0400
Subject: master - lvchange: avoid multiple metadata updates/reloads/backups
Message-ID: <201704010059.v310xsX8008126@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25b5915c9b5260c59d627bd1f6db8220bd4ad61e
Commit:        25b5915c9b5260c59d627bd1f6db8220bd4ad61e
Parent:        fb1f38a6f677c0127807e6ee403af21c6d6e25da
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Apr 1 02:38:48 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Apr 1 02:38:48 2017 +0200

lvchange: avoid multiple metadata updates/reloads/backups

_lvchange_properties_single() processes multiple command
line arguments in a loop causing metadata updates and/or
backups per argument.

Optimize to only perform one update and/or backup
(but necessary interim ones; e.g. for --resync)
per command run.

Related: rhbz1437611
---
 tools/lvchange.c |  193 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 120 insertions(+), 73 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 7239f18..27b5184 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,8 +17,35 @@
 
 #include "memlock.h"
 
+/*
+ * Passed back from callee to request caller to
+ * commit / update and reload / backup metadata.
+ *
+ * This allows for one metadata update per command run
+ * (unless mandatory interim ones in callee).
+ */
+enum metadata_request {
+	MR_COMMIT	 = 0x1,
+	MR_UPDATE_RELOAD = 0x2,
+	MR_BACKUP	 = 0x4
+};
+
+static int _vg_write_commit(const struct logical_volume *lv, const char *what)
+{
+	log_very_verbose("Updating %slogical volume %s on disk(s).",
+			 what ? : "", display_lvname(lv));
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+		log_error("Failed to update %smetadata of %s on disk.",
+			  what ? : "", display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _lvchange_permission(struct cmd_context *cmd,
-				struct logical_volume *lv)
+				struct logical_volume *lv,
+				enum metadata_request *mr)
 {
 	uint32_t lv_access;
 	struct lvinfo info;
@@ -67,14 +94,15 @@ static int _lvchange_permission(struct cmd_context *cmd,
 			    display_lvname(lv));
 	}
 
-	if (!lv_update_and_reload(lv))
-		return_0;
+	/* Request caller to update and reload metadata */
+	*mr |= MR_UPDATE_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_pool_update(struct cmd_context *cmd,
-				 struct logical_volume *lv)
+				 struct logical_volume *lv,
+				 enum metadata_request *mr)
 {
 	int update = 0;
 	unsigned val;
@@ -110,9 +138,7 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	if (!update)
 		return 0;
 
-	if (!lv_update_and_reload(lv))
-		return_0;
-
+	*mr |= MR_UPDATE_RELOAD;
 	return 1;
 }
 
@@ -345,12 +371,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	if (!seg_is_raid(seg) && !seg->log_lv) {
 		if (lv_is_not_synced(lv)) {
 			lv->status &= ~LV_NOTSYNCED;
-			log_very_verbose("Updating logical volume %s on disk(s).",
-					 display_lvname(lv));
-			if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
-				log_error("Failed to update metadata on disk.");
+			if (!_vg_write_commit(lv, NULL))
 				return 0;
-			}
 		}
 
 		if (!_reactivate_lv(lv, active, exclusive)) {
@@ -375,8 +397,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
-		log_error("Failed to update intermediate VG metadata on disk.");
+	if (!_vg_write_commit(lv, "intermediate")) {
 		if (!_reactivate_lv(lv, active, exclusive))
 			stack;
 		return 0;
@@ -426,11 +447,8 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
-		log_error("Failed to update metadata on disk for %s.",
-			  display_lvname(lv));
+	if (!_vg_write_commit(lv, NULL))
 		return 0;
-	}
 
 	if (!_reactivate_lv(lv, active, exclusive)) {
 		backup(lv->vg);
@@ -444,7 +462,9 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	return 1;
 }
 
-static int _lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_alloc(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   enum metadata_request *mr)
 {
 	int want_contiguous = arg_int_value(cmd, contiguous_ARG, 0);
 	alloc_policy_t alloc = (alloc_policy_t)
@@ -467,16 +487,16 @@ static int _lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 	log_very_verbose("Updating logical volume %s on disk(s).", display_lvname(lv));
 
 	/* No need to suspend LV for this change */
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-		return_0;
 
-	backup(lv->vg);
+	/* Request caller to commit+backuo metadata */
+	*mr |= (MR_COMMIT | MR_BACKUP);
 
 	return 1;
 }
 
 static int _lvchange_errorwhenfull(struct cmd_context *cmd,
-				   struct logical_volume *lv)
+				   struct logical_volume *lv,
+				   enum metadata_request *mr)
 {
 	unsigned ewf = arg_int_value(cmd, errorwhenfull_ARG, 0);
 
@@ -491,14 +511,15 @@ static int _lvchange_errorwhenfull(struct cmd_context *cmd,
 	else
 		lv->status &= ~LV_ERROR_WHEN_FULL;
 
-	if (!lv_update_and_reload(lv))
-		return_0;
+	/* Request caller to update and reload metadata */
+	*mr |= MR_UPDATE_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_readahead(struct cmd_context *cmd,
-			       struct logical_volume *lv)
+			       struct logical_volume *lv,
+			       enum metadata_request *mr)
 {
 	unsigned read_ahead = 0;
 	unsigned pagesize = (unsigned) lvm_getpagesize() >> SECTOR_SHIFT;
@@ -537,14 +558,15 @@ static int _lvchange_readahead(struct cmd_context *cmd,
 	log_verbose("Setting read ahead to %u for %s.",
 		    read_ahead, display_lvname(lv));
 
-	if (!lv_update_and_reload(lv))
-		return_0;
+	/* Request caller to update and reload metadata */
+	*mr |= MR_UPDATE_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_persistent(struct cmd_context *cmd,
-				struct logical_volume *lv)
+				struct logical_volume *lv,
+				enum metadata_request *mr)
 {
 	enum activation_change activate = CHANGE_AN;
 
@@ -600,11 +622,8 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 			    lv->major, lv->minor, display_lvname(lv));
 	}
 
-	log_very_verbose("Updating logical volume %s on disk(s).",
-			 display_lvname(lv));
-
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-		return_0;
+	if (!_vg_write_commit(lv, NULL))
+		return 0;
 
 	if (activate != CHANGE_AN) {
 		log_verbose("Re-activating logical volume %s.", display_lvname(lv));
@@ -615,12 +634,15 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 		}
 	}
 
-	backup(lv->vg);
+	/* Request caller to backup metadata */
+	*mr |= MR_BACKUP;
 
 	return 1;
 }
 
-static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_cache(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   enum metadata_request *mr)
 {
 	cache_metadata_format_t format;
 	cache_mode_t mode;
@@ -655,8 +677,8 @@ static int _lvchange_cache(struct cmd_context *cmd, struct logical_volume *lv)
 	    !cache_set_policy(first_seg(lv), name, settings))
 		goto_out;
 
-	if (!lv_update_and_reload(lv))
-		goto_out;
+	/* Request caller to update and reload metadata */
+	*mr |= MR_UPDATE_RELOAD;
 
 	r = 1;
 out:
@@ -666,7 +688,8 @@ out:
 	return r;
 }
 
-static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int arg)
+static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
+			 int arg, enum metadata_request *mr)
 {
 	if (!change_tag(cmd, NULL, lv, NULL, arg))
 		return_0;
@@ -674,10 +697,8 @@ static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int
 	log_very_verbose("Updating logical volume %s on disk(s).", display_lvname(lv));
 
 	/* No need to suspend LV for this change */
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-		return_0;
-
-	backup(lv->vg);
+	/* Request caller to commit+backup metadata */
+	*mr |= (MR_COMMIT | MR_BACKUP);
 
 	return 1;
 }
@@ -730,7 +751,8 @@ static int _lvchange_rebuild(struct logical_volume *lv)
 	return lv_raid_rebuild(lv, rebuild_pvh);
 }
 
-static int _lvchange_writemostly(struct logical_volume *lv)
+static int _lvchange_writemostly(struct logical_volume *lv,
+				 enum metadata_request *mr)
 {
 	int pv_count, i = 0;
 	uint32_t s, writemostly;
@@ -847,13 +869,14 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 		}
 	}
 
-	if (!lv_update_and_reload(lv))
-		return_0;
+	/* Request caller to update and reload metadata */
+	*mr |= MR_UPDATE_RELOAD;
 
 	return 1;
 }
 
-static int _lvchange_recovery_rate(struct logical_volume *lv)
+static int _lvchange_recovery_rate(struct logical_volume *lv,
+				   enum metadata_request *mr)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
@@ -871,13 +894,14 @@ static int _lvchange_recovery_rate(struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!lv_update_and_reload(lv))
-		return_0;
+	/* Request caller to update and reload metadata */
+	*mr |= MR_UPDATE_RELOAD;
 
 	return 1;
 }
 
-static int _lvchange_profile(struct logical_volume *lv)
+static int _lvchange_profile(struct logical_volume *lv,
+			     enum metadata_request *mr)
 {
 	const char *old_profile_name, *new_profile_name;
 	struct profile *new_profile;
@@ -900,15 +924,13 @@ static int _lvchange_profile(struct logical_volume *lv)
 	log_verbose("Changing configuration profile for LV %s: %s -> %s.",
 		    display_lvname(lv), old_profile_name, new_profile_name);
 
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-		return_0;
-
-	backup(lv->vg);
+	/* Request caller to commit+backup metadata */
+	*mr |= (MR_COMMIT | MR_BACKUP);
 
 	return 1;
 }
 
-static int _lvchange_activation_skip(struct logical_volume *lv)
+static int _lvchange_activation_skip(struct logical_volume *lv, enum metadata_request *mr)
 {
 	int skip = arg_int_value(lv->vg->cmd, setactivationskip_ARG, 0);
 
@@ -917,10 +939,26 @@ static int _lvchange_activation_skip(struct logical_volume *lv)
 	log_verbose("Changing activation skip flag to %s for LV %s.",
 		    display_lvname(lv), skip ? "enabled" : "disabled");
 
-	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
-		return_0;
+	/* Request caller to commit+backup metadata */
+	*mr |= (MR_COMMIT | MR_BACKUP);
 
-	backup(lv->vg);
+	return 1;
+}
+
+/* Update and reload or commit and/or backup metadata for @lv as requested by @mr */
+static int _commit_update_backup(struct logical_volume *lv,
+				 const enum metadata_request mr)
+{
+	if (mr & MR_UPDATE_RELOAD) {
+		if (!lv_update_and_reload(lv))
+			return_0;
+
+	} else if ((mr & MR_COMMIT) &&
+		   !_vg_write_commit(lv, NULL))
+		return 0;
+
+	if (mr & MR_BACKUP)
+		backup(lv->vg);
 
 	return 1;
 }
@@ -944,6 +982,7 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 {
 	int doit = 0, docmds = 0;
 	int i, opt_enum;
+	enum metadata_request mr = 0;
 
 	/*
 	 * If a persistent lv lock already exists from activation
@@ -962,6 +1001,7 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 		if (!arg_is_set(cmd, opt_enum))
 			continue;
 
+		/* Archive will only happen once per run */
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 
@@ -969,60 +1009,60 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 
 		switch (opt_enum) {
 		case permission_ARG:
-			doit += _lvchange_permission(cmd, lv);
+			doit += _lvchange_permission(cmd, lv, &mr);
 			break;
 
 		case alloc_ARG:
 		case contiguous_ARG:
-			doit += _lvchange_alloc(cmd, lv);
+			doit += _lvchange_alloc(cmd, lv, &mr);
 			break;
 
 		case errorwhenfull_ARG:
-			doit += _lvchange_errorwhenfull(cmd, lv);
+			doit += _lvchange_errorwhenfull(cmd, lv, &mr);
 			break;
 
 		case readahead_ARG:
-			doit += _lvchange_readahead(cmd, lv);
+			doit += _lvchange_readahead(cmd, lv, &mr);
 			break;
 
 		case persistent_ARG:
-			doit += _lvchange_persistent(cmd, lv);
+			doit += _lvchange_persistent(cmd, lv, &mr);
 			break;
 
 		case discards_ARG:
 		case zero_ARG:
-			doit += _lvchange_pool_update(cmd, lv);
+			doit += _lvchange_pool_update(cmd, lv, &mr);
 			break;
 
 		case addtag_ARG:
 		case deltag_ARG:
-			doit += _lvchange_tag(cmd, lv, opt_enum);
+			doit += _lvchange_tag(cmd, lv, opt_enum, &mr);
 			break;
 
 		case writemostly_ARG:
 		case writebehind_ARG:
-			doit += _lvchange_writemostly(lv);
+			doit += _lvchange_writemostly(lv, &mr);
 			break;
 
 		case minrecoveryrate_ARG:
 		case maxrecoveryrate_ARG:
-			doit += _lvchange_recovery_rate(lv);
+			doit += _lvchange_recovery_rate(lv, &mr);
 			break;
 
 		case profile_ARG:
 		case metadataprofile_ARG:
 		case detachprofile_ARG:
-			doit += _lvchange_profile(lv);
+			doit += _lvchange_profile(lv, &mr);
 			break;
 
 		case setactivationskip_ARG:
-			doit += _lvchange_activation_skip(lv);
+			doit += _lvchange_activation_skip(lv, &mr);
 			break;
 
 		case cachemode_ARG:
 		case cachepolicy_ARG:
 		case cachesettings_ARG:
-			doit += _lvchange_cache(cmd, lv);
+			doit += _lvchange_cache(cmd, lv, &mr);
 			break;
 
 		default:
@@ -1037,6 +1077,9 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 	if (doit != docmds)
 		return_ECMD_FAILED;
 
+	if (!_commit_update_backup(lv, mr))
+		return_ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 
@@ -1379,7 +1422,12 @@ static int _lvchange_persistent_single(struct cmd_context *cmd,
 				       struct logical_volume *lv,
 				       struct processing_handle *handle)
 {
-	if (!_lvchange_persistent(cmd, lv))
+	enum metadata_request mr = 0;
+
+	if (!_lvchange_persistent(cmd, lv, &mr))
+		return_ECMD_FAILED;
+
+	if (!_commit_update_backup(lv, mr))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -1412,4 +1460,3 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		  cmd->command->command_index, cmd->command->command_id);
 	return ECMD_FAILED;
 }
-


