From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Apr 2019 13:01:46 -0400
Subject: master - hints: fix non-empty hints list when not using hints
Message-ID: <201904111701.x3BH1k2K001378@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0b869e46a935003c8ed99dbbbd2d2e745315ff6
Commit:        d0b869e46a935003c8ed99dbbbd2d2e745315ff6
Parent:        0cc80ccfd5215073f0f0b0aa3c2913076ae01751
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 11 11:49:18 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 11 11:58:51 2019 -0500

hints: fix non-empty hints list when not using hints

When hints are invalid and ignored, the list of hints
could be non-empty (from additions before an invalid
hint was found).  This confused the calling code which
was checking for an empty list to see if hints were used.
Ensure the list is empty when hints are not used.
---
 lib/label/hints.c |   15 ++++++++++-----
 lib/label/label.c |   16 +++++++++-------
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index eb0e725..a9e9e07 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1147,12 +1147,15 @@ check:
  * Returns 1: use hints that are returned in hints list.
  */
 
-int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
+int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	      struct dm_list *devs_in, struct dm_list *devs_out)
 {
+	struct dm_list hints_list;
 	int needs_refresh = 0;
 	char *vgname = NULL;
 
+	dm_list_init(&hints_list);
+
 	/* Decide below if the caller should create new hints. */
 	*newhints = NEWHINTS_NONE;
 
@@ -1230,7 +1233,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
 	/*
 	 * couln't read file for some reason, not normal, just skip using hints
 	 */
-	if (!_read_hint_file(cmd, hints, &needs_refresh)) {
+	if (!_read_hint_file(cmd, &hints_list, &needs_refresh)) {
 		log_debug("get_hints: read fail");
 		_unlock_hints();
 		return 0;
@@ -1259,7 +1262,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
 	 * of the hints file so it will be recreated, and we must
 	 * be following that since we found no hints.
 	 */
-	if (dm_list_empty(hints)) {
+	if (dm_list_empty(&hints_list)) {
 		log_debug("get_hints: no entries");
 
 		if (!_lock_hints(LOCK_EX, NONBLOCK))
@@ -1279,12 +1282,14 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
 	 * us which devs are PVs. We might want to enable this optimization
 	 * separately.)
 	 */
-	_get_single_vgname_cmd_arg(cmd, hints, &vgname);
+	_get_single_vgname_cmd_arg(cmd, &hints_list, &vgname);
 
-	_apply_hints(cmd, hints, vgname, devs_in, devs_out);
+	_apply_hints(cmd, &hints_list, vgname, devs_in, devs_out);
 
 	log_debug("get_hints: applied using %d other %d",
 		  dm_list_size(devs_out), dm_list_size(devs_in));
+
+	dm_list_splice(hints_out, &hints_list);
 	return 1;
 }
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 6b3d16c..fc74272 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -855,7 +855,7 @@ int label_scan(struct cmd_context *cmd)
 {
 	struct dm_list all_devs;
 	struct dm_list scan_devs;
-	struct dm_list hints;
+	struct dm_list hints_list;
 	struct dev_iter *iter;
 	struct device_list *devl, *devl2;
 	struct device *dev;
@@ -866,7 +866,7 @@ int label_scan(struct cmd_context *cmd)
 
 	dm_list_init(&all_devs);
 	dm_list_init(&scan_devs);
-	dm_list_init(&hints);
+	dm_list_init(&hints_list);
 
 	/*
 	 * Iterate through all the devices in dev-cache (block devs that appear
@@ -930,8 +930,10 @@ int label_scan(struct cmd_context *cmd)
 	 * able to avoid rescan in vg_read, but locking early would
 	 * apply to more cases.)
 	 */
-	if (!get_hints(cmd, &hints, &newhints, &all_devs, &scan_devs))
+	if (!get_hints(cmd, &hints_list, &newhints, &all_devs, &scan_devs)) {
 		dm_list_splice(&scan_devs, &all_devs);
+		dm_list_init(&hints_list);
+	}
 
 	log_debug("Will scan %d devices skip %d", dm_list_size(&scan_devs), dm_list_size(&all_devs));
 
@@ -977,8 +979,8 @@ int label_scan(struct cmd_context *cmd)
 
 	dm_list_init(&cmd->hints);
 
-	if (!dm_list_empty(&hints)) {
-		if (!validate_hints(cmd, &hints)) {
+	if (!dm_list_empty(&hints_list)) {
+		if (!validate_hints(cmd, &hints_list)) {
 			/*
 			 * We scanned a subset of all devices based on hints.
 			 * With the results from the scan we may decide that
@@ -986,11 +988,11 @@ int label_scan(struct cmd_context *cmd)
 			 */
 			log_debug("Will scan %d remaining devices", dm_list_size(&all_devs));
 			_scan_list(cmd, cmd->filter, &all_devs, NULL);
-			_free_hints(&hints);
+			_free_hints(&hints_list);
 			newhints = 0;
 		} else {
 			/* The hints may be used by another device iteration. */
-			dm_list_splice(&cmd->hints, &hints);
+			dm_list_splice(&cmd->hints, &hints_list);
 		}
 	}
 


