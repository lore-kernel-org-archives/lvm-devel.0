From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Jun 2014 12:44:45 +0000 (UTC)
Subject: master - compilation: fix warnings: build_dm_uuid now accepts whole struct logical_volume, not lvid
Message-ID: <20140618124445.736C2602BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21964f47d5e30d925cd8e80b6402f1a2c69ad673
Commit:        21964f47d5e30d925cd8e80b6402f1a2c69ad673
Parent:        fc6e2a703b604ea5c69f7ea2e00a871c70514b73
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 18 14:43:13 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 18 14:43:13 2014 +0200

compilation: fix warnings: build_dm_uuid now accepts whole struct logical_volume, not lvid

replicator/replicator.c:338:2: warning: passing argument 2 of 'build_dm_uuid' from incompatible pointer type [enabled by default]
replicator/replicator.c:629:3: warning: passing argument 2 of 'build_dm_uuid' from incompatible pointer type [enabled by default]
replicator/replicator.c:644:6: warning: passing argument 2 of 'build_dm_uuid' from incompatible pointer type [enabled by default]
replicator/replicator.c:668:7: warning: passing argument 2 of 'build_dm_uuid' from incompatible pointer type [enabled by default]
replicator/replicator.c:677:4: warning: passing argument 2 of 'build_dm_uuid' from incompatible pointer type [enabled by default]
---
 lib/replicator/replicator.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 6a116d2..2e3632a 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -335,7 +335,7 @@ static int _replicator_add_target_line(struct dev_manager *dm,
 	if (!seg->rlog_lv)
 		return_0;
 
-	if (!(rlog_dlid = build_dm_uuid(mem, seg->rlog_lv->lvid.s, NULL)))
+	if (!(rlog_dlid = build_dm_uuid(mem, seg->rlog_lv, NULL)))
 		return_0;
 
 	dm_list_iterate_items(rsite, &seg->lv->rsites) {
@@ -626,7 +626,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 					      cmd->use_linear_target,
 					      seg->lv->vg->name, seg->lv->name))
 			return_0;
-		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL)))
+		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv, NULL)))
 			return_0;
 		return dm_tree_node_add_target_area(node, NULL, rdev_dlid, 0);
 	} else if (seg->lv->rdevice->rsite->site_index) {
@@ -641,7 +641,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 	 * must be present in dm_tree
 	 */
 	if (!seg_is_replicator_dev(seg) ||
-	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator->lvid.s, NULL)))
+	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator, NULL)))
 		return_0;
 
 	/* Select remote devices with the same device index */
@@ -665,7 +665,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 		}
 
 		if (!rdev->lv ||
-		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv->lvid.s, NULL)))
+		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv, NULL)))
 			return_0;
 
 		slog_dlid = NULL;
@@ -674,7 +674,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 		if (rdev->slog) {
 			slog_flags = DM_NOSYNC;
 			slog_size = (uint32_t) rdev->slog->size;
-			if (!(slog_dlid = build_dm_uuid(mem, rdev->slog->lvid.s, NULL)))
+			if (!(slog_dlid = build_dm_uuid(mem, rdev->slog, NULL)))
 				return_0;
 		} else if (rdev->slog_name &&
 			   sscanf(rdev->slog_name, "%" PRIu32, &slog_size) == 1) {


