From: Milan Broz <mbroz@redhat.com>
Date: Mon, 29 Mar 2010 15:12:57 +0200
Subject: [PATCH 4/5] Do not traverse PV segment list twice.
In-Reply-To: <cover.1269866168.git.mbroz@redhat.com>
References: <cover.1269866168.git.mbroz@redhat.com>
Message-ID: <bc3f172e447130e28915c38ea55903551fe567a9.1269866168.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In addition to previous patch, we really do not need
to search for segment which was just allocated in
split request.

Make pv_split_segment function return newly allocated
(split) segment also.

(So after this patch, there is only one user
of slow find_peg_by_pe).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/pv_alloc.h |    3 ++-
 lib/metadata/pv_manip.c |   39 +++++++++++++++++++++++----------------
 2 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/pv_alloc.h b/lib/metadata/pv_alloc.h
index 7c67b2c..601bbf1 100644
--- a/lib/metadata/pv_alloc.h
+++ b/lib/metadata/pv_alloc.h
@@ -20,7 +20,8 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv, uint32_t pe,
 				       uint32_t area_len,
 				       struct lv_segment *seg,
 				       uint32_t area_num);
-int pv_split_segment(struct physical_volume *pv, uint32_t pe);
+int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+		     struct pv_segment **peg_allocated);
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction);
 int check_pv_segments(struct volume_group *vg);
 void merge_pv_segments(struct pv_segment *peg1, struct pv_segment *peg2);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index b80c3f1..bd3f488 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -96,15 +96,16 @@ static struct pv_segment *find_peg_by_pe(const struct physical_volume *pv,
  * Split peg at given extent.
  * Second part is always deallocated.
  */
-static int _pv_split_segment(struct physical_volume *pv, struct pv_segment *peg,
-			     uint32_t pe)
+static struct pv_segment *_pv_split_segment(struct physical_volume *pv,
+					    struct pv_segment *peg,
+					    uint32_t pe)
 {
 	struct pv_segment *peg_new;
 
 	if (!(peg_new = _alloc_pv_segment(pv->fmt->cmd->mem, peg->pv, pe,
 					  peg->len + peg->pe - pe,
 					  NULL, 0)))
-		return_0;
+		return_NULL;
 
 	peg->len = peg->len - peg_new->len;
 
@@ -115,18 +116,19 @@ static int _pv_split_segment(struct physical_volume *pv, struct pv_segment *peg,
 		peg->lvseg->lv->vg->free_count += peg_new->len;
 	}
 
-	return 1;
+	return peg_new;
 }
 
 /*
  * Ensure there is a PV segment boundary at the given extent.
  */
-int pv_split_segment(struct physical_volume *pv, uint32_t pe)
+int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+		     struct pv_segment **peg_allocated)
 {
-	struct pv_segment *peg;
+	struct pv_segment *peg, *peg_new = NULL;
 
 	if (pe == pv->pe_count)
-		return 1;
+		goto out;
 
 	if (!(peg = find_peg_by_pe(pv, pe))) {
 		log_error("Segment with extent %" PRIu32 " in PV %s not found",
@@ -135,11 +137,16 @@ int pv_split_segment(struct physical_volume *pv, uint32_t pe)
 	}
 
 	/* This is a peg start already */
-	if (pe == peg->pe)
-		return 1;
+	if (pe == peg->pe) {
+		peg_new = peg;
+		goto out;
+	}
 
-	if (!_pv_split_segment(pv, peg, pe))
+	if (!(peg_new = _pv_split_segment(pv, peg, pe)))
 		return_0;
+out:
+	if (peg_allocated)
+		*peg_allocated = peg_new;
 
 	return 1;
 }
@@ -154,17 +161,17 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv,
 				       struct lv_segment *seg,
 				       uint32_t area_num)
 {
-	struct pv_segment *peg;
+	struct pv_segment *peg = NULL;
 
 	/* Missing format1 PV */
 	if (!pv)
 		return &null_pv_segment;
 
-	if (!pv_split_segment(pv, pe) ||
-	    !pv_split_segment(pv, pe + area_len))
+	if (!pv_split_segment(pv, pe, &peg) ||
+	    !pv_split_segment(pv, pe + area_len, NULL))
 		return_NULL;
 
-	if (!(peg = find_peg_by_pe(pv, pe))) {
+	if (!peg) {
 		log_error("Missing PV segment on %s at %u.",
 			  pv_dev_name(pv), pe);
 		return NULL;
@@ -200,7 +207,7 @@ int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 	}
 
 	if (!pv_split_segment(peg->pv, peg->pe + peg->lvseg->area_len -
-				       area_reduction))
+				       area_reduction, NULL))
 		return_0;
 
 	return 1;
@@ -373,7 +380,7 @@ static int _reduce_pv(struct physical_volume *pv, struct volume_group *vg, uint3
 		}
 	}
 
-	if (!pv_split_segment(pv, new_pe_count))
+	if (!pv_split_segment(pv, new_pe_count, NULL))
 		return_0;
 
 	dm_list_iterate_items_safe(peg, pegt, &pv->segments) {
-- 
1.7.0.3


