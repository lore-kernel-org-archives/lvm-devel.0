From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:02:57 +0000 (UTC)
Subject: master - report: reporting unknown status
Message-ID: <20150120140257.AA5F360D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e34b004422f0d51263e0d34f4064556cfc9148f6
Commit:        e34b004422f0d51263e0d34f4064556cfc9148f6
Parent:        64d8ed502d29a1f19416280bb0e3f346e7f2668c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 12:38:38 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 14:53:07 2015 +0100

report: reporting unknown status

Add SEG_STATUS_UNKNOWN when status cannot be parsed.
Also add 'info_ok' variable when info was correctly obtained.
---
 lib/activate/activate.h |    4 +++-
 tools/reporter.c        |   20 ++++++++------------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 1376ce5..7cb8271 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -36,7 +36,8 @@ typedef enum {
 	SEG_STATUS_RAID,
 	SEG_STATUS_SNAPSHOT,
 	SEG_STATUS_THIN,
-	SEG_STATUS_THIN_POOL
+	SEG_STATUS_THIN_POOL,
+	SEG_STATUS_UNKNOWN
 } lv_seg_status_type_t;
 
 struct lv_seg_status {
@@ -48,6 +49,7 @@ struct lv_seg_status {
 
 struct lv_with_info_and_seg_status {
 	const struct logical_volume *lv;	/* input */
+	int info_ok;
 	struct lvinfo info;			/* output */
 	int seg_part_of_lv;			/* output */
 	struct lv_seg_status seg_status;	/* input/output, see lv_seg_status */
diff --git a/tools/reporter.c b/tools/reporter.c
index f803dd8..6c278cb 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -57,27 +57,23 @@ static int _do_info_and_status(struct cmd_context *cmd,
 				struct lv_with_info_and_seg_status *status,
 				int do_info, int do_status)
 {
-	status->seg_status.mem = NULL;
+	unsigned use_layer = lv_is_thin_pool(lv) ? 1 : 0;
 
+	status->lv = lv;
 	if (do_status) {
 		if (!(status->seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 			return_0;
 		if (!lv_seg)
 			_choose_lv_segment_for_status_report(lv, &lv_seg);
-		if (do_info) {
+		if (do_info)
 			/* both info and status */
-			if (!lv_info_with_seg_status(cmd, lv, lv_seg, 0, status, 1, 1))
-				status->info.exists = 0;
-		} else {
+			status->info_ok = lv_info_with_seg_status(cmd, lv, lv_seg, use_layer, status, 1, 1);
+		else
 			/* status only */
-			if (!lv_status(cmd, lv_seg, &status->seg_status))
-				status->info.exists = 0;
-		}
-	} else if (do_info) {
+			status->info_ok = lv_status(cmd, lv_seg, use_layer, &status->seg_status);
+	} else if (do_info)
 		/* info only */
-		if (!lv_info(cmd, lv, 0, &status->info, 1, 1))
-			status->info.exists = 0;
-	}
+		status->info_ok = lv_info(cmd, lv, use_layer, &status->info, 1, 1);
 
 	return 1;
 }


