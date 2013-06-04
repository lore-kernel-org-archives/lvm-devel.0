From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:29 +0000 (UTC)
Subject: dev-mornfall-activate - lvconvert: check for snapshot-merge support before merge init
Message-ID: <20130604192629.3448560D78@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4777eb68728859a0b3651e29c628111ed7c99103
Commit:        4777eb68728859a0b3651e29c628111ed7c99103
Parent:        4f6c2951d6495ee335ab69da44ae2647cd341276
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 16 08:21:57 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 16 08:21:57 2013 +0200

lvconvert: check for snapshot-merge support before merge init

---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/snapshot_manip.c    |   12 ++++++++++--
 tools/lvconvert.c                |    6 +++++-
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a4ffe26..c3cb116 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -734,7 +734,7 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv);
 void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 		       struct logical_volume *cow, uint32_t chunk_size, int merge);
 
-void init_snapshot_merge(struct lv_segment *cow_seg, struct logical_volume *origin);
+int init_snapshot_merge(struct lv_segment *cow_seg, struct logical_volume *origin);
 
 void clear_snapshot_merge(struct logical_volume *origin);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 0c10104..11f60d8 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -19,6 +19,7 @@
 #include "toolcontext.h"
 #include "lv_alloc.h"
 #include "activate.h"
+#include "segtype.h"
 
 int lv_is_origin(const struct logical_volume *lv)
 {
@@ -110,8 +111,8 @@ void init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 }
 
-void init_snapshot_merge(struct lv_segment *cow_seg,
-			 struct logical_volume *origin)
+int init_snapshot_merge(struct lv_segment *cow_seg,
+			struct logical_volume *origin)
 {
 	/*
 	 * Even though lv_is_visible(cow_seg->lv) returns 0,
@@ -127,6 +128,13 @@ void init_snapshot_merge(struct lv_segment *cow_seg,
 	cow_seg->status |= MERGING;
 	origin->snapshot = cow_seg;
 	origin->status |= MERGING;
+
+	if (cow_seg->segtype->ops->target_present &&
+	    !cow_seg->segtype->ops->target_present(cow_seg->lv->vg->cmd,
+				cow_seg, NULL))
+		return 0;
+
+	return 1;
 }
 
 void clear_snapshot_merge(struct logical_volume *origin)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7b4bb6e..17e39ae 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1832,7 +1832,11 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		}
 	}
 
-	init_snapshot_merge(cow_seg, origin);
+	if (!init_snapshot_merge(cow_seg, origin)) {
+		log_error("Can't initialize snapshot merge. "
+			  "Missing support in kernel?");
+		return_0;
+	}
 
 	/* store vg on disk(s) */
 	if (!vg_write(lv->vg))


