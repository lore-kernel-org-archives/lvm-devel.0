From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:25 +0000 (GMT)
Subject: stable-2.02 - allocation: report allocation error instead of crash
Message-ID: <20210201133825.2282E3834437@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1282e9e2984a6ad48e9ee09a15dce7f3aab3e833
Commit:        1282e9e2984a6ad48e9ee09a15dce7f3aab3e833
Parent:        862a86982cef87779e361987fbcc62f15729ecef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 10:24:19 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:35:53 2021 +0100

allocation: report allocation error instead of crash

Current allocation limitation requires to fit metadata/log LV on
a single PV. This is usually not a big problem, but since
thin-pool and cache-pool is using this for allocating extents
for their metadata LVs it might be eventually causing errors
where the remaining free spaces for large metadata size is spread
over several PV.
---
 lib/metadata/lv_manip.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8bfa33a0a..e48e5d18f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1934,15 +1934,18 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 			aa[smeta].pv = pva->map->pv;
 			aa[smeta].pe = pva->start;
 			aa[smeta].len = ah->log_len;
-
+			if (aa[smeta].len > pva->count) {
+				log_error("Metadata does not fit on a single PV.");
+				return 0;
+			}
 			log_debug_alloc("Allocating parallel metadata area %" PRIu32
 					" on %s start PE %" PRIu32
 					" length %" PRIu32 ".",
 					(smeta - (ah->area_count + ah->parity_count)),
 					pv_dev_name(aa[smeta].pv), aa[smeta].pe,
-					ah->log_len);
+					aa[smeta].len);
 
-			consume_pv_area(pva, ah->log_len);
+			consume_pv_area(pva, aa[smeta].len);
 			dm_list_add(&ah->alloced_areas[smeta], &aa[smeta].list);
 		}
 		aa[s].len = (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) ? len - ah->log_len : len;


