From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2011 17:29:34 -0000
Subject: LVM2 ./WHATS_NEW tools/pvmove.c
Message-ID: <20110927172934.27589.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-27 17:29:34

Modified files:
	.              : WHATS_NEW 
	tools          : pvmove.c 

Log message:
	Replace incomplete pvmove activation failure recovery code with a message.
	
	As it stands, the recovery code can make things worse sometimes so it's
	better to insist on a proper 'pvmove --abort' cleanup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2141&r2=1.2142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/WHATS_NEW	2011/09/27 17:09:42	1.2141
+++ LVM2/WHATS_NEW	2011/09/27 17:29:33	1.2142
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Replace incomplete pvmove activation failure recovery code with a message.
   Abort if _finish_pvmove suspend_lvs fails instead of cleaning up incompletely.
   Change suspend_lvs to call vg_revert internally.
   Change vg_revert to void and remove superfluous calls after failed vg_commit.
--- LVM2/tools/pvmove.c	2011/09/27 17:09:43	1.88
+++ LVM2/tools/pvmove.c	2011/09/27 17:29:33	1.89
@@ -390,22 +390,9 @@
 			}
 
 			/*
-			 * Nothing changed yet, try to revert pvmove.
-			 * FIXME This error path is incomplete and unsafe.
+			 * FIXME Run --abort internally here.
 			 */
-			log_error("Temporary pvmove mirror activation failed.");
-
-			/* Ensure that temporary mrror is deactivate even on other nodes. */
-			/* FIXME Unsafe to proceed if this fails without checking explicitly that no pvmove LVs are still active */
-			(void)deactivate_lv(cmd, lv_mirr);
-
-			/* Revert metadata */
-			/* FIXME Use --abort code instead? */
-			if (!_detach_pvmove_mirror(cmd, lv_mirr) ||
-			    !lv_remove(lv_mirr) ||
-			    !vg_write(vg) || !vg_commit(vg))
-				log_error("ABORTING: Restoring original configuration "
-					  "before pvmove failed. Run pvmove --abort.");
+			log_error("ABORTING: Temporary pvmove mirror activation failed. Run pvmove --abort.");
 			goto_out;
 		}
 	}


