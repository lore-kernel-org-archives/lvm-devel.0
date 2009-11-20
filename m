From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:48 -0500
Subject: [PATCH 08/15] lvm-merge-reporting
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-9-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Report merging snapshot as 'S' instead of 's':
This is useful for when the snapshot is still active and merging hasn't
started yet; it shows a merge is pending.  Once merging starts the
merging snapshot will be hidden but can still be displayed with 'lvs -a'

Report snapshot origin with merging snapshot as 'O' instead of 'o':
Before merge starts this shows that a merge is pending.  While merging
the snapshot will be hidden, 'O' enables a user to see that there is a
snapshot merging.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/report/report.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 54192d5..9b3fd0d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -314,8 +314,12 @@ static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 	else if (lv->status & VIRTUAL)
 		repstr[0] = 'v';
 	/* Origin takes precedence over Mirror */
-	else if (lv_is_origin(lv))
-		repstr[0] = 'o';
+	else if (lv_is_origin(lv)) {
+		if (lv->merging_snapshot)
+			repstr[0] = 'O';
+		else
+			repstr[0] = 'o';
+	}
 	else if (lv->status & MIRRORED) {
 		if (lv->status & MIRROR_NOTSYNCED)
 			repstr[0] = 'M';
@@ -328,9 +332,12 @@ static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_
 			repstr[0] = 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
-	else if (lv_is_cow(lv))
-		repstr[0] = 's';
-	else
+	else if (lv_is_cow(lv)) {
+		if (find_cow(lv)->status & SNAPSHOT_MERGE)
+			repstr[0] = 'S';
+		else
+			repstr[0] = 's';
+	} else
 		repstr[0] = '-';
 
 	if (lv->status & PVMOVE)
-- 
1.6.5.2


