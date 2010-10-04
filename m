From: Milan Broz <mbroz@redhat.com>
Date: Mon,  4 Oct 2010 18:48:47 +0200
Subject: [PATCH] Restrict lvm1 partial mode.
Message-ID: <1286210927-10607-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Current lvm1 allocation code seems to not properly
map segments on missing PVs.

For now disable this functionality.
(It never worked and previous commit just introduced segfault here.)

So the partial mode in lvm1 can only process missing PVs
with no LV segments only.

Also do not use random PV UUID for missing part but use fixed
string derived from VG UUID (to not confuse clvmd tests).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format1/format1.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index d6c462a..f5a9d12 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -118,6 +118,28 @@ static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
 	struct disk_list *dl;
 	struct dm_list *pvh;
 	struct pv_list *pvl;
+	struct lv_list *ll;
+	struct lv_segment *seg;
+
+	/*
+	 * FIXME: code should remap missing segments to error segment.
+	 * Also current mapping code allocates 1 segment per missing extent.
+	 * For now bail out completely - allocated structures are not complete
+	 */
+	dm_list_iterate_items(ll, &vg->lvs)
+		dm_list_iterate_items(seg, &ll->lv->segments) {
+
+			/* area_count is always 1 here, s == 0 */
+			if (seg_type(seg, 0) != AREA_PV)
+				continue;
+
+			if (seg_pv(seg, 0))
+				continue;
+
+			log_error("Partial mode support for missing lvm1 PVs and "
+				  "partially available LVs is currently not implemented.");
+			return 0;
+	}
 
 	dm_list_iterate(pvh, pvs) {
 		dl = dm_list_item(pvh, struct disk_list);
@@ -129,8 +151,10 @@ static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
 	    !(pvl->pv = dm_pool_zalloc(vg->vgmem, sizeof(*pvl->pv))))
 		return_0;
 
-	if (!id_create(&pvl->pv->id))
-		goto_out;
+	/* Use vg uuid with replaced first chars to "missing" as missing PV UUID */
+	memcpy(&pvl->pv->id.uuid, vg->id.uuid, sizeof(pvl->pv->id.uuid));
+	memcpy(&pvl->pv->id.uuid, "missing", 7);
+
 	if (!(pvl->pv->vg_name = dm_pool_strdup(vg->vgmem, vg->name)))
 		goto_out;
 	memcpy(&pvl->pv->vgid, &vg->id, sizeof(vg->id));
-- 
1.7.1


