From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Jan 2011 14:43:54 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110104144354.14530.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-01-04 14:43:54

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Export DM_CONTROL_NODE_UMASK and use it while creating /dev/mapper/control.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.434&r2=1.435
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW_DM	2010/12/21 21:08:52	1.434
+++ LVM2/WHATS_NEW_DM	2011/01/04 14:43:53	1.435
@@ -1,5 +1,6 @@
 Version 1.02.61 - 
 ====================================
+  Export DM_CONTROL_NODE_UMASK and use it while creating /dev/mapper/control.
 
 Version 1.02.60 - 20th December 2010
 ====================================
--- LVM2/libdm/libdevmapper.h	2010/12/20 13:39:12	1.131
+++ LVM2/libdm/libdevmapper.h	2011/01/04 14:43:54	1.132
@@ -1219,6 +1219,7 @@
 int dm_udev_wait(uint32_t cookie);
 
 #define DM_DEV_DIR_UMASK 0022
+#define DM_CONTROL_NODE_UMASK 0177
 
 #ifdef __cplusplus
 }
--- LVM2/libdm/ioctl/libdm-iface.c	2010/12/13 10:43:58	1.86
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/01/04 14:43:54	1.87
@@ -282,12 +282,14 @@
 	log_verbose("Creating device %s (%u, %u)", control, major, minor);
 
 	(void) dm_prepare_selinux_context(control, S_IFCHR);
+	old_umask = umask(DM_CONTROL_NODE_UMASK);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
 		  MKDEV(major, minor)) < 0)  {
 		log_sys_error("mknod", control);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		return 0;
 	}
+	umask(old_umask);
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	return 1;


