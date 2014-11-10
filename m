From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:06 +0000 (UTC)
Subject: master - cache: used cache-pool becomes invisible
Message-ID: <20141110210606.B22C960E17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32e4af6479689c4e25ecd273368d22136c93a75d
Commit:        32e4af6479689c4e25ecd273368d22136c93a75d
Parent:        09e32e4addd63d232ea98b0c6d633efbfc503daf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 9 21:04:33 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 21:36:21 2014 +0100

cache: used cache-pool becomes invisible

While cache-pool is in use - it is considered invisible.
---
 WHATS_NEW                 |    1 +
 lib/metadata/pool_manip.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8c0a85d..6084ee7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Cache-pool in use becomes invisible LV.
   Don't prompt for removal of _pmspare in VG without pool metadata LV.
   Deactivation of snapshot origin detects and deactivates left-over snapshots.
   Properly report error when taking snapshot of any cache type LV.
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 7152c51..b2e99f1 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -102,6 +102,9 @@ int attach_pool_lv(struct lv_segment *seg,
 	seg->origin = origin;
 	seg->lv->status |= seg_is_cache(seg) ? CACHE : THIN_VOLUME;
 
+	if (seg_is_cache(seg))
+		lv_set_hidden(pool_lv); /* Used cache-pool is hidden */
+
 	if (origin && !add_seg_to_segs_using_this_lv(origin, seg))
 		return_0;
 
@@ -137,6 +140,7 @@ int detach_pool_lv(struct lv_segment *seg)
 		if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
 			return_0;
 		seg->lv->status &= ~CACHE;
+		lv_set_visible(seg->pool_lv);
 		seg->pool_lv = NULL;
 		return 1;
 	}


