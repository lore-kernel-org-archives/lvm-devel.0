From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:13 +0000 (GMT)
Subject: stable-2.02 - alloc: improve estimation of sufficient_pes_free
Message-ID: <20201016191113.4CC89396EC6A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8744d97c7b974a1ad990a0b7e61fa496a9500a52
Commit:        8744d97c7b974a1ad990a0b7e61fa496a9500a52
Parent:        6b1f67da0699d408477b6cdd79cdd34f8b4b98cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 20:57:20 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

alloc: improve estimation of sufficient_pes_free

Metadata size was calculated correctly only for raids.

Fixes problem for crash during lvcreate when thin-pool was created
on a VG where remaining free space had the size to only fit a single
metadata LV and not also its _pmspare.

Lvcreate crashed with this assert message:

lvcreate: metadata/pv_map.c:198: consume_pv_area: Assertion `to_go <= pva->count' failed.
Aborted (core dumped)

TODO: there is probably to large overload of several alloc_handle
variables.

Reported-by: Wu Guanghao<wuguanghao3@huawei.com>
Reported-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 WHATS_NEW               | 1 +
 lib/metadata/lv_manip.c | 6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c902ccde5..125e094ee 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Improve estimation of needed extents when creating thin-pool.
   Use extra 1% when resizing thin-pool metadata LV with --use-policy.
   Enhance --use-policy percentage rounding.
   Switch code base to use flexible array syntax.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 74b2afa96..cbd4798ac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1698,12 +1698,12 @@ static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 {
 	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
 	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
-	uint32_t metadata_extents_needed = ah->alloc_and_split_meta ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
-	uint32_t total_extents_needed = area_extents_needed + parity_extents_needed + metadata_extents_needed;
+	uint32_t metadata_extents_needed = ah->alloc_and_split_meta ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN + ah->log_len; /* One each */
+	uint64_t total_extents_needed = (uint64_t)area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 
 	if (total_extents_needed > free_pes) {
-		log_error("Insufficient free space: %" PRIu32 " extents needed,"
+		log_error("Insufficient free space: %" PRIu64 " extents needed,"
 			  " but only %" PRIu32 " available",
 			  total_extents_needed, free_pes);
 		return 0;


