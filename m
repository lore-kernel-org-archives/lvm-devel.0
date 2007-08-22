From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Aug 2007 19:32:42 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20070822193242.20716.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-22 19:32:40

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix lvconvert_mirrors detection of number of existing mirrors.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.690&r2=1.691
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2007/08/22 14:38:15	1.690
+++ LVM2/WHATS_NEW	2007/08/22 19:32:39	1.691
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Fix lvconvert_mirrors detection of number of existing mirrors.
   Clean up numerous compiler warnings that crept in recently.
   Remove several unused parameters from _allocate().
   Only permit --force, --verbose and --debug arguments to be repeated.
--- LVM2/tools/lvconvert.c	2007/08/22 14:38:18	1.36
+++ LVM2/tools/lvconvert.c	2007/08/22 19:32:39	1.37
@@ -242,7 +242,7 @@
 	unsigned corelog = 0;
 
 	seg = first_seg(lv);
-	existing_mirrors = seg->area_count;
+	existing_mirrors = (lv->status & MIRRORED) ? seg->area_count : 1;
 
 	/*
 	 * Adjust required number of mirrors


