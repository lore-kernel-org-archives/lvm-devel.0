From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Oct 2010 11:44:21 -0000
Subject: LVM2/libdm ioctl/libdm-iface.c misc/dm-ioctl.h
Message-ID: <20101025114421.30097.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-25 11:44:21

Modified files:
	libdm/ioctl    : libdm-iface.c 
	libdm/misc     : dm-ioctl.h 

Log message:
	Use a more-generic name for the new kernel flag so list_devices can share it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-ioctl.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/libdm/ioctl/libdm-iface.c	2010/10/15 01:10:28	1.82
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/10/25 11:44:20	1.83
@@ -1542,7 +1542,7 @@
 				  "kernel.  Aborting operation.");
 			goto bad;
 		}
-		dmi->flags |= DM_NEW_UUID_FLAG;
+		dmi->flags |= DM_UUID_FLAG;
 	}
 
 	dmi->target_count = count;
--- LVM2/libdm/misc/dm-ioctl.h	2010/10/15 01:10:28	1.6
+++ LVM2/libdm/misc/dm-ioctl.h	2010/10/25 11:44:21	1.7
@@ -328,6 +328,6 @@
  * If set, rename changes the uuid not the name.  Only permitted
  * if no uuid was previously supplied: an existing uuid cannot be changed.
  */
-#define DM_NEW_UUID_FLAG        (1 << 14) /* In */
+#define DM_UUID_FLAG			(1 << 14) /* In */
 
 #endif				/* _LINUX_DM_IOCTL_H */


