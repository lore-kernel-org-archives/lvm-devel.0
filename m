From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:23 +0000 (UTC)
Subject: master - cleanup: display_lvname
Message-ID: <20160310174023.C618860DFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00e641ef37a977129acc503f3fa1b67f556ac5eb
Commit:        00e641ef37a977129acc503f3fa1b67f556ac5eb
Parent:        8507db192481b5539d9721c912ce5556049bf050
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 7 10:45:50 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

cleanup: display_lvname

---
 tools/lvconvert.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f02a7f9..d80292a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1829,34 +1829,35 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 				    struct lvconvert_params *lp)
 {
 	struct volume_group *vg = cow->vg;
+	const char *cow_name = display_lvname(cow);
 
 	if (!lv_is_cow(cow)) {
-		log_error("%s/%s is not a snapshot.", vg->name, cow->name);
+		log_error("%s is not a snapshot.", cow_name);
 		return 0;
 	}
 
 	if (lv_is_origin(cow) || lv_is_external_origin(cow)) {
-		log_error("Unable to split LV %s/%s that is a snapshot origin.", vg->name, cow->name);
+		log_error("Unable to split LV %s that is a snapshot origin.", cow_name);
 		return 0;
 	}
 
 	if (lv_is_merging_cow(cow)) {
-		log_error("Unable to split off snapshot %s/%s being merged into its origin.", vg->name, cow->name);
+		log_error("Unable to split off snapshot %s being merged into its origin.", cow_name);
 		return 0;
 	}
 
 	if (lv_is_virtual_origin(origin_from_cow(cow))) {
-		log_error("Unable to split off snapshot %s/%s with virtual origin.", vg->name, cow->name);
+		log_error("Unable to split off snapshot %s with virtual origin.", cow_name);
 		return 0;
 	}
 
 	if (lv_is_thin_pool(cow) || lv_is_pool_metadata_spare(cow)) {
-		log_error("Unable to split off LV %s/%s needed by thin volume(s).", vg->name, cow->name);
+		log_error("Unable to split off LV %s needed by thin volume(s).", cow_name);
 		return 0;
 	}
 
 	if (!(vg->fid->fmt->features & FMT_MDAS)) {
-		log_error("Unable to split off snapshot %s/%s using old LVM1-style metadata.", vg->name, cow->name);
+		log_error("Unable to split off snapshot %s using old LVM1-style metadata.", cow_name);
 		return 0;
 	}
 
@@ -1870,7 +1871,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return_0;
 
 	if (lv_is_pvmove(cow) || lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
-		log_error("LV %s/%s type is unsupported with --splitsnapshot.", vg->name, cow->name);
+		log_error("LV %s type is unsupported with --splitsnapshot.", cow_name);
 		return 0;
 	}
 
@@ -1882,8 +1883,8 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		    lv_is_visible(cow) &&
 		    lv_is_active(cow)) {
 			if (yes_no_prompt("Do you really want to split off active "
-					  "logical volume %s? [y/n]: ", cow->name) == 'n') {
-				log_error("Logical volume %s not split.", cow->name);
+					  "logical volume %s? [y/n]: ", cow_name) == 'n') {
+				log_error("Logical volume %s not split.", cow_name);
 				return 0;
 			}
 		}
@@ -1892,14 +1893,14 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	if (!archive(vg))
 		return_0;
 
-	log_verbose("Splitting snapshot %s/%s from its origin.", vg->name, cow->name);
+	log_verbose("Splitting snapshot %s from its origin.", cow_name);
 
 	if (!vg_remove_snapshot(cow))
 		return_0;
 
 	backup(vg);
 
-	log_print_unless_silent("Logical Volume %s/%s split from its origin.", vg->name, cow->name);
+	log_print_unless_silent("Logical Volume %s split from its origin.", cow_name);
 
 	return 1;
 }
@@ -2056,27 +2057,27 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 			       struct lvconvert_params *lp)
 {
 	struct logical_volume *org;
+	const char *snap_name = display_lvname(lv);
 
 	if (lv_is_cache_type(lv)) {
 		log_error("Snapshots are not yet supported with cache type LVs %s.",
-			  display_lvname(lv));
+			  snap_name);
 		return 0;
 	}
 
 	if (lv_is_mirrored(lv)) {
-		log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
+		log_error("Unable to convert mirrored LV %s into a snapshot.", snap_name);
 		return 0;
 	}
 
 	if (lv_is_origin(lv)) {
 		/* Unsupported stack */
-		log_error("Unable to convert origin \"%s\" into a snapshot.", lv->name);
+		log_error("Unable to convert origin %s into a snapshot.", snap_name);
 		return 0;
 	}
 
 	if (lv_is_pool(lv)) {
-		log_error("Unable to convert pool LVs %s into a snapshot.",
-			  display_lvname(lv));
+		log_error("Unable to convert pool LVs %s into a snapshot.", snap_name);
 		return 0;
 	}
 
@@ -2087,8 +2088,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	}
 
 	if (org == lv) {
-		log_error("Unable to use %s as both snapshot and origin.",
-			  display_lvname(lv));
+		log_error("Unable to use %s as both snapshot and origin.", snap_name);
 		return 0;
 	}
 
@@ -2112,23 +2112,23 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	}
 
 	log_warn("WARNING: Converting logical volume %s to snapshot exception store.",
-		 display_lvname(lv));
+		 snap_name);
 	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 
 	if (!lp->yes &&
 	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",
-			  display_lvname(lv)) == 'n') {
+			  snap_name) == 'n') {
 		log_error("Conversion aborted.");
 		return 0;
 	}
 
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Couldn't deactivate LV %s.", lv->name);
+		log_error("Couldn't deactivate logical volume %s.", snap_name);
 		return 0;
 	}
 
 	if (!lp->zero || !(lv->status & LVM_WRITE))
-		log_warn("WARNING: \"%s\" not zeroed", lv->name);
+		log_warn("WARNING: %s not zeroed", snap_name);
 	else {
 		lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(cmd, lv) ||
@@ -2156,7 +2156,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!lv_update_and_reload(org))
 		return_0;
 
-	log_print_unless_silent("Logical volume %s converted to snapshot.", lv->name);
+	log_print_unless_silent("Logical volume %s converted to snapshot.", snap_name);
 
 	return 1;
 }


