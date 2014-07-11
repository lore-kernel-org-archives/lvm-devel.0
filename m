From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:11 +0000 (UTC)
Subject: master - lvconvert: fix return codes
Message-ID: <20140711113411.84BA161133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64828d877edbf1907557d76e44eb86d00f7a1f3a
Commit:        64828d877edbf1907557d76e44eb86d00f7a1f3a
Parent:        baf825331cb37fd29007e7ed7596fb3683c8b37d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 12:24:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:49:02 2014 +0200

lvconvert: fix return codes

Error codes in some function are directly used
as command result - thus return 0 is not error code,
but success - switch to proper ECMD_FAILED.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   16 +++++++++-------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 77cc2d7..dcaaf23 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Return proper error codes for some failing lvconvert funtions.
   Add initial code to use cache tools (cache_check|dump|repair|restore).
   Add "degraded" activation mode and make it the default.
   Add separate lv_active_{locally,remotely,exclusively} LV reporting fields.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2a2a398..62a9d4e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -894,7 +894,7 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (dm_snprintf(lv_full_name, sizeof(lv_full_name), "%s/%s", lv->vg->name, lv->name) < 0) {
 		log_error(INTERNAL_ERROR "Name \"%s/%s\" is too long.", lv->vg->name, lv->name);
-		return 0;
+		return ECMD_FAILED;
 	}
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
@@ -1995,7 +1995,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 
         if (lv_info(cmd, cow, 0, &info, 1, 0)) {
                 if (!lv_check_not_in_use(cmd, cow, &info))
-                        return_0;
+			return_ECMD_FAILED;
 
                 if ((lp->force == PROMPT) &&
                     lv_is_visible(cow) &&
@@ -3047,8 +3047,11 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->splitsnapshot)
 		return _lvconvert_splitsnapshot(cmd, lv, lp);
 
-	if (arg_count(cmd, repair_ARG) && lv_is_thin_pool(lv))
-		return _lvconvert_thinpool_repair(cmd, lv, lp);
+	if (arg_count(cmd, repair_ARG) && lv_is_thin_pool(lv)) {
+		if (!_lvconvert_thinpool_repair(cmd, lv, lp))
+			return_ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
 
 	if (arg_count(cmd, repair_ARG) &&
 	    !(lv->status & MIRRORED) && !(lv->status & RAID)) {
@@ -3070,9 +3073,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		 * to consult the default.
 		 */
 		if (arg_count(cmd, mirrors_ARG) && !lv_is_mirrored(lv)) {
-			lp->segtype = get_segtype_from_string(cmd, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL));
-			if (!lp->segtype)
-				return_0;
+			if (!(lp->segtype = get_segtype_from_string(cmd, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL))))
+				return_ECMD_FAILED;
 		}
 	}
 	if (lp->merge) {


