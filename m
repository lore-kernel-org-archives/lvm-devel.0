From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:06 +0000 (UTC)
Subject: master - lvconvert: reoder old snapshot merge
Message-ID: <20140924085706.B87DF60D58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c96665e6a88780e31a84f9fb287c2e30c7552b0c
Commit:        c96665e6a88780e31a84f9fb287c2e30c7552b0c
Parent:        84cdf85bd2d682f11deeff51e39f3bfb98753829
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 23 20:23:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

lvconvert: reoder old snapshot merge

Move check for snapshot-merge support before archiving.

Split code on 2 paths - with merge_on_activate
using vg_write & vg_commit
and lv_update_reload call for instant merging.

Move printing after backup.
---
 tools/lvconvert.c |   68 +++++++++++++++++-----------------------------------
 1 files changed, 22 insertions(+), 46 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0978172..9f9ec5d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2100,7 +2100,6 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 					 struct logical_volume *lv,
 					 struct lvconvert_params *lp)
 {
-	int r = 0;
 	int merge_on_activate = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *snap_seg = find_snapshot(lv);
@@ -2146,6 +2145,13 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (snap_seg->segtype->ops->target_present &&
+	    !snap_seg->segtype->ops->target_present(cmd, snap_seg, NULL)) {
+		log_error("Can't initialize snapshot merge. "
+			  "Missing support in kernel?");
+		return 0;
+	}
+
 	if (!archive(lv->vg))
 		return_0;
 
@@ -2171,58 +2177,28 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 
 	init_snapshot_merge(snap_seg, origin);
 
-	if (snap_seg->segtype->ops->target_present &&
-	    !snap_seg->segtype->ops->target_present(snap_seg->lv->vg->cmd,
-						    snap_seg, NULL)) {
-		log_error("Can't initialize snapshot merge. "
-			  "Missing support in kernel?");
-		return 0;
-	}
-
-	/* store vg on disk(s) */
-	if (!vg_write(lv->vg))
-		return_0;
-
 	if (merge_on_activate) {
-		/* commit vg but skip starting the merge */
-		if (!vg_commit(lv->vg))
+		/* Store and commit vg but skip starting the merge */
+		if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+			return_0;
+		backup(lv->vg);
+	} else {
+		/* Perform merge */
+		if (!lv_update_and_reload(origin))
 			return_0;
-		r = 1;
-		log_print_unless_silent("Merging of snapshot %s will occur on "
-					"next activation of %s.",
-					display_lvname(lv), display_lvname(origin));
-		goto out;
-	}
-
-	/* Perform merge */
-	if (!suspend_lv(cmd, origin)) {
-		log_error("Failed to suspend origin %s.", origin->name);
-		vg_revert(lv->vg);
-		goto out;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		if (!resume_lv(cmd, origin))
-			stack;
-		goto_out;
-	}
 
-	if (!resume_lv(cmd, origin)) {
-		log_error("Failed to reactivate origin %s.", origin->name);
-		goto out;
+		lp->need_polling = 1;
+		lp->lv_to_poll = origin;
 	}
 
-	lp->need_polling = 1;
-	lp->lv_to_poll = origin;
-
-	r = 1;
-out:
-	backup(lv->vg);
-
-	if (r)
+	if (merge_on_activate)
+		log_print_unless_silent("Merging of snapshot %s will occur on "
+					"next activation of %s.",
+					display_lvname(lv), display_lvname(origin));
+	else
 		log_print_unless_silent("Merging of volume %s started.", lv->name);
 
-	return r;
+	return 1;
 }
 
 static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,


