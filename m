From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:08:56 +0000 (UTC)
Subject: master - snapshot: revert and move check to lvconvert
Message-ID: <20131122200856.BBEC760EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d196410fc071cfe15638bbde0b3ac8bbbf4be53
Commit:        6d196410fc071cfe15638bbde0b3ac8bbbf4be53
Parent:        3d3b8bfd1c7cc22383580b2723415ddcf9fbe7d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 14:52:35 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 20:57:30 2013 +0100

snapshot: revert and move check to lvconvert

Revert 4777eb68728859a0b3651e29c628111ed7c99103 which put
target_present check into init_snapshot_merge(). However
this function is also used when parsing metadata. So we would
get this present test performed even when target is not really
needed. So move this target_present test directly into lvconvert.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/snapshot_manip.c    |   12 ++----------
 tools/lvconvert.c                |    8 ++++++--
 4 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 41251b8..119463b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Move test for target present from init_snapshot_merge() to lvconvert.
   Check for failure of lvmcache_add_mda() when writing pv.
   Check for failure of dev_get_size() when reporting device size.
   Drop extra unneeded '/' when scanning sysfs directory.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ed1ec8d..33c534f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -880,7 +880,7 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		       struct logical_volume *cow, uint32_t chunk_size, int merge);
 
-int init_snapshot_merge(struct lv_segment *snap_seg, struct logical_volume *origin);
+void init_snapshot_merge(struct lv_segment *snap_seg, struct logical_volume *origin);
 
 void clear_snapshot_merge(struct logical_volume *origin);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index fc1273e..c491918 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -19,7 +19,6 @@
 #include "toolcontext.h"
 #include "lv_alloc.h"
 #include "activate.h"
-#include "segtype.h"
 
 int lv_is_origin(const struct logical_volume *lv)
 {
@@ -152,8 +151,8 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 }
 
-int init_snapshot_merge(struct lv_segment *snap_seg,
-			struct logical_volume *origin)
+void init_snapshot_merge(struct lv_segment *snap_seg,
+			 struct logical_volume *origin)
 {
 	/*
 	 * Even though lv_is_visible(snap_seg->lv) returns 0,
@@ -169,13 +168,6 @@ int init_snapshot_merge(struct lv_segment *snap_seg,
 	snap_seg->status |= MERGING;
 	origin->snapshot = snap_seg;
 	origin->status |= MERGING;
-
-	if (snap_seg->segtype->ops->target_present &&
-	    !snap_seg->segtype->ops->target_present(snap_seg->lv->vg->cmd,
-						    snap_seg, NULL))
-		return 0;
-
-	return 1;
 }
 
 void clear_snapshot_merge(struct logical_volume *origin)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 92a2022..6a7281b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1919,10 +1919,14 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		}
 	}
 
-	if (!init_snapshot_merge(snap_seg, origin)) {
+	init_snapshot_merge(snap_seg, origin);
+
+	if (snap_seg->segtype->ops->target_present &&
+	    !snap_seg->segtype->ops->target_present(snap_seg->lv->vg->cmd,
+						    snap_seg, NULL)) {
 		log_error("Can't initialize snapshot merge. "
 			  "Missing support in kernel?");
-		return_0;
+		return 0;
 	}
 
 	/* store vg on disk(s) */


