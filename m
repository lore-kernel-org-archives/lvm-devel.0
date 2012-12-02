From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:16 +0000 (UTC)
Subject: master - lvm2api: fix size reporting
Message-ID: <20121202170216.A748EA0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ec474f38aac948a3fb2cb572af9a756b0ac585d
Commit:        9ec474f38aac948a3fb2cb572af9a756b0ac585d
Parent:        83978cdec8aa6f6b6af2cb8937d64cc16b88cf18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 10:29:03 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:55:08 2012 +0100

lvm2api: fix size reporting

API is reporting all sizes as 64bit integers in bytes.
Fix at those places, where sectors were returned
to remain consistent.
---
 WHATS_NEW               |    3 ++-
 lib/report/properties.c |   20 ++++++++++----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca1b539..43bdb0e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,9 @@
 Version 2.02.99 - 
 ===================================
+  Fix lvm2app to return all property sizes in bytes.
   Recognize DM_DISABLE_UDEV environment variable for a complete fallback.
   Do not verify udev operations if --noudevsync command option is used.
-  Fix lvm2api and return lvseg discards property as string.
+  Fix lvm2app and return lvseg discards property as string.
   Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
   Recognise STEC skd devices in filter.
   Recognise Violin Memory vtms devices in filter.
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 0cd39ba..6a4d960 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -183,7 +183,7 @@ GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
 #define _seg_count_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
 #define _origin_set _not_implemented_set
-GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
+GET_LV_NUM_PROPERTY_FN(origin_size, (SECTOR_SIZE * lv_origin_size(lv)))
 #define _origin_size_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
 #define _snap_percent_set _not_implemented_set
@@ -233,7 +233,7 @@ GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
 #define _vg_sysid_set _not_implemented_set
-GET_VG_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
+GET_VG_NUM_PROPERTY_FN(vg_extent_size, (SECTOR_SIZE * vg->extent_size))
 #define _vg_extent_size_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
 #define _vg_extent_count_set _not_implemented_set
@@ -269,17 +269,17 @@ GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg->lv->vg->vgmem, lvseg
 #define _segtype_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripes, lvseg->area_count)
 #define _stripes_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(stripesize, lvseg->stripe_size)
+GET_LVSEG_NUM_PROPERTY_FN(stripesize, (SECTOR_SIZE * lvseg->stripe_size))
 #define _stripesize_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(stripe_size, lvseg->stripe_size)
+GET_LVSEG_NUM_PROPERTY_FN(stripe_size, (SECTOR_SIZE * lvseg->stripe_size))
 #define _stripe_size_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(regionsize, lvseg->region_size)
+GET_LVSEG_NUM_PROPERTY_FN(regionsize, (SECTOR_SIZE * lvseg->region_size))
 #define _regionsize_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(region_size, lvseg->region_size)
+GET_LVSEG_NUM_PROPERTY_FN(region_size, (SECTOR_SIZE * lvseg->region_size))
 #define _region_size_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(chunksize, lvseg_chunksize(lvseg))
+GET_LVSEG_NUM_PROPERTY_FN(chunksize, (SECTOR_SIZE * lvseg_chunksize(lvseg)))
 #define _chunksize_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(chunk_size, lvseg_chunksize(lvseg))
+GET_LVSEG_NUM_PROPERTY_FN(chunk_size, (SECTOR_SIZE * lvseg_chunksize(lvseg)))
 #define _chunk_size_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(thin_count, dm_list_size(&lvseg->lv->segs_using_this_lv))
 #define _thin_count_set _not_implemented_set
@@ -289,7 +289,7 @@ GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
 #define _transaction_id_set _not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(discards, lvseg_discards_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _discards_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
+GET_LVSEG_NUM_PROPERTY_FN(seg_start, (SECTOR_SIZE * lvseg_start(lvseg)))
 #define _seg_start_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
 #define _seg_start_pe_set _not_implemented_set
@@ -307,7 +307,7 @@ GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 #define _pvseg_start_set _not_implemented_set
-GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, pvseg->len)
+GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
 #define _pvseg_size_set _not_implemented_set
 
 


