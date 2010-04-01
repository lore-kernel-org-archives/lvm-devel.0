From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 14:30:52 -0000
Subject: LVM2/lib/device dev-io.c
Message-ID: <20100401143052.20755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 14:30:52

Modified files:
	lib/device     : dev-io.c 

Log message:
	temporarily downgrade the 'open while suspended' error till we fix it properly

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/lib/device/dev-io.c	2010/04/01 10:34:10	1.66
+++ LVM2/lib/device/dev-io.c	2010/04/01 14:30:51	1.67
@@ -392,7 +392,8 @@
 	}
 
 	if (memlock())
-		log_error(INTERNAL_ERROR "dev_open(%s) called while suspended",
+		/* FIXME Make this log_error */
+		log_verbose("dev_open(%s) called while suspended",
 			 dev_name(dev));
 
 	if (dev->flags & DEV_REGULAR)


