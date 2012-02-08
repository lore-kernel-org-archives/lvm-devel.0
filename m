From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:07:18 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20120208110718.28491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:07:17

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Fix fd resource leak in error path
	
	Use 'goto bad' to cleanup fd on error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.539&r2=1.540
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/WHATS_NEW_DM	2012/02/08 11:05:04	1.539
+++ LVM2/WHATS_NEW_DM	2012/02/08 11:07:17	1.540
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Fix fd resource leak in error path for _udev_notify_sem_create().
   Leave space for '\0' for readline() call in _sysfs_get_kernel_name().
 
 Version 1.02.69 - 1st February 2012
--- LVM2/libdm/libdm-common.c	2012/02/08 11:05:05	1.135
+++ LVM2/libdm/libdm-common.c	2012/02/08 11:07:17	1.136
@@ -1738,7 +1738,7 @@
 		log_error("semid %d: sem_ctl GETVAL failed for "
 			  "cookie 0x%" PRIx32 ": %s",
 			  gen_semid, gen_cookie, strerror(errno));
-		return 0;		
+		goto bad;
 	}
 
 	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) incremented to %d",


