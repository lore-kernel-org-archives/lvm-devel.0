From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 29 Mar 2011 08:04:41 -0500
Subject: [PATCH 1 of 2] LVM: lv_extend param reduction
Message-ID: <201103291304.p2TD4fCw024070@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-lv_extend-param-reduction.patch

Remove unnecessary/unused parameters in 'lv_extend'.

This is to simplify the parameter list before the next patch adds new
parameters.

Please note that I have pulled the unused 'status' parameter because
lv_extend is always called with 'status = 0u'.


Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -2148,16 +2148,14 @@ int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv __attribute__((unused)),
-	      uint32_t mirrored_pe __attribute__((unused)),
-	      uint64_t status, struct dm_list *allocatable_pvs,
+	      struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc)
 {
 	int r = 1;
 	struct alloc_handle *ah;
 
 	if (segtype_is_virtual(segtype))
-		return lv_add_virtual_segment(lv, status, extents, segtype);
+		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0, 0,
 				    extents, allocatable_pvs, alloc, NULL)))
@@ -2165,7 +2163,7 @@ int lv_extend(struct logical_volume *lv,
 
 	if (mirrors < 2)
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
-				   stripe_size, status, 0);
+				   stripe_size, 0u, 0);
 	else
 		r = _lv_extend_mirror(ah, lv, extents, 0, stripes, stripe_size);
 
@@ -3389,7 +3387,7 @@ static struct logical_volume *_create_vi
 				   ALLOC_INHERIT, vg)))
 		return_NULL;
 
-	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
+	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents,
 		       NULL, ALLOC_INHERIT))
 		return_NULL;
 
@@ -3611,7 +3609,7 @@ int lv_create_single(struct volume_group
 		dm_list_splice(&lv->tags, &lp->tags);
 
 	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       1, lp->extents, NULL, 0u, 0u, lp->pvh, lp->alloc))
+		       1, lp->extents, lp->pvh, lp->alloc))
 		return_0;
 
 	if (lp->mirrors > 1) {
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -501,8 +501,7 @@ int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
-	      uint64_t status, struct dm_list *allocatable_pvs,
+	      struct dm_list *allocatable_pvs,
 	      alloc_policy_t alloc);
 
 /* lv must be part of lv->vg->lvs */
Index: LVM2/tools/lvresize.c
===================================================================
--- LVM2.orig/tools/lvresize.c
+++ LVM2/tools/lvresize.c
@@ -673,7 +673,7 @@ static int _lvresize(struct cmd_context 
 		   !lv_extend(lv, lp->segtype, lp->stripes,
 			      lp->stripe_size, lp->mirrors,
 			      lp->extents - lv->le_count,
-			      NULL, 0u, 0u, pvh, alloc)) {
+			      pvh, alloc)) {
 		stack;
 		return ECMD_FAILED;
 	}


