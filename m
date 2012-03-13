From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Mar 2012 20:21:31 -0000
Subject: LVM2 ./WHATS_NEW tools/pvmove.c
Message-ID: <20120313202131.20353.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-13 20:21:28

Modified files:
	.              : WHATS_NEW 
	tools          : pvmove.c 

Log message:
	Fix error message when pvmove LV activation fails with name already in use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2352&r2=1.2353
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2012/03/12 14:40:41	1.2352
+++ LVM2/WHATS_NEW	2012/03/13 20:21:26	1.2353
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix error message when pvmove LV activation fails with name already in use.
   Better structure layout for device_info in dev_subsystem_name().
   Change message severity for creation of VG over uninitialised devices.
   Fix error path for failing toolcontext creation.
--- LVM2/tools/pvmove.c	2012/02/28 14:24:58	1.93
+++ LVM2/tools/pvmove.c	2012/03/13 20:21:27	1.94
@@ -369,7 +369,7 @@
 	}
 
 	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
-		log_error("ABORTING: Volume group metadata update failed. (first_time: %d)", first_time);
+		log_error("ABORTING: Temporary pvmove mirror %s failed.", first_time ? "activation" : "reload");
 		/* FIXME Add a recovery path for first time too. */
 		if (!first_time && !revert_lv(cmd, lv_mirr))
 			stack;


