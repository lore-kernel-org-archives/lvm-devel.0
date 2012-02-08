From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:25:11 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20120208112511.3067.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:25:10

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Set all parameters to 0
	
	Since the function dm_get_next_target() returns NULL as 'next' pointer
	so it's not a 'real' error - set 0 to all parameters when NULL is
	returned because of missing head.
	
	i.e. one of use case::
	do {
	next = dm_get_next_target(dmt, next, &start, &length,
	&target_type, &params);
	size += length;
	} while (next);

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.540&r2=1.541
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/WHATS_NEW_DM	2012/02/08 11:07:17	1.540
+++ LVM2/WHATS_NEW_DM	2012/02/08 11:25:09	1.541
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Set all parameters to 0 for dm_get_next_target() for NULL return.
   Fix fd resource leak in error path for _udev_notify_sem_create().
   Leave space for '\0' for readline() call in _sysfs_get_kernel_name().
 
--- LVM2/libdm/ioctl/libdm-iface.c	2012/01/17 14:36:59	1.132
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/02/08 11:25:10	1.133
@@ -573,8 +573,13 @@
 	if (!t)
 		t = dmt->head;
 
-	if (!t)
+	if (!t) {
+		*start = 0;
+		*length = 0;
+		*target_type = 0;
+		*params = 0;
 		return NULL;
+	}
 
 	*start = t->start;
 	*length = t->length;


