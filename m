From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 15:56:07 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdm-common.c
Message-ID: <20090911155607.10868.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 15:56:07

Modified files:
	.              : WHATS_NEW 
	libdm          : libdm-common.c 

Log message:
	Check that udev is running and set internal state appropriately.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1256&r2=1.1257
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/WHATS_NEW	2009/09/11 15:55:07	1.1256
+++ LVM2/WHATS_NEW	2009/09/11 15:56:06	1.1257
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Check that udev is running and set internal state appropriately.
   Add libudev configuration check.
   Add lvm2app.sh to nightly tests conditional upon configure --enable-applib.
   Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
--- LVM2/libdm/libdm-common.c	2009/09/03 21:51:26	1.77
+++ LVM2/libdm/libdm-common.c	2009/09/11 15:56:07	1.78
@@ -28,6 +28,9 @@
 #  include <sys/types.h>
 #  include <sys/ipc.h>
 #  include <sys/sem.h>
+#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+#  include <libudev.h>
+#endif
 #endif
 
 #ifdef linux
@@ -45,6 +48,7 @@
 static int _verbose = 0;
 
 #ifdef UDEV_SYNC_SUPPORT
+static int _udev_running = -1;
 static int _sync_with_udev = 1;
 #endif
 
@@ -825,14 +829,58 @@
 
 #else		/* UDEV_SYNC_SUPPORT */
 
+
+static int _check_udev_is_running(void)
+{
+	#ifndef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+	log_debug("Could not get udev state because libudev library "
+		  "was not found and it was not compiled in. "
+		  "Assuming udev is not running.");
+	return 0;
+	#else	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
+	struct udev *udev;
+	struct udev_queue *udev_queue;
+	int r;
+
+	if (!(udev = udev_new()))
+		goto error;
+
+	if (!(udev_queue = udev_queue_new(udev))) {
+		udev_unref(udev);
+		goto error;
+	}
+
+	r = udev_queue_get_udev_is_active(udev_queue);
+
+	if (!r)
+		log_debug("Udev is not running. "
+			  "Not using udev synchronisation code.");
+
+	udev_queue_unref(udev_queue);
+	udev_unref(udev);
+
+	return r;
+
+error:
+	log_debug("Could not get udev state. Assuming udev is not running.");
+	return 0;
+	#endif	/* HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE */
+}
+
 void dm_udev_set_sync_support(int sync_with_udev)
 {
+	if (_udev_running < 0)
+		_udev_running = _check_udev_is_running();
+
 	_sync_with_udev = sync_with_udev;
 }
 
 int dm_udev_get_sync_support(void)
 {
-	return _sync_with_udev;
+	if (_udev_running < 0)
+		_udev_running = _check_udev_is_running();
+
+	return _udev_running && _sync_with_udev;
 }
 
 static int _get_cookie_sem(uint32_t cookie, int *semid)


