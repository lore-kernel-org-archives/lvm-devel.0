From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:51 +0000 (GMT)
Subject: main - gcc-fanalyzer: add extra check for origin_from_cow
Message-ID: <20210920132951.CAE7C3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e21c8524e8b31e61fe4db99664319e2823f1a53
Commit:        3e21c8524e8b31e61fe4db99664319e2823f1a53
Parent:        93d565eda992abc0460cc8fc7b9998bd1996a447
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 22:04:54 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 13:58:57 2021 +0200

gcc-fanalyzer: add extra check for origin_from_cow

Make analyzer work easier with explicit check for internal error.
---
 lib/metadata/snapshot_manip.c | 32 +++++++++++++++++++++++++-------
 tools/lvconvert.c             |  7 ++++++-
 2 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 463bb291b..99eb9c30d 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -111,13 +111,18 @@ int cow_has_min_chunks(const struct volume_group *vg, uint32_t cow_extents, uint
 
 int lv_is_cow_covering_origin(const struct logical_volume *lv)
 {
-	return lv_is_cow(lv) &&
-		(lv->size >= _cow_max_size(lv->vg->cmd, origin_from_cow(lv)->size,
-					   find_snapshot(lv)->chunk_size));
+	const struct logical_volume *origin;
+
+	return (lv_is_cow(lv) &&
+		(origin = origin_from_cow(lv)) &&
+		(lv->size >= _cow_max_size(lv->vg->cmd, origin->size,
+					   find_snapshot(lv)->chunk_size)));
 }
 
 int lv_is_visible(const struct logical_volume *lv)
 {
+	const struct logical_volume *origin;
+
 	if (lv_is_historical(lv))
 		return 1;
 
@@ -125,13 +130,16 @@ int lv_is_visible(const struct logical_volume *lv)
 		return 0;
 
 	if (lv_is_cow(lv)) {
-		if (lv_is_virtual_origin(origin_from_cow(lv)))
+		if (!(origin = origin_from_cow(lv)))
+			return_0;
+
+		if (lv_is_virtual_origin(origin))
 			return 1;
 
 		if (lv_is_merging_cow(lv))
 			return 0;
 
-		return lv_is_visible(origin_from_cow(lv));
+		return lv_is_visible(origin);
 	}
 
 	return lv->status & VISIBLE_LV ? 1 : 0;
@@ -160,6 +168,9 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 {
 	if (lv->snapshot)
 		return lv->snapshot->origin;
+
+	log_debug(INTERNAL_ERROR "Cannot get origin from snapshot %s.",
+		  display_lvname(lv));
 	return NULL;
 }
 
@@ -286,8 +297,15 @@ int vg_add_snapshot(struct logical_volume *origin,
 
 int vg_remove_snapshot(struct logical_volume *cow)
 {
-	struct logical_volume *origin = origin_from_cow(cow);
-	int is_origin_active = lv_is_active(origin);
+	struct logical_volume *origin;
+	int is_origin_active;
+
+	if (!lv_is_cow(cow))
+		return_0;
+
+	origin = origin_from_cow(cow);
+
+	is_origin_active = lv_is_active(origin);
 
 	if (is_origin_active &&
 	    lv_is_virtual_origin(origin)) {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 33ab0637d..a7fb848be 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2142,11 +2142,16 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 					 struct logical_volume **lv_to_poll)
 {
 	int merge_on_activate = 0;
-	struct logical_volume *origin = origin_from_cow(lv);
+	struct logical_volume *origin;
 	struct lv_segment *snap_seg = find_snapshot(lv);
 	struct lvinfo info;
 	dm_percent_t snap_percent;
 
+	if (!snap_seg)
+		return_0;
+
+	origin = origin_from_cow(lv);
+
 	/* Check if merge is possible */
 	if (lv_is_merging_origin(origin)) {
 		log_error("Cannot merge snapshot %s into the origin %s "


