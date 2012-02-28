From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Feb 2012 08:36:52 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20120228083652.15070.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-28 08:36:51

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Fix dm_task_set_name to properly resolve path to dm name.
	
	Wrong variable was checked in _dm_task_set_name_from_path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.574&r2=1.575
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/WHATS_NEW_DM	2012/02/23 22:45:43	1.574
+++ LVM2/WHATS_NEW_DM	2012/02/28 08:36:51	1.575
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Fix dm_task_set_name to properly resolve path to dm name (1.02.71).
   Add dm_strncpy() function as a faster strncpy() replacement.
 
 Version 1.02.72 - 23rd February 2012
--- LVM2/libdm/libdm-common.c	2012/02/15 12:23:16	1.141
+++ LVM2/libdm/libdm-common.c	2012/02/28 08:36:51	1.142
@@ -526,7 +526,7 @@
 		return 0;
 	}
 
-	if (!stat(path, &st2) && (st1.st_rdev == st2.st_rdev))
+	if (!stat(buf, &st2) && (st1.st_rdev == st2.st_rdev))
 		final_name = name;
 	else if (_find_dm_name_of_device(st1.st_rdev, buf, sizeof(buf)))
 		final_name = buf;


