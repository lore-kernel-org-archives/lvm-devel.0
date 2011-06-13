From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Jun 2011 03:53:02 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110613035302.15944.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-13 03:53:02

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix fields in warning message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106

--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/13 03:32:46	1.105
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/13 03:53:02	1.106
@@ -2062,11 +2062,11 @@
 	    dmt->type == DM_DEVICE_RELOAD)
 		log_error("Performing unsafe table load while %d device(s) "
 			  "are known to be suspended: "
-			  "%s%s %s %s%.0d%s%.0d%s%s",
+			  "%s%s%s %s%.0d%s%.0d%s%s",
 			  suspended_counter,
-	                  dmt->new_uuid ? "UUID " : "",
-	                  dmi->name,
-			  dmi->uuid,
+	                  dmt->dev_name ? : "",
+	                  dmt->uuid ? " UUID " : "",
+			  dmt->uuid ? : "",
 	                  dmt->major > 0 ? "(" : "",
 	                  dmt->major > 0 ? dmt->major : 0,
 	                  dmt->major > 0 ? ":" : "",


