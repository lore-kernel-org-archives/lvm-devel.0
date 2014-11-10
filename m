From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:19 +0000 (UTC)
Subject: master - snapshot: virtual save commit
Message-ID: <20141110210619.3BF0A608F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a41286c012e8a15a41f0d807c0cb62de7f515b3
Commit:        6a41286c012e8a15a41f0d807c0cb62de7f515b3
Parent:        ff30783a4f44c823544133260acb8c5171fbd0a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 5 15:15:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

snapshot: virtual save commit

More efficient spare volume creation. Save 1 extra commit
and properly activate this volume according to our cluster
activation rules (using lv_active_change() for this).
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   83 ++++++++++++++++++++++++-----------------------
 2 files changed, 43 insertions(+), 41 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f70c657..616d1b0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Reduce vg write and vg commits when creating spare volumes.
   When remove_layer_from_lv() removes layer, restore subLV names.
   Cache-pool in use becomes invisible LV.
   Don't prompt for removal of _pmspare in VG without pool metadata LV.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 99ed6d1..d664453 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6434,12 +6434,6 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 		       NULL, ALLOC_INHERIT, 0))
 		return_NULL;
 
-	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg))
-		return_NULL;
-
-	backup(vg);
-
 	return lv;
 }
 
@@ -7084,11 +7078,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			}
 		}
 	} else if (lp->snapshot) {
+		lv->status |= LV_TEMPORARY;
 		if (!activate_lv_local(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
 				  "exception store.");
 			goto revert_new_lv;
 		}
+		lv->status &= ~LV_TEMPORARY;
 	} else if (!lv_active_change(cmd, lv, lp->activate, 0)) {
 		log_error("Failed to activate new LV.");
 		goto deactivate_and_revert_new_lv;
@@ -7132,41 +7128,25 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL; /* FIXME: revert */
 		}
 	} else if (lp->snapshot) {
+		/* Deactivate zeroed COW, avoid any race usage */
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Aborting. Couldn't deactivate snapshot COW area %s.",
+				  display_lvname(lv));
+			goto deactivate_and_revert_new_lv; /* Let's retry on error path */
+		}
+
+		/* Create zero origin volume for spare snapshot */
+		if (lp->virtual_extents &&
+		    !(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
+							 lp->permission,
+							 lp->virtual_extents)))
+			goto revert_new_lv;
+
 		/* Reset permission after zeroing */
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
 
 		/*
-		 * For clustered VG deactivate zeroed COW to not keep
-		 * the LV lock. For non-clustered VG, deactivate
-		 * if origin is real (not virtual) inactive device.
-		 */
-		if ((vg_is_clustered(vg) ||
-		     (!lp->virtual_extents && !lv_is_active(origin_lv))) &&
-		    !deactivate_lv(cmd, lv)) {
-			log_error("Aborting. Couldn't deactivate snapshot COW area. "
-				  "Manual intervention required.");
-			return NULL;
-		}
-
-		/* A virtual origin must be activated explicitly. */
-		if (lp->virtual_extents) {
-			if (!(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
-								 lp->permission,
-								 lp->virtual_extents))) {
-				stack;
-				goto deactivate_and_revert_new_lv;
-			}
-			if (!activate_lv_excl(cmd, origin_lv)) {
-				log_error("Couldn't get exclusive lock for virtual origin LV %s",
-					  lv->name);
-				if (!lv_remove(origin_lv))
-					stack;
-				goto deactivate_and_revert_new_lv;
-			}
-		}
-
-		/*
 		 * COW LV is activated via implicit activation of origin LV
 		 * Only the snapshot origin holds the LV lock in cluster
 		 */
@@ -7176,17 +7156,38 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			goto deactivate_and_revert_new_lv;
 		}
 
-		/* store vg on disk(s) */
-		if (!lv_update_and_reload(origin_lv))
-			return_NULL;
+		if (lp->virtual_extents) {
+			/* Store vg on disk(s) */
+			if (!vg_write(vg) || !vg_commit(vg))
+				return_NULL; /* Metadata update fails, deep troubles */
+
+			backup(vg);
+			/*
+			 * TODO:
+			 *   We do not actually need snapshot-origin as an active device,
+			 *   as virtual origin is already 'hidden' private device without
+			 *   vg/lv links. As such it is not supposed to be used by any user.
+			 *   Also it would save one dm table entry, but it needs quite a few
+			 *   changes in the libdm/lvm2 code base to support it.
+			 */
+			/* Activate spare snapshot once it is a complete LV */
+			if (!lv_active_change(cmd, origin_lv, lp->activate, 1)) {
+				log_error("Failed to activate sparce volume %s.",
+					  display_lvname(origin_lv));
+				return NULL;
+			}
+		} else if (!lv_update_and_reload(origin_lv)) {
+			log_error("Aborting. Manual intervention required.");
+			return NULL; /* FIXME: revert */
+		}
 	}
 out:
 	return lv;
 
 deactivate_and_revert_new_lv:
 	if (!deactivate_lv(cmd, lv)) {
-		log_error("Unable to deactivate failed new LV \"%s/%s\". "
-			  "Manual intervention required.", lv->vg->name, lv->name);
+		log_error("Unable to deactivate failed new LV %s. "
+			  "Manual intervention required.",  display_lvname(lv));
 		return NULL;
 	}
 


