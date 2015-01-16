From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 16 Jan 2015 12:44:53 +0000 (UTC)
Subject: master - raid_manip: v2 fix multi-segment misallocation on 'lvconvert --repair'
Message-ID: <20150116124453.840E46023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=302b6c99a7c78e4f57b6afe4ef1007a1ba74e40b
Commit:        302b6c99a7c78e4f57b6afe4ef1007a1ba74e40b
Parent:        0bcc0cf95dc85e41379de518b04ae2703858f118
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jan 16 13:44:16 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jan 16 13:44:16 2015 +0100

raid_manip: v2 fix multi-segment misallocation on 'lvconvert --repair'

The previous patch felt short WRT disabling allocation on PVs holding other
legs of the RAID LV persistently; this patch introduces an internal,
transient PV flag PV_ALLOCATION_PROHIBITED to address this very problem.

General problem description for completeness:

An 'lvconvert --repair $RAID_LV" to replace a failed leg of a multi-segment
RAID10/4/5/6 logical volume can lead to allocation of (parts of) the replacement
image component pair on the physical volume of another image component
(e.g. image 0 allocated on the same PV as image 1 silently impeding resilience).

Patch fixes this severe resilince issue by prohibiting allocation on PVs
already holding other legs of the RAID set. It allows to allocate free space
on any operational PV already holding parts of the image component pair.
---
 lib/metadata/metadata-exported.h |    6 ++++--
 lib/metadata/pv_map.c            |    5 ++++-
 lib/metadata/raid_manip.c        |    7 ++++---
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a48aef2..94e8ebf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -119,8 +119,10 @@
 
 #define LV_PENDING_DELETE	UINT64_C(0x0004000000000000)    /* LV - Internal use only */
 #define LV_ERROR_WHEN_FULL	UINT64_C(0x0008000000000000)    /* LV - error when full */
-
-/* Next unused flag:		UINT64_C(0x0010000000000000)    */
+#define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
+									e.g. to prohibit allocation of a RAID image
+									on a PV already holing an image of the RAID set */
+/* Next unused flag:		UINT64_C(0x0020000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/pv_map.c b/lib/metadata/pv_map.c
index 4423a7d..b6cf31e 100644
--- a/lib/metadata/pv_map.c
+++ b/lib/metadata/pv_map.c
@@ -133,8 +133,11 @@ static int _create_maps(struct dm_pool *mem, struct dm_list *pvs, struct dm_list
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, pvs) {
-		if (!(pvl->pv->status & ALLOCATABLE_PV))
+		if (!(pvl->pv->status & ALLOCATABLE_PV) ||
+		    (pvl->pv->status & PV_ALLOCATION_PROHIBITED)) {
+		    	pvl->pv->status &= ~PV_ALLOCATION_PROHIBITED;
 			continue;
+		}
 		if (is_missing_pv(pvl->pv))
 			continue;
 		assert(pvl->pv->dev);
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index cb0366f..d502379 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1553,14 +1553,15 @@ static int _avoid_pvs_of_lv(struct logical_volume *lv, void *data)
 	dm_list_iterate_items(pvl, allocate_pvs)
 		if (!(lv->status & PARTIAL_LV) &&
 		    lv_is_on_pv(lv, pvl->pv))
-			pvl->pv->status &= ~ALLOCATABLE_PV;
+			pvl->pv->status |= PV_ALLOCATION_PROHIBITED;
 
 	return 1;
  }
 
 /*
- * Prevent any PVs holding other image components of @lv from being used for allocation,
- * I.e. reset ALLOCATABLE_PV on respective PVs listed on @allocatable_pvs
+ * Prevent any PVs holding other image components of @lv from being used for allocation
+ * by setting the internal PV_ALLOCATION_PROHIBITED flag to use it to avoid generating
+ * pv maps for those PVs.
  */
 static void _avoid_pvs_with_other_images_of_lv(struct logical_volume *lv, struct dm_list *allocate_pvs)
 {


