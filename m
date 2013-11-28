From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:49 +0000 (UTC)
Subject: master - snapshot: move code of old snapshot merge
Message-ID: <20131128114849.12BAA60F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8724c0fcebcc35df980e6819e5c531f213fe2767
Commit:        8724c0fcebcc35df980e6819e5c531f213fe2767
Parent:        b3679590dfb9839196c36ac74b86377ae2a10f8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 26 12:09:41 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:45:28 2013 +0100

snapshot: move code of old snapshot merge

Move code for merging old snapshot into its own function.
---
 tools/lvconvert.c |   68 ++++++++++++++++++++++++++++------------------------
 1 files changed, 37 insertions(+), 31 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 051463b..34c8de2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1884,31 +1884,59 @@ static int lvconvert_snapshot(struct cmd_context *cmd,
 	return 1;
 }
 
-static int lvconvert_merge(struct cmd_context *cmd,
-			   struct logical_volume *lv,
-			   struct lvconvert_params *lp)
+static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct lvconvert_params *lp)
 {
 	int r = 0;
 	int merge_on_activate = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *snap_seg = find_snapshot(lv);
 	struct lvinfo info;
+	percent_t snap_percent;
 
 	/* Check if merge is possible */
+	if (!lv_is_cow(lv)) {
+		log_error("\"%s\" is not a mergeable logical volume.",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv_is_merging_cow(lv)) {
-		log_error("Snapshot %s is already merging", lv->name);
+		log_error("Snapshot %s is already merging.", lv->name);
 		return 0;
 	}
+
 	if (lv_is_merging_origin(origin)) {
 		log_error("Snapshot %s is already merging into the origin.",
 			  find_snapshot(origin)->cow->name);
 		return 0;
 	}
+
 	if (lv_is_virtual_origin(origin)) {
 		log_error("Snapshot %s has virtual origin.", lv->name);
 		return 0;
 	}
 
+	if (lv_is_external_origin(origin_from_cow(lv))) {
+		log_error("Cannot merge snapshot \"%s\" into "
+			  "the read-only external origin \"%s\".",
+			  lv->name, origin_from_cow(lv)->name);
+		return 0;
+	}
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)
+	    && info.exists && info.live_table &&
+	    (!lv_snapshot_percent(lv, &snap_percent) ||
+	     snap_percent == PERCENT_INVALID)) {
+		log_error("Unable to merge invalidated snapshot LV \"%s\".",
+			  lv->name);
+		return 0;
+	}
+
+	if (!archive(lv->vg))
+		return_0;
+
 	/*
 	 * Prevent merge with open device(s) as it would likely lead
 	 * to application/filesystem failure.  Merge on origin's next
@@ -1955,7 +1983,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 
 	/* Perform merge */
 	if (!suspend_lv(cmd, origin)) {
-		log_error("Failed to suspend origin %s", origin->name);
+		log_error("Failed to suspend origin %s.", origin->name);
 		vg_revert(lv->vg);
 		goto out;
 	}
@@ -1967,7 +1995,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	}
 
 	if (!resume_lv(cmd, origin)) {
-		log_error("Failed to reactivate origin %s", origin->name);
+		log_error("Failed to reactivate origin %s.", origin->name);
 		goto out;
 	}
 
@@ -1978,6 +2006,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	log_print_unless_silent("Merging of volume %s started.", lv->name);
 out:
 	backup(lv->vg);
+
 	return r;
 }
 
@@ -2588,8 +2617,6 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct lvconvert_params *lp = handle;
 	struct dm_list *failed_pvs;
-	struct lvinfo info;
-	percent_t snap_percent;
 
 	if (lv->status & LOCKED) {
 		log_error("Cannot convert locked LV %s", lv->name);
@@ -2634,29 +2661,8 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 	if (lp->merge) {
-		if (!lv_is_cow(lv)) {
-			log_error("\"%s\" is not a mergeable logical volume",
-				  lv->name);
-			return ECMD_FAILED;
-		}
-		if (lv_is_external_origin(origin_from_cow(lv))) {
-			log_error("Cannot merge snapshot \"%s\" into "
-				  "the read-only external origin \"%s\".",
-				  lv->name, origin_from_cow(lv)->name);
-			return ECMD_FAILED;
-		}
-	        if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)
-		    && info.exists && info.live_table &&
-		    (!lv_snapshot_percent(lv, &snap_percent) ||
-		     snap_percent == PERCENT_INVALID)) {
-			log_error("Unable to merge invalidated snapshot LV \"%s\"", lv->name);
-			return ECMD_FAILED;
-		}
-		if (!archive(lv->vg))
-			return_ECMD_FAILED;
-
-		if (!lvconvert_merge(cmd, lv, lp)) {
-			log_error("Unable to merge LV \"%s\" into its origin.", lv->name);
+		if (!_lvconvert_merge_old_snapshot(cmd, lv, lp)) {
+			log_print_unless_silent("Unable to merge LV \"%s\" into its origin.", lv->name);
 			return ECMD_FAILED;
 		}
 	} else if (lp->snapshot) {


