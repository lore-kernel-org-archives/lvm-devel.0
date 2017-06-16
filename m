From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:28 -0400
Subject: master - raid: report percent with segtype info
Message-ID: <201706161513.v5GFDS8P011174@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59d646167f8f47fbef3231469675f52d90432205
Commit:        59d646167f8f47fbef3231469675f52d90432205
Parent:        529dcaf6a3c4fea4a15baf13cf057d2333860c05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 16 13:20:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:01 2017 +0200

raid: report percent with segtype info

Enhance reporting code, so it does not need to do 'extra' ioctl to
get 'status' of normal raid and provide percentage directly.

When we have 'merging' snapshot into raid origin, we still need to get
this secondary number with extra status call - however, since  'raid'
is always a single segment LV - we may skip 'copy_percent' call as
we directly know the percent and also with better precision.

NOTE: for mirror we still base reported number on the percetage of
transferred extents which might get quite imprecisse if big size
of extent is used while volume itself is smaller as reporting jump
steps are much bigger the actual reported number provides.

2nd.NOTE: raid lvs line report already requires quite a few extra status
calls for the same device - but fix will be need slight code improval.
---
 WHATS_NEW           |    1 +
 lib/metadata/lv.c   |    9 +++++++++
 lib/report/report.c |   10 ++++++----
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b2796f6..305e185 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Improve raid status reporting with lvs.
   No longer necessary to '--force' a repair for RAID1
   Linear to RAID1 upconverts now use "recover" sync action, not "resync".
   Improve lvcreate --cachepool arg validation.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b24c4aa..555df1a 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -395,6 +395,15 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 			}
 		}
 		break;
+	case SEG_STATUS_RAID:
+		switch (type) {
+		case PERCENT_GET_DIRTY:
+			p = dm_make_percent(s->raid->insync_regions, s->raid->total_regions);
+			break;
+		default:
+			p = DM_PERCENT_INVALID;
+		}
+		break;
 	case SEG_STATUS_SNAPSHOT:
 		if (s->snapshot->merge_failed)
 			p = DM_PERCENT_INVALID;
diff --git a/lib/report/report.c b/lib/report/report.c
index d9880b2..f61776e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3079,11 +3079,13 @@ static int _copypercent_disp(struct dm_report *rh,
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	/* TODO: just cache passes through lvseg_percent... */
-	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv))
+	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv) ||
+	    (!lv_is_merging_origin(lv) && lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv))))
 		percent = lvseg_percent_with_info_and_seg_status(lvdm, PERCENT_GET_DIRTY);
-	else if (((lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv)) &&
-		   lv_raid_percent(lv, &percent)) ||
-		  (lv_is_mirror(lv) &&
+	else if (lv_is_raid(lv) && !seg_is_any_raid0(first_seg(lv)))
+		/* old way for percentage when merging snapshot into raid origin */
+		(void) lv_raid_percent(lv, &percent);
+	else if (((lv_is_mirror(lv) &&
 		   lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
 		 (percent != DM_PERCENT_INVALID))
 		percent = copy_percent(lv);


