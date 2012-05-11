From: agk@sourceware.org <agk@sourceware.org>
Date: 11 May 2012 15:32:20 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120511153220.14421.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-11 15:32:19

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Always include debug mesg when cling to allocated is set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.376&r2=1.377

--- LVM2/lib/metadata/lv_manip.c	2012/05/11 15:26:30	1.376
+++ LVM2/lib/metadata/lv_manip.c	2012/05/11 15:32:19	1.377
@@ -1673,7 +1673,7 @@
 	if (alloc_parms->flags & A_CLING_TO_ALLOCED)
 		ix_offset = ah->area_count;
 
-	if (alloc_parms->alloc == ALLOC_NORMAL)
+	if (alloc_parms->alloc == ALLOC_NORMAL || (alloc_parms->flags & A_CLING_TO_ALLOCED))
 		log_debug("Cling_to_allocated is %sset",
 			  alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
 


