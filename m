From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:48 -0500
Subject: master - pvmove: change locking on finish
Message-ID: <201711151309.vAFD9mhU002025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a25f9b210692fe5cd164441b76a78b11fb4ee4e5
Commit:        a25f9b210692fe5cd164441b76a78b11fb4ee4e5
Parent:        9d04ecc7b3574efb1772e84e8796b7044b830220
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 14 20:53:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 14:07:00 2017 +0100

pvmove: change locking on finish

---
 WHATS_NEW           |    1 +
 tools/pvmove_poll.c |   49 +++++++++++++++----------------------------------
 2 files changed, 16 insertions(+), 34 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 728cc4f..b1454a3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Ehnance pvmove locking.
   Deactivate activated LVs on error path when pvmove activation fails.
   Add "io" to log/debug_classes for logging low-level I/O.
   Eliminate redundant nested VG metadata in VG struct.
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 5bddee4..36c2d0c 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -92,6 +92,8 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		  struct logical_volume *lv_mirr, struct dm_list *lvs_changed)
 {
+	struct lv_list *lvl;
+	struct logical_volume *holder;
 	int r = 1;
 
 	if (!dm_list_empty(lvs_changed) &&
@@ -101,48 +103,27 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	/* Store metadata without dependencies on mirror segments */
-	if (!vg_write(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
-			  "to disk.");
-		return 0;
-	}
+	if (!lv_update_and_reload(lv_mirr))
+		return_0;
 
-	/* Suspend LVs changed (implicitly suspends lv_mirr) */
-	if (!suspend_lvs(cmd, lvs_changed, vg)) {
-		log_error("ABORTING: Locking LVs to remove temporary mirror failed");
-		if (!revert_lv(cmd, lv_mirr))
-			stack;
-		return 0;
+	/* Takes locks and resumed volumes (should be still suspended, but preloaded) */
+	dm_list_iterate_items(lvl, lvs_changed) {
+		holder = (struct logical_volume *) lv_lock_holder(lvl->lv);
+		if (!resume_lv(cmd, holder)) {
+			log_error("Failed to reactivate logical volume %s.",
+				  display_lvname(holder));
+			r = 0; /* But try to resume as much as we can */
+		}
 	}
 
-	/* Store metadata without dependencies on mirror segments */
-	if (!vg_commit(vg)) {
-		log_error("ABORTING: Failed to write new data locations "
-			  "to disk.");
-		if (!revert_lv(cmd, lv_mirr))
-			stack;
-		if (!revert_lvs(cmd, lvs_changed))
-			stack;
+	if (!r)
 		return 0;
-	}
-
-	/* Unsuspend LVs */
-	if (!resume_lvs(cmd, lvs_changed))
-		stack;
-
-	/* Release mirror LV.  (No pending I/O because it's been suspended.) */
-	if (!activate_lv_excl_local(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\"",
-			  lv_mirr->name);
-		r = 0;
-	}
 
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
 		log_error("ABORTING: Unable to deactivate temporary logical "
 			  "volume %s.", display_lvname(lv_mirr));
-		r = 0;
+		return 0;
 	}
 
 	log_verbose("Removing temporary pvmove LV");
@@ -162,5 +143,5 @@ int pvmove_finish(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME backup positioning */
 	backup(vg);
 
-	return r;
+	return 1;
 }


