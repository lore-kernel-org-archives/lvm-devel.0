From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 19 Jan 2010 20:22:06 -0600
Subject: [PATCH 5 of 10] LVM: remove unused parameter
Message-ID: <201001200222.o0K2M6Qc024112@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-remove-unused-parameter.patch

Here we get rid of completely unused parameters.  No-one
uses them and they are confusing.  (They imply a certain
level of processing is down by the time these functions
are called, which is not the case.)  If they were just
extra params, I wouldn't bother, but they add to confusion.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -645,8 +645,7 @@ static int _setup_alloced_segment(struct
 				  uint32_t stripe_size,
 				  const struct segment_type *segtype,
 				  struct alloced_area *aa,
-				  uint32_t region_size,
-				  struct logical_volume *log_lv __attribute((unused)))
+				  uint32_t region_size)
 {
 	uint32_t s, extents, area_multiple;
 	struct lv_segment *seg;
@@ -686,15 +685,14 @@ static int _setup_alloced_segments(struc
 				   uint64_t status,
 				   uint32_t stripe_size,
 				   const struct segment_type *segtype,
-				   uint32_t region_size,
-				   struct logical_volume *log_lv)
+				   uint32_t region_size)
 {
 	struct alloced_area *aa;
 
 	dm_list_iterate_items(aa, &alloced_areas[0]) {
 		if (!_setup_alloced_segment(lv, status, area_count,
 					    stripe_size, segtype, aa,
-					    region_size, log_lv))
+					    region_size))
 			return_0;
 	}
 
@@ -1397,7 +1395,7 @@ int lv_add_segment(struct alloc_handle *
 	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
 				     num_areas, status,
 				     stripe_size, segtype,
-				     region_size, log_lv))
+				     region_size))
 		return_0;
 
 	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {


