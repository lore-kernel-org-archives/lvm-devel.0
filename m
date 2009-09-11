From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 16:11:25 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090911161125.8140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 16:11:25

Modified files:
	libdm          : libdm-common.c 

Log message:
	Move dm_cookie_supported check into dm_udev_get_sync_supprt function.
	
	We don't have to call dm_cookie_supported with dm_udev_get_sync_support
	this way. Also, it's necessary for the current code to work properly on
	systems without cookie support (older kernels).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/libdm/libdm-common.c	2009/09/11 15:57:51	1.79
+++ LVM2/libdm/libdm-common.c	2009/09/11 16:11:25	1.80
@@ -881,7 +881,7 @@
 	if (_udev_running < 0)
 		_udev_running = _check_udev_is_running();
 
-	return _udev_running && _sync_with_udev;
+	return dm_cookie_supported() && _udev_running && _sync_with_udev;
 }
 
 static int _get_cookie_sem(uint32_t cookie, int *semid)
@@ -1064,7 +1064,7 @@
 {
 	int semid;
 
-	if (!dm_udev_get_sync_support() || !dm_cookie_supported()) {
+	if (!dm_udev_get_sync_support()) {
 		dmt->event_nr = *cookie = 0;
 		return 1;
 	}
@@ -1099,7 +1099,7 @@
 {
 	int semid;
 
-	if (!cookie || !dm_udev_get_sync_support() || !dm_cookie_supported())
+	if (!cookie || !dm_udev_get_sync_support())
 		return 1;
 
 	if (!_get_cookie_sem(cookie, &semid))
@@ -1120,7 +1120,7 @@
 	int semid;
 	struct sembuf sb = {0, 0, 0};
 
-	if (!cookie || !dm_udev_get_sync_support() || !dm_cookie_supported())
+	if (!cookie || !dm_udev_get_sync_support())
 		return 1;
 
 	if (!_get_cookie_sem(cookie, &semid))


