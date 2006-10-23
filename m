From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Oct 2006 15:54:52 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20061023155452.20354.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-23 15:54:51

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c pv_map.c pv_map.h 

Log message:
	Perform high-level free space check before each allocation attempt.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.477&r2=1.478
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2006/10/23 11:46:15	1.477
+++ LVM2/WHATS_NEW	2006/10/23 15:54:51	1.478
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Perform high-level free space check before each allocation attempt.
   Don't allow a node to remove an LV that's exclusively active on anther node.
   Cope if same PV is included more than once in cmdline PE range list.
   Set PV size to current device size if it is found to be zero.
--- LVM2/lib/metadata/lv_manip.c	2006/10/08 12:01:12	1.110
+++ LVM2/lib/metadata/lv_manip.c	2006/10/23 15:54:51	1.111
@@ -890,8 +890,17 @@
 	uint32_t next_le;
 	struct seg_pvs *spvs;
 	struct list *parallel_pvs;
+	uint32_t free_pes;
+
+	/* Is there enough total space? */
+	free_pes = pv_maps_size(pvms);
+	if (needed > free_pes) {
+		log_error("Insufficient free space: %" PRIu32 " extents needed,"
+			  " but only %" PRIu32 " available", needed,
+			  free_pes);
+		return 0;
+	}
 
-	/* FIXME Do calculations on free extent counts before selecting space */
 	/* FIXME Select log PV appropriately if there isn't one yet */
 
 	/* Are there any preceding segments we must follow on from? */
--- LVM2/lib/metadata/pv_map.c	2006/10/21 23:18:43	1.26
+++ LVM2/lib/metadata/pv_map.c	2006/10/23 15:54:51	1.27
@@ -32,6 +32,7 @@
 	}
 
 	list_add(&pva->list, &a->list);
+	a->map->pe_count += a->count;
 }
 
 static int _create_single_area(struct dm_pool *mem, struct pv_map *pvm,
@@ -191,6 +192,7 @@
 void consume_pv_area(struct pv_area *pva, uint32_t to_go)
 {
 	list_del(&pva->list);
+	pva->map->pe_count -= pva->count;
 
 	assert(to_go <= pva->count);
 
@@ -201,3 +203,14 @@
 		_insert_area(&pva->map->areas, pva);
 	}
 }
+
+uint32_t pv_maps_size(struct list *pvms)
+{
+	struct pv_map *pvm;
+	uint32_t pe_count = 0;
+
+	list_iterate_items(pvm, pvms)
+		pe_count += pvm->pe_count;
+
+	return pe_count;
+}
--- LVM2/lib/metadata/pv_map.h	2005/10/16 23:03:58	1.7
+++ LVM2/lib/metadata/pv_map.h	2006/10/23 15:54:51	1.8
@@ -37,6 +37,7 @@
 struct pv_map {
 	struct physical_volume *pv;
 	struct list areas;		/* struct pv_areas */
+	uint32_t pe_count;		/* Total number of PEs */
 
 	struct list list;
 };
@@ -49,4 +50,6 @@
 
 void consume_pv_area(struct pv_area *area, uint32_t to_go);
 
+uint32_t pv_maps_size(struct list *pvms);
+
 #endif


