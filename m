From: agk@sourceware.org <agk@sourceware.org>
Date: 15 May 2012 21:27:28 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20120515212728.12186.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-15 21:27:25

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Set delay_resume_if_new on deptree snapshot origin.
	(Must avoid activating snapshot origin more than once concurrently.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.601&r2=1.602
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/WHATS_NEW_DM	2012/05/08 14:31:44	1.601
+++ LVM2/WHATS_NEW_DM	2012/05/15 21:27:24	1.602
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Set delay_resume_if_new on deptree snapshot origin.
   Log value chosen in _find_config_bool like other variable types do.
   Synchronize with dead of dmeventd.
   Rename (Blk)DevNames/DevNos dmsetup header to (Blk)DevNamesUsed/DevNosUsed.
--- LVM2/libdm/libdm-deptree.c	2012/05/15 20:03:12	1.165
+++ LVM2/libdm/libdm-deptree.c	2012/05/15 21:27:24	1.166
@@ -2358,8 +2358,10 @@
 	if ((r = dm_task_run(dmt))) {
 		r = dm_task_get_info(dmt, &dnode->info);
 		if (r && !dnode->info.inactive_table)
-			log_verbose("Suppressed %s identical table reload.",
-				    dnode->name);
+			log_verbose("Suppressed %s (%" PRIu32 ":%" PRIu32
+				    ") identical table reload.",
+				    dnode->name,
+				    dnode->info.major, dnode->info.minor);
 
 		existing_table_size = dm_task_get_existing_table_size(dmt);
 		if ((dnode->props.size_changed =
@@ -2548,6 +2550,12 @@
 	/* Resume snapshot origins after new snapshots */
 	dnode->activation_priority = 1;
 
+	/*
+	 * Don't resume the origin immediately in case it is a non-trivial 
+	 * target that must not be active more than once concurrently!
+	 */
+	origin_node->props.delay_resume_if_new = 1;
+
 	return 1;
 }
 


