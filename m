From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:52 +0000 (UTC)
Subject: master - cleanup: use lv_update_and_reload
Message-ID: <20161123165552.9415960F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a4dfe6ce7f44e2996e48fa0dd7dfd98680cae86
Commit:        8a4dfe6ce7f44e2996e48fa0dd7dfd98680cae86
Parent:        a04b4bb89ef79ebaf44804f9230f8ee8c652eb7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 10:57:36 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:53:44 2016 +0100

cleanup: use lv_update_and_reload

Avoid code duplication and use exiting commonly used
lv_update_and_reload() function.

There is still one place left where mirror is doing strange
double suspend call - needs there more thinking what's wrong with
that code.
---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |   56 ++++--------------------------------------------
 2 files changed, 6 insertions(+), 51 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 40a9ef4..2f96ece 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Use lv_update_and_reload() inside mirror code where it applies.
   Preserve mirrored status for temporary layered mirrors.
   Use transient raid check before repairing raid volume.
   Implement transient status check for raid volumes.
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index f5a3676..baa19fa 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -798,36 +798,12 @@ static int _split_mirror_images(struct logical_volume *lv,
 		lv->status &= ~LV_NOTSYNCED;
 	}
 
-	if (!vg_write(mirrored_seg->lv->vg)) {
-		log_error("Intermediate VG metadata write failed.");
-		return 0;
-	}
-
 	/*
-	 * Suspend the mirror - this includes all the sub-LVs and
-	 *                      soon-to-be-split sub-LVs
+	 * Suspend and resume the mirror - this includes all
+	 * the sub-LVs and soon-to-be-split sub-LVs
 	 */
-	if (!suspend_lv(cmd, mirrored_seg->lv)) {
-		log_error("Failed to lock %s", mirrored_seg->lv->name);
-		vg_revert(mirrored_seg->lv->vg);
-		return 0;
-	}
-
-	if (!vg_commit(mirrored_seg->lv->vg)) {
-		resume_lv(cmd, mirrored_seg->lv);
-		return 0;
-	}
-
-	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
-
-	/*
-	 * Resume the mirror - this also activates the visible, independent
-	 *                     soon-to-be-split sub-LVs
-	 */
-	if (!resume_lv(cmd, mirrored_seg->lv)) {
-		log_error("Problem resuming %s", mirrored_seg->lv->name);
-		return 0;
-	}
+	if (!lv_update_and_reload(mirrored_seg->lv))
+		return_0;
 
 	/*
 	 * Recycle newly split LV so it is properly renamed.
@@ -1062,30 +1038,8 @@ static int _remove_mirror_images(struct logical_volume *lv,
 			return 0;
 		}
 
-		if (!vg_write(detached_log_lv->vg)) {
-			log_error("intermediate VG write failed.");
-			return 0;
-		}
-
-		if (!suspend_lv(detached_log_lv->vg->cmd,
-				detached_log_lv)) {
-			log_error("Failed to suspend %s",
-				  detached_log_lv->name);
-			return 0;
- 		}
-
-		if (!vg_commit(detached_log_lv->vg)) {
-			if (!resume_lv(detached_log_lv->vg->cmd,
-				       detached_log_lv))
-				stack;
+		if (!lv_update_and_reload(detached_log_lv))
 			return_0;
-		}
-
-		if (!resume_lv(detached_log_lv->vg->cmd, detached_log_lv)) {
-			log_error("Failed to resume %s",
-				  detached_log_lv->name);
-			return 0;
-		}
 	}
 
 	/*


