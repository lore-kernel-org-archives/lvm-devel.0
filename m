From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 31 Jan 2011 11:54:55 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110131115455.16794.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-01-31 11:54:55

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add a debug message when uevent is not generated and we call udev_complete internally.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/libdm/ioctl/libdm-iface.c	2011/01/28 10:16:04	1.88
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/01/31 11:54:55	1.89
@@ -1979,8 +1979,11 @@
 		}
 	}
 
-	if (ioctl_with_uevent && !_check_uevent_generated(dmi))
+	if (ioctl_with_uevent && !_check_uevent_generated(dmi)) {
+		log_debug("Uevent not generated! Calling udev_complete "
+			  "internally to avoid process lock-up.");
 		_udev_complete(dmt);
+	}
 
 #else /* Userspace alternative for testing */
 #endif


