From: Milan Broz <mbroz@redhat.com>
Date: Mon, 29 Mar 2010 15:12:58 +0200
Subject: [PATCH 5/5] Fix all segments memory is allocated from vg private mempool.
In-Reply-To: <cover.1269866168.git.mbroz@redhat.com>
References: <cover.1269866168.git.mbroz@redhat.com>
Message-ID: <97111f869b70279be7e1caa047cd7a1e059a763a.1269866168.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Physical segments were still allocated from global
command context mempool.

This leads to very high memory usage when
activating large VG (vgchange).
(Memory usage was about 2G when >3000LVs).

Fix it by properly using vg->vgmem private pool,
so all the memory is released early.

New memory pool parameter is needed here for pv_split_segment
function.

Also fix the same problem in some minor allocations
(vg description, lv segment split).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/import.c |    2 +-
 lib/metadata/lv_manip.c  |    2 +-
 lib/metadata/merge.c     |    4 ++--
 lib/metadata/pv_alloc.h  |    3 ++-
 lib/metadata/pv_manip.c  |   21 ++++++++++++---------
 5 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 03ff990..f686418 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -114,7 +114,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		if (!(vg = (*vsn)->read_vg(fid, cft, 0)))
 			goto_out;
 
-		(*vsn)->read_desc(fid->fmt->cmd->mem, cft, when, desc);
+		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
 		break;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c9d1759..650bc83 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -47,7 +47,7 @@ int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
 	log_very_verbose("Adding %s:%" PRIu32 " as an user of %s",
 			 seg->lv->name, seg->le, lv->name);
 
-	if (!(sl = dm_pool_zalloc(lv->vg->cmd->mem, sizeof(*sl)))) {
+	if (!(sl = dm_pool_zalloc(lv->vg->vgmem, sizeof(*sl)))) {
 		log_error("Failed to allocate segment list");
 		return 0;
 	}
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 66e9ce0..bd65c69 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -268,7 +268,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 	}
 
 	/* Clone the existing segment */
-	if (!(split_seg = alloc_lv_segment(lv->vg->cmd->mem, seg->segtype,
+	if (!(split_seg = alloc_lv_segment(lv->vg->vgmem, seg->segtype,
 					   seg->lv, seg->le, seg->len,
 					   seg->status, seg->stripe_size,
 					   seg->log_lv,
@@ -279,7 +279,7 @@ static int _lv_split_segment(struct logical_volume *lv, struct lv_segment *seg,
 		return 0;
 	}
 
-	if (!str_list_dup(lv->vg->cmd->mem, &split_seg->tags, &seg->tags)) {
+	if (!str_list_dup(lv->vg->vgmem, &split_seg->tags, &seg->tags)) {
 		log_error("LV segment tags duplication failed");
 		return 0;
 	}
diff --git a/lib/metadata/pv_alloc.h b/lib/metadata/pv_alloc.h
index 601bbf1..ebf6561 100644
--- a/lib/metadata/pv_alloc.h
+++ b/lib/metadata/pv_alloc.h
@@ -20,7 +20,8 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv, uint32_t pe,
 				       uint32_t area_len,
 				       struct lv_segment *seg,
 				       uint32_t area_num);
-int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+int pv_split_segment(struct dm_pool *mem,
+		     struct physical_volume *pv, uint32_t pe,
 		     struct pv_segment **peg_allocated);
 int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction);
 int check_pv_segments(struct volume_group *vg);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index bd3f488..a4ca7a1 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -96,13 +96,14 @@ static struct pv_segment *find_peg_by_pe(const struct physical_volume *pv,
  * Split peg at given extent.
  * Second part is always deallocated.
  */
-static struct pv_segment *_pv_split_segment(struct physical_volume *pv,
+static struct pv_segment *_pv_split_segment(struct dm_pool *mem,
+					    struct physical_volume *pv,
 					    struct pv_segment *peg,
 					    uint32_t pe)
 {
 	struct pv_segment *peg_new;
 
-	if (!(peg_new = _alloc_pv_segment(pv->fmt->cmd->mem, peg->pv, pe,
+	if (!(peg_new = _alloc_pv_segment(mem, peg->pv, pe,
 					  peg->len + peg->pe - pe,
 					  NULL, 0)))
 		return_NULL;
@@ -122,7 +123,8 @@ static struct pv_segment *_pv_split_segment(struct physical_volume *pv,
 /*
  * Ensure there is a PV segment boundary at the given extent.
  */
-int pv_split_segment(struct physical_volume *pv, uint32_t pe,
+int pv_split_segment(struct dm_pool *mem,
+		     struct physical_volume *pv, uint32_t pe,
 		     struct pv_segment **peg_allocated)
 {
 	struct pv_segment *peg, *peg_new = NULL;
@@ -142,7 +144,7 @@ int pv_split_segment(struct physical_volume *pv, uint32_t pe,
 		goto out;
 	}
 
-	if (!(peg_new = _pv_split_segment(pv, peg, pe)))
+	if (!(peg_new = _pv_split_segment(mem, pv, peg, pe)))
 		return_0;
 out:
 	if (peg_allocated)
@@ -167,8 +169,8 @@ struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv,
 	if (!pv)
 		return &null_pv_segment;
 
-	if (!pv_split_segment(pv, pe, &peg) ||
-	    !pv_split_segment(pv, pe + area_len, NULL))
+	if (!pv_split_segment(seg->lv->vg->vgmem, pv, pe, &peg) ||
+	    !pv_split_segment(seg->lv->vg->vgmem, pv, pe + area_len, NULL))
 		return_NULL;
 
 	if (!peg) {
@@ -206,8 +208,9 @@ int release_pv_segment(struct pv_segment *peg, uint32_t area_reduction)
 		return 1;
 	}
 
-	if (!pv_split_segment(peg->pv, peg->pe + peg->lvseg->area_len -
-				       area_reduction, NULL))
+	if (!pv_split_segment(peg->lvseg->lv->vg->vgmem,
+			      peg->pv, peg->pe + peg->lvseg->area_len -
+			      area_reduction, NULL))
 		return_0;
 
 	return 1;
@@ -380,7 +383,7 @@ static int _reduce_pv(struct physical_volume *pv, struct volume_group *vg, uint3
 		}
 	}
 
-	if (!pv_split_segment(pv, new_pe_count, NULL))
+	if (!pv_split_segment(vg->vgmem, pv, new_pe_count, NULL))
 		return_0;
 
 	dm_list_iterate_items_safe(peg, pegt, &pv->segments) {
-- 
1.7.0.3


