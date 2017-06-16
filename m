From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:31 -0400
Subject: master - cleanup: use 'dm_get_status_raid'
Message-ID: <201706161513.v5GFDVjZ011185@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7c9ec8a24a0271e55ea5aa0c9f6525011d0fa0c
Commit:        b7c9ec8a24a0271e55ea5aa0c9f6525011d0fa0c
Parent:        59d646167f8f47fbef3231469675f52d90432205
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 16 10:48:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:01 2017 +0200

cleanup: use 'dm_get_status_raid'

Use single 'dm' call to parse raid status.
(Avoiding multiple parsers - even when we know it's slighly
less efficient).
---
 lib/raid/raid.c |   37 +++++++++++--------------------------
 1 files changed, 11 insertions(+), 26 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 969007c..c5cfb0f 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -358,36 +358,21 @@ static int _raid_target_percent(void **target_state,
 				uint64_t *total_numerator,
 				uint64_t *total_denominator)
 {
-	int i;
-	uint64_t numerator, denominator;
-	char *pos = params;
-	/*
-	 * Status line:
-	 *    <raid_type> <#devs> <status_chars> <synced>/<total>
-	 * Example:
-	 *    raid1 2 AA 1024000/1024000
-	 */
-	for (i = 0; i < 3; i++) {
-		pos = strstr(pos, " ");
-		if (pos)
-			pos++;
-		else
-			break;
-	}
-	if (!pos || (sscanf(pos, FMTu64 "/" FMTu64 "%n", &numerator, &denominator, &i) != 2) ||
-	    !denominator) {
-		log_error("Failed to parse %s status fraction: %s",
-			  (seg) ? seg->segtype->name : "segment", params);
-		return 0;
-	}
+	struct dm_status_raid *sr;
+
+	if (!dm_get_status_raid(mem, params, &sr))
+		return_0;
 
-	*total_numerator += numerator;
-	*total_denominator += denominator;
+	*total_numerator += sr->insync_regions;
+	*total_denominator += sr->total_regions;
 
 	if (seg)
-		seg->extents_copied = (uint64_t) seg->area_len * dm_make_percent(numerator, denominator) / DM_PERCENT_100;
+		seg->extents_copied = (uint64_t) seg->area_len
+			* dm_make_percent(sr->insync_regions , sr->total_regions) / DM_PERCENT_100;
+
+	*percent = dm_make_percent(sr->insync_regions, sr->total_regions);
 
-	*percent = dm_make_percent(numerator, denominator);
+	dm_pool_free(mem, sr);
 
 	return 1;
 }


