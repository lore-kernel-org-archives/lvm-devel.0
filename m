From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Jun 2014 03:05:15 +0000 (UTC)
Subject: master - misc: after releasing a PV segment, merge it with any adjacent free space
Message-ID: <20140626030515.3BD6A610A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7028fd31a0f2d2234ffdd1b94ea6ae6128ca9362
Commit:        7028fd31a0f2d2234ffdd1b94ea6ae6128ca9362
Parent:        b35fb0b15af1d87693be286f0630e95622056a77
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 25 22:04:58 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 25 22:04:58 2014 -0500

misc: after releasing a PV segment, merge it with any adjacent free space

Previously, the seg_pvs used to track free and allocated space where left
in place after 'release_pv_segment' was called to free space from an LV.
Now, an attempt is made to combine any adjacent seg_pvs that also track
free space.  Usually, this doesn't provide much benefit, but in a case
where one command might free some space and then do an allocation, it
can make a difference.  One such case is during a repair of a RAID LV,
where one PV of a multi-PV image fails.  This new behavior is used when
the replacement image can be allocated from the remaining space of the
PV that did not fail.  (First the entire image with the failed PV is
removed.  Then the image is reallocated from the remaining PVs.)
---
 lib/metadata/pv_manip.c |   67 ++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 2717031..2cc7892 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -246,8 +246,65 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 	return 1;
 }
 
+static int _merge_free_pv_segment(struct pv_segment *peg)
+{
+	struct dm_list *l;
+	struct pv_segment *merge_peg;
+
+	if (peg->lvseg) {
+		log_error(INTERNAL_ERROR
+			  "_merge_free_pv_seg called on a"
+			  " segment that is not free.");
+		return 0;
+	}
+
+	/*
+	 * FIXME:
+	 * Should we free the list element once it is deleted
+	 * from the list?  I think not.  It is likely part of
+	 * a mempool.
+	 */
+	/* Attempt to merge with Free space before */
+	if ((l = dm_list_prev(&peg->pv->segments, &peg->list))) {
+		merge_peg = dm_list_item(l, struct pv_segment);
+		if (!merge_peg->lvseg) {
+			merge_peg->len += peg->len;
+			dm_list_del(&peg->list);
+			peg = merge_peg;
+		}
+	}
+
+	/* Attempt to merge with Free space after */
+	if ((l = dm_list_next(&peg->pv->segments, &peg->list))) {
+		merge_peg = dm_list_item(l, struct pv_segment);
+		if (!merge_peg->lvseg) {
+			peg->len += merge_peg->len;
+			dm_list_del(&merge_peg->list);
+		}
+	}
+
+	return 1;
+}
+
+/*
+ * release_pv_segment
+ * @peg
+ * @area_reduction
+ *
+ * WARNING: When release_pv_segment is called, the freed space may be
+ *          merged into the 'pv_segment's before and after it in the
+ *          list if they are also free.  Thus, any iterators of the
+ *          'pv->segments' list that call this function must be aware
+ *          that the list can change in a way that is unsafe even for
+ *          *_safe iterators.  Restart the iterator in these cases.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 {
+	struct dm_list *l;
+	struct pv_segment *merge_peg;
+
 	if (!peg->lvseg) {
 		log_error("release_pv_segment with unallocated segment: "
 			  "%s PE %" PRIu32, pv_dev_name(peg->pv), peg->pe);
@@ -261,9 +318,7 @@ int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 		peg->lvseg = NULL;
 		peg->lv_area = 0;
 
-		/* FIXME merge free space */
-
-		return 1;
+		return _merge_free_pv_segment(peg);
 	}
 
 	if (!pv_split_segment(peg->lvseg->lv->vg->vgmem,
@@ -271,6 +326,12 @@ int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 			      area_reduction, NULL))
 		return_0;
 
+	/* The segment after 'peg' now holds free space, try to merge it */
+	if ((l = dm_list_next(&peg->pv->segments, &peg->list))) {
+		merge_peg = dm_list_item(l, struct pv_segment);
+		return _merge_free_pv_segment(merge_peg);
+	}
+
 	return 1;
 }
 


