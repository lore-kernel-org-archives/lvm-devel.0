From: agk@sourceware.org <agk@sourceware.org>
Date: 15 May 2012 14:10:55 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20120515141055.9422.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-15 14:10:54

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	indicate when deptree detects but ignores size change in debug msg

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164

--- LVM2/libdm/libdm-deptree.c	2012/03/04 17:36:24	1.163
+++ LVM2/libdm/libdm-deptree.c	2012/05/15 14:10:54	1.164
@@ -2364,9 +2364,6 @@
 		existing_table_size = dm_task_get_existing_table_size(dmt);
 		if ((dnode->props.size_changed =
 		     (existing_table_size == seg_start) ? 0 : 1)) {
-			log_debug("Table size changed from %" PRIu64 " to %"
-				  PRIu64 " for %s", existing_table_size,
-				  seg_start, dnode->name);
 			/*
 			 * Kernel usually skips size validation on zero-length devices
 			 * now so no need to preload them.
@@ -2374,6 +2371,11 @@
 			/* FIXME In which kernel version did this begin? */
 			if (!existing_table_size && dnode->props.delay_resume_if_new)
 				dnode->props.size_changed = 0;
+
+			log_debug("Table size changed from %" PRIu64 " to %"
+				  PRIu64 " for %s.%s", existing_table_size,
+				  seg_start, dnode->name,
+				  dnode->props.size_changed ? "" : " (Ignoring.)");
 		}
 	}
 


