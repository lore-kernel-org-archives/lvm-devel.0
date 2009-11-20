From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:41 -0500
Subject: [PATCH 01/15] use snapshot metadata usage to determine if snapshot is empty
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Future dm-snapshot will append metadata sectors used to a snapshot's
status.  This patch allows LVM2 to accurately determine if the snapshot
store is empty.  Knowing when a snapshot store is empty is important in
the context of snapshot-merge (means merge is complete).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/snapshot/snapshot.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index d5bac31..6b1a0e2 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -95,15 +95,17 @@ static int _snap_target_percent(void **target_state __attribute((unused)),
 				char *params, uint64_t *total_numerator,
 				uint64_t *total_denominator)
 {
-	uint64_t numerator, denominator;
+	uint64_t total_sectors, sectors_allocated, metadata_sectors = 0;
+	int r;
 
-	if (sscanf(params, "%" PRIu64 "/%" PRIu64,
-		   &numerator, &denominator) == 2) {
-		*total_numerator += numerator;
-		*total_denominator += denominator;
-		if (!numerator)
+	r = sscanf(params, "%" PRIu64 "/%" PRIu64 " %" PRIu64,
+		   &sectors_allocated, &total_sectors, &metadata_sectors);
+	if (r == 2 || r == 3) {
+		*total_numerator += sectors_allocated;
+		*total_denominator += total_sectors;
+		if (sectors_allocated == metadata_sectors)
 			*percent_range = PERCENT_0;
-		else if (numerator == denominator)
+		else if (sectors_allocated == total_sectors)
 			*percent_range = PERCENT_100;
 		else
 			*percent_range = PERCENT_0_TO_100;
-- 
1.6.5.2


