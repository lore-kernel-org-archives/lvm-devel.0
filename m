From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  4 Jul 2013 11:34:26 +0000 (UTC)
Subject: master - thin: swap if branch
Message-ID: <20130704113426.F0EAD60EF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=969c87fa5b66859567a2d6de2b6700ee795d8e59
Commit:        969c87fa5b66859567a2d6de2b6700ee795d8e59
Parent:        f88f5a1ca3b0c77a2c353460ff35d802bbb05a34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 4 11:25:41 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 4 13:33:41 2013 +0200

thin: swap if branch

Move shorter if branch in front.
Use buffer for _tmeta and _tdata names so too long name
of LV is earlier detected.
---
 tools/lvconvert.c |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c2041c0..fff0188 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1991,13 +1991,12 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 {
 	int r = 0;
 	const char *old_name;
-	int len = strlen(pool_lv->name) + 16; /* _tmeta, _tdata */
 	struct lv_segment *seg;
 	struct logical_volume *data_lv = pool_lv;
 	struct logical_volume *metadata_lv;
 	struct logical_volume *pool_metadata_lv;
 	struct logical_volume *external_lv = NULL;
-	char metadata_name[len], data_name[len];
+	char metadata_name[NAME_LEN], data_name[NAME_LEN];
 
 	if (!lv_is_visible(pool_lv)) {
 		log_error("Can't convert internal LV %s/%s.",
@@ -2035,11 +2034,28 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			 pool_lv->name) < 0) ||
 	    (dm_snprintf(data_name, sizeof(data_name), "%s_tdata",
 			 pool_lv->name) < 0)) {
-		log_error("Failed to create lv names.");
+		log_error("Failed to create internal lv names, "
+			  "thin pool name is too long.");
 		return 0;
 	}
 
-	if (lp->pool_metadata_lv_name) {
+	if (!lp->pool_metadata_lv_name) {
+		if (!update_pool_params(cmd, lp->target_attr, lp->passed_args,
+					pool_lv->le_count, pool_lv->vg->extent_size,
+					&lp->chunk_size, &lp->discards,
+					&lp->poolmetadata_size))
+			return_0;
+
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
+
+		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
+							lp->read_ahead,	lp->stripes,
+							lp->stripe_size,
+							lp->poolmetadata_size,
+							lp->alloc, lp->pvh)))
+			return_0;
+	} else {
 		if (!(metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name))) {
 			log_error("Unknown metadata LV %s.", lp->pool_metadata_lv_name);
 			return 0;
@@ -2135,22 +2151,6 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 					&lp->chunk_size, &lp->discards,
 					&lp->poolmetadata_size))
 			return_0;
-	} else {
-		if (!update_pool_params(cmd, lp->target_attr, lp->passed_args,
-					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadata_size))
-			return_0;
-
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
-			return_0;
-
-		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
-							lp->read_ahead,	lp->stripes,
-							lp->stripe_size,
-							lp->poolmetadata_size,
-							lp->alloc, lp->pvh)))
-			return_0;
 	}
 
 	if (!deactivate_lv(cmd, metadata_lv)) {
@@ -2203,7 +2203,7 @@ mda_write:
 
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */
-	if (strcmp(metadata_lv->name, metadata_name) &&
+	if (!lp->pool_metadata_lv_name &&
 	    !lv_rename_update(cmd, metadata_lv, metadata_name, 0))
 		return_0;
 


