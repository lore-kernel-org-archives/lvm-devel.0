From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 May 2010 22:08:39 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20100503220839.5670.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-05-03 22:08:39

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Specify exactly which ioctl doesn't have a cookie set (for better debugging).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/libdm/ioctl/libdm-iface.c	2010/05/03 21:06:53	1.72
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/05/03 22:08:38	1.73
@@ -1770,11 +1770,13 @@
 		 * libdevmapper's node and symlink creation code.
 		 */
 		if (!dmt->cookie_set && dm_udev_get_sync_support()) {
-			log_debug("Cookie value is not set while trying to call "
-				  "DM_DEVICE_RESUME, DM_DEVICE_REMOVE or DM_DEVICE_RENAME "
+			log_debug("Cookie value is not set while trying to call %s "
 				  "ioctl. Please, consider using libdevmapper's udev "
 				  "synchronisation interface or disable it explicitly "
-				  "by calling dm_udev_set_sync_support(0).");
+				  "by calling dm_udev_set_sync_support(0).",
+				  dmt->type == DM_DEVICE_RESUME ? "DM_DEVICE_RESUME" :
+				  dmt->type == DM_DEVICE_REMOVE ? "DM_DEVICE_REMOVE" :
+								  "DM_DEVICE_RENAME");
 			log_debug("Switching off device-mapper and all subsystem related "
 				  "udev rules. Falling back to libdevmapper node creation.");
 			/*


