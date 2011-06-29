From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 11:36:38 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110629113638.31579.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 11:36:37

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Remove temporary failures now, but continue to give INTERNAL_ERROR.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/29 08:54:13	1.109
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/29 11:36:37	1.110
@@ -2059,7 +2059,7 @@
 	}
 
 	if ((suspended_counter = dm_get_suspended_counter()) &&
-	    dmt->type == DM_DEVICE_RELOAD) {
+	    dmt->type == DM_DEVICE_RELOAD)
 		log_error(INTERNAL_ERROR "Performing unsafe table load while %d device(s) "
 			  "are known to be suspended: "
 			  "%s%s%s %s%.0d%s%.0d%s%s",
@@ -2073,8 +2073,6 @@
 	                  dmt->minor > 0 ? dmt->minor : 0,
 	                  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
 	                  dmt->major > 0 ? ") " : "");
-		return 0;
-	}
 
 	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:


