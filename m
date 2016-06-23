From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:43 +0000 (UTC)
Subject: master - cleanup: add dots to some messages
Message-ID: <20160623130143.59D6E6066C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6268d0a080f61c85c2681b3dcfdd5b00f849ace1
Commit:        6268d0a080f61c85c2681b3dcfdd5b00f849ace1
Parent:        0a525832f9902f6268d155f22975653f27877816
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 14 14:56:17 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:08 2016 +0200

cleanup: add dots to some messages

Add missing dots and one comment.
---
 lib/activate/activate.c   |    2 +-
 lib/metadata/lv_manip.c   |   11 ++++++-----
 lib/metadata/thin_manip.c |    4 ++--
 tools/lvresize.c          |   10 +++++-----
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7f5d36f..d4c297e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1394,7 +1394,7 @@ int lvs_in_vg_opened(const struct volume_group *vg)
 		if (lv_is_visible(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 
-	log_debug_activation("Counted %d open LVs in VG %s", count, vg->name);
+	log_debug_activation("Counted %d open LVs in VG %s.", count, vg->name);
 
 	return count;
 }
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 439a3d7..6cf7323 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4347,7 +4347,7 @@ static int _request_confirmation(const struct volume_group *vg,
 	struct lvinfo info = { 0 };
 
 	if (!lv_info(vg->cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
-		log_error("lv_info failed: aborting");
+		log_error("lv_info failed: aborting.");
 		return 0;
 	}
 
@@ -4373,7 +4373,7 @@ static int _request_confirmation(const struct volume_group *vg,
 	if (!lp->ac_force) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
 				  display_lvname(lv)) == 'n') {
-			log_error("Logical volume %s NOT reduced",
+			log_error("Logical volume %s NOT reduced.",
 				  display_lvname(lv));
 			return 0;
 		}
@@ -4890,7 +4890,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 
 	/* FIXME Support LVs with mixed segment types */
 	if (lp->segtype != get_segtype_from_string(cmd, lp->ac_type ? : lp->segtype->name)) {
-		log_error("VolumeType does not match (%s)", lp->segtype->name);
+		log_error("VolumeType does not match (%s).", lp->segtype->name);
 		return 0;
 	}
 
@@ -5174,8 +5174,7 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 {
 	if (lv_is_origin(lv)) {
 		if (lp->resize == LV_REDUCE) {
-			log_error("Snapshot origin volumes cannot be reduced "
-				  "in size yet.");
+			log_error("Snapshot origin volumes cannot be reduced in size yet.");
 			return 0;
 		}
 
@@ -5273,6 +5272,8 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 			      lp->extents - lv->le_count,
 			      pvh, alloc, lp->approx_alloc))
 		return_NULL;
+	/* Check for over provisioning only when lv_extend() passed,
+	 * ATM this check does not fail */
 	else if (!pool_check_overprovisioning(lv))
 		return_NULL;
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 0d850d6..2f66675 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -206,7 +206,7 @@ int thin_pool_feature_supported(const struct logical_volume *lv, int feature)
 	    seg->segtype->ops->target_present &&
 	    !seg->segtype->ops->target_present(lv->vg->cmd, NULL, &attr)) {
 		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel", seg->segtype->name);
+			  "detected in your kernel.", seg->segtype->name);
 		return 0;
 	}
 
@@ -753,7 +753,7 @@ int check_new_thin_pool(const struct logical_volume *pool_lv)
 		return 0;
 	}
 
-	log_verbose("Deactivating public thin pool %s",
+	log_verbose("Deactivating public thin pool %s.",
 		    display_lvname(pool_lv));
 
 	/* Prevent any 'race' with in-use thin pool and always deactivate */
diff --git a/tools/lvresize.c b/tools/lvresize.c
index ee6678f..f7e17b8 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -101,13 +101,13 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	if (lp->resize == LV_EXTEND && lp->sign == SIGN_MINUS) {
-		log_error("Negative argument not permitted - use lvreduce");
+		log_error("Negative argument not permitted - use lvreduce.");
 		return 0;
 	}
 
 	if (lp->resize == LV_REDUCE &&
 	    ((lp->sign == SIGN_PLUS) || (lp->poolmetadatasign == SIGN_PLUS))) {
-		log_error("Positive sign not permitted - use lvextend");
+		log_error("Positive sign not permitted - use lvextend.");
 		return 0;
 	}
 
@@ -115,7 +115,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 
 	if (!argc) {
-		log_error("Please provide the logical volume name");
+		log_error("Please provide the logical volume name.");
 		return 0;
 	}
 
@@ -191,8 +191,8 @@ static int _lvresize_single(struct cmd_context *cmd, const char *vg_name,
 
 	/* Does LV exist? */
 	if (!(lv = find_lv(vg, lp->lv_name))) {
-		log_error("Logical volume %s not found in volume group %s",
-			  lp->lv_name, lp->vg_name);
+		log_error("Logical volume %s not found in volume group %s.",
+			  lp->lv_name, vg->name);
 		goto out;
 	}
 


