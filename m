From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  6 Nov 2015 00:12:54 +0000 (UTC)
Subject: master - mirror: Fix log size calc when more than 1 extent.
Message-ID: <20151106001254.0EEB061084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8096f2224c0502a0cb56aaebd59d836daa677bc2
Commit:        8096f2224c0502a0cb56aaebd59d836daa677bc2
Parent:        16780f6faa4fc24613720acc893f9f14955a6053
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Nov 5 23:40:47 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Nov 5 23:40:47 2015 +0000

mirror: Fix log size calc when more than 1 extent.

Currently the code creates the log separately after allocating space for
the data and as no data allocation is needed this second time,
total_extents ends up holding zero so use new_extents directly instead.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7431483..015eba0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.134 - 
 ====================================
+  Pass correct data size to mirror log calc so log can be bigger than 1 extent.
 
 Version 2.02.133 - 30th October 2015
 ====================================
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2310bfa..3c72c08 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1579,7 +1579,7 @@ struct alloc_handle {
  * Returns log device size in extents, algorithm from kernel code
  */
 #define BYTE_SHIFT 3
-static uint32_t mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint32_t area_len)
+static uint32_t _mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint32_t area_len)
 {
 	size_t area_size, bitset_size, log_size, region_count;
 
@@ -3281,12 +3281,15 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
-			mirror_log_extents(ah->region_size, extent_size,
-					   (existing_extents + total_extents) / ah->area_multiple);
+			_mirror_log_extents(ah->region_size, extent_size,
+					    (existing_extents + new_extents) / ah->area_multiple);
 	}
 
 	log_debug("Adjusted allocation request to %" PRIu32 " logical extents. Existing size %" PRIu32 ". New size %" PRIu32 ".",
 		  total_extents, existing_extents, total_extents + existing_extents);
+	if (ah->log_len)
+		log_debug("Mirror log of %" PRIu32 " extents of size %" PRIu32 "sectors needed for region size %" PRIu32  ".",
+			  ah->log_len, extent_size, ah->region_size);
 
 	if (mirrors || stripes)
 		total_extents += existing_extents;


