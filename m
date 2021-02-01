From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:36 +0000 (GMT)
Subject: main - pvmove: automatically resolve whole stacked LV
Message-ID: <20210201114736.30E273836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=45f0c48365457b2ca4cec163f4435327f0978bd3
Commit:        45f0c48365457b2ca4cec163f4435327f0978bd3
Parent:        abc9265a063670e277e6859ba0203d09ae20604d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 25 01:17:14 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:06:13 2021 +0100

pvmove: automatically resolve whole stacked LV

When passing 'pvmove --name arg' try to automatically move
all associated dependencies with given LV.

i.e. 'pvmove --name thinpool vg vgnew'
moves all thins and data and metadata LV into a new VG vgnew.
---
 lib/metadata/metadata.c | 57 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 35 insertions(+), 22 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f4d07a4f7..266db0a4c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -459,14 +459,33 @@ int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	return _move_pv(vg_from, vg_to, pv_name, 1);
 }
 
+struct vg_from_to {
+	struct volume_group *from;
+	struct volume_group *to;
+};
+
+static int _move_pvs_used_by_lv_cb(struct logical_volume *lv, void *data)
+{
+	struct vg_from_to *v = (struct vg_from_to*) data;
+	struct lv_segment *lvseg;
+	unsigned s;
+
+	dm_list_iterate_items(lvseg, &lv->segments)
+		for (s = 0; s < lvseg->area_count; s++)
+			if (seg_type(lvseg, s) == AREA_PV)
+				if (!_move_pv(v->from, v->to,
+					      pv_dev_name(seg_pv(lvseg, s)), 0))
+					return_0;
+
+	return 1;
+}
+
 int move_pvs_used_by_lv(struct volume_group *vg_from,
 			struct volume_group *vg_to,
 			const char *lv_name)
 {
-	struct lv_segment *lvseg;
-	unsigned s;
+	struct vg_from_to data = { .from = vg_from, .to = vg_to };
 	struct lv_list *lvl;
-	struct logical_volume *lv;
 
 	/* FIXME: handle tags */
 	if (!(lvl = find_lv_in_vg(vg_from, lv_name))) {
@@ -475,28 +494,22 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
-	if (vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
-	    vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+	if (vg_bad_status_bits(vg_from, RESIZEABLE_VG)) {
+		log_error("Cannot move PV(s) from non resize volume group %s.", vg_from->name);
 		return 0;
+	}
 
-	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
-		if (lvseg->log_lv)
-			if (!move_pvs_used_by_lv(vg_from, vg_to,
-						     lvseg->log_lv->name))
-				return_0;
-		for (s = 0; s < lvseg->area_count; s++) {
-			if (seg_type(lvseg, s) == AREA_PV) {
-				if (!_move_pv(vg_from, vg_to,
-					      pv_dev_name(seg_pv(lvseg, s)), 0))
-					return_0;
-			} else if (seg_type(lvseg, s) == AREA_LV) {
-				lv = seg_lv(lvseg, s);
-				if (!move_pvs_used_by_lv(vg_from, vg_to,
-							     lv->name))
-				    return_0;
-			}
-		}
+	if (vg_bad_status_bits(vg_to, RESIZEABLE_VG)) {
+		log_error("Cannot move PV(s) to non resize volume group %s.", vg_to->name);
+		return 0;
 	}
+
+	if (!for_each_sub_lv(lvl->lv, _move_pvs_used_by_lv_cb, &data))
+		return_0;
+
+	if (!_move_pvs_used_by_lv_cb(lvl->lv, &data))
+		return_0;
+
 	return 1;
 }
 


