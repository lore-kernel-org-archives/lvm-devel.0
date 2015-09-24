From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Sep 2015 16:56:40 +0000 (UTC)
Subject: master - alloc: Move _calc_area_multiple.
Message-ID: <20150924165640.A8731606D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a74e19f80958e0eafeb49ef7a346ba7421b5698
Commit:        4a74e19f80958e0eafeb49ef7a346ba7421b5698
Parent:        e773e719109ad54c289f86a54b316e787f0110c8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Sep 24 17:56:19 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 24 17:56:19 2015 +0100

alloc: Move _calc_area_multiple.

---
 lib/metadata/lv_manip.c |   90 +++++++++++++++++++++++-----------------------
 1 files changed, 45 insertions(+), 45 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 429a487..02a43b7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1264,6 +1264,51 @@ static int _lv_segment_add_areas(struct logical_volume *lv,
 	return 1;
 }
 
+static uint32_t _calc_area_multiple(const struct segment_type *segtype,
+				    const uint32_t area_count,
+				    const uint32_t stripes)
+{
+	if (!area_count)
+		return 1;
+
+	/* Striped */
+	if (segtype_is_striped(segtype))
+		return area_count;
+
+	/* Parity RAID (e.g. RAID 4/5/6) */
+	if (segtype_is_raid(segtype) && segtype->parity_devs) {
+		/*
+		 * As articulated in _alloc_init, we can tell by
+		 * the area_count whether a replacement drive is
+		 * being allocated; and if this is the case, then
+		 * there is no area_multiple that should be used.
+		 */
+		if (area_count <= segtype->parity_devs)
+			return 1;
+
+		return area_count - segtype->parity_devs;
+	}
+
+	/*
+	 * RAID10 - only has 2-way mirror right now.
+	 *          If we are to move beyond 2-way RAID10, then
+	 *          the 'stripes' argument will always need to
+	 *          be given.
+	 */
+	if (!strcmp(segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
+		if (!stripes)
+			return area_count / 2;
+		return stripes;
+	}
+
+	/* Mirrored stripes */
+	if (stripes)
+		return stripes;
+
+	/* Mirrored */
+	return 1;
+}
+
 /*
  * Reduce the size of an lv_segment.  New size can be zero.
  */
@@ -1519,51 +1564,6 @@ struct alloc_handle {
 	struct dm_list alloced_areas[0];
 };
 
-static uint32_t _calc_area_multiple(const struct segment_type *segtype,
-				    const uint32_t area_count,
-				    const uint32_t stripes)
-{
-	if (!area_count)
-		return 1;
-
-	/* Striped */
-	if (segtype_is_striped(segtype))
-		return area_count;
-
-	/* Parity RAID (e.g. RAID 4/5/6) */
-	if (segtype_is_raid(segtype) && segtype->parity_devs) {
-		/*
-		 * As articulated in _alloc_init, we can tell by
-		 * the area_count whether a replacement drive is
-		 * being allocated; and if this is the case, then
-		 * there is no area_multiple that should be used.
-		 */
-		if (area_count <= segtype->parity_devs)
-			return 1;
-
-		return area_count - segtype->parity_devs;
-	}
-
-	/*
-	 * RAID10 - only has 2-way mirror right now.
-	 *          If we are to move beyond 2-way RAID10, then
-	 *          the 'stripes' argument will always need to
-	 *          be given.
-	 */
-	if (!strcmp(segtype->name, _lv_type_names[LV_TYPE_RAID10])) {
-		if (!stripes)
-			return area_count / 2;
-		return stripes;
-	}
-
-	/* Mirrored stripes */
-	if (stripes)
-		return stripes;
-
-	/* Mirrored */
-	return 1;
-}
-
 /*
  * Returns log device size in extents, algorithm from kernel code
  */


