From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:08:51 +0000 (UTC)
Subject: master - cleanup: move lv assignment
Message-ID: <20130611120851.678C3610D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0def236d636d2f4d9d0a08878d19a59891fa963
Commit:        d0def236d636d2f4d9d0a08878d19a59891fa963
Parent:        f5a3bef276fe610b34b7ea6c53d332c429c31f01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 13:28:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 13:55:26 2013 +0200

cleanup: move lv assignment

Use shorter  lv->.
---
 tools/lvresize.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index ae42ce8..7b1bd50 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -386,25 +386,27 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_external_origin(lvl->lv)) {
+	lv = lvl->lv;
+
+	if (lv_is_external_origin(lv)) {
 		/*
 		 * Since external-origin can be activated read-only,
 		 * there is no way to use extended areas.
 		 */
-		log_error("Cannot resize external origin \"%s\".", lvl->lv->name);
+		log_error("Cannot resize external origin \"%s\".", lv->name);
 		return EINVALID_CMD_LINE;
 	}
 
-	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
+	if (lv->status & (RAID_IMAGE | RAID_META)) {
 		log_error("Cannot resize a RAID %s directly",
-			  (lvl->lv->status & RAID_IMAGE) ? "image" :
+			  (lv->status & RAID_IMAGE) ? "image" :
 			  "metadata area");
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_raid_with_tracking(lvl->lv)) {
+	if (lv_is_raid_with_tracking(lv)) {
 		log_error("Cannot resize %s while it is tracking a split image",
-			  lvl->lv->name);
+			  lv->name);
 		return ECMD_FAILED;
 	}
 
@@ -430,8 +432,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	    !_validate_stripesize(cmd, vg, lp))
 		return EINVALID_CMD_LINE;
 
-	lv = lvl->lv;
-
 	if (use_policy) {
 		if (!lv_is_cow(lv) &&
 		    !lv_is_thin_pool(lv)) {
@@ -817,7 +817,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 
 	log_print_unless_silent("%sing logical volume %s to %s",
 				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
-				lp->lv_name,
+				lv->name,
 				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
 
 	if (lp->resize == LV_REDUCE) {
@@ -848,7 +848,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		lock_lv = lv;
 
 	if (!suspend_lv(cmd, lock_lv)) {
-		log_error("Failed to suspend %s", lp->lv_name);
+		log_error("Failed to suspend %s", lock_lv->name);
 		vg_revert(vg);
 		backup(vg);
 		return ECMD_FAILED;
@@ -863,7 +863,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!resume_lv(cmd, lock_lv)) {
-		log_error("Problem reactivating %s", lp->lv_name);
+		log_error("Problem reactivating %s", lock_lv->name);
 		backup(vg);
 		return ECMD_FAILED;
 	}


