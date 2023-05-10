From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 10 May 2023 16:36:11 +0000 (GMT)
Subject: main - Fix "multisegment RAID1, allocator uses one disk for both legs"
Message-ID: <20230510163611.2FE883851C19@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05c2b10c5d0a99993430ffbcef684a099ba810ad
Commit:        05c2b10c5d0a99993430ffbcef684a099ba810ad
Parent:        bf794b66f412765e49c4d79a4bb95b454f2357fc
Author:        heinzm <heinzm@redhat.com>
AuthorDate:    Wed May 10 18:22:11 2023 +0200
Committer:     heinzm <heinzm@redhat.com>
CommitterDate: Wed May 10 18:35:21 2023 +0200

Fix "multisegment RAID1, allocator uses one disk for both legs"

In case of e.g. 3 PVs, creating or extending a RaidLV causes SubLV
collocation thus putting segments of diffent rimage (and potentially
larger rmeta) SubLVs onto the same PV.  For redundant RaidLVs this'll
compromise redundancy.  Fix by detecting such bogus allocation on
lvcreate/lvextend and reject the request.
---
 lib/metadata/lv_manip.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 298d307f3..9a9e547be 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4454,6 +4454,38 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	return 1;
 }
 
+/* Check either RAID images and metas are being allocated redundantly. */
+static int _lv_raid_redundant(struct logical_volume *lv,
+			      struct dm_list *allocatable_pvs, int meta)
+{
+	uint32_t nlvs, s;
+	struct lv_segment *seg = first_seg(lv);
+	struct pv_list *pvl;
+
+	if (meta && !seg->meta_areas)
+		return 1;
+
+	dm_list_iterate_items(pvl, allocatable_pvs) {
+		nlvs = 0;
+
+		for (s = 0; s < seg->area_count; s++) {
+			struct logical_volume *slv = meta ? seg_metalv(seg, s) : seg_lv(seg, s);
+
+			if (slv && lv_is_on_pv(slv, pvl->pv) && nlvs++)
+				return 0;
+		}
+	}
+
+	return 1;
+}
+
+/* Check both RAID images and metas are being allocated redundantly. */
+static int _lv_raid_redundant_allocation(struct logical_volume *lv, struct dm_list *allocatable_pvs)
+{
+	return _lv_raid_redundant(lv, allocatable_pvs, 0) &&
+	       _lv_raid_redundant(lv, allocatable_pvs, 1);
+}
+
 /*
  * Entry point for single-step LV allocation + extension.
  * Extents is the number of logical extents to append to the LV unless
@@ -4556,6 +4588,15 @@ int lv_extend(struct logical_volume *lv,
 						mirrors, stripes, stripe_size)))
 			goto_out;
 
+		if (segtype_is_raid(segtype) &&
+		    alloc != ALLOC_ANYWHERE &&
+		    !(r = _lv_raid_redundant_allocation(lv, allocatable_pvs))) {
+			log_error("Insufficient suitable allocatable extents for logical volume %s", display_lvname(lv));
+			if (!lv_remove(lv) || !vg_write(lv->vg) || !vg_commit(lv->vg))
+				return_0;
+			goto out;
+		}
+
 		if (lv_raid_has_integrity(lv)) {
 			if (!lv_extend_integrity_in_raid(lv, allocatable_pvs)) {
 				r = 0;

