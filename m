From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 13 Jan 2021 10:09:18 +0000 (GMT)
Subject: stable-2.02 - alloc: enhance estimation of sufficient_pes_free
Message-ID: <20210113100918.CC65D385B805@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=194630be52b6459b331fcf338539c82263125162
Commit:        194630be52b6459b331fcf338539c82263125162
Parent:        b98c3346350b7c270140c1f21fda0436876e16e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 12 15:58:07 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 13 10:40:46 2021 +0100

alloc: enhance estimation of sufficient_pes_free

Since commit 77fdc17d70e62cab75efaaf0dad02493b948610d always include
log_len size into needed extents - however now we may need sometimes
more extents then necessary - mainly when multiple PVs are involved
into allocation.

Add logs_still_needed into calculation of sufficient_pes_free()
---
 lib/metadata/lv_manip.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e96a04a69..346ec9f77 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1700,11 +1700,13 @@ static uint32_t _mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint
 
 /* Is there enough total space or should we give up immediately? */
 static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
-				uint32_t allocated, uint32_t extents_still_needed)
+				uint32_t allocated, uint32_t log_still_needed,
+				uint32_t extents_still_needed)
 {
 	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
 	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
-	uint32_t metadata_extents_needed = ah->alloc_and_split_meta ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN + ah->log_len; /* One each */
+	uint32_t metadata_extents_needed = (ah->alloc_and_split_meta ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN) +
+	    (log_still_needed ? ah->log_len : 0); /* One each */
 	uint64_t total_extents_needed = (uint64_t)area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 
@@ -3200,7 +3202,9 @@ static int _allocate(struct alloc_handle *ah,
 		old_allocated = alloc_state.allocated;
 		log_debug_alloc("Trying allocation using %s policy.", get_alloc_string(alloc));
 
-		if (!ah->approx_alloc && !_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
+		if (!ah->approx_alloc && !_sufficient_pes_free(ah, pvms, alloc_state.allocated,
+							       alloc_state.log_area_count_still_needed,
+							       ah->new_extents))
 			goto_out;
 
 		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg,


