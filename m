From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:08 -0500
Subject: master - parser: allow --zero for pool conversion
Message-ID: <201703101836.v2AIa8wx021737@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07c24736e088755b01134d164c3f155e368b6bc5
Commit:        07c24736e088755b01134d164c3f155e368b6bc5
Parent:        46820bfff3f40d58d28500ce9caafb8625211597
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 3 11:31:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

parser: allow --zero for pool conversion

---
 tools/command-lines.in |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 3a449ef..d73005f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -308,7 +308,8 @@ OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
 --stripesize SizeKB, --regionsize RegionSize, --interval Number
 
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
---poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB
+--poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
+--zero Bool
 
 OO_LVCONVERT_CACHE: --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool
@@ -423,7 +424,7 @@ FLAGS: SECONDARY_SYNTAX
 # Create a new command set for these and migrate them out of lvconvert?
 
 lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache
-OO: --thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO: --thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
 RULE: all and lv_is_visible
@@ -431,7 +432,7 @@ RULE: all not lv_is_locked
 
 # alternate form of lvconvert --type thin
 lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
-OO: --type thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO: --type thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin
 DESC: (infers --type thin).
@@ -459,7 +460,7 @@ FLAGS: SECONDARY_SYNTAX
 
 lvconvert --type thin-pool LV_linear_striped_raid_cache
 OO: --stripes_long Number, --stripesize SizeKB,
---discards Discards, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+--discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
@@ -490,7 +491,7 @@ RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_orig
 
 lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
 OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
---discards Discards, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+--discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
 DESC: Convert LV to type thin-pool (variant, use --type thin-pool).


