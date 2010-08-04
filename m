From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 04 Aug 2010 17:51:39 -0500
Subject: [PATCH] Specified PVs being ignored when performing mirror split (bug 619221)
Message-ID: <1280962299.15228.2.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

Fix for bug 619221 - log device splitting regression

An incorrect fix for an annoyance has caused a regression.  The offending
check-in was: 
http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c?cvsroot=lvm2&f=h#rev1.140

This check-in caused any PVs specified on the command line to be
ignored when performing a mirror split.

This patch reverses the aforementioned check-in (solving the regressions)
and posits a new solution to the list reversal problem.  The original
problem was that we would always take the lowest mimage LVs from a mirror
when performing a split, but what we really want is to take the highest
mimage LVs.  This patch accomplishes that by simply not short-circuiting
the processing done in _move_removable_mimages_to_end.  This function
would start from the beginning of the mirror sub-lv list and work its
way to the end - quiting when it found just enough to cover the requested
amount.  This would always leave the least desirable LVs to be removed
at the end of the list.


Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -524,7 +524,7 @@ static int _move_removable_mimages_to_en
 					  uint32_t count,
 					  struct dm_list *removable_pvs)
 {
-	int i, images;
+	int i, images, matches = 0;
 	struct logical_volume *sub_lv;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 
@@ -536,7 +536,7 @@ static int _move_removable_mimages_to_en
 	 * the begining of the list again.  We must visit the
 	 * images up to the last one we just moved.
 	 */
-	for (images = mirrored_seg->area_count; images && count; images--) {
+	for (images = mirrored_seg->area_count; images; images--) {
 		for (i = 0; i < images; i++) {
 			sub_lv = seg_lv(mirrored_seg, i);
 
@@ -544,17 +544,17 @@ static int _move_removable_mimages_to_en
 			    is_mirror_image_removable(sub_lv, removable_pvs)) {
 				if (!shift_mirror_images(mirrored_seg, i))
 					return_0;
-				count--;
+				matches++;
 				break;
 			}
 		}
 
 		/* Did we shift any images? */
 		if (i == images)
-			return 0;
+			break;
 	}
 
-	return !count;
+	return (matches < count) ? 0 : 1;
 }
 
 static int _mirrored_lv_in_sync(struct logical_volume *lv)
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -1015,7 +1015,7 @@ static int _lvconvert_mirrors_aux(struct
 						  lv->le_count,
 						  lp->region_size);
 
-	if (!operable_pvs && !lp->keep_mimages)
+	if (!operable_pvs)
 		operable_pvs = lp->pvh;
 
 	seg = first_seg(lv);



