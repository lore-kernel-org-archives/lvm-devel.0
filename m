From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Oct 2011 18:28:28 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20111003182828.1779.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-03 18:28:26

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Update error path tracing for _resume_node
	
	dm_task_create & dm_task_set_name produces it's own log_error
	Add missing stacks for dm_task_set_cookie, dm_task_run,
	dm_task_get_info.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.508&r2=1.509
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/WHATS_NEW_DM	2011/09/29 08:53:48	1.508
+++ LVM2/WHATS_NEW_DM	2011/10/03 18:28:25	1.509
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Update debug logging for _resume_node.
   Add functions to support thin provisioning target (API unstable).
   Improve libdm-config error path reporting.
   Update dmsetup resume man with --addnodeonresume/create options.
--- LVM2/libdm/libdm-deptree.c	2011/10/03 18:26:07	1.116
+++ LVM2/libdm/libdm-deptree.c	2011/10/03 18:28:25	1.117
@@ -1127,13 +1127,13 @@
 	log_verbose("Resuming %s (%" PRIu32 ":%" PRIu32 ")", name, major, minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RESUME))) {
-		log_error("Suspend dm_task creation failed for %s", name);
+		log_debug("Suspend dm_task creation failed for %s.", name);
 		return 0;
 	}
 
 	/* FIXME Kernel should fill in name on return instead */
 	if (!dm_task_set_name(dmt, name)) {
-		log_error("Failed to set readahead device name for %s", name);
+		log_debug("Failed to set device name for %s resumption.", name);
 		goto out;
 	}
 
@@ -1149,13 +1149,16 @@
 		log_error("Failed to set read ahead");
 
 	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
-		goto out;
+		goto_out;
 
-	if ((r = dm_task_run(dmt))) {
-		if (already_suspended)
-			dec_suspended();
-		r = dm_task_get_info(dmt, newinfo);
-	}
+	if (!(r = dm_task_run(dmt)))
+		goto_out;
+
+	if (already_suspended)
+		dec_suspended();
+
+	if (!(r = dm_task_get_info(dmt, newinfo)))
+		stack;
 
 out:
 	dm_task_destroy(dmt);


