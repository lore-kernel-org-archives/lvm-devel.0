From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Sep 2013 16:30:29 +0000 (UTC)
Subject: master - RAID: Fix _sufficient_pes_free calculation for RAID
Message-ID: <20130926163029.41D256107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=acdc731e83f7ba646a5e3c55398032464605ee58
Commit:        acdc731e83f7ba646a5e3c55398032464605ee58
Parent:        d6516d2f7900aa233c2a96e171b355bec7e54395
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Sep 26 11:30:07 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Sep 26 11:30:07 2013 -0500

RAID: Fix _sufficient_pes_free calculation for RAID

lib/metadata/lv_manip.c:_sufficient_pes_free() was calculating the
required space for RAID allocations incorrectly due to double
accounting.  This resulted in failure to allocate when available
space was tight.

When RAID data and metadata areas are allocated together, the total
amount is stored in ah->new_extents and ah->alloc_and_split_meta is
set.  '_sufficient_pes_free' was adding the necessary metadata extents
to ah->new_extents without ever checking ah->alloc_and_split_meta.
This often led to double accounting of the metadata extents.  This
patch checks 'ah->alloc_and_split_meta' to perform proper calculations
for RAID.

This error is only present in the function that checks for the needed
space, not in the functions that do the actual allocation.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7750d2e..3a307c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Fix RAID calculation for sufficient allocatable space.
   Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
   Add lvm.conf allocation/thin_pool_chunk_size_calculation option.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f945b79..3789566 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1162,7 +1162,7 @@ static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 {
 	uint32_t area_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
 	uint32_t parity_extents_needed = (extents_still_needed - allocated) * ah->parity_count / ah->area_multiple;
-	uint32_t metadata_extents_needed = ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
+	uint32_t metadata_extents_needed = (ah->alloc_and_split_meta) ? 0 : ah->metadata_area_count * RAID_METADATA_AREA_LEN; /* One each */
 	uint32_t total_extents_needed = area_extents_needed + parity_extents_needed + metadata_extents_needed;
 	uint32_t free_pes = pv_maps_size(pvms);
 


