From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:47 +0000 (UTC)
Subject: master - cleanup: lvconvert use standard function exit
Message-ID: <20141006133347.B421A60DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73c74d582c27400f8cad939a52503e3721c0e153
Commit:        73c74d582c27400f8cad939a52503e3721c0e153
Parent:        8d272ba0ada6deae264e44705a4ce3b7ece93cd0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 4 17:17:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:07 2014 +0200

cleanup: lvconvert use standard function exit

Use 1|0 inside _lvconvert_splitsnapshot to match rest of code.
---
 tools/lvconvert.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4bf4306..8f25561 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1962,45 +1962,45 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 
 	if (!lv_is_cow(cow)) {
 		log_error("%s/%s is not a snapshot.", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_origin(cow) || lv_is_external_origin(cow)) {
 		log_error("Unable to split LV %s/%s that is a snapshot origin.", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_merging_cow(cow)) {
 		log_error("Unable to split off snapshot %s/%s being merged into its origin.", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
 		log_error("Unable to split off snapshot %s/%s with virtual origin.", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_thin_pool(cow) || lv_is_pool_metadata_spare(cow)) {
 		log_error("Unable to split off LV %s/%s needed by thin volume(s).", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!(vg->fid->fmt->features & FMT_MDAS)) {
 		log_error("Unable to split off snapshot %s/%s using old LVM1-style metadata.", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!vg_check_status(vg, LVM_WRITE))
-		return_ECMD_FAILED;
+		return_0;
 
 	if (lv_is_pvmove(cow) || lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
 		log_error("LV %s/%s type is unsupported with --splitsnapshot.", vg->name, cow->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (lv_is_active_locally(cow)) {
 		if (!lv_check_not_in_use(cow))
-			return_ECMD_FAILED;
+			return_0;
 
 		if ((lp->force == PROMPT) && !lp->yes &&
 		    lv_is_visible(cow) &&
@@ -2008,24 +2008,24 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 			if (yes_no_prompt("Do you really want to split off active "
 					  "logical volume %s? [y/n]: ", cow->name) == 'n') {
 				log_error("Logical volume %s not split.", cow->name);
-				return ECMD_FAILED;
+				return 0;
 			}
 		}
 	}
 
 	if (!archive(vg))
-		return_ECMD_FAILED;
+		return_0;
 
 	log_verbose("Splitting snapshot %s/%s from its origin.", vg->name, cow->name);
 
 	if (!vg_remove_snapshot(cow))
-		return_ECMD_FAILED;
+		return_0;
 
 	backup(vg);
 
 	log_print_unless_silent("Logical Volume %s/%s split from its origin.", vg->name, cow->name);
 
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 
@@ -3239,8 +3239,11 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lp->splitsnapshot)
-		return _lvconvert_splitsnapshot(cmd, lv, lp);
+	if (lp->splitsnapshot) {
+		if (!_lvconvert_splitsnapshot(cmd, lv, lp))
+			return_ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
 
 	if (lp->splitcache) {
 		if (!_lvconvert_splitcache(cmd, lv, lp))


