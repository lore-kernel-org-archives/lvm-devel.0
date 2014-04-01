From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:55:59 +0000 (UTC)
Subject: master - cache: cache segment is non-discardable
Message-ID: <20140401185559.031596092A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a15a210a532f7d1d46b042adbd8d3c65793f103
Commit:        0a15a210a532f7d1d46b042adbd8d3c65793f103
Parent:        a018c57f0bd36f1b56c67a2afe5254e6da8251b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 17:57:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:17:10 2014 +0200

cache: cache segment is non-discardable

Since cache segment is purely virtual mapping, it has nothing for
discard. Discardable is cache origin here which is now
properly removed on 'delete' phase.

Plain lv_empty() call needs to only detach cache origin and leave
origin unchanged.
---
 lib/metadata/lv_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 17933a2..618c1a1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -561,8 +561,7 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 		return 1;
 	}
 
-	if (seg_is_cache(seg) ||
-	    (seg_lv(seg, s)->status & MIRROR_IMAGE) ||
+	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
 	    (seg_lv(seg, s)->status & THIN_POOL_DATA) ||
 	    (seg_lv(seg, s)->status & CACHE_POOL_DATA)) {
 		if (!lv_reduce(seg_lv(seg, s), area_reduction))
@@ -814,6 +813,10 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 			if (seg->metadata_lv && !lv_remove(seg->metadata_lv))
 				return_0;
 
+			/* Remove cache origin only when removing (not on lv_empty()) */
+			if (delete && seg_is_cache(seg) && !lv_remove(seg_lv(seg, 0)))
+				return_0;
+
 			if (seg->pool_lv && !detach_pool_lv(seg))
 				return_0;
 


