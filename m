From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:23 +0000 (UTC)
Subject: master - thin: always activate and deactive pool when creating
Message-ID: <20140311233423.1910460EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a60cbcf45c553dfc168552cf9af3059359ec95d
Commit:        8a60cbcf45c553dfc168552cf9af3059359ec95d
Parent:        6a0d97a65c793e5875fc6c4f0a815c37ed4b6d38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 11 23:07:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:16:27 2014 +0100

thin: always activate and deactive pool when creating

When we create thin-pool we have used trick to keep
volume active, but since we now support TEMPORARY flag,
we could just localy active & deactive metadata LV,
and let the thinpool through normal activation process.
---
 lib/metadata/lv_manip.c   |   63 +++------------------------------------------
 lib/metadata/pool_manip.c |    3 ++
 2 files changed, 7 insertions(+), 59 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1264de7..9246920 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6288,19 +6288,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lv_activation_skip(lv, lp->activate, lp->activation_skip & ACTIVATION_SKIP_IGNORE))
 		lp->activate = CHANGE_AN;
 
-	/*
-	 * For thin pools - deactivate when inactive pool is requested or
-	 * for cluster give-up local lock and take proper exlusive lock
-	 */
-	if (lv_is_thin_pool(lv) &&
-	    (!is_change_activating(lp->activate) ||
-	     vg_is_clustered(lv->vg)) &&
-	    /* Deactivates cleared metadata LV */
-	    !deactivate_lv(lv->vg->cmd, lv)) {
-		stack;
-		goto deactivate_failed;
-	}
-
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_NULL;
@@ -6319,50 +6306,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lp->temporary)
 		lv->status |= LV_TEMPORARY;
 
-	if (lv_is_cache_type(lv)) {
-		if (!lv_is_active(lv)) {
-			if (!activate_lv_excl(cmd, lv)) {
-				log_error("Failed to activate pool %s.",
-					  lv->name);
-				goto deactivate_and_revert_new_lv;
-			}
-		} else {
-			if (!suspend_lv(cmd, lv)) {
-				log_error("Failed to suspend pool %s.",
-					  lv->name);
-				goto deactivate_and_revert_new_lv;
-			}
-			if (!resume_lv(cmd, lv)) {
-				log_error("Failed to resume pool %s.", lv->name);
-				goto deactivate_and_revert_new_lv;
-			}
-		}
-	} else if (lv_is_thin_pool(lv)) {
-		if (is_change_activating(lp->activate)) {
-			if (vg_is_clustered(lv->vg)) {
-				if (!activate_lv_excl(cmd, lv)) {
-					log_error("Failed to activate pool %s.", lv->name);
-					goto deactivate_and_revert_new_lv;
-				}
-			} else {
-				/*
-				 * Suspend cleared plain metadata LV
-				 * but now already commited as pool LV
-				 * and resume it as a pool LV.
-				 *
-				 * This trick avoids collision with udev watch rule.
-				 */
-				if (!suspend_lv(cmd, lv)) {
-					log_error("Failed to suspend pool %s.", lv->name);
-					goto deactivate_and_revert_new_lv;
-				}
-				if (!resume_lv(cmd, lv)) {
-					log_error("Failed to resume pool %s.", lv->name);
-					goto deactivate_and_revert_new_lv;
-				}
-			}
-		}
-	} else if (lv_is_thin_volume(lv)) {
+	if (lv_is_thin_volume(lv)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {
 			if (!suspend_lv_origin(cmd, org)) {
@@ -6400,7 +6344,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 	} else if (!lv_active_change(cmd, lv, lp->activate)) {
 		log_error("Failed to activate new LV.");
-		if (lp->zero || lp->wipe_signatures)
+		if (lp->zero || lp->wipe_signatures ||
+		    lv_is_thin_pool(lv) ||
+		    lv_is_cache_type(lv))
 			goto deactivate_and_revert_new_lv;
 		return NULL;
 	}
@@ -6494,7 +6440,6 @@ out:
 
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, lv)) {
-deactivate_failed:
 		log_error("Unable to deactivate failed new LV \"%s/%s\". "
 			  "Manual intervention required.", lv->vg->name, lv->name);
 		return NULL;
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 0c7bf96..f414f3f 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -267,6 +267,9 @@ int create_pool(struct logical_volume *pool_lv,
 			goto bad;
 		}
 		pool_lv->status &= ~LV_TEMPORARY;
+		/* Deactivates cleared metadata LV */
+		if (!deactivate_lv_local(pool_lv->vg->cmd, pool_lv))
+			goto_bad;
 	}
 
 	if (dm_snprintf(name, sizeof(name), "%s_%s", pool_lv->name,


