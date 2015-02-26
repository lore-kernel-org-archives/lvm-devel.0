From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Feb 2015 18:41:24 +0000 (UTC)
Subject: master - lvchange: Allow -prw to change kernel only.
Message-ID: <20150226184124.C20D160E6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5394c8f260d091b7a41d78e3dbae32f90386cc4
Commit:        b5394c8f260d091b7a41d78e3dbae32f90386cc4
Parent:        71d97fd88afa0d8240569412bb1d3d256e596f6d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 26 18:38:26 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 26 18:38:26 2015 +0000

lvchange: Allow -prw to change kernel only.

If an LV is already rw but still ro in the kernel, allow -prw to issue a
refresh to try to change the kernel state to rw.

Intended for use after clearing activation/read_only_volume_list in
lvm.conf.
---
 tools/lvchange.c |  109 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 59 insertions(+), 50 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index b44ef33..6ed953f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -16,17 +16,18 @@
 #include "tools.h"
 #include "memlock.h"
 
-static int lvchange_permission(struct cmd_context *cmd,
-			       struct logical_volume *lv)
+static int _lvchange_permission(struct cmd_context *cmd,
+				struct logical_volume *lv)
 {
 	uint32_t lv_access;
 	struct lvinfo info;
+	unsigned info_obtained = 0;
 
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
-	if ((lv_access & LVM_WRITE) && (lv->status & LVM_WRITE)) {
-		log_error("Logical volume \"%s\" is already writable",
-			  lv->name);
+	if (lv_is_external_origin(lv)) {
+		log_error("Cannot change permissions of external origin "
+			  "\"%s\".", lv->name);
 		return 0;
 	}
 
@@ -36,14 +37,22 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_external_origin(lv)) {
-		log_error("Cannot change permissions of external origin "
-			  "\"%s\".", lv->name);
+	if ((lv_access & LVM_WRITE) && (lv->status & LVM_WRITE)) {
+		/* Refresh if it's read-write in metadata but read-only in kernel */
+		if (lv_info(cmd, lv, 0, &info, 0, 0) &&
+		    (info_obtained = 1, info.exists) && info.read_only) {
+			log_print_unless_silent("Logical volume \"%s\" is already writable.  Refreshing kernel state.",
+						lv->name);
+			return lv_refresh(cmd, lv);
+		}
+
+		log_error("Logical volume \"%s\" is already writable",
+			  lv->name);
 		return 0;
 	}
 
 	if (lv_is_mirrored(lv) && vg_is_clustered(lv->vg) &&
-	    lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
+	    (info_obtained || lv_info(cmd, lv, 0, &info, 0, 0)) && info.exists) {
 		log_error("Cannot change permissions of mirror \"%s\" "
 			  "while active.", lv->name);
 		return 0;
@@ -79,8 +88,8 @@ static int lvchange_permission(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_pool_update(struct cmd_context *cmd,
-				struct logical_volume *lv)
+static int _lvchange_pool_update(struct cmd_context *cmd,
+				 struct logical_volume *lv)
 {
 	int update = 0;
 	unsigned val;
@@ -126,8 +135,8 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_monitoring(struct cmd_context *cmd,
-			       struct logical_volume *lv)
+static int _lvchange_monitoring(struct cmd_context *cmd,
+				struct logical_volume *lv)
 {
 	struct lvinfo info;
 
@@ -148,8 +157,8 @@ static int lvchange_monitoring(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_background_polling(struct cmd_context *cmd,
-				       struct logical_volume *lv)
+static int _lvchange_background_polling(struct cmd_context *cmd,
+					struct logical_volume *lv)
 {
 	struct lvinfo info;
 
@@ -257,7 +266,7 @@ static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
  *
  * Suspend and resume a logical volume.
  */
-static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	log_verbose("Refreshing logical volume \"%s\" (if active)", lv->name);
 
@@ -285,7 +294,7 @@ static int _reactivate_lv(struct logical_volume *lv,
  *
  * Force a mirror or RAID array to undergo a complete initializing resync.
  */
-static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int active = 0;
 	int exclusive = 0;
@@ -468,7 +477,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	return 1;
 }
 
-static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int want_contiguous = arg_int_value(cmd, contiguous_ARG, 0);
 	alloc_policy_t alloc = (alloc_policy_t)
@@ -499,8 +508,8 @@ static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 	return 1;
 }
 
-static int lvchange_errorwhenfull(struct cmd_context *cmd,
-				  struct logical_volume *lv)
+static int _lvchange_errorwhenfull(struct cmd_context *cmd,
+				   struct logical_volume *lv)
 {
 	unsigned ewf = arg_int_value(cmd, errorwhenfull_ARG, 0);
 
@@ -521,8 +530,8 @@ static int lvchange_errorwhenfull(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_readahead(struct cmd_context *cmd,
-			      struct logical_volume *lv)
+static int _lvchange_readahead(struct cmd_context *cmd,
+			       struct logical_volume *lv)
 {
 	unsigned read_ahead = 0;
 	unsigned pagesize = (unsigned) lvm_getpagesize() >> SECTOR_SHIFT;
@@ -566,8 +575,8 @@ static int lvchange_readahead(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_persistent(struct cmd_context *cmd,
-			       struct logical_volume *lv)
+static int _lvchange_persistent(struct cmd_context *cmd,
+				struct logical_volume *lv)
 {
 	enum activation_change activate = CHANGE_AN;
 
@@ -639,7 +648,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume *lv)
+static int _lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct dm_config_tree *policy = NULL;
 	int r = 0;
@@ -663,7 +672,7 @@ out:
 	return r;
 }
 
-static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int arg)
+static int _lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int arg)
 {
 	if (!change_tag(cmd, NULL, lv, NULL, arg))
 		return_0;
@@ -679,7 +688,7 @@ static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int
 	return 1;
 }
 
-static int lvchange_writemostly(struct logical_volume *lv)
+static int _lvchange_writemostly(struct logical_volume *lv)
 {
 	int s, pv_count, i = 0;
 	char **pv_names;
@@ -779,7 +788,7 @@ static int lvchange_writemostly(struct logical_volume *lv)
 	return 1;
 }
 
-static int lvchange_recovery_rate(struct logical_volume *lv)
+static int _lvchange_recovery_rate(struct logical_volume *lv)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
@@ -810,7 +819,7 @@ static int lvchange_recovery_rate(struct logical_volume *lv)
 	return 1;
 }
 
-static int lvchange_profile(struct logical_volume *lv)
+static int _lvchange_profile(struct logical_volume *lv)
 {
 	const char *old_profile_name, *new_profile_name;
 	struct profile *new_profile;
@@ -841,7 +850,7 @@ static int lvchange_profile(struct logical_volume *lv)
 	return 1;
 }
 
-static int lvchange_activation_skip(struct logical_volume *lv)
+static int _lvchange_activation_skip(struct logical_volume *lv)
 {
 	int skip = arg_int_value(lv->vg->cmd, setactivationskip_ARG, 0);
 
@@ -860,7 +869,7 @@ static int lvchange_activation_skip(struct logical_volume *lv)
 
 
 static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   struct processing_handle *handle __attribute__((unused)))
+			    struct processing_handle *handle __attribute__((unused)))
 {
 	int doit = 0, docmds = 0;
 	struct logical_volume *origin;
@@ -966,7 +975,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, permission_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_permission(cmd, lv);
+		doit += _lvchange_permission(cmd, lv);
 		docmds++;
 	}
 
@@ -974,7 +983,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, contiguous_ARG) || arg_count(cmd, alloc_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_alloc(cmd, lv);
+		doit += _lvchange_alloc(cmd, lv);
 		docmds++;
 	}
 
@@ -982,7 +991,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, errorwhenfull_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_errorwhenfull(cmd, lv);
+		doit += _lvchange_errorwhenfull(cmd, lv);
 		docmds++;
 	}
 
@@ -990,7 +999,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, readahead_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_readahead(cmd, lv);
+		doit += _lvchange_readahead(cmd, lv);
 		docmds++;
 	}
 
@@ -998,7 +1007,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, persistent_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_persistent(cmd, lv);
+		doit += _lvchange_persistent(cmd, lv);
 		docmds++;
 		if (sigint_caught())
 			return_ECMD_FAILED;
@@ -1008,7 +1017,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    arg_count(cmd, zero_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_pool_update(cmd, lv);
+		doit += _lvchange_pool_update(cmd, lv);
 		docmds++;
 	}
 
@@ -1016,7 +1025,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, addtag_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_tag(cmd, lv, addtag_ARG);
+		doit += _lvchange_tag(cmd, lv, addtag_ARG);
 		docmds++;
 	}
 
@@ -1024,7 +1033,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, deltag_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_tag(cmd, lv, deltag_ARG);
+		doit += _lvchange_tag(cmd, lv, deltag_ARG);
 		docmds++;
 	}
 
@@ -1032,7 +1041,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, writemostly_ARG) || arg_count(cmd, writebehind_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_writemostly(lv);
+		doit += _lvchange_writemostly(lv);
 		docmds++;
 	}
 
@@ -1041,7 +1050,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    arg_count(cmd, maxrecoveryrate_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_recovery_rate(lv);
+		doit += _lvchange_recovery_rate(lv);
 		docmds++;
 	}
 
@@ -1050,21 +1059,21 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	    arg_count(cmd, detachprofile_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_profile(lv);
+		doit += _lvchange_profile(lv);
 		docmds++;
 	}
 
 	if (arg_count(cmd, setactivationskip_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_activation_skip(lv);
+		doit += _lvchange_activation_skip(lv);
 		docmds++;
 	}
 
 	if (arg_count(cmd, cachepolicy_ARG) || arg_count(cmd, cachesettings_ARG)) {
 		if (!archive(lv->vg))
 			return_ECMD_FAILED;
-		doit += lvchange_cachepolicy(cmd, lv);
+		doit += _lvchange_cachepolicy(cmd, lv);
 		docmds++;
 	}
 
@@ -1072,7 +1081,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
 
 	if (arg_count(cmd, resync_ARG) &&
-	    !lvchange_resync(cmd, lv))
+	    !_lvchange_resync(cmd, lv))
 		return_ECMD_FAILED;
 
 	if (arg_count(cmd, syncaction_ARG) &&
@@ -1084,15 +1093,15 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!_lvchange_activate(cmd, lv))
 			return_ECMD_FAILED;
 	} else if (arg_count(cmd, refresh_ARG)) {
-		if (!lvchange_refresh(cmd, lv))
+		if (!_lvchange_refresh(cmd, lv))
 			return_ECMD_FAILED;
 	} else {
 		if (arg_count(cmd, monitor_ARG) &&
-		    !lvchange_monitoring(cmd, lv))
+		    !_lvchange_monitoring(cmd, lv))
 			return_ECMD_FAILED;
 
 		if (arg_count(cmd, poll_ARG) &&
-		    !lvchange_background_polling(cmd, lv))
+		    !_lvchange_background_polling(cmd, lv))
 			return_ECMD_FAILED;
 	}
 
@@ -1136,8 +1145,8 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	int update = update_partial_safe || update_partial_unsafe;
 
 	if (!update &&
-            !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
-            !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
+	    !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
+	    !arg_count(cmd, monitor_ARG) && !arg_count(cmd, poll_ARG)) {
 		log_error("Need 1 or more of -a, -C, -M, -p, -r, -Z, "
 			  "--resync, --refresh, --alloc, --addtag, --deltag, "
 			  "--monitor, --poll or --discards");


