From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:33 +0000 (GMT)
Subject: dev-next - cleanup: reduce code dupliction
Message-ID: <20210322153933.84262385480A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3d28b1b64ff6b89ac5150787f694e1db1794a1f
Commit:        d3d28b1b64ff6b89ac5150787f694e1db1794a1f
Parent:        d37b19aaaab0c28f4d1e4ae0690c73c0031a027b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 10:45:26 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:21:18 2021 +0100

cleanup: reduce code dupliction

---
 lib/raid/raid.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 941ba8dc8..2f1eb6cf8 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -441,12 +441,10 @@ static int _raid_target_percent(void **target_state,
 
 	*total_numerator += sr->insync_regions;
 	*total_denominator += sr->total_regions;
+	*percent = dm_make_percent(sr->insync_regions, sr->total_regions);
 
 	if (seg)
-		seg->extents_copied = (uint64_t) seg->area_len
-			* dm_make_percent(sr->insync_regions , sr->total_regions) / DM_PERCENT_100;
-
-	*percent = dm_make_percent(sr->insync_regions, sr->total_regions);
+		seg->extents_copied = (uint64_t) seg->area_len * *percent / DM_PERCENT_100;
 
 	dm_pool_free(mem, sr);
 


