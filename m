From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 15:24:25 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20080116152425.22020.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 15:24:25

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Don't use block_on_error with mirror targets above version 1.12.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.760&r2=1.761
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2008/01/15 20:37:49	1.760
+++ LVM2/WHATS_NEW	2008/01/16 15:24:25	1.761
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Don't use block_on_error with mirror targets above version 1.12.
   Update vgsplit to include vgcreate-style options when new VG is destination.
   Update vgsplit to accept existing VG as destination.
   lvconvert waits for completion of initial sync by default.
--- LVM2/lib/mirror/mirrored.c	2007/08/20 20:55:27	1.46
+++ LVM2/lib/mirror/mirrored.c	2008/01/16 15:24:25	1.47
@@ -348,14 +348,14 @@
 		_mirrored_present = target_present("mirror", 1);
 
 		/*
-		 * block_on_error available with mirror target >= 1.1
+		 * block_on_error available with mirror target >= 1.1 and <= 1.11
 		 * or with 1.0 in RHEL4U3 driver >= 4.5
 		 */
 		/* FIXME Move this into libdevmapper */
 
 		if (target_version("mirror", &maj, &min, &patchlevel) &&
 		    maj == 1 && 
-		    (min >= 1 || 
+		    ((min >= 1 && min <= 11) || 
 		     (min == 0 && driver_version(vsn, sizeof(vsn)) &&
 		      sscanf(vsn, "%u.%u.%u", &maj2, &min2, &patchlevel2) == 3 &&
 		      maj2 == 4 && min2 == 5 && patchlevel2 == 0)))	/* RHEL4U3 */


