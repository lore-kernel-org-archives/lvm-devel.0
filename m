From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:40:22 -0000
Subject: LVM2 ./WHATS_NEW libdm/ioctl/libdm-iface.c
Message-ID: <20101130224022.26776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:40:20

Modified files:
	.              : WHATS_NEW 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add stack trace for error path
	
	If dm_task_set_cookie() fails print stack trace, but keep going on.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1817&r2=1.1818
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/WHATS_NEW	2010/11/30 22:23:35	1.1817
+++ LVM2/WHATS_NEW	2010/11/30 22:40:19	1.1818
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Add error path stack traces for _process_mapper_dir(), _create_and_load_v4().
   Add missing test for failed pool allocation in write_config_node().
   Replace snprintf with dm_snprintf in clvmd-command.c.
   Check reallocated buffer for NULL before use in clvmd do_command().
--- LVM2/libdm/ioctl/libdm-iface.c	2010/11/30 22:32:44	1.84
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/11/30 22:40:20	1.85
@@ -1779,9 +1779,10 @@
 	if (dmt->cookie_set) {
 		cookie = (dmt->event_nr & ~DM_UDEV_FLAGS_MASK) |
 			 (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
-		dm_task_set_cookie(dmt, &cookie,
-				   (dmt->event_nr & DM_UDEV_FLAGS_MASK) >>
-				    DM_UDEV_FLAGS_SHIFT);
+		if (!dm_task_set_cookie(dmt, &cookie,
+					(dmt->event_nr & DM_UDEV_FLAGS_MASK) >>
+					DM_UDEV_FLAGS_SHIFT))
+                        stack; /* keep going */
 	}
 
 	if (!dm_task_run(dmt))


