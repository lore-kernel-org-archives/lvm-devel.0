From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 12 Aug 2016 20:47:41 +0000 (UTC)
Subject: master - raid_manip: add missing code avoiding MetaLV collocation on the same PV
Message-ID: <20160812204741.A075860D79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d52b17dfcbbbc19d4fee1ba117448bed3759ba8
Commit:        6d52b17dfcbbbc19d4fee1ba117448bed3759ba8
Parent:        0973d6e3314cc0f0ff1e5024feb131c2187d97f2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 12 22:46:57 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 12 22:46:57 2016 +0200

raid_manip: add missing code avoiding MetaLV collocation on the same PV

Adding MetaLVs to given DataLVs (e.g. raid0 -> raid0_meta takeover),
_avoid_pvs_with_other_images_of_lv() was missing code to prohibit
allocation when called with a just allocated MetaLV to prohibit
collaocation of the next allocated MetaLV on the same PV.

- resolves rhbz1366738
---
 lib/metadata/raid_manip.c |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ce560fe..831b1dd 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -176,14 +176,22 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 	return 1;
 }
 
+/* HM Helper: prohibit allocation on @pv if @lv already has segments allocated on it */
+static int _avoid_pv_of_lv(struct logical_volume *lv, struct physical_volume *pv)
+{
+	if (!lv_is_partial(lv) && lv_is_on_pv(lv, pv))
+		pv->status |= PV_ALLOCATION_PROHIBITED;
+
+	return 1;
+}
+
 static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
 {
 	struct dm_list *allocate_pvs = (struct dm_list *) data;
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, allocate_pvs)
-		if (!lv_is_partial(lv) && lv_is_on_pv(lv, pvl->pv))
-			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
+		_avoid_pv_of_lv(lv, pvl->pv);
 
 	return 1;
 }
@@ -195,7 +203,15 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
  */
 static int _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {
-	return for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
+	/* HM FIXME: check fails in case we will ever have mixed AREA_PV/AREA_LV segments */
+	if ((seg_type(first_seg(lv), 0) == AREA_PV ? _avoid_pvs_of_lv(lv, allocate_pvs):
+						     for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs)))
+		return 1;
+
+	log_error("Failed to prevent PVs holding image components "
+		  "from LV %s being used for allocation.",
+		  display_lvname(lv));
+	return 0;
 }
 
 static void _clear_allocation_prohibited(struct dm_list *pvs)
@@ -1595,7 +1611,7 @@ static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 		}
 
 		dm_list_add(new_meta_lvs, &lvl_array[a++].list);
-		
+
 		dm_list_iterate_items(lvl1, new_meta_lvs)
 			if (!_avoid_pvs_with_other_images_of_lv(lvl1->lv, allocate_pvs))
 				return_0;


