From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:45 +0000 (UTC)
Subject: master - thin: improve pool creation activation order
Message-ID: <20130718162645.D478460DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08df7ba844f837c4a09540feadaa734d7f3259f8
Commit:        08df7ba844f837c4a09540feadaa734d7f3259f8
Parent:        4e724f5f52e3f641d1ccc5a90d0af2ad73a52a8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 18 16:44:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

thin: improve pool creation activation order

Pool creation involves clearing of metadata device
which triggers udev watch rule we cannot udev synchronize with
in current code.

This metadata devices needs to be activated localy,
so in cluster mode deactivation and reactivation
is always needed.

However for non-clustered mode we may reload table
via suspend/resume path which avoids collision with
udev watch rule which was occasionaly triggering
retry deactivation loop.

Code has been also split into 2 separate code paths
for thin pools and thin volumes which improved readability
of the code as well.

Deactivation has been moved out of extend_pool() and
decision is now in _lv_create_an_lv() which knows
the change mode.
---
 WHATS_NEW                 |    1 +
 lib/metadata/lv_manip.c   |   57 +++++++++++++++++++++++++++++++++++++--------
 lib/metadata/thin_manip.c |    8 +-----
 3 files changed, 49 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f49c71c..f9cfa01 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Improve activation order when creating thin pools in non-clustered VG.
   List thin-pool and thin modules for thin volumes.
   Correct thin creation error paths.
   Use local activation for clearing snapshot COW device.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2bfd65e..42a5f1e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5701,6 +5701,19 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		lp->activate = CHANGE_AN;
 	}
 
+	/*
+	 * For thin pools - deactivate when inactive pool is requested or
+	 * for cluster give-up local lock and take proper exlusive lock
+	 */
+	if (lv_is_thin_pool(lv) &&
+	    (!is_change_activating(lp->activate) ||
+	     vg_is_clustered(lv->vg)) &&
+	    /* Deactivates cleared metadata LV */
+	    !deactivate_lv(lv->vg->cmd, lv)) {
+		stack;
+		goto deactivate_failed;
+	}
+
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_NULL;
@@ -5712,7 +5725,32 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		goto out;
 	}
 
-	if (seg_is_thin(lp)) {
+	if (lv_is_thin_pool(lv)) {
+		if (is_change_activating(lp->activate)) {
+			if (vg_is_clustered(lv->vg)) {
+				if (!activate_lv_excl(cmd, lv)) {
+					log_error("Failed to activate pool %s.", lv->name);
+					goto deactivate_and_revert_new_lv;
+				}
+			} else {
+				/*
+				 * Suspend cleared plain metadata LV
+				 * but now already commited as pool LV
+				 * and resume it as a pool LV.
+				 *
+				 * This trick avoids collision with udev watch rule.
+				 */
+				if (!suspend_lv(cmd, lv)) {
+					log_error("Failed to suspend pool %s.", lv->name);
+					goto deactivate_and_revert_new_lv;
+				}
+				if (!resume_lv(cmd, lv)) {
+					log_error("Failed to resume pool %s.", lv->name);
+					goto deactivate_and_revert_new_lv;
+				}
+			}
+		}
+	} else if (lv_is_thin_volume(lv)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {
 			if (!suspend_lv_origin(cmd, org)) {
@@ -5731,16 +5769,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				goto revert_new_lv;
 			}
 		}
-		if ((lp->activate != CHANGE_AN) && (lp->activate != CHANGE_ALN)) {
-			/* At this point send message to kernel thin mda */
-			pool_lv = lv_is_thin_pool(lv) ? lv : first_seg(lv)->pool_lv;
-			if (!update_pool_lv(pool_lv, 1)) {
+		if (is_change_activating(lp->activate)) {
+			/* Send message so that table preload knows new thin */
+			if (!update_pool_lv(first_seg(lv)->pool_lv, 1)) {
 				stack;
-				goto deactivate_and_revert_new_lv;
+				goto revert_new_lv;
 			}
 			if (!activate_lv_excl(cmd, lv)) {
-				log_error("Aborting. Failed to activate thin %s.",
-					  lv->name);
+				log_error("Failed to activate thin %s.", lv->name);
 				goto deactivate_and_revert_new_lv;
 			}
 		}
@@ -5838,8 +5874,9 @@ out:
 
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate failed new LV. "
-			  "Manual intervention required.");
+deactivate_failed:
+		log_error("Unable to deactivate failed new LV \"%s/%s\". "
+			  "Manual intervention required.", lv->vg->name, lv->name);
 		return NULL;
 	}
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 8724845..adb0a25 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -473,13 +473,7 @@ int extend_pool(struct logical_volume *pool_lv, const struct segment_type *segty
 		    !set_lv(pool_lv->vg->cmd, pool_lv, UINT64_C(0), 0)) {
 			log_error("Aborting. Failed to wipe pool metadata %s.",
 				  pool_lv->name);
-			return 0;
-		}
-
-		if (!deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
-			log_error("Aborting. Could not deactivate pool metadata %s.",
-				  pool_lv->name);
-			return 0;
+			goto bad;
 		}
 	} else {
 		log_warn("WARNING: Pool %s is created without initialization.", pool_lv->name);


