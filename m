From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:01 -0500
Subject: master - mirror: use lv_update_and_reload_origin
Message-ID: <201711241511.vAOFB1F3000372@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddbe763eb81c5f9608ca9ff192bd33d9d37acd77
Commit:        ddbe763eb81c5f9608ca9ff192bd33d9d37acd77
Parent:        aa68b898ff9c51dcbd87c6be34632e33f0299a18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 13:58:23 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:05:21 2017 +0100

mirror: use lv_update_and_reload_origin

Replace complex code with standard lv_update_and_reload_origin().
Extra suspend should not be necessary.
(If they would be - dependency tree would have bug for fixing).
---
 lib/metadata/mirror.c |   44 +-------------------------------------------
 1 files changed, 1 insertions(+), 43 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c89408c..327ce99 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1038,50 +1038,8 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	 * remove the LVs from the mirror set, commit that metadata
 	 * then deactivate and remove them fully.
 	 */
-	if (!vg_write(mirrored_seg->lv->vg)) {
-		log_error("intermediate VG write failed.");
-		return 0;
-	}
-
-	if (!suspend_lv_origin(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Failed to lock %s.", display_lvname(mirrored_seg->lv));
-		vg_revert(mirrored_seg->lv->vg);
-		return 0;
-	}
-
-	/* FIXME: second suspend should not be needed
-	 * Explicitly suspend temporary LV.
-	 * This balances critical_section_inc() calls with critical_section_dec()
-	 * in resume (both local and cluster) and also properly propagates precommitted
-	 * metadata into dm table on other nodes.
-	 * FIXME: check propagation of suspend with visible flag
-	 */
-	if (temp_layer_lv && !suspend_lv(temp_layer_lv->vg->cmd, temp_layer_lv))
-		log_error("Problem suspending temporary LV %s.", display_lvname(temp_layer_lv));
-
-	if (!vg_commit(mirrored_seg->lv->vg)) {
-		if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv))
-			stack;
+	if (!lv_update_and_reload_origin(mirrored_seg->lv))
 		return_0;
-	}
-
-	log_very_verbose("Updating %s in kernel.", display_lvname(mirrored_seg->lv));
-
-	/*
-	 * Avoid having same mirror target loaded twice simultaneously by first
-	 * resuming the removed LV which now contains an error segment.
-	 * As it's now detached from mirrored_seg->lv we must resume it
-	 * explicitly.
-	 */
-	if (temp_layer_lv && !resume_lv(temp_layer_lv->vg->cmd, temp_layer_lv)) {
-		log_error("Problem resuming temporary LV %s.", display_lvname(temp_layer_lv));
-		return 0;
-	}
-
-	if (!resume_lv_origin(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
-		log_error("Problem reactivating %s.", display_lvname(mirrored_seg->lv));
-		return 0;
-	}
 
 	/* Save or delete the 'orphan' LVs */
 	reactivate = lv_is_active(lv_lock_holder(lv));


