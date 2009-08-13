From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Aug 2009 19:36:05 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/mirror/mirrored.c
Message-ID: <20090813193605.11299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-08-13 19:36:04

Modified files:
	.              : WHATS_NEW_DM 
	lib/mirror     : mirrored.c 

Log message:
	mirror table generating code:  Properly handle 'block_on_errors' and 'cluster' features
	
	The device-mapper mirror CTR table has been changing over time.  This has
	now been corrected to handle the old and new methods for invoking the
	'block_on_errors' and 'cluster' features.  (The code that does this was
	accidentally committed in the previous check-in.  This check-in finishes
	the job.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.293&r2=1.294
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/WHATS_NEW_DM	2009/08/06 19:32:26	1.293
+++ LVM2/WHATS_NEW_DM	2009/08/13 19:36:04	1.294
@@ -1,5 +1,6 @@
 Version 1.02.37 -
 =================================
+  Fix mirror table CTR code to handle 'block_on_error' and 'cluster' features
 
 Version 1.02.36 - 6th August 2009
 =================================
--- LVM2/lib/mirror/mirrored.c	2009/07/09 11:29:00	1.62
+++ LVM2/lib/mirror/mirrored.c	2009/08/13 19:36:04	1.63
@@ -362,14 +362,22 @@
 		_mirrored_present = target_present(cmd, "mirror", 1);
 
 		/*
-		 * block_on_error available with mirror target >= 1.1 and <= 1.11
+		 * block_on_error available as "block_on_error" log
+		 * argument with mirror target >= 1.1 and <= 1.11
 		 * or with 1.0 in RHEL4U3 driver >= 4.5
+		 *
+		 * block_on_error available as "handle_errors" mirror
+		 * argument with mirror target >= 1.12.
+		 *
+		 * libdm-deptree.c is smart enough to handle the differences
+		 * between block_on_error and handle_errors for all
+		 * mirror target versions >= 1.1
 		 */
 		/* FIXME Move this into libdevmapper */
 
 		if (target_version("mirror", &maj, &min, &patchlevel) &&
 		    maj == 1 &&
-		    ((min >= 1 && min <= 11) ||
+		    ((min >= 1) ||
 		     (min == 0 && driver_version(vsn, sizeof(vsn)) &&
 		      sscanf(vsn, "%u.%u.%u", &maj2, &min2, &patchlevel2) == 3 &&
 		      maj2 == 4 && min2 == 5 && patchlevel2 == 0)))	/* RHEL4U3 */


