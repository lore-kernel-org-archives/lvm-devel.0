From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Dec 2008 15:24:54 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_alloc.h lib/m ...
Message-ID: <20081219152454.13886.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-12-19 15:24:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_alloc.h lv_manip.c metadata.h mirror.c 

Log message:
	Calculate mirror log size instead of hardcoding 1 extent size.
	
	It fails for 1k PE now.
	
	Patch adds log_region_size into allocation habdle struct
	and use it in _alloc_parallel_area() for proper log size calculation
	instead of hardcoded 1 extent - which can fail.
	
	Reproducer for incorrect log size calculation:
	DEV=/dev/sd[bcd]
	
	pvcreate $DEV
	vgcreate -s 1k vg_test $DEV
	lvcreate -m1 -L 12M -n mirr vg_test
	
	https://bugzilla.redhat.com/show_bug.cgi?id=477040
	
	The log size calculation is mostly copied from kernel code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1012&r2=1.1013
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/WHATS_NEW	2008/12/19 15:23:03	1.1012
+++ LVM2/WHATS_NEW	2008/12/19 15:24:52	1.1013
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Calculate mirror log size instead of using 1 extent.
   Check if requested major/minor pair is already used.
   Fix incorrect return value in help function.
   Fix vgrename using UUID in case there are VGs with the same name.
--- LVM2/lib/metadata/lv_alloc.h	2008/11/03 22:14:29	1.22
+++ LVM2/lib/metadata/lv_alloc.h	2008/12/19 15:24:53	1.23
@@ -47,7 +47,7 @@
                                       const struct segment_type *segtype,
                                       uint32_t stripes,
                                       uint32_t mirrors, uint32_t log_count,
-				      uint32_t extents,
+				      uint32_t log_region_size, uint32_t extents,
                                       struct dm_list *allocatable_pvs,
 				      alloc_policy_t alloc,
 				      struct dm_list *parallel_areas);
--- LVM2/lib/metadata/lv_manip.c	2008/12/04 15:54:27	1.160
+++ LVM2/lib/metadata/lv_manip.c	2008/12/19 15:24:53	1.161
@@ -516,6 +516,7 @@
 	uint32_t area_count;		/* Number of parallel areas */
 	uint32_t area_multiple;		/* seg->len = area_len * area_multiple */
 	uint32_t log_count;		/* Number of parallel 1-extent logs */
+	uint32_t log_region_size;	/* region size for log device */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
 	struct dm_list *parallel_areas;	/* PVs to avoid */
@@ -543,6 +544,7 @@
 					uint32_t mirrors,
 					uint32_t stripes,
 					uint32_t log_count,
+					uint32_t log_region_size,
 					struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
@@ -582,6 +584,7 @@
 
 	ah->area_count = area_count;
 	ah->log_count = log_count;
+	ah->log_region_size = log_region_size;
 	ah->alloc = alloc;
 	ah->area_multiple = calc_area_multiple(segtype, area_count);
 
@@ -704,6 +707,28 @@
 }
 
 /*
+ * Returns log device size in extents, algorithm from kernel code
+ */
+#define BYTE_SHIFT 3
+static uint32_t mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint32_t area_len)
+{
+	size_t area_size, bitset_size, log_size, region_count;
+
+	area_size = area_len * pe_size;
+	region_count = dm_div_up(area_size, region_size);
+
+	/* Work out how many "unsigned long"s we need to hold the bitset. */
+	bitset_size = dm_round_up(region_count, sizeof(uint32_t) << BYTE_SHIFT);
+	bitset_size >>= BYTE_SHIFT;
+
+	/* Log device holds both header and bitset. */
+	log_size = dm_round_up((MIRROR_LOG_OFFSET << SECTOR_SHIFT) + bitset_size, 1 << SECTOR_SHIFT);
+	log_size >>= SECTOR_SHIFT;
+
+	return dm_div_up(log_size, pe_size);
+}
+
+/*
  * This function takes a list of pv_areas and adds them to allocated_areas.
  * If the complete area is not needed then it gets split.
  * The part used is removed from the pv_map so it can't be allocated twice.
@@ -745,7 +770,9 @@
 	if (log_area) {
 		ah->log_area.pv = log_area->map->pv;
 		ah->log_area.pe = log_area->start;
-		ah->log_area.len = MIRROR_LOG_SIZE;	/* FIXME Calculate & check this */
+		ah->log_area.len = mirror_log_extents(ah->log_region_size,
+						      pv_pe_size(log_area->map->pv),
+						      area_len);
 		consume_pv_area(log_area, ah->log_area.len);
 	}
 
@@ -817,7 +844,7 @@
 
 	/* FIXME only_single_area_segments used as workaround to skip log LV - needs new param? */
 	if (!only_single_area_segments && seg_is_mirrored(seg) && seg->log_lv) {
-		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, MIRROR_LOG_SIZE,
+		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count?:1,
 				       NULL, 0, 0, 0, only_single_area_segments,
 				       fn, data)))
 			stack;
@@ -1256,7 +1283,7 @@
 				      const struct segment_type *segtype,
 				      uint32_t stripes,
 				      uint32_t mirrors, uint32_t log_count,
-				      uint32_t extents,
+				      uint32_t log_region_size, uint32_t extents,
 				      struct dm_list *allocatable_pvs,
 				      alloc_policy_t alloc,
 				      struct dm_list *parallel_areas)
@@ -1282,7 +1309,7 @@
 		alloc = vg->alloc;
 
 	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc, mirrors,
-			       stripes, log_count, parallel_areas)))
+			       stripes, log_count, log_region_size, parallel_areas)))
 		return_NULL;
 
 	if (!segtype_is_virtual(segtype) &&
@@ -1577,7 +1604,7 @@
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, status, extents, segtype);
 
-	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0,
+	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0, 0,
 				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
--- LVM2/lib/metadata/metadata.h	2008/12/04 15:54:27	1.185
+++ LVM2/lib/metadata/metadata.h	2008/12/19 15:24:53	1.186
@@ -34,7 +34,18 @@
 //#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
 //#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
-#define MIRROR_LOG_SIZE 1	/* Extents */
+#define MIRROR_LOG_OFFSET	2	/* sectors */
+
+/*
+ * Ceiling(n / sz)
+ */
+#define dm_div_up(n, sz) (((n) + (sz) - 1) / (sz))
+
+/*
+ * Ceiling(n / size) * size
+ */
+#define dm_round_up(n, sz) (dm_div_up((n), (sz)) * (sz))
+
 
 /* Various flags */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
--- LVM2/lib/metadata/mirror.c	2008/11/03 22:14:29	1.79
+++ LVM2/lib/metadata/mirror.c	2008/12/19 15:24:53	1.80
@@ -1171,7 +1171,7 @@
 							   lv->le_count,
 							   region_size);
 
-	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0,
+	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
 				    lv->le_count, allocatable_pvs, alloc,
 				    parallel_areas))) {
 		log_error("Unable to allocate mirror extents for %s.", lv->name);
@@ -1388,7 +1388,7 @@
 
 	/* allocate destination extents */
 	ah = allocate_extents(lv->vg, NULL, segtype,
-			      0, 0, log_count, 0,
+			      0, 0, log_count, region_size, 0,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror log.");
@@ -1443,7 +1443,7 @@
 		return_0;
 
 	ah = allocate_extents(lv->vg, NULL, segtype,
-			      stripes, mirrors, log_count, lv->le_count,
+			      stripes, mirrors, log_count, region_size, lv->le_count,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror(s).");


