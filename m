From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 22 Jan 2010 09:15:32 -0500
Subject: [PATCH 3/3] Return error if _percent_run is unable to get a percentage.
In-Reply-To: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
References: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
Message-ID: <1264169732-8692-4-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The original behavior of assuming the percentage is 100% leads to
endless polling in the case of snapshot-merge.  This happens when one
polldaemon is racing with another (polling the same LV).  The first to
see the LV status reach the "finished" state will alter the LV that the
other polldaemon(s) are polling.
---
 lib/activate/dev_manager.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 25b7a10..25160e3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -509,18 +509,12 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	if (total_denominator) {
 		*percent = (float) total_numerator *100 / total_denominator;
 		*overall_percent_range = combined_percent_range;
-	} else {
+	} else if (!first_time) {
 		*percent = 100;
-		if (first_time) {
-			/* above ->target_percent() was not executed! */
-			/* FIXME why return PERCENT_100 et. al. in this case? */
-			*overall_percent_range = PERCENT_100;
-			if (lv && lv_is_merging_origin(lv)) {
-				/* must fail in snapshot-merge case */
-				goto_out;
-			}
-		} else
-			*overall_percent_range = combined_percent_range;
+		*overall_percent_range = combined_percent_range;
+	} else {
+		/* above ->target_percent() was not executed! */
+		goto_out;
 	}
 
 	log_debug("LV percent: %f", *percent);
-- 
1.6.6


