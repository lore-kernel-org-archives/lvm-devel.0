From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 20 Apr 2017 15:46:21 -0400
Subject: master - raid: define return value on error paths
Message-ID: <201704201946.v3KJkLQ0013091@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d8a63f446e159bbd34292962e4ad9e25ea00cb95
Commit:        d8a63f446e159bbd34292962e4ad9e25ea00cb95
Parent:        5fb571740224a1a7670d20f23c444c602ef5cf85
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 20 21:32:40 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 20 21:32:40 2017 +0200

raid: define return value on error paths

---
 lib/metadata/raid_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9114f60..77ca006 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -530,18 +530,18 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 		 * Returning 2 from pre function -> lv is suspended and
 		 * metadata got updated, don't need to do it again
 		 */
-		if (!(origin_only ? resume_lv_origin(lv->vg->cmd, lv_lock_holder(lv)) :
-				    resume_lv(lv->vg->cmd, lv_lock_holder(lv)))) {
+		if (!(r = (origin_only ? resume_lv_origin(lv->vg->cmd, lv_lock_holder(lv)) :
+					 resume_lv(lv->vg->cmd, lv_lock_holder(lv))))) {
 			log_error("Failed to resume %s.", display_lvname(lv));
 			goto err;
 		}
 
 	/* Update metadata and reload mappings including flags (e.g. LV_REBUILD, LV_RESHAPE_DELTA_DISKS_PLUS) */
-	} else if (!(origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))
+	} else if (!(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))))
 		goto err;
 
 	/* Eliminate any residual LV and don't commit the metadata */
-	if (!_eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0))
+	if (!(r = _eliminate_extracted_lvs_optional_write_vg(lv->vg, removal_lvs, 0)))
 		goto err;
 
 	/*
@@ -554,7 +554,7 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	 * and if successful, performs metadata backup.
 	 */
 	log_debug_metadata("Clearing any flags for %s passed to the kernel.", display_lvname(lv));
-	if (!_reset_flags_passed_to_kernel(lv, &flags_reset))
+	if (!(r = _reset_flags_passed_to_kernel(lv, &flags_reset)))
 		goto err;
 
 	/* Call any @fn_post_on_lv before the second update call (e.g. to rename LVs back) */
@@ -565,7 +565,7 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 
 	/* Update and reload to clear out reset flags in the metadata and in the kernel */
 	log_debug_metadata("Updating metadata mappings for %s.", display_lvname(lv));
-	if ((r != 2 || flags_reset) && !(origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv))) {
+	if ((r != 2 || flags_reset) && !(r = (origin_only ? lv_update_and_reload_origin(lv) : lv_update_and_reload(lv)))) {
 		log_error(INTERNAL_ERROR "Update of LV %s failed.", display_lvname(lv));
 		goto err;
 	}


