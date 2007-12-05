From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Dec 2007 22:11:22 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in lib/metadata/l ...
Message-ID: <20071205221122.25120.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-05 22:11:20

Modified files:
	.              : WHATS_NEW configure.in 
	lib/metadata   : lv_alloc.h lv_manip.c 
	man            : lvchange.8 lvcreate.8 
	tools          : lvconvert.c lvcreate.c pvmove.c 

Log message:
	export can_split parameter until rest of pvmove allocation restructuring gets done

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.741&r2=1.742
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2007/12/04 15:39:25	1.741
+++ LVM2/WHATS_NEW	2007/12/05 22:11:19	1.742
@@ -43,7 +43,9 @@
   All tools: print --help output to stdout, not stderr.
   After a diagnostic, suggest --help, rather than printing all --help output.
   Add %PVS extents option to lvresize, lvextend, and lvcreate.
+  Add 'make check' to run tests in new subdirectory 'test'.
   Moved the obsolete test subdirectory to old-tests.
+  Cope with relative paths in configure --with-dmdir.
   Remove no-longer-correct restrictions on PV arg count with stripes/mirrors.
   Fix strdup memory leak in str_list_dup().
   Link with -lpthread when static SELinux libraries require that.
--- LVM2/configure.in	2007/09/21 10:16:43	1.63
+++ LVM2/configure.in	2007/12/05 22:11:19	1.64
@@ -1,6 +1,6 @@
 ##
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004, 2007 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 ##
 ## This file is part of LVM2.
 ##
--- LVM2/lib/metadata/lv_alloc.h	2007/11/22 14:54:35	1.18
+++ LVM2/lib/metadata/lv_alloc.h	2007/12/05 22:11:19	1.19
@@ -50,6 +50,7 @@
 				      uint32_t extents,
                                       struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
+				      unsigned can_split,
 				      struct list *parallel_areas);
 
 int lv_add_segment(struct alloc_handle *ah,
--- LVM2/lib/metadata/lv_manip.c	2007/11/22 14:54:35	1.135
+++ LVM2/lib/metadata/lv_manip.c	2007/12/05 22:11:19	1.136
@@ -1055,13 +1055,13 @@
 		     struct volume_group *vg,
 		     struct logical_volume *lv,
 		     uint32_t new_extents,
+		     unsigned can_split,
 		     struct list *allocatable_pvs)
 {
 	struct pv_area **areas;
 	uint32_t allocated = lv ? lv->le_count : 0;
 	uint32_t old_allocated;
 	struct lv_segment *prev_lvseg = NULL;
-	unsigned can_split = 1;	/* Are we allowed more than one segment? */
 	int r = 0;
 	struct list *pvms;
 	uint32_t areas_size;
@@ -1180,6 +1180,7 @@
 				      uint32_t extents,
 				      struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
+				      unsigned can_split,
 				      struct list *parallel_areas)
 {
 	struct alloc_handle *ah;
@@ -1208,7 +1209,7 @@
 
 	if (!segtype_is_virtual(segtype) &&
 	    !_allocate(ah, vg, lv, (lv ? lv->le_count : 0) + extents,
-		       allocatable_pvs)) {
+		       can_split, allocatable_pvs)) {
 		stack;
 		alloc_destroy(ah);
 		return NULL;
@@ -1403,16 +1404,18 @@
 	uint32_t m;
 	struct alloc_handle *ah;
 	struct lv_segment *seg;
+	unsigned can_split = 1;
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, status, extents, segtype);
 
 	/* FIXME Temporary restriction during code reorganisation */
 	if (mirrored_pv)
-		alloc = ALLOC_CONTIGUOUS;
+		can_split = 0;
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0,
-				    extents, allocatable_pvs, alloc, NULL)))
+				    extents, allocatable_pvs, alloc, can_split,
+				    NULL)))
 		return_0;
 
 	if (mirrors < 2) {
--- LVM2/man/lvchange.8	2007/11/09 16:51:54	1.14
+++ LVM2/man/lvchange.8	2007/12/05 22:11:20	1.15
@@ -75,11 +75,10 @@
 .I \-r, \-\-readahead ReadAheadSectors|auto|none
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
-be a value between 2 and 120.
+be a value between 2 and 120 sectors.
 The default value is "auto" which allows the kernel to choose
 a suitable value automatically.
 "None" is equivalent to specifying zero.
-N.B. This setting is currently disregarded and "auto" is always used.
 .TP
 .I \-\-refresh
 If the logical volume is active, reload its metadata.
--- LVM2/man/lvcreate.8	2007/11/09 16:51:54	1.20
+++ LVM2/man/lvcreate.8	2007/12/05 22:11:20	1.21
@@ -125,7 +125,6 @@
 The default value is "auto" which allows the kernel to choose
 a suitable value automatically.
 "None" is equivalent to specifying zero.
-N.B. This setting is currently disregarded and "auto" is always used.
 .TP
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log 
--- LVM2/tools/lvconvert.c	2007/11/22 14:54:35	1.46
+++ LVM2/tools/lvconvert.c	2007/12/05 22:11:20	1.47
@@ -339,7 +339,7 @@
 					    1, lp->mirrors - 1,
 					    corelog ? 0U : 1U,
 					    lv->le_count, lp->pvh, lp->alloc,
-					    parallel_areas)))
+					    1, parallel_areas)))
 			return_0;
 
 		lp->region_size = adjusted_mirror_region_size(lv->vg->extent_size,
@@ -385,7 +385,7 @@
 
 			if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype, 0,
 						    0, 1, 0, lp->pvh, lp->alloc,
-						    parallel_areas))) {
+						    1, parallel_areas))) {
 				stack;
 				return 0;
 			}
--- LVM2/tools/lvcreate.c	2007/12/05 19:24:32	1.162
+++ LVM2/tools/lvcreate.c	2007/12/05 22:11:20	1.163
@@ -750,7 +750,7 @@
 
 		if (!(ah = allocate_extents(vg, NULL, lp->segtype, lp->stripes,
 					    lp->mirrors, lp->corelog ? 0U : 1U,
-					    lp->extents, pvh, lp->alloc, NULL)))
+					    lp->extents, pvh, lp->alloc, 1, NULL)))
 			return_0;
 
 		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
--- LVM2/tools/pvmove.c	2007/11/15 02:20:03	1.43
+++ LVM2/tools/pvmove.c	2007/12/05 22:11:20	1.44
@@ -161,6 +161,11 @@
 			log_print("Skipping locked LV %s", lv->name);
 			continue;
 		}
+		/* FIXME Just insert the layer below - no allocation */
+		// This knows nothing about pvmove
+		// insert_layer_for_segments_on_pv(cmd, lv, source_pvl, lv_mirr, *lvs_changed)
+		//   - for each lv segment using that pv
+		//     - call new fn insert_internal_layer()
 		if (!insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
 					   allocatable_pvs, alloc,
 					   *lvs_changed)) {
@@ -175,6 +180,10 @@
 		return NULL;
 	}
 
+	/* FIXME Do allocation and convert to mirror */
+	// again, this knows nothing about pvmove: it's a normal lvconvert lv_mirr to mirror with in-core log
+	// - a flag passed in requires that parent segs get split after the allocation (with failure if not possible)
+
 	return lv_mirr;
 }
 


