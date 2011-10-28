From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:17:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20111028201756.30828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:17:56

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Extend virtual segment instead of adding new one
	
	Before adding a new virtual segment to LV, check first whether
	the last segment isn't already of the same type. In this case
	extend last segment instead of creating the new one.
	
	Thin volumes should have always only 1 virtual segment, but it
	helps also to virtual snapshot or error segtype..

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2174&r2=1.2175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.304&r2=1.305

--- LVM2/WHATS_NEW	2011/10/28 20:12:54	1.2174
+++ LVM2/WHATS_NEW	2011/10/28 20:17:55	1.2175
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Increase virtual segment size instead of creating multiple segment list.
   Add last_seg(lv) internal function.
   Support empty string for log/prefix.
   Fix regression that allowed mirrored logs for cluster mirrors.
--- LVM2/lib/metadata/lv_manip.c	2011/10/23 16:02:02	1.304
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:17:56	1.305
@@ -2043,20 +2043,23 @@
 		thin_pool_lv = lvl->lv;
 	}
 
-	if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
-				     status, 0, NULL, thin_pool_lv, 0,
-				     extents, 0, 0, 0, NULL))) {
-		log_error("Couldn't allocate new zero segment.");
-		return 0;
+	if ((seg = last_seg(lv)) && (seg->segtype == segtype)) {
+		seg->area_len += extents;
+		seg->len += extents;
+	} else {
+		if (!(seg = alloc_lv_segment(segtype, lv, lv->le_count, extents,
+					     status, 0, NULL, thin_pool_lv, 0,
+					     extents, 0, 0, 0, NULL))) {
+			log_error("Couldn't allocate new zero segment.");
+			return 0;
+		}
+		lv->status |= VIRTUAL;
+		dm_list_add(&lv->segments, &seg->list);
 	}
 
-	dm_list_add(&lv->segments, &seg->list);
-
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents *lv->vg->extent_size;
 
-	lv->status |= VIRTUAL;
-
 	return 1;
 }
 


