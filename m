From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Oct 2006 23:18:46 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/pv_map.c tools/t ...
Message-ID: <20061021231846.20780.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-21 23:18:44

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : pv_map.c 
	tools          : toollib.c 

Log message:
	Cope if same PV is included more than once in cmdline PE range list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.475&r2=1.476
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2006/10/19 12:53:46	1.475
+++ LVM2/WHATS_NEW	2006/10/21 23:18:43	1.476
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Cope if same PV is included more than once in cmdline PE range list.
   Set PV size to current device size if it is found to be zero.
   Add segment parameter to target_present functions.
 
--- LVM2/lib/metadata/pv_map.c	2005/10/16 23:03:58	1.25
+++ LVM2/lib/metadata/pv_map.c	2006/10/21 23:18:43	1.26
@@ -19,6 +19,8 @@
 
 /*
  * Areas are maintained in size order, largest first.
+ *
+ * FIXME Cope with overlap.
  */
 static void _insert_area(struct list *head, struct pv_area *a)
 {
@@ -126,22 +128,31 @@
 
 static int _create_maps(struct dm_pool *mem, struct list *pvs, struct list *pvms)
 {
-	struct pv_map *pvm;
+	struct pv_map *pvm, *pvm2;
 	struct pv_list *pvl;
 
 	list_iterate_items(pvl, pvs) {
 		if (!(pvl->pv->status & ALLOCATABLE_PV))
 			continue;
 
-		if (!(pvm = dm_pool_zalloc(mem, sizeof(*pvm)))) {
-			stack;
-			return 0;
-		}
+		pvm = NULL;
 
-		pvm->pv = pvl->pv;
-
-		list_init(&pvm->areas);
-		list_add(pvms, &pvm->list);
+		list_iterate_items(pvm2, pvms)
+			if (pvm2->pv->dev == pvl->pv->dev) {
+				pvm = pvm2;
+				break;
+			}
+
+		if (!pvm) {
+			if (!(pvm = dm_pool_zalloc(mem, sizeof(*pvm)))) {
+				stack;
+				return 0;
+			}
+
+			pvm->pv = pvl->pv;
+			list_init(&pvm->areas);
+			list_add(pvms, &pvm->list);
+		}
 
 		if (!_create_all_areas_for_pv(mem, pvm, pvl->pe_ranges)) {
 			stack;
--- LVM2/tools/toollib.c	2006/10/02 16:15:03	1.90
+++ LVM2/tools/toollib.c	2006/10/21 23:18:43	1.91
@@ -844,23 +844,24 @@
 /*
  * Process physical extent range specifiers
  */
-static int _add_pe_range(struct dm_pool *mem, struct list *pe_ranges,
-			 uint32_t start, uint32_t count)
+static int _add_pe_range(struct dm_pool *mem, const char *pvname,
+			 struct list *pe_ranges, uint32_t start, uint32_t count)
 {
 	struct pe_range *per;
 
-	log_debug("Adding PE range: start PE %" PRIu32 " length %" PRIu32,
-		  start, count);
+	log_debug("Adding PE range: start PE %" PRIu32 " length %" PRIu32
+		  " on %s", start, count, pvname);
 
 	/* Ensure no overlap with existing areas */
 	list_iterate_items(per, pe_ranges) {
 		if (((start < per->start) && (start + count - 1 >= per->start))
 		    || ((start >= per->start) &&
 			(per->start + per->count - 1) >= start)) {
-			log_error("Overlapping PE ranges detected (%" PRIu32
-				  "-%" PRIu32 ", %" PRIu32 "-%" PRIu32 ")",
+			log_error("Overlapping PE ranges specified (%" PRIu32
+				  "-%" PRIu32 ", %" PRIu32 "-%" PRIu32 ")"
+				  " on %s",
 				  start, start + count - 1, per->start,
-				  per->start + per->count - 1);
+				  per->start + per->count - 1, pvname);
 			return 0;
 		}
 	}
@@ -878,14 +879,14 @@
 }
 
 static int _parse_pes(struct dm_pool *mem, char *c, struct list *pe_ranges,
-		      uint32_t size)
+		      const char *pvname, uint32_t size)
 {
 	char *endptr;
 	uint32_t start, end;
 
 	/* Default to whole PV */
 	if (!c) {
-		if (!_add_pe_range(mem, pe_ranges, UINT32_C(0), size)) {
+		if (!_add_pe_range(mem, pvname, pe_ranges, UINT32_C(0), size)) {
 			stack;
 			return 0;
 		}
@@ -935,7 +936,7 @@
 			return 0;
 		}
 
-		if (!_add_pe_range(mem, pe_ranges, start, end - start + 1)) {
+		if (!_add_pe_range(mem, pvname, pe_ranges, start, end - start + 1)) {
 			stack;
 			return 0;
 		}
@@ -949,46 +950,56 @@
 	return 0;
 }
 
-static void _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
+static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
 			     char *colon, int allocatable_only, struct list *r)
 {
 	const char *pvname;
-	struct pv_list *new_pvl;
+	struct pv_list *new_pvl = NULL, *pvl2;
 	struct list *pe_ranges;
 
 	pvname = dev_name(pvl->pv->dev);
 	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
 		log_error("Physical volume %s not allocatable", pvname);
-		return;
+		return 1;
 	}
 
 	if (allocatable_only &&
 	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
 		log_err("No free extents on physical volume \"%s\"", pvname);
-		return;
+		return 1;
 	}
 
-	if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
-		log_err("Unable to allocate physical volume list.");
-		return;
-	}
+	list_iterate_items(pvl2, r)
+		if (pvl->pv->dev == pvl2->pv->dev) {
+			new_pvl = pvl2;
+			break;
+		}
+	
+	if (!new_pvl) {
+		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
+			log_err("Unable to allocate physical volume list.");
+			return 0;
+		}
 
-	memcpy(new_pvl, pvl, sizeof(*new_pvl));
+		memcpy(new_pvl, pvl, sizeof(*new_pvl));
 
-	if (!(pe_ranges = dm_pool_alloc(mem, sizeof(*pe_ranges)))) {
-		log_error("Allocation of pe_ranges list failed");
-		return;
+		if (!(pe_ranges = dm_pool_alloc(mem, sizeof(*pe_ranges)))) {
+			log_error("Allocation of pe_ranges list failed");
+			return 0;
+		}
+		list_init(pe_ranges);
+		new_pvl->pe_ranges = pe_ranges;
+		list_add(r, &new_pvl->list);
 	}
-	list_init(pe_ranges);
 
 	/* Determine selected physical extents */
-	if (!_parse_pes(mem, colon, pe_ranges, pvl->pv->pe_count)) {
+	if (!_parse_pes(mem, colon, pe_ranges, dev_name(pvl->pv->dev),
+			pvl->pv->pe_count)) {
 		stack;
-		return;
+		return 0;
 	}
-	new_pvl->pe_ranges = pe_ranges;
 
-	list_add(r, &new_pvl->list);
+	return 1;
 }
 
 struct list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
@@ -1021,8 +1032,12 @@
 			list_iterate_items(pvl, &vg->pvs) {
 				if (str_list_match_item(&pvl->pv->tags,
 							tagname)) {
-					_create_pv_entry(mem, pvl, NULL,
-							 allocatable_only, r);
+					if (!_create_pv_entry(mem, pvl, NULL,
+							      allocatable_only,
+							      r)) {
+						stack;
+						return NULL;
+					}
 				}
 			}
 			continue;
@@ -1044,7 +1059,10 @@
 				"Volume Group \"%s\"", pvname, vg->name);
 			return NULL;
 		}
-		_create_pv_entry(mem, pvl, colon, allocatable_only, r);
+		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r)) {
+			stack;
+			return NULL;
+		}
 	}
 
 	if (list_empty(r))


