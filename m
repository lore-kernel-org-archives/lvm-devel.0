From: heinzm@redhat.com <heinzm@redhat.com>
Date: Fri, 19 Dec 2014 18:24:17 +0100
Subject: [PATCH] raid_manip: fix multi-segment misallocation on 'lvconvert --repair ' (bz#1168959)
Message-ID: <1419009857-19750-1-git-send-email-heinzm@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Heinz Mauelshagen <heinzm@redhat.com>

An 'lvconvert --repair $RAID_LV" to replace a failed leg of a multi-segment
RAID10/4/5/6 logical volume can lead to allocation of (parts of) the replacement
image component pair on the physical volume of another image component
(e.g. image 0 allocated on the same PV as image 1 silently impeding resilience).

Patch fixes this severe resilince issue by prohibiting allocation
on PVs already holding other legs of the RAID set.
It allows to allocate free space on any operational PV already holding parts of
the image component pair

Signed-off-by: Heinz Mauelshagen <heinzm@redhat.com>

---
 lib/metadata/raid_manip.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 59d3adb..97f79ee 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1545,6 +1545,28 @@ has_enough_space:
 	return 1;
 }
 
+static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
+{
+	struct dm_list *allocate_pvs = (struct dm_list *) data;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, allocate_pvs)
+		if (!(lv->status & PARTIAL_LV) &&
+		    lv_is_on_pv(lv, pvl->pv))
+			pvl->pv->status &= ~ALLOCATABLE_PV;
+ 
+ 	return 1;
+ }
+ 
+/*
+ * Prevent any PVs holding other image components of @lv from being used for allocation,
+ * I.e. reset ALLOCATABLE_PV on respective PVs listed on @allocatable_pvs
+ */
+static void _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
+{
+	for_each_sub_lv(lv, _avoid_pvs_of_lv, allocate_pvs);
+}
+
 /*
  * lv_raid_replace
  * @lv
@@ -1643,6 +1665,9 @@ int lv_raid_replace(struct logical_volume *lv,
 		}
 	}
 
+	/* Prevent any PVs holding image components from being used for allocation */
+	_avoid_pvs_with_other_images_of_lv(lv, allocate_pvs);
+
 	/*
 	 * Allocate the new image components first
 	 * - This makes it easy to avoid all currently used devs
-- 
2.1.0


