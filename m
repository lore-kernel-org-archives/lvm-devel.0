From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:31:02 -0000
Subject: LVM2 lib/metadata/lv_manip.c tools/lvresize.c
Message-ID: <20111028203102.9052.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:31:01

Modified files:
	lib/metadata   : lv_manip.c 
	tools          : lvresize.c 

Log message:
	Thin pool resize support for data LV
	
	Support for extension of pool data LV.
	
	TODO: figure out thin volume for suspend/resume in cluster.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.310&r2=1.311
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:29:32	1.310
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:31:01	1.311
@@ -2557,19 +2557,23 @@
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
-	if (segtype_is_thin_pool(segtype))
+	if (!lv->le_count && segtype_is_thin_pool(segtype))
+		/* Thin pool allocation treats its metadata device like a mirror log. */
 		log_count = 1;
 	else if (segtype_is_raid(segtype) && !lv->le_count)
 		log_count = mirrors * stripes;
 
-	/* Thin pool allocation treats its metadata device like a mirror log. */
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    log_count, region_size, extents,
 				    allocatable_pvs, alloc, NULL)))
 		return_0;
 
 	if (segtype_is_thin_pool(segtype)) {
-		if (!(r = extend_pool(lv, segtype, ah)))
+		if (!lv->le_count) {
+			if (!(r = extend_pool(lv, segtype, ah)))
+				stack;
+		} else if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
+						       stripes, stripe_size)))
 			stack;
 	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype)) {
 		if (!(r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
--- LVM2/tools/lvresize.c	2011/10/06 15:32:27	1.139
+++ LVM2/tools/lvresize.c	2011/10/28 20:31:01	1.140
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -669,6 +669,25 @@
 		}
 	}
 
+	if (lv_is_thin_pool(lv)) {
+		if (lp->resize == LV_REDUCE) {
+			log_error("Thin pool volumes cannot be reduced in size yet.");
+			return ECMD_FAILED;
+		}
+
+		if (lp->resizefs) {
+			log_warn("Thin pool volumes do not have filesystem.");
+			lp->resizefs = 0;
+		}
+
+		if (!lp->stripes) {
+			/* Try to use the same strip settings for underlying pool data LV */
+			lp->stripes = last_seg(seg_lv(first_seg(lv), 0))->area_count;
+			if (!lp->stripe_size)
+				lp->stripe_size = last_seg(seg_lv(first_seg(lv), 0))->stripe_size;
+		}
+	}
+
 	if ((lp->resize == LV_REDUCE) && lp->argc)
 		log_warn("Ignoring PVs on command line when reducing");
 
@@ -730,6 +749,10 @@
 	/* If snapshot, must suspend all associated devices */
 	if (lv_is_cow(lv))
 		lock_lv = origin_from_cow(lv);
+	else if (lv_is_used_thin_pool(lv))
+		// FIXME: what to pick here - maybe an active thin?
+		// but it still seems to be racy in cluster
+		lock_lv = lv;
 	else
 		lock_lv = lv;
 


