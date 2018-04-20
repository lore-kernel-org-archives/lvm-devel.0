From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:34 -0400
Subject: master - mirror: fix 32bit size calculation
Message-ID: <201804201101.w3KB1YpC031152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73189170f53ea661e7bf117404cdb5f461f0df1b
Commit:        73189170f53ea661e7bf117404cdb5f461f0df1b
Parent:        ff3ffe30e4c3ceac4abbdece7068bf7299a8ab39
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 19 12:29:42 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:08:57 2018 +0200

mirror: fix 32bit size calculation

On 32bit arch  size_t remains 4-byte wide - so size can't
get correct result for multiplication of 32bit numbers.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 15908ca..0bb94aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix incorrect mirror log size calculation on 32bit arch.
   Enhnace preloading tree creating.
   Fix regression on acceptance of any LV on lvconvert.
   Restore usability of thin LV to be again external origin for another thin.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index da5e355..f275ecd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1667,9 +1667,9 @@ struct alloc_handle {
 #define BYTE_SHIFT 3
 static uint32_t _mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint32_t area_len)
 {
-	size_t area_size, bitset_size, log_size, region_count;
+	uint64_t area_size, region_count, bitset_size, log_size;
 
-	area_size = (size_t)area_len * pe_size;
+	area_size = (uint64_t) area_len * pe_size;
 	region_count = dm_div_up(area_size, region_size);
 
 	/* Work out how many "unsigned long"s we need to hold the bitset. */


