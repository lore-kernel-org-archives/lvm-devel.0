From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Jan 2010 23:06:37 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100108230637.2645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-08 23:06:36

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	update comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193

--- LVM2/lib/metadata/lv_manip.c	2010/01/08 22:32:35	1.192
+++ LVM2/lib/metadata/lv_manip.c	2010/01/08 23:06:36	1.193
@@ -1396,8 +1396,6 @@
 	/*
 	 * We don't actually use the 'log_lv' parameter for anything more
 	 * than just figuring out that this allocation is for a log device
-	 * It'd be nice to change the arguments type, but the function is
-	 * exported.
 	 */
 	aa_list = (log_lv) ? &ah->log_areas :
 		&ah->alloced_areas[first_area];


