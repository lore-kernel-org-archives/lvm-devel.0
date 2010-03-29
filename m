From: Milan Broz <mbroz@redhat.com>
Date: Mon, 29 Mar 2010 15:12:56 +0200
Subject: [PATCH 3/5] Optimise PV segments search.
In-Reply-To: <cover.1269866168.git.mbroz@redhat.com>
References: <cover.1269866168.git.mbroz@redhat.com>
Message-ID: <2b3c46606ca6551910d31687611f513f9f4d477e.1269866168.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The function find_peg_by_pe is incredibly inefficient
for Pvs with many segments.

In shiny future there should be binary (or interval) tree
instead of sorted linked list (volunteers?).

Anyway, for now, we can use dirty trick here to optimise this case:

 - Allocations are usually applied from the beginning
 of PV (we have no alloocation policy which allocates areas
 "backwards")

 - The only user of find_peg_by_pe is pv_split_segment()
 call. In *most* cases it need to split *last* PV segment.

So if we search sorted pv segment list backwards, we
hit the requested segment immediatelly.

This patch applies this tiny change.
(and saves >30% of processing time when >3000LVs segments are on one PV!)

To discourage using this inefficient function from other code,
it is moved to pv_manip.c and used static for now:-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   12 ------------
 lib/metadata/metadata.h |    3 ---
 lib/metadata/pv_manip.c |   14 ++++++++++++++
 3 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 020e897..c52acb8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1799,18 +1799,6 @@ struct lv_segment *first_seg(const struct logical_volume *lv)
 	return NULL;
 }
 
-/* Find segment at a given physical extent in a PV */
-struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe)
-{
-	struct pv_segment *peg;
-
-	dm_list_iterate_items(peg, &pv->segments)
-		if (pe >= peg->pe && pe < peg->pe + peg->len)
-			return peg;
-
-	return NULL;
-}
-
 int vg_remove_mdas(struct volume_group *vg)
 {
 	struct metadata_area *mda;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 542be6e..782d300 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -308,9 +308,6 @@ struct pv_list *find_pv_in_pv_list(const struct dm_list *pl,
 /* Find LV segment containing given LE */
 struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le);
 
-/* Find PV segment containing given LE */
-struct pv_segment *find_peg_by_pe(const struct physical_volume *pv, uint32_t pe);
-
 /*
  * Remove a dev_dir if present.
  */
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 1b0a457..b80c3f1 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -78,6 +78,20 @@ int peg_dup(struct dm_pool *mem, struct dm_list *peg_new, struct dm_list *peg_ol
 	return 1;
 }
 
+/* Find segment at a given physical extent in a PV */
+static struct pv_segment *find_peg_by_pe(const struct physical_volume *pv,
+					 uint32_t pe)
+{
+	struct pv_segment *peg;
+
+	/* search backwards to optimise mostly used last segment split */
+	dm_list_iterate_back_items(peg, &pv->segments)
+		if (pe >= peg->pe && pe < peg->pe + peg->len)
+			return peg;
+
+	return NULL;
+}
+
 /*
  * Split peg at given extent.
  * Second part is always deallocated.
-- 
1.7.0.3


