From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 12 Aug 2016 22:20:29 +0000 (UTC)
Subject: master - raid_manip: pay attention to PVs listed on command line when allocating MetaLVs
Message-ID: <20160812222029.4297160C1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c9b9b276a35dcc6dce8e6a19e7afc01eef451a7
Commit:        9c9b9b276a35dcc6dce8e6a19e7afc01eef451a7
Parent:        6d52b17dfcbbbc19d4fee1ba117448bed3759ba8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Aug 13 00:20:01 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Aug 13 00:20:01 2016 +0200

raid_manip: pay attention to PVs listed on command line when allocating MetaLVs

Adding MetaLVs to given DataLVs (e.g. raid0 -> raid0_meta takeover) wasn't
paying attention to any PVs listed on the lvconvert command line.
---
 lib/metadata/raid_manip.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 831b1dd..a7814a8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1604,10 +1604,21 @@ static int _alloc_rmeta_devs_for_rimage_devs(struct logical_volume *lv,
 	dm_list_iterate_items(lvl, new_data_lvs) {
 		log_debug_metadata("Allocating new metadata LV for %s", lvl->lv->name);
 
-		if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv, allocate_pvs)) {
-			log_error("Failed to allocate metadata LV for %s in %s",
-				  lvl->lv->name, lv->vg->name);
-			return 0;
+		/*
+		 * Try to collocate with DataLV first and
+		 * if that fails allocate on different PV.
+		 */
+		if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv,
+					 allocate_pvs != &lv->vg->pvs ? allocate_pvs : NULL)) {
+			dm_list_iterate_items(lvl1, new_meta_lvs)
+				if (!_avoid_pvs_with_other_images_of_lv(lvl1->lv, allocate_pvs))
+					return_0;
+
+			if (!_alloc_rmeta_for_lv(lvl->lv, &lvl_array[a].lv, allocate_pvs)) {
+				log_error("Failed to allocate metadata LV for %s in %s",
+					  lvl->lv->name, lv->vg->name);
+				return 0;
+			}
 		}
 
 		dm_list_add(new_meta_lvs, &lvl_array[a++].list);


