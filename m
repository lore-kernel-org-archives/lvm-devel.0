From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Jun 2011 12:56:02 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20110622125602.21718.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-22 12:56:02

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Add check for library fallback in _deactivate_node.
	
	This fn calls rm_dev_node directly - an exceptional case. It needs to check
	the DM_UDEV_DISABLE_LIBRARY_FALLBACK flag directly (it's called in dm_task_run
	normally where it's checked already).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/libdm/libdm-deptree.c	2011/06/13 03:32:46	1.96
+++ LVM2/libdm/libdm-deptree.c	2011/06/22 12:56:02	1.97
@@ -984,8 +984,9 @@
 	r = dm_task_run(dmt);
 
 	/* FIXME Until kernel returns actual name so dm-ioctl.c can handle it */
-	rm_dev_node(name, dmt->cookie_set &&
-			  !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG));
+	if (!(udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK))
+		rm_dev_node(name, dmt->cookie_set &&
+				  !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG));
 
 	/* FIXME Remove node from tree or mark invalid? */
 


