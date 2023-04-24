From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Apr 2023 20:57:56 +0000 (GMT)
Subject: main - fix dev_name use in add_areas_line
Message-ID: <20230424205756.167E53858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31cfcf7ce9aab5dd16ba15e48bfe33be849fad4c
Commit:        31cfcf7ce9aab5dd16ba15e48bfe33be849fad4c
Parent:        afc02ae6e7234e1190cedf5c74ca3d6367efd7d1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 24 15:47:45 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 24 15:49:00 2023 -0500

fix dev_name use in add_areas_line

This function was relying on dev_name() returning NULL
to indicate no device, but dev_name never returns NULL.
---
 lib/activate/dev_manager.c | 45 +++++++++++++++++++++++++++++----------------
 1 file changed, 29 insertions(+), 16 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 07d58733e..ac3f01718 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3000,34 +3000,47 @@ static int _add_error_area(struct dev_manager *dm, struct dm_tree_node *node,
 	return 1;
 }
 
+static int _bad_pv_area(struct lv_segment *seg, uint32_t s)
+{
+	struct stat info;
+	const char *name;
+	struct device *dev;
+
+	if (!seg_pvseg(seg, s))
+		return 1;
+	if (!seg_pv(seg, s))
+		return 1;
+	if (!(dev = seg_dev(seg, s)))
+		return 1;
+	if (dm_list_empty(&dev->aliases))
+		return 1;
+	/* FIXME Avoid repeating identical stat in dm_tree_node_add_target_area */
+	name = dev_name(dev);
+	if (stat(name, &info) < 0)
+		return 1;
+	if (!S_ISBLK(info.st_mode))
+		return 1;
+	return 0;
+}
+
 int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 		   struct dm_tree_node *node, uint32_t start_area,
 		   uint32_t areas)
 {
+	struct cmd_context *cmd = seg->lv->vg->cmd;
 	uint64_t extent_size = seg->lv->vg->extent_size;
 	uint32_t s;
 	char *dlid;
-	struct stat info;
 	const char *name;
 	unsigned num_error_areas = 0;
 	unsigned num_existing_areas = 0;
 
-	/* FIXME Avoid repeating identical stat in dm_tree_node_add_target_area */
 	for (s = start_area; s < areas; s++) {
-
-		/* FIXME: dev_name() does not return NULL!  It needs to check if dm_list_empty(&dev->aliases)
-		   but this knot of logic is too complex to pull apart without careful deconstruction. */
-
-		if ((seg_type(seg, s) == AREA_PV &&
-		     (!seg_pvseg(seg, s) || !seg_pv(seg, s) || !seg_dev(seg, s) ||
-		       !(name = dev_name(seg_dev(seg, s))) || !*name ||
-		       stat(name, &info) < 0 || !S_ISBLK(info.st_mode))) ||
-		    (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s))) {
-			if (!seg->lv->vg->cmd->partial_activation) {
-				if (!seg->lv->vg->cmd->degraded_activation ||
-				    !lv_is_raid_type(seg->lv)) {
-					log_error("Aborting.  LV %s is now incomplete "
-						  "and '--activationmode partial' was not specified.",
+		if (((seg_type(seg, s) == AREA_PV) && _bad_pv_area(seg, s)) ||
+		    ((seg_type(seg, s) == AREA_LV) && !seg_lv(seg, s))) {
+			if (!cmd->partial_activation) {
+				if (!cmd->degraded_activation || !lv_is_raid_type(seg->lv)) {
+					log_error("Aborting.  LV %s is incomplete and --activationmode partial was not specified.",
 						  display_lvname(seg->lv));
 					return 0;
 				}

