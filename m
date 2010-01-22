From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 22 Jan 2010 09:15:30 -0500
Subject: [PATCH 1/3] Eliminate extra status ioctls that check open_count in _add_new_lv_to_dtree.
In-Reply-To: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
References: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
Message-ID: <1264169732-8692-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

DM >= 4.7.0 always returns open_count so just use the associated nodes'
existing info.

Introduce _cached_info() to get an LV's cached info.
---
 lib/activate/dev_manager.c |   46 +++++++++++++++++++++++++++++++++++--------
 1 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3d3c14b..25b7a10 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -249,6 +249,35 @@ int dev_manager_info(struct dm_pool *mem, const char *name,
 		     info, read_ahead);
 }
 
+static const struct dm_info *_cached_info(struct dm_pool *mem,
+					  const struct logical_volume *lv,
+					  struct dm_tree *dtree)
+{
+	const char *dlid;
+	struct dm_tree_node *dnode;
+	const struct dm_info *dinfo;
+
+	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
+		log_error("dlid build failed for %s", lv->name);
+		return NULL;
+	}
+
+	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid))) {
+		log_error("failed to find tree node for %s", lv->name);
+		return NULL;
+	}
+
+	if (!(dinfo = dm_tree_node_get_info(dnode))) {
+		log_error("failed to get info from tree node for %s", lv->name);
+		return NULL;
+	}
+
+	if (!dinfo->exists)
+		return NULL;
+
+	return dinfo;
+}
+
 /* FIXME Interface must cope with multiple targets */
 static int _status_run(const char *name, const char *uuid,
 		       unsigned long long *s, unsigned long long *l,
@@ -1117,7 +1146,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
-	struct dm_info dinfo;
+	const struct dm_info *dinfo;
 	char *name, *dlid, *lv_name;
 	uint32_t max_stripe_size = UINT32_C(0);
 	uint32_t read_ahead = lv->read_ahead;
@@ -1130,15 +1159,14 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/*
 		 * Clear merge attributes if merge isn't currently possible:
 		 * either origin or merging snapshot are open
-		 * - must refresh info's open_count, so using the tree's
-		 *   existing nodes' info isn't an option
-		 * - but use "snapshot-merge" if it is already being used
+		 * - but use "snapshot-merge" if it is already in use
+		 * - open_count is always retrieved (as of dm-ioctl 4.7.0)
+		 *   so just use the tree's existing nodes' info
 		 */
-		/* FIXME Avoid this - open_count is always returned by kernel now. */
-		if ((dev_manager_info(dm->mem, NULL, lv,
-				      0, 1, 0, &dinfo, NULL) && dinfo.open_count) ||
-		    (dev_manager_info(dm->mem, NULL, find_merging_cow(lv)->cow,
-				      0, 1, 0, &dinfo, NULL) && dinfo.open_count)) {
+		if (((dinfo = _cached_info(dm->mem, lv,
+					   dtree)) && dinfo->open_count) ||
+		    ((dinfo = _cached_info(dm->mem, find_merging_cow(lv)->cow,
+					   dtree)) && dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge"))
 				clear_snapshot_merge(lv);
-- 
1.6.6


