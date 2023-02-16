From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:44 +0000 (GMT)
Subject: main - lvconvert: fix return codes
Message-ID: <20230216231044.35B623858C78@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=501cc19034d114683458fadeacb1bb1b47ab0195
Commit:        501cc19034d114683458fadeacb1bb1b47ab0195
Parent:        08265641f3a8590f7bb41c92af65e572cdc8d099
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 13:13:32 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 16 13:15:03 2023 +0100

lvconvert: fix return codes

Several inverted return code resulted the command returned
a success as exit code, while the function errored internally.
---
 tools/lvconvert.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c41d9aaf1..34ef5ac1e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4249,7 +4249,7 @@ static int _lvconvert_to_pool_single(struct cmd_context *cmd,
 		break;
 	default:
 		log_error(INTERNAL_ERROR "Invalid lvconvert pool command");
-		return 0;
+		return ECMD_FAILED;
 	};
 
 	if (cmd->position_argc > 1) {
@@ -5192,10 +5192,10 @@ static int _lvconvert_visible_check(struct cmd_context *cmd, struct logical_volu
 {
 	if (!lv_is_visible(lv)) {
 		log_error("Operation not permitted on hidden LV %s.", display_lvname(lv));
-		return 0;
+		return ECMD_FAILED;
 	}
 
-	return 1;
+	return ECMD_PROCESSED;
 }
 
 static int _lvconvert_change_mirrorlog_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -5428,20 +5428,20 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 
 	if (lvc.lv_name &&
 	    !validate_restricted_lvname_param(cmd, &vg_name, &lvc.lv_name))
-		return_0;
+		goto_out;
 
 	lvc.virtual_extents = extents_from_size(cmd,
 						arg_uint64_value(cmd, virtualsize_ARG, UINT64_C(0)),
 						vg->extent_size);
 
 	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_VDO)))
-		return_0;
+		goto_out;
 
 	if (activation() && lvc.segtype->ops->target_present) {
 		if (!lvc.segtype->ops->target_present(cmd, NULL, &lvc.target_attr)) {
 			log_error("%s: Required device-mapper target(s) not detected in your kernel.",
 				  lvc.segtype->name);
-			return 0;
+			goto out;
 		}
 	}
 
@@ -5455,7 +5455,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto_out;
 
 	if (!get_vdo_settings(cmd, &vdo_params, NULL))
-		return_0;
+		goto_out;
 
 	if (!activate_lv(cmd, lv)) {
 		log_error("Cannot activate %s.", display_lvname(lv));
@@ -6367,20 +6367,20 @@ static int _lvconvert_integrity_remove(struct cmd_context *cmd, struct logical_v
 
 	if (!lv_is_integrity(lv) && !lv_is_raid(lv)) {
 		log_error("LV does not have integrity.");
-		return 0;
+		return ECMD_FAILED;
 	}
 
 	/* ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))
-		return_0;
+		return_ECMD_FAILED;
 
 	if (lv_is_raid(lv))
 		ret = lv_remove_integrity_from_raid(lv);
 	if (!ret)
-		return_0;
+		return_ECMD_FAILED;
 
 	log_print_unless_silent("Logical volume %s has removed integrity.", display_lvname(lv));
-	return 1;
+	return ECMD_PROCESSED;
 }
 
 static int _lvconvert_integrity_add(struct cmd_context *cmd, struct logical_volume *lv,

