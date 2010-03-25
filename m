From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 02:31:50 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20100325023150.4496.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 02:31:49

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c pv_map.h 

Log message:
	Introduce pv_area_used into allocation algorithm and add debug messages.
	
	This is the next preparatory step towards better --alloc anywhere
	support and is not intended to break anything that currently works so
	please report any problems - segfaults, bogus data in the new debug
	messages, or if the code now chooses bizarre allocation layouts.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1477&r2=1.1478
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.212&r2=1.213
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2010/03/24 22:25:11	1.1477
+++ LVM2/WHATS_NEW	2010/03/25 02:31:48	1.1478
@@ -1,7 +1,8 @@
 Version 2.02.63 - 
 ================================
-  Add "monitoring" option to "activation" section of lvm.conf.
-  Add --monitor and --ignoremonitoring support to lvcreate.
+  Introduce pv_area_used into allocation algorithm and add debug messages.
+  Add activation/monitoring to lvm.conf.
+  Add --monitor and --ignoremonitoring to lvcreate.
   Allow dynamic extension of array of areas selected as allocation candidates.
   Export and use only valid cookie value in test suite.
   Remove const modifier for struct volume_group* from process_each_lv_in_vg().
--- LVM2/lib/metadata/lv_manip.c	2010/03/23 22:30:19	1.212
+++ LVM2/lib/metadata/lv_manip.c	2010/03/25 02:31:49	1.213
@@ -735,7 +735,7 @@
  * The part used is removed from the pv_map so it can't be allocated twice.
  */
 static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t needed,
-				struct pv_area **areas, uint32_t *allocated,
+				struct pv_area_used *areas, uint32_t *allocated,
 				unsigned log_needs_allocating, uint32_t ix_log_offset)
 {
 	uint32_t area_len, len, remaining;
@@ -749,8 +749,8 @@
 
 	/* Reduce area_len to the smallest of the areas */
 	for (s = 0; s < ah->area_count; s++)
-		if (area_len > areas[s]->count)
-			area_len = areas[s]->count;
+		if (area_len > areas[s].used)
+			area_len = areas[s].used;
 
 	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) * total_area_count))) {
 		log_error("alloced_area allocation failed");
@@ -769,11 +769,15 @@
 			len = ah->log_len;
 		}
 
-		aa[s].pv = areas[s + ix_log_skip]->map->pv;
-		aa[s].pe = areas[s + ix_log_skip]->start;
+		aa[s].pv = areas[s + ix_log_skip].pva->map->pv;
+		aa[s].pe = areas[s + ix_log_skip].pva->start;
 		aa[s].len = len;
 
-		consume_pv_area(areas[s + ix_log_skip], len);
+		log_debug("Allocating parallel area %" PRIu32
+			  " on %s start PE %" PRIu32 " length %" PRIu32 ".",
+			  s, dev_name(aa[s].pv->dev), aa[s].pe, len);
+
+		consume_pv_area(areas[s + ix_log_skip].pva, len);
 
 		dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 	}
@@ -863,13 +867,13 @@
 
 static int _comp_area(const void *l, const void *r)
 {
-	const struct pv_area *lhs = *((const struct pv_area * const *) l);
-	const struct pv_area *rhs = *((const struct pv_area * const *) r);
+	const struct pv_area_used *lhs = *((const struct pv_area_used * const *) l);
+	const struct pv_area_used *rhs = *((const struct pv_area_used * const *) r);
 
-	if (lhs->count < rhs->count)
+	if (lhs->used < rhs->used)
 		return 1;
 
-	else if (lhs->count > rhs->count)
+	else if (lhs->used > rhs->used)
 		return -1;
 
 	return 0;
@@ -881,7 +885,7 @@
 struct pv_match {
 	int (*condition)(struct pv_segment *pvseg, struct pv_area *pva);
 
-	struct pv_area **areas;
+	struct pv_area_used *areas;
 	struct pv_area *pva;
 	uint32_t areas_size;
 	int s;	/* Area index of match */
@@ -924,7 +928,12 @@
 	if (s >= pvmatch->areas_size)
 		return 1;
 
-	pvmatch->areas[s] = pvmatch->pva;
+	/*
+	 * Only used for cling and contiguous policies so its safe to say all
+	 * the available space is used.
+	 */
+	pvmatch->areas[s].pva = pvmatch->pva;
+	pvmatch->areas[s].used = pvmatch->pva->count;
 
 	return 2;	/* Finished */
 }
@@ -934,7 +943,7 @@
  */
 static int _check_cling(struct cmd_context *cmd,
 			struct lv_segment *prev_lvseg, struct pv_area *pva,
-			struct pv_area **areas, uint32_t areas_size)
+			struct pv_area_used *areas, uint32_t areas_size)
 {
 	struct pv_match pvmatch;
 	int r;
@@ -962,7 +971,7 @@
  */
 static int _check_contiguous(struct cmd_context *cmd,
 			     struct lv_segment *prev_lvseg, struct pv_area *pva,
-			     struct pv_area **areas, uint32_t areas_size)
+			     struct pv_area_used *areas, uint32_t areas_size)
 {
 	struct pv_match pvmatch;
 	int r;
@@ -989,7 +998,7 @@
  * Choose sets of parallel areas to use, respecting any constraints.
  */
 static int _find_parallel_space(struct alloc_handle *ah, alloc_policy_t alloc,
-				struct dm_list *pvms, struct pv_area ***areas_ptr,
+				struct dm_list *pvms, struct pv_area_used **areas_ptr,
 				uint32_t *areas_size_ptr, unsigned can_split,
 				struct lv_segment *prev_lvseg,
 				uint32_t *allocated, uint32_t needed)
@@ -1005,6 +1014,7 @@
 	unsigned too_small_for_log_count; /* How many too small for log? */
 	uint32_t max_parallel;	/* Maximum extents to allocate */
 	uint32_t next_le;
+	uint32_t required;	/* Extents we're trying to obtain from a given area */
 	struct seg_pvs *spvs;
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
@@ -1062,6 +1072,9 @@
 			}
 		}
 
+		log_needs_allocating = (ah->log_area_count &&
+					dm_list_empty(&ah->alloced_areas[ah->area_count])) ?  1 : 0;
+
 		/*
 		 * Put the smallest area of each PV that is at least the
 		 * size we need into areas array.  If there isn't one
@@ -1121,30 +1134,44 @@
 				      !(alloc == ALLOC_ANYWHERE))))
 					goto next_pv;
 
+				/*
+				 * Except with ALLOC_ANYWHERE, replace first area with this
+				 * one which is smaller but still big enough.
+				 */
 				if (!already_found_one ||
 				    alloc == ALLOC_ANYWHERE) {
 					ix++;
 					already_found_one = 1;
 				}
 
+				if (ix + ix_offset - 1 < ah->area_count)
+					required = (max_parallel - *allocated) / ah->area_multiple;
+				else
+					required = ah->log_len;
+
+				if (required > pva->count)
+					required = pva->count;
+
 				/* Expand areas array if needed after an area was split. */
 				if (ix + ix_offset > *areas_size_ptr) {
 					*areas_size_ptr *= 2;
 					*areas_ptr = dm_realloc(*areas_ptr, sizeof(**areas_ptr) * (*areas_size_ptr));
 				}
-				(*areas_ptr)[ix + ix_offset - 1] = pva;
+				(*areas_ptr)[ix + ix_offset - 1].pva = pva;
+				(*areas_ptr)[ix + ix_offset - 1].used = required;
+				log_debug("Trying allocation area %" PRIu32 " on %s start PE %" PRIu32
+					  " length %" PRIu32 " leaving %" PRIu32 ".",
+					  ix + ix_offset - 1, dev_name(pva->map->pv->dev), pva->start, required,
+					  pva->count - required);
 			}
 		next_pv:
-			if (ix >= *areas_size_ptr)
+			if (ix + ix_offset >= ah->area_count + (log_needs_allocating ? ah->log_area_count : 0))
 				break;
 		}
 
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
-		log_needs_allocating = (ah->log_area_count &&
-					dm_list_empty(&ah->alloced_areas[ah->area_count])) ?  1 : 0;
-
 		if (ix + ix_offset < ah->area_count +
 		   (log_needs_allocating ? ah->log_area_count : 0))
 			break;
@@ -1166,7 +1193,7 @@
 			/* How many areas are too small for the log? */
 			while (too_small_for_log_count < ix_offset + ix &&
 			       (*((*areas_ptr) + ix_offset + ix - 1 -
-				  too_small_for_log_count))->count < ah->log_len)
+				  too_small_for_log_count)).used < ah->log_len)
 				too_small_for_log_count++;
 			ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
 		}
@@ -1197,7 +1224,7 @@
 		     unsigned can_split,
 		     struct dm_list *allocatable_pvs)
 {
-	struct pv_area **areas;
+	struct pv_area_used *areas;
 	uint32_t allocated = lv ? lv->le_count : 0;
 	uint32_t old_allocated;
 	struct lv_segment *prev_lvseg = NULL;
@@ -1206,12 +1233,16 @@
 	uint32_t areas_size;
 	alloc_policy_t alloc;
 	struct alloced_area *aa;
+	unsigned log_allocated;
 
 	if (allocated >= ah->new_extents && !ah->log_area_count) {
 		log_error("_allocate called with no work to do!");
 		return 1;
 	}
 
+	if (!ah->log_area_count)
+		log_allocated = 1;
+
 	if (ah->alloc == ALLOC_CONTIGUOUS)
 		can_split = 0;
 
@@ -1252,6 +1283,11 @@
 	/* Attempt each defined allocation policy in turn */
 	for (alloc = ALLOC_CONTIGUOUS; alloc < ALLOC_INHERIT; alloc++) {
 		old_allocated = allocated;
+		log_debug("Trying allocation using %s policy.  "
+			  "Need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log extents.",
+			  get_alloc_string(alloc),
+			  (ah->new_extents - allocated) / ah->area_multiple,
+			  ah->area_count, log_allocated ? 0 : ah->log_area_count);
 		if (!_find_parallel_space(ah, alloc, pvms, &areas,
 					  &areas_size, can_split,
 					  prev_lvseg, &allocated, ah->new_extents))
@@ -1259,6 +1295,9 @@
 		if ((allocated == ah->new_extents) || (ah->alloc == alloc) ||
 		    (!can_split && (allocated != old_allocated)))
 			break;
+		/* Log is always allocated the first time anything is allocated. */
+		if (old_allocated != allocated)
+			log_allocated = 1;
 	}
 
 	if (allocated != ah->new_extents) {
--- LVM2/lib/metadata/pv_map.h	2008/11/03 22:14:29	1.10
+++ LVM2/lib/metadata/pv_map.h	2010/03/25 02:31:49	1.11
@@ -34,6 +34,18 @@
 	struct dm_list list;		/* pv_map.areas */
 };
 
+/*
+ * When building up a potential group of "parallel" extent ranges during
+ * an allocation attempt, track the maximum number of extents that may
+ * need to be used as a particular parallel area.  Several of these
+ * structs may reference the same pv_area, but 'used' may differ between
+ * them.
+ */
+struct pv_area_used {
+	struct pv_area *pva;
+	uint32_t used;
+};
+
 struct pv_map {
 	struct physical_volume *pv;
 	struct dm_list areas;		/* struct pv_areas */
@@ -49,6 +61,7 @@
 			    struct dm_list *allocatable_pvs);
 
 void consume_pv_area(struct pv_area *area, uint32_t to_go);
+void reinsert_reduced_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);
 


