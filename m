From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:02 +0000 (UTC)
Subject: master - conf: support zero for missing_stripe_filler
Message-ID: <20161111160002.5A79B601DB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8fc4d093ee125e3667046b892c14e4a920a8da0
Commit:        d8fc4d093ee125e3667046b892c14e4a920a8da0
Parent:        e54cce245f2829107e1ed09221bca7ff7921d98b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 18 12:58:22 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:16 2016 +0100

conf: support zero for missing_stripe_filler

Make it easier to replace missing segments with 'zero' returning
target - otherwise user would have to create some extra target
to provide zeros as /dev/zero can't be used (not a block device).

Also break code loop when segment is found and make it an INTERNAL_ERROR
where it's missing.
---
 WHATS_NEW                    |    1 +
 lib/activate/dev_manager.c   |   24 ++++++++++++++++--------
 lib/commands/toolcontext.c   |    3 ++-
 lib/config/config_settings.h |    3 ++-
 4 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2af2992..57c382f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Missing stripe filler now could be also 'zero'.
   lvconvert --repair accepts --interval and --background option.
   More efficiently prepare _rmeta devices when creating a new raid LV.
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2dc0fd8..dcea359 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2250,8 +2250,8 @@ bad:
 	return NULL;
 }
 
-static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
-			       struct lv_segment *seg, int s)
+static char *_add_error_or_zero_device(struct dev_manager *dm, struct dm_tree *dtree,
+				       struct lv_segment *seg, int s, int use_zero)
 {
 	char *dlid, *name;
 	char errid[32];
@@ -2262,13 +2262,15 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 	uint64_t size = (uint64_t) seg->len * seg->lv->vg->extent_size;
 
 	dm_list_iterate_items(seg_i, &seg->lv->segments) {
-		if (seg == seg_i)
+		if (seg == seg_i) {
 			segno = i;
+			break;
+		}
 		++i;
 	}
 
 	if (segno < 0) {
-		log_error("_add_error_device called with bad segment");
+		log_error(INTERNAL_ERROR "_add_error_or_zero_device called with bad segment.");
 		return NULL;
 	}
 
@@ -2291,8 +2293,13 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 		/* Create new node */
 		if (!(node = dm_tree_add_new_dev(dtree, name, dlid, 0, 0, 0, 0, 0)))
 			return_NULL;
-		if (!dm_tree_node_add_error_target(node, size))
-			return_NULL;
+
+		if (use_zero) {
+			if (!dm_tree_node_add_zero_target(node, size))
+				return_NULL;
+		} else
+			if (!dm_tree_node_add_error_target(node, size))
+				return_NULL;
 	} else {
 		/* Already exists */
 		if (!dm_tree_add_dev(dtree, info.major, info.minor)) {
@@ -2310,14 +2317,15 @@ static int _add_error_area(struct dev_manager *dm, struct dm_tree_node *node,
 {
 	char *dlid;
 	uint64_t extent_size = seg->lv->vg->extent_size;
+	int use_zero = !strcmp(dm->cmd->stripe_filler, TARGET_NAME_ZERO) ? 1 : 0;
 
-	if (!strcmp(dm->cmd->stripe_filler, TARGET_NAME_ERROR)) {
+	if (!strcmp(dm->cmd->stripe_filler, TARGET_NAME_ERROR) || use_zero) {
 		/*
 		 * FIXME, the tree pointer is first field of dm_tree_node, but
 		 * we don't have the struct definition available.
 		 */
 		struct dm_tree **tree = (struct dm_tree **) node;
-		if (!(dlid = _add_error_device(dm, *tree, seg, s)))
+		if (!(dlid = _add_error_or_zero_device(dm, *tree, seg, s, use_zero)))
 			return_0;
 		if (!dm_tree_node_add_target_area(node, NULL, dlid, extent_size * seg_le(seg, s)))
 			return_0;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 002af05..bfb7c1b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -640,7 +640,8 @@ static int _process_config(struct cmd_context *cmd)
 	if (!strcmp(cmd->stripe_filler, "/dev/ioerror") &&
 	    stat(cmd->stripe_filler, &st))
 		cmd->stripe_filler = "error";
-	else if (strcmp(cmd->stripe_filler, "error")) {
+	else if (strcmp(cmd->stripe_filler, "error") &&
+		 strcmp(cmd->stripe_filler, "zero")) {
 		if (stat(cmd->stripe_filler, &st)) {
 			log_warn("WARNING: activation/missing_stripe_filler = \"%s\" "
 				 "is invalid,", cmd->stripe_filler);
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9eed969..e0770b6 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1111,7 +1111,8 @@ cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECT
 cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL, 0, NULL,
 	"Method to fill missing stripes when activating an incomplete LV.\n"
 	"Using 'error' will make inaccessible parts of the device return I/O\n"
-	"errors on access. You can instead use a device path, in which case,\n"
+	"errors on access. Using 'zero' will return success (and zero) on I/O\n"
+	"You can instead use a device path, in which case,\n"
 	"that device will be used in place of missing stripes. Using anything\n"
 	"other than 'error' with mirrored or snapshotted volumes is likely to\n"
 	"result in data corruption.\n")


