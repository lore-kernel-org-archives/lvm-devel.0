From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Sep 2011 16:36:40 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20110921163640.16609.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-21 16:36:39

Modified files:
	tools          : pvmove.c 

Log message:
	FIXMEs to note problems with some error paths.  (Perhaps safer to disable
	them until they can be fixed completely?)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/tools/pvmove.c	2011/08/30 14:55:19	1.86
+++ LVM2/tools/pvmove.c	2011/09/21 16:36:39	1.87
@@ -365,6 +365,7 @@
 	}
 
 	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed)) {
+		/* FIXME vg_revert must be moved *before* any LV resumes */
 		vg_revert(vg);
 		goto_out;
 	}
@@ -388,13 +389,16 @@
 
 			/*
 			 * Nothing changed yet, try to revert pvmove.
+			 * FIXME This error path is incomplete and unsafe.
 			 */
 			log_error("Temporary pvmove mirror activation failed.");
 
 			/* Ensure that temporary mrror is deactivate even on other nodes. */
+			/* FIXME Unsafe to proceed if this fails without checking explicitly that no pvmove LVs are still active */
 			(void)deactivate_lv(cmd, lv_mirr);
 
 			/* Revert metadata */
+			/* FIXME Use --abort code instead? */
 			if (!_detach_pvmove_mirror(cmd, lv_mirr) ||
 			    !lv_remove(lv_mirr) ||
 			    !vg_write(vg) || !vg_commit(vg))


