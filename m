From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 15:57:27 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120304155727.16076.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 15:57:27

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Just make error message more clear
	
	Make more obvious, the origin LV for snapshot must be active.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.369&r2=1.370

--- LVM2/lib/metadata/lv_manip.c	2012/03/01 10:09:36	1.369
+++ LVM2/lib/metadata/lv_manip.c	2012/03/04 15:57:27	1.370
@@ -4218,7 +4218,7 @@
 			}
 
 			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
-				log_error("Check for existence of snapshot "
+				log_error("Check for existence of active snapshot "
 					  "origin '%s' failed.", org->name);
 				return NULL;
 			}


