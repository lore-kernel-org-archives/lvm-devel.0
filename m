From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:32 +0000 (UTC)
Subject: master - thin: report pool as holder when no active thin volume
Message-ID: <20160919120132.6FB336050A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=776d5a25b4ab036103ec99291cb0056fa61490fa
Commit:        776d5a25b4ab036103ec99291cb0056fa61490fa
Parent:        c26cd4853668f1da94eb98e18d7a52c93fd21197
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 16 21:47:57 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

thin: report pool as holder when no active thin volume

In the case there is no active thin volume, report thin pool
as lock holder. This fixed function like lvextend
which either expecte lock holder LV is some active thin
or 'possibly' inactive thin pool.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9c6ba3b..649607b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lock-holder device for thin pool with inactive thin volumes.
   Use --alloc normal for mirror logs even if the mimages were stricter.
   Use O_DIRECT to gather metadata in lvmdump.
   Fix possible NULL pointer derefence when checking for monitoring.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 33129e3..188a255 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1547,7 +1547,7 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 	if (lv_is_cow(lv))
 		return lv_lock_holder(origin_from_cow(lv));
 
-	if (lv_is_thin_pool(lv))
+	if (lv_is_thin_pool(lv)) {
 		/* Find any active LV from the pool */
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
 			if (lv_is_active(sl->seg->lv)) {
@@ -1555,6 +1555,8 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 						     display_lvname(lv));
 				return sl->seg->lv;
 			}
+		return lv;
+	}
 
 	/* RAID changes visibility of splitted LVs but references them still as leg/meta */
 	if ((lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) && lv_is_visible(lv))


