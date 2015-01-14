From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 14 Jan 2015 12:43:05 +0000 (UTC)
Subject: master - raid_manip: fix multi-segment misallocation on 'lvconvert --repair'
Message-ID: <20150114124305.4AE2C60364@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdd17eee377013a569e2aeed0cbe865749323def
Commit:        cdd17eee377013a569e2aeed0cbe865749323def
Parent:        8804023825e9eb00df653a7c5116097d1ce49087
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jan 14 13:41:55 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 14 13:41:55 2015 +0100

raid_manip: fix multi-segment misallocation on 'lvconvert --repair'

An 'lvconvert --repair $RAID_LV" to replace a failed leg of a multi-segment
RAID10/4/5/6 logical volume can lead to allocation of (parts of) the replacement
image component pair on the physical volume of another image component
(e.g. image 0 allocated on the same PV as image 1 silently impeding resilience).

Patch fixes this severe resilince issue by prohibiting allocation on PVs
already holding other legs of the RAID set. It allows to allocate free space
on any operational PV already holding parts of the image component pair.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e295e6c..bbb45c4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Fix lvconvert --repair to honour resilience requirement for segmented RAID LV.
   Filter out partitioned device-mapper devices as unsuitable for use as PVs.
   Also notify lvmetad about filtered device if using pvscan --cache DevicePath.
   Use LVM's own selection instead of awk expressions in clvmd startup scripts.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6f951f4..cb0366f 100644
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
+	return 1;
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


