From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 4 Apr 2017 17:54:20 -0400
Subject: master - lvchange: enhance avoiding multiple metadata updates/reloads/backups
Message-ID: <201704042154.v34LsKuh016493@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a12b3af033d8086e0399e5433a3307ebb05b9d0b
Commit:        a12b3af033d8086e0399e5433a3307ebb05b9d0b
Parent:        e7ec9aab8a9a546e1b6ef7dc49e8012373691c3b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Apr 4 23:53:55 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Apr 4 23:53:55 2017 +0200

lvchange: enhance avoiding multiple metadata updates/reloads/backups

Enhance commit 25b5915c9b5260c59d627bd1f6db8220bd4ad61e
to process options requiring immediate metadata commits
and reloads after those we can group together doing just
one commit and an optional reload for the whole group.

Backup metadata after processing options successfully.

Related: rhbz1437611
---
 tools/lvchange.c |  247 +++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 179 insertions(+), 68 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 27b5184..c68ea98 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -19,21 +19,18 @@
 
 /*
  * Passed back from callee to request caller to
- * commit / update and reload / backup metadata.
+ * commit and optionally reload metadata.
  *
  * This allows for one metadata update per command run
  * (unless mandatory interim ones in callee).
  */
-enum metadata_request {
-	MR_COMMIT	 = 0x1,
-	MR_UPDATE_RELOAD = 0x2,
-	MR_BACKUP	 = 0x4
-};
+#define	MR_COMMIT	0x1 /* Commit metadata, don't reload table(s) */
+#define	MR_RELOAD	0x2 /* Commit metadata _and_  reload table(s) */
 
 static int _vg_write_commit(const struct logical_volume *lv, const char *what)
 {
-	log_very_verbose("Updating %slogical volume %s on disk(s).",
-			 what ? : "", display_lvname(lv));
+	log_very_verbose("Updating %s%slogical volume %s on disk(s).",
+			 what ? : "", what ? " " : "", display_lvname(lv));
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
 		log_error("Failed to update %smetadata of %s on disk.",
 			  what ? : "", display_lvname(lv));
@@ -45,7 +42,7 @@ static int _vg_write_commit(const struct logical_volume *lv, const char *what)
 
 static int _lvchange_permission(struct cmd_context *cmd,
 				struct logical_volume *lv,
-				enum metadata_request *mr)
+				uint32_t *mr)
 {
 	uint32_t lv_access;
 	struct lvinfo info;
@@ -94,15 +91,15 @@ static int _lvchange_permission(struct cmd_context *cmd,
 			    display_lvname(lv));
 	}
 
-	/* Request caller to update and reload metadata */
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_pool_update(struct cmd_context *cmd,
 				 struct logical_volume *lv,
-				 enum metadata_request *mr)
+				 uint32_t *mr)
 {
 	int update = 0;
 	unsigned val;
@@ -138,7 +135,9 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	if (!update)
 		return 0;
 
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
+
 	return 1;
 }
 
@@ -464,7 +463,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 
 static int _lvchange_alloc(struct cmd_context *cmd,
 			   struct logical_volume *lv,
-			   enum metadata_request *mr)
+			   uint32_t *mr)
 {
 	int want_contiguous = arg_int_value(cmd, contiguous_ARG, 0);
 	alloc_policy_t alloc = (alloc_policy_t)
@@ -488,15 +487,15 @@ static int _lvchange_alloc(struct cmd_context *cmd,
 
 	/* No need to suspend LV for this change */
 
-	/* Request caller to commit+backuo metadata */
-	*mr |= (MR_COMMIT | MR_BACKUP);
+	/* Request caller to commit metadata */
+	*mr |= MR_COMMIT;
 
 	return 1;
 }
 
 static int _lvchange_errorwhenfull(struct cmd_context *cmd,
 				   struct logical_volume *lv,
-				   enum metadata_request *mr)
+				   uint32_t *mr)
 {
 	unsigned ewf = arg_int_value(cmd, errorwhenfull_ARG, 0);
 
@@ -511,15 +510,15 @@ static int _lvchange_errorwhenfull(struct cmd_context *cmd,
 	else
 		lv->status &= ~LV_ERROR_WHEN_FULL;
 
-	/* Request caller to update and reload metadata */
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_readahead(struct cmd_context *cmd,
 			       struct logical_volume *lv,
-			       enum metadata_request *mr)
+			       uint32_t *mr)
 {
 	unsigned read_ahead = 0;
 	unsigned pagesize = (unsigned) lvm_getpagesize() >> SECTOR_SHIFT;
@@ -558,15 +557,15 @@ static int _lvchange_readahead(struct cmd_context *cmd,
 	log_verbose("Setting read ahead to %u for %s.",
 		    read_ahead, display_lvname(lv));
 
-	/* Request caller to update and reload metadata */
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_persistent(struct cmd_context *cmd,
 				struct logical_volume *lv,
-				enum metadata_request *mr)
+				uint32_t *mr)
 {
 	enum activation_change activate = CHANGE_AN;
 
@@ -634,15 +633,12 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 		}
 	}
 
-	/* Request caller to backup metadata */
-	*mr |= MR_BACKUP;
-
 	return 1;
 }
 
 static int _lvchange_cache(struct cmd_context *cmd,
 			   struct logical_volume *lv,
-			   enum metadata_request *mr)
+			   uint32_t *mr)
 {
 	cache_metadata_format_t format;
 	cache_mode_t mode;
@@ -677,8 +673,8 @@ static int _lvchange_cache(struct cmd_context *cmd,
 	    !cache_set_policy(first_seg(lv), name, settings))
 		goto_out;
 
-	/* Request caller to update and reload metadata */
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
 
 	r = 1;
 out:
@@ -689,7 +685,7 @@ out:
 }
 
 static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
-			 int arg, enum metadata_request *mr)
+			 int arg, uint32_t *mr)
 {
 	if (!change_tag(cmd, NULL, lv, NULL, arg))
 		return_0;
@@ -697,8 +693,9 @@ static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv,
 	log_very_verbose("Updating logical volume %s on disk(s).", display_lvname(lv));
 
 	/* No need to suspend LV for this change */
-	/* Request caller to commit+backup metadata */
-	*mr |= (MR_COMMIT | MR_BACKUP);
+
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_COMMIT;
 
 	return 1;
 }
@@ -752,7 +749,7 @@ static int _lvchange_rebuild(struct logical_volume *lv)
 }
 
 static int _lvchange_writemostly(struct logical_volume *lv,
-				 enum metadata_request *mr)
+				 uint32_t *mr)
 {
 	int pv_count, i = 0;
 	uint32_t s, writemostly;
@@ -869,14 +866,14 @@ static int _lvchange_writemostly(struct logical_volume *lv,
 		}
 	}
 
-	/* Request caller to update and reload metadata */
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_recovery_rate(struct logical_volume *lv,
-				   enum metadata_request *mr)
+				   uint32_t *mr)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
@@ -894,14 +891,14 @@ static int _lvchange_recovery_rate(struct logical_volume *lv,
 		return 0;
 	}
 
-	/* Request caller to update and reload metadata */
-	*mr |= MR_UPDATE_RELOAD;
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
 
 	return 1;
 }
 
 static int _lvchange_profile(struct logical_volume *lv,
-			     enum metadata_request *mr)
+			     uint32_t *mr)
 {
 	const char *old_profile_name, *new_profile_name;
 	struct profile *new_profile;
@@ -924,13 +921,13 @@ static int _lvchange_profile(struct logical_volume *lv,
 	log_verbose("Changing configuration profile for LV %s: %s -> %s.",
 		    display_lvname(lv), old_profile_name, new_profile_name);
 
-	/* Request caller to commit+backup metadata */
-	*mr |= (MR_COMMIT | MR_BACKUP);
+	/* Request caller to commit metadata */
+	*mr |= MR_COMMIT;
 
 	return 1;
 }
 
-static int _lvchange_activation_skip(struct logical_volume *lv, enum metadata_request *mr)
+static int _lvchange_activation_skip(struct logical_volume *lv, uint32_t *mr)
 {
 	int skip = arg_int_value(lv->vg->cmd, setactivationskip_ARG, 0);
 
@@ -940,16 +937,15 @@ static int _lvchange_activation_skip(struct logical_volume *lv, enum metadata_re
 		    display_lvname(lv), skip ? "enabled" : "disabled");
 
 	/* Request caller to commit+backup metadata */
-	*mr |= (MR_COMMIT | MR_BACKUP);
+	*mr |= MR_COMMIT;
 
 	return 1;
 }
 
 /* Update and reload or commit and/or backup metadata for @lv as requested by @mr */
-static int _commit_update_backup(struct logical_volume *lv,
-				 const enum metadata_request mr)
+static int _commit_reload(struct logical_volume *lv, uint32_t mr)
 {
-	if (mr & MR_UPDATE_RELOAD) {
+	if (mr & MR_RELOAD) {
 		if (!lv_update_and_reload(lv))
 			return_0;
 
@@ -957,9 +953,6 @@ static int _commit_update_backup(struct logical_volume *lv,
 		   !_vg_write_commit(lv, NULL))
 		return 0;
 
-	if (mr & MR_BACKUP)
-		backup(lv->vg);
-
 	return 1;
 }
 
@@ -976,13 +969,22 @@ static int _commit_update_backup(struct logical_volume *lv,
  * . (or all the code could live in the _single fn)
  */
 
+/*
+ * Process 2 types of options differently
+ * minimizing metadata commits and table reloads:
+ *
+ * 1. process group of options not requiring metadata commit(, reload)
+ *    for each option and commit(, reload) metadata for the whole group
+ *
+ * 2. process the options requiring metadata commit+reload per option
+ */
 static int _lvchange_properties_single(struct cmd_context *cmd,
 			               struct logical_volume *lv,
 			               struct processing_handle *handle)
 {
-	int doit = 0, docmds = 0;
+	int docmds = 0, doit = 0, doit_total = 0, change_msg = 1, second_group = 0;
 	int i, opt_enum;
-	enum metadata_request mr = 0;
+	uint32_t mr = 0;
 
 	/*
 	 * If a persistent lv lock already exists from activation
@@ -995,90 +997,199 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
+	/* First group of options which allow for one metadata commit/update for the whole group */
 	for (i = 0; i < cmd->command->ro_count; i++) {
 		opt_enum = cmd->command->required_opt_args[i].opt;
 
 		if (!arg_is_set(cmd, opt_enum))
 			continue;
 
-		/* Archive will only happen once per run */
+		switch (opt_enum) {
+		/*
+		 * Skip options requiring per option commit/reload
+		 * to process them in the second step.
+		 */
+		case discards_ARG:
+		case zero_ARG:
+		case cachemode_ARG:
+		case cachepolicy_ARG:
+		case cachesettings_ARG:
+			second_group++;
+			continue;
+		default:
+			break;
+		}
+
+		/* Archive will only happen once per run. */
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
 
-		docmds++;
-
+		/*
+		 * Process the following options and to a single
+		 * metadata commit/reload for the whole group.
+		 */
 		switch (opt_enum) {
 		case permission_ARG:
+			docmds++;
 			doit += _lvchange_permission(cmd, lv, &mr);
 			break;
 
 		case alloc_ARG:
 		case contiguous_ARG:
+			docmds++;
 			doit += _lvchange_alloc(cmd, lv, &mr);
 			break;
 
 		case errorwhenfull_ARG:
+			docmds++;
 			doit += _lvchange_errorwhenfull(cmd, lv, &mr);
 			break;
 
 		case readahead_ARG:
+			docmds++;
 			doit += _lvchange_readahead(cmd, lv, &mr);
 			break;
 
 		case persistent_ARG:
+			docmds++;
 			doit += _lvchange_persistent(cmd, lv, &mr);
 			break;
 
-		case discards_ARG:
-		case zero_ARG:
-			doit += _lvchange_pool_update(cmd, lv, &mr);
-			break;
-
 		case addtag_ARG:
 		case deltag_ARG:
+			docmds++;
 			doit += _lvchange_tag(cmd, lv, opt_enum, &mr);
 			break;
 
 		case writemostly_ARG:
 		case writebehind_ARG:
+			docmds++;
 			doit += _lvchange_writemostly(lv, &mr);
 			break;
 
 		case minrecoveryrate_ARG:
 		case maxrecoveryrate_ARG:
+			docmds++;
 			doit += _lvchange_recovery_rate(lv, &mr);
 			break;
 
 		case profile_ARG:
 		case metadataprofile_ARG:
 		case detachprofile_ARG:
+			docmds++;
 			doit += _lvchange_profile(lv, &mr);
 			break;
 
 		case setactivationskip_ARG:
+			docmds++;
 			doit += _lvchange_activation_skip(lv, &mr);
 			break;
 
+		default:
+			log_error(INTERNAL_ERROR "Failed to check for option %s",
+				  arg_long_option_name(i));
+		}
+	}
+
+	/* Any options of the first group processed? */
+	if (docmds) {
+		doit_total = doit;
+		doit = 0;
+
+		/* Display any logical volume change */
+		if (doit_total) {
+			log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
+			change_msg = 0;
+
+			/* Commit(, reload) metadata once for whole processed group of options */
+			if (!_commit_reload(lv, mr))
+				return_ECMD_FAILED;
+		}
+
+		/* Bail out if any processing of an option in the first group failed */
+		if (docmds != doit_total)
+			return_ECMD_FAILED;
+
+		/* Do backup if processing the first group of options went ok */
+		backup(lv->vg);
+
+	} else if (!second_group)
+		return_ECMD_FAILED;
+
+	/* Second group of options which need per option metadata commit+reload(s) */
+	for (i = 0; i < cmd->command->ro_count; i++) {
+		opt_enum = cmd->command->required_opt_args[i].opt;
+
+		if (!arg_is_set(cmd, opt_enum))
+			continue;
+
+		switch (opt_enum) {
+		/* Skip any of the already processed options */
+		case permission_ARG:
+		case alloc_ARG:
+		case contiguous_ARG:
+		case errorwhenfull_ARG:
+		case readahead_ARG:
+		case persistent_ARG:
+		case addtag_ARG:
+		case deltag_ARG:
+		case writemostly_ARG:
+		case writebehind_ARG:
+		case minrecoveryrate_ARG:
+		case maxrecoveryrate_ARG:
+		case profile_ARG:
+		case metadataprofile_ARG:
+		case detachprofile_ARG:
+		case setactivationskip_ARG:
+			continue;
+		default:
+			break;
+		}
+
+		/* Archive will only happen once per run */
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+
+		mr = 0;
+
+		switch (opt_enum) {
+		/* Process the following options which need per option metadata commit and reload */
+		case discards_ARG:
+		case zero_ARG:
+			docmds++;
+			doit += _lvchange_pool_update(cmd, lv, &mr);
+			break;
+
 		case cachemode_ARG:
 		case cachepolicy_ARG:
 		case cachesettings_ARG:
+			docmds++;
 			doit += _lvchange_cache(cmd, lv, &mr);
 			break;
 
 		default:
-			log_error(INTERNAL_ERROR "Failed to check for option %s",
-				  arg_long_option_name(i));
+			break;
 		}
+
+		/* Display any logical volume change unless already displayed in step 1. */
+		if (doit && change_msg) {
+			log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
+			change_msg = 0;
+		}
+
+		/* Commit(,reload) metadata per processed option */
+		if (!_commit_reload(lv, mr))
+			return_ECMD_FAILED;
 	}
 
-	if (doit)
-		log_print_unless_silent("Logical volume %s changed.", display_lvname(lv));
+	doit_total += doit;
 
-	if (doit != docmds)
+	/* Bail out if no options wwre found or any processing of an option in the second group failed */
+	if (!docmds || docmds != doit_total)
 		return_ECMD_FAILED;
 
-	if (!_commit_update_backup(lv, mr))
-		return_ECMD_FAILED;
+	/* Do backup if processing the second group of options went ok */
+	backup(lv->vg);
 
 	return ECMD_PROCESSED;
 }
@@ -1422,12 +1533,12 @@ static int _lvchange_persistent_single(struct cmd_context *cmd,
 				       struct logical_volume *lv,
 				       struct processing_handle *handle)
 {
-	enum metadata_request mr = 0;
+	uint32_t mr = 0;
 
 	if (!_lvchange_persistent(cmd, lv, &mr))
 		return_ECMD_FAILED;
 
-	if (!_commit_update_backup(lv, mr))
+	if (!_commit_reload(lv, mr))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;


