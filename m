From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 12 Aug 2010 17:30:57 -0500
Subject: [PATCH] Bug 612291: Fix splitmirrors in cluster.
Message-ID: <1281652261.16190.5.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM commands were reporting expected results, but DM devices where not
being renamed on remote nodes ('remote' WRT the node issuing the
'lvconvert --splitmirrors' command).  This could cause problems more
severe than just naming issues when the number of images split from a
mirror was greater than 1 (like the newly split mirror never activating
on the remote nodes).

 brassow

Fix for bug 612291: dm devices of split off mirror images are not removed

DM devices were not handled properly on nodes in a cluster that were not
where the splitmirrors command was issued.  This was happening because
suspend_lv/resume_lv were being used in a place where activate_lv should
have been used.

When the suspend/resume are issued on (effectively) new LVs, their
'resource' (UUID) is not located in the lv_hash.  Thus, both operations
turn into no-ops.  You can see this from the output of clvmd from one
of the remote nodes:
<snip>
CLVMD[3c7ed710]: Aug 12 17:01:44 do_suspend_lv, lock not already held
<snip>
CLVMD[3c7ed710]: Aug 12 17:02:03 do_resume_lv, lock not already held

'activate_lv' enjoins the other nodes in the cluster to process the lock
and activate the new LV.  clvmd output from remote node as follows:
CLVMD[776e5710]: Aug 12 16:53:21 do_lock_lv: resource 'zMseY7CBuO3Ty09vXlplPAHzD0Y0CovjrTdv0R1VcwggMwPdYhutHErRcwm5Nd2S', cmd = 0x19 LCK_LV_ACTIVATE (READ|LV|NONBLOCK), flags = 0x84 (DMEVENTD_MONITOR ), memlock = 1
CLVMD[776e5710]: Aug 12 16:53:21 sync_lock: 'zMseY7CBuO3Ty09vXlplPAHzD0Y0CovjrTdv0R1VcwggMwPdYhutHErRcwm5Nd2S' mode:1 flags=1
CLVMD[776e5710]: Aug 12 16:53:21 sync_lock: returning lkid 27b0001


Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -719,19 +719,8 @@ static int _split_mirror_images(struct l
 		return 0;
 	}
 
-	/*
-	 * Suspend the newly split-off LV (balance memlock count
-	 * and prepare for DM automated renaming via resume).
-	 */
-	if (!suspend_lv(lv->vg->cmd, new_lv)) {
-		log_error("Failed to lock newly split LV, %s", new_lv->name);
-		vg_revert(lv->vg);
-		return 0;
-	}
-
 	/* Bring newly split-off LV into existence */
-	log_very_verbose("Creating %s", new_lv->name);
-	if (!resume_lv(lv->vg->cmd, new_lv)) {
+	if (!activate_lv(lv->vg->cmd, new_lv)) {
 		log_error("Failed to activate newly split LV, %s",
 			  new_lv->name);
 		return 0;



