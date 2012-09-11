From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 11 Sep 2012 18:11:33 +0000 (UTC)
Subject: master - cleanup: Reduce indentation by short-circuiting function
Message-ID: <20120911181133.674672364@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05131f5853e86419d9c726faa961b8d012298d9c
Commit:        05131f5853e86419d9c726faa961b8d012298d9c
Parent:        cdb0339319c89b8d1e5611537e9775a8c3ce5844
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 11 12:55:17 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 11 12:55:17 2012 -0500

cleanup:  Reduce indentation by short-circuiting function

By changing the conditional for resyncing mirrors with core-logs a
bit, we can short-circuit the rest of the function for that case
and reduce the amount of indenting in the rest of the function.

This cleanup will simplify future patches aimed at properly handling
the resync of RAID LVs.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |   98 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 56 insertions(+), 43 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8718a0b..c0b84ab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Disallow addition of RAID images until the array is in-sync.
   Fix RAID LV creation with '--test' so valid commands do not fail.
   Add lvm_lv_rename() to lvm2api.
   Fix setvbuf code by closing and reopening stream before changing buffer.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1f32d5c..cbdb353 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -335,67 +335,79 @@ static int lvchange_resync(struct cmd_context *cmd,
 	 * it to reset the sync status.  We only need to
 	 * worry about persistent logs.
 	 */
-	if (!log_lv && !(lv->status & LV_NOTSYNCED)) {
+	if (!log_lv) {
+		if (!(lv->status & LV_NOTSYNCED)) {
+			lv->status &= ~LV_NOTSYNCED;
+			log_very_verbose("Updating logical volume \"%s\""
+					 " on disk(s)", lv->name);
+			if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+				log_error("Failed to update metadata on disk.");
+				return 0;
+			}
+		}
+
 		if (active && !activate_lv(cmd, lv)) {
 			log_error("Failed to reactivate %s to resynchronize "
 				  "mirror", lv->name);
 			return 0;
 		}
+
 		return 1;
 	}
 
+	/*
+	 * Now we handle mirrors with log devices
+	 */
 	lv->status &= ~LV_NOTSYNCED;
 
-	if (log_lv) {
-		/* Separate mirror log so we can clear it */
-		detach_mirror_log(first_seg(lv));
-
-		if (!vg_write(lv->vg)) {
-			log_error("Failed to write intermediate VG metadata.");
-			if (!attach_mirror_log(first_seg(lv), log_lv))
-				stack;
-			if (active && !activate_lv(cmd, lv))
-				stack;
-			return 0;
-		}
+	/* Separate mirror log so we can clear it */
+	detach_mirror_log(first_seg(lv));
 
-		if (!vg_commit(lv->vg)) {
-			log_error("Failed to commit intermediate VG metadata.");
-			if (!attach_mirror_log(first_seg(lv), log_lv))
-				stack;
-			if (active && !activate_lv(cmd, lv))
-				stack;
-			return 0;
-		}
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write intermediate VG metadata.");
+		if (!attach_mirror_log(first_seg(lv), log_lv))
+			stack;
+		if (active && !activate_lv(cmd, lv))
+			stack;
+		return 0;
+	}
 
-		backup(lv->vg);
+	if (!vg_commit(lv->vg)) {
+		log_error("Failed to commit intermediate VG metadata.");
+		if (!attach_mirror_log(first_seg(lv), log_lv))
+			stack;
+		if (active && !activate_lv(cmd, lv))
+			stack;
+		return 0;
+	}
 
-		if (!activate_lv(cmd, log_lv)) {
-			log_error("Unable to activate %s for mirror log resync",
-				  log_lv->name);
-			return 0;
-		}
+	backup(lv->vg);
 
-		log_very_verbose("Clearing log device %s", log_lv->name);
-		if (!set_lv(cmd, log_lv, log_lv->size, 0)) {
-			log_error("Unable to reset sync status for %s", lv->name);
-			if (!deactivate_lv(cmd, log_lv))
-				log_error("Failed to deactivate log LV after "
-					  "wiping failed");
-			return 0;
-		}
+	if (!activate_lv(cmd, log_lv)) {
+		log_error("Unable to activate %s for mirror log resync",
+			  log_lv->name);
+		return 0;
+	}
 
-		if (!deactivate_lv(cmd, log_lv)) {
-			log_error("Unable to deactivate log LV %s after wiping "
-				  "for resync", log_lv->name);
-			return 0;
-		}
+	log_very_verbose("Clearing log device %s", log_lv->name);
+	if (!set_lv(cmd, log_lv, log_lv->size, 0)) {
+		log_error("Unable to reset sync status for %s", lv->name);
+		if (!deactivate_lv(cmd, log_lv))
+			log_error("Failed to deactivate log LV after "
+				  "wiping failed");
+		return 0;
+	}
 
-		/* Put mirror log back in place */
-		if (!attach_mirror_log(first_seg(lv), log_lv))
-			stack;
+	if (!deactivate_lv(cmd, log_lv)) {
+		log_error("Unable to deactivate log LV %s after wiping "
+			  "for resync", log_lv->name);
+		return 0;
 	}
 
+	/* Put mirror log back in place */
+	if (!attach_mirror_log(first_seg(lv), log_lv))
+		stack;
+
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
 		log_error("Failed to update metadata on disk.");


