From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Aug 2007 20:03:49 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20070822200349.18788.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-22 20:03:46

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Change lvconvert_mirrors to use mirror segtype not striped.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.691&r2=1.692
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2007/08/22 19:32:39	1.691
+++ LVM2/WHATS_NEW	2007/08/22 20:03:44	1.692
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Change lvconvert_mirrors to use mirror segtype not striped.
   Fix lvconvert_mirrors detection of number of existing mirrors.
   Clean up numerous compiler warnings that crept in recently.
   Remove several unused parameters from _allocate().
--- LVM2/tools/lvconvert.c	2007/08/22 19:32:39	1.37
+++ LVM2/tools/lvconvert.c	2007/08/22 20:03:46	1.38
@@ -208,7 +208,7 @@
 			return 0;
 		}
 
-		if (!(lp->segtype = get_segtype_from_string(cmd, "striped")))
+		if (!(lp->segtype = get_segtype_from_string(cmd, "mirror")))
 			return_0;
 	}
 
@@ -236,7 +236,6 @@
 	struct alloc_handle *ah = NULL;
 	struct logical_volume *log_lv;
 	struct list *parallel_areas;
-	struct segment_type *segtype;  /* FIXME: could I just use lp->segtype */
 	float sync_percent;
 	const char *mirrorlog;
 	unsigned corelog = 0;
@@ -339,7 +338,7 @@
 		if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
 					    1, lp->mirrors - 1,
 					    corelog ? 0U : 1U,
-					    lv->le_count * (lp->mirrors - 1),
+					    lv->le_count,
 					    NULL, 0, lp->pvh,
 					    lp->alloc,
 					    parallel_areas)))
@@ -386,9 +385,7 @@
 				return 0;
 			}
 
-			segtype = get_segtype_from_string(cmd, "striped");
-
-			if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0,
+			if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype, 0,
 						    0, 1, 0,
 						    NULL, 0, lp->pvh,
 						    lp->alloc,


