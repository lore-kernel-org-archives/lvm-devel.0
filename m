From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:18 +0000 (UTC)
Subject: master - activation: optimize away lv_has_target_type
Message-ID: <20161205161518.447A1602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2c7e0ad1196cc9323b63807ed199bcf4b10807c
Commit:        e2c7e0ad1196cc9323b63807ed199bcf4b10807c
Parent:        6fd20be629b6dceb96702c5f875a2e612e6f465d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 5 15:23:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:10:14 2016 +0100

activation: optimize away lv_has_target_type

It's actually not needed to call extra lv_has_target_type() to detect
snapshot merge is in progress - decode this right during status
capturing and save even few extra ioctl calls.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   50 ++++++++++++++++++++++++++++------------------
 2 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a097477..df4c49e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Avoid using lv_has_target_type() call within lv_info_with_seg_status.
   Simplify internal lv_info_with_seg_status API.
   Decide which status is needed in one place for lv_info_with_seg_status.
   Fix matching of LV segment when checking for it info status.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index afdf518..3128f36 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -757,7 +757,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 			    struct lv_with_info_and_seg_status *status,
 			    int with_open_count, int with_read_ahead)
 {
-	const struct logical_volume *lv = status->lv = lv_seg->lv;
+	const struct logical_volume *olv, *lv = status->lv = lv_seg->lv;
 
 	if (!activation())
 		return 0;
@@ -780,36 +780,46 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 				status->info.exists = 0; /* So pool LV is not active */
 		}
 		return 1;
-	} else if (lv_is_origin(lv) &&
-		   (!lv_is_merging_origin(lv) ||
-		    !lv_has_target_type(cmd->mem, lv, NULL, TARGET_NAME_SNAPSHOT_MERGE))) {
+	} else if (lv_is_origin(lv)) {
 		/* Query segment status for 'layered' (-real) device most of the time,
 		 * only for merging snapshot, query its progress.
 		 * TODO: single LV may need couple status to be exposed at once....
 		 *       but this needs more logical background
 		 */
-		/* Show INFO for actual origin */
-		if (!_lv_info(cmd, lv, 0, &status->info, NULL, NULL, with_open_count, with_read_ahead))
+		/* Show INFO for actual origin and grab status for merging origin */
+		if (!_lv_info(cmd, lv, 0, &status->info, lv_seg,
+			      lv_is_merging_origin(lv) ? &status->seg_status : NULL,
+			      with_open_count, with_read_ahead))
 			return_0;
 
-		if (status->info.exists)
+		if (status->info.exists &&
+		    (status->seg_status.type != SEG_STATUS_SNAPSHOT)) /* Not merging */
 			/* Grab STATUS from layered -real */
 			(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
 		return 1;
 	} else if (lv_is_cow(lv)) {
-		if (lv_is_merging_cow(lv) &&
-		    lv_has_target_type(cmd->mem, origin_from_cow(lv), NULL, TARGET_NAME_SNAPSHOT_MERGE)) {
-			/*
-			 * When merge is in progress, query merging origin LV instead.
-			 * COW volume is already mapped as error target in this case.
-			 */
-			status->lv = lv = origin_from_cow(lv);
-			lv_seg = first_seg(lv);
-			log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
-					     display_lvname(lv));
-		} else
-			/* Hadle fictional lvm2 snapshot and query snapshotX volume */
-			lv_seg = find_snapshot(lv);
+		if (lv_is_merging_cow(lv)) {
+			olv = origin_from_cow(lv);
+
+			if (!_lv_info(cmd, olv, 0, &status->info, first_seg(olv), &status->seg_status,
+				      with_open_count, with_read_ahead))
+				return_0;
+
+			if (status->seg_status.type == SEG_STATUS_SNAPSHOT) {
+				log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
+						     display_lvname(lv));
+				/*
+				 * When merge is in progress, query merging origin LV instead.
+				 * COW volume is already mapped as error target in this case.
+				 */
+				status->lv = olv;
+				return 1;
+			}
+
+			/* Merge not yet started, still a snapshot... */
+		}
+		/* Hadle fictional lvm2 snapshot and query snapshotX volume */
+		lv_seg = find_snapshot(lv);
 	}
 
 	return _lv_info(cmd, lv, 0, &status->info, lv_seg, &status->seg_status,


