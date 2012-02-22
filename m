From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Feb 2012 17:14:40 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120222171440.20525.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-02-22 17:14:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2297&r2=1.2298
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.362&r2=1.363

--- LVM2/WHATS_NEW	2012/02/20 21:11:06	1.2297
+++ LVM2/WHATS_NEW	2012/02/22 17:14:38	1.2298
@@ -1,5 +1,6 @@
 Version 2.02.93 - 
 ====================================
+  Fix 'build_parallel_areas_from_lv' to work properly with RAID 4/5/6
 
 Version 2.02.92 - 20th February 2012
 ====================================
--- LVM2/lib/metadata/lv_manip.c	2012/02/15 15:18:43	1.362
+++ LVM2/lib/metadata/lv_manip.c	2012/02/22 17:14:39	1.363
@@ -3061,7 +3061,8 @@
 	struct dm_list *parallel_areas;
 	struct seg_pvs *spvs;
 	uint32_t current_le = 0;
-	struct lv_segment * uninitialized_var(seg);
+	uint32_t raid_multiple;
+	struct lv_segment *seg = first_seg(lv);
 
 	if (!(parallel_areas = dm_pool_alloc(cmd->mem, sizeof(*parallel_areas)))) {
 		log_error("parallel_areas allocation failed");
@@ -3100,7 +3101,9 @@
 			return_NULL;
 
 		current_le = spvs->le + spvs->len;
-	} while (current_le < lv->le_count);
+		raid_multiple = (seg->segtype->parity_devs) ?
+			seg->area_count - seg->segtype->parity_devs : 1;
+	} while ((current_le * raid_multiple) < lv->le_count);
 
 	/* FIXME Merge adjacent segments with identical PV lists (avoids need for contiguous allocation attempts between successful allocations) */
 


