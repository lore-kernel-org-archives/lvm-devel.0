From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 13 Jan 2012 21:56:39 -0500
Subject: [PATCH] Add invalid snapshot awareness to snapshot merge support
Message-ID: <20120114025639.GA10541@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Prevent an invalid snapshot from being merged via lvconvert.
Allow an merging snapshot that was invalidated to be removed (useful for
a snapshot merge that was deferred until next activation but the
snapshot was invalidated beforehand).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/dev_manager.c       |   11 +++++++++--
 lib/metadata/lv.c                |    4 +---
 lib/metadata/lv_manip.c          |   15 +++++++++++----
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/snapshot_manip.c    |   10 ++++++++++
 tools/lvconvert.c                |    7 +++++++
 6 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 513aaa8..a1c3b90 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -742,6 +742,7 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 percent_t *percent)
 {
+	const struct logical_volume *_lv;
 	char *name;
 	const char *dlid;
 	int fail_if_percent_unsupported = 0;
@@ -761,13 +762,19 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 		fail_if_percent_unsupported = 1;
 	}
 
+	if (lv_is_merging_cow(lv)) {
+		/* must check percent of origin for a merging snapshot */
+		_lv = origin_from_cow(lv);
+	} else
+		_lv = lv;
+
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = dm_build_dm_name(dm->mem, _lv->vg->name, _lv->name, NULL)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, _lv->lvid.s, NULL)))
 		return_0;
 
 	/*
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index ed6b42d..9391d7f 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -348,7 +348,6 @@ static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 }
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	percent_t snap_percent;
 	struct lvinfo info;
 	struct lv_segment *seg;
 	char *repstr;
@@ -422,8 +421,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 		/* Snapshot dropped? */
 		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent) ||
-		     snap_percent == PERCENT_INVALID)) {
+		    lv_is_invalid_cow(lv)) {
 			repstr[0] = toupper(repstr[0]);
 			if (info.suspended)
 				repstr[4] = 'S'; /* Susp Inv snapshot */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0675350..8f0f452 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3262,13 +3262,20 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	struct dm_list *snh, *snht;
 	struct seg_list *sl, *tsl;
+	struct lvinfo info;
 
 	if (lv_is_cow(lv)) {
-		/* A merging snapshot cannot be removed directly */
+		/*
+		 * A merging snapshot cannot be removed directly unless
+		 * it has been invalidated.
+		 */
 		if (lv_is_merging_cow(lv) && !level) {
-			log_error("Can't remove merging snapshot logical volume \"%s\"",
-				  lv->name);
-			return 0;
+			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists &&
+			    info.live_table && !lv_is_invalid_cow(lv)) {
+				log_error("Can't remove merging snapshot logical volume \"%s\"",
+					  lv->name);
+				return 0;
+			}
 		}
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f516f3d..2179663 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -678,6 +678,7 @@ int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_origin(const struct logical_volume *origin);
 int lv_is_merging_cow(const struct logical_volume *snapshot);
+int lv_is_invalid_cow(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
 int lv_is_visible(const struct logical_volume *lv);
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 5766d0b..1e12aa1 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -30,6 +30,16 @@ int lv_is_cow(const struct logical_volume *lv)
 	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
+int lv_is_invalid_cow(const struct logical_volume *lv)
+{
+	percent_t snap_percent;
+
+	if (!lv_snapshot_percent(lv, &snap_percent) ||
+	    snap_percent == PERCENT_INVALID)
+		return 1;
+	return 0;
+}
+
 int lv_is_visible(const struct logical_volume *lv)
 {
 	if (lv->status & SNAPSHOT)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9553b9b..d2eb99b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1706,6 +1706,7 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct lvconvert_params *lp = handle;
 	struct dm_list *failed_pvs;
+	struct lvinfo info;
 
 	if (lv->status & LOCKED) {
 		log_error("Cannot convert locked LV %s", lv->name);
@@ -1739,6 +1740,12 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 				  lv->name);
 			return ECMD_FAILED;
 		}
+	        if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
+                	if (info.live_table && lv_is_invalid_cow(lv)) {
+	                        log_error("Unable to merge invalidated snapshot LV \"%s\"", lv->name);
+        	                return ECMD_FAILED;
+                	}
+		}
 		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;


