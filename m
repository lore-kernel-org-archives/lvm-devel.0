From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:13 +0000 (UTC)
Subject: master - snapshot: code move
Message-ID: <20131122200913.6BF9761133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ff53bb7b682a13e32d986e53a40eeb8fb5e47c4
Commit:        1ff53bb7b682a13e32d986e53a40eeb8fb5e47c4
Parent:        30c127eaf8561c9fc4b0aecace2991d3551a5dd3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 18:19:13 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

snapshot: code move

Move some code lines in front, they will be shared with thin snapshot
merge later.
---
 lib/metadata/snapshot_manip.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index c491918..3e90f3e 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -154,6 +154,10 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 void init_snapshot_merge(struct lv_segment *snap_seg,
 			 struct logical_volume *origin)
 {
+	snap_seg->status |= MERGING;
+	origin->snapshot = snap_seg;
+	origin->status |= MERGING;
+
 	/*
 	 * Even though lv_is_visible(snap_seg->lv) returns 0,
 	 * the snap_seg->lv (name: snapshotX) is _not_ hidden;
@@ -165,9 +169,6 @@ void init_snapshot_merge(struct lv_segment *snap_seg,
 	 *   merge metadata (snap_seg->lv is now "internal")
 	 */
 	snap_seg->lv->status &= ~VISIBLE_LV;
-	snap_seg->status |= MERGING;
-	origin->snapshot = snap_seg;
-	origin->status |= MERGING;
 }
 
 void clear_snapshot_merge(struct logical_volume *origin)


