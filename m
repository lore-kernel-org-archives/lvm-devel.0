From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 16 Aug 2010 11:13:19 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20100816111319.29220.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-16 11:13:19

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	dm-mod autoloading support is in kernel 2.6.36 actually.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/libdm/ioctl/libdm-iface.c	2010/08/03 13:16:21	1.79
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/08/16 11:13:18	1.80
@@ -392,7 +392,7 @@
 	 */
 	if (!_control_exists(control, 0, 0) ||
 	    !(KERNEL_VERSION(_kernel_major, _kernel_minor, _kernel_release) >=
-	      KERNEL_VERSION(2, 6, 35)) ||
+	      KERNEL_VERSION(2, 6, 36)) ||
 	    !_open_and_assign_control_fd(control)) {
 		if (!_control_device_number(&major, &minor))
 			log_error("Is device-mapper driver missing from kernel?");


