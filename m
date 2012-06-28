From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Jun 2012 00:11:55 +0000 (UTC)
Subject: master - discards: don't discard reconfigured extents
Message-ID: <20120628001155.05F1D1719@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07a25c249b3ed449ca9f678c19ddb320967adaa9
Commit:        07a25c249b3ed449ca9f678c19ddb320967adaa9
Parent:        e59f6981e6547fcffc8bd86b435dac3e805b9fc0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 27 21:53:02 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 27 22:12:01 2012 +0100

discards: don't discard reconfigured extents

Update release_lv_segment_area not to discard any PV extents,
as it also gets used when moving extents between LVs.
Instead, call a new function release_and_discard_lv_segment_area() in
the two places where data should be discarded - lv_reduce() and
remove_mirrors_from_segments().
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_alloc.h |    1 +
 lib/metadata/lv_manip.c |   21 ++++++++++++++++++---
 lib/metadata/mirror.c   |    2 +-
 4 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bc9cea7..0eac530 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Never issue discards when LV extents are being reconfigured, not deleted.
   Allow release_lv_segment_area to fail as functions it calls can fail.
   Open device read-only to obtain readahead value.
   Fix lvconvert error path NULL pointer dereference.
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index 71ca1ab..9f8e0e3 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -42,6 +42,7 @@ int move_lv_segment_area(struct lv_segment *seg_to, uint32_t area_to,
 			 struct lv_segment *seg_from, uint32_t area_from);
 int release_lv_segment_area(struct lv_segment *seg, uint32_t s,
 			    uint32_t area_reduction);
+int release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s, uint32_t area_reduction);
 
 struct alloc_handle;
 struct alloc_handle *allocate_extents(struct volume_group *vg,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bdcc925..a0be887 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -299,17 +299,22 @@ struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 	return seg;
 }
 
-int release_lv_segment_area(struct lv_segment *seg, uint32_t s,
-			    uint32_t area_reduction)
+static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s,
+						uint32_t area_reduction, int with_discard)
 {
 	if (seg_type(seg, s) == AREA_UNASSIGNED)
 		return 1;
 
 	if (seg_type(seg, s) == AREA_PV) {
+		if (with_discard && !discard_pv_segment(seg_pvseg(seg, s), area_reduction))
+			return_0;
+
 		if (!release_pv_segment(seg_pvseg(seg, s), area_reduction))
 			return_0;
+
 		if (seg->area_len == area_reduction)
 			seg_type(seg, s) = AREA_UNASSIGNED;
+
 		return 1;
 	}
 
@@ -365,6 +370,16 @@ int release_lv_segment_area(struct lv_segment *seg, uint32_t s,
 	return 1;
 }
 
+int release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s, uint32_t area_reduction)
+{
+	return _release_and_discard_lv_segment_area(seg, s, area_reduction, 1);
+}
+
+int release_lv_segment_area(struct lv_segment *seg, uint32_t s, uint32_t area_reduction)
+{
+	return _release_and_discard_lv_segment_area(seg, s, area_reduction, 0);
+}
+
 /*
  * Move a segment area from one segment to another
  */
@@ -501,7 +516,7 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 		area_reduction = reduction;
 
 	for (s = 0; s < seg->area_count; s++)
-		if (!release_lv_segment_area(seg, s, area_reduction))
+		if (!release_and_discard_lv_segment_area(seg, s, area_reduction))
 			return_0;
 
 	seg->len -= reduction;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index d943175..61e4b47 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1469,7 +1469,7 @@ int remove_mirrors_from_segments(struct logical_volume *lv,
 		}
 
 		for (s = new_mirrors + 1; s < seg->area_count; s++)
-			if (!release_lv_segment_area(seg, s, seg->area_len))
+			if (!release_and_discard_lv_segment_area(seg, s, seg->area_len))
 				return_0;
 
 		seg->area_count = new_mirrors + 1;


