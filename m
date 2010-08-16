From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 16 Aug 2010 18:02:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100816180216.19180.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-16 18:02:15

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
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
	do_suspend_lv, lock not already held
	<snip>
	do_resume_lv, lock not already held
	
	'activate_lv' enjoins the other nodes in the cluster to process the lock
	and activate the new LV.  clvmd output from remote node as follows:
	do_lock_lv: resource 'zMseY7CBuO3Ty09vXlplPAHzD0Y0CovjrTdv0R1VcwggMwPdYhutHErRcwm5Nd2S', cmd = 0x19 LCK_LV_ACTIVATE (READ|LV|NONBLOCK), flags = 0x84 (DMEVENTD_MONITOR ), memlock = 1
	sync_lock: 'zMseY7CBuO3Ty09vXlplPAHzD0Y0CovjrTdv0R1VcwggMwPdYhutHErRcwm5Nd2S' mode:1 flags=1
	sync_lock: returning lkid 27b0001
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1702&r2=1.1703
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW	2010/08/12 09:14:59	1.1702
+++ LVM2/WHATS_NEW	2010/08/16 18:02:14	1.1703
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix 'lvconvert --splitmirrors' in cluster operation.
   Fix clvmd init script exit code when executed as non-root user.
   Change default alignment of pe_start to 1MB.
   Add --norestorefile option to pvcreate.
--- LVM2/lib/metadata/mirror.c	2010/08/06 15:38:32	1.131
+++ LVM2/lib/metadata/mirror.c	2010/08/16 18:02:14	1.132
@@ -719,19 +719,8 @@
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


