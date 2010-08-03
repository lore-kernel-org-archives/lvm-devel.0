From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 Aug 2010 07:56:04 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20100803075604.1030.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-03 07:56:04

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Add check for kernel semaphore support and disable udev_sync if not available.
	
	udev_sync feature requires semaphores (part of System V IPC) to be configured
	in kernel (CONFIG_SYSVIPC). Check whether it is supported and if not, give
	a warning message and disable udev synchronisation code automatically to
	avoid any further error states and associated problems.
	
	One should use the kernel with System V IPC support enabled or libdevmapper
	with udev_sync feature disabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.400&r2=1.401
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/WHATS_NEW_DM	2010/07/28 21:58:08	1.400
+++ LVM2/WHATS_NEW_DM	2010/08/03 07:56:03	1.401
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Add check for kernel semaphore support and disable udev_sync if not available.
 
 Version 1.02.53 - 28th July 2010
 ================================
--- LVM2/libdm/libdm-common.c	2010/07/09 15:34:47	1.97
+++ LVM2/libdm/libdm-common.c	2010/08/03 07:56:03	1.98
@@ -60,6 +60,7 @@
 static int _verbose = 0;
 
 #ifdef UDEV_SYNC_SUPPORT
+static int _semaphore_supported = -1;
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
 static int _udev_checking = 1;
@@ -929,6 +930,23 @@
 
 #else		/* UDEV_SYNC_SUPPORT */
 
+static int _check_semaphore_is_supported()
+{
+	int maxid;
+	union semun arg;
+	struct seminfo seminfo;
+
+	arg.__buf = &seminfo;
+	maxid = semctl(0, 0, SEM_INFO, arg);
+
+	if (maxid < 0) {
+		log_warn("Kernel not configured for semaphores (System V IPC). "
+			 "Not using udev synchronisation code.");
+		return 0;
+	}
+
+	return 1;
+}
 
 static int _check_udev_is_running(void)
 {
@@ -958,20 +976,27 @@
 	return 0;
 }
 
-void dm_udev_set_sync_support(int sync_with_udev)
+static void _check_udev_sync_requirements_once()
 {
+	if (_semaphore_supported < 0)
+		_semaphore_supported = _check_semaphore_is_supported();
+
 	if (_udev_running < 0)
 		_udev_running = _check_udev_is_running();
+}
 
+void dm_udev_set_sync_support(int sync_with_udev)
+{
+	_check_udev_sync_requirements_once();
 	_sync_with_udev = sync_with_udev;
 }
 
 int dm_udev_get_sync_support(void)
 {
-	if (_udev_running < 0)
-		_udev_running = _check_udev_is_running();
+	_check_udev_sync_requirements_once();
 
-	return dm_cookie_supported() && _udev_running && _sync_with_udev;
+	return _semaphore_supported && dm_cookie_supported() &&
+		_udev_running && _sync_with_udev;
 }
 
 void dm_udev_set_checking(int checking)


