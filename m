From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:10 -0500
Subject: master - pvmove: finish no longer needs explicit resumed
Message-ID: <201711241511.vAOFBAwt000396@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=16ef133be2a6aaa0d16078326e739d19eaf5f66b
Commit:        16ef133be2a6aaa0d16078326e739d19eaf5f66b
Parent:        2a6981a6976368f633942a13cf007b141b2ece0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 14:00:22 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

pvmove: finish no longer needs explicit resumed

Activation code can see from holders needed LVs for resume.
---
 tools/pvmove_poll.c |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 36c2d0c..982bf96 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -92,10 +92,6 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed)
 {
-	struct lv_list *lvl;
-	struct logical_volume *holder;
-	int r = 1;
-
 	if (!dm_list_empty(lvs_changed) &&
 	    (!_detach_pvmove_mirror(cmd, lv_mirr) ||
 	    !replace_lv_with_error_segment(lv_mirr))) {
@@ -106,19 +102,6 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 	if (!lv_update_and_reload(lv_mirr))
 		return_0;
 
-	/* Takes locks and resumed volumes (should be still suspended, but preloaded) */
-	dm_list_iterate_items(lvl, lvs_changed) {
-		holder = (struct logical_volume *) lv_lock_holder(lvl->lv);
-		if (!resume_lv(cmd, holder)) {
-			log_error("Failed to reactivate logical volume %s.",
-				  display_lvname(holder));
-			r = 0; /* But try to resume as much as we can */
-		}
-	}
-
-	if (!r)
-		return 0;
-
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
 		log_error("ABORTING: Unable to deactivate temporary logical "


