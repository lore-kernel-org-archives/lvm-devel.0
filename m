From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 16 Sep 2009 14:36:58 -0400
Subject: [PATCH] Add lv_psize field - calculate total physical storage size for an lv.
Message-ID: <1253126218-13161-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds an 'lv_psize' field to lvs reports to allow us to
display the physical size consumed by an LV.  This is useful for
LVs such as mirrors which have multiple 'hidden' LVs.  In these
cases the 'lv_size' parameter displays the logical size, not the
physical size.  So we add another field here to display the phyisical
size.

NOTE: There's a bug in this for snapshots.  There is either a bug
in my usage of lv_postorder or a bug in lv_postorder itself,
not sure at this point.  In any case, the callback gets called 2x's
on the actual snapshot lvname, which is why the size is incorrect.

Example:
lvcreate -L 64M -m1 -n lvmir vg1
lvcreate -L 16M -n lv2 vg1
lvcreate -L 8M -n lv2snap -s vg1/lv2
lvcreate -L 16M -n lv3linear vg1
lvcreate --virtualoriginsize 1T --size 100M --snapshot --name sparse vg1

lvs -a -oname,size,lv_psize
  LV               LSize   LPSize
  lv2               16.00M  16.00M
  lv2snap            8.00M  32.00M
  lv3linear         16.00M  16.00M
  lvmir             64.00M 132.00M
  [lvmir_mimage_0]  64.00M      0
  [lvmir_mimage_1]  64.00M      0
  [lvmir_mlog]       4.00M      0
  sparse           100.00M 200.00M
  [sparse_vorigin]   1.00T      0

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   27 +++++++++++++++++++++++++++
 lib/report/columns.h             |    1 +
 lib/report/report.c              |   11 +++++++++++
 4 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 50f0b90..fe1c263 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -707,6 +707,7 @@ uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
 
 uint64_t lv_size(const struct logical_volume *lv);
+uint64_t lv_get_psize(const struct logical_volume *lv);
 
 int vg_missing_pv_count(const struct volume_group *vg);
 uint32_t vg_seqno(const struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 263c705..564925d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1957,6 +1957,33 @@ static int _lv_mark_if_partial(struct logical_volume *lv)
 	return _lv_postorder(lv, _lv_mark_if_partial_single, NULL);
 }
 
+static int _lv_get_pesize_single(struct logical_volume *lv, void *data)
+{
+	int s;
+	uint64_t *size = (uint64_t *)data;
+	struct lv_segment *lvseg;
+
+	dm_list_iterate_items(lvseg, &lv->segments) {
+		for (s = 0; s < lvseg->area_count; ++s) {
+			if (seg_type(lvseg, s) == AREA_PV) {
+				*size += (seg_pvseg(lvseg, s)->len
+					  * seg_pv(lvseg, s)->pe_size);
+			}
+		}
+	}
+
+	return 1;
+}
+
+uint64_t lv_get_psize(const struct logical_volume *lv)
+{
+	uint64_t size = 0;
+
+	_lv_postorder(lv, _lv_get_pesize_single, &size);
+
+	return size;
+}
+
 /*
  * Mark LVs with missing PVs using PARTIAL_LV status flag. The flag is
  * propagated transitively, so LVs referencing other LVs are marked
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 49ebab4..d24e73a 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -65,6 +65,7 @@ FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major", "Currently assig
 FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor", "Currently assigned minor number or -1 if LV is not active.")
 FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, "lv_kernel_read_ahead", "Currently-in-use read ahead setting in current units.")
 FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size", "Size of LV in current units.")
+FIELD(LVS, lv, NUM, "LPSize", lvid, 5, lvpsize, "lv_psize", "Total physical storage used by the LV in current units.")
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count", "Number of segments in LV.")
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV.")
 FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, "origin_size", "For snapshots, the size of the origin device of this LV.")
diff --git a/lib/report/report.c b/lib/report/report.c
index 15354e7..90c15a5 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -966,6 +966,17 @@ static int _vgmdafree_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
+static int _lvpsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t psize = 0;
+
+	psize = lv_get_psize(lv);
+	return _size64_disp(rh, mem, field, &psize, private);
+}
+
 static int _lvcount_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
-- 
1.6.0.6


