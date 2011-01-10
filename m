From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:42:32 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h
Message-ID: <20110110134232.25171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:42:32

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 

Log message:
	Define DM_COOKIE_AUTO_CREATE
	
	TODO: Use it also for already written code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.435&r2=1.436
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/WHATS_NEW_DM	2011/01/04 14:43:53	1.435
+++ LVM2/WHATS_NEW_DM	2011/01/10 13:42:31	1.436
@@ -1,5 +1,6 @@
 Version 1.02.61 - 
 ====================================
+  Add DM_COOKIE_AUTO_CREATE to libdevmapper.h.
   Export DM_CONTROL_NODE_UMASK and use it while creating /dev/mapper/control.
 
 Version 1.02.60 - 20th December 2010
--- LVM2/libdm/libdevmapper.h	2011/01/04 14:43:54	1.132
+++ LVM2/libdm/libdevmapper.h	2011/01/10 13:42:31	1.133
@@ -1214,6 +1214,11 @@
 int dm_udev_get_sync_support(void);
 void dm_udev_set_checking(int checking);
 int dm_udev_get_checking(void);
+
+/*
+ * Default value to get new auto generated cookie created
+ */
+#define DM_COOKIE_AUTO_CREATE 0
 int dm_udev_create_cookie(uint32_t *cookie);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);


